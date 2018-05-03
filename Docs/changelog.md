ArcHUD3 v4.1/4.2 (fixes for WoW 7)
-------------

* Added support for language zhCN (thanks to yuningning520)
* Updated ComboPoints (thanks to jasonolive)
* Updated rings ComboPoints, SoulShards, Runes (thanks to jasonolive)
* Added ring ArcaneCharges (thanks to jasonolive)

ArcHUD3 v4.0 (fixes for WoW 7)
-------------

* Migrated to UnitIsTapDenied (TargetHealth, FocusHealth)
* Migrated alpha animation to SetFromAlpha/SetToAlpha
* Texture rendering fix (thanks to jasonolive)

ArcHUD3 2.3 "Staggering Troll"
-------------

* added absorbs to Player Health ring
* added Stagger ring
* added separate scaling option for Target Frame
* change: set new default position for Target Casting ring
* change: disabled Focus Casting ring by default
* bug fix: hide/show RuneFrame with PlayerFrame

nyyr


ArcHUD3 2.2 "Burning Skies"
-------------

* added option to change Death Knight rune order
* bug fixes

nyyr


ArcHUD3 2.1 "Dizzying Curiosity"
-------------

* added Shadow Orbs ring
* bug fixes

nyyr


ArcHUD3 2.0 "Dizzying Curiosity" (WoW 5.0)
-------------

* added Monk Chi ring
* added Moonkin Eclipse ring
* added Burning Embers and Demonic Fury to Warlock Soul Shards ring
* added ring for Death Knight runes
* added options to center/scale Blizzard's spell activation overlays on ArcHUD
* added option to all arcs to allow attachment to inner (pet) anchor
* added dynamic separators to certain rings (configurable)
* added rendering of arbitrary arcs (configurable in v2.1)
* added inverse fillings of rings (configurable in v2.1)
* added "shine" to rings (currently DK runes only)
* fixed an issue with changing pet anchors (ticket #51)
* fixed an issue with unit frames created by ArcHUD and used by other addons (tickets #52/#38) 

nyyr


ArcHUD3 1.4 "Maximum Focus"
-------------

* added possibility to set maximum duration of custom buff arcs (#48)
* fixed graphical issue with some rings (#49)
* added focus casting ring (#47)

nyyr


ArcHUD3 1.3 "Hidden Chimera"
-------------

* added profile management
* added option to show incoming heal for health bars
* buff icons are now resizable
* multiple buffs per custom buff arc (separated with semicolon, precedence in order of their listing)
* added option to change opacity of Blizzard's spell activation overlays 
* added a toggle command (/archud toggle)
* configuration sheets now stretched to full width
* bug fix in target casting ring

nyyr


ArcHUD3 1.2 "Fiery Babel Fish"
-------------

* added deDE locale
* added ruRU locale (thanks to StingerSoft)
* added option to only show target (de)buffs cast by player
* fixed a display issue of the soul shards arc

nyyr


ArcHUD3 1.1 "Happy Plainsrunner"
-------------

* Fixed a taint (disabled dynamic nameplates IC)
* Added buff icons to custom buff arcs
* Removed indication of pet happiness (removed in WoW 4.1)
* Changed defaults: player/pet unit frames off by default
* Casting arcs:
  * Fixed text positions to avoid overlap
  * Swapped text fields of target casting arc and player casting arc (target casting more prominent now)
  * Added indication of interruptable spells (target casts)
  * Added indication of network latency/spell queue time (player casts)
  * Added sparks for casts

nyyr


ArcHUD3 1.0 "Plainsrunner"
-------------

First complete release with some new features such as custom buff arcs.

nyyr


ArcHUD3 0.9 "Phoenix" (WoW 4.0)
-------------

Updated to Ace3 and API fixes for WoW 4.0.1

nyyr


ArcHUD 2.1
-------------

This addon adds a combat HUD to your UI, showing player/target/pet hp and
mana/rage/whatever as rings centered on your screen. It uses the StatRings
code originally made by Iriel but later modified by Antiarc. It also shows a
small target frame with textual hp/mana as well as a 3D target model for other
players.

It has support for FlightMap destination timers and also have a casting bar
with spell text and timer. If the casting bar is enabled it will hide the
default Blizzard casting bar.

ArcHud uses MobHealth2/MobInfo-2 for mob health display.

Based on Tivoli's beta Nurfed HUD which used the StatRings modification by
Antiarc.

Some of the features implemented in ArcHUD was first implemented in other
addons, credits goes out to Moog for his modification of NurfedHUD called
Moog_Hud as well as to Repent for creating eCastingBar where I got the
FlightMap support code from.

Once installed you can access ArcHUD options by typing /archud or /ah in the
chat window.

Written by Saleel/Nenie of Argent Dawn.

