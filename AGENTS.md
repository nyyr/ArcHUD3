# AGENTS.md — ArcHUD3

Guidance for AI agents working in this repository. ArcHUD3 is a World of Warcraft addon (Ace3-based combat HUD) supporting **retail** and **every Classic re-release** (Vanilla/Anniversary, TBC, Wrath, Cata, MoP) from a shared Lua codebase with per-edition `.toc` files.

## Project layout

| Path | Purpose |
|---|---|
| `ArcHUD3.toc` | Mainline/retail TOC (`## Interface: 120100`, currently tracking Midnight 12.0.x) |
| `ArcHUD3_Vanilla.toc` | Classic Era / Anniversary (`Interface: 11509`), loads `embeds-vanilla.xml` + `Rings/Rings-classic.xml` |
| `ArcHUD3_TBC.toc` | Classic TBC (`Interface: 20506`) |
| `ArcHUD3_Wrath.toc` | Classic Wrath (`Interface: 30405`) |
| `ArcHUD3_Cata.toc` | Classic Cata (`Interface: 40402`), loads `Rings/Rings-mop.xml`-style split (check file list per TOC) |
| `ArcHUD3_MoP.toc` | Classic MoP (`Interface: 50504`) |
| `Core.lua` | Addon bootstrap: creates the `ArcHUD` Ace3 addon object, expansion/edition detection flags (`isClassicWoW`, `isMidnight`, etc.), `ArcHUD.defaults` (AceDB profile defaults), class/rep colors |
| `ModuleCore.lua` | `ArcHUD.modulePrototype` — shared lifecycle (`OnInitialize`, `OnEnable`, `InitConfigOptions`) that every "ring" module mixes into via `ArcHUD:NewModule(name)` |
| `RingTemplate.lua` / `RingTemplate.xml` | Low-level quadrant-based partial-arc rendering engine (`ArcHUDRingTemplate`) — the math/texture-coordinate core that draws the partial circular arcs |
| `Config.lua` | AceConfig options tables, slash command (`/archud` likely), profile management UI |
| `Frames.lua` / `Frames.xml` | Core HUD frame layout/anchors |
| `Nameplates.lua` | Nameplate integration |
| `BlizzardFrames.lua` | Hooks/adjustments to Blizzard's default UI frames (player/target/focus/spell-activation overlays) |
| `AuraContainers.lua` | Buff/debuff icon containers shown around rings |
| `Utils.lua` | Shared helper functions |
| `Rings/*.lua` + `Rings/Rings*.xml` | Individual "ring" modules — one per resource/feature (Health, Power, ComboPoints, HolyPower, SoulShards, Chi, Eclipse, Runes, Stagger, Essence, ArcaneCharges, Casting variants, Mirror Timer, Pet/Focus/Target variants, etc.). Each is a self-contained `ArcHUD:NewModule("Name")` with its own `defaults`, `options`, and `Initialize` |
| `Locales/*.lua` + `Locales.xml` | AceLocale string tables per language (`ArcHUD_Core`, `ArcHUD_Module` namespaces) |
| `Libs/` | **Empty except `.gitkeep`** — third-party libs (Ace3 suite, LibClassicCasterino, LibClassicDurations) are fetched as externals via `.pkgmeta`, not committed. Don't expect them to be present when just reading the repo |
| `.pkgmeta` | CurseForge/WowAce packager manifest: `package-as`, library externals list |
| `.github/workflows/release.yml`, `.travis.yml` | CI/release automation (BigWigsMods packager convention: `@project-version@`, `@project-date-iso@`, `@file-abbreviated-hash@` tokens get substituted at release time — do not "fix" these, they are intentional packager placeholders) |
| `Docs/` | `changelog.md`, `ring-prototypes.txt` (arc math notes, "a bit outdated"), `statrings.txt`, `history.txt` |

## Architecture notes

