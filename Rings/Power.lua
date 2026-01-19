-- localization
local LM = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Module")

local moduleName = "Power"
local module = ArcHUD:NewModule(moduleName)
module.version = "2.0 (@file-abbreviated-hash@)"
module.unit = "player"
module.isPower = true
module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		ShowText = true,
		ShowTextMax = true,
		ShowPerc = true,
		SwapHealthPowerText = false,
		ColorMana = PowerBarColor[0],
		ColorRage = PowerBarColor[1],
		ColorFocus = PowerBarColor[2],
		ColorEnergy = PowerBarColor[3],
		ColorRunic = PowerBarColor[6],
		Side = 2,
		Level = 0,
	}
}
module.options = {
	{name = "ShowText", text = "SHOWTEXT", tooltip = "SHOWTEXT"},
	{name = "ShowTextMax", text = "SHOWTEXTMAX", tooltip = "SHOWTEXTMAX"},
	{name = "ShowPerc", text = "SHOWPERC", tooltip = "SHOWPERC"},
	{name = "SwapHealthPowerText", text = "SWAPHEALTHPOWERTEXT", tooltip = "SWAPHEALTHPOWERTEXT"},
	hasmanabar = true,
	attach = true,
}

module.localized = true

----------------------------------------------
-- Initialize
----------------------------------------------
function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)

	self.MPText = self:CreateFontString(self.f, "BACKGROUND", {150, 15}, 14, "LEFT", {1.0, 1.0, 0.0}, {"TOPLEFT", ArcHUDFrameCombo, "TOPRIGHT", 0, 0})
	self.MPPerc = self:CreateFontString(self.f, "BACKGROUND", {70, 14}, 12, "LEFT", {1.0, 1.0, 1.0}, {"TOPLEFT", self.MPText, "BOTTOMLEFT", 0, 0})
	
		-- Create StatusBar arc for 12.0.0+ (Midnight)
		if ArcHUD.isMidnight then
			-- Note: Mask texture path needs to be created - using placeholder for now
			-- Power is right side (Side=2), pass module name to determine positioning
			self.statusBarArc = self.parent:CreateStatusBarArc(self.f, nil, self.name) -- TODO: Add mask texture path
		if self.statusBarArc then
			self.statusBarArc:Hide() -- Hide by default
		end
	end
	
	if not ArcHUD.isMidnight then
		self:RegisterTimer("UpdatePowerBar", self.UpdatePowerBar, 0.1, self, true)
	end
	
	self:CreateStandardModuleOptions(10)
end

----------------------------------------------
-- Update
----------------------------------------------
function module:OnModuleUpdate()
	if self.db.profile.ShowText then
		self.MPText:Show()
	else
		self.MPText:Hide()
	end

	if self.db.profile.ShowPerc then
		self.MPPerc:Show()
	else
		self.MPPerc:Hide()
	end
	
	if self.db.profile.SwapHealthPowerText then
		-- left
		self.MPText:ClearAllPoints()
		self.MPText:SetPoint("TOPRIGHT", ArcHUDFrameCombo, "TOPLEFT", 0, 0)
		self.MPText:SetJustifyH("RIGHT")
		self.MPPerc:ClearAllPoints()
		self.MPPerc:SetPoint("TOPRIGHT", self.MPText, "BOTTOMRIGHT", 0, 0)
		self.MPPerc:SetJustifyH("RIGHT")
	else
		-- right
		self.MPText:ClearAllPoints()
		self.MPText:SetPoint("TOPLEFT", ArcHUDFrameCombo, "TOPRIGHT", 0, 0)
		self.MPText:SetJustifyH("LEFT")
		self.MPPerc:ClearAllPoints()
		self.MPPerc:SetPoint("TOPLEFT", self.MPText, "BOTTOMLEFT", 0, 0)
		self.MPPerc:SetJustifyH("LEFT")
	end
	
	local HealthMod = ArcHUD:GetModule("Health")
	if HealthMod.db.profile.SwapHealthPowerText ~= self.db.profile.SwapHealthPowerText then
		HealthMod.db.profile.SwapHealthPowerText = self.db.profile.SwapHealthPowerText
		ArcHUD:SendMessage("ARCHUD_MODULE_UPDATE", "Health")
	end

	self:UpdateColor(UnitPowerType(self.unit))
	self:UpdatePowerBar()
end

