-- localization
local LM = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Module")

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

ArcHUD.customModuleCount = 0
ArcHUD.customModules = {}

local CustomBuffRingTemplate = {}

local _, _, rev = string.find("$Rev: 24 $", "([0-9]+)")
CustomBuffRingTemplate.version = "1.0 (r" .. rev .. ")"

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
		Color = {r = 1, g = 1, b = 0.5},
		
		Debuff = false,
		Unit = "player",
		BuffName = "<new>",			-- buff name
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
}

CustomBuffRingTemplate.localized = true

function CustomBuffRingTemplate:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)
	
	self.Text = self:CreateFontString(self.f, "BACKGROUND", {40, 12}, 10, "CENTER", {1.0, 1.0, 1.0}, {"TOP", self.f, "BOTTOMLEFT", 20, -130})
	
	self:RegisterTimer("UpdateBuff", self.UpdateBuff, 0.1, self, true)
	
	self:CreateStandardModuleOptions(0)
	self:AppendCustomModuleOptions()
end

function CustomBuffRingTemplate:OnModuleUpdate()
	self.Flash = self.db.profile.Flash
	
	self.Text:ClearAllPoints()
	if(self.db.profile.Side == 1) then
		-- Attach to left side
		self.Text:SetPoint("TOP", self.f, "BOTTOMLEFT", -20, -130)
	else
		-- Attach to right side
		self.Text:SetPoint("TOP", self.f, "BOTTOMLEFT", 20, -130)
	end
	
	self.f:SetMax(self.db.profile.MaxCount)
	self:UpdateBuff()
end

function CustomBuffRingTemplate:OnModuleEnable()
	self.f.dirty = true
	self.f.fadeIn = 0.25
	
	self.unit = self.db.profile.Unit
	self.f:SetMax(self.db.profile.MaxCount)
	self.f:SetValue(0)

	self.f:UpdateColor(self.db.profile.Color)
	self:UpdateBuff()

	-- Register the events we will use
	self:RegisterEvent("PLAYER_ENTERING_WORLD",	"EventHandler")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "EventHandler")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED", 	"EventHandler")
	self:RegisterEvent("UNIT_AURA",				"EventHandler")

	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
	
	self:Debug(1, "CustomBuffRingTemplate:OnModuleEnable()")
end

function CustomBuffRingTemplate:OnModuleDisable()
	-- Unregister events
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
	self:UnregisterEvent("UNIT_AURA")

	self:StopTimer("UpdateBuff")
end

