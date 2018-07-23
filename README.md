[![Build Status](https://travis-ci.org/nyyr/ArcHUD3.svg)](https://travis-ci.org/nyyr/ArcHUD3)

# ArcHUD3

ArcHUD displays smooth arcs around your character in the middle of the screen to inform you about the health and power (mana, rage, ...) of you, your pet, and your target. In addition, it shows casts, combo points, holy power, soul shards, and a couple of other things. It discretely fades when you are out of combat and at full health/power.

This is a continuation of ArcHUD2 which managed to survive various patches... until the Cataclysm. Thanks to Nenie, the original author of ArcHUD2, for supporting me with this new version.

Please report any bugs or feature requests via the ticket system. The login is the same as your Curse login.

These arcs are currently supported:

* Health and power (mana, rage, focus, energy, runic power) for player, pet, target, and focus target
* Player's secondary power (Holy Power, Soul Shards, Chi etc.)
* Casting/channelling progress for player, target, and focus target
* Fatigue/breath (mirror timer)
* Combo points (including unconsumed combo points on previous target, e.g. on dead corpses)
* Custom (de)buff arcs: Ever wanted to keep track of the stacks and/or remaining times of some specific (de)buffs such as Evangelism, Savage Roar, Beacon of Light, Weakened Soul, etc? Then just create your own custom (de)buff arc for it!

In addition, some additional target information is displayed:

* Current target (name, class, guild, 3D model)
* Current (de)buffs on target
* Target-of-target and target-of-target-of-target

Small warning: Using this addon apparently bears a high risk of getting addicted to it, as these user comments suggest. I received those after taking over the development of ArcHUD when the Cataclysm happened:

* "...nothing ever quite matched the smooth, clean simplicity of ArcHUD's graceful rings."
* "Great job!! I've used this addon for years! None of the other HUDs come close to the functionality and elegance of ArcHUD."
* "Thanks for the work on it so far, much more lightweight than IceHud!"
* "Was staring at the various icehud/metahud alternatives with discomfort and sadness right after the patch [4.0]."
* "Awesome! Thank you so much for that miracle!"
* "Thank you so much for continuing this fantastic addon."
* "...nothing could compare to ArcHUD..."
* "For a whole 4years I had this mod and I missed it so much in the passed few weeks. I tried other HUD mods but they were too in my face >.< . Best HUD mod IMO! Thanks for resurrecting an old friend :D"
* "Loving the new ArcHUD my favorite HUD by far :)"
* "I don't think I could play wow without this addon :)"
* "I've actually grown kind of dependent on it because I'll occasionally run out of Mana/ die without this."
* "Hey mate, just came to thank You again for taking over this beauty, awesome job!"
* "THAT addon! So long I have been searching for a replacement when the development stopped, thanks for bringing it back to live!"

So use it at your own risk ;)

## Download

* On Github under [releases](https://github.com/nyyr/ArcHUD3/releases)
* On [WoW Interface](http://www.wowinterface.com/downloads/info24629-ArcHUD3.html)
* On [WowAce](https://www.wowace.com/projects/archud3)
* On [CurseForge](https://www.curseforge.com/wow/addons/archud3)

## Frequently Asked Questions

* How do I add [a arc for a specific buff/debuff (remaining time & stacks)](https://github.com/nyyr/ArcHUD3/issues/36)?
* Where is my [Combo Point/Soul Shard Numeric Indicator](https://github.com/nyyr/ArcHUD3/issues/35)?

## Developer Notes

* [Change log](Docs/changelog.md)
* [Ring Prototypes](Docs/ring-prototypes.txt) (a bit outdated)
* [Maths behind the rings](Docs/statrings.txt)
* [History](Docs/history.txt)
* [Publishing via Travis CI](http://www.wowinterface.com/forums/showthread.php?t=55801)
