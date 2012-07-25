local module = ArcHUD:NewModule("SoulShards")
local _, _, rev = string.find("$Rev: 24 $", "([0-9]+)")
module.version = "1.2 (r" .. rev .. ")"

module.unit = "player"
module.noAutoAlpha = false

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		Flash = false,
		Side = 2,
		Level = 2,
		Color = {r = 0.5, g = 0, b = 0.5},
		RingVisibility = 2, -- always fade out when out of combat, regardless of ring status
	}
}
module.options = {
	attach = true,
}
module.localized = true

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)
	
	local maxShards = UnitPowerMax(self.unit, SPELL_POWER_SOUL_SHARDS);
	self.f:SetMax(maxShards)
	self.f:SetValue(0)
	
	self:CreateStandardModuleOptions(45)
end

function module:OnModuleUpdate()
	self.Flash = self.db.profile.Flash
	self:UpdateShards()
end

function module:OnModuleEnable()
	local _, class = UnitClass("player")
	if (class ~= "WARLOCK") then return end

	self.f.dirty = true
	self.f.fadeIn = 0.25

	self.f:UpdateColor(self.db.profile.Color)
	self.f:SetValue(UnitPower(self.unit, SPELL_POWER_SOUL_SHARDS))

	-- Register the events we will use
	self:RegisterEvent("UNIT_POWER",			"UpdatePower")
	self:RegisterEvent("PLAYER_ENTERING_WORLD",	"UpdatePower");
	self:RegisterEvent("UNIT_DISPLAYPOWER", 	"UpdatePower");

	-- Activate ring timers
	self:StartRingTimers()

	if UnitLevel("player") < SHARDBAR_SHOW_LEVEL then
		self:RegisterEvent("PLAYER_LEVEL_UP");
		self.f:Hide()
	else
		self.f:Show()
	end
end

function module:UpdateShards()
	local num = UnitPower(self.unit, SPELL_POWER_SOUL_SHARDS)
	self.f:SetValue(num)

	local maxShards = UnitPowerMax(self.unit, SPELL_POWER_SOUL_SHARDS);	
	self.f:SetMax(maxShards)
	
	if (num < maxShards and num >= 0) then
		self.f:StopPulse()
		self.f:UpdateColor(self.db.profile.Color)
	else
		if(self.Flash) then
			self.f:StartPulse()
		else
			self.f:StopPulse()
		end
	end
	
	if (num > 0) then
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
		if (arg1 == self.unit and arg2 == "SOUL_SHARDS") then
			self:UpdateShards()
		end
	else
		self:UpdateShards()
	end
end

function module:PLAYER_LEVEL_UP()
	if UnitLevel("player") >= SHARDBAR_SHOW_LEVEL then
		self:UnregisterEvent("PLAYER_LEVEL_UP");
		self.f:Show()
	end
end
