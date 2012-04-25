------------------------------
----- Translation for enEN
local L = LibStub("AceLocale-3.0"):NewLocale("ArcHUD_Core", "enUS", true)

-- Core stuff
L["CMD_OPTS_FRAME"]		= "Open options window"
L["CMD_OPTS_MODULES"]	= "Open module options window"
L["CMD_OPTS_CUSTOM"]	= "Open custom module options window"
L["CMD_OPTS_TOGGLE"]	= "Toggle visibility of ArcHUD"
L["CMD_OPTS_DEBUG"]		= "Set debugging level"
L["CMD_OPTS_DEBUG_SET"]	= "Setting debugging level to '%s'"
L["CMD_RESET"]			= "Reset settings for this character to the defaults"
L["CMD_RESET_HELP"]		= "This option will allow you to do two things, firstly you can reset your settings to their defaults.  To do this type 'CONFIRM' after the option so that the AddOn will know you've read this information"
L["CMD_RESET_CONFIRM"]	= "This option will reset all of your options to the default values they had when the AddOn was installed"
L["TEXT_RESET"]			= "Please type CONFIRM after this command to confirm you really do wish to reset your settings"
L["TEXT_RESET_CONFIRM"]	= "All settings have been reset to their defaults"
L["TEXT_ENABLED"]       = "ArcHUD is now enabled."
L["TEXT_DISABLED"]      = "ArcHUD is now disabled."

L["FONT"]				= "FRIZQT__.TTF"

L["Version"]		= true
L["Authors"]		= true

--	Options
L["TEXT"] = {
	TITLE		= "ArcHUD3 Options",
	GENERAL		= "General settings",
	
	PROFILES	= "Profiles",
	PROFILES_SELECT= "Select profile",
	PROFILES_CREATE= "Create new profile",
	PROFILES_DELETE= "Delete profile",
	PROFILES_CANNOTDELETE= "Cannot delete default profile.",
	PROFILES_DEFAULT= "Default profile",
	PROFILES_EXISTS= "Profile already exists.",
	
	DISPLAY		= "Display options",
	PLAYERFRAME	= "Player frame",
	TARGETFRAME	= "Target frame",
	PLAYERMODEL	= "3D model for players",
	MOBMODEL	= "3D model for mobs",
	SHOWGUILD	= "Show player guild",
	SHOWCLASS	= "Show target class",
	SHOWBUFFS 	= "Show (de)buffs",
	SHOWONLYBUFFSCASTBYPLAYER = "Show only your (de)buffs",
	SHOWBUFFTT 	= "Show (de)buff tooltips",
	HIDEBUFFTTIC = "Hide (de)buff tooltips in combat",
	BUFFICONSIZE= "(De)buff icon size",
	SHOWPVP		= "Show player PvP status flag",
	TOT			= "Enable target's target",
	TOTOT		= "Enable target's target's target",

	NAMEPLATES	= "Nameplate options",
	NPPLAYEROPT = "Player",
	NPPLAYER	= "Player",
	NPPET		= "Pet",
	HOVERMSG	= "Nameplate hover message",
	HOVERDELAY	= "Nameplate hover delay",
	NPTARGETOPT = "Targets",
	NPTARGET	= "Target",
	NPTOT		= "Target's target",
	NPTOTOT		= "Target's target's target",
	NPCOMBAT	= "Enable nameplates in combat",
	
	COMBOPOINTS = "Combo points options",
	SHOWCOMBO	= "Show combo point text",
	COMBODECAY	= "Decay delay",
	HOLYPOWERCOMBO = "Show Holy Power as combo points",
	SOULSHARDCOMBO = "Show Soul Shards as combo points",
	CPCOLOR		= "Color of combo points",
	CPCOLORDECAY = "Color of decaying combo points",
	RESETCOLORS	= "Reset colors",

	FADE		= "Fade options",
	FADE_FULL	= "When full",
	FADE_OOC	= "Out of combat",
	FADE_IC		= "In combat",
	RINGVIS		= "Fade behaviour",
	RINGVIS_1	= "Fade Full: Fade when full",
	RINGVIS_2	= "Fade OOC: Fade when out of combat",
	RINGVIS_3	= "Fade Both: Fade when full or out of combat (default)",
	
	POSITIONING	= "Positioning",
	WIDTH		= "HUD width",
	YLOC		= "Vertical alignment",
	XLOC		= "Horizontal alignment",
	SCALE		= "Scale",
	ATTACHTOP	= "Attach target frame to top",
	MFUNLOCK	= "Unlock movable frames",
	MFRESET		= "Reset positions",
	
	MISC		= "Miscellanous options",
	BLIZZPLAYER = "Blizzard player frame visible",
	BLIZZTARGET = "Blizzard target frame visible",
	BLIZZFOCUS  = "Blizzard focus frame visible",
	BLIZZSPELLACT= "Opacity of spell activation overlays",

	RINGS		= "Ring options",
	RING		= "Ring",
}

