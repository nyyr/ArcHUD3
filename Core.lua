----------------------------------------------
-- Create the addon object
----------------------------------------------
ArcHUD = LibStub("AceAddon-3.0"):NewAddon("ArcHUD",
	"AceConsole-3.0",
	"AceEvent-3.0",
	"AceHook-3.0",
	"AceTimer-3.0")

-- Version
ArcHUD.version = "@project-version@ (@project-abbreviated-hash@)"
ArcHUD.codename = "Pandemic"
ArcHUD.authors = "nyyr, Nenie"

-- Classic specifics
ArcHUD.isClassicWoW = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
ArcHUD.isClassicTbc = (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)
ArcHUD.isClassicWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
ArcHUD.classic = ArcHUD.isClassicWoW or ArcHUD.isClassicTbc or ArcHUD.isClassicWrath
ArcHUD.UnitCastingInfo = UnitCastingInfo
ArcHUD.UnitChannelInfo = UnitChannelInfo

if ArcHUD.isClassicWoW then
	ArcHUD.LibClassicCasterino = LibStub("LibClassicCasterino", true)
	ArcHUD.UnitCastingInfo = function(unit)
        return ArcHUD.LibClassicCasterino:UnitCastingInfo(unit)
    end
    ArcHUD.UnitChannelInfo = function(unit)
        return ArcHUD.LibClassicCasterino:UnitChannelInfo(unit)
    end
end

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
ArcHUD.timers = {}

