local moduleName = "PetPower"
local module = ArcHUD:NewModule(moduleName)
module.version = "2.0 (aadecab)"

module.unit = "pet"
module.isPower = true

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		ShowPerc = true,
		ColorMana = PowerBarColor[0],
		ColorRage = PowerBarColor[1],
		ColorFocus = PowerBarColor[2],
		ColorEnergy = PowerBarColor[3],
		ColorRunic = PowerBarColor[6],
		InnerAnchor = true,
		Side = 2,
		Level = 0,
	}
}
module.options = {
	{name = "ShowPerc", text = "SHOWPERC", tooltip = "SHOWPERC"},
	hasmanabar = true,
}
module.localized = true

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)

	self.f.BG:SetReversed(true)
	self.f.BG:SetAngle(180)

	self.f:SetReversed(true)
	self.f:SetAlpha(0)

	self.MPPerc = self:CreateFontString(self.f, "BACKGROUND", {100, 17}, 16, "LEFT", {1.0, 1.0, 1.0}, {"BOTTOMLEFT", self.f, "BOTTOMLEFT", 65, -125})
	
	self:CreateStandardModuleOptions(36)
end

function module:OnModuleUpdate()
	if(self.db.profile.ShowPerc) then
		self.MPPerc:Show()
	else
		self.MPPerc:Hide()
	end

	if not self.db.profile.InnerAnchor then
		fontName, _, fontFlags = self.MPPerc:GetFont()
		self.MPPerc:SetFont(fontName, 11, fontFlags)

		self.MPPerc:SetWidth(40)
		self.MPPerc:SetHeight(12)

		self.MPPerc:ClearAllPoints()
		if(self.db.profile.Side == 1) then
			-- Attach to left side
			self.MPPerc:SetPoint("TOPLEFT", self.f, "BOTTOMLEFT", -100, -115)
		else
			-- Attach to right side
			self.MPPerc:SetPoint("TOPLEFT", self.f, "BOTTOMLEFT", 50, -115)
		end
	else
		fontName, _, fontFlags = self.MPPerc:GetFont()
		self.MPPerc:SetFont(fontName, 16, fontFlags)
		
		self.MPPerc:SetWidth(100)
		self.MPPerc:SetHeight(17)

		-- TODO side
		self.MPPerc:ClearAllPoints()
		self.MPPerc:SetPoint("BOTTOMLEFT", self.f, "BOTTOMLEFT", 65, -125)
	end

	self.f:SetValue(UnitPower(self.unit))
	self:UpdateColor(UnitPowerType(self.unit))
end

function module:OnModuleEnable()
	self.f:SetMax(10)
	self.f:SetValue(10)

	if(UnitExists(self.unit) and UnitPowerMax(self.unit) > 0) then
		self.MPPerc:SetText(floor((UnitPower(self.unit) / UnitPowerMax(self.unit)) * 100).."%")
		self.f:SetMax(UnitPowerMax(self.unit))
		self.f:SetValue(UnitPower(self.unit))
	else
		self.MPPerc:SetText("")
		self.f:SetValue(0)
	end

	-- Register the events we will use
	self:RegisterEvent("PET_UI_UPDATE",		"UpdatePet")
	self:RegisterEvent("PET_BAR_UPDATE",	"UpdatePet")
	self:RegisterUnitEvent("UNIT_PET",		"UpdatePet", "player")
	self:RegisterUnitEvent("UNIT_POWER_UPDATE",	"UpdatePower")
	self:RegisterUnitEvent("UNIT_MAXPOWER",	"UpdatePower")
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER")

	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
end

function module:UNIT_DISPLAYPOWER()
	self:UpdateColor(UnitPowerType(self.unit))
	self.f:SetMax(UnitPowerMax(self.unit))
end

function module:UpdatePet(event, arg1)
	if(event == "UNIT_PET" and arg1 ~= "player") then return end
	if(UnitExists(self.unit)) then
		self:UpdateColor(UnitPowerType(self.unit))
		self.f:SetMax(UnitPowerMax(self.unit))
		self.f:SetValue(UnitPower(self.unit))
		if (UnitPowerMax(self.unit) > 0) then
			self.MPPerc:SetText(floor((UnitPower(self.unit) / UnitPowerMax(self.unit)) * 100).."%")
			self.f:Show()
		else
			self.MPPerc:SetText("")
			self.f:Hide()
		end
	else
		self.parent.PetIsInCombat = false
		self.f:Hide()
	end
end

function module:UpdatePower(event, arg1)
	if(arg1 == self.unit) then
		if (event == "UNIT_MAXPOWER") then
			self:UpdateColor(UnitPowerType(self.unit))
			self.f:SetMax(UnitPowerMax(self.unit))
		else
			self.f:SetValue(UnitPower(self.unit))
			if (UnitPowerMax(self.unit) > 0) then
				self.MPPerc:SetText(floor((UnitPower(self.unit) / UnitPowerMax(self.unit)) * 100).."%")
			else
				self.MPPerc:SetText("")
			end
		end
	end
end

