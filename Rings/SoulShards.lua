local module = ArcHUD:NewModule("SoulShards")
module.version = "3.0 (@file-abbreviated-hash@)"

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
	self:RegisterEvent("PLAYER_ENTERING_WORLD",	"UpdatePower")
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "UpdatePower", self.unit)
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "UpdatePower", self.unit)
	
	-- Activate ring timers
	self:StartRingTimers()
	
	self.f:Show()
	self.active = true
end


function module:UpdatePowerRing()
	local maxPower = UnitPowerMax(self.unit, SPELL_POWER_SOUL_SHARDS)
	local num = UnitPower(self.unit, SPELL_POWER_SOUL_SHARDS)
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
		if (arg1 == self.unit and (arg2 == "SOUL_SHARDS")) then
			self:UpdatePowerRing()
		end
	else
		self:UpdatePowerRing()
	end
end

