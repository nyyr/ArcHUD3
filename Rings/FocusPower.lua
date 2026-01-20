local moduleName = "FocusPower"
local module = ArcHUD:NewModule(moduleName)
module.version = "2.0 (@file-abbreviated-hash@)"

module.unit = "focus"
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
		Side = 2,
		Level = 3,
	},
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
	
	-- Create StatusBar arc for 12.0.0+ (Midnight)
	if ArcHUD.isMidnight then
		self.statusBarArc = self.parent:CreateStatusBarArc(self.f, self.name)
		self.zeroAlphaCurve = self.parent:CreateZeroAlphaCurve()
		if self.statusBarArc then
			self.statusBarArc:Hide() -- Hide by default
			self.f:HideAllButOutline()
		end
	end
	
	self:CreateStandardModuleOptions(41)
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
	if self.db.profile.Side and self.statusBarArc then
		self.parent:UpdateStatusBarSide(self.statusBarArc, self.db.profile.Side)
	end
	if(UnitExists(self.unit)) then
		self.f:SetValue(UnitPower(self.unit))
		self:UpdateColor(UnitPowerType(self.unit))
	end
end

function module:OnModuleEnable()
	if ArcHUD.isMidnight then
		-- 12.0.0+ (Midnight): Initialize StatusBar arc
		if not UnitExists(self.unit) then
			self.MPPerc:SetText("")
			if self.statusBarArc then
				self.statusBarArc:Hide()
			end
		else
			local powerType = UnitPowerType(self.unit)
			-- Update StatusBar arc
			if self.statusBarArc then
				self.parent:UpdateStatusBarArcPower(self.statusBarArc, self.unit, powerType)
				local info = self:GetPowerBarColorText(powerType)
				-- Use GetPowerBarColor (not GetPowerBarColorText) for StatusBar color
				local barColor = self:GetPowerBarColor(powerType)
				self.parent:SetStatusBarArcColor(self.statusBarArc, barColor.r, barColor.g, barColor.b, 1)
			end
			
			-- Update text - display actual values, including secret values
			self.MPPerc:SetText(self.parent:FormatPowerPercent(self.unit, powerType))
		end
	else
		-- Pre-12.0.0: Use original system
		if not UnitExists(self.unit) then
			self.f:SetMax(100)
			self.f:SetValue(0)
			self.MPPerc:SetText("")
		else
			self.f:SetMax(UnitPowerMax(self.unit))
			self.f:SetValue(UnitPower(self.unit))
			self.MPPerc:SetText(floor((UnitPower(self.unit) / UnitPowerMax(self.unit)) * 100).."%")
		end
	end

	-- Register the events we will use
	self:RegisterUnitEvent("UNIT_POWER_UPDATE",	"UpdatePower")
	self:RegisterUnitEvent("UNIT_MAXPOWER",	"UpdatePower")
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")

	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
end

function module:PLAYER_FOCUS_CHANGED()
	self.f.alphaState = -1
	if ArcHUD.isMidnight then
		-- 12.0.0+ (Midnight): Use StatusBar approach
		if(not UnitExists(self.unit)) then
			self.MPPerc:SetText("")
			if self.statusBarArc then
				self.statusBarArc:Hide()
			end
		else
			self.f.pulse = false
			local powerType = UnitPowerType(self.unit)
			local maxPower = UnitPowerMax(self.unit)
			local maxPowerSecret = self.parent:IsSecretValue(maxPower)
			
			self:UpdateColor(powerType)
			
			-- Update StatusBar arc
			if self.statusBarArc then
				self.parent:UpdateStatusBarArcPower(self.statusBarArc, self.unit, powerType)
				local info = self:GetPowerBarColorText(powerType)
				-- Use GetPowerBarColor (not GetPowerBarColorText) for StatusBar color
				local barColor = self:GetPowerBarColor(powerType)
				self.parent:SetStatusBarArcColor(self.statusBarArc, barColor.r, barColor.g, barColor.b, 1)
			end
			
			local power = UnitPower(self.unit)
			if(UnitIsDead(self.unit) or UnitIsGhost(self.unit) or (not maxPowerSecret and maxPower == 0)) then
				-- Use zero alpha curve to hide text when power is 0
				local alpha = UnitPowerPercent(self.unit, powerType, false, self.zeroAlphaCurve)
				self.MPPerc:SetAlpha(alpha)
				self.MPPerc:SetText("")
			else
				-- Use zero alpha curve to show/hide text based on power
				local alpha = UnitPowerPercent(self.unit, powerType, false, self.zeroAlphaCurve)
				self.MPPerc:SetAlpha(alpha)
				local p = self.parent:GetPowerPercent(self.unit, powerType)
				local pctInt = math.floor(p * 100)
				self.MPPerc:SetText(pctInt.."%")
			end
		end
	else
		-- Pre-12.0.0: Use original system
		if(not UnitExists(self.unit)) then
			self.f:SetMax(100)
			self.f:SetValue(0)
			self.MPPerc:SetText("")
		else
			self.f.pulse = false
			self.f:SetMax(UnitPowerMax(self.unit))
			self:UpdateColor(UnitPowerType(self.unit))
			if(UnitIsDead(self.unit) or UnitIsGhost(self.unit) or UnitPowerMax(self.unit) == 0) then
				self.f:SetValue(0)
				self.MPPerc:SetText("")
			else
				self.f:SetValue(UnitPower(self.unit))
				self.MPPerc:SetText(floor((UnitPower(self.unit) / UnitPowerMax(self.unit)) * 100).."%")
			end
		end
	end
