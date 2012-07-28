local module = ArcHUD:NewModule("Eclipse")
local _, _, rev = string.find("$Rev: 24 $", "([0-9]+)")
module.version = "2.0 (r" .. rev .. ")"

module.unit = "player"
module.noAutoAlpha = false

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		Flash = true,
		Side = 2,
		Level = 1,
		ColorLunar = {r = 0.5, g = 0.5, b = 1}, -- lunar
		ColorSolar = {r = 1, g = 0.5, b = 0.5}, -- solar
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
	
	self:CreateStandardModuleOptions(55)
end

function module:OnModuleUpdate()
	self.Flash = self.db.profile.Flash
	self:UpdatePowerRing()
end

function module:OnModuleEnable()
	local _, class = UnitClass("player")
	if (class ~= "DRUID") then return end
	
	self.f.dirty = true
	self.f.fadeIn = 0.25

	self.f:UpdateColor(self.db.profile.Color)

	-- check whether we are balanced spec'ed and in caster/moonkin form
	self:RegisterEvent("PLAYER_TALENT_UPDATE",		"CheckCurrentPower")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM",	"CheckCurrentPower")
	
	self:CheckCurrentPower()
end

function module:CheckCurrentPower()
	local spec = GetSpecialization()
	local form = GetShapeshiftFormID();
	if (spec == 1 and (form == MOONKIN_FORM or not form)) then
		if (not self.active) then
			self.active = true
		
			-- Register the events we will use
			self:RegisterEvent("UNIT_POWER_FREQUENT",	"UpdatePower")
			self:RegisterEvent("PLAYER_ENTERING_WORLD",	"UpdatePower")
			self:RegisterEvent("UNIT_DISPLAYPOWER", 	"UpdatePower")
			
			-- Activate ring timers
			self:StartRingTimers()
			
			self.f:Show()
		end
		
		self:UpdatePowerRing()
		
	else
		self.f:Hide()
		self.active = nil
		
		self:UnregisterEvent("UNIT_POWER_FREQUENT")
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:UnregisterEvent("UNIT_DISPLAYPOWER")
		
		self:StopRingTimers()
	end
end

function module:UpdatePowerRing()
	local maxPower = UnitPowerMax(self.unit, SPELL_POWER_ECLIPSE)
	local num = UnitPower(self.unit, SPELL_POWER_ECLIPSE)
	self.f:SetMax(maxPower)
	
	if (num < 0) then
		-- lunar power
		num = num * -1
		self.f:UpdateColor(self.db.profile.ColorLunar)
	else
		-- solar power
		self.f:UpdateColor(self.db.profile.ColorSolar)
	end
	
	self.f:SetValue(num)
	
	if (num < maxPower and num >= 0) then
		self.f:StopPulse()
	else
		if (self.Flash) then
			self.f:StartPulse()
		else
			self.f:StopPulse()
		end
	end
end

function module:UpdatePower(event, arg1, arg2)
	if (event == "UNIT_POWER_FREQUENT") then
		if (arg1 == self.unit and arg2 == "ECLIPSE") then
			self:UpdatePowerRing()
		end
	else
		self:UpdatePowerRing()
	end
end

