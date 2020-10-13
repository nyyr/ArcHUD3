--[[ deprecated; leaving as example for more sophisticated rings

local module = ArcHUD:NewModule("Eclipse")
module.version = "2.0 (ede58a8)"

module.unit = "player"
module.noAutoAlpha = nil

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		Flash = true,
		Side = 2,
		Level = 1,
		ColorLunar = {r = 0.5, g = 0.5, b = 1}, -- lunar
		ColorSolar = {r = 1, g = 0.5, b = 0.5}, -- solar
		--RingVisibility = 2, -- always fade out when out of combat, regardless of ring status
	}
}
module.options = {
	{name = "Flash", text = "FLASH", tooltip = "FLASH"},
	attach = true,
	customcolors = {
		{name = "ColorLunar", text = "COLORLUNAR"},
		{name = "ColorSolar", text = "COLORSOLAR"},
	}
}
module.localized = true

local ECLIPSE_MARKER_COORDS = {}
ECLIPSE_MARKER_COORDS["none"] = { 0.93, 0.99, 0.82, 0.99 }
ECLIPSE_MARKER_COORDS["sun"] = { 0.93, 1.0, 0.641, 0.82 }
ECLIPSE_MARKER_COORDS["moon"] = { 1.0, 0.93, 0.641, 0.82 }

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)
	
	self:CreateStandardModuleOptions(55)
end

function module:OnModuleUpdate()
	if self.frames then
		self.frames[1]:UpdateColor(self.db.profile.ColorLunar)
		self.frames[2]:UpdateColor(self.db.profile.ColorSolar)
	end
end

function module:OnModuleEnable()
	local _, class = UnitClass(self.unit)
	if (class ~= "DRUID") then return end
	
	if (not self.frames) then
		-- two rings, one for lunar and one for solar energy
		self.frames = {}
		self.frames[1] = self.f
		self.frames[1]:UpdateColor(self.db.profile.ColorLunar)
		self.frames[1]:SetStartAngle(90)
		self:AttachRing(self.frames[1])
		self.frames[1].sparkRed:SetVertexColor(0.5, 0.5, 0.5)
		self.frames[1]:SetSpark(0.001, true)
		
		self.frames[2] = self:CreateRing(false, ArcHUDFrame)
		self.frames[2]:SetAlpha(0)
		self.frames[2]:UpdateColor(self.db.profile.ColorSolar)
		self.frames[2]:SetEndAngle(89.999)
		self.frames[2].inverseFill = true
		self:AttachRing(self.frames[2])
		
		for i=1,2 do
			self.frames[i].dirty = true
			self.frames[i].fadeIn = 0.25
		end
	end

	-- check whether we are balanced spec'ed and in caster/moonkin form
	self:RegisterEvent("PLAYER_TALENT_UPDATE",		"CheckCurrentPower")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM",	"CheckCurrentPower")
	
	self:CheckCurrentPower()
end

function module:CheckCurrentPower()
	local spec = GetSpecialization()
	local form = GetShapeshiftFormID();
	if (spec == 1 and (form == MOONKIN_FORM or not form)) then
		if (not self.active) then
			self.active = true
		
			-- Register the events we will use
			self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdatePower")
			self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "UpdatePower", self.unit)
			self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "UpdatePower", self.unit)
			
			-- Activate ring timers
			self:StartRingTimers()
			
			self.frames[1]:Show()
			self.frames[2]:Show()
		end
		
		self:UpdatePowerRing()
		
	else
		if (self.active) then
			self.frames[1]:Hide()
			self.frames[2]:Hide()
			self.active = nil
			
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
			self:UnregisterUnitEvent("UNIT_POWER_FREQUENT")
			self:UnregisterUnitEvent("UNIT_DISPLAYPOWER")
			
			self:StopRingTimers()
		end
	end
end

function module:UpdatePowerRing()
	local maxPower = UnitPowerMax(self.unit, SPELL_POWER_ECLIPSE)
	local num = UnitPower(self.unit, SPELL_POWER_ECLIPSE)
	local f
	
	if (num < 0) then
		-- lunar power
		num = num * -1
		f = self.frames[1]
		self.frames[2]:SetValue(0)
		--self.indicator:SetTexCoord(unpack(ECLIPSE_MARKER_COORDS["moon"]))
	else
		-- solar power
		f = self.frames[2]
		self.frames[1]:SetValue(0)
		--self.indicator:SetTexCoord(unpack(ECLIPSE_MARKER_COORDS["sun"]))
	end
	
	f:SetMax(maxPower)
	f:SetValue(num)
	
	if (num < maxPower and num >= 0) then
		f:StopPulse()
	else
		if (self.db.profile.Flash) then
			f:StartPulse()
		else
			f:StopPulse()
		end
	end
end

function module:UpdatePower(event, arg1, arg2)
	if (event == "UNIT_POWER_FREQUENT") then
		if (arg1 == self.unit and arg2 == "ECLIPSE") then
			self:UpdatePowerRing()
		end
	else
		self:UpdatePowerRing()
	end
end

]]