end

function module:UNIT_DISPLAYPOWER()
	if(arg1 ~= self.unit) then return end

	if ArcHUD.isMidnight then
		-- 12.0.0+ (Midnight): Use StatusBar approach
		local powerType = UnitPowerType(self.unit)
		self:UpdateColor(powerType)
		
		-- Update StatusBar arc
		if self.statusBarArc then
			self.parent:UpdateStatusBarArcPower(self.statusBarArc, self.unit, powerType)
			local info = self:GetPowerBarColorText(powerType)
			self.parent:SetStatusBarArcColor(self.statusBarArc, info.r, info.g, info.b, 1)
		end
		
		-- Update text
		local maxPower = UnitPowerMax(self.unit)
		local maxPowerSecret = self.parent:IsSecretValue(maxPower)
		if not maxPowerSecret and maxPower > 0 then
			local p = self.parent:GetPowerPercent(self.unit, powerType)
			local pctInt = math.floor(p * 100)
			self.MPPerc:SetText(pctInt.."%")
		else
			local p = self.parent:GetPowerPercent(self.unit, powerType)
			if p and not self.parent:IsSecretValue(p) then
				local pctInt = math.floor(p * 100)
				if pctInt > 0 then
					self.MPPerc:SetText(pctInt.."%")
				else
					self.MPPerc:SetText("")
				end
			else
				self.MPPerc:SetText("")
			end
		end
	else
		-- Pre-12.0.0: Use original system
		self:UpdateColor(UnitPowerType(self.unit))
		self.f:SetValue(UnitPower(self.unit))
		self.f:SetMax(UnitPowerMax(self.unit))

		if(UnitPowerMax(self.unit) > 0) then
			self.MPPerc:SetText(floor((UnitPower(self.unit) / UnitPowerMax(self.unit)) * 100).."%")
		else
			self.MPPerc:SetText("")
		end
	end
end

function module:UpdatePower(event, arg1)
	if ArcHUD.isMidnight then
		-- 12.0.0+ (Midnight): Use StatusBar approach
		local powerType = UnitPowerType(self.unit)
		local power, maxPower = UnitPower(self.unit), UnitPowerMax(self.unit)
		local powerSecret = self.parent:IsSecretValue(power)
		local maxPowerSecret = self.parent:IsSecretValue(maxPower)
		local canCalculate = not powerSecret and not maxPowerSecret
		
		-- Update StatusBar arc
		if self.statusBarArc then
			self.parent:UpdateStatusBarArcPower(self.statusBarArc, self.unit, powerType)
			local info = self:GetPowerBarColorText(powerType)
			self.parent:SetStatusBarArcColor(self.statusBarArc, info.r, info.g, info.b, 1)
		end
		
		-- Update text
		local p = self.parent:GetPowerPercent(self.unit, powerType)
		local pctInt = math.floor(p * 100)

		if canCalculate and maxPower > 0 then
			self.MPPerc:SetText(pctInt.."%")
		else
			if pctInt > 0 then
				self.MPPerc:SetText(pctInt.."%")
			else
				self.MPPerc:SetText("")
			end
		end

		-- Use zero alpha curve to show/hide text based on power
		local alpha = UnitPowerPercent(self.unit, powerType, false, self.zeroAlphaCurve)
		self.MPPerc:SetAlpha(alpha)
	else
		-- Pre-12.0.0: Use original system
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
	end
end
