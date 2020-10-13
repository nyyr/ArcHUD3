local moduleName = "TargetPower"
local module = ArcHUD:NewModule(moduleName)
module.version = "2.0 (aadecab)"

module.unit = "target"
module.isPower = true

module.defaults = {
	profile = {
		Enabled = false,
		Outline = true,
		ShowPerc = true,
		ColorMana = PowerBarColor[0],
		ColorRage = PowerBarColor[1],
		ColorFocus = PowerBarColor[2],
		ColorEnergy = PowerBarColor[3],
		ColorRunic = PowerBarColor[6],
		Side = 1,
		Level = 2,
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

	self.MPPerc = self:CreateFontString(self.f, "BACKGROUND", {40, 12}, 10, "CENTER", {1.0, 1.0, 1.0}, {"TOP", self.f, "BOTTOMLEFT", 20, -130})
	--{"TOPLEFT", self.f, "BOTTOMLEFT", -100, -115})
	self:RegisterTimer("UpdatePowerBar", self.UpdatePower, 0.1, self, true)
	
	self:CreateStandardModuleOptions(25)
end

function module:OnModuleUpdate()
	if(self.db.profile.ShowPerc) then
		self.MPPerc:Show()
	else
		self.MPPerc:Hide()
	end

	-- Clear all points for the percentage display
	self.MPPerc:ClearAllPoints()
	if(self.db.profile.Side == 1) then
		-- Attach to left side
		self.MPPerc:SetPoint("TOP", self.f, "BOTTOMLEFT", -20, -130)
	else
		-- Attach to right side
		self.MPPerc:SetPoint("TOP", self.f, "BOTTOMLEFT", 20, -130)
	end
	if(UnitExists(self.unit)) then
		self.f:SetValue(UnitPower(self.unit))
		self:UpdateColor(UnitPowerType(self.unit))
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
	self:RegisterUnitEvent("UNIT_POWER_UPDATE", "UpdatePower")
	self:RegisterUnitEvent("UNIT_MAXPOWER", "UpdatePower")
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "UpdateDisplayPower")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")

	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
end

function module:PLAYER_TARGET_CHANGED()
	self.f.alphaState = -1
	if(not UnitExists(self.unit)) then
		self.f:SetMax(100)
		self.f:SetValue(0)
		self.MPPerc:SetText("")
	else
		local power = UnitPower(self.unit)
		local maxPower = UnitPowerMax(self.unit)
		
		self.f.pulse = false
		self.f:SetMax(maxPower)
		self:UpdateColor(UnitPowerType(self.unit))
		if(UnitIsDead(self.unit) or UnitIsGhost(self.unit) or maxPower == 0) then
			self.f:SetValue(0)
			self.MPPerc:SetText("")
		else
			self.f:SetValue(power)
			self.MPPerc:SetText(floor((power / maxPower) * 100).."%")
		end
	end
end

function module:UpdateDisplayPower(event, arg1)
	if(arg1 ~= self.unit) then return end
	
	local power = UnitPower(self.unit)
	local maxPower = UnitPowerMax(self.unit)

	self:UpdateColor(UnitPowerType(self.unit))
	self.f:SetValue(power)
	self.f:SetMax(maxPower)

	if(maxPower > 0) then
		self.MPPerc:SetText(floor((power / maxPower) * 100).."%")
	else
		self.MPPerc:SetText("")
	end
end

function module:UpdatePower(event, arg1)
	if (arg1 ~= self.unit) then return end
	
	local power = UnitPower(self.unit)
	local maxPower = UnitPowerMax(self.unit)
	
	if(event == "UNIT_MAXPOWER") then
		self.f:SetMax(maxPower)
		if(maxPower > 0) then
			self.MPPerc:SetText(floor((power / maxPower) * 100).."%")
		else
			self.MPPerc:SetText("")
		end
	else
		self.f:SetValue(power)
		if(maxPower > 0) then
			self.MPPerc:SetText(floor((power / maxPower) * 100).."%")
		else
			self.MPPerc:SetText("")
		end
	end
	if(power == maxPower or power == 0) then
		self:StopTimer("UpdatePowerBar")
	else
		self:StartTimer("UpdatePowerBar")
	end
end
