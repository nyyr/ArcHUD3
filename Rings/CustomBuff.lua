-- localization
local LM = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Module")
local AceAddon = LibStub("AceAddon-3.0")

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local LibClassicDurations = nil

-- classic/retail differences
local UnitAura = UnitAura	-- on retail this improves performance, on classic it prevents tainting the global
if ArcHUD.isClassicWoW then
	LibClassicDurations = LibStub("LibClassicDurations", true)
	LibClassicDurations:Register("ArcHUD_CustomBuffModule")
	UnitAura = LibClassicDurations.UnitAuraWrapper
end

ArcHUD.customModuleCount = 0
ArcHUD.customModules = {}

local CustomBuffRingTemplate = {}

CustomBuffRingTemplate.version = "1.4 (@file-abbreviated-hash@)"

CustomBuffRingTemplate.unit = "player"
CustomBuffRingTemplate.noAutoAlpha = true

CustomBuffRingTemplate.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		ShowText = true,
		Flash = false,
		Side = 2,
		Level = 2,
		ShowSeparators = false,
		Color = {r = 1, g = 1, b = 0.5},
		
		Debuff = false,
		Unit = "player",
		BuffName = "<new>",			-- buff name
		CastByPlayer = true,		-- only show if (de)buff is cast by player
		UseStacks = false,			-- display either stacks or remaining time
		TextUseStacks = false,		-- display either stacks or remaining time
		MaxCount = 1,				-- maximum possible appliances of buff
	}
}

CustomBuffRingTemplate.options = {
	{name = "ShowText", text = "SHOWTEXT", tooltip = "SHOWTEXT"},
	{name = "Flash", text = "FLASH", tooltip = "FLASH"},
	hascolor = true,
	attach = true,
	hasseparators = true,
}

CustomBuffRingTemplate.localized = true

function CustomBuffRingTemplate:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)
	
	self.BuffButton = CreateFrame("Button", nil, self.f)
	self.BuffButton:SetWidth(15)
	self.BuffButton:SetHeight(15)
	self.BuffButton:SetPoint("TOP", self.f)
	self.BuffButton:EnableMouse(false);

	self.BuffButton.Icon = self.BuffButton:CreateTexture(nil, "ARTWORK")
	self.BuffButton.Icon:SetWidth(15)
	self.BuffButton.Icon:SetHeight(15)
	self.BuffButton.Icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	self.BuffButton.Icon:SetPoint("CENTER", self.BuffButton, "CENTER")
	self.BuffButton.Icon:Show()

	self.BuffButton:Show()
	
	self.Text = self:CreateFontString(self.BuffButton, "OVERLAY", {40, 12}, 10, "CENTER", {1.0, 1.0, 1.0}, {"TOP", self.BuffButton, "TOP", 1, -2})
	self.Text:Show()
	
	self:RegisterTimer("UpdateBuff", self.UpdateBuff, 0.1, self, true)
	
	self:CreateStandardModuleOptions(0)
	self:AppendCustomModuleOptions()
end

function CustomBuffRingTemplate:OnModuleUpdate()
	-- Update unit
	if self.unit ~= self.db.profile.Unit then
		self.unit = self.db.profile.Unit
		self:UnregisterUnitEvent("UNIT_AURA")
		self:RegisterUnitEvent("UNIT_AURA", "EventHandler") -- default unit is self.unit
	end

	self.Flash = self.db.profile.Flash
	self:UpdateColor()
	
	self.BuffButton:ClearAllPoints()
	if(self.db.profile.Side == 1) then
		-- Attach to left side
		self.BuffButton:SetPoint("TOP", self.f, "BOTTOMLEFT", -20, -130)
	else
		-- Attach to right side
		self.BuffButton:SetPoint("TOP", self.f, "BOTTOMLEFT", 20, -130)
	end
	
	if (self.db.profile.ShowText) then
		self.Text:Show()
	else
		self.Text:SetText("")
		self.Text:Hide()
	end
	
	self.BuffButton:Show()
	
	self.BuffNames = { strsplit(";", self.db.profile.BuffName) }
	for i,n in ipairs(self.BuffNames) do
		self.BuffNames[i] = strtrim(n)
	end
	
	self.f:SetMax(self.db.profile.MaxCount)
	self:UpdateBuff()
end

