local module = ArcHUD:NewModule("ShadowOrbs")
local _, _, rev = string.find("$Rev: 109 $", "([0-9]+)")
module.version = "2.1 (r" .. rev .. ")"

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
		Color = {r = 0.5, g = 0, b = 0.5},
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
	
	self:CreateStandardModuleOptions(55)
end

function module:OnModuleUpdate()
	self:UpdateColor()
end

function module:OnModuleEnable()
	local _, class = UnitClass("player")
	if (class ~= "PRIEST") then return end
	
	self.f.dirty = true
	self.f.fadeIn = 0.25

	self:UpdateColor()

	-- Register the events we will use
	self:RegisterEvent("PLAYER_ENTERING_WORLD",	"UpdatePower")
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "UpdatePower")
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "UpdatePower")

	-- Activate ring timers
	self:StartRingTimers()
	
	self:UpdateOrbs()

	self.f:Show()
end

function module:UpdateOrbs()
	local max = UnitPowerMax(self.unit, SPELL_POWER_SHADOW_ORBS)
	local num = UnitPower(self.unit, SPELL_POWER_SHADOW_ORBS)
	self.f:SetMax(max)
	self.f:SetValue(num)
	
	if(num < max and num >= 0) then
		self.f:StopPulse()
	else
		if(self.db.profile.Flash) then
			self.f:StartPulse()
		else
			self.f:StopPulse()
		end
	end
end

function module:UpdatePower(event, arg1, arg2)
	if (event == "UNIT_POWER_FREQUENT") then
		if (arg1 == self.unit and arg2 == "SHADOW_ORBS") then
			self:UpdateOrbs()
		end
	else
		self:UpdateOrbs()
	end
end
