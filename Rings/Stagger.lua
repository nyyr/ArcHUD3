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
		Side = 1,
		Level = -1,
		ColorLight = PowerBarColor and PowerBarColor["STAGGER"] and PowerBarColor["STAGGER"][1] or {r = 0.52, g = 1.0, b = 0.52}, -- Light green
		ColorModerate = PowerBarColor and PowerBarColor["STAGGER"] and PowerBarColor["STAGGER"][2] or {r = 1.0, g = 0.98, b = 0.72}, -- Yellow
		ColorHeavy = PowerBarColor and PowerBarColor["STAGGER"] and PowerBarColor["STAGGER"][3] or {r = 1.0, g = 0.42, b = 0.42}, -- Red
		ColorExtreme = PowerBarColor and PowerBarColor["STAGGER"] and PowerBarColor["STAGGER"][4] or {r = 0.63, g = 0.12, b = 0.8}, -- Purple
		MaxPerc = 100, -- maximum value of ring in % of maximum health
	}
}
module.options = {
	attach = true,
	customcolors = {
		{name = "ColorLight", text = "COLORSTAGGERL"},
		{name = "ColorModerate", text = "COLORSTAGGERM"},
		{name = "ColorHeavy", text = "COLORSTAGGERH"},
		{name = "ColorExtreme", text = "COLORSTAGGERE"},
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

----------------------------------------------
-- Initialize
----------------------------------------------
function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)

	self:CreateStandardModuleOptions(55)
	
	-- additional options
	local additionalOptions = {
		maxPerc = {
			type		= "range",
			name		= LM["TEXT"]["STAGGER_MAX"],
			desc		= LM["TOOLTIP"]["STAGGER_MAX"],
			min			= 10,
			max			= 200,
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
		local staggerAmount = UnitStagger(self.unit)
		
		if staggerAmount > 0 then
			local maxHealth = UnitHealthMax(self.unit)
			local maxHealthSecret = self.parent:IsSecretValue(maxHealth)
			
			-- Only calculate max if values are not secret
			if not maxHealthSecret then
				self.f:SetMax(maxHealth * self.db.profile.MaxPerc / 100)
			end
			
			self.f.isHidden = nil
			
			--self:Debug(1, "SpellId: "..tostring(spellId)..", Amount: "..tostring(v1).."/"..tostring(v2)..", Duration: "..tostring(duration))
			
			if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
			else
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
			end

			self.f:SetValue(staggerAmount)
			
			-- Try to create color curve if not already cached
			if not self.colorCurve then
				local curveType = Enum.LuaCurveType or Enum.CurveType
				if curveType then
					self.colorCurve = C_CurveUtil.CreateColorCurve()
					if self.colorCurve then
						self.colorCurve:SetType(curveType.Linear)
						local colorLight = self.db.profile.ColorLight
						self.colorCurve:AddPoint(0.0, CreateColor(colorLight.r, colorLight.g, colorLight.b))
						local colorModerate = self.db.profile.ColorModerate
						self.colorCurve:AddPoint(0.3, CreateColor(colorModerate.r, colorModerate.g, colorModerate.b))
						local colorHeavy = self.db.profile.ColorHeavy
						self.colorCurve:AddPoint(0.6, CreateColor(colorHeavy.r, colorHeavy.g, colorHeavy.b))
						local colorExtreme = self.db.profile.ColorExtreme
						self.colorCurve:AddPoint(1.2, CreateColor(colorExtreme.r, colorExtreme.g, colorExtreme.b))
					end
				end
			end
			if self.colorCurve and  not maxHealthSecret then
				local color = self.colorCurve:Evaluate(staggerAmount/maxHealth)
				self:UpdateColor(color)
			end
			
		else
			self.f.isHidden = true
			self.f:SetValue(0)
			self.f:SetRingAlpha(0)
		end
	end
end
