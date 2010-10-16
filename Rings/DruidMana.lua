local module = ArcHUD:NewModule("DruidMana")
local _, _, rev = string.find("$Rev: 113 $", "([0-9]+)")
module.version = "2.0." .. rev
module.unit = "player"
module.defaults = {
	profile = {
		Enabled = false,
		Outline = true,
		ShowText = true,
		ShowPerc = true,
		ColorMode = "default",
		Color = {r = 0, g = 0, b = 1},
		Side = 2,
		Level = 1,
	}
}
module.options = {
	{name = "ShowText", text = "SHOWTEXT", tooltip = "SHOWTEXT"},
	{name = "ShowPerc", text = "SHOWPERC", tooltip = "SHOWPERC"},
	attach = true,
}
module.localized = true

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)

	self.MPText = self:CreateFontString(self.f, "BACKGROUND", {150, 13}, 12, "LEFT", {0.0, 1.0, 1.0}, {"TOPLEFT", ArcHUDFrameCombo, "TOPRIGHT", 0, 14})
	self.MPPerc = self:CreateFontString(self.f, "BACKGROUND", {70, 12}, 10, "LEFT", {1.0, 1.0, 1.0}, {"TOPLEFT", self.parent:GetModule("Power").MPPerc, "TOPRIGHT", 0, -1})

	-- Override Update timer
	self.parent:RegisterMetro(self.name .. "Update", self.UpdateRing, 0.1, self)
end

function module:Update()
	if(self.db.profile.ShowText) then
		self.MPText:Show()
	else
		self.MPText:Hide()
	end

	if(self.db.profile.ShowPerc) then
		self.MPPerc:Show()
	else
		self.MPPerc:Hide()
	end

	self:UpdateColor()
end

function module:Enable()
	-- Don't go further if player is not a druid
	local _, class = UnitClass(self.unit)
	if(class ~= "DRUID") then return end

	-- Register the events we will use
	self:RegisterEvent("UNIT_DISPLAYPOWER")
	

	-- Activate the timers
	self:StartMetro(self.name .. "Alpha")
	self:StartMetro(self.name .. "Fade")
	self:StartMetro(self.name .. "Update")
	
	self.f:Show()
end

function module:UpdateRing()
	if(self.doUpdates) then
		self:UpdateMana(UnitPower(self.unit, 0), UnitPowerMax(self.unit, 0))
		if(self.f.startValue < self.f.maxValue and ArcHUD.PlayerIsInCombat) then
			self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
		elseif(self.f.startValue < self.f.maxValue and not ArcHUD.PlayerIsInCombat) then
			self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
		else
			self.f:SetRingAlpha(0)
		end
	else
		self.f:SetRingAlpha(0)
	end
end

function module:UpdateMana(curMana, maxMana)
	if(self.doUpdates) then
		self.MPText:SetText(floor(curMana).."/"..floor(maxMana))
		self.MPPerc:SetText(floor((curMana/maxMana)*100).."%")
		self.f:SetMax(maxMana)
		self.f:SetValue(curMana)
	end
end

function module:UNIT_DISPLAYPOWER(arg1)
	if(arg1 ~= self.unit) then return end
	if(UnitPowerType(self.unit) == 1 or UnitPowerType(self.unit) == 3) then
		--Bear or Cat form
		--print("Starting DruidMana ring updates")
		self.doUpdates = 1
		self:UpdateMana(UnitPower(self.unit, 0), UnitPowerMax(self.unit, 0))
	elseif(UnitPowerType(self.unit) == 0 and self.doUpdates) then
		--player/aqua/travel
		--print("Stopping DruidMana ring updates")
		self.doUpdates = false
	end
end
