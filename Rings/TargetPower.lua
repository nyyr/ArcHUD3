local moduleName = "TargetPower"
local module = ArcHUD:NewModule(moduleName)
local _, _, rev = string.find("$Rev$", "([0-9]+)")
module.version = "0.9 (r"..rev..")"
module.unit = "target"
module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		ShowPerc = true,
		ColorMode = "default",
		ColorMana = PowerBarColor[0],
		ColorRage = PowerBarColor[1],
		ColorFocus = PowerBarColor[2],
		ColorEnergy = PowerBarColor[3],
		Side = 2,
		Level = 1,
	}
}
module.options = {
	{name = "ShowPerc", text = "SHOWPERC", tooltip = "SHOWPERC"},
	hasmanabar = true,
	attach = true,
}
module.localized = true

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)

	self.MPPerc = self:CreateFontString(self.f, "BACKGROUND", {40, 12}, 11, "RIGHT", {1.0, 1.0, 1.0}, {"TOPLEFT", self.f, "BOTTOMLEFT", -100, -115})
	self.parent:RegisterMetro(self.name .. "UpdatePowerBar", self.UpdatePower, 0.1, self)
	
	self:CreateStandardModuleOptions(25)
end

function module:Update()
	if(self.db.profile.ShowPerc) then
		self.MPPerc:Show()
	else
		self.MPPerc:Hide()
	end

	-- Clear all points for the percentage display
	self.MPPerc:ClearAllPoints()
	if(self.db.profile.Side == 1) then
		-- Attach to left side
		self.MPPerc:SetPoint("TOPLEFT", self.f, "BOTTOMLEFT", -100, -115)
	else
		-- Attach to right side
		self.MPPerc:SetPoint("TOPLEFT", self.f, "BOTTOMLEFT", 50, -115)
	end
	if(UnitExists(self.unit)) then
		self.f:SetValue(UnitPower(self.unit))
		self:UpdateColor(PowerBarColor[UnitPowerType(self.unit)])
	end
end

function module:OnModuleEnable()
	if not UnitExists(self.unit) then
		self.f:SetMax(100)
		self.f:SetValue(0)
		self.MPPerc:SetText("")
	else
		self.f:SetMax(UnitPowerMax(self.unit))
		self.f:SetValue(UnitPower(self.unit))
		self.MPPerc:SetText(floor((UnitPower(self.unit) / UnitPowerMax(self.unit)) * 100).."%")
	end

	-- Register the events we will use
	self:RegisterEvent("UNIT_POWER",		"UpdatePower")
	self:RegisterEvent("UNIT_MAXPOWER",		"UpdatePower")
	self:RegisterEvent("UNIT_DISPLAYPOWER")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")

	-- Activate the timers
	self.parent:StartMetro(self.name .. "Alpha")
	self.parent:StartMetro(self.name .. "Fade")
	self.parent:StartMetro(self.name .. "Update")

	self.f:Show()
end

function module:PLAYER_TARGET_CHANGED()
	self.f.alphaState = -1
	if(not UnitExists(self.unit)) then
		self.f:SetMax(100)
		self.f:SetValue(0)
		self.MPPerc:SetText("")
	else
		self.f.pulse = false
		self.f:SetMax(UnitPowerMax(self.unit))
		self:UpdateColor(PowerBarColor[UnitPowerType(self.unit)])
		if(UnitIsDead(self.unit) or UnitIsGhost(self.unit) or UnitPowerMax(self.unit) == 0) then
			self.f:SetValue(0)
			self.MPPerc:SetText("")
		else
			self.f:SetValue(UnitPower(self.unit))
			self.MPPerc:SetText(floor((UnitPower(self.unit) / UnitPowerMax(self.unit)) * 100).."%")
		end
	end
end

function module:UNIT_DISPLAYPOWER(arg1)
	if(arg1 ~= self.unit) then return end

	self:UpdateColor(PowerBarColor[UnitPowerType(self.unit)])
	self.f:SetValue(UnitPower(self.unit))
	self.f:SetMax(UnitPowerMax(self.unit))

	if(UnitPowerMax(self.unit) > 0) then
		self.MPPerc:SetText(floor((UnitPower(self.unit) / UnitPowerMax(self.unit)) * 100).."%")
	else
		self.MPPerc:SetText("")
	end
end

function module:UpdatePower(event)
	if(event == "UNIT_MAXPOWER") then
		self.f:SetMax(UnitPowerMax(self.unit))
		if(UnitPowerMax(self.unit) > 0) then
			self.MPPerc:SetText(floor((UnitPower(self.unit) / UnitPowerMax(self.unit)) * 100).."%")
		else
			self.MPPerc:SetText("")
		end
	else
		self.f:SetValue(UnitPower(self.unit))
		if(UnitPowerMax(self.unit) > 0) then
			self.MPPerc:SetText(floor((UnitPower(self.unit) / UnitPowerMax(self.unit)) * 100).."%")
		else
			self.MPPerc:SetText("")
		end
	end
	if(UnitPower(self.unit) == UnitPowerMax(self.unit) or UnitPower(self.unit) == 0) then
		self.parent:StopMetro(self.name .. "UpdatePowerBar")
	else
		self.parent:StartMetro(self.name .. "UpdatePowerBar")
	end
end
