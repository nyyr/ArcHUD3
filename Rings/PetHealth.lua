local moduleName = "PetHealth"
local module = ArcHUD:NewModule(moduleName)
module.version = "2.0 (@file-abbreviated-hash@)"

module.unit = "pet"
module.isHealth = true

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		ShowPerc = true,
		ColorMode = "fade",
		Color = {r = 0, g = 1, b = 0},
		InnerAnchor = true,
		Side = 1,
		Level = 0,
	}
}
module.options = {
	{name = "ShowPerc", text = "SHOWPERC", tooltip = "SHOWPERC"},
	hascolorfade = true,
}
module.localized = true

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)

	self.f:SetAlpha(0)

	self.HPPerc = self:CreateFontString(self.f, "BACKGROUND", {100, 17}, 16, "RIGHT", {1.0, 1.0, 1.0}, {"BOTTOMLEFT", self.f, "BOTTOMLEFT", -165, -125})
	
	-- Create StatusBar arc for 12.0.0+ (Midnight)
	if ArcHUD.isMidnight then
		-- Note: Mask texture path needs to be created - using placeholder for now
		-- PetHealth is left side (Side=1), pass module name to determine positioning
		self.statusBarArc = self.parent:CreateStatusBarArc(self.f, nil, self.name) -- TODO: Add mask texture path
		if self.statusBarArc then
			self.statusBarArc:Hide() -- Hide by default
		end
	end
	
	self:CreateStandardModuleOptions(35)
end

function module:OnModuleUpdate()
	if(self.db.profile.ShowPerc) then
		self.HPPerc:Show()
	else
		self.HPPerc:Hide()
	end

	if not self.db.profile.InnerAnchor then
		fontName, _, fontFlags = self.HPPerc:GetFont()
		self.HPPerc:SetFont(fontName, 11, fontFlags)

		self.HPPerc:SetWidth(40)
		self.HPPerc:SetHeight(12)

		self.HPPerc:ClearAllPoints()
		if(self.db.profile.Side == 1) then
			-- Attach to left side
			self.HPPerc:SetPoint("TOPLEFT", self.f, "BOTTOMLEFT", -100, -115)
		else
			-- Attach to right side
			self.HPPerc:SetPoint("TOPLEFT", self.f, "BOTTOMLEFT", 50, -115)
		end
	else
		fontName, _, fontFlags = self.HPPerc:GetFont()
		self.HPPerc:SetFont(fontName, 16, fontFlags)
		
		self.HPPerc:SetWidth(100)
		self.HPPerc:SetHeight(17)

		-- TODO side
		self.HPPerc:ClearAllPoints()
		self.HPPerc:SetPoint("BOTTOMLEFT", self.f, "BOTTOMLEFT", -165, -125)
	end

	self.f:SetValue(UnitHealth(self.unit))
	self:UpdateColor()
end

function module:OnModuleEnable()
	self:UpdateColor(self.db.profile.Color)
	
	if ArcHUD.isMidnight then
		-- 12.0.0+ (Midnight): Initialize StatusBar arc
		if(UnitExists(self.unit)) then
			local maxHealth = UnitHealthMax(self.unit)
			local maxHealthSecret = self.parent:IsSecretValue(maxHealth)
			
			if not maxHealthSecret and maxHealth > 0 then
				-- Update StatusBar arc
				if self.statusBarArc then
					self.parent:UpdateStatusBarArcHealth(self.statusBarArc, self.unit)
					-- Returns ColorMixin object (may contain secret values)
					local color = self.parent:GetHealthColorFromUnit(self.unit)
					self.parent:SetStatusBarArcColor(self.statusBarArc, color)
				end
				
			-- Update text - display actual values, including secret values
			self.HPPerc:SetText(self.parent:FormatHealthPercent(self.unit))
			else
				if self.statusBarArc then
					self.statusBarArc:Hide()
				end
				self.HPPerc:SetText("")
			end
		else
			if self.statusBarArc then
				self.statusBarArc:Hide()
			end
			self.HPPerc:SetText("")
		end
	else
		-- Pre-12.0.0: Use original system
		if(UnitExists(self.unit) and UnitHealthMax(self.unit) > 0) then
			self.HPPerc:SetText(floor((UnitHealth(self.unit) / UnitHealthMax(self.unit)) * 100).."%")
			self.f:SetMax(UnitHealthMax(self.unit))
			self.f:SetValue(UnitHealth(self.unit))
		else
			self.HPPerc:SetText("")
			self.f:SetMax(0)
			self.f:SetValue(0)
		end
	end

	-- Register the events we will use
	self:RegisterEvent("PET_UI_UPDATE",		 "UpdatePet")
	self:RegisterEvent("PET_BAR_UPDATE",	 "UpdatePet")
	self:RegisterUnitEvent("UNIT_PET",		 "UpdatePet", "player")
	self:RegisterUnitEvent("UNIT_HEALTH", 	 "UpdateHealth")
	self:RegisterUnitEvent("UNIT_MAXHEALTH", "UpdateHealth")

	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
end

