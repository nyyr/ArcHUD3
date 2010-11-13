local module = ArcHUD:NewModule("HolyPower")
local _, _, rev = string.find("$Rev: 24 $", "([0-9]+)")
module.version = "1.0 (r" .. rev .. ")"

module.unit = "player"
module.noAutoAlpha = true

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		Flash = true,
		Side = 2,
		Level = 2,
		Color = {r = 1, g = 1, b = 0.5},
	}
}
module.options = {
	{name = "Flash", text = "FLASH", tooltip = "FLASH"},
	hascolor = true,
	attach = true,
}
module.localized = true

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)
	
	self.f:SetMax(MAX_HOLY_POWER)
	self.f:SetValue(0)
	
	self:CreateStandardModuleOptions(45)
end

function module:OnModuleUpdate()
	self.Flash = self.db.profile.Flash
end

function module:OnModuleEnable()
	local _, class = UnitClass("player")
	if (class ~= "PALADIN") then return end

	self.f.dirty = true
	self.f.fadeIn = 0.25

	self.f:UpdateColor(self.db.profile.Color)
	self.f:SetValue(UnitPower(self.unit, SPELL_POWER_HOLY_POWER))

	-- Register the events we will use
	self:RegisterEvent("UNIT_POWER",			"UpdatePower")
	self:RegisterEvent("PLAYER_ENTERING_WORLD",	"UpdatePower");
	self:RegisterEvent("UNIT_DISPLAYPOWER", 	"UpdatePower");

	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
end

function module:UpdateHolyPower()
	local num = UnitPower(self.unit, SPELL_POWER_HOLY_POWER)
	self.f:SetValue(num)
	
	if(num < MAX_HOLY_POWER and num >= 0) then
		self.f:StopPulse()
		self.f:UpdateColor(self.db.profile.Color)
	else
		if(self.Flash) then
			self.f:StartPulse()
		else
			self.f:StopPulse()
		end
	end
	
	if(num > 0) then
		if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
			self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
		else
			self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
		end
	else
		self.f:SetRingAlpha(0)
	end
end

function module:UpdatePower(event, arg1, arg2)
	if (event == "UNIT_POWER") then
		if (arg1 == self.unit and arg2 == "HOLY_POWER") then
			self:UpdateHolyPower()
		end
	else
		self:UpdateHolyPower()
	end
end
