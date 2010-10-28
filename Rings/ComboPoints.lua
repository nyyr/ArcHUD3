local module = ArcHUD:NewModule("ComboPoints")
local _, _, rev = string.find("$Rev$", "([0-9]+)")
module.version = "0.9 (r" .. rev .. ")"
module.unit = "player"
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
	nocolor = true,
	attach = true,
}
module.localized = true

module.oldPoints = 0

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)

	-- Override Update timer
	self.parent:RegisterMetro(self.name .. "Update", self.UpdateAlpha, 0.05, self.f)
	
	self:CreateStandardModuleOptions(45)
end

function module:Update()
	self.Flash = self.db.profile.Flash
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

	-- Activate the timers
	self.parent:StartMetro(self.name .. "Alpha")
	self.parent:StartMetro(self.name .. "Fade")
	self.parent:StartMetro(self.name .. "Update")

	self.f:Show()
end

function module:UpdateAlpha(arg1)
	if(self.pulse) then
		self.alphaPulse = self.alphaPulse + arg1/2
		local amt = math.sin(self.alphaPulse * self.twoPi) * 0.5 + 0.5
		self:UpdateColor({self.db.profile.Color.r, ["g"] = amt, ["b"] = amt})
	end
end

function module:UpdateComboPoints(event, arg1)
	self:Debug(3, "UpdateComboPoints("..tostring(event)..", "..tostring(arg1)..")")
	if ((arg1 == self.unit) or
		(event == "PLAYER_TARGET_CHANGED" and GetComboPoints(self.unit) > 0)) then
		
		self.oldPoints = GetComboPoints(self.unit)
		self.f:SetValue(self.oldPoints)
		if(self.oldPoints < 5 and self.oldPoints >= 0) then
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
		if(self.oldPoints > 0) then
			if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
			else
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
			end
		else
			self.f:SetRingAlpha(0)
		end
		
	elseif (self.oldPoints > 0) then
		-- we have still some points on previous target
		self.f:UpdateColor(self.db.profile.ColorOldPoints)
	end
end