function CustomBuffRingTemplate:OnModuleEnable()
	self.f.dirty = true
	self.f.maxFadeTime = 0.25
	
	self.unit = self.db.profile.Unit
	self.f:SetMax(self.db.profile.MaxCount)
	self.f:SetValue(0)
	
	self.BuffNames = { strsplit(";", self.db.profile.BuffName) }
	for i,n in ipairs(self.BuffNames) do
		self.BuffNames[i] = strtrim(n)
	end

	self:UpdateColor()
	self:UpdateBuff()

	-- Register the events we will use
	self:RegisterEvent("PLAYER_ENTERING_WORLD",	"EventHandler")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "EventHandler")
	if not ArcHUD.classic then
		self:RegisterEvent("PLAYER_FOCUS_CHANGED", 	"EventHandler")
	end
	self:RegisterUnitEvent("UNIT_AURA",			"EventHandler")

	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
	
	--self:Debug(1, "CustomBuffRingTemplate:OnModuleEnable()")
end

function CustomBuffRingTemplate:OnModuleDisable()
	-- Unregister events
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	if not ArcHUD.classic then
		self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
	end
	self:UnregisterUnitEvent("UNIT_AURA")

	self:StopTimer("UpdateBuff")
end

local function CustomBuff_UpdateBuff(frame, elapsed)
	frame.module:UpdateBuff()
end

local function CustomBuff_UnitAuraByName(unit, auraName, isDebuff)
	local name, iconTex, count, duration, expirationTime, unitCaster
	
	local filter = "HELPFUL"
	if isDebuff then
		filter = "HARMFUL"
	end

	for i = 1, 40 do
		name, iconTex, count, _, duration, expirationTime, unitCaster = UnitAura(unit, i, filter)
		if not name then
			return nil
		end
		if name == auraName then
			return name, iconTex, count, duration, expirationTime, unitCaster
		end
	end
end

function CustomBuffRingTemplate:UpdateBuff()
	local name, iconTex, count, duration, expirationTime, unitCaster
	local visible = false
	local timer = false
	
	for i,n in ipairs(self.BuffNames) do
		name, iconTex, count, duration, expirationTime, unitCaster = 
			CustomBuff_UnitAuraByName(self.unit, n, self.db.profile.Debuff)
		if (name and ((not self.db.profile.CastByPlayer) or unitCaster == "player")) then
			break -- prioritize buffs in their given order
		end
	end
	
	if (name and ((not self.db.profile.CastByPlayer) or unitCaster == "player")) then
	
		-- ring
		if (self.db.profile.UseStacks) then
			if (self.f.casting) then self.f.casting = 0 end
			self.f:SetValue(count)
			visible = true
			
		elseif (duration) then
			if (not self.f.casting) then self.f.casting = 1 end
			if (self.db.profile.MaxCount > 1) then
				local m = self.db.profile.MaxCount*1000
				if (self.f.maxValue ~= m) then
					self.f:SetMax(m)
				end
			else
				local m = duration*1000
				if (math.floor(self.f.maxValue) ~= math.floor(m)) then
					self.f:SetMax(m)
				end
			end
			local t = GetTime()
			if (expirationTime > t) then
				self.f:SetValue((expirationTime - t)*1000)
				visible = true
				timer = true
			end
			
		end
		
		-- text
		if (self.db.profile.ShowText) then
			if (self.db.profile.TextUseStacks) then
				self.Text:SetText(count)
			elseif (duration) then
				local t = GetTime()
				if (expirationTime > t) then
					self.Text:SetText(math.floor(expirationTime - t))
					timer = true
				end
			else
				self.Text:SetText("")
			end
		end
		
		-- buff icon
		self.BuffButton.Icon:SetTexture(iconTex)
		
		-- flashing
		if(count < self.db.profile.MaxCount and count >= 0) then
			self.f:StopPulse()
		else
			if(self.Flash) then
				self.f:StartPulse()
			else
				self.f:StopPulse()
			end
		end
		
		--self:Debug(1, "Visible "..tostring(visible)..", Timer "..tostring(timer)..", alpha "..tostring(self.f:GetAlpha())..
		--	", unit "..self.unit..", buff "..name)

	end
	
	if (visible) then
		if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
			self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
		else
			self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
		end
	else
		if (self.f.endValue > 0) then
			self.f.casting = 0
			self.f:StopPulse()
			self.f:SetRingAlpha(0)
			self.f:SetValue(0)
			self.Text:SetText("")
		end
	end
	
	if (timer) then
		if (self.f.casting) then
			if (self.f.UpdateHook == nil) then
				self.f.UpdateHook = CustomBuff_UpdateBuff
			end
			-- we do not need a timer if we have an update hook
		else
			self:StartTimer("UpdateBuff")
			self.timerStarted = true
		end
		
	else
		if (self.timerStarted) then
			self:StopTimer("UpdateBuff")
			self.timerStarted = false
		end
		if (self.f.UpdateHook ~= nil) then
			self.f.UpdateHook = nil
		end
		
	end
