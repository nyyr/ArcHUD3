local module = ArcHUD:NewModule("Chi")
local _, _, rev = string.find("$Rev: 24 $", "([0-9]+)")
module.version = "2.0 (r" .. rev .. ")"

module.unit = "player"
module.noAutoAlpha = true

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		Flash = true,
		Side = 2,
		Level = 1,
		Color = {r = 0.7, g = 1, b = 0.9},
		RingVisibility = 2, -- always fade out when out of combat, regardless of ring status
	}
}
module.options = {
	{name = "Flash", text = "FLASH", tooltip = "FLASH"},
	attach = true,
}
module.localized = true

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)
	
	local maxChi = UnitPowerMax(self.unit, SPELL_POWER_LIGHT_FORCE);
	self.f:SetMax(maxChi)
	self.f:SetValue(0)
	
	self:CreateStandardModuleOptions(55)
end

function module:OnModuleUpdate()
	self.Flash = self.db.profile.Flash
	self:UpdateColor()
end

function module:OnModuleEnable()
	local _, class = UnitClass("player")
	if (class ~= "MONK") then return end

	self.f.dirty = true
	self.f.fadeIn = 0.25

	self.f:UpdateColor(self.db.profile.Color)
	self.f:SetValue(UnitPower(self.unit, SPELL_POWER_LIGHT_FORCE))

	-- Register the events we will use
	self:RegisterEvent("UNIT_POWER_FREQUENT",	"UpdatePower")
	self:RegisterEvent("PLAYER_ENTERING_WORLD",	"UpdatePower");
	self:RegisterEvent("UNIT_DISPLAYPOWER", 	"UpdatePower");

	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
end

function module:UpdateChi()
	local maxChi = UnitPowerMax(self.unit, SPELL_POWER_LIGHT_FORCE)
	local num = UnitPower(self.unit, SPELL_POWER_LIGHT_FORCE)
	self.f:SetMax(maxChi)
	self.f:SetValue(num)
	
	if(num < maxChi and num >= 0) then
		self.f:StopPulse()
		self.f:UpdateColor(self.db.profile.Color)
	else
		if(self.Flash) then
			self.f:StartPulse()
		else
			self.f:StopPulse()
		end
	end
	
--[[
	if(num > 0) then
		if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
			self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
		else
			self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
		end
	else
		self.f:SetRingAlpha(0)
	end
]]
end

function module:UpdatePower(event, arg1, arg2)
	if (event == "UNIT_POWER_FREQUENT") then
		if (arg1 == self.unit and (arg2 == "LIGHT_FORCE" or arg2 == "DARK_FORCE")) then
			self:UpdateChi()
		end
	else
		self:UpdateChi()
	end
end