-- Set up default configuration
ArcHUD.defaults = {
	profile = {
		Debug = nil,
		TargetFrame = true,
		PlayerFrame = false,
		PlayerModel = true,
		MobModel = true,
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
		Nameplate_player = true,
		Nameplate_pet = true,
		Nameplate_target = false,
		Nameplate_targettarget = false,
		Nameplate_targettargettarget = false,
		HoverMsg = false,
		HoverDelay = 1.5,
		Scale = 1.0,
		ScaleTargetFrame = 1.0,
		AttachTop = false,
		ShowBuffs = true,
		ShowOnlyBuffsCastByPlayer = false,
		ShowBuffTooltips = true,
		HideBuffTooltipsIC = false,
		BuffIconSize = 20,
		ShowHealthPowerTextMax = true,
		BlizzPlayer = true,
		BlizzTarget = true,
		BlizzFocus = true,
		BlizzSpellActCenter = true,
		BlizzSpellActScale = 0.8,
		BlizzSpellActOpacity = 1.0,
		ShowPVP = true,
		-- deprecated: ShowComboPoints = true,
		Positions = {},
		ShowResting = true,
		-- deprecated: ShowHolyPowerPoints = false,
		-- deprecated: ShowSoulShardPoints = false,
		-- deprecated: ShowChiPoints = false,
		-- deprecated: ShowRunePoints = false,
		-- deprecated: ShowSoulFragmentPoints = false,
		-- deprecated: ColorComboPoints = {r = 1, g = 1, b = 0},
		-- deprecated: ColorOldComboPoints = {r = 0.5, g = 0.5, b = 0.5},
		-- deprecated: OldComboPointsDecay = 10.0,
		CustomModules = {},
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
	["DEATHKNIGHT"] = "C41F3B",
	["MONK"] = 		"00FF96"
}

-- Reputation colors
ArcHUD.RepColor = { "FF4444", "DD4444", "DD7744", "BB9944", "44DD44", "55EE44", "66FF44"}

-- for backward compatibility (WoW 4.x-5.x)
if not UnitIsGroupLeader then
	UnitIsGroupLeader = UnitIsPartyLeader
end

----------------------------------------------
-- Print debug message
----------------------------------------------
function ArcHUD:LevelDebug(level, msg, ...)
	if (self.db.global.debugLevel) then
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
	if (level == nil) or (level > 0 and level <= 4) then
		local levelName = "off"
		if (level ~= nil) then
			levelName = debugLevels[level]
			self:Printf(L["CMD_OPTS_DEBUG_SET"], levelName)
		end
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
	self.db = LibStub("AceDB-3.0"):New("ArcHUD3DB", ArcHUD.defaults, "profile")

	-- Set debug level
	--self:SetDebugging(true)
	self:SetDebugLevel(self.db.profile.Debug)

	self:LevelDebug(d_info, "Registering timers")
	self:RegisterTimer("UpdatePetNamePlate", self.UpdatePetNamePlate, 2, self, true)
	self:RegisterTimer("UpdateTargetTarget", self.UpdateTargetTarget, 1, self, true)
	self:RegisterTimer("CheckNamePlateMouseOver", self.CheckNamePlateMouseOver, 0.1, self, true)
	self:RegisterTimer("UpdateTargetPower", self.UpdateTargetPower, 0.1, self, true)

	self:LevelDebug(d_info, "Creating HUD frame elements")
	self.TargetHUD = self:CreateHUDFrames()

	self:InitConfig()
	
	self:SendMessage("ARCHUD_LOADED")
	
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	
	self:LevelDebug(d_notice, "ArcHUD has been initialized.")
end

----------------------------------------------
-- OnEnable()
----------------------------------------------
function ArcHUD:OnEnable()
	self:LevelDebug(d_notice, "Registering events")
	
	-- basic events
	self:RegisterEvent("PLAYER_ENTERING_WORLD",	"EventHandler")

	self:RegisterEvent("PLAYER_ENTER_COMBAT",	"CombatStatus")
	self:RegisterEvent("PLAYER_LEAVE_COMBAT", 	"CombatStatus")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", 	"CombatStatus")
	self:RegisterEvent("PLAYER_REGEN_DISABLED",	"CombatStatus")
	self:RegisterEvent("PET_ATTACK_START",		"CombatStatus")
	self:RegisterEvent("PET_ATTACK_STOP",		"CombatStatus")

	self:RegisterEvent("UNIT_FACTION",			"UpdateFaction")
	self:RegisterEvent("GROUP_ROSTER_UPDATE",	"UpdateFaction")

	self:RegisterEvent("RAID_TARGET_UPDATE",	"UpdateRaidTargetIcon")

	self:RegisterEvent("PLAYER_FLAGS_CHANGED")
	self:RegisterEvent("PLAYER_UPDATE_RESTING")

	if ArcHUD.classic then
		self:RegisterEvent("UNIT_HAPPINESS", "UpdatePetNamePlate")
	end

	self:RegisterMessage("ARCHUD_FRAME_MOVED", 	"CheckFrames")

	-- Set initial combat flags
	self.PlayerIsInCombat = false
	self.PlayerIsRegenOn = true
	self.PetIsInCombat = false

	self:LevelDebug(d_warn, "OnProfileChanged() A")
	self:OnProfileChanged()
	self:LevelDebug(d_warn, "OnProfileChanged() B")

	self.Enabled = true
	
	ArcHUDFrame:Show()
	
	self:LevelDebug(d_notice, "Triggering ring enable event")
	self:SendMessage("ARCHUD_MODULE_ENABLE")
	self:LevelDebug(d_info, L["TEXT_ENABLED"])
	
	if (AH_RuneFrame) then
		AH_RuneFrame:Show()
	end
	
	-- load custom buff modules (OnInitialize() is too early)
	self:LoadCustomBuffModules()
end

----------------------------------------------
-- OnDisable()
----------------------------------------------
function ArcHUD:OnDisable()
	self:LevelDebug(d_notice, "Triggering ring disable event")
	self:SendMessage("ARCHUD_MODULE_DISABLE")

	self:HideBlizzardPlayer(true)
	self:HideBlizzardTarget(true)
	self:HideBlizzardFocus(true)
	
	-- basic events
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	self:UnregisterEvent("PLAYER_ENTER_COMBAT")
	self:UnregisterEvent("PLAYER_LEAVE_COMBAT")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PET_ATTACK_START")
	self:UnregisterEvent("PET_ATTACK_STOP")

	self:UnregisterEvent("UNIT_FACTION")
	self:UnregisterEvent("PARTY_MEMBERS_CHANGED")

	self:UnregisterEvent("RAID_TARGET_UPDATE")

	self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
	self:UnregisterEvent("PLAYER_UPDATE_RESTING")

	if ArcHUD.classic then
		self:UnregisterEvent("UNIT_HAPPINESS")
	end

	self:UnregisterMessage("ARCHUD_FRAME_MOVED")
	
	-- Hide frame
	ArcHUDFrame:Hide()

	self.Enabled = false
	self:LevelDebug(d_info, L["TEXT_DISABLED"])
end

----------------------------------------------
-- OnProfileChanged()
----------------------------------------------
function ArcHUD:OnProfileChanged(db, profile)
	self.updating = true

	self:UnregisterAll()
	self:LevelDebug(d_notice, "OnProfileChanged()")
	
	if(self.db.profile.BlizzPlayer and self.BlizzPlayerHidden or not self.db.profile.BlizzPlayer and not self.BlizzPlayerHidden) then
		self:HideBlizzardPlayer(self.db.profile.BlizzPlayer)
	end
	if(self.db.profile.BlizzTarget and self.BlizzTargetHidden or not self.db.profile.BlizzTarget and not self.BlizzTargetHidden) then
		self:HideBlizzardTarget(self.db.profile.BlizzTarget)
	end
	if(self.db.profile.BlizzFocus and self.BlizzFocusHidden or not self.db.profile.BlizzFocus and not self.BlizzFocusHidden) then
		self:HideBlizzardFocus(self.db.profile.BlizzFocus)
	end
	
	if (SpellActivationOverlayFrame) then
		SpellActivationOverlayFrame:SetScale(self.db.profile.BlizzSpellActScale)
		if self.db.profile.BlizzSpellActCenter then
			SpellActivationOverlayFrame:ClearAllPoints()
			SpellActivationOverlayFrame:SetPoint("CENTER", ArcHUDFrame, "CENTER", 0, -87)
		else
			SpellActivationOverlayFrame:ClearAllPoints()
			SpellActivationOverlayFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		end
		self:HookBlizzardSpellActivation((self.db.profile.BlizzSpellActOpacity < 1.0))
	end
	
	if (self.db.profile.PlayerFrame) then
		self.Nameplates.player:Show()
		self.Nameplates.pet:Show()
	else
		self.Nameplates.player:Hide()
		self.Nameplates.pet:Hide()
	end
	
	if(self.db.profile.TargetFrame) then
		self:LevelDebug(d_notice, "Targetframe enabled. Registering unit events")
		self:RegisterEvent("UNIT_HEALTH", 			"EventHandler")
		self:RegisterEvent("UNIT_MAXHEALTH", 		"EventHandler")
		self:RegisterEvent("UNIT_POWER_UPDATE", 	"EventHandler")
		self:RegisterEvent("UNIT_MAXPOWER",			"EventHandler")
		self:RegisterEvent("UNIT_DISPLAYPOWER", 	"EventHandler")
		if(self.db.profile.ShowBuffs) then
			self:RegisterEvent("UNIT_AURA", 		"TargetAuras")
		else
			for i=1,40 do
				self.TargetHUD["Buff"..i]:Hide()
				self.TargetHUD["Debuff"..i]:Hide()
			end
		end
		self:RegisterEvent("PLAYER_TARGET_CHANGED",	  "TargetUpdate")
		if (not ArcHUD.classic) then
			self:RegisterEvent("PLAYER_FOCUS_CHANGED", 	  "TargetUpdate")
		end

		-- Show target frame if we have a target
		if(UnitExists("target")) then
			self:TargetUpdate()
		end

		self:LevelDebug(d_notice, "Enabling TargetTarget updates")
		-- Enable Target's Target('s Target) updates
		self:StartTimer("UpdateTargetTarget")

		if(self.db.profile.AttachTop) then
			self:LevelDebug(d_notice, "Attaching targetframe to top")
			self.TargetHUD:ClearAllPoints()
			self.TargetHUD:SetPoint("BOTTOM", self.TargetHUD:GetParent(), "TOP", 0, -100)
		else
			self:LevelDebug(d_notice, "Attaching targetframe to bottom")
			self.TargetHUD:ClearAllPoints()
			self.TargetHUD:SetPoint("TOP", self.TargetHUD:GetParent(), "BOTTOM", 0, -60)
		end

		-- Check for custom frame placements
		for id, pos in pairs(self.db.profile.Positions) do
			if(type(pos) == "table") then
				self.movableFrames[id]:ClearAllPoints()
				self.movableFrames[id]:SetPoint("BOTTOMLEFT", WorldFrame, "BOTTOMLEFT", pos.x, pos.y)
			end
		end
	else
		self:StopTimer("UpdateTargetTarget")
		self:StopTimer("UpdateTargetPower")
		self.TargetHUD:SetAlpha(0)
		self.TargetHUD:Lock()
		
		self:UnregisterEvent("UNIT_HEALTH", 			"EventHandler")
		self:UnregisterEvent("UNIT_MAXHEALTH", 			"EventHandler")
		self:UnregisterEvent("UNIT_POWER_UPDATE", 				"EventHandler")
		self:UnregisterEvent("UNIT_MAXPOWER",			"EventHandler")
		self:UnregisterEvent("UNIT_DISPLAYPOWER", 		"EventHandler")
		self:UnregisterEvent("UNIT_AURA", 				"TargetAuras")
		self:UnregisterEvent("PLAYER_TARGET_CHANGED",	"TargetUpdate")
		if (not ArcHUD.classic) then
			self:UnregisterEvent("PLAYER_FOCUS_CHANGED", 	"TargetUpdate")
		end
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

	--self:LevelDebug(d_notice, "Position frame. YLoc: "..self.db.profile.YLoc.." XLoc: "..self.db.profile.XLoc)
	ArcHUDFrame:ClearAllPoints()
	ArcHUDFrame:SetPoint("CENTER", WorldFrame, "CENTER", self.db.profile.XLoc, self.db.profile.YLoc)

	--self:LevelDebug(d_notice, "Setting scale. Scale: "..self.db.profile.Scale)
	-- Scale the HUD according to user settings.
	ArcHUDFrame:SetScale(self.db.profile.Scale)
	
	-- Scale TargetHUD according to user settings (relative to ArcHUDFrame).
	self.TargetHUD:SetScale(self.db.profile.ScaleTargetFrame)
	
	-- Set playername
	self:UpdateFaction()
	self:PLAYER_UPDATE_RESTING()

	-- Enable nameplate updates
	self:RestartNamePlateTimers()
	
	-- Update target HUD
	self:UpdateTargetHUD()
	
	-- Modules
	self:SendMessage("ARCHUD_MODULE_UPDATE")
	
	self.updating = false

	self:LevelDebug(d_notice, "OnProfileChanged() done")
