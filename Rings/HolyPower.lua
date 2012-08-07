local module = ArcHUD:NewModule("HolyPower")
local _, _, rev = string.find("$Rev$", "([0-9]+)")
module.version = "2.0 (r" .. rev .. ")"

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
		Color = {r = 1, g = 1, b = 0.5},
		RingVisibility = 2, -- always fade out when out of combat, regardless of ring status
	}
}
module.options = {
	{name = "Flash", text = "FLASH_HP", tooltip = "FLASH_HP"},
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
	if (class ~= "PALADIN") then return end

	self.f.dirty = true
	self.f.fadeIn = 0.25

	-- Register the events we will use
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdatePower")
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "UpdatePower", self.unit)
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "UpdatePower", self.unit)
	
	-- Activate ring timers
	self:StartRingTimers()

	self:UpdateColor()
	self:UpdateHolyPower()
	
	self.f:Show()
end

function module:UpdateHolyPower()
	local maxHolyPower = UnitPowerMax(self.unit, SPELL_POWER_HOLY_POWER);
	local num = UnitPower(self.unit, SPELL_POWER_HOLY_POWER)
	self.f:SetMax(maxHolyPower)
	self.f:SetValue(num)
	
	if(num < HOLY_POWER_FULL and num >= 0) then
		self.f:StopPulse()
	else
		if(self.db.profile.Flash and num >= HOLY_POWER_FULL) then
			self.f:StartPulse()
		else
			self.f:StopPulse()
		end
	end
end

function module:UpdatePower(event, arg1, arg2)
	if (event == "UNIT_POWER_FREQUENT") then
		if (arg1 == self.unit and arg2 == "HOLY_POWER") then
			self:UpdateHolyPower()
		end
	else
		self:UpdateHolyPower()
	end
end
