-- localization
local LM = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Module")

local moduleName = "Health"
local module = ArcHUD:NewModule(moduleName)
module.version = "2.3 (@file-abbreviated-hash@)"

module.unit = "player"
module.isHealth = true
module.healPrediction = 0

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		ShowText = true,
		ShowTextMax = true,
		ShowPerc = true,
		ShowDef = false,
		ShowIncoming = not ArcHUD.classic,
		ShowAbsorbs = not ArcHUD.classic,
		SwapHealthPowerText = false,
		ColorMode = "fade",
		Color = {r = 0, g = 1, b = 0},
		ColorAbsorbs = {r = 1, g = 1, b = 1},
		Side = 1,
		Level = 0,
	}
}
if (ArcHUD.classic) then
	module.options = {
		{name = "ShowText", text = "SHOWTEXT", tooltip = "SHOWTEXT"},
		{name = "ShowTextMax", text = "SHOWTEXTMAX", tooltip = "SHOWTEXTMAX"},
		{name = "ShowPerc", text = "SHOWPERC", tooltip = "SHOWPERC"},
		{name = "ShowDef", text = "DEFICIT", tooltip = "DEFICIT"},
		{name = "SwapHealthPowerText", text = "SWAPHEALTHPOWERTEXT", tooltip = "SWAPHEALTHPOWERTEXT"},
		hascolorfade = true,
		attach = true,
		customcolors = {
			{name = "ColorAbsorbs", text = "COLORABSORBS"},
		}
	}
else
	module.options = {
		{name = "ShowText", text = "SHOWTEXT", tooltip = "SHOWTEXT"},
		{name = "ShowTextMax", text = "SHOWTEXTMAX", tooltip = "SHOWTEXTMAX"},
		{name = "ShowPerc", text = "SHOWPERC", tooltip = "SHOWPERC"},
		{name = "ShowDef", text = "DEFICIT", tooltip = "DEFICIT"},
		{name = "ShowIncoming", text = "INCOMINGHEALS", tooltip = "INCOMINGHEALS"},
		{name = "ShowAbsorbs", text = "SHOWABSORBS", tooltip = "SHOWABSORBS"},
		{name = "SwapHealthPowerText", text = "SWAPHEALTHPOWERTEXT", tooltip = "SWAPHEALTHPOWERTEXT"},
		hascolorfade = true,
		attach = true,
		customcolors = {
			{name = "ColorAbsorbs", text = "COLORABSORBS"},
		}
	}
end

module.localized = true

----------------------------------------------
-- Initialize
----------------------------------------------
function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)

	self.HPText = self:CreateFontString(self.f, "BACKGROUND", {150, 15}, 14, "RIGHT", {1.0, 1.0, 0.0}, {"TOPRIGHT", ArcHUDFrameCombo, "TOPLEFT", 0, 0})
	self.HPPerc = self:CreateFontString(self.f, "BACKGROUND", {70, 14}, 12, "RIGHT", {1.0, 1.0, 1.0}, {"TOPRIGHT", self.HPText, "BOTTOMRIGHT", 0, 0})
	self.DefText = self:CreateFontString(self.f, "BACKGROUND", {70, 14}, 11, "RIGHT", {1.0, 0.2, 0.2}, {"BOTTOMRIGHT", self.HPText, "TOPRIGHT", 0, 0})
	
	self:CreateStandardModuleOptions(5)
end

----------------------------------------------
-- Update
----------------------------------------------
function module:OnModuleUpdate()
	-- Get options and setup accordingly
	if(self.db.profile.ShowText) then
		self.HPText:Show()
	else
		self.HPText:Hide()
	end

	if(self.db.profile.ShowPerc) then
		self.HPPerc:Show()
	else
		self.HPPerc:Hide()
	end

	if(self.db.profile.ShowDef) then
		self.DefText:Show()
	else
		self.DefText:Hide()
	end
	
	if self.db.profile.SwapHealthPowerText then
		-- right
		self.HPText:ClearAllPoints()
		self.HPText:SetPoint("TOPLEFT", ArcHUDFrameCombo, "TOPRIGHT", 0, 0)
		self.HPText:SetJustifyH("LEFT")
		self.HPPerc:ClearAllPoints()
		self.HPPerc:SetPoint("TOPLEFT", self.HPText, "BOTTOMLEFT", 0, 0)
		self.HPPerc:SetJustifyH("LEFT")
		self.DefText:ClearAllPoints()
		self.DefText:SetPoint("BOTTOMLEFT", self.HPText, "TOPLEFT", 0, 0)
		self.DefText:SetJustifyH("LEFT")
	else
		-- left
		self.HPText:ClearAllPoints()
		self.HPText:SetPoint("TOPRIGHT", ArcHUDFrameCombo, "TOPLEFT", 0, 0)
		self.HPText:SetJustifyH("RIGHT")
		self.HPPerc:ClearAllPoints()
		self.HPPerc:SetPoint("TOPRIGHT", self.HPText, "BOTTOMRIGHT", 0, 0)
		self.HPPerc:SetJustifyH("RIGHT")
		self.DefText:ClearAllPoints()
		self.DefText:SetPoint("BOTTOMRIGHT", self.HPText, "TOPRIGHT", 0, 0)
		self.DefText:SetJustifyH("RIGHT")
	end
	
	local PowerMod = ArcHUD:GetModule("Power")
	if PowerMod.db.profile.SwapHealthPowerText ~= self.db.profile.SwapHealthPowerText then
		PowerMod.db.profile.SwapHealthPowerText = self.db.profile.SwapHealthPowerText
		ArcHUD:SendMessage("ARCHUD_MODULE_UPDATE", "Power")
	end

	if self.db.profile.ShowAbsorbs then
		self.frames[2]:Show()
		self:UpdateAbsorbs(nil, self.unit)
	else
		self.frames[2]:Hide()
	end
	
	self:UpdateHealth(nil, self.unit)
