local moduleName = "TargetPower"
local module = ArcHUD:NewModule(moduleName)
module.version = "2.0 (@file-abbreviated-hash@)"

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
	
	-- Create StatusBar arc for 12.0.0+ (Midnight)
	if ArcHUD.isMidnight then
		-- Note: Mask texture path needs to be created - using placeholder for now
		-- TargetPower is left side (Side=1), pass module name to determine positioning
		self.statusBarArc = self.parent:CreateStatusBarArc(self.f, nil, self.name) -- TODO: Add mask texture path
		if self.statusBarArc then
			self.statusBarArc:Hide() -- Hide by default
		end
	end
	
	if not ArcHUD.isMidnight then
		self:RegisterTimer("UpdatePowerBar", self.UpdatePower, 0.1, self, true)
	end
	
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
	if ArcHUD.isMidnight then
		-- 12.0.0+ (Midnight): Use StatusBar approach
		if(not UnitExists(self.unit)) then
			self.MPPerc:SetText("")
			if self.statusBarArc then
				self.statusBarArc:Hide()
			end
		else
			local powerType = UnitPowerType(self.unit)
			local power, maxPower = UnitPower(self.unit), UnitPowerMax(self.unit)
			local maxPowerSecret = self.parent:IsSecretValue(maxPower)
			
			self.f.pulse = false
			self:UpdateColor(powerType)
			
			-- Update StatusBar arc
			if self.statusBarArc then
				self.parent:UpdateStatusBarArcPower(self.statusBarArc, self.unit, powerType)
				local info = self:GetPowerBarColorText(powerType)
				-- Use GetPowerBarColor (not GetPowerBarColorText) for StatusBar color
				local barColor = self:GetPowerBarColor(powerType)
				self.parent:SetStatusBarArcColor(self.statusBarArc, barColor.r, barColor.g, barColor.b, 1)
			end
			
			if(UnitIsDead(self.unit) or UnitIsGhost(self.unit) or (not maxPowerSecret and maxPower == 0)) then
				if self.statusBarArc then
					self.statusBarArc:Hide()
				end
				self.MPPerc:SetText("")
			else
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
end

function module:UpdateDisplayPower(event, arg1)
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
		local p = self.parent:GetPowerPercent(self.unit, powerType)
		local pctInt = math.floor(p * 100)
		if pctInt > 0 then
			self.MPPerc:SetText(pctInt.."%")
		else
			self.MPPerc:SetText("")
		end
	else
		-- Pre-12.0.0: Use original system
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
end

function module:UpdatePower(event, arg1)
	if (arg1 ~= self.unit) then return end
	
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
			if pctInt > 0 then
				self.MPPerc:SetText(pctInt.."%")
			else
				self.MPPerc:SetText("")
			end
			
			-- Timer management
			if power == maxPower or power == 0 then
				self:StopTimer("UpdatePowerBar")
			else
				self:StartTimer("UpdatePowerBar")
			end
		else
			if pctInt > 0 then
				self.MPPerc:SetText(pctInt.."%")
			else
				self.MPPerc:SetText("")
			end
		end
	else
		-- Pre-12.0.0: Use original system
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
end
