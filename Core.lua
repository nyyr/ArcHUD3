----------------------------------------------
-- Create the addon object
----------------------------------------------
ArcHUD = LibStub("AceAddon-3.0"):NewAddon("ArcHUD",
	"AceConsole-3.0",
	"AceEvent-3.0",
	"AceHook-3.0")

-- Major version
ArcHUD.version = "3.0"
	
-- Locale object
local L = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Core")

-- Debugging levels
--   1 Warning
--   2 Info
--   3 Notice
--   4 Off
local debugLevels = {"warn", "info", "notice", "off"}
local d_warn = 1
local d_info = 2
local d_notice = 3

-- Set up tables
ArcHUD.movableFrames = {}
ArcHUD.Nameplates = {}
ArcHUD.metroHandlers = {}

-- Set up default configuration
local cfgDefaults = {
	profile = {
		Debug = nil,
		TargetFrame = true,
		PlayerModel = true,
		MobModel = false,
		ShowGuild = true,
		ShowClass = false,
		Width = 30,
		YLoc = 0,
		XLoc = 0,
		FadeFull = 0.1,
		FadeOOC = 0.5,
		FadeIC = 0.75,
		RingVisibility = 3,
		PartyLock = true,
		TargetTarget = true,
		TargetTargetTarget = true,
		NameplatePlayer = true,
		NameplatePet = true,
		NameplateTarget = true,
		NameplateTargettargettarget = true,
		NameplateCombat = true,
		Scale = 1.0,
		AttachTop = false,
		ShowBuffs = true,
		HoverMsg = true,
		HoverDelay = 3,
		BlizzPlayer = true,
		BlizzTarget = true,
		ShowPVP = true,
		ShowComboPoints = true,
		PetNameplateFade = false,
		Positions = {},
		ShowResting = true,
		ShowHolyPowerPoints = true,
		ShowSoulShardPoints = true,
	}
}

-- Setup class colors
ArcHUD.ClassColor = {
	["MAGE"] =		"69CCF0",
	["WARLOCK"] =	"9482C9",
	["PRIEST"] =	"FFFFFF",
	["DRUID"] =		"FF7D0A",
	["SHAMAN"] =	"0070DE",
	["PALADIN"] =	"F58CBA",
	["ROGUE"] =		"FFF569",
	["HUNTER"] =	"ABD473",
	["WARRIOR"] =	"C79C6E",
	["DEATHKNIGHT"] = "C41F3B"
}

-- Reputation colors
ArcHUD.RepColor = { "FF4444", "DD4444", "DD7744", "BB9944", "44DD44", "55EE44", "66FF44"}

----------------------------------------------
-- Print debug message
----------------------------------------------
function ArcHUD:LevelDebug(level, msg, ...)
	if (self.db.global.debugLevel ~= nil) then
		if (level <= self.db.global.debugLevel) then
			self:Printf(msg, ...)
		end
	end
end

----------------------------------------------
-- Return current debug level
----------------------------------------------
function ArcHUD:GetDebugLevel()
	return self.db.global.debugLevel
end

----------------------------------------------
-- Set debug level
----------------------------------------------
function ArcHUD:SetDebugLevel(level)
	if (level == nil) or (level >= 0 and level < 4) then
		local levelName = "off"
		if (level ~= nil) then
			levelName = debugLevels[level]
		end
		self:Printf(L["CMD_OPTS_DEBUG_SET"], levelName)
		self.db.global.debugLevel = level
	else
		self:Print("Invalid debug level: "..level)
	end
end

----------------------------------------------
-- OnInitialize()
----------------------------------------------
function ArcHUD:OnInitialize()
	-- Set up database
	self.db = LibStub("AceDB-3.0"):New("ArcHUDDB", cfgDefaults, "profile")

	-- Set debug level
	--self:SetDebugging(true)
	self:SetDebugLevel(self.db.profile.Debug)

	local _, _, rev = string.find("$Rev: 0 $", "([0-9]+)")
	self.version = self.version .. "." .. rev
	
	self.metroFrame = CreateFrame("Frame")
	self.metroFrame:Hide()
	self.metroFrame:SetScript("OnUpdate", self.OnMetroUpdate)
	
	----------------------------------------------
	-- Set up chat commands
	--
	local AceConfig = LibStub("AceConfig-3.0")
	AceConfig:RegisterOptionsTable("ArcHUD", {
		type = "group",
		name = "ArcHUD",
		args = {
			reset = {
				type 		= "group",
				name		= "reset",
				desc		= L["CMD_RESET"],
				args		= {
					confirm = {
						type	= "execute",
						name	= "CONFIRM",
						desc	= L["CMD_RESET_CONFIRM"],
						func	= function()
							ArcHUD:ResetOptionsConfirm()
						end
					}
				}
			},
			config = {
				type		= "execute",
				name		= "config",
				desc		= L["CMD_OPTS_FRAME"],
				func		= function()
					ArcHUD:LevelDebug(d_warn, "NYI config");
--[[
					if not ddframe then
						ddframe = CreateFrame("Frame", nil, UIParent)
						ddframe:SetWidth(2)
						ddframe:SetHeight(2)
						ddframe:SetPoint("BOTTOMLEFT", GetCursorPosition())
						ddframe:SetClampedToScreen(true)
						dewdrop:Register(ddframe, 'dontHook', true, 'children', ArcHUD.createDDMenu)
					end
					local x,y = GetCursorPosition()
					ddframe:SetPoint("BOTTOMLEFT", x / UIParent:GetScale(), y / UIParent:GetScale())
					dewdrop:Open(ddframe)
]]--
				end,
			},
			debug = {
				type		= "select",
				name		= "debug",
				desc		= L["CMD_OPTS_DEBUG"],
				values		= {"off", "warn", "info", "notice"},
				get			= function()
					return debugLevels[ArcHUD:GetDebugLevel() or 4]
				end,
				set			= function(info, v)
					if (v == 1) then 
						ArcHUD:SetDebugLevel(nil)
						ArcHUD.db.profile.Debug = nil
					else 
						ArcHUD:SetDebugLevel(v - 1)
						ArcHUD.db.profile.Debug = v
					end
				end,
				order 		= -2,
			},
		},
	}, {"archud", "ah"})