end

----------------------------------------------
-- OnModuleEnable
----------------------------------------------
function module:OnModuleEnable()
	-- Initial setup
	self:UpdateColor()
	self.f:SetMax(UnitHealthMax(self.unit))

	self.f.pulse = false

	if(UnitIsGhost(self.unit)) then
		self.f:GhostMode(true, self.unit)
	else
		self.f:GhostMode(false, self.unit)
		self.f:SetValue(UnitHealth(self.unit))
		self.HPText:SetText(self.parent:fint(UnitHealth(self.unit)).."/"..self.parent:fint(UnitHealthMax(self.unit)))
		self.HPText:SetTextColor(0, 1, 0)
		self.HPPerc:SetText(floor((UnitHealth(self.unit)/UnitHealthMax(self.unit))*100).."%")
		self.DefText:SetText("0")
	end
	
	if (not self.frames) then
		-- create frame for absorbs
		self.frames = {}
		self.frames[1] = self.f
		self.frames[2] = self:CreateRing(false, ArcHUDFrame)
		
		self.frames[1].nextRingPart = self.frames[2]
		
		self.frames[2]:SetStartAngle(self.frames[1].angle)
		self.frames[2]:SetMax(10)
		self.frames[2]:SetValue(0, 0)
		self.frames[2]:UpdateColor(self.db.profile.ColorAbsorbs)
		self.frames[2]:SetRingAlpha(0)
		self.frames[2].dirty = true
	end

	-- Register the events we will use
	self:RegisterUnitEvent("UNIT_HEALTH", "UpdateHealth")
	self:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "UpdateHealth")
	self:RegisterUnitEvent("UNIT_MAXHEALTH", "UpdateHealth")
	if (not ArcHUD.classic) then
		self:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "UpdateHealthPrediction")
		self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "UpdateAbsorbs")
	end
	self:RegisterEvent("PLAYER_LEVEL_UP")

	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
end

----------------------------------------------
-- PLAYER_LEVEL_UP
----------------------------------------------
function module:PLAYER_LEVEL_UP()
	self.f:SetMax(UnitHealthMax(self.unit))
end

----------------------------------------------
-- UpdateHealth
----------------------------------------------
function module:UpdateHealth(event, arg1)
	if(arg1 == self.unit) then
		local health, maxHealth = UnitHealth(self.unit), UnitHealthMax(self.unit)
		local p = health/maxHealth
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

		if(UnitIsGhost(self.unit)) then
			self.f:GhostMode(true, self.unit)
		else
			self.f:GhostMode(false, self.unit)

			if(self.ColorMode == "fade") then
				self:UpdateColor({r = r, g = g, b = 0.0})
				self.HPText:SetTextColor(r, g, 0)
			else
				self.HPText:SetTextColor(0, 1, 0)
				self:UpdateColor()
			end
			if self.db.profile.ShowTextMax then
				self.HPText:SetText(self.parent:fint(health).."/"..self.parent:fint(maxHealth))
			else
				self.HPText:SetText(self.parent:fint(health))
			end
			self.HPPerc:SetText(floor((health/maxHealth)*100).."%")

			local deficit = maxHealth - health
			if deficit <= 0 then
				deficit = ""
			else
				deficit = "-" .. self.parent:fint(deficit)
			end
			self.DefText:SetText(deficit)

			self.f:SetMax(maxHealth)
			
			if (not ArcHUD.classic) then
				local totalAbsorbs = UnitGetTotalAbsorbs(self.unit)
				if totalAbsorbs > 0 then
					self.frames[2]:SetMax(maxHealth - health)
				end
			end
			
			self.f:SetValue(health)
		end
		
		if self.healPrediction > 0 then
			local ih = self.healPrediction
			if health + ih >= maxHealth then
				ih = maxHealth - health - 1 -- spark will be hidden if <= 0 or >= max
			end
			self.f:SetSpark(health + ih)
		end
	end
end

----------------------------------------------
-- UpdateHealthPrediction
----------------------------------------------
function module:UpdateHealthPrediction(event, arg1)
	if self.db.profile.ShowIncoming and (arg1 == self.unit) then
		local ih = UnitGetIncomingHeals(self.unit)
		--self:Debug(1, "ih: %s", tostring(ih))
		if (not ih) or (ih == 0) then
			self.healPrediction = 0
			self.f:SetSpark(0) -- hide
		else
			self.healPrediction = ih
			local health, maxHealth = self.f.endValue, self.f.maxValue
			if health + ih >= maxHealth then
				ih = maxHealth - health - 1 -- spark will be hidden if <= 0 or >= max
			end
			--self:Debug(1, "spark: %s", tostring(health+ih))
			self.f:SetSpark(health + ih)
		end
	end
end

----------------------------------------------
-- UpdateAbsorbs
----------------------------------------------
function module:UpdateAbsorbs(event, arg1)
	if self.db.profile.ShowAbsorbs and (arg1 == self.unit) then
		local totalAbsorbs = UnitGetTotalAbsorbs(self.unit)
		
		if totalAbsorbs == 0 then
			self.frames[2].isHidden = true
			self.frames[2]:SetValue(0)
			self.frames[2]:SetRingAlpha(0)
		else
			local health, maxHealth = UnitHealth(self.unit), UnitHealthMax(self.unit)
			self.frames[2].isHidden = nil
			self.frames[2]:SetMax(maxHealth - health)
			self.frames[2]:SetValue(totalAbsorbs)
			if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
				self.frames[2]:SetRingAlpha(ArcHUD.db.profile.FadeIC)
			else
				self.frames[2]:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
			end
		end
	end
end
