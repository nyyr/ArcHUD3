local module = ArcHUD:NewModule("ComboPoints")
module.version = "5.0 (243459a)"

module.unit = "player"
module.noAutoAlpha = nil

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		Flash = true,
		Side = 2,
		Level = 1,
		ShowSeparators = true,
		Color = PowerBarColor["COMBO_POINTS"],
		RingVisibility = 2, -- always fade out when out of combat, regardless of ring status
		ShowTextHuge = true
	}
}
module.options = {
	{name = "Flash", text = "FLASH", tooltip = "FLASH"},
	{name = "ShowTextHuge", text = "SHOWTEXTHUGE", tooltip = "SHOWTEXTHUGE"}, -- fka "combo points"
	attach = true,
	hasseparators = true,
}
module.localized = true

module.class = "ROGUE"
module.specs = nil -- array of SPEC_... constants; nil if this ring is available for all specs
module.powerType = Enum.PowerType.ComboPoints
module.powerTypeString = "COMBO_POINTS"
module.flashAt = nil -- flash when full

function module:Initialize()
	self.InitializePowerRing = ArcHUD.templatePowerRing.InitializePowerRing
	self.OnModuleUpdate = ArcHUD.templatePowerRing.OnModuleUpdate
	self.OnModuleEnable = ArcHUD.templatePowerRing.OnModuleEnable
	self.UpdatePowerRing = ArcHUD.templatePowerRing.UpdatePowerRing
	self.UpdatePower = ArcHUD.templatePowerRing.UpdatePower
	self.UpdateActive = ArcHUD.templatePowerRing.UpdateActive

	self:InitializePowerRing()
end


--[[

module.unit = "player"
module.noAutoAlpha = nil
module.maxUsablePoints = 5

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		Flash = true,
		Side = 2,
		Level = 1,
		ShowSeparators = true,
		Color = {r = 1, g = 0, b = 0},
		RingVisibility = 2, -- always fade out when out of combat, regardless of ring status
	}
}
module.options = {
	{name = "Flash", text = "FLASH", tooltip = "FLASH"},
	attach = true,
	hasseparators = true,
}
module.localized = true

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)
	self:CreateStandardModuleOptions(50)
end

function module:OnModuleUpdate()
	self.Flash = self.db.profile.Flash
	self:UpdateColor()
end

function module:OnModuleEnable()
	local _, myclass = UnitClass("player");

	if ((myclass ~= "ROGUE") and (myclass ~= "DRUID")) then
		return
	end
		
	self.f.dirty = true
	self.f.fadeIn = 0.25

	self.f:UpdateColor(self.db.profile.Color)
	
	-- Register the events we will use
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent");
	self:RegisterEvent("PLAYER_TARGET_CHANGED",	"OnEvent")
	self:RegisterEvent("UNIT_DISPLAYPOWER", "OnEvent");
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "OnEvent", self.unit);	
	self:RegisterUnitEvent("UNIT_MAXPOWER", "OnEvent", self.unit);
	
	-- Activate ring timers
	self:StartRingTimers()
	
	self:UpdateComboPointsMax()
	self:UpdateComboPoints()
	
	self.f:Show()
end

function module:UpdateComboPointsMax()
	local maxComboPoints = UnitPowerMax(self.unit, SPELL_POWER_COMBO_POINTS)
	self.f:SetMax(maxComboPoints)
	
	if (maxComboPoints == 5 or maxComboPoints == 8) then
		self.maxUsablePoints = 5;
	elseif (maxComboPoints == 6) then
		self.maxUsablePoints = 6;
	end
end

function module:UpdateComboPoints()
	local powerType, powerToken = UnitPowerType(self.unit);
	if (powerType == SPELL_POWER_ENERGY) then
		self.f:Show()
		local comboPoints = UnitPower(self.unit, SPELL_POWER_COMBO_POINTS);
		self.f:SetValue(comboPoints)
		if(comboPoints < self.maxUsablePoints) then
			self.f:StopPulse()
		else
			if(self.Flash) then
				self.f:StartPulse()
			else
				self.f:StopPulse()
			end
		end
	else
		-- Druid not in feral form with leftover combo points
		self.f:Hide()
	end
end

function module:OnEvent(event, arg1, arg2)
	if (event == "UNIT_POWER_FREQUENT") then
		if (arg1 == self.unit and arg2 == "COMBO_POINTS") then
			self:UpdateComboPoints()
		end
	elseif (event == "UNIT_MAXPOWER") then
		self:UpdateComboPointsMax()
	else
		self:UpdateComboPoints()
	end
end

]]