end

----------------------------------------------
-- UnregisterAll()
----------------------------------------------
function ArcHUD:UnregisterAll()
	self:LevelDebug(d_notice, "Unregistering events")

	self:UnregisterEvent("UNIT_HEALTH")
	self:UnregisterEvent("UNIT_MAXHEALTH")
	self:UnregisterEvent("UNIT_POWER_UPDATE")
	self:UnregisterEvent("UNIT_MAXPOWER")
	self:UnregisterEvent("UNIT_DISPLAYPOWER")

	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("UNIT_FACTION") 
	self:UnregisterEvent("PLAYER_TARGET_CHANGED") 
	if (not ArcHUD.classic) then
		self:UnregisterEvent("PLAYER_FOCUS_CHANGED") 
	end

	self:LevelDebug(d_notice, "Disabling timers")
	self:StopTimer("UpdateTargetTarget")
	self:StopTimer("UpdatePetNamePlate")
	self:StopTimer("CheckNamePlateMouseOver")
	self:StopTimer("UpdateTargetPower")

	self:LevelDebug(d_notice, "Hiding frames")
	for i=1,40 do
		self.TargetHUD["Buff"..i]:Hide()
		self.TargetHUD["Debuff"..i]:Hide()
	end
	self.TargetHUD:SetAlpha(0)