function CustomBuffRingTemplate:UpdateBuff()
	local name, count, duration, expirationTime
	local visible = false
	local timer = false
	
	if (self.db.profile.Debuff) then
		name, _, _, count, _, duration, expirationTime = 
			UnitDebuff(self.unit, self.db.profile.BuffName) 
	else
		name, _, _, count, _, duration, expirationTime = 
			UnitBuff(self.unit, self.db.profile.BuffName) 
	end
	
	if (name) then
		
		-- ring
		if (self.db.profile.UseStacks) then
			self.f:SetValue(count)
			visible = true
		elseif (duration) then
			if (self.f.maxValue ~= duration*1000) then
				self.f:SetMax(duration*1000)
			end
			local t = GetTime()
			if (expirationTime > t) then
				self.f:SetValue((expirationTime - t)*1000)
				visible = true
				timer = true
			end
		end
		
		-- text
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
	
	end
	
	--self:Debug(1, "Visible "..tostring(visible)..", Timer "..tostring(timer)..", alpha "..tostring(self.f:GetAlpha()))
	self.f:Show()
	
	if (visible) then
		if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
			self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
		else
			self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
		end
	else
		self.f:StopPulse()
		self.f:SetRingAlpha(0)
		self.f:SetValue(0)
		self.Text:SetText("")
	end
	
	if (timer) then
		self:StartTimer("UpdateBuff")
	else
		self:StopTimer("UpdateBuff")
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
			self:UpdateBuff()
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
			self.unit = v
			self:UpdateBuff()
			self.optionsTable.name = self.db.profile.BuffName .. " (" .. self.db.profile.Unit .. ")"
			AceConfigRegistry:NotifyChange("ArcHUD_CustomModules")
		end,
	}
	
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
			self:UpdateBuff()
			self.optionsTable.name = self.db.profile.BuffName .. " (" .. self.db.profile.Unit .. ")"
			AceConfigRegistry:NotifyChange("ArcHUD_CustomModules")
		end,
	}
	
	self.optionsTable.args.UseStacks = {
		type		= "toggle",
		name		= LM["TEXT"]["CUSTSTACKS"],
		desc		= LM["TOOLTIP"]["CUSTSTACKS"],
		order		= 4,
		get			= function ()
			return self.db.profile.UseStacks
		end,
		set			= function (info, v)
			self.db.profile.UseStacks = v
			self:UpdateBuff()
		end,
	}
	
	self.optionsTable.args.TextUseStacks = {
		type		= "toggle",
		name		= LM["TEXT"]["CUSTTEXTSTACKS"],
		desc		= LM["TOOLTIP"]["CUSTTEXTSTACKS"],
		order		= 5,
		get			= function ()
			return self.db.profile.TextUseStacks
		end,
		set			= function (info, v)
			self.db.profile.TextUseStacks = v
			self:UpdateBuff()
		end,
	}
	
	self.optionsTable.args.MaxCount = {
		type		= "range",
		name		= LM["TEXT"]["CUSTMAX"],
		desc		= LM["TOOLTIP"]["CUSTMAX"],
		min			= 1,
		max			= 40,
		step		= 1,
		order		= 6,
		get			= function ()
			return self.db.profile.MaxCount
		end,
		set			= function (info, v)
			self.db.profile.MaxCount = v
			self.f:SetMax(v)
			self:UpdateBuff()
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
	if (self.customModuleCount >= 32) then
		-- TODO: reuse deleted modules
		self:Print("Too many instances ("..self.customModuleCount..") of custom buff module. "..
			"If you have deleted some during this session, relog and try again.")
		return
	end

	self.customModuleCount = self.customModuleCount + 1
	local name = "Custom_"..self.customModuleCount
	
	local module = self:NewModule(name)
	
	module.isCustom		= true
	module.version 		= CustomBuffRingTemplate.version
	module.unit 		= CustomBuffRingTemplate.unit
	module.noAutoAlpha 	= CustomBuffRingTemplate.noAutoAlpha
	module.options 		= CustomBuffRingTemplate.options
	module.localized 	= CustomBuffRingTemplate.localized
	
	module.Initialize 		= CustomBuffRingTemplate.Initialize
	module.OnModuleUpdate 	= CustomBuffRingTemplate.OnModuleUpdate
	module.OnModuleEnable 	= CustomBuffRingTemplate.OnModuleEnable
	module.OnModuleDisable 	= CustomBuffRingTemplate.OnModuleDisable
	module.UpdateBuff 		= CustomBuffRingTemplate.UpdateBuff
	module.EventHandler 	= CustomBuffRingTemplate.EventHandler
	module.AppendCustomModuleOptions = CustomBuffRingTemplate.AppendCustomModuleOptions
	
	module.db = { profile = {} }
	
	if (config == nil) then
		config = CustomBuffRingTemplate.defaults.profile
		for k,v in pairs(config) do
			module.db.profile[k] = v
		end
	else
		module.db.profile = config
	end
	
	table.insert(self.customModules, module)
	self:LevelDebug(1, "Created new custom buff module: "..module.db.profile.BuffName..", "..module.db.profile.Unit)
	
	module:OnInitialize()
	module:Enable()
	--self:SendMessage("ARCHUD_MODULE_ENABLE", name)
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
	for i,config in ipairs(self.db.profile.CustomModules) do
		self:CreateCustomBuffModule(config)
	end
	self:SendMessage("ARCHUD_MODULE_ENABLE")
end
