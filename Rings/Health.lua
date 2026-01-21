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
		ShowIncoming = ArcHUD.hasHealPrediction,
		ShowAbsorbs = ArcHUD.hasAbsorbs,
		SwapHealthPowerText = false,
		ColorMode = "fade",
		Color = {r = 0, g = 1, b = 0},
		ColorAbsorbs = {r = 1, g = 1, b = 1},
		Side = 1,
		Level = 0,
	}
}
if (not ArcHUD.hasAbsorbs) then
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
	
		-- Create StatusBar arc for 12.0.0+ (Midnight)
		if ArcHUD.isMidnight then
			self.statusBarArc = self.parent:CreateStatusBarArc(self.f, self.name)
		if self.statusBarArc then
			self.statusBarArc:Hide() -- Hide by default, show when we have valid data
			self.f:HideAllButOutline()
		end
	end
	
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

	if self.db.profile.Side and self.statusBarArc then
		self.parent:UpdateStatusBarSide(self.statusBarArc, self.db.profile.Side)
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
	
	if ArcHUD.isMidnight then
		-- 12.0.0+ (Midnight): Initialize StatusBar arc
		local health, maxHealth = UnitHealth(self.unit), UnitHealthMax(self.unit)
		local healthSecret = self.parent:IsSecretValue(health)
		local maxHealthSecret = self.parent:IsSecretValue(maxHealth)
		local canCalculate = not healthSecret and not maxHealthSecret
		
		self.f.pulse = false

		if(UnitIsGhost(self.unit)) then
			self.f:GhostMode(true, self.unit)
			if self.statusBarArc then
				self.statusBarArc:Hide()
			end
		else
			self.f:GhostMode(false, self.unit)
			
			-- Update StatusBar arc
			if self.statusBarArc then
				self.parent:UpdateStatusBarArcHealth(self.statusBarArc, self.unit)
				-- Update color from unit using ColorCurveObject
				-- Returns ColorMixin object (may contain secret values)
				local color = self.parent:GetHealthColorFromUnit(self.unit)
				self.parent:SetStatusBarArcColor(self.statusBarArc, color)
			end
			
			-- Update percentage text immediately (same time as StatusBar) to avoid lag
			self.HPPerc:SetText(self.parent:FormatHealthPercent(self.unit))
			
			-- Update text - display actual values, including secret values
			if canCalculate then
				self.HPText:SetText(self.parent:FormatHealthText(self.unit))
				self.DefText:SetText("0")
			else
				-- Secret values - show formatted text directly
				self.HPText:SetText(self.parent:FormatHealthText(self.unit))
				self.DefText:SetText("")
			end
			self.HPText:SetTextColor(0, 1, 0)
		end
	else
		-- Pre-12.0.0: Use original system
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
	if ArcHUD.classic then
		self:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "UpdateHealth")
	end
	self:RegisterUnitEvent("UNIT_MAXHEALTH", "UpdateHealth")
	if (ArcHUD.hasHealPrediction) then
		self:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "UpdateHealthPrediction")
	end
	if (ArcHUD.hasAbsorbs) then
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
	if ArcHUD.isMidnight then
		-- On Midnight, max health may be secret - StatusBar handles this via percentage
		-- No need to update max explicitly
	else
		-- Pre-12.0.0: Update max normally
		self.f:SetMax(UnitHealthMax(self.unit))
	end
end

----------------------------------------------
-- UpdateHealth
----------------------------------------------
function module:UpdateHealth(event, arg1)
	if(arg1 == self.unit) then
		if ArcHUD.isMidnight then
			-- 12.0.0+ (Midnight): Use StatusBar approach
			local health, maxHealth = UnitHealth(self.unit), UnitHealthMax(self.unit)
			local healthSecret = self.parent:IsSecretValue(health)
			local maxHealthSecret = self.parent:IsSecretValue(maxHealth)
			local canCalculate = not healthSecret and not maxHealthSecret
			
			-- Update percentage text FIRST to ensure it updates on every event (including first)
			self.HPPerc:SetText(self.parent:FormatHealthPercent(self.unit))
			
			-- Update StatusBar arc
			if self.statusBarArc then
				self.parent:UpdateStatusBarArcHealth(self.statusBarArc, self.unit)
				-- Update color from unit using ColorCurveObject
				-- Returns ColorMixin object (may contain secret values)
				local color = self.parent:GetHealthColorFromUnit(self.unit)
				self.parent:SetStatusBarArcColor(self.statusBarArc, color)
			end
			
			-- Update text display - display actual values, including secret values
			
			if canCalculate then
				if self.db.profile.ShowTextMax then
					self.HPText:SetText(self.parent:FormatHealthText(self.unit))
				else
					-- Use fint to format current health (will use AbbreviateNumbers with precision: 1)
					local healthStr = self.parent:fint(health)
					self.HPText:SetText(healthStr)
				end
				-- Deficit calculation
				local deficit = maxHealth - health
				if deficit <= 0 then
					self.DefText:SetText("")
				else
					self.DefText:SetText("-" .. self.parent:fint(deficit))
				end
			else
				-- Values are secret - show formatted text directly
				self.HPText:SetText(self.parent:FormatHealthText(self.unit))
				self.DefText:SetText("")
			end
			
			-- Color text
			if(self.ColorMode == "fade") then
				local color = self.parent:GetHealthColorFromUnit(self.unit)
				-- ColorMixin has GetRGB() method - use it directly
				-- GetRGB() may return secret values, but SetTextColor can handle them
				if color and type(color) == "table" and color.GetRGB then
					-- Use GetRGB() directly - SetTextColor can handle secret values
					self.HPText:SetTextColor(color:GetRGB())
					-- For UpdateColor on the ring, we need to extract values
					-- Try to get RGB for UpdateColor, but handle secret values gracefully
					local r, g, b = color:GetRGB()
					-- Check if we can use these values for UpdateColor
					-- If they're secret, UpdateColor might not work, so skip it
					if not self.parent:IsSecretValue(r) and not self.parent:IsSecretValue(g) and
					   type(r) == "number" and type(g) == "number" then
						self:UpdateColor({r = r, g = g, b = b or 0})
					else
						-- Secret values - can't use for UpdateColor, but text color is already set
						-- Keep default ring color
					end
				else
					-- Legacy mode or fallback - should not happen in Midnight
					self.HPText:SetTextColor(1, 1, 0)
					self:UpdateColor({r = 1, g = 1, b = 0})
				end
			else
				self.HPText:SetTextColor(0, 1, 0)
				self:UpdateColor()
			end
			
			-- Ghost mode handling
			if(UnitIsGhost(self.unit)) then
				self.f:GhostMode(true, self.unit)
				if self.statusBarArc then
					self.statusBarArc:Hide()
				end
			else
				self.f:GhostMode(false, self.unit)
			end
			
			-- Absorbs (only if we can calculate)
			if (ArcHUD.hasAbsorbs) and canCalculate then
				local totalAbsorbs = UnitGetTotalAbsorbs(self.unit)
				if totalAbsorbs and totalAbsorbs > 0 then
					if not self.frames then
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
					self.frames[2]:SetMax(maxHealth - health)
				end
			end
			
			-- Heal prediction (only if we can calculate)
			if self.healPrediction > 0 and canCalculate then
				local ih = self.healPrediction
				if health + ih >= maxHealth then
					ih = maxHealth - health - 1
				end
				-- Note: Spark positioning may not work with StatusBar - may need alternative
			end
		else
			-- Pre-12.0.0: Use original ring system
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
				
				if (ArcHUD.hasAbsorbs) then
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
end