--[[
	self:LevelDebug(d_notice, "Creating core addon Dewdrop menu")
	self.dewdrop_menu = {
		["L1"] = {
			{"text", L["TEXT"]["TITLE"], "isTitle", true},
			{"text", L["Version: "]..self.version,	"notClickable", true},
			{"text", L["Author: "]..self.author, "notClickable", true},
			{},
			{"text", L["TEXT"]["DISPLAY"], "hasArrow", true, "value", "L2_display"},
			{"text", L["TEXT"]["NAMEPLATES"], "hasArrow", true, "value", "L2_nameplates"},
			{"text", L["TEXT"]["MOVEFRAMES"], "hasArrow", true, "value", "L2_movable"},
			{"text", L["TEXT"]["FADE"], "hasArrow", true, "value", "L2_fade"},
			{"text", L["TEXT"]["MISC"], "hasArrow", true, "value", "L2_misc"},
			{},
			{"text", L["TEXT"]["RINGS"], "isTitle", true},
		},
		["L2_display"] = {
			{
				"text", L["TEXT"]["TARGETFRAME"],
				"tooltipTitle", L["TEXT"]["TARGETFRAME"],
				"tooltipText", L["TOOLTIP"]["TARGETFRAME"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "TargetFrame"
			},
			{
				"text", L["TEXT"]["BLIZZPLAYER"],
				"tooltipTitle", L["TEXT"]["BLIZZPLAYER"],
				"tooltipText", L["TOOLTIP"]["BLIZZPLAYER"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "BlizzPlayer"
			},
			{
				"text", L["TEXT"]["BLIZZTARGET"],
				"tooltipTitle", L["TEXT"]["BLIZZTARGET"],
				"tooltipText", L["TOOLTIP"]["BLIZZTARGET"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "BlizzTarget"
			},
			{
				"text", L["TEXT"]["PLAYERMODEL"],
				"tooltipTitle", L["TEXT"]["PLAYERMODEL"],
				"tooltipText", L["TOOLTIP"]["PLAYERMODEL"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "PlayerModel"
			},
			{
				"text", L["TEXT"]["MOBMODEL"],
				"tooltipTitle", L["TEXT"]["MOBMODEL"],
				"tooltipText", L["TOOLTIP"]["MOBMODEL"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "MobModel"
			},
			{
				"text", L["TEXT"]["SHOWGUILD"],
				"tooltipTitle", L["TEXT"]["SHOWGUILD"],
				"tooltipText", L["TOOLTIP"]["SHOWGUILD"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "ShowGuild"
			},
			{
				"text", L["TEXT"]["SHOWCLASS"],
				"tooltipTitle", L["TEXT"]["SHOWCLASS"],
				"tooltipText", L["TOOLTIP"]["SHOWCLASS"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "ShowClass"
			},
			{
				"text", L["TEXT"]["SHOWBUFFS"],
				"tooltipTitle", L["TEXT"]["SHOWBUFFS"],
				"tooltipText", L["TOOLTIP"]["SHOWBUFFS"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "ShowBuffs"
			},
			{
				"text", L["TEXT"]["SHOWCOMBO"],
				"tooltipTitle", L["TEXT"]["SHOWCOMBO"],
				"tooltipText", L["TOOLTIP"]["SHOWCOMBO"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "ShowComboPoints"
			},
			{
				"text", L["TEXT"]["SHOWPVP"],
				"tooltipTitle", L["TEXT"]["SHOWPVP"],
				"tooltipText", L["TOOLTIP"]["SHOWPVP"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "ShowPVP"
			},
			{
				"text", L["TEXT"]["ATTACHTOP"],
				"tooltipTitle", L["TEXT"]["ATTACHTOP"],
				"tooltipText", L["TOOLTIP"]["ATTACHTOP"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "AttachTop"
			},
			{
				"text", L["TEXT"]["TOT"],
				"tooltipTitle", L["TEXT"]["TOT"],
				"tooltipText", L["TOOLTIP"]["TOT"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "TargetTarget"
			},
			{
				"text", L["TEXT"]["TOTOT"],
				"tooltipTitle", L["TEXT"]["TOTOT"],
				"tooltipText", L["TOOLTIP"]["TOTOT"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "TargetTargetTarget"
			},
		},
		["L2_nameplates"] = {
			{
				"text", L["TEXT"]["NPPLAYER"],
				"tooltipTitle", L["TEXT"]["NPPLAYER"],
				"tooltipText", L["TOOLTIP"]["NPPLAYER"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "Nameplate_player"
			},
			{
				"text", L["TEXT"]["NPPET"],
				"tooltipTitle", L["TEXT"]["NPPET"],
				"tooltipText", L["TOOLTIP"]["NPPET"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "Nameplate_pet"
			},
			{
				"text", L["TEXT"]["NPTARGET"],
				"tooltipTitle", L["TEXT"]["NPTARGET"],
				"tooltipText", L["TOOLTIP"]["NPTARGET"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "Nameplate_target"
			},
			{
				"text", L["TEXT"]["NPTOT"],
				"tooltipTitle", L["TEXT"]["NPTOT"],
				"tooltipText", L["TOOLTIP"]["NPTOT"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "Nameplate_targettarget"
			},
			{
				"text", L["TEXT"]["NPTOTOT"],
				"tooltipTitle", L["TEXT"]["NPTOTOT"],
				"tooltipText", L["TOOLTIP"]["NPTOTOT"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "Nameplate_targettargettarget"
			},
			{},
			{
				"text", L["TEXT"]["NPCOMBAT"],
				"tooltipTitle", L["TEXT"]["NPCOMBAT"],
				"tooltipText", L["TOOLTIP"]["NPCOMBAT"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "NameplateCombat"
			},
			{
				"text", L["TEXT"]["PETNPFADE"],
				"tooltipTitle", L["TEXT"]["PETNPFADE"],
				"tooltipText", L["TOOLTIP"]["PETNPFADE"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "PetNameplateFade"
			},
			{
				"text", L["TEXT"]["HOVERMSG"],
				"tooltipTitle", L["TEXT"]["HOVERMSG"],
				"tooltipText", L["TOOLTIP"]["HOVERMSG"],
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "toggle",
				"arg2", "HoverMsg"
			},
			{
				"text", L["TEXT"]["HOVERDELAY"],
				"tooltipTitle", L["TEXT"]["HOVERDELAY"],
				"tooltipText", L["TOOLTIP"]["HOVERDELAY"],
				"hasArrow", true,
				"hasSlider", true,
				"sliderMin", 0,
				"sliderMax", 5,
				"sliderMinText", "Instant",
				"sliderMaxText", "5s",
				"sliderStep", 0.5,
				"sliderValue", 0,
				"sliderFunc", ArcHUD.modDB,
				"sliderArg1", "set",
				"sliderArg2", "HoverDelay"
			},
		},
		["L2_movable"] = {
			{
				"text", L["TEXT"]["MFTHUD"],
				"tooltipTitle", L["TEXT"]["MFTHUD"],
				"tooltipText", L["TOOLTIP"]["MFTHUD"],
				"checked", false,
				"func", ArcHUD.toggleLock,
				"arg1", "targethud",
			},
			{
				"text", L["TEXT"]["MFTT"],
				"tooltipTitle", L["TEXT"]["MFTT"],
				"tooltipText", L["TOOLTIP"]["MFTT"],
				"checked", false,
				"func", ArcHUD.toggleLock,
				"arg1", "targettarget",
			},
			{
				"text", L["TEXT"]["MFTTT"],
				"tooltipTitle", L["TEXT"]["MFTTT"],
				"tooltipText", L["TOOLTIP"]["MFTTT"],
				"checked", false,
				"func", ArcHUD.toggleLock,
				"arg1", "targettargettarget",
			},
			{},
			{
				"text", L["TEXT"]["RESETTHUD"],
				"tooltipTitle", L["TEXT"]["RESETTHUD"],
				"tooltipText", L["TOOLTIP"]["RESETTHUD"],
				"func", ArcHUD.resetFrame,
				"arg1", "targethud",
			},
			{
				"text", L["TEXT"]["RESETTT"],
				"tooltipTitle", L["TEXT"]["RESETTT"],
				"tooltipText", L["TOOLTIP"]["RESETTT"],
				"func", ArcHUD.resetFrame,
				"arg1", "targettarget",
			},
			{
				"text", L["TEXT"]["RESETTTT"],
				"tooltipTitle", L["TEXT"]["RESETTTT"],
				"tooltipText", L["TOOLTIP"]["RESETTTT"],
				"func", ArcHUD.resetFrame,
				"arg1", "targettargettarget",
			},
		},
		["L2_fade"] = {
			{
				"text", L["TEXT"]["FADE_FULL"],
				"tooltipTitle", L["TEXT"]["FADE_FULL"],
				"tooltipText", L["TOOLTIP"]["FADE_FULL"],
				"hasArrow", true,
				"hasSlider", true,
				"sliderStep", 0.01,
				"sliderIsPercent", true,
				"sliderValue", 0,
				"sliderFunc", ArcHUD.modDB,
				"sliderArg1", "set",
				"sliderArg2", "FadeFull"
			},
			{
				"text", L["TEXT"]["FADE_OOC"],
				"tooltipTitle", L["TEXT"]["FADE_OOC"],
				"tooltipText", L["TOOLTIP"]["FADE_OOC"],
				"hasArrow", true,
				"hasSlider", true,
				"sliderStep", 0.01,
				"sliderIsPercent", true,
				"sliderValue", 0,
				"sliderFunc", ArcHUD.modDB,
				"sliderArg1", "set",
				"sliderArg2", "FadeOOC"
			},
			{
				"text", L["TEXT"]["FADE_IC"],
				"tooltipTitle", L["TEXT"]["FADE_IC"],
				"tooltipText", L["TOOLTIP"]["FADE_IC"],
				"hasArrow", true,
				"hasSlider", true,
				"sliderStep", 0.01,
				"sliderIsPercent", true,
				"sliderValue", 0,
				"sliderFunc", ArcHUD.modDB,
				"sliderArg1", "set",
				"sliderArg2", "FadeIC"
			},
		},
		["L2_misc"] = {
			{
				"text", L["TEXT"]["WIDTH"],
				"tooltipTitle", L["TEXT"]["WIDTH"],
				"tooltipText", L["TOOLTIP"]["WIDTH"],
				"hasArrow", true,
				"hasSlider", true,
				"sliderMin", 30,
				"sliderMax", 100,
				"sliderStep", 1,
				"sliderValue", 0,
				"sliderFunc", ArcHUD.modDB,
				"sliderArg1", "set",
				"sliderArg2", "Width"
			},
			{
				"text", L["TEXT"]["YLOC"],
				"tooltipTitle", L["TEXT"]["YLOC"],
				"tooltipText", L["TOOLTIP"]["YLOC"],
				"hasArrow", true,
				"hasSlider", true,
				"sliderMin", -200,
				"sliderMax", 400,
				"sliderStep", 1,
				"sliderValue", 0,
				"sliderFunc", ArcHUD.modDB,
				"sliderArg1", "set",
				"sliderArg2", "YLoc"
			},
			{
				"text", L["TEXT"]["XLOC"],
				"tooltipTitle", L["TEXT"]["XLOC"],
				"tooltipText", L["TOOLTIP"]["XLOC"],
				"hasArrow", true,
				"hasSlider", true,
				"sliderMin", -500,
				"sliderMax", 500,
				"sliderStep", 5,
				"sliderValue", 0,
				"sliderFunc", ArcHUD.modDB,
				"sliderArg1", "set",
				"sliderArg2", "XLoc"
			},
			{
				"text", L["TEXT"]["SCALE"],
				"tooltipTitle", L["TEXT"]["SCALE"],
				"tooltipText", L["TOOLTIP"]["SCALE"],
				"hasArrow", true,
				"hasSlider", true,
				"sliderStep", 0.01,
				"sliderMax", 2,
				"sliderIsPercent", true,
				"sliderValue", 0,
				"sliderFunc", ArcHUD.modDB,
				"sliderArg1", "set",
				"sliderArg2", "Scale"
			},
			{
				"text", L["TEXT"]["RINGVIS"],
				"tooltipTitle", L["TEXT"]["RINGVIS"],
				"tooltipText", L["TOOLTIP"]["RINGVIS"],
				"hasArrow", true,
				"value", "L3_ringvis"
			},
		},
		["L3_ringvis"] = {
			{
				"text", L["TEXT"]["RINGVIS_1"],
				"tooltipTitle", L["TEXT"]["RINGVIS_1"],
				"tooltipText", L["TOOLTIP"]["RINGVIS_1"],
				"isRadio", true,
				"checked", true,
				"func", ArcHUD.modDB,
				"arg1", "set",
				"arg2", "RingVisibility",
				"arg3", 1
			},
			{
				"text", L["TEXT"]["RINGVIS_2"],
				"tooltipTitle", L["TEXT"]["RINGVIS_2"],
				"tooltipText", L["TOOLTIP"]["RINGVIS_2"],
				"isRadio", true,
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "set",
				"arg2", "RingVisibility",
				"arg3", 2
			},
			{
				"text", L["TEXT"]["RINGVIS_3"],
				"tooltipTitle", L["TEXT"]["RINGVIS_3"],
				"tooltipText", L["TOOLTIP"]["RINGVIS_3"],
				"isRadio", true,
				"checked", false,
				"func", ArcHUD.modDB,
				"arg1", "set",
				"arg2", "RingVisibility",
				"arg3", 3
			},
		},
	}
]]--

	self:LevelDebug(d_notice, "Registering Metrognome timers")
	self:RegisterMetro("UpdatePetNamePlate", self.UpdatePetNamePlate, 2, self)
	self:RegisterMetro("UpdateTargetTarget", self.UpdateTargetTarget, 1, self)
	self:RegisterMetro("CheckNamePlateMouseOver", self.CheckNamePlateMouseOver, 0.1, self)
	self:RegisterMetro("UpdateTargetPower", self.UpdateTargetPower, 0.1, self)

	self:LevelDebug(d_info, "Creating HUD frame elements")
	self.TargetHUD = self:CreateHUDFrames()

	self:SendMessage("ARCHUD_LOADED")
	self:LevelDebug(d_info, "ArcHUD has been initialized.")
end

----------------------------------------------
-- OnEnable()
----------------------------------------------
function ArcHUD:OnEnable()
	self:LevelDebug(d_notice, "Registering events")
	self:RegisterEvent("PLAYER_ENTERING_WORLD",	"EventHandler")

	self:RegisterEvent("PLAYER_ENTER_COMBAT",	"CombatStatus")
	self:RegisterEvent("PLAYER_LEAVE_COMBAT", 	"CombatStatus")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", 	"CombatStatus")
	self:RegisterEvent("PLAYER_REGEN_DISABLED",	"CombatStatus")
	self:RegisterEvent("PET_ATTACK_START",		"CombatStatus")
	self:RegisterEvent("PET_ATTACK_STOP",		"CombatStatus")

--	self:RegisterEvent("UNIT_FACTION",			"UpdateFaction")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED",	"UpdateFaction")

	self:RegisterEvent("RAID_TARGET_UPDATE",	"UpdateRaidTargetIcon")

	self:RegisterEvent("PLAYER_FLAGS_CHANGED")
	self:RegisterEvent("PLAYER_UPDATE_RESTING")

	self:RegisterEvent("ArcHUD_FramesMoved", 	"CheckFrames")

	-- Set initial combat flags
	self.PlayerIsInCombat = false
	self.PlayerIsRegenOn = true
	self.PetIsInCombat = false

	self:OnProfileEnable()

	self.Enabled = true

	ArcHUDFrame:Show()
	self:LevelDebug(d_notice, "Triggering ring enable event")
	self:SendMessage("ARCHUD_MODULE_ENABLE")
	self:LevelDebug(d_info, "ArcHUD is now enabled")
end

----------------------------------------------
-- OnDisable()
----------------------------------------------
function ArcHUD:OnDisable()
	self:LevelDebug(d_notice, "Triggering ring disable event")
	self:TriggerEvent("ARCHUD_MODULE_DISABLE")

	self:HideBlizzardPlayer(true)
	self:HideBlizzardTarget(true)

	-- Hide frame
	ArcHUDFrame:Hide()

	self.Enabled = false
	self:LevelDebug(d_info, "ArcHUD is now disabled")
end

----------------------------------------------
-- OnProfileEnable()
----------------------------------------------
function ArcHUD:OnProfileEnable()
	if(self.db.profile.BlizzPlayer and self.BlizzPlayerHidden or not self.db.profile.BlizzPlayer and not self.BlizzPlayerHidden) then
		self:HideBlizzardPlayer(self.db.profile.BlizzPlayer)
	end
	if(self.db.profile.BlizzTarget and self.BlizzTargetHidden or not self.db.profile.BlizzTarget and not self.BlizzTargetHidden) then
		self:HideBlizzardTarget(self.db.profile.BlizzTarget)
	end

	if(self.db.profile.TargetFrame) then
		self:LevelDebug(d_notice, "Targetframe enabled. Registering unit events")
		self:RegisterEvent("UNIT_HEALTH", 			"EventHandler")
		self:RegisterEvent("UNIT_MAXHEALTH", 		"EventHandler")
		self:RegisterEvent("UNIT_POWER", 			"EventHandler")
		self:RegisterEvent("UNIT_MAXPOWER",			"EventHandler")
		self:RegisterEvent("UNIT_DISPLAYPOWER", 	"EventHandler")
		if(self.db.profile.ShowBuffs) then
			self:RegisterEvent("UNIT_AURA", 		"TargetAuras")
		else
			for i=1,16 do
				self.TargetHUD["Buff"..i]:Hide()
				self.TargetHUD["Debuff"..i]:Hide()
			end
		end
		self:RegisterEvent("PLAYER_TARGET_CHANGED",	"TargetUpdate")
		self:RegisterEvent("PLAYER_FOCUS_CHANGED", 	"TargetUpdate")

		-- Show target frame if we have a target
		if(UnitExists("target")) then
			self:TargetUpdate()
		end

		self:LevelDebug(d_notice, "Enabling TargetTarget updates")
		-- Enable Target's Target('s Target) updates
		self:StartMetro("UpdateTargetTarget")

		if(self.db.profile.AttachTop) then
			self:LevelDebug(d_notice, "Attaching targetframe to top")
			self.TargetHUD:ClearAllPoints()
			self.TargetHUD:SetPoint("BOTTOM", self.TargetHUD:GetParent(), "TOP", 0, -100)
		else
			self:LevelDebug(d_notice, "Attaching targetframe to bottom")
			self.TargetHUD:ClearAllPoints()
			self.TargetHUD:SetPoint("TOP", self.TargetHUD:GetParent(), "BOTTOM", 0, -50)
		end

		-- Check for custom frame placements
		for id, pos in pairs(self.db.profile.Positions) do
			if(type(pos) == "table") then
				self.movableFrames[id]:ClearAllPoints()
				self.movableFrames[id]:SetPoint("BOTTOMLEFT", WorldFrame, "BOTTOMLEFT", pos.x, pos.y)
			end
		end
	else
		self:StopMetro("UpdateTargetTarget")
		self:StopMetro("UpdateTargetPower")
		self.TargetHUD:SetAlpha(0)
		self.TargetHUD:Lock()
	end

	self:LevelDebug(d_notice, "Positioning ring anchors. Width: "..self.db.profile.Width)
	-- Position the HUD according to user settings
	anchorModule = self:GetModule("Anchors", true)
	if not (anchorModule == nil) then
		self:GetModule("Anchors").Left:ClearAllPoints()
		self:GetModule("Anchors").Left:SetPoint("TOPLEFT", ArcHUDFrame, "TOPLEFT", 0-self.db.profile.Width, 0)
		self:GetModule("Anchors").Right:ClearAllPoints()
		self:GetModule("Anchors").Right:SetPoint("TOPLEFT", ArcHUDFrame, "TOPRIGHT", self.db.profile.Width, 0)
	end

	self:LevelDebug(d_notice, "Position frame. YLoc: "..self.db.profile.YLoc.." XLoc: "..self.db.profile.XLoc)
	ArcHUDFrame:ClearAllPoints()
	ArcHUDFrame:SetPoint("CENTER", WorldFrame, "CENTER", self.db.profile.XLoc, self.db.profile.YLoc)

	self:LevelDebug(d_notice, "Setting scale. Scale: "..self.db.profile.Scale)
	-- Scale the HUD according to user settings.
	ArcHUDFrame:SetScale(self.db.profile.Scale)

	self:LevelDebug(d_notice, "Setting player name to nameplate")
	-- Set playername
	self:UpdateFaction()
	self:PLAYER_UPDATE_RESTING()

	-- Enable nameplate updates
	self:StartNamePlateTimers()

	-- Combo points frame
	self:InitComboPointsFrame()
end

----------------------------------------------
-- OnProfileDisable()
----------------------------------------------
function ArcHUD:OnProfileDisable()
	self:LevelDebug(d_notice, "Unregistering events")
	if(self:IsEventRegistered("UNIT_HEALTH")) then
		self:UnregisterEvent("UNIT_HEALTH")
		self:UnregisterEvent("UNIT_MAXHEALTH")
		self:UnregisterEvent("UNIT_POWER")
		self:UnregisterEvent("UNIT_MAXPOWER")
		self:UnregisterEvent("UNIT_DISPLAYPOWER")
	end
	if(self:IsEventRegistered("UNIT_AURA")) then self:UnregisterEvent("UNIT_AURA") end
	if(self:IsEventRegistered("UNIT_FACTION")) then self:UnregisterEvent("UNIT_FACTION") end
	if(self:IsEventRegistered("PLAYER_TARGET_CHANGED")) then self:UnregisterEvent("PLAYER_TARGET_CHANGED") end
	if(self:IsEventRegistered("PLAYER_FOCUS_CHANGED")) then self:UnregisterEvent("PLAYER_FOCUS_CHANGED") end

	self:LevelDebug(d_notice, "Disabling timers")
	self:StopMetro("UpdateTargetTarget")
	self:StopMetro("UpdatePetNamePlate")
	self:StopMetro("CheckNamePlateMouseOver")
	self:StopMetro("UpdateTargetPower")
	self:UnregisterMetro("Enable_player")
	self:UnregisterMetro("Enable_pet")

	self:LevelDebug(d_notice, "Hiding frames")
	for i=1,16 do
		self.TargetHUD["Buff"..i]:Hide()
		self.TargetHUD["Debuff"..i]:Hide()
	end
	self.TargetHUD:SetAlpha(0)
end

----------------------------------------------
-- ResetOptionsConfirm()
----------------------------------------------
function ArcHUD:ResetOptionsConfirm()
	self:LevelDebug(d_warn, "NYI: ResetOptionsConfirm()")
--[[
	self:ResetDB("profile")
	self.updating = true
	self:OnProfileDisable()
	self:OnProfileEnable()
	self:TriggerEvent("ARCHUD_MODULE_UPDATE")
	self.updating = false
	self:Print(L["TEXT_RESET_CONFIRM"])
]]--
end

----------------------------------------------
-- TargetUpdate()
----------------------------------------------
function ArcHUD:TargetUpdate()
	self:LevelDebug(d_info, "TargetUpdate called")
	-- Make sure we are targeting someone and that ArcHUD is enabled
	if (UnitExists("target") and self.db.profile.TargetFrame) then
		self:LevelDebug(d_info, "TargetUpdate: Updating target frame...")

		-- 3D target model
		if((self.db.profile.PlayerModel and UnitIsPlayer("target")) or (self.db.profile.MobModel and not UnitIsPlayer("target"))) then
			self.TargetHUD.Model:Show()
			self.TargetHUD.Model:SetUnit("target")
			self:LevelDebug(d_notice, "TargetUpdate: Enabling 3D model. Player - "..((self.db.profile.PlayerModel and UnitIsPlayer("target")) and "yes" or "no")..", Mob - "..((self.db.profile.MobModel and not UnitIsPlayer("target")) and "yes" or "no"))
		else
			self.TargetHUD.Model:Hide()
			self:LevelDebug(d_notice, "TargetUpdate: Disabling 3D model")
		end

		self.TargetHUD:SetAlpha(1)

		if(UnitIsDead("target") or UnitIsGhost("target")) then
			self.TargetHUD.HPText:SetText("Dead")
		else
			self.TargetHUD.HPText:SetText(UnitHealth("target").."/"..UnitHealthMax("target"))
		end

		-- Does the unit have mana? If so we want to show it
		if (UnitPowerMax("target") > 0) then
			self.TargetHUD.MPText:SetText(UnitPower("target").."/"..UnitPowerMax("target"))
			self:StartMetro("UpdateTargetPower")
		else
			self.TargetHUD.MPText:SetText(" ")
			self:StopMetro("UpdateTargetPower")
		end

		local addtolevel = ""
		if(self.db.profile.ShowClass) then
			addtolevel = " " .. (UnitIsPlayer("target") and UnitClass("target") or UnitCreatureFamily("target") or UnitCreatureType("target") or "Unknown")
			self.TargetHUD.Level:SetJustifyH("CENTER")
		else
			self.TargetHUD.Level:SetJustifyH("LEFT")
		end
		-- What kind of target is it? If UnitLevel returns negative we have a target whose
		--   level are too high to show or a boss
		if (UnitLevel("target") < 0) then
			if ( UnitClassification("target") == "worldboss" ) then
				self.TargetHUD.Level:SetText("Boss" .. addtolevel)
			else
				self.TargetHUD.Level:SetText("L??" .. addtolevel)
			end
		else
			if (UnitClassification("target") == "normal") then
				self.TargetHUD.Level:SetText("L" .. UnitLevel("target") .. addtolevel)
			-- Make sure we mark elites with a + after the level
			elseif (UnitClassification("target") == "elite") then
				self.TargetHUD.Level:SetText("L" .. UnitLevel("target") .. "+" .. addtolevel)
			-- Make sure we mark rares with Rare before level
			elseif (UnitClassification("target") == "rare") then
				self.TargetHUD.Level:SetText("Rare L" .. UnitLevel("target") .. addtolevel)
			-- Make sure we mark rareelites with Rare before level and a + after level
			elseif (UnitClassification("target") == "rareelite") then
				self.TargetHUD.Level:SetText("Rare L" .. UnitLevel("target") .. "+" .. addtolevel)
			end
		end

		-- Check if the target is friendly to the player
		targetfriend = UnitIsFriend("player","target")

		-- Color the level display based on the targets level in relation
		--  to player level
		if (targetfriend) then
			self.TargetHUD.Level:SetTextColor(1, 0.9, 0)
		elseif (UnitIsTrivial("target")) then
			self.TargetHUD.Level:SetTextColor(0.7, 0.7, 0.7)
		elseif (UnitLevel("target") == -1) then
			self.TargetHUD.Level:SetTextColor(1, 0, 0)
		elseif (UnitLevel("target") <= (UnitLevel("player")-3)) then
			self.TargetHUD.Level:SetTextColor(0, 0.9, 0)
		elseif (UnitLevel("target") >= (UnitLevel("player")+5)) then
			self.TargetHUD.Level:SetTextColor(1, 0, 0)
		elseif (UnitLevel("target") >= (UnitLevel("player")+3)) then
			self.TargetHUD.Level:SetTextColor(1, 0.5, 0)
		else
			self.TargetHUD.Level:SetTextColor(1, 0.9, 0)
		end

		-- Color the targets hp and mana text correctly
		local info = {}
		if (UnitPowerType("target") == 0) then
			info = { r = 0.00, g = 1.00, b = 1.00 }
		else
			info = PowerBarColor[UnitPowerType("target")]
		end
		self.TargetHUD.MPText:SetTextColor(info.r, info.g, info.b)

		if(targetfriend) then
			self.TargetHUD.HPText:SetTextColor(0, 1, 0)
		else
			self.TargetHUD.HPText:SetTextColor(1, 0, 0)
		end

		-- The name of the target should be colored differently if it's a player or if
		--   it's a mob
		local _, class = UnitClass("target")
		local color = self.ClassColor[class]
		local decoration_l, decoration_r = "", ""
		if(UnitIsUnit("target", "focus")) then
			decoration_l = "|cffffffff>>|r "
			decoration_r = " |cffffffff<<|r"
		end
		if (color and UnitIsPlayer("target")) then
			-- Is target in a guild?
			local guild, _, _ = GetGuildInfo("target")

			-- Color the target name based on class since we have a player targeted
			if(guild and ArcHUD.db.profile.ShowGuild) then
				self.TargetHUD.Name:SetText(decoration_l.."|cff"..color..UnitName("target").." <"..guild..">".."|r"..decoration_r)
			else
				self.TargetHUD.Name:SetText(decoration_l.."|cff"..color..UnitName("target").."|r"..decoration_r)
			end
		else
			-- Color the target name based on reaction (red to green) since we have a
			--   mob targeted
			local reaction = self.RepColor[UnitReaction("target","player")]
			if(reaction) then
				self.TargetHUD.Name:SetText(decoration_l.."|cff"..reaction..UnitName("target").."|r"..decoration_r)
			else
				self.TargetHUD.Name:SetText(decoration_l..UnitName("target")..decoration_r)
			end
		end

		-- Show clickable nameplate only if the target is a friendly player and not self
		--[[if(UnitIsPlayer("target") and targetfriend and not UnitIsUnit("player", "target")) then
			self.NamePlates.Target:Show()
		else
			self.NamePlates.Target:Hide()
		end]]

		if(self.db.profile.ShowBuffs) then
			-- Update buffs and debuffs for the target
			self:TargetAuras()
		end

		self:UpdateFaction("target")
		self:UpdateRaidTargetIcon()
		self:PLAYER_FLAGS_CHANGED("target")

		if(self.BlizzTargetHidden and not self.updating) then
			if(UnitIsEnemy("target", "player")) then
				PlaySound("igCreatureAggroSelect")
			elseif(UnitIsFriend("player", "target")) then
				PlaySound("igCharacterNPCSelect")
			else
				PlaySound("igCreatureNeutralSelect")
			end
		end

		self.Nameplates.target:Enable()
	else
		-- We didn't have anything targeted or ArcHUD is disabled so lets hide the
		--   target frame again
		if(self.BlizzTargetHidden and not self.updating) then
			PlaySound("INTERFACESOUND_LOSTTARGETUNIT")
		end
		if(self.TargetHUD.locked) then
			self.TargetHUD:SetAlpha(0)
		else
			self.TargetHUD:SetAlpha(1)
		end

		self:StopMetro("UpdateTargetPower")
		self.Nameplates.target:Disable()
	end
end

----------------------------------------------
-- TargetAuras()
----------------------------------------------
function ArcHUD:TargetAuras()
	if(not arg1 == "target") then return end
	local unit = "target"
	local i, icon, buff, debuff, debuffborder, debuffcount, debuffType, color, duration, expirationTime
	for i = 1, 16 do
		_, _, buff, _, _, duration, expirationTime, _, _ = UnitBuff(unit, i)
		button = self.TargetHUD["Buff"..i]
		if (buff) then
			--icon = getglobal(button:GetName().."Icon")
			button.Icon:SetTexture(buff)
			button:Show()
			button.unit = unit

			if(duration) then
				if(duration > 0) then
					button.Cooldown:Show()
					startCooldownTime = expirationTime - duration
					button.Cooldown:SetCooldown(startCooldownTime, duration)
				else
					button.Cooldown:Hide()
				end
			else
				button.Cooldown:Hide()
			end
		else
			button:Hide()
		end
	end

	for i = 1, 16 do
		_, _, debuff, debuffApplications, debuffType, duration, expirationTime, _, _ = UnitDebuff(unit, i)
		button = self.TargetHUD["Debuff"..i]
		if (debuff) then
			--icon = getglobal(button:GetName().."Icon")
			--debuffborder = getglobal(button:GetName().."Border")
			--debuffcount = getglobal(button:GetName().."Count")
			button.Icon:SetTexture(debuff)
			button:Show()
			button.Border:Show()
			button.isdebuff = 1
			button.unit = unit
			if ( debuffType ) then
				color = DebuffTypeColor[debuffType]
			else
				color = DebuffTypeColor["none"]
			end
			button.Border:SetVertexColor(color.r, color.g, color.b)
			if (debuffApplications > 1) then
				button.Count:SetText(debuffApplications)
				button.Count:Show()
			else
				button.Count:Hide()
			end

			if(duration) then
				if(duration > 0) then
					button.Cooldown:Show()
					startCooldownTime = expirationTime - duration
					button.Cooldown:SetCooldown(startCooldownTime, duration)
				else
					button.Cooldown:Hide()
				end
			else
				button.Cooldown:Hide()
			end

		else
			button:Hide()
		end
	end
end

----------------------------------------------
-- SetAuraTooltip()
----------------------------------------------
function ArcHUD:SetAuraTooltip(this)
	self:LevelDebug(d_notice, "NYI: SetAuraTooltip()")
--[[
	if (not this:IsVisible()) then return end
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	local unit = this.unit
	if (this.isdebuff == 1) then
		GameTooltip:SetUnitDebuff(unit, this:GetID())
	else
		GameTooltip:SetUnitBuff(unit, this:GetID())
	end
]]--
end

----------------------------------------------
-- UpdateTargetPower()
----------------------------------------------
function ArcHUD:UpdateTargetPower()
	self.TargetHUD.MPText:SetText(UnitPower("target").."/"..UnitPowerMax("target"))
end

----------------------------------------------
-- UpdateFaction()
----------------------------------------------
function ArcHUD:UpdateFaction(unit)
	self:LevelDebug(d_info, "UpdateFaction: arg1 = %s, unit = %s", arg1 or "nil", unit or "nil")

	if(not unit and arg1 and arg1 ~= "player") then return end
	if(arg1 and not unit) then unit = arg1 end

	if(unit and unit == "target") then
		local factionGroup = UnitFactionGroup("target")
		if(UnitIsPVPFreeForAll("target")) then
			self.TargetHUD.PVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
			self.TargetHUD.PVPIcon:Show()
		elseif(factionGroup and UnitIsPVP("target")) then
			self.TargetHUD.PVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup)
			self.TargetHUD.PVPIcon:Show()
		else
			self.TargetHUD.PVPIcon:Hide()
		end
	else
		local factionGroup, factionName = UnitFactionGroup("player");
		local _, class = UnitClass("player")
		local color = self.ClassColor[class]
		if(self.db.profile.ShowPVP and UnitIsPVPFreeForAll("player")) then
			if(not self.PVPEnabled) then
				PlaySound("igPVPUpdate")
			end
			self.Nameplates.player.Text:SetText("|cffffff00[FFA] |cff"..(color or "ffffff")..(UnitName("player") or "Unknown Entity").."|r")
			self.PVPEnabled = true
		elseif(self.db.profile.ShowPVP and factionGroup and UnitIsPVP("player")) then
			if(not self.PVPEnabled) then
				PlaySound("igPVPUpdate")
			end
			self.Nameplates.player.Text:SetText("|cffff0000[PVP] |cff"..(color or "ffffff")..(UnitName("player") or "Unknown Entity").."|r")
			self.PVPEnabled = true
		else
			self.Nameplates.player.Text:SetText("|cff"..(color or "ffffff")..(UnitName("player") or "Unknown Entity").."|r")
			self.PVPEnabled = nil
		end
	end
end

----------------------------------------------
-- UpdateRaidTargetIcon()
----------------------------------------------
function ArcHUD:UpdateRaidTargetIcon()
	if(not UnitExists("target")) then self.TargetHUD.RaidTargetIcon:Hide() return end

	local index = GetRaidTargetIndex("target")
	if(index) then
		SetRaidTargetIconTexture(self.TargetHUD.RaidTargetIcon, index)
		self.TargetHUD.RaidTargetIcon:Show()
	else
		self.TargetHUD.RaidTargetIcon:Hide()
	end
end

----------------------------------------------
-- PLAYER_FLAGS_CHANGED()
----------------------------------------------
function ArcHUD:PLAYER_FLAGS_CHANGED(unit)
	if(arg1 and not unit) then unit = arg1 end
	if(not UnitExists("target")) then self.TargetHUD.LeaderIcon:Hide() return end

	if(unit == "target") then
		if(UnitIsPartyLeader("target")) then
			self.TargetHUD.LeaderIcon:Show()
		else
			self.TargetHUD.LeaderIcon:Hide()
		end
	end
end

----------------------------------------------
-- UpdatePetNamePlate()
----------------------------------------------
function ArcHUD:UpdatePetNamePlate()
	if(UnitExists("pet")) then
		local happiness, _, _ = GetPetHappiness()
		local color, alpha
		if(happiness) then
			if(happiness == 1) then
				color = "ff0000"
				happiness = " :("
				alpha = 0.75
			elseif(happiness == 2) then
				color = "ffff00"
				happiness = " :||"
				alpha = 0.50
			elseif(happiness == 3) then
				color = "00ff00"
				happiness = " :)"
				alpha = 0.0
			end
		else
			color = "ffffff"
			happiness = ""
			alpha = 0.0
		end
		self.Nameplates.pet.alpha = alpha
		if(not self.Nameplates.pet.Started) then
			ArcHUDRingTemplate.SetRingAlpha(self.Nameplates.pet, alpha)
		end
		self.Nameplates.pet.Text:SetText("|cff"..color..UnitName("pet").." "..happiness.."|r")
		self.Nameplates.pet.disabled = false
	else
		self.Nameplates.pet:Disable()
		self.Nameplates.pet.disabled = true
		self.Nameplates.pet:SetAlpha(0)
	end
end

----------------------------------------------
-- UpdateTargetTarget()
----------------------------------------------
function ArcHUD:UpdateTargetTarget()
	-- Handle Target's Target
	if(UnitExists("targettarget") and self.db.profile.TargetTarget) then
		local _, class = UnitClass("targettarget")
		local color = self.ClassColor[class]
		local decoration = ""
		if(UnitIsUnit("targettarget", "focus")) then
			decoration = "|cffffffff>|r "
		end
		if (color and UnitIsPlayer("targettarget")) then
				self.TargetHUD.Target.Name:SetText(decoration.."|cff"..color..UnitName("targettarget").."|r")
		else
			local reaction = self.RepColor[UnitReaction("targettarget","player")]
			if(reaction) then
				self.TargetHUD.Target.Name:SetText(decoration.."|cff"..reaction..UnitName("targettarget").."|r")
			else
				self.TargetHUD.Target.Name:SetText(decoration..UnitName("targettarget"))
			end
		end

		local info = {}
		if (UnitPowerType("targettarget") == 0) then
			info = { r = 0.00, g = 1.00, b = 1.00 }
		else
			info = PowerBarColor[UnitPowerType("targettarget")]
		end
		self.TargetHUD.Target.MPText:SetTextColor(info.r, info.g, info.b)

		if(UnitIsFriend("player","targettarget")) then
			self.TargetHUD.Target.HPText:SetTextColor(0, 1, 0)
		else
			self.TargetHUD.Target.HPText:SetTextColor(1, 0, 0)
		end
		if(UnitIsDead("targettarget") or UnitIsGhost("targettarget")) then
			self.TargetHUD.Target.HPText:SetText("Dead")
		else
			self.TargetHUD.Target.HPText:SetText(math.floor(UnitHealth("targettarget")/UnitHealthMax("targettarget")*100).."%")
		end

		if (UnitPowerMax("targettarget") > 0) then
			self.TargetHUD.Target.MPText:SetText(math.floor(UnitPower("targettarget")/UnitPowerMax("targettarget")*100).."%")
		else
			self.TargetHUD.Target.MPText:SetText(" ")
		end
		self.TargetHUD.Target:SetAlpha(1)
		self.Nameplates.targettarget:Enable()
	else
		if(self.TargetHUD.Target.locked) then
			self.TargetHUD.Target:SetAlpha(0)
		end
		self.Nameplates.targettarget:Disable()
	end

	-- Handle Target's Target's Target
	if(UnitExists("targettargettarget") and self.db.profile.TargetTargetTarget) then
		local _, class = UnitClass("targettargettarget")
		local color = self.ClassColor[class]
		local decoration = ""
		if(UnitIsUnit("targettargettarget", "focus")) then
			decoration = "|cffffffff>|r "
		end
		if (color and UnitIsPlayer("targettargettarget")) then
				self.TargetHUD.TargetTarget.Name:SetText(decoration.."|cff"..color..UnitName("targettargettarget").."|r")
		else
			local reaction = self.RepColor[UnitReaction("targettargettarget","player")]
			if(reaction) then
				self.TargetHUD.TargetTarget.Name:SetText(decoration.."|cff"..reaction..UnitName("targettargettarget").."|r")
			else
				self.TargetHUD.TargetTarget.Name:SetText(decoration..UnitName("targettargettarget"))
			end
		end

		local info = {}
		if (UnitPowerType("targettargettarget") == 0) then
			info = { r = 0.00, g = 1.00, b = 1.00 }
		else
			info = PowerBarColor[UnitPowerType("targettargettarget")]
		end
		self.TargetHUD.TargetTarget.MPText:SetTextColor(info.r, info.g, info.b)

		if(UnitIsFriend("player","targettargettarget")) then
			self.TargetHUD.TargetTarget.HPText:SetTextColor(0, 1, 0)
		else
			self.TargetHUD.TargetTarget.HPText:SetTextColor(1, 0, 0)
		end
		if(UnitIsDead("targettargettarget") or UnitIsGhost("targettargettarget")) then
			self.TargetHUD.TargetTarget.HPText:SetText("Dead")
		else
			self.TargetHUD.TargetTarget.HPText:SetText(math.floor(UnitHealth("targettargettarget")/UnitHealthMax("targettargettarget")*100).."%")
		end

		if (UnitPowerMax("targettargettarget") > 0) then
			self.TargetHUD.TargetTarget.MPText:SetText(math.floor(UnitPower("targettargettarget")/UnitPowerMax("targettargettarget")*100).."%")
		else
			self.TargetHUD.TargetTarget.MPText:SetText(" ")
		end
		self.TargetHUD.TargetTarget:SetAlpha(1)
		self.Nameplates.targettargettarget:Enable()
	else
		if(self.TargetHUD.TargetTarget.locked) then
			self.TargetHUD.TargetTarget:SetAlpha(0)
		end
		self.Nameplates.targettargettarget:Disable()
	end
end

----------------------------------------------
-- UpdateFonts()
----------------------------------------------
function ArcHUD:UpdateFonts(tbl)
	local update = false
    for k,v in pairs(tbl) do
        if(type(v) == "table") then
			if(v.GetFont) then
				local fontName, fontSize, fontFlags = v:GetFont()
				if(fontName) then
					self:LevelDebug(d_info, "UpdateFonts: fontName = %s, localeFont = %s", fontName, L["FONT"])
				end
				if(fontName and not string.find(fontName, L["FONT"])) then
					v:SetFont("Fonts\\"..L["FONT"], fontSize, fontFlags)
					update = true
				end
			end
            self:UpdateFonts(v)
        end
    end
	if(update) then
		self:LevelDebug(d_notice, "Fonts updated")
	end
end

----------------------------------------------
-- Event Handler
----------------------------------------------
function ArcHUD:EventHandler(event, arg1)
	if (event == "UNIT_DISPLAYPOWER") then
		local info = {}
		if (arg1 == "target") then
			if (UnitPowerType(arg1) == 0) then
				info = { r = 0.00, g = 1.00, b = 1.00 }
			else
				info = PowerBarColor[UnitPowerType(arg1)]
			end
			self.TargetHUD.MPText:SetTextColor(info.r, info.g, info.b)
			
		elseif (arg1 == "player") then
			-- Affects Holy Power / Soul Shards
			self:UpdateComboPointsFrame()
		end
		
	elseif (event == "UNIT_POWER") then
		if (arg1 == "player") then
			-- Affects Holy Power / Soul Shards
			self:UpdateComboPointsFrame()
		end
		
	elseif (event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH") then
		if (arg1 == "target") then
			self.TargetHUD.HPText:SetText(UnitHealth(arg1).."/"..UnitHealthMax(arg1))
		end
		
	elseif(event == "PLAYER_ENTERING_WORLD") then
		self.PlayerIsInCombat = false
		self.PlayerIsRegenOn = true
		self:SetComboPoints(0)
		
	else
		if (arg1 == "target") then
			self.TargetHUD.MPText:SetText(UnitPower(arg1).."/"..UnitPowerMax(arg1))
		end
	end
end

----------------------------------------------
-- PLAYER_UPDATE_RESTING()
----------------------------------------------
function ArcHUD:PLAYER_UPDATE_RESTING()
	if(self.db.profile.ShowResting) then
		self.Nameplates.player.Resting:SetText(IsResting() and "Resting" or "")
	else
		self.Nameplates.player.Resting:SetText("")
	end
end

----------------------------------------------
-- CombatStatus()
----------------------------------------------
function ArcHUD:CombatStatus(event)
	self:LevelDebug(d_info, "CombatStatus: event = " .. event)

	if(event == "PLAYER_ENTER_COMBAT" or event == "PLAYER_REGEN_DISABLED") then
		self.PlayerIsInCombat = true
		if(event == "PLAYER_REGEN_DISABLED") then
			self.PlayerIsRegenOn = false
		end
	elseif(event == "PLAYER_LEAVE_COMBAT" or event == "PLAYER_REGEN_ENABLED") then
		if(event == "PLAYER_LEAVE_COMBAT" and self.PlayerIsRegenOn) then
			self.PlayerIsInCombat = false
		elseif(event == "PLAYER_REGEN_ENABLED") then
			self.PlayerIsInCombat = false
			self.PlayerIsRegenOn = true
		end
	elseif(event == "PET_ATTACK_START") then
		self.PetIsInCombat = true
	elseif(event == "PET_ATTACK_STOP") then
		self.PetIsInCombat = false
	end
end


--[[ 
----------------------------------------------
-- Blizzard Frame functions
-- Taken from AceUnitFrames
function ArcHUD:HideBlizzardPlayer(hide)
	self.BlizzPlayerHidden = not hide
	if not hide then
		PlayerFrame:UnregisterAllEvents()
		PlayerFrameHealthBar:UnregisterAllEvents()
		PlayerFrameManaBar:UnregisterAllEvents()
		PlayerFrame:Hide()

		PetFrame:UnregisterAllEvents()
		PetFrameHealthBar:UnregisterAllEvents()
		PetFrameManaBar:UnregisterAllEvents()
		PetFrame:Hide()
	else
		PlayerFrame:RegisterEvent("UNIT_LEVEL")
		PlayerFrame:RegisterEvent("UNIT_COMBAT")
		PlayerFrame:RegisterEvent("UNIT_PVP_UPDATE")
		PlayerFrame:RegisterEvent("UNIT_MAXMANA")
		PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		PlayerFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
		PlayerFrame:RegisterEvent("PLAYER_LEAVE_COMBAT")
		PlayerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
		PlayerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		PlayerFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
		PlayerFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
		PlayerFrame:RegisterEvent("PARTY_LEADER_CHANGED")
		PlayerFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
		PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		PlayerFrame:RegisterEvent("RAID_ROSTER_UPDATE")
		PlayerFrame:RegisterEvent("PLAYTIME_CHANGED")
		PlayerFrame:RegisterEvent("UNIT_NAME_UPDATE")
		PlayerFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
		PlayerFrame:RegisterEvent("UNIT_DISPLAYPOWER")
		PlayerFrameHealthBar:RegisterEvent("CVAR_UPDATE")
		PlayerFrameHealthBar:RegisterEvent("UNIT_HEALTH")
		PlayerFrameHealthBar:RegisterEvent("UNIT_MAXHEALTH")
		PlayerFrameManaBar:RegisterEvent("CVAR_UPDATE")
		PlayerFrameManaBar:RegisterEvent("UNIT_MANA")
		PlayerFrameManaBar:RegisterEvent("UNIT_RAGE")
		PlayerFrameManaBar:RegisterEvent("UNIT_FOCUS")
		PlayerFrameManaBar:RegisterEvent("UNIT_ENERGY")
		PlayerFrameManaBar:RegisterEvent("UNIT_HAPPINESS")
		PlayerFrameManaBar:RegisterEvent("UNIT_MAXMANA")
		PlayerFrameManaBar:RegisterEvent("UNIT_MAXRAGE")
		PlayerFrameManaBar:RegisterEvent("UNIT_MAXFOCUS")
		PlayerFrameManaBar:RegisterEvent("UNIT_MAXENERGY")
		PlayerFrameManaBar:RegisterEvent("UNIT_MAXHAPPINESS")
		PlayerFrameManaBar:RegisterEvent("UNIT_DISPLAYPOWER")
		PlayerFrame:Show()

		PetFrame:RegisterEvent("UNIT_PET")
		PetFrame:RegisterEvent("UNIT_COMBAT")
		PetFrame:RegisterEvent("UNIT_AURA")
		PetFrame:RegisterEvent("PET_ATTACK_START")
		PetFrame:RegisterEvent("PET_ATTACK_STOP")
		PetFrame:RegisterEvent("UNIT_HAPPINESS")
		PetFrame:RegisterEvent("UNIT_NAME_UPDATE")
		PetFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
		PetFrame:RegisterEvent("UNIT_DISPLAYPOWER")
		PetFrameHealthBar:RegisterEvent("CVAR_UPDATE")
		PetFrameHealthBar:RegisterEvent("UNIT_HEALTH")
		PetFrameHealthBar:RegisterEvent("UNIT_MAXHEALTH")
		PetFrameManaBar:RegisterEvent("CVAR_UPDATE")
		PetFrameManaBar:RegisterEvent("UNIT_MANA")
		PetFrameManaBar:RegisterEvent("UNIT_RAGE")
		PetFrameManaBar:RegisterEvent("UNIT_FOCUS")
		PetFrameManaBar:RegisterEvent("UNIT_ENERGY")
		PetFrameManaBar:RegisterEvent("UNIT_HAPPINESS")
		PetFrameManaBar:RegisterEvent("UNIT_MAXMANA")
		PetFrameManaBar:RegisterEvent("UNIT_MAXRAGE")
		PetFrameManaBar:RegisterEvent("UNIT_MAXFOCUS")
		PetFrameManaBar:RegisterEvent("UNIT_MAXENERGY")
		PetFrameManaBar:RegisterEvent("UNIT_MAXHAPPINESS")
		PetFrameManaBar:RegisterEvent("UNIT_DISPLAYPOWER")
		if(UnitExists("pet")) then
			PetFrame:Show()
		end
	end
end
function ArcHUD:HideBlizzardTarget(hide)
	self.BlizzTargetHidden = not hide
	if not hide then
		TargetFrame:UnregisterAllEvents()
		TargetFrameHealthBar:UnregisterAllEvents()
		TargetFrameManaBar:UnregisterAllEvents()
		TargetFrame:Hide()

		ComboFrame:UnregisterAllEvents()
	else
		TargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
		TargetFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
		TargetFrame:RegisterEvent("UNIT_HEALTH")
		TargetFrame:RegisterEvent("UNIT_LEVEL")
		TargetFrame:RegisterEvent("UNIT_FACTION")
		TargetFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
		TargetFrame:RegisterEvent("UNIT_AURA")
		TargetFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
		TargetFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
		TargetFrame:RegisterEvent("UNIT_NAME_UPDATE")
		TargetFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
		TargetFrame:RegisterEvent("UNIT_DISPLAYPOWER")
		TargetFrame:RegisterEvent("RAID_TARGET_UPDATE")
		TargetFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		TargetFrameHealthBar:RegisterEvent("CVAR_UPDATE")
		TargetFrameHealthBar:RegisterEvent("UNIT_HEALTH")
		TargetFrameHealthBar:RegisterEvent("UNIT_MAXHEALTH")
		TargetFrameManaBar:RegisterEvent("CVAR_UPDATE")
		TargetFrameManaBar:RegisterEvent("UNIT_MANA")
		TargetFrameManaBar:RegisterEvent("UNIT_RAGE")
		TargetFrameManaBar:RegisterEvent("UNIT_FOCUS")
		TargetFrameManaBar:RegisterEvent("UNIT_ENERGY")
		TargetFrameManaBar:RegisterEvent("UNIT_HAPPINESS")
		TargetFrameManaBar:RegisterEvent("UNIT_MAXMANA")
		TargetFrameManaBar:RegisterEvent("UNIT_MAXRAGE")
		TargetFrameManaBar:RegisterEvent("UNIT_MAXFOCUS")
		TargetFrameManaBar:RegisterEvent("UNIT_MAXENERGY")
		TargetFrameManaBar:RegisterEvent("UNIT_MAXHAPPINESS")
		TargetFrameManaBar:RegisterEvent("UNIT_DISPLAYPOWER")
		--if(UnitExists("target")) then
			--TargetFrame:Show()
		--end
		this = TargetFrame
		TargetFrame_Update()

		ComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
		ComboFrame:RegisterEvent("UNIT_COMBO_POINTS")
	end
end
]]--

----------------------------------------------
-- Register callback for metronome
-- From Metrognome-2.0
----------------------------------------------
-- Sets up a new OnUpdate handler
-- name - A unique name, if you only need one handler then your addon's name will suffice here
-- func - Function to be called
-- rate (optional but highly reccomended) - The rate (in seconds) at which your function should be called
-- a1-4 (optional) - A args to be passed to func, this is a great place to pass self
--                   if a2 is defined then the elapsed time will not be passed to your function!
-- Returns true if you've been registered
----------------------------------------------
function ArcHUD:RegisterMetro(name, func, rate, a1, a2, a3, a4, a5, a6)
	self:LevelDebug(d_notice, "Registering metronome on "..name)
	
	if self.metroHandlers[name] then
		self:LevelDebug(d_warn, "A timer with the name "..name.." is already registered")
	end
	
	if func == nil then
		self:LevelDebug(d_warn, "*** Attempt to register "..name.." without a function")
		return
	end

	local t = {}
	t.name, t.func, t.rate = name, func, rate or 0
	t.a1, t.a2, t.a3, t.a4, t.a5, t.a6 = a1, a2, a3, a4, a5, a6
	self.metroHandlers[name] = t
	return true
end

----------------------------------------------
-- Unregister callback for metronome
-- From Metrognome-2.0
----------------------------------------------
-- Removes an OnUpdate handler
-- name - the hander you want to remove
-- Returns true if successful
----------------------------------------------
function ArcHUD:UnregisterMetro(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10)
	self:LevelDebug(d_notice, "Unregistering metronome on "..a1)

	if not self.metroHandlers[a1] then return end
	
	reclaimtable(self.metroHandlers[a1])
	self.metroHandlers[a1] = nil
	
	if a2 then self:UnregisterMetro(a2,a3,a4,a5,a6,a7,a8,a9,a10)
	elseif not next(self.metroHandlers) then self.metroFrame:Hide() end
	return true
end

----------------------------------------------
-- Unregister callback for metronome
-- From Metrognome-2.0
----------------------------------------------
-- Query a timer's status
-- Args: name - the schedule you wish to look up
-- Returns: registered - true if a schedule exists with this name
--          rate - the registered rate, if defined
--          running - true if this schedule is currently running
--          limit - limit of times to repeat this timer
--          elapsed - time elapsed this cycle of the timer
----------------------------------------------
function ArcHUD:MetroStatus(name)
	if not ArcHUD.metroHandlers[name] then return false end
	return true, ArcHUD.metroHandlers[name].rate, ArcHUD.metroHandlers[name].running, ArcHUD.metroHandlers[name].limit, ArcHUD.metroHandlers[name].elapsed
end

----------------------------------------------
-- Metronome tick
-- From Metrognome-2.0
----------------------------------------------
function ArcHUD:OnMetroUpdate(elapsed)
	if (ArcHUD.metroHandlers == nil) then
		ArcHUD:LevelDebug(d_warn, "metroHandlers not initialized")
		return
	end
	for i,v in pairs(ArcHUD.metroHandlers) do
		if v.running then
			v.elapsed = v.elapsed + elapsed
			if v.elapsed >= v.rate then
				local mem, time = gcinfo(), GetTime()
				-- ArcHUD:LevelDebug(d_notice, "Metronome is calling "..i)
				v.func(v.a1 or v.arg, v.a2 or v.elapsed, v.a3, v.a4, v.a5, v.a6)
				mem, time = gcinfo() - mem, GetTime() - time
				if mem >= 0 then v.mem, v.time, v.count = (v.mem or 0) + mem, (v.time or 0) + time, (v.count or 0) + 1 end
				v.elapsed = 0
				if v.limit then v.limit = v.limit - 1 end
				if v.limit and v.limit <= 0 then ArcHUD:StopMetro(i) end
			end
		end
	end
end

----------------------------------------------
-- Add callback into metronome
-- From Metrognome-2.0
----------------------------------------------
-- Begins triggering updates
-- name - the hander you want to start
-- numexec (optional) - Limit the number of times the timer runs
-- Returns true if successful
----------------------------------------------
function ArcHUD:StartMetro(name, numexec)
	-- self:LevelDebug(d_notice, "Starting metronome on "..name)
	
	if not self.metroHandlers[name] then 
		self:LevelDebug(d_warn, "Attempt to start unregistered metronome callback "..name)
		return
	end
	
	self.metroHandlers[name].limit = numexec
	self.metroHandlers[name].elapsed = 0
	self.metroHandlers[name].running = true
	self.metroFrame:Show()
	return true
end

----------------------------------------------
-- Remove callback into metronome
-- From Metrognome-2.0
----------------------------------------------
-- Stops triggering updates
-- name - the hander you want to stop
-- Returns true if successful
----------------------------------------------
function ArcHUD:StopMetro(name)
	-- self:LevelDebug(d_notice, "Stopping metronome on "..name)

	if not self.metroHandlers[name] then return end
	
	self.metroHandlers[name].running = nil
	self.metroHandlers[name].limit = nil
	if not next(self.metroHandlers) then self.metroFrame:Hide() end
	return true
end
