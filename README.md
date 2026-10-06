# Forever Minimap Target

A tiny addon for **World of Warcraft: Forever** that brings the **Target** and **Focus** entries back to the minimap tracking menu, so your current target and focus show up on the minimap again.

The game still supports both, but the tracking menu only lists them when the full tracking list is switched on. This addon adds the two checkboxes to the normal menu, below the other entries.

## Usage

Click the tracking button at the minimap and tick **Target** and/or **Focus**. The game does not keep these on across logins, so the addon saves your choice per character and sets it again after every loading screen. **Target** is on by default.

If you have switched on the full tracking list (`/console minimapTrackingShowAll 1`), the game already lists both entries and the addon does nothing.

## Install

1. Download the latest release zip.
2. Extract it so you have `World of Warcraft\_classic_beta_\Interface\AddOns\ForeverMinimapTarget`.
3. Restart the game or type `/reload`.

## Without the addon

You can switch target tracking on once per character with:

```
/run for i=1,C_Minimap.GetNumTrackingTypes() do local f=C_Minimap.GetTrackingFilter(i) if f and f.filterID==Enum.MinimapTrackingFilter.Target then C_Minimap.SetTracking(i,true) end end
```

## Support

The addon is free and always will be. If it made your game a bit nicer, you can [buy me a coffee](https://buymeacoffee.com/conoar).
