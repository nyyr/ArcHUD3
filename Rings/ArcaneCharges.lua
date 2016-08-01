local module = ArcHUD:NewModule("ArcaneCharges")
local _, _, rev = string.find("$Rev: 109 $", "([0-9]+)")
module.version = "1.0 (r" .. rev .. ")"

module.unit = "player"
module.noAutoAlpha = nil

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		Flash = false,
		Side = 2,
		Level = 1,
		ShowSeparators = true,
		Color = {r = 0.3, g = 0.3, b = 1},
		RingVisibility = 2, -- always fade out when out of combat, regardless of ring status
	}
}
module.options = {
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
	if (class ~= "MAGE") then return end
	
	self.f.dirty = true
	self.f.fadeIn = 0.25

	self:UpdateColor()

	-- Check to see if we are an Arcane Mage
	self:CheckSpecialization()
	
	-- Activate ring timers
	self:StartRingTimers()
end

function module:CheckSpecialization()
	local spec = GetSpecialization();
	local showBar = false;

	if ( spec == SPEC_MAGE_ARCANE ) then
		self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "UpdatePower", self.unit);	
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdatePower");
		self:RegisterEvent("UNIT_DISPLAYPOWER", "UpdatePower");
		showBar = true;
	else
		self:UnregisterEvent("UNIT_POWER_FREQUENT");
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		self:UnregisterEvent("UNIT_DISPLAYPOWER");
	end
	
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "UpdatePower");
	
	self.f:SetShown(showBar);
end

function module:UpdatePowerRing()
	local maxPower = UnitPowerMax(self.unit, SPELL_POWER_ARCANE_CHARGES)
	local num = UnitPower(self.unit, SPELL_POWER_ARCANE_CHARGES)
	self.f:SetMax(maxPower)
	self.f:SetValue(num)
	
	--self:Debug(1, "UpdatePowerRing(): %d/%d", num, maxPower)
	
	if (num < maxPower and num >= 0) then
		self.f:StopPulse()
		self.f:UpdateColor(self.db.profile.Color)
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
		if (arg1 == self.unit and (arg2 == "ARCANE_CHARGES")) then
			self:UpdatePowerRing()
		end
	elseif (event == "PLAYER_TALENT_UPDATE") then
		self:CheckSpecialization()
		self:UpdatePowerRing()
	else
		self:UpdatePowerRing()
	end
end