----------------------------------------------
-- Enable
----------------------------------------------
function module:OnModuleEnable()
	self.f.pulse = false

	if ArcHUD.isMidnight then
		-- 12.0.0+ (Midnight): Initialize StatusBar arc
		if(UnitIsGhost(self.unit)) then
			self.f:GhostMode(true, self.unit)
			if self.statusBarArc then
				self.statusBarArc:Hide()
			end
		else
			self.f:GhostMode(false, self.unit)
			
			local powerType = UnitPowerType(self.unit)
			local info = self:GetPowerBarColorText(powerType)
			self.MPText:SetVertexColor(info.r, info.g, info.b)
			
			-- Update StatusBar arc
			if self.statusBarArc then
				self.parent:UpdateStatusBarArcPower(self.statusBarArc, self.unit, powerType)
				-- Use GetPowerBarColor (not GetPowerBarColorText) for StatusBar color
				-- GetPowerBarColorText returns light colors for text readability, but bar should use actual power color
				local barColor = self:GetPowerBarColor(powerType)
				self.parent:SetStatusBarArcColor(self.statusBarArc, barColor.r, barColor.g, barColor.b, 1)
			end
			
			-- Update text - display actual values, including secret values
			local power, maxPower = UnitPower(self.unit), UnitPowerMax(self.unit)
			local powerSecret = self.parent:IsSecretValue(power)
			local maxPowerSecret = self.parent:IsSecretValue(maxPower)
			local canCalculate = not powerSecret and not maxPowerSecret
			
			if canCalculate then
				self.MPText:SetText(self.parent:FormatPowerText(self.unit, powerType))
			else
				-- Secret values - show formatted text directly
				self.MPText:SetText(self.parent:FormatPowerText(self.unit, powerType))
			end
			self.MPPerc:SetText(self.parent:FormatPowerPercent(self.unit, powerType))
		end
	else
		-- Pre-12.0.0: Use original system
		if(UnitIsGhost(self.unit)) then
			self.f:GhostMode(true, self.unit)
		else
			self.f:GhostMode(false, self.unit)

			local info = self:GetPowerBarColorText(UnitPowerType(self.unit))
			self.MPText:SetVertexColor(info.r, info.g, info.b)

			self.f:SetMax(UnitPowerMax(self.unit))
			self.f:SetValue(UnitPower(self.unit))
			self.MPText:SetText(self.parent:fint(UnitPower(self.unit)).."/"..self.parent:fint(UnitPowerMax(self.unit)))
			self.MPPerc:SetText(floor((UnitPower(self.unit)/UnitPowerMax(self.unit))*100).."%")
		end
	end

	-- Register the events we will use
	self:RegisterUnitEvent("UNIT_POWER_UPDATE", "UpdatePowerEvent")
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "UpdatePowerEvent") -- For smoother updates
	self:RegisterUnitEvent("UNIT_MAXPOWER", "UpdatePowerEvent")
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "UpdatePowerType")
	self:RegisterEvent("PLAYER_ALIVE", "UpdatePowerEvent")
	self:RegisterEvent("PLAYER_LEVEL_UP")

	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
end

----------------------------------------------
-- PLAYER_LEVEL_UP
----------------------------------------------
function module:PLAYER_LEVEL_UP()
	if ArcHUD.isMidnight then
		-- On Midnight, max power may be secret - StatusBar handles this via percentage
		-- No need to update max explicitly
	else
		-- Pre-12.0.0: Update max normally
		self.f:SetMax(UnitPowerMax(self.unit))
	end
end

----------------------------------------------
-- Update Power (timer)
----------------------------------------------
function module:UpdatePowerBar()
	if (not UnitIsGhost(self.unit)) then
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
			end
			
			-- Update text
			-- Update text - display actual values, including secret values
			if canCalculate and maxPower > 0 then
				if self.db.profile.ShowTextMax then
					self.MPText:SetText(self.parent:FormatPowerText(self.unit, powerType))
				else
					local powerStr = self.parent:IsSecretValue(power) and tostring(power) or self.parent:fint(power)
					self.MPText:SetText(powerStr)
				end
				self.MPPerc:SetText(self.parent:FormatPowerPercent(self.unit, powerType))
				
				-- Stop timer when at full or empty
				if power == maxPower or power == 0 then
					self:StopTimer("UpdatePowerBar")
				end
			else
				-- Secret values - show formatted text directly
				self.MPText:SetText(self.parent:FormatPowerText(self.unit, powerType))
				self.MPPerc:SetText(self.parent:FormatPowerPercent(self.unit, powerType))
			end
		else
			-- Pre-12.0.0: Use original system
			local power = UnitPower(self.unit)
			local maxPower = UnitPowerMax(self.unit)
			
			if (maxPower > 0) then
				if self.db.profile.ShowTextMax then
					self.MPText:SetText(self.parent:fint(power).."/"..self.parent:fint(maxPower))
				else
					self.MPText:SetText(self.parent:fint(power))
				end
				self.MPPerc:SetText(floor((power/maxPower)*100).."%")
			else
				self.MPText:SetText("")
				self.MPPerc:SetText("")
			end
			
			self.f:SetMax(maxPower)
			self.f:SetValue(power)
				
			if (power == maxPower or power == 0) then
				self:StopTimer("UpdatePowerBar")
			end
		end
	end