L["TOOLTIP"] = {
	PROFILES_SELECT = "Select a profile for this character.",
	PROFILES_CREATE = "Create a new profile based on the current profile and activate it.",
	PROFILES_DELETE = "Delete current profile and set default profile as active one.",

	PLAYERFRAME	= "Toggle display of player and pet nameplates",
	TARGETFRAME = "Toggle display of entire target frame",
	PLAYERMODEL = "Toggle display of 3D target model of players",
	MOBMODEL	= "Toggle display of 3D target model of mobs",
	SHOWGUILD	= "Show player guild information next to their name",
	SHOWCLASS	= "Show target class or creature type",
	SHOWBUFFS	= "Toggle display of buffs and debuffs",
	SHOWONLYBUFFSCASTBYPLAYER = "Show (de)buffs only if cast by you. 'Show (de)buffs' must be enabled.",
	SHOWBUFFTT 	= "Toggle display of buff or debuff tooltips",
	HIDEBUFFTTIC = "Toggle display of buff or debuff tooltips in combat",
	BUFFICONSIZE= "Set icon size of (de)buffs in pixels",
	SHOWPVP		= "Toggle display of PVP status flag on the player nameplate",
	TOT			= "Enable displaying of target's target",
	TOTOT		= "Enable displaying of target's target's target",

	NPPLAYER	= "Toggle clickable player's nameplate. "..
		"The player nameplate's state cannot be changed in combat due to UI restrictions. "..
		"Thus, it cannot be activated in combat by hovering over them, or it will remain activated if active upon entering combat.",
	NPPET		= "Toggle clickable pet's nameplate. "..
		"The pet nameplate's state cannot be changed in combat due to UI restrictions. "..
		"Thus, it cannot be activated in combat by hovering over them, or it will remain activated if active upon entering combat.",
	NPTARGET	= "Toggle clickable target's nameplate",
	NPTOT		= "Toggle clickable target's target nameplate",
	NPTOTOT		= "Toggle clickable target's target's target nameplate",
	NPCOMBAT	= "Toggle always enabling clickable nameplates when entering combat", -- TODO: obsolete
	HOVERMSG	= "Toggle displaying of a chat message when mouse input is enabled",
	HOVERDELAY	= "Amount of seconds needed to hover above the player/pet nameplate to activate it",
	
	SHOWCOMBO	= "Toggle display of combo points in the center of the HUD",
	COMBODECAY	= "Set delay in seconds before combo points on previous target disappear (set to 0 to disable this feature)",
	HOLYPOWERCOMBO = "Toggle display of Holy Power points as combo points (combo points must be turned on)",
	SOULSHARDCOMBO = "Toggle display of Soul Shards as combo points (combo points must be turned on)",
	CPCOLOR		= "Set text color of combo points",
	CPCOLORDECAY = "Set color of decaying combo points",
	RESETCOLORS	= "Reset colors to default values",

	FADE_FULL	= "Alpha to fade to when out of combat and ring at 100%",
	FADE_OOC	= "Alpha to fade to when out of combat or ring not at 100%",
	FADE_IC		= "Alpha to fade to when in combat (only used if behaviour is set to FadeBoth or FadeOOC)",
	RINGVIS		= "Sets when the rings fade out:\n" ..
				  "Fade Full: Fade out when rings are full, regardless of combat status\n" ..
				  "Fade OOC: Always fade out when out of combat, regardless of ring status\n" ..
				  "Fade both: Fade out when out of combat or rings are full (default)",
	RINGVIS_1	= "Fade out when rings are full, regardless of combat status",
	RINGVIS_2	= "Always fade out when out of combat, regardless of ring status",
	RINGVIS_3	= "Fade out when out of combat or rings are full (default)",

	WIDTH		= "Sets how much the rings should be separated from the center",
	YLOC		= "Positions ArcHUD along the Y-axis. Positive values brings it up, negative values brings it down",
	XLOC		= "Positions ArcHUD along the X-axis. Positive values brings it right, negative values brings it left",
	SCALE		= "Set the Scale Factor",
	ATTACHTOP	= "Attach target frame to the top of the rings instead of the bottom",
	MFUNLOCK	= "Allows you to move target frames around freely",
	MFRESET		= "Reset positions of movable frames",
	
	BLIZZPLAYER = "Toggles visibility of the Blizzard player frame",
	BLIZZTARGET = "Toggles visibility of the Blizzard target frame",
	BLIZZFOCUS  = "Toggles visibility of the Blizzard focus frame",
	BLIZZSPELLACT= "Sets opacity of Blizzard's spell activation overlays.",
	
}