- **Ace3-based**: `ArcHUD = LibStub("AceAddon-3.0"):NewAddon("ArcHUD", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")`. Uses AceDB-3.0 for profiles (`ArcHUD3DB` SavedVariables), AceLocale-3.0 for i18n, AceConfig-3.0/AceGUI-3.0 for the options panel.
- **Module ("ring") pattern**: every feature lives in `Rings/*.lua` as `local module = ArcHUD:NewModule(moduleName)`, sets `module.defaults`/`module.options`/`module.unit`, and implements `module:Initialize()`. `ModuleCore.lua`'s `ArcHUD.modulePrototype` supplies the common `OnInitialize`/`OnEnable`/`InitConfigOptions` lifecycle and a per-module `:Debug(level, msg, ...)`. When adding a new ring, copy an existing `Rings/*.lua` file as the template rather than writing the lifecycle from scratch.
- **Edition detection flags** (set once in `Core.lua`, use these instead of re-deriving): `ArcHUD.isClassicWoW`, `isClassicTbc`, `isClassicWrath`, `isClassicCata`, `isClassicMop`, `ArcHUD.classic` (true up through Wrath), `ArcHUD.isMidnight` (12.0+ detection via `issecretvalue`/`UnitHealthPercent`/`C_CurveUtil` existence), `ArcHUD.hasHealPrediction`, `ArcHUD.hasAbsorbs`. Gate any edition-specific behavior on these rather than checking `WOW_PROJECT_ID` directly in ring files.
- **Casting info abstraction**: `ArcHUD.UnitCastingInfo` / `ArcHUD.UnitChannelInfo` are indirected through `LibClassicCasterino` on Classic Era; always call `ArcHUD.UnitCastingInfo(unit)`, never `UnitCastingInfo` directly, so Classic Era keeps working.
- **Ring rendering engine**: `RingTemplate.lua` divides each ring into 4 quadrants with dedicated subset/slice texture-coordinate functions. This is intentionally low-level texture math — read `Docs/ring-prototypes.txt` and `Docs/statrings.txt` before modifying it.
- **Midnight (12.0+) impact on rings**: per the README, secret-valued health/power on 12.0+ means some ring polish (spark, smooth animation, angled tips) is no longer achievable exactly as before. `ArcHUD.isMidnight` is the gate for the degraded/approximated rendering path. When touching ring code that reads `UnitHealth`/`UnitPower`/aura fields, assume the value may be a secret on Midnight clients — see the wow-addon-dev skill's secret-values guidance (truthy-only checks, `tonumber()` scrubbing for comparisons, never index fields off a secret-derived table).
- **SavedVariables**: single `## SavedVariables: ArcHUD3DB` (account-wide), consumed via AceDB — don't add ad-hoc globals for persistence.

## Working in this repo

- **Multi-TOC edits**: a change to shared Lua/XML files (Core.lua, ModuleCore.lua, Rings/*) applies to all editions automatically since every `.toc` lists the same filenames. Only touch the per-edition `.toc` files themselves when changing the `## Interface:` number, the embeds file (`embeds.xml` vs `embeds-vanilla.xml`), or the ring XML manifest (`Rings.xml` vs `Rings-classic.xml` vs `Rings-mop.xml`).
- **Don't hand-edit `@project-version@`, `@project-date-iso@`, `@file-abbreviated-hash@`, `@project-abbreviated-hash@`** — these are BigWigsMods packager keywords substituted by CI/the packager script at release time, not literal text to fill in.
- **Don't commit anything under `Libs/`** other than `.gitkeep` — libraries are pulled by the packager from `.pkgmeta` externals. If you need a library API to develop/test locally, fetch it manually but do not add it to git.
- **No build step for iteration**: this is plain Lua/XML consumed directly by the WoW client. There's no compiler; validate changes by loading the addon in-game (or via `luac -p`/`lua -e "assert(loadfile(...))"` for a quick syntax check when no client is available) — see the wow-addon-dev skill's verification checklist.
- **After editing any `.toc`** (interface bump, file list change), a full WoW client restart is required — `/reload` does not reload the TOC parser.
- **Follow the existing module scaffold** for new rings: `Rings/Rings.xml`/`Rings-classic.xml`/`Rings-mop.xml` each list which `Rings/*.lua` files load for that edition family — add new ring files to the right XML manifest(s), and gate the module registration itself (not just its options) on the relevant `ArcHUD.isClassic*`/`ArcHUD.classic` flags if it's edition-specific (e.g., `ComboPointsDruid.lua`, `RunesClassic.lua`, `ManaElementalShaman.lua` are spec/edition-specific rings already following this pattern).
- **Localization**: new user-facing strings go through `L`/`LM` (`AceLocale-3.0`, namespaces `ArcHUD_Core`/`ArcHUD_Module`), added to `Locales/enUS.lua` first (fallback locale) and mirrored as keys (untranslated is fine) in `deDE.lua`/`ruRU.lua`/`zhCN.lua`.
- **Debug logging**: use the module's `self:Debug(level, msg, ...)` (levels 1=warn, 2=info, 3=notice) rather than raw `print`.

## Domain knowledge

For general WoW addon development practices (TOC format, SavedVariables load order, Ace3 conventions, taint/secure-template rules, Midnight 12.0 secret-values migration, debugging via BugSack, packaging/distribution), consult the `wow-addon-dev` skill at `https://github.com/TheMizeGuy/wow-addon-dev/blob/main/SKILL.md` before making non-trivial changes — it documents the exact gotchas (event registration order, combat lockdown, addon-message limits, Interface version bumps) relevant to a multi-edition Ace3 addon like this one.

For recent changes of patch 12.1, consult https://warcraft.wiki.gg/wiki/Patch_12.1.0/API_changes
