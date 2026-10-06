# Gallery images

Source for the CurseForge gallery: one HTML page per image (1920×1080), shared look in `style.css`
(same frame as KeepOrSell). `minimap.svg`, `target.svg` and `focus.svg` are drawn by hand, not Blizzard assets.

Render all pages to JPG (or a single one with `sh render.sh 02-menu.html`):

```sh
sh render.sh
```

Not in the repo (Blizzard assets, git-ignored), fetch them before rendering:

- `fonts/FRIZQT__.TTF`: `curl -L -o fonts/FRIZQT__.TTF https://wago.tools/api/casc/615960`
- `icons/<name>.jpg`: `curl -o icons/<name>.jpg https://wow.zamimg.com/images/wow/icons/large/<name>.jpg`
  for every `icons/…` referenced in the pages and in `minimap.svg`