end

----------------------------------------------
-- ResetOptionsConfirm()
----------------------------------------------
function ArcHUD:ResetOptionsConfirm()
	self.db:ResetDB()
	self:OnProfileChanged()
	self:Print(L["TEXT_RESET_CONFIRM"])
end

----------------------------------------------
-- Completely refresh HUD
----------------------------------------------
function ArcHUD:UpdateTargetHUD()
	self:TargetUpdate()
end

----------------------------------------------
-- TargetUpdate()
----------------------------------------------
function ArcHUD:TargetUpdate(event, arg1)
	
	-- Make sure we are targeting someone and that ArcHUD is enabled
	if (UnitExists("target") and self.db.profile.TargetFrame) then
		--self:LevelDebug(d_info, "TargetUpdate: Updating target frame...")

		-- 3D target model
		if((self.db.profile.PlayerModel and UnitIsPlayer("target")) or (self.db.profile.MobModel and not UnitIsPlayer("target"))) then
			self.TargetHUD.Model:Show()
			self.TargetHUD.Model:SetUnit("target")
			--self:LevelDebug(d_notice, "TargetUpdate: Enabling 3D model. Player - "..((self.db.profile.PlayerModel and UnitIsPlayer("target")) and "yes" or "no")..", Mob - "..((self.db.profile.MobModel and not UnitIsPlayer("target")) and "yes" or "no"))
		else
			self.TargetHUD.Model:Hide()
			--self:LevelDebug(d_notice, "TargetUpdate: Disabling 3D model")
		end

		self.TargetHUD:SetAlpha(1)

		if(UnitIsDead("target") or UnitIsGhost("target")) then
			self.TargetHUD.HPText:SetText("Dead")
		else
			if self.db.profile.ShowHealthPowerTextMax then
				self.TargetHUD.HPText:SetText(self:fint(UnitHealth("target")).."/"..self:fint(UnitHealthMax("target")))
			else
				self.TargetHUD.HPText:SetText(self:fint(UnitHealth("target")))
			end
		end

		-- Does the unit have power? If so we want to show it
		if (UnitPowerMax("target") > 0) then
			if self.db.profile.ShowHealthPowerTextMax then
				self.TargetHUD.MPText:SetText(self:fint(UnitPower("target")).."/"..self:fint(UnitPowerMax("target")))
			else
				self.TargetHUD.MPText:SetText(self:fint(UnitPower("target")))
			end
			self:StartTimer("UpdateTargetPower")
		else
			self.TargetHUD.MPText:SetText(" ")
			self:StopTimer("UpdateTargetPower")
		end

		local addtolevel = ""
		if(self.db.profile.ShowClass) then
			addtolevel = " " .. (UnitIsPlayer("target") and UnitClass("target") or UnitCreatureFamily("target") or UnitCreatureType("target") or "Unknown")
			self.TargetHUD.Level:SetJustifyH("CENTER")
		else
			self.TargetHUD.Level:SetJustifyH("CENTER")
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
			self:TargetAuras(nil, "target")
		end

		self:UpdateFaction("target")
		self:UpdateRaidTargetIcon()
		self:PLAYER_FLAGS_CHANGED("target")

		if(self.BlizzTargetHidden and not self.updating) then
			if(UnitIsEnemy("target", "player")) then
				PlaySound(SOUNDKIT.IG_CREATURE_AGGRO_SELECT) -- igCreatureAggroSelect
			elseif(UnitIsFriend("player", "target")) then
				PlaySound(SOUNDKIT.IG_CHARACTER_NPC_SELECT) -- igCharacterNPCSelect
			else
				PlaySound(SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT) -- igCreatureNeutralSelect
			end
		end

		self.Nameplates.target:Enable()
	else
		-- We didn't have anything targeted or ArcHUD is disabled so lets hide the
		--   target frame again
		if(self.BlizzTargetHidden and not self.updating) then
			PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT) -- INTERFACESOUND_LOSTTARGETUNIT
		end
		if (self.TargetHUD.locked) then
			self.TargetHUD:SetAlpha(0)
		else
			self.TargetHUD:SetAlpha(1)
		end
		
		self.TargetHUD.Model:Hide()

		self:StopTimer("UpdateTargetPower")
		self.Nameplates.target:Disable()
	end
