local module = ArcHUD:NewModule("ComboPoints")
local _, _, rev = string.find("$Rev: 106 $", "([0-9]+)")
module.version = "2.0." .. rev
module.unit = "player"
module.defaults = {
	Enabled = true,
	Outline = true,
	Flash = true,
	Side = 2,
	Level = 1,
}
module.options = {
	{name = "Flash", text = "FLASH", tooltip = "FLASH"},
	nocolor = true,
	attach = true,
}
module.localized = true

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)

	-- Override Update timer
	self:RegisterMetro(self.name .. "Update", self.UpdateAlpha, 0.05, self.f)
end

function module:Update()
	self.Flash = self.db.profile.Flash
end

function module:Enable()
	self.f.dirty = true
	self.f.fadeIn = 0.25

	self.f:UpdateColor({["r"] = 1, ["g"] = 0, ["b"] = 0})
	self.f:SetMax(5)
	self.f:SetValue(GetComboPoints(self.unit))

	-- Register the events we will use
	self:RegisterEvent("UNIT_COMBO_POINTS",	"UpdateComboPoints")
	self:RegisterEvent("PLAYER_TARGET_CHANGED",	"UpdateComboPoints")

	-- Activate the timers
	self:StartMetro(self.name .. "Alpha")
	self:StartMetro(self.name .. "Fade")
	self:StartMetro(self.name .. "Update")

	self.f:Show()
end

function module:UpdateAlpha()
	if(self.pulse) then
		self.alphaPulse = self.alphaPulse + arg1/2
		local amt = math.sin(self.alphaPulse * self.twoPi) * 0.5 + 0.5
		self:UpdateColor({["r"] = 1, ["g"] = amt, ["b"] = amt})
	end
end

function module:UpdateComboPoints()
	if (arg1 == self.unit) then
		self.f:SetValue(GetComboPoints(self.unit))
		if(GetComboPoints(self.unit) < 5 and GetComboPoints(self.unit) >= 0) then
			self.f.pulse = false
			self.f.alphaPulse = 0
			self.f:UpdateColor({["r"] = 1, ["g"] = 0, ["b"] = 0})
		else
			if(self.Flash) then
				self.f.pulse = true
			else
				self.f.pulse = false
			end
		end
		if(GetComboPoints(self.unit) > 0) then
			if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
			else
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
			end
		else
			self.f:SetRingAlpha(0)
		end
	end
end

