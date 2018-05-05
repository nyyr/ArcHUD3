local module = ArcHUD:NewModule("ShadowOrbs")
module.version = "2.1 (@file-abbreviated-hash@)"

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

local SHADOW_ORBS_SHOW_LEVEL = 10

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
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "CheckCurrentPower")
	self:RegisterEvent("PLAYER_LEVEL_UP", "CheckCurrentPower")
	
	-- Check whether we may actually show this ring
	self:CheckCurrentPower()
end

function module:CheckCurrentPower()
	local spec = GetSpecialization()
	if (spec == SPEC_PRIEST_SHADOW and (UnitLevel("player") >= SHADOW_ORBS_SHOW_LEVEL)) then
		self.currentSpellPower = SPELL_POWER_SHADOW_ORBS
	else
		self.currentSpellPower = nil
	end
	
	--self:Debug(1, "CheckCurrentPower(): %s", tostring(self.currentSpellPower))
	
	if (self.currentSpellPower) then
		if (not self.active) then
			-- Register the events we will use
			self:RegisterEvent("PLAYER_ENTERING_WORLD",	"UpdatePower")
			self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "UpdatePower")
			self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "UpdatePower")
			
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
		if (arg1 == self.unit and arg2 == "SHADOW_ORBS") then
			self:UpdatePowerRing()
		end
	else
		self:UpdatePowerRing()
	end
end