end

----------------------------------------------
-- TargetAuras()
----------------------------------------------
function ArcHUD:TargetAuras(event, arg1)
	if(not arg1 == "target") then return end
	local unit = "target"
	local i, icon, buff, count, buffType, color, duration, expirationTime
	local filter = ""
	
	if (self.db.profile.ShowOnlyBuffsCastByPlayer) then
		filter = "PLAYER"
	end
	
	-- buffs
	for i = 1, 40 do
		local _, buff, count, buffType, duration, expirationTime = UnitBuff(unit, i, filter)
		button = self.TargetHUD["Buff"..i]
		if (buff) then
			button.Icon:SetTexture(buff)
			button:Show()
			button.unit = unit

			if (count > 1) then
				button.Count:SetText(count)
				button.Count:Show()
				button.Count:SetPoint("CENTER", button, "CENTER", 2, 0)
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

	-- debuffs
	for i = 1, 40 do
		local _, buff, count, buffType, duration, expirationTime = UnitDebuff(unit, i, filter)
		button = self.TargetHUD["Debuff"..i]
		if (buff) then
			button.Icon:SetTexture(buff)
			button:Show()
			button.Border:Show()
			button.isdebuff = 1
			button.unit = unit
			
			if ( buffType ) then
				color = DebuffTypeColor[buffType]
			else
				color = DebuffTypeColor["none"]
			end
			button.Border:SetVertexColor(color.r, color.g, color.b)
			
			if (count > 1) then
				button.Count:SetText(count)
				button.Count:Show()
				button.Count:SetPoint("CENTER", button, "CENTER", 2, 0)
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
	if (not this:IsVisible() or (self.db.profile.ShowBuffTooltips == false)) then return end
	if (self.db.profile.HideBuffTooltipsIC and self.PlayerIsInCombat) then return end

	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	local unit = this.unit
	if (this.isdebuff == 1) then
		GameTooltip:SetUnitDebuff(unit, this:GetID())
	else
		GameTooltip:SetUnitBuff(unit, this:GetID())
	end