end

function CustomBuffRingTemplate:EventHandler(event, arg1, arg2)
	if (event == "UNIT_AURA" and arg1 ~= self.unit) then
		return
	end
	
	self:UpdateBuff()
end

function CustomBuffRingTemplate:AppendCustomModuleOptions()

	self.optionsTable.args.Debuff = {
		type		= "toggle",
		name		= LM["TEXT"]["CUSTDEBUFF"],
		desc		= LM["TOOLTIP"]["CUSTDEBUFF"],
		order		= 1,
		get			= function ()
			return self.db.profile.Debuff
		end,
		set			= function (info, v)
			self.db.profile.Debuff = v
			self:OnModuleUpdate()
		end,
	}
	
	self.optionsTable.args.Unit = {
		type		= "select",
		name		= LM["TEXT"]["CUSTUNIT"],
		desc		= LM["TOOLTIP"]["CUSTUNIT"],
		values		= {player = "player", target = "target", pet = "pet", focus = "focus"},
		order		= 2,
		get			= function ()
			return self.db.profile.Unit
		end,
		set			= function (info, v)
			self.db.profile.Unit = v
			self:OnModuleUpdate()
			self.optionsTable.name = self.db.profile.BuffName .. " (" .. self.db.profile.Unit .. ")"
			AceConfigRegistry:NotifyChange("ArcHUD_CustomModules")
		end,
	}

	if ArcHUD.classic then
		self.optionsTable.args.Unit.values.focus = nil
	end
	
	self.optionsTable.args.BuffName = {
		type		= "input",
		name		= LM["TEXT"]["CUSTNAME"],
		desc		= LM["TOOLTIP"]["CUSTNAME"],
		order		= 3,
		get			= function ()
			return self.db.profile.BuffName
		end,
		set			= function (info, v)
			self.db.profile.BuffName = v
			self:OnModuleUpdate()
			self.optionsTable.name = self.db.profile.BuffName .. " (" .. self.db.profile.Unit .. ")"
			AceConfigRegistry:NotifyChange("ArcHUD_CustomModules")
		end,
	}
	
	self.optionsTable.args.CastByPlayer = {
		type		= "toggle",
		name		= LM["TEXT"]["CUSTCASTBYPLAYER"],
		desc		= LM["TOOLTIP"]["CUSTCASTBYPLAYER"],
		order		= 4,
		get			= function ()
			return self.db.profile.CastByPlayer
		end,
		set			= function (info, v)
			self.db.profile.CastByPlayer = v
			self:OnModuleUpdate()
		end,
	}
	
	self.optionsTable.args.UseStacks = {
		type		= "toggle",
		name		= LM["TEXT"]["CUSTSTACKS"],
		desc		= LM["TOOLTIP"]["CUSTSTACKS"],
		order		= 5,
		get			= function ()
			return self.db.profile.UseStacks
		end,
		set			= function (info, v)
			self.db.profile.UseStacks = v
			self:OnModuleUpdate()
		end,
	}
	
	self.optionsTable.args.TextUseStacks = {
		type		= "toggle",
		name		= LM["TEXT"]["CUSTTEXTSTACKS"],
		desc		= LM["TOOLTIP"]["CUSTTEXTSTACKS"],
		order		= 6,
		get			= function ()
			return self.db.profile.TextUseStacks
		end,
		set			= function (info, v)
			self.db.profile.TextUseStacks = v
			self:OnModuleUpdate()
		end,
	}
	
	self.optionsTable.args.MaxCount = {
		type		= "input",
		name		= LM["TEXT"]["CUSTMAX"],
		desc		= LM["TOOLTIP"]["CUSTMAX"],
		order		= 7,
		get			= function (info)
			return tostring(self.db.profile.MaxCount)
		end,
		set			= function (info, v)
			v = tonumber(v)
			if (not v) or v < 1 then
				return ArcHUD:Printf(LM["TEXT"]["CUSTMAXVALIDATE"])
			else
				v = math.floor(v)
				self.db.profile.MaxCount = v
				self.f:SetMax(v)
				self:OnModuleUpdate()
			end
		end,
	}
	
	self.optionsTable.args.Delete = {
		type		= "execute",
		name		= LM["TEXT"]["CUSTDEL"],
		desc		= LM["TOOLTIP"]["CUSTDEL"],
		order		= 19,
		func		= function ()
			ArcHUD:DeleteCustomBuffModule(self)
		end,
	}
	
	self.optionsTable.args.archeader = {
		type		= "header",
		name		= LM["TEXT"]["CUSTRING"],
		order		= 20,
	}
	
