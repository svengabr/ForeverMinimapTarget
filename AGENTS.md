# AGENTS.md

Notes for AI agents (Claude Code, Codex, Cursor …) working on ForeverMinimapTarget.

## What the addon does

WoW: Forever's minimap tracking menu (Blizzard_Minimap/Mainline/Minimap.lua, tag `MENU_MINIMAP_TRACKING`) only lists
filters from `MinimapConstants.OPTIONAL_FILTERS` or with a spell ID, unless the cvar `minimapTrackingShowAll` is on.
`Enum.MinimapTrackingFilter.Target` and `.Focus` are not in that list, so they vanished from the menu a few days
after launch, although `C_Minimap.SetTracking` still turns them on (verified in the client).

The addon hooks the menu with `Menu.ModifyMenu` and appends a divider plus one checkbox per filter. Entries are
looked up by `filterID` (the tracking index differs per class). State is read live from
`C_Minimap.GetTrackingInfo`; the game saves it per character (`minimapTrackedInfov4`). With
`minimapTrackingShowAll` on, nothing is added. Everything lives in `ForeverMinimapTarget.lua`.

Note: Blizzard's "Uncheck all" re-enables the Target filter (it is in `CONDITIONAL_FILTERS`). That is Blizzard
behavior, not a bug here.

## Rules

- **English only in the repo**: code comments, commit messages, `AGENTS.md`, `CHANGELOG.md`, `README.md` and
  workflow files.
- Played and tested only on WoW: Forever (Interface 16001, Blizzard UI source: Gethe/wow-ui-source, branch
  `forever`).
- Commit messages follow Conventional Commits (`feat:`, `fix:`, `chore:` …).
- The README is also the **CurseForge project description**. After README changes, remind the maintainer to paste
  it there by hand.

## Checks

There are no unit tests. In-game behavior can only be checked in the client; say so honestly.

**luacheck:** `.luacheckrc` lists every global the addon uses; add new globals there.
Locally without a Lua install via Docker:
`docker run --rm -v "$PWD:/data" -w /data ghcr.io/lunarmodules/luacheck .`

## Release

Publishing is automatic via `.github/workflows/release.yml` (BigWigsMods/packager) to CurseForge and GitHub
Releases, **only on tags** `v*`. A CurseForge project ID (`## X-Curse-Project-ID`) is not set yet; add it to the
TOC once the project exists. Tags and pushes only after the maintainer approves.
