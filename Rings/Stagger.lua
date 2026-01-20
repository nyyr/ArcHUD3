-- localization
local LM = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Module")

local moduleName = "Stagger"
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
		Side = 1,
		Level = -1,
		ColorLight = PowerBarColor and PowerBarColor["STAGGER"] and PowerBarColor["STAGGER"][1] or {r = 0.52, g = 1.0, b = 0.52}, -- Light green
		ColorModerate = PowerBarColor and PowerBarColor["STAGGER"] and PowerBarColor["STAGGER"][2] or {r = 1.0, g = 0.98, b = 0.72}, -- Yellow
		ColorHeavy = PowerBarColor and PowerBarColor["STAGGER"] and PowerBarColor["STAGGER"][3] or {r = 1.0, g = 0.42, b = 0.42}, -- Red
		MaxPerc = 100, -- maximum value of ring in % of maximum health
	}
}
module.options = {
	{name = "ShowText", text = "SHOWTEXT", tooltip = "SHOWTEXT"},
	attach = true,
	customcolors = {
		{name = "ColorLight", text = "COLORSTAGGERL"},
		{name = "ColorModerate", text = "COLORSTAGGERM"},
		{name = "ColorHeavy", text = "COLORSTAGGERH"},
	}
}

module.localized = true

-- Ensure color settings are properly initialized
function module:InitializeColors()
	local colorNames = {"ColorLight", "ColorModerate", "ColorHeavy"}
	for _, colorName in ipairs(colorNames) do
		local color = self.db.profile[colorName]
		if not color or type(color) ~= "table" or not color.r or not color.g or not color.b then
			-- Reset to default
			self.db.profile[colorName] = self.defaults.profile[colorName]
		end
	end
end

-- Buff IDs
local LIGHT_STAGGER = 124275
local MODERATE_STAGGER = 124274
local HEAVY_STAGGER = 124273
--local STAGGER = 124255

----------------------------------------------
-- Initialize
----------------------------------------------
function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)

	self.BuffButton = CreateFrame("Button", nil, self.f)
	self.BuffButton:SetWidth(15)
	self.BuffButton:SetHeight(15)
	self.BuffButton:SetPoint("TOP", self.f)
	self.BuffButton:EnableMouse(false);

	self.BuffButton.Icon = self.BuffButton:CreateTexture(nil, "ARTWORK")
	self.BuffButton.Icon:SetWidth(15)
	self.BuffButton.Icon:SetHeight(15)
	self.BuffButton.Icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	self.BuffButton.Icon:SetPoint("CENTER", self.BuffButton, "CENTER")
	self.BuffButton.Icon:Show()

	self.BuffButton:Show()

	self.Text = self:CreateFontString(self.BuffButton, "OVERLAY", {40, 12}, 10, "CENTER", {1.0, 1.0, 1.0}, {"TOP", self.BuffButton, "TOP", 1, -2})
	self.Text:Show()

	self:CreateStandardModuleOptions(55)
	
	-- additional options
	local additionalOptions = {
		maxPerc = {
			type		= "range",
			name		= LM["TEXT"]["STAGGER_MAX"],
			desc		= LM["TOOLTIP"]["STAGGER_MAX"],
			min			= 10,
			max			= 100,
			step		= 10,
			order		= 100,
			get			= function ()
				return self.db.profile.MaxPerc
			end,
			set			= function (info, v)
				self.db.profile.MaxPerc = v
				self:UpdateValue(nil, self.unit)
			end,
		},
	}
	
	self:AppendModuleOptions(additionalOptions)
end

----------------------------------------------
-- Update
----------------------------------------------
function module:OnModuleUpdate()
	self.BuffButton:ClearAllPoints()
	if(self.db.profile.Side == 1) then
		-- Attach to left side
		self.BuffButton:SetPoint("TOP", self.f, "BOTTOMLEFT", -20, -130)
	else
		-- Attach to right side
		self.BuffButton:SetPoint("TOP", self.f, "BOTTOMLEFT", 20, -130)
	end
	
	if (self.db.profile.ShowText) then
		self.Text:Show()
	else
		self.Text:SetText("")
		self.Text:Hide()
	end
	
	self.BuffButton:Show()
	
	self:UpdateValue(nil, self.unit)
end

----------------------------------------------
-- OnModuleEnable
----------------------------------------------
function module:OnModuleEnable()
	local _, class = UnitClass(self.unit)
	if (class ~= "MONK") then return end

	-- Ensure color settings are properly initialized
	self:InitializeColors()

	-- Initial setup
	self:UpdateColor()
	
	if ArcHUD.isMidnight then
		-- 12.0.0+ (Midnight): Max health may be secret - handle in UpdateValue
		-- No need to set max explicitly here
	else
		-- Pre-12.0.0: Set max normally
		self.f:SetMax(UnitHealthMax(self.unit))
	end

	-- Register the events we will use
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateValue")
	self:RegisterUnitEvent("UNIT_MAXHEALTH", "UpdateValue")
	self:RegisterUnitEvent("UNIT_AURA", "UpdateValue")

	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
	
	self:Debug(1, "Stagger-Ring activated")
end

----------------------------------------------
-- UpdateValue
----------------------------------------------
function module:UpdateValue(event, arg1)
	if(arg1 == self.unit) then
		local name, iconTex, debuffType, duration, expirationTime, unitCaster, spellId, v1, v2, v3
		local hasStagger
		for i = 1,40 do
			name, iconTex, _, debuffType, duration, expirationTime, unitCaster, _, _, spellId, _, _, _, v1, v2 =
				C_UnitAuras.GetDebuffDataByIndex(self.unit, i)
			if spellId == LIGHT_STAGGER or spellId == MODERATE_STAGGER or spellId == HEAVY_STAGGER then
				hasStagger = true
				break
			end
		end
		
		if hasStagger then
			local maxHealth = UnitHealthMax(self.unit)
			local maxHealthSecret = self.parent:IsSecretValue(maxHealth)
			local v2Secret = self.parent:IsSecretValue(v2)
			
			-- Only calculate max if values are not secret
			if not maxHealthSecret then
				self.f:SetMax(maxHealth * self.db.profile.MaxPerc / 100)
			else
				-- Fallback: use a reasonable estimate
				if not v2Secret and v2 then
					self.f:SetMax(v2 * 2)
				else
					self.f:SetMax(1000) -- Default fallback
				end
			end
			
			self.f.isHidden = nil
			
			--self:Debug(1, "SpellId: "..tostring(spellId)..", Amount: "..tostring(v1).."/"..tostring(v2)..", Duration: "..tostring(duration))
			
			if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
			else
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
			end
			
			-- Only set value if not secret
			if not v2Secret then
				self.f:SetValue(v2)
			else
				self.f:SetValue(0)
			end
			
			if spellId == LIGHT_STAGGER then
				self:UpdateColor(self.db.profile.ColorLight)
			elseif spellId == MODERATE_STAGGER then
				self:UpdateColor(self.db.profile.ColorModerate)
			elseif spellId == HEAVY_STAGGER then
				self:UpdateColor(self.db.profile.ColorHeavy)
			end
			
			if (duration) then
				local t = GetTime()
				if (expirationTime > t) then
					self.Text:SetText(math.floor(expirationTime - t))
				end
			else
				self.Text:SetText("")
			end
			
			self.BuffButton.Icon:SetTexture(iconTex)
			self.BuffButton:Show()
		else
			self.f.isHidden = true
			self.f:SetValue(0)
			self.f:SetRingAlpha(0)
			self.Text:SetText("")
			self.BuffButton:Hide()
		end
	end
end