-- Modules
local LM = LibStub("AceLocale-3.0"):NewLocale("ArcHUD_Module", "enUS", true)

LM["FONT"]			= "FRIZQT__.TTF"

LM["Version"]	= true
LM["Authors"]	= true

LM["Health"]		= "Player Health"
LM["Power"]			= "Player Power"
LM["PetHealth"]		= "Pet Health"
LM["PetPower"]		= "Pet Power"
LM["TargetCasting"]	= "Target Casting"
LM["TargetHealth"]	= "Target Health"
LM["TargetPower"]	= "Target Power"
LM["FocusCasting"]	= "Focus Casting"
LM["FocusHealth"]	= "Focus Health"
LM["FocusPower"]	= "Focus Power"
LM["Casting"]		= "Player Casting"
LM["DruidMana"]		= "Druid Mana"
LM["MirrorTimer"]	= "Mirror Timer"
LM["ComboPoints"]	= "Combo Points"
LM["EnergyTick"]	= "Energy Tick"
LM["HolyPower"]		= "Holy Power"
LM["SoulShards"]	= "Soul Shards"
LM["CustomBuff"]	= "Custom Buff" -- TODO: to be removed

LM["TEXT"] = {
	TITLE		= "Arcs Options",

	ENABLED		= "Enabled",
	OUTLINE		= "Ring outline",
	SHOWTEXT	= "Show text",
	SHOWPERC	= "Show percentage",
	FLASH		= "Flash when ring is full",
	SHOWSPELL	= "Show spell being cast",
	SHOWTIME	= "Show spell timer",
	INDINTERRUPT= "Highlight interruptable spells",
	INDLATENCY  = "Indicate latency",
	INDSPELLQ   = "Indicate spell queue time limit",
	HIDEBLIZZ	= "Hide default Blizzard frame",
	ENABLEMENU	= "Enable right-click menu",
	DEFICIT		= "Deficit",
	INCOMINGHEALS= "Indicate incoming heals",
	SHOWINCOMBAT= "Show in combat",
	SHOWINSTEALTH="Show in stealth",
	ATTACH		= "Attachment",
	SIDE		= "Side",
	LEVEL		= "Level",
	COLOR		= "Color mode",
	COLORRESET	= "Reset color",
	COLORFADE	= "Color fading",
	COLORCUST	= "Custom color",
	COLORSET	= "Ring color",
	COLORSETFADE= "Ring color",
	COLORFRIEND = "Friendly ring color",
	COLORFOE	= "Foe ring color",
	COLORMANA 	= "Mana ring color",
	COLORRAGE	= "Rage ring color",
	COLORFOCUS 	= "Focus ring color",
	COLORENERGY	= "Energy ring color",
	COLORRUNIC	= "Runic power ring color",
	ATTACHRING	= "Detach ring",
	
	CUSTOM		= "Custom Buff Arcs",
	CUSTNEW		= "New custom arc",
	CUSTRING	= "Arc options",
	
	CUSTDEBUFF	= "Debuff",
	CUSTUNIT	= "Unit",
	CUSTNAME	= "(De)Buff Name",
	CUSTCASTBYPLAYER = "Show only your (de)buff",
	CUSTSTACKS	= "Use stack applications",
	CUSTTEXTSTACKS = "Display stack applications",
	CUSTMAX		= "Stack size",
	CUSTDEL		= "Delete",
}