end

----------------------------------------------
-- Update Power (event)
----------------------------------------------
function module:UpdatePowerEvent(event, arg1)
	if (arg1 == self.unit) then
		if ArcHUD.isMidnight then
			-- 12.0.0+ (Midnight): Use StatusBar approach
			local powerType = UnitPowerType(self.unit)
			local power, maxPower = UnitPower(self.unit), UnitPowerMax(self.unit)
			local powerSecret = self.parent:IsSecretValue(power)
			local maxPowerSecret = self.parent:IsSecretValue(maxPower)
			local canCalculate = not powerSecret and not maxPowerSecret
			
			if(UnitIsGhost(self.unit) or (UnitIsDead(self.unit) and event == "PLAYER_ALIVE")) then
				self.f:GhostMode(true, self.unit)
				if self.statusBarArc then
					self.statusBarArc:Hide()
				end
			else
				self.f:GhostMode(false, self.unit)
				
				-- Update StatusBar arc
				if self.statusBarArc then
					self.parent:UpdateStatusBarArcPower(self.statusBarArc, self.unit, powerType)
					-- Use GetPowerBarColor (not GetPowerBarColorText) for StatusBar color
					-- GetPowerBarColorText returns light colors for text readability, but bar should use actual power color
					local barColor = self:GetPowerBarColor(powerType)
					self.parent:SetStatusBarArcColor(self.statusBarArc, barColor.r, barColor.g, barColor.b, 1)
				end
				
				-- Update text - display actual values, including secret values
				if canCalculate and maxPower > 0 then
					if self.db.profile.ShowTextMax then
						self.MPText:SetText(self.parent:FormatPowerText(self.unit, powerType))
					else
						local powerStr = self.parent:IsSecretValue(power) and tostring(power) or self.parent:fint(power)
						self.MPText:SetText(powerStr)
					end
					self.MPPerc:SetText(self.parent:FormatPowerPercent(self.unit, powerType))
					
					-- Timer management
					if power == maxPower or power == 0 then
						self:StopTimer("UpdatePowerBar")
					else
						self:StartTimer("UpdatePowerBar")
					end
				else
					-- Secret values - show formatted text directly
					self.MPText:SetText(self.parent:FormatPowerText(self.unit, powerType))
					self.MPPerc:SetText(self.parent:FormatPowerPercent(self.unit, powerType))
				end
			end
		else
			-- Pre-12.0.0: Use original system
			local power = UnitPower(self.unit)
			local maxPower = UnitPowerMax(self.unit)
			
			if(UnitIsGhost(self.unit) or (UnitIsDead(self.unit) and event == "PLAYER_ALIVE")) then
				self.f:GhostMode(true, self.unit)
			else
				self.f:GhostMode(false, self.unit)
				
				if (maxPower > 0) then
					if self.db.profile.ShowTextMax then
						self.MPText:SetText(self.parent:fint(power).."/"..self.parent:fint(maxPower))
					else
						self.MPText:SetText(self.parent:fint(power))
					end
					self.MPPerc:SetText(floor((power/maxPower)*100).."%")
				else
					self.MPText:SetText("")
					self.MPPerc:SetText("")
				end

				self.f:SetMax(maxPower)
				self.f:SetValue(power)
			end
			
			if (power == maxPower or power == 0) then
				self:StopTimer("UpdatePowerBar")
			else
				self:StartTimer("UpdatePowerBar")
			end
		end
	end
end

function module:UpdatePowerType(event, arg1)
	if (arg1 == self.unit) then
		if(event == "UNIT_DISPLAYPOWER") then
			self:UpdateColor(UnitPowerType(self.unit))
			
			local info = self:GetPowerBarColorText(UnitPowerType(self.unit))
			self.MPText:SetVertexColor(info.r, info.g, info.b)
		end
		self:UpdatePowerBar()
	end
end