end

----------------------------------------------
-- UpdateTargetPower()
----------------------------------------------
function ArcHUD:UpdateTargetPower()
	if self.db.profile.ShowHealthPowerTextMax then
		self.TargetHUD.MPText:SetText(self:fint(UnitPower("target")).."/"..self:fint(UnitPowerMax("target")))
	else
		self.TargetHUD.MPText:SetText(self:fint(UnitPower("target")))
	end
end

----------------------------------------------
-- UpdateFaction()
----------------------------------------------
function ArcHUD:UpdateFaction(unit)
	--self:LevelDebug(d_info, "UpdateFaction: arg1 = %s, unit = %s", arg1 or "nil", unit or "nil")

	if(not unit and arg1 and arg1 ~= "player") then return end
	if(arg1 and not unit) then unit = arg1 end

	if(unit and unit == "target") then
		local factionGroup = UnitFactionGroup("target")
		if(UnitIsPVPFreeForAll("target")) then
			self.TargetHUD.PVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
			self.TargetHUD.PVPIcon:Show()
		elseif(factionGroup and UnitIsPVP("target") and factionGroup ~= "Neutral") then
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
				PlaySound(SOUNDKIT.IG_PVP_UPDATE)
			end
			self.Nameplates.player.Text:SetText("|cffffff00[FFA] |cff"..(color or "ffffff")..(UnitName("player") or "Unknown Entity").."|r")
			self.PVPEnabled = true
		elseif(self.db.profile.ShowPVP and factionGroup and UnitIsPVP("player")) then
			if(not self.PVPEnabled) then
				PlaySound(SOUNDKIT.IG_PVP_UPDATE)
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
		if(UnitIsGroupLeader("target")) then
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
		local color = "00ff00"
		local alpha = self.db.profile.FadeFull
		local happiness = ""
		if ArcHUD.classic then
			happiness, _, _ = GetPetHappiness()
			if(happiness) then
				if(happiness == 1) then
					color = "ff0000"
					happiness = "  :("
					alpha = self.db.profile.FadeIC
				elseif(happiness == 2) then
					color = "ffff00"
					happiness = "  :||"
					alpha = self.db.profile.FadeOOC
				elseif(happiness == 3) then
					color = "00ff00"
					happiness = "  :)"
					alpha = self.db.profile.FadeFull
				end
			else
				happiness = ""
			end
		end
		self.Nameplates.pet.alpha = alpha
		if ((not self.Nameplates.pet.state)) then
			ArcHUDRingTemplate.SetRingAlpha(self.Nameplates.pet, alpha)
		end
		self.Nameplates.pet.Text:SetText("|cff"..color..UnitName("pet")..happiness.."|r")
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
					self:LevelDebug(d_notice, "UpdateFonts: fontName = %s, localeFont = %s", fontName, L["FONT"])
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
	local class = nil
	if (arg1 and type(arg1) == "string") then
		_, class = UnitClass(arg1)
	end

	if (event == "UNIT_DISPLAYPOWER") then
		local info = {}
		if (arg1 == "target") then
			if (UnitPowerType(arg1) == 0) then
				info = { r = 0.00, g = 1.00, b = 1.00 }
			else
				info = PowerBarColor[UnitPowerType(arg1)]
			end
			self.TargetHUD.MPText:SetTextColor(info.r, info.g, info.b)
		end

	elseif (event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH") then
		if (arg1 == "target") then
			if self.db.profile.ShowHealthPowerTextMax then
				self.TargetHUD.HPText:SetText(self:fint(UnitHealth(arg1)).."/"..self:fint(UnitHealthMax(arg1)))
			else
				self.TargetHUD.HPText:SetText(self:fint(UnitHealth(arg1)))
			end
		end

	elseif(event == "PLAYER_ENTERING_WORLD") then
		self.PlayerIsInCombat = false
		self.PlayerIsRegenOn = true

	else
		if (arg1 == "target") then
			self.TargetHUD.MPText:SetText(self:fint(UnitPower(arg1)).."/"..self:fint(UnitPowerMax(arg1)))
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
function ArcHUD:CombatStatus(event, arg1, arg2)
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

----------------------------------------------
-- Register a timer
----------------------------------------------
function ArcHUD:RegisterTimer(name, callback, delay, arg, repeating)
	self.timers[name] = {func = callback, delay = delay, arg = arg, repeating = repeating}
end

----------------------------------------------
-- Start a registered timer
----------------------------------------------
function ArcHUD:StartTimer(name)
	local t = self.timers[name]
	if (t) then
		if not (t.active and (t.repeating or GetTime()-t.startTime < t.delay)) then
			if (t.repeating) then
				self.timers[name].handle = self:ScheduleRepeatingTimer(t.func, t.delay, t.arg)
				self.timers[name].active = true
				--self:LevelDebug(d_warn, "Started repeating timer "..name..", handle "..tostring(self.timers[name].handle))
			else
				self.timers[name].handle = self:ScheduleTimer(t.func, t.delay, t.arg)
				self.timers[name].active = true
				self.timers[name].startTime = GetTime()
				--self:LevelDebug(d_warn, "Started single-shot timer "..name..", handle "..tostring(self.timers[name].handle))
			end
		end
	else
		self:LevelDebug(d_warn, "WARN: Tried to start unregistered timer (name "..name..")")
	end
end

----------------------------------------------
-- Stop a registered timer
----------------------------------------------
function ArcHUD:StopTimer(name)
	local t = self.timers[name]
	if (t) then
		if (t.active) then
			if (not self:CancelTimer(t.handle, true)) then
				self:LevelDebug(d_warn, "WARN: Tried to cancel invalid timer handle (name "..name..")")
			--else
				--self:LevelDebug(d_warn, "Stopped "..name..", handle "..tostring(t.handle))
			end
			self.timers[name].handle = nil
			self.timers[name].active = nil
		end
	else
		self:LevelDebug(d_warn, "WARN: Tried to cancel unregistered timer (name "..name..")")
	end
end

----------------------------------------------
-- List timers
----------------------------------------------
function ArcHUD:TimersPrintPerf()
	for n,t in pairs(self.timers) do
		self:LevelDebug(d_warn, n..": delay "..t.delay..
			", repeat "..tostring(t.repeating)..
			", active "..tostring((t.repeating and t.active) or (t.active and GetTime()-t.startTime <= t.delay)))
	end
end
