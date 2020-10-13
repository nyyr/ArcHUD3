-- localization
local LM = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Module")

local moduleName = "Power"
local module = ArcHUD:NewModule(moduleName)
module.version = "2.0 (243459a)"
module.unit = "player"
module.isPower = true
module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		ShowText = true,
		ShowTextMax = true,
		ShowPerc = true,
		SwapHealthPowerText = false,
		ColorMana = PowerBarColor[0],
		ColorRage = PowerBarColor[1],
		ColorFocus = PowerBarColor[2],
		ColorEnergy = PowerBarColor[3],
		ColorRunic = PowerBarColor[6],
		Side = 2,
		Level = 0,
	}
}
module.options = {
	{name = "ShowText", text = "SHOWTEXT", tooltip = "SHOWTEXT"},
	{name = "ShowTextMax", text = "SHOWTEXTMAX", tooltip = "SHOWTEXTMAX"},
	{name = "ShowPerc", text = "SHOWPERC", tooltip = "SHOWPERC"},
	{name = "SwapHealthPowerText", text = "SWAPHEALTHPOWERTEXT", tooltip = "SWAPHEALTHPOWERTEXT"},
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
	self.MPPerc = self:CreateFontString(self.f, "BACKGROUND", {70, 14}, 12, "LEFT", {1.0, 1.0, 1.0}, {"TOPLEFT", self.MPText, "BOTTOMLEFT", 0, 0})
	self:RegisterTimer("UpdatePowerBar", self.UpdatePowerBar, 0.1, self, true)
	
	self:CreateStandardModuleOptions(10)
end

----------------------------------------------
-- Update
----------------------------------------------
function module:OnModuleUpdate()
	if self.db.profile.ShowText then
		self.MPText:Show()
	else
		self.MPText:Hide()
	end

	if self.db.profile.ShowPerc then
		self.MPPerc:Show()
	else
		self.MPPerc:Hide()
	end
	
	if self.db.profile.SwapHealthPowerText then
		-- left
		self.MPText:ClearAllPoints()
		self.MPText:SetPoint("TOPRIGHT", ArcHUDFrameCombo, "TOPLEFT", 0, 0)
		self.MPText:SetJustifyH("RIGHT")
		self.MPPerc:ClearAllPoints()
		self.MPPerc:SetPoint("TOPRIGHT", self.MPText, "BOTTOMRIGHT", 0, 0)
		self.MPPerc:SetJustifyH("RIGHT")
	else
		-- right
		self.MPText:ClearAllPoints()
		self.MPText:SetPoint("TOPLEFT", ArcHUDFrameCombo, "TOPRIGHT", 0, 0)
		self.MPText:SetJustifyH("LEFT")
		self.MPPerc:ClearAllPoints()
		self.MPPerc:SetPoint("TOPLEFT", self.MPText, "BOTTOMLEFT", 0, 0)
		self.MPPerc:SetJustifyH("LEFT")
	end
	
	local HealthMod = ArcHUD:GetModule("Health")
	if HealthMod.db.profile.SwapHealthPowerText ~= self.db.profile.SwapHealthPowerText then
		HealthMod.db.profile.SwapHealthPowerText = self.db.profile.SwapHealthPowerText
		ArcHUD:SendMessage("ARCHUD_MODULE_UPDATE", "Health")
	end

	self:UpdateColor(UnitPowerType(self.unit))
	self:UpdatePowerBar()
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
		self.MPText:SetText(self.parent:fint(UnitPower(self.unit)).."/"..self.parent:fint(UnitPowerMax(self.unit)))
		self.MPPerc:SetText(floor((UnitPower(self.unit)/UnitPowerMax(self.unit))*100).."%")
	end

	-- Register the events we will use
	self:RegisterUnitEvent("UNIT_POWER_UPDATE", "UpdatePowerEvent")
	self:RegisterUnitEvent("UNIT_MAXPOWER", "UpdatePowerEvent")
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "UpdatePowerType")
	self:RegisterEvent("PLAYER_ALIVE", "UpdatePowerEvent")
	self:RegisterEvent("PLAYER_LEVEL_UP")

	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
end

----------------------------------------------
-- PLAYER_LEVEL_UP
----------------------------------------------
function module:PLAYER_LEVEL_UP()
	self.f:SetMax(UnitPowerMax(self.unit))
end

----------------------------------------------
-- Update Power (timer)
----------------------------------------------
function module:UpdatePowerBar()
	if (not UnitIsGhost(self.unit)) then
		local power = UnitPower(self.unit)
		local maxPower = UnitPowerMax(self.unit)
		
		if (maxPower > 0) then
			if self.db.profile.ShowTextMax then
				self.MPText:SetText(self.parent:fint(power).."/"..self.parent:fint(maxPower))
			else
				self.MPText:SetText(self.parent:fint(power))
			end
			self.MPPerc:SetText(floor((power/maxPower)*100).."%")
		else
			self.MPText:SetText("")
			self.MPPerc:SetText("")
		end
		
		self.f:SetMax(maxPower)
		self.f:SetValue(power)
			
		if (power == maxPower or power == 0) then
			self:StopTimer("UpdatePowerBar")
		end
	end
end

----------------------------------------------
-- Update Power (event)
----------------------------------------------
function module:UpdatePowerEvent(event, arg1)
	if (arg1 == self.unit) then
		local power = UnitPower(self.unit)
		local maxPower = UnitPowerMax(self.unit)
		
		if(UnitIsGhost(self.unit) or (UnitIsDead(self.unit) and event == "PLAYER_ALIVE")) then
			self.f:GhostMode(true, self.unit)
		else
			self.f:GhostMode(false, self.unit)
			
			if (maxPower > 0) then
				if self.db.profile.ShowTextMax then
					self.MPText:SetText(self.parent:fint(power).."/"..self.parent:fint(maxPower))
				else
					self.MPText:SetText(self.parent:fint(power))
				end
				self.MPPerc:SetText(floor((power/maxPower)*100).."%")
			else
				self.MPText:SetText("")
				self.MPPerc:SetText("")
			end

			self.f:SetMax(maxPower)
			self.f:SetValue(power)
		end
		
		if (power == maxPower or power == 0) then
			self:StopTimer("UpdatePowerBar")
		else
			self:StartTimer("UpdatePowerBar")
		end
	end
end

function module:UpdatePowerType(event, arg1)
	if (arg1 == self.unit) then
		if(event == "UNIT_DISPLAYPOWER") then
			self:UpdateColor(UnitPowerType(self.unit))
			
			local info = self:GetPowerBarColorText(UnitPowerType(self.unit))
			self.MPText:SetVertexColor(info.r, info.g, info.b)
		end
		self:UpdatePowerBar()
	end
end

