local module = ArcHUD:NewModule("SoulShards")
local _, _, rev = string.find("$Rev$", "([0-9]+)")
module.version = "2.0 (r" .. rev .. ")"

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
		Color = {r = 0.5, g = 0, b = 0.5},
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
	if (class ~= "WARLOCK") then return end
	
	self.f.dirty = true
	self.f.fadeIn = 0.25

	self:UpdateColor()

	-- check which spell power to use
	self:RegisterEvent("PLAYER_TALENT_UPDATE",	"CheckCurrentPower")
	self:RegisterEvent("SPELLS_CHANGED",		"CheckCurrentPower")
	
	self:CheckCurrentPower()
end

function module:CheckCurrentPower()
	local spec = GetSpecialization()
	if (spec == SPEC_WARLOCK_AFFLICTION and IsPlayerSpell(WARLOCK_SOULBURN)) then
		self.currentSpellPower = SPELL_POWER_SOUL_SHARDS
		
	elseif (spec == SPEC_WARLOCK_DESTRUCTION and IsPlayerSpell(WARLOCK_BURNING_EMBERS)) then
		self.currentSpellPower = SPELL_POWER_BURNING_EMBERS
		
	elseif (spec == SPEC_WARLOCK_DEMONOLOGY) then
		self.currentSpellPower = SPELL_POWER_DEMONIC_FURY
		
	else
		self.currentSpellPower = nil
	end
	
	--self:Debug(1, "CheckCurrentPower(): %s", tostring(self.currentSpellPower))
	
	if (self.currentSpellPower) then
		if (not self.active) then
			-- Register the events we will use
			self:RegisterEvent("PLAYER_ENTERING_WORLD",	"UpdatePower")
			self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "UpdatePower", self.unit)
			self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "UpdatePower", self.unit)
			
			-- we'll never need it again
			self:UnregisterEvent("SPELLS_CHANGED")
			
			-- Activate ring timers
			self:StartRingTimers()
			
			self.f:Show()
			self.active = true
		end
		
		self:UpdatePowerRing()
		
	else
		if (self.active) then
			self.f:Hide()
			self.active = nil
			
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
			self:UnregisterUnitEvent("UNIT_POWER_FREQUENT")
			self:UnregisterUnitEvent("UNIT_DISPLAYPOWER")
			
			self:StopRingTimers()
		end
	end
end

function module:UpdatePowerRing()
	local maxPower = UnitPowerMax(self.unit, self.currentSpellPower)
	local num = UnitPower(self.unit, self.currentSpellPower)
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
		if (arg1 == self.unit and (arg2 == "SOUL_SHARDS" or arg2 == "BURNING_EMBERS" or arg2 == "DEMONIC_FURY")) then
			self:UpdatePowerRing()
		end
	else
		self:UpdatePowerRing()
	end
end