function module:UpdatePet(event, arg1)
	if(event == "UNIT_PET" and arg1 ~= "player") then return end
	if(UnitExists(self.unit)) then
		if ArcHUD.isMidnight then
			-- 12.0.0+ (Midnight): Use StatusBar approach
			--self:Debug(3, "PetHealth:UpdatePet("..event..", "..tostring(arg1).."): max = "..
			--	tostring(UnitHealthMax(self.unit))..", health = "..tostring(UnitHealth(self.unit)))
			self:UpdateColor()
			
			-- Update StatusBar arc
			if self.statusBarArc then
				self.parent:UpdateStatusBarArcHealth(self.statusBarArc, self.unit)
				local r, g, b, a = self.parent:GetHealthColorFromUnit(self.unit)
				self.parent:SetStatusBarArcColor(self.statusBarArc, r, g, b, a)
			end
			
			-- Update text
			local maxHealth = UnitHealthMax(self.unit)
			local maxHealthSecret = self.parent:IsSecretValue(maxHealth)
			if not maxHealthSecret and maxHealth > 0 then
				local p = self.parent:GetHealthPercent(self.unit)
				local pctInt = math.floor(p * 100)
				self.HPPerc:SetText(pctInt.."%")
				self.f:Show()
			else
				self.HPPerc:SetText("")
				if self.statusBarArc then
					self.statusBarArc:Hide()
				end
				self.f:Hide()
			end
		else
			-- Pre-12.0.0: Use original system
			--self:Debug(3, "PetHealth:UpdatePet("..event..", "..tostring(arg1).."): max = "..
			--	tostring(UnitHealthMax(self.unit))..", health = "..tostring(UnitHealth(self.unit)))
			self:UpdateColor()
			self.f:SetMax(UnitHealthMax(self.unit))
			self.f:SetValue(UnitHealth(self.unit))
			if (UnitHealthMax(self.unit) > 0) then
				self.HPPerc:SetText(floor((UnitHealth(self.unit) / UnitHealthMax(self.unit)) * 100).."%")
				self.f:Show()
			else
				self.HPPerc:SetText("")
				self.f:Hide()
			end
		end
	else
		self.parent.PetIsInCombat = false
		if self.statusBarArc then
			self.statusBarArc:Hide()
		end
		self.f:Hide()
	end
end

function module:UpdateHealth(event, arg1)
	if(arg1 == self.unit) then
		if ArcHUD.isMidnight then
			-- 12.0.0+ (Midnight): Use StatusBar approach
			local health, maxHealth = UnitHealth(self.unit), UnitHealthMax(self.unit)
			local healthSecret = self.parent:IsSecretValue(health)
			local maxHealthSecret = self.parent:IsSecretValue(maxHealth)
			local canCalculate = not healthSecret and not maxHealthSecret
			
			-- Get percentage using safe API - display actual values
			
			-- Update StatusBar arc
			if self.statusBarArc then
				self.parent:UpdateStatusBarArcHealth(self.statusBarArc, self.unit)
				local r, g, b, a = self.parent:GetHealthColorFromUnit(self.unit)
				self.parent:SetStatusBarArcColor(self.statusBarArc, r, g, b, a)
			end
			
			-- Color calculation (only if we can calculate)
			local r, g = 1, 1
			if canCalculate and not self.parent:IsSecretValue(p) then
				if ( p > 0.5 ) then
					r = (1.0 - p) * 2
					g = 1.0
				else
					r = 1.0
					g = p * 2
				end
				if ( r < 0 ) then r = 0 elseif ( r > 1 ) then r = 1 end
				if ( g < 0 ) then g = 0 elseif ( g > 1 ) then g = 1 end
			end
			
			if(self.ColorMode == "fade") then
				self:UpdateColor({r = r, g = g, b = 0})
			else
				self:UpdateColor()
			end
			
			-- Update text - use FormatHealthPercent to handle secret values
			self.HPPerc:SetText(self.parent:FormatHealthPercent(self.unit))
		else
			-- Pre-12.0.0: Use original system
			local p=UnitHealth(self.unit)/UnitHealthMax(self.unit)
			local r, g = 1, 1
			if ( p > 0.5 ) then
				r = (1.0 - p) * 2
				g = 1.0
			else
				r = 1.0
				g = p * 2
			end
			if ( r < 0 ) then r = 0 elseif ( r > 1 ) then r = 1 end
			if ( g < 0 ) then g = 0 elseif ( g > 1 ) then g = 1 end
			if(self.ColorMode == "fade") then
				self:UpdateColor({r = r, g = g, b = 0})
			else
				self:UpdateColor()
			end

			--self:Debug(3, "PetHealth:UpdateHealth("..event..", "..arg1.."): max = "..
			--	tostring(UnitHealthMax(self.unit))..", health = "..tostring(UnitHealth(self.unit)))
			
			if (event == "UNIT_MAXHEALTH") then
				self.f:SetMax(UnitHealthMax(self.unit))
			else
				if (self.f.maxValue ~= UnitHealthMax(self.unit)) then
					-- might happen that UNIT_HEALTH and UNIT_MAXHEALTH arrive in the wrong order
					self.f:SetMax(UnitHealthMax(self.unit))
				end
				self.f:SetValue(UnitHealth(self.unit))
				if (UnitHealthMax(self.unit) > 0) then
					self.HPPerc:SetText(floor((UnitHealth(self.unit) / UnitHealthMax(self.unit)) * 100).."%")
				else
					self.HPPerc:SetText("")
				end
			end
		end
	end
end