----------------------------------------------
-- UpdateHealthPrediction
----------------------------------------------
function module:UpdateHealthPrediction(event, arg1)
	if self.db.profile.ShowIncoming and (arg1 == self.unit) then
		local ih = UnitGetIncomingHeals(self.unit)
		--self:Debug(1, "ih: %s", tostring(ih))
		-- Protect against secret values in comparison
		local ihSecret = self.parent:IsSecretValue(ih)
		if ihSecret then
			-- Secret value - can't compare, skip spark
			self.healPrediction = 0
			if not ArcHUD.isMidnight then
				self.f:SetSpark(0) -- hide
			end
		elseif (not ih) or (ih == 0) then
			self.healPrediction = 0
			if not ArcHUD.isMidnight then
				self.f:SetSpark(0) -- hide
			end
		else
			self.healPrediction = ih
			if ArcHUD.isMidnight then
				-- On Midnight, spark positioning may not work with StatusBar
				-- Skip spark for now - may need alternative visualization
			else
				-- Pre-12.0.0: Use original spark system
				local health, maxHealth = self.f.endValue, self.f.maxValue
				if health + ih >= maxHealth then
					ih = maxHealth - health - 1 -- spark will be hidden if <= 0 or >= max
				end
				--self:Debug(1, "spark: %s", tostring(health+ih))
				self.f:SetSpark(health + ih)
			end
		end
	end
end

----------------------------------------------
-- UpdateAbsorbs
----------------------------------------------
function module:UpdateAbsorbs(event, arg1)
	if self.db.profile.ShowAbsorbs and (arg1 == self.unit) then
		local totalAbsorbs = UnitGetTotalAbsorbs(self.unit)
		local totalAbsorbsSecret = self.parent:IsSecretValue(totalAbsorbs)
		
		-- Check if absorbs are zero or nil - protect against secret value comparison
		local hasAbsorbs = true
		if not totalAbsorbs then
			hasAbsorbs = false
		elseif not totalAbsorbsSecret then
			-- Only compare if not secret
			if totalAbsorbs == 0 then
				hasAbsorbs = false
			end
		end
		-- If secret, assume hasAbsorbs (let StatusBar/ring handle it)
		
		if not hasAbsorbs then
			if self.frames and self.frames[2] then
				self.frames[2].isHidden = true
				self.frames[2]:SetValue(0)
				self.frames[2]:SetRingAlpha(0)
			end
		else
			local health, maxHealth = UnitHealth(self.unit), UnitHealthMax(self.unit)
			local healthSecret = self.parent:IsSecretValue(health)
			local maxHealthSecret = self.parent:IsSecretValue(maxHealth)
			
			if self.frames and self.frames[2] then
				self.frames[2].isHidden = nil
				
				-- Only calculate max if values are not secret
				if not healthSecret and not maxHealthSecret then
					self.frames[2]:SetMax(maxHealth - health)
				elseif not totalAbsorbsSecret then
					-- Fallback: use a reasonable estimate (only if totalAbsorbs is not secret)
					self.frames[2]:SetMax(totalAbsorbs * 2)
				else
					-- All values are secret - use a default max
					self.frames[2]:SetMax(100)
				end
				
				-- SetValue can handle secret values directly
				self.frames[2]:SetValue(totalAbsorbs)
				if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
					self.frames[2]:SetRingAlpha(ArcHUD.db.profile.FadeIC)
				else
					self.frames[2]:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
				end
			end
		end
	end
end