LM["TOOLTIP"] = {
	ENABLED		= "Toggle the ring on and off",
	OUTLINE		= "Toggle the outline around the ring",
	SHOWTEXT	= "Toggle text display (health, mana, etc.)",
	SHOWPERC	= "Toggle showing percentage",
	SHOWSPELL	= "Toggle displaying of current spell being casted",
	SHOWTIME	= "Toggle showing spell timer",
	INDINTERRUPT= "Toggle highlighting of interruptable spells. The casting arc will have a yellow outline for interruptable spells. Arc outline needs to be activated.",
	INDLATENCY  = "Toggle indication of current world latency. Adds with spell queue time limit if selected.",
	INDSPELLQ   = "Toggle indication of spell queue time limit (lag tolerance). It should be safe to start casting the next spell once the current cast passes the indicator. Adds with latency if selected.",
	FLASH		= "Toggle flashing when ring is full",
	HIDEBLIZZ	= "Toggle showing of default Blizzard frame",
	ENABLEMENU	= "Toggle right-click menu on and off",
	DEFICIT		= "Toggle health deficit (Max health - current health)",
	INCOMINGHEALS= "Toggle indication of incoming heals",
	SHOWINCOMBAT= "Toggle showing ticking while in combat",
	SHOWINSTEALTH="Toggle showing ticking while stealthed",
	SIDE		= "Set which side to attach to",
	LEVEL		= "Set at which level it should be attached relative to the anchor (<-1: towards center, 0: at anchor, >1: away from center)",
	COLOR		= "Set color mode:\n"..
					"Color fading: Set the ring color to fade (green to red for health)\n"..
					"Custom color: Set the ring color to a custom defined color",
	COLORRESET	= "Reset color to the ring's default color",
	COLORFADE	= "Set the ring color to fade (green to red for health)",
	COLORCUST	= "Set the ring color to custom defined colors",
	COLORSET	= "Set custom ring color",
	COLORSETFADE= "Set custom ring color (color mode must be set to \"custom\")",
	COLORFRIEND	= "Set custom friendly ring color",
	COLORFOE	= "Set custom foe ring color",
	COLORMANA	= "Set custom mana ring color",
	COLORRAGE	= "Set custom rage ring color",
	COLORFOCUS	= "Set custom focus ring color",
	COLORENERGY	= "Set custom energy ring color",
	COLORRUNIC	= "Set custom runic power ring color",
	ATTACHRING	= "Toggle attachment of the ring to the normal frame anchors (will behave like a normal ring when active)",
	
	CUSTNEW		= "Create a new custom arc for a specific buff or debuff",
	CUSTDEBUFF	= "Look for debuffs instead of buffs",
	CUSTUNIT	= "Unit on which the (de)buff is applied",
	CUSTNAME	= "Name of the (de)buff. Multiple (de)buffs can be named by separating them with semicolon (;). Priorities are given according to their order here.",
	CUSTCASTBYPLAYER = "Show only if (de)buff is cast by you",
	CUSTSTACKS	= "Use stack applications instead of remaining time for the arc",
	CUSTTEXTSTACKS = "Display stack applications as text instead of remaining time",
	CUSTMAX		= "Maximum stack size of the (de)buff",
	CUSTDEL		= "Delete this custom arc",
}

LM["SIDE"] = {
	LEFT		= "Left anchor",
	RIGHT		= "Right anchor",
}
