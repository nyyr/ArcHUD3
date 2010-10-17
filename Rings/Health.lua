-- localization
local LM = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Module")

local moduleName = "Health"
local module = ArcHUD:NewModule("Health")
local _, _, rev = string.find("$Rev: 0 $", "([0-9]+)")
module.version = "3.0." .. rev
module.unit = "player"
module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		ShowText = true,
		ShowPerc = true,
		ShowDef = false,
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
	hascolorfade = true,
	attach = true,
}
module.optionsTable = {
	type		= "group",
	name		= LM[moduleName],
	args = {
		enabled = ArcHUD:GenerateModuleOption_Enabled(moduleName),
	},
}

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
end

----------------------------------------------
-- Update
----------------------------------------------
function module:Update()
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

	self.f:SetValue(UnitHealth(self.unit))
	self:UpdateColor()
end

----------------------------------------------
-- Enable
----------------------------------------------
function module:Enable()
	-- Initial setup
	self:UpdateColor(self.db.profile.Color)
	self.f:SetMax(UnitHealthMax(self.unit))

	self.f.pulse = false

	if(UnitIsGhost(self.unit)) then
		self.f:GhostMode(true, self.unit)
	else
		self.f:GhostMode(false, self.unit)
		self.f:SetValue(UnitHealth(self.unit))
		self.HPText:SetText(UnitHealth(self.unit).."/"..UnitHealthMax(self.unit))
		self.HPText:SetTextColor(0, 1, 0)
		self.HPPerc:SetText(floor((UnitHealth(self.unit)/UnitHealthMax(self.unit))*100).."%")
		self.DefText:SetText("0")
	end

	-- Register the events we will use
	self:RegisterEvent("UNIT_HEALTH", 		"UpdateHealth")
	self:RegisterEvent("UNIT_MAXHEALTH", 	"UpdateHealth")
	self:RegisterEvent("PLAYER_LEVEL_UP")

	-- Activate the timers
	self.parent:StartMetro(self.name .. "Alpha")
	self.parent:StartMetro(self.name .. "Fade")
	self.parent:StartMetro(self.name .. "Update")

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
			self.HPText:SetText(UnitHealth(self.unit).."/"..UnitHealthMax(self.unit))
			self.HPPerc:SetText(floor((UnitHealth(self.unit)/UnitHealthMax(self.unit))*100).."%")

			local deficit = UnitHealthMax(self.unit) - UnitHealth(self.unit)
			if deficit <= 0 then
				deficit = ""
			else
				deficit = "-" .. deficit
			end
			self.DefText:SetText(deficit)

			self.f:SetMax(UnitHealthMax(self.unit))
			self.f:SetValue(UnitHealth(self.unit))
		end
	end
end
