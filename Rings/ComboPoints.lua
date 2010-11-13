local module = ArcHUD:NewModule("ComboPoints")
local _, _, rev = string.find("$Rev$", "([0-9]+)")
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
		Color = {r = 1, g = 0, b = 0},
		ColorOldPoints = {r = 0.5, g = 0.5, b = 0.5},
	}
}
module.options = {
	{name = "Flash", text = "FLASH", tooltip = "FLASH"},
	hascolor = true,
	attach = true,
}
module.localized = true

module.oldPoints = 0
module.RemoveOldCP_started = false

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)

	-- Override Update timer
	self:RegisterTimer("RemoveOldCP", self.RemoveOldCP, self.parent.db.profile.OldComboPointsDecay, self)
	
	self:CreateStandardModuleOptions(45)
end

function module:OnModuleUpdate()
	self.Flash = self.db.profile.Flash
	--self.parent:UnregisterMetro(self.name .. "RemoveOldCP")
	self:RegisterTimer("RemoveOldCP", self.RemoveOldCP, self.parent.db.profile.OldComboPointsDecay, self)
end

function module:OnModuleEnable()
	self.f.dirty = true
	self.f.fadeIn = 0.25

	self.f:UpdateColor(self.db.profile.Color)
	self.f:SetMax(5)
	self.f:SetValue(GetComboPoints(self.unit))

	-- Register the events we will use
	self:RegisterEvent("UNIT_COMBO_POINTS",	"UpdateComboPoints")
	self:RegisterEvent("PLAYER_TARGET_CHANGED",	"UpdateComboPoints")

	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
end

function module:UpdateComboPoints(event, arg1)
	--self:Debug(3, "UpdateComboPoints("..tostring(event)..", "..tostring(arg1)..")")
	if ((event == "UNIT_COMBO_POINTS" and arg1 == self.unit) or
		(event == "PLAYER_TARGET_CHANGED" and GetComboPoints(self.unit) > 0 and
			UnitExists("target") and not UnitIsDead("target"))) then
		
		if (self.RemoveOldCP_started) then
			self:StopTimer("RemoveOldCP")
			self.RemoveOldCP_started = false
		end
		
		self.oldPoints = GetComboPoints(self.unit)
		self.f:SetValue(self.oldPoints)
		if(self.oldPoints < 5 and self.oldPoints >= 0) then
			self.f:StopPulse()
		else
			if(self.Flash) then
				self.f:StartPulse()
			else
				self.f:StopPulse()
			end
		end
		if(self.oldPoints > 0) then
			if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
			else
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
			end
		else
			self.f:SetRingAlpha(0)
		end
		
	elseif (event == "PLAYER_TARGET_CHANGED") then
		if (ArcHUD.db.profile.OldComboPointsDecay > 0.0) then
			if (not self.RemoveOldCP_started and self.oldPoints > 0) then
				-- we have still some points on previous target
				self.f:UpdateColor(self.db.profile.ColorOldPoints)
				self:StartTimer("RemoveOldCP")
				self.RemoveOldCP_started = true
			end
		else
			self.oldPoints = 0
			self.f:SetRingAlpha(0)
		end
	end
end

function module:RemoveOldCP()
	self.RemoveOldCP_started = false
	self.oldPoints = 0
	self.f:StopPulse()
	self.f:SetRingAlpha(0)
end
