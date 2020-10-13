-- localization
local LM = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Module")

local moduleName = "Stagger"
local module = ArcHUD:NewModule(moduleName)
module.version = "2.3 (0375fe9)"

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
		ColorLight = PowerBarColor["STAGGER"][1],
		ColorModerate = PowerBarColor["STAGGER"][2],
		ColorHeavy = PowerBarColor["STAGGER"][3],
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

	-- Initial setup
	self:UpdateColor()
	self.f:SetMax(UnitHealthMax(self.unit))

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
				UnitDebuff(self.unit, i)
			if spellId == LIGHT_STAGGER or spellId == MODERATE_STAGGER or spellId == HEAVY_STAGGER then
				hasStagger = true
				break
			end
		end
		
		if hasStagger then
			local maxHealth = UnitHealthMax(self.unit)
			self.f:SetMax(maxHealth * self.db.profile.MaxPerc / 100)
			self.f.isHidden = nil
			
			--self:Debug(1, "SpellId: "..tostring(spellId)..", Amount: "..tostring(v1).."/"..tostring(v2)..", Duration: "..tostring(duration))
			
			if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
			else
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
			end
			
			self.f:SetValue(v2)
			
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
