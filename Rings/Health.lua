-- localization
local LM = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Module")

local moduleName = "Health"
local module = ArcHUD:NewModule(moduleName)
local _, _, rev = string.find("$Rev$", "([0-9]+)")
module.version = "1.0 (r"..rev..")"

module.unit = "player"
module.isHealth = true

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		ShowText = true,
		ShowPerc = true,
		ShowDef = false,
		ShowIncoming = false,
		ColorMode = "fade",
		Color = {r = 0, g = 1, b = 0},
		Side = 1,
		Level = 0,
	}
}
module.options = {
	{name = "ShowText", text = "SHOWTEXT", tooltip = "SHOWTEXT"},
	{name = "ShowPerc", text = "SHOWPERC", tooltip = "SHOWPERC"},
	{name = "ShowDef", text = "DEFICIT", tooltip = "DEFICIT"},
	{name = "ShowIncoming", text = "INCOMINGHEALS", tooltip = "INCOMINGHEALS"},
	hascolorfade = true,
	attach = true,
}

module.localized = true

module.healPrediction = 0

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

	-- Register the events we will use
	self:RegisterEvent("UNIT_HEALTH", 		"UpdateHealth")
	self:RegisterEvent("UNIT_MAXHEALTH", 	"UpdateHealth")
	self:RegisterEvent("UNIT_HEAL_PREDICTION")
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
			self.HPText:SetText(self.parent:fint(health).."/"..self.parent:fint(maxHealth))
			self.HPPerc:SetText(floor((health/maxHealth)*100).."%")

			local deficit = maxHealth - health
			if deficit <= 0 then
				deficit = ""
			else
				deficit = "-" .. self.parent:fint(deficit)
			end
			self.DefText:SetText(deficit)

			self.f:SetMax(maxHealth)
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
-- UNIT_HEALTH_PREDICTION
----------------------------------------------
function module:UNIT_HEAL_PREDICTION(event, arg1)
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
