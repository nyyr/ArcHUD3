local moduleName = "PetHealth"
local module = ArcHUD:NewModule(moduleName)
module.version = "2.0 (aadecab)"

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
	if(UnitExists(self.unit) and UnitHealthMax(self.unit) > 0) then
		self.HPPerc:SetText(floor((UnitHealth(self.unit) / UnitHealthMax(self.unit)) * 100).."%")
		self.f:SetMax(UnitHealthMax(self.unit))
		self.f:SetValue(UnitHealth(self.unit))
	else
		self.HPPerc:SetText("")
		self.f:SetMax(0)
		self.f:SetValue(0)
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
	else
		self.parent.PetIsInCombat = false
		self.f:Hide()
	end
end

function module:UpdateHealth(event, arg1)
	if(arg1 == self.unit) then
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
