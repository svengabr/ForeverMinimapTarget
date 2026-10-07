"""Fetches the WoW: Forever minimap textures used by reddit.html into assets/ (git-ignored, Blizzard assets).

Source is wago.tools (CASC files of the Forever build, product wow_cn_beta, Interface 16001). Atlas coordinates
come from the UiTextureAtlasMember table of the same build. Needs Pillow.
"""
import io
import os
import struct
import urllib.request

from PIL import Image

BUILD = "1.60.1.70235"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets")

# name: (fileDataID, left, right, top, bottom)
ATLAS = {
    "minimap-frame": (8026708, 1, 507, 1, 507),        # ui-hud-minimap-frame-c60-2x
    "minimap-day": (8026708, 595, 661, 509, 575),      # ui-hud-minimap-daycycle-c60-2x
    "button": (4618666, 441, 480, 402, 440),           # ui-hud-minimap-button-2x
    "tracking": (4618666, 149, 179, 520, 548),         # ui-hud-minimap-tracking-up-2x
    "mail": (4618666, 42, 81, 520, 550),               # ui-hud-minimap-mail-up-2x
    "calendar": (4618663, 93, 114, 106, 125),          # ui-hud-calendar-6-up
    "arrow-player": (4618666, 441, 486, 238, 283),     # ui-hud-minimap-arrow-player-2x
    "blip-target": (1121272, 549, 581, 548, 580),      # target
    "blip-focus": (1121272, 685, 717, 412, 444),       # focus
}

# Whole textures: tracking menu icons (interface/minimap/tracking/*.blp)
FILES = {"menu-target": 524052, "menu-focus": 524051, "menu-mailbox": 136459, "menu-repair": 136465,
         "menu-flightmaster": 136456}

# Minimap tiles around Northshire Abbey (world/minimaps/azeroth/mapX_Y.blp), stitched 2×2
TILES = {(31, 48): 204453, (32, 48): 204493, (31, 49): 204454, (32, 49): 204494}


def fetch(fdid):
    # Raw files are cached in assets/cache/, the big atlases take a while to download
    cached = os.path.join(OUT, "cache", f"{fdid}.blp")
    if os.path.exists(cached):
        with open(cached, "rb") as f:
            return f.read()
    url = f"https://wago.tools/api/casc/{fdid}?download&build={BUILD}"
    # wago.tools rejects Python's default user agent
    req = urllib.request.Request(url, headers={"User-Agent": "curl/8"})
    with urllib.request.urlopen(req) as resp:
        data = resp.read()
    os.makedirs(os.path.dirname(cached), exist_ok=True)
    with open(cached, "wb") as f:
        f.write(data)
    return data


def load_blp(data):
    # Pillow can't read uncompressed BLP2 (encoding 3, BGRA), which the HUD atlases use
    if data[:4] == b"BLP2" and data[8] == 3:
        w, h = struct.unpack_from("<II", data, 12)
        offset = struct.unpack_from("<I", data, 20)[0]
        return Image.frombytes("RGBA", (w, h), data[offset:offset + w * h * 4], "raw", "BGRA")
    return Image.open(io.BytesIO(data)).convert("RGBA")


def main():
    os.makedirs(OUT, exist_ok=True)
    sheets = {}
    for name, (fdid, left, right, top, bottom) in ATLAS.items():
        if fdid not in sheets:
            sheets[fdid] = load_blp(fetch(fdid))
        sheets[fdid].crop((left, top, right, bottom)).save(os.path.join(OUT, name + ".png"))
        print(name)
    for name, fdid in FILES.items():
        load_blp(fetch(fdid)).save(os.path.join(OUT, name + ".png"))
        print(name)
    tiles = {pos: load_blp(fetch(fdid)) for pos, fdid in TILES.items()}
    size = next(iter(tiles.values())).width
    terrain = Image.new("RGB", (size * 2, size * 2))
    for (x, y), tile in tiles.items():
        terrain.paste(tile.convert("RGB"), ((x - 31) * size, (y - 48) * size))
    terrain.save(os.path.join(OUT, "terrain.jpg"), quality=92)
    print("terrain")


if __name__ == "__main__":
    main()
