# AGENTS.md

Notes for AI agents (Claude Code, Codex, Cursor …) working on ForeverMinimapTarget.

## What the addon does

WoW: Forever's minimap tracking menu (Blizzard_Minimap/Mainline/Minimap.lua, tag `MENU_MINIMAP_TRACKING`) only lists
filters from `MinimapConstants.OPTIONAL_FILTERS` or with a spell ID, unless the cvar `minimapTrackingShowAll` is on.
`Enum.MinimapTrackingFilter.Target` and `.Focus` are not in that list, so they vanished from the menu a few days
after launch, although `C_Minimap.SetTracking` still turns them on (verified in the client).

The addon hooks the menu with `Menu.ModifyMenu` and appends a divider plus one checkbox per filter. Entries are
looked up by `filterID` (the tracking index differs per class). Checkboxes show the live state from
`C_Minimap.GetTrackingInfo`. The game does not keep Target on across a relog (observed in the client), so the
wanted state is saved in `ForeverMinimapTargetCharDB` (SavedVariablesPerCharacter; Target defaults to on, Focus is
only touched once the player ticks it) and applied on every `PLAYER_ENTERING_WORLD` and again 3 s later. With
`minimapTrackingShowAll` on, the addon adds nothing and enforces nothing. Everything lives in `ForeverMinimapTarget.lua`;
the addon list icon is `Icon.tga` (64×64, scaled down from `media/logo.png`).

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
Releases (CurseForge project ID in the TOC), **only on tags** `v*`, never on a plain push.

1. Add the new version to `CHANGELOG.md` and commit.
2. Create an annotated tag `vX.Y.Z` and push it; that starts the upload.

Don't replace `## Version: @project-version@` by hand, the packager sets it from the tag. It sits in a `#@non-debug@`
block so a source checkout shows `dev` instead of the raw placeholder; the packager drops the `#@debug@` line and
uncomments the real one.
Tags and pushes only after the maintainer approves.
