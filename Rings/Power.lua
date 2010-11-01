-- localization
local LM = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Module")

local moduleName = "Power"
local module = ArcHUD:NewModule(moduleName)
local _, _, rev = string.find("$Rev$", "([0-9]+)")
module.version = "0.9 (r"..rev..")"
module.unit = "player"
module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		ShowText = true,
		ShowPerc = true,
		ColorMode = "default",
		ColorMana = PowerBarColor[0],
		ColorRage = PowerBarColor[1],
		ColorFocus = PowerBarColor[2],
		ColorEnergy = PowerBarColor[3],
		Side = 2,
		Level = 0,
	}
}
module.options = {
	{name = "ShowText", text = "SHOWTEXT", tooltip = "SHOWTEXT"},
	{name = "ShowPerc", text = "SHOWPERC", tooltip = "SHOWPERC"},
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
	self.MPPerc = self:CreateFontString(self.f, "BACKGROUND", {40, 14}, 12, "LEFT", {1.0, 1.0, 1.0}, {"TOPLEFT", self.MPText, "BOTTOMLEFT", 0, 0})
	self.parent:RegisterMetro(self.name .. "UpdatePowerBar", self.UpdatePower, 0.1, self, self.unit)
	
	self:CreateStandardModuleOptions(10)
end

----------------------------------------------
-- Update
----------------------------------------------
function module:Update()
	if(self.db.profile.ShowText) then
		self.MPText:Show()
	else
		self.MPText:Hide()
	end

	if(self.db.profile.ShowPerc) then
		self.MPPerc:Show()
	else
		self.MPPerc:Hide()
	end

	self.f:SetValue(UnitPower(self.unit))
	self:UpdateColor(PowerBarColor[UnitPowerType(self.unit)])
end

----------------------------------------------
-- Enable
----------------------------------------------
function module:OnModuleEnable()
	self.f.pulse = false

	if(UnitIsGhost(self.unit)) then
		self.f:GhostMode(true, self.unit)
	else
		self.f:GhostMode(false, self.unit)

		info = self:GetPowerBarColorText(UnitPowerType(self.unit))
		self.MPText:SetVertexColor(info.r, info.g, info.b)

		self.f:SetMax(UnitPowerMax(self.unit))
		self.f:SetValue(UnitPower(self.unit))
		self.MPText:SetText(UnitPower(self.unit).."/"..UnitPowerMax(self.unit))
		self.MPPerc:SetText(floor((UnitPower(self.unit)/UnitPowerMax(self.unit))*100).."%")
	end

	-- Register the events we will use
	self:RegisterEvent("UNIT_POWER", 		"UpdatePowerEvent")
	self:RegisterEvent("UNIT_MAXPOWER", 	"UpdatePowerEvent")
	self:RegisterEvent("UNIT_DISPLAYPOWER", "UpdatePowerType")
	self:RegisterEvent("PLAYER_ALIVE", 		"UpdatePowerEvent")
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
	self.f:SetMax(UnitPowerMax(self.unit))
end

----------------------------------------------
-- Update Power (metronome)
----------------------------------------------
function module:UpdatePower()
	if(UnitIsGhost(self.unit) or (UnitIsDead(self.unit) and event == "PLAYER_ALIVE")) then
		self.f:GhostMode(true, self.unit)
	else
		self.f:GhostMode(false, self.unit)

		self.MPText:SetText(UnitPower(self.unit).."/"..UnitPowerMax(self.unit))
		self.MPPerc:SetText(floor((UnitPower(self.unit)/UnitPowerMax(self.unit))*100).."%")

		self.f:SetMax(UnitPowerMax(self.unit))
		self.f:SetValue(UnitPower(self.unit))
	end
	if (UnitPower(self.unit) == UnitPowerMax(self.unit) or UnitPower(self.unit) == 0) then
		self.parent:StopMetro(self.name .. "UpdatePowerBar")
	end
end

----------------------------------------------
-- Update Power (event)
----------------------------------------------
function module:UpdatePowerEvent(event, arg1)
	if (arg1 == self.unit) then
		if(UnitIsGhost(self.unit) or (UnitIsDead(self.unit) and event == "PLAYER_ALIVE")) then
			self.f:GhostMode(true, self.unit)
		else
			self.f:GhostMode(false, self.unit)

			self.MPText:SetText(UnitPower(self.unit).."/"..UnitPowerMax(self.unit))
			self.MPPerc:SetText(floor((UnitPower(self.unit)/UnitPowerMax(self.unit))*100).."%")

			self.f:SetMax(UnitPowerMax(self.unit))
			self.f:SetValue(UnitPower(self.unit))
		end
		if (UnitPower(self.unit) == UnitPowerMax(self.unit) or UnitPower(self.unit) == 0) then
			self.parent:StopMetro(self.name .. "UpdatePowerBar")
		else
			self.parent:StartMetro(self.name .. "UpdatePowerBar")
		end
	end
end

function module:UpdatePowerType(event, arg1)
	if (arg1 == self.unit) then
		if(event == "UNIT_DISPLAYPOWER") then
			self:UpdateColor(self:GetPowerBarColor(UnitPowerType(self.unit)))
			
			info = self:GetPowerBarColorText(UnitPowerType(self.unit))
			self.MPText:SetVertexColor(info.r, info.g, info.b)
		end
		self:UpdatePower()
	end
end