end

----------------------------------------------
-- Create a new custom buff module
----------------------------------------------
function ArcHUD:CreateCustomBuffModule(config)
	local name, module
	local recycled = false
	
	-- Limit the number of custom modules
	if (self.customModuleCount >= 32) then
		self:Print("Too many instances ("..self.customModuleCount..") of custom buff module.")
		return
	end
	
	-- Check if we can reuse a deleted module
	for i,m in ipairs(self.customModules) do
		if m.deleted then
			module = m
			name = module:GetName()
			module.deleted = false
			recycled = true
			break
		end
	end

	-- Create a new module if necessary
	if (module == nil) then
		self.customModuleCount = self.customModuleCount + 1
		name = "Custom_"..self.customModuleCount
		module = self:NewModule(name)
	
		module.isCustom		= true
		module.version 		= CustomBuffRingTemplate.version
		module.unit 		= CustomBuffRingTemplate.unit
		module.noAutoAlpha 	= CustomBuffRingTemplate.noAutoAlpha
		module.defaults 	= CustomBuffRingTemplate.defaults
		module.options 		= CustomBuffRingTemplate.options
		module.localized 	= CustomBuffRingTemplate.localized
		
		module.Initialize 		= CustomBuffRingTemplate.Initialize
		module.OnModuleUpdate 	= CustomBuffRingTemplate.OnModuleUpdate
		module.OnModuleEnable 	= CustomBuffRingTemplate.OnModuleEnable
		module.OnModuleDisable 	= CustomBuffRingTemplate.OnModuleDisable
		module.UpdateBuff 		= CustomBuffRingTemplate.UpdateBuff
		module.EventHandler 	= CustomBuffRingTemplate.EventHandler
		module.AppendCustomModuleOptions = CustomBuffRingTemplate.AppendCustomModuleOptions
	end
	
	-- Initialize settings
	module.db = { profile = {} }
	if (config == nil) then
		-- copy by value
		config = CustomBuffRingTemplate.defaults.profile
		config.Color = {r = config.Color.r, g = config.Color.g, b = config.Color.b}
		for k,v in pairs(config) do
			module.db.profile[k] = v
		end
	else
		module.db.profile = config
	end
	
	table.insert(self.customModules, module)
	self:LevelDebug(1, "Created new custom buff module: "..module.db.profile.BuffName..", "..module.db.profile.Unit)
	
	if (recycled) then
		module:Initialize()
		module:InitConfigOptions()
		module:Enable()
	else
		-- Needed for dynamically created modules
		-- (i.e. modules created after the ADDON_LOADED event)
		AceAddon:InitializeAddon(module)
		AceAddon:EnableAddon(module)
	end
end

----------------------------------------------
-- Delete a custom buff module
----------------------------------------------
function ArcHUD:DeleteCustomBuffModule(module)
	-- we cannot remove a module completely during run time
	-- just ensure that it shuts up and that its settings are removed
	ArcHUD:RemoveCustomModuleOptionsTable("ArcHUD_"..module:GetName())
	module.deleted = true
	module:Disable()
	
	self:SyncCustomModuleSettings()
end

----------------------------------------------
-- Save settings for custom modules
-- Note: Do not call within :CreateCustomBuffModule()!
----------------------------------------------
function ArcHUD:SyncCustomModuleSettings()
	-- clear settings
	self.db.profile.CustomModules = {}
	
	-- synchronize settings
	for i,m in ipairs(self.customModules) do
		if not m.deleted then
			table.insert(self.db.profile.CustomModules, m.db.profile)
		end
	end
end

----------------------------------------------
-- Load saved custom modules
----------------------------------------------
function ArcHUD:LoadCustomBuffModules()
	if (self.customModuleCount == 0) then
		for i,config in ipairs(self.db.profile.CustomModules) do
			self:CreateCustomBuffModule(config)
		end
	end
end
