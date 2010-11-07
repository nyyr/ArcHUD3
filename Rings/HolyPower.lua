local module = ArcHUD:NewModule("HolyPower")
local _, _, rev = string.find("$Rev: 24 $", "([0-9]+)")
module.version = "1.0 (r" .. rev .. ")"

module.unit = "player"
module.noAutoAlpha = true

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		Flash = true,
		Side = 2,
		Level = 2,
		Color = {r = 1, g = 1, b = 0.5},
	}
}
module.options = {
	{name = "Flash", text = "FLASH", tooltip = "FLASH"},
	nocolor = true,
	attach = true,
}
module.localized = true

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)
	
	self.f:SetMax(MAX_HOLY_POWER)
	self.f:SetValue(0)

	-- Override Update timer
	self.parent:RegisterMetro(self.name .. "Update", self.UpdateAlpha, 0.05, self.f)
	
	self:CreateStandardModuleOptions(45)
end

function module:Update()
	self.Flash = self.db.profile.Flash
end

function module:OnModuleEnable()
	local _, class = UnitClass("player")
	if (class ~= "PALADIN") then return end

	self.f.dirty = true
	self.f.fadeIn = 0.25

	self.f:UpdateColor(self.db.profile.Color)
	self.f:SetValue(UnitPower(self.unit, SPELL_POWER_HOLY_POWER))

	-- Register the events we will use
	self:RegisterEvent("UNIT_POWER",	"UpdatePower")

	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
end

function module:UpdateAlpha(arg1)
	if(self.pulse) then
		self.alphaPulse = self.alphaPulse + arg1/2
		local amt = math.sin(self.alphaPulse * self.twoPi) * 0.25 + 0.25
		self:UpdateColor({["r"] = module.db.profile.Color.r, ["g"] = module.db.profile.Color.g, ["b"] = amt})
	end
end

function module:UpdatePower(event, arg1, arg2)
	self:Debug(3, "UpdateComboPoints("..tostring(event)..", "..tostring(arg1)..")")
	if (event == "UNIT_POWER" and arg1 == self.unit and arg2 == "HOLY_POWER") then
		local num = UnitPower(self.unit, SPELL_POWER_HOLY_POWER)
		self.f:SetValue(num)
		
		if(num < 3 and num >= 0) then
			self.f.pulse = false
			self.f.alphaPulse = 0
			self.f:UpdateColor(self.db.profile.Color)
		else
			if(self.Flash) then
				self.f.pulse = true
			else
				self.f.pulse = false
			end
		end
		
		if(num > 0) then
			if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
			else
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
			end
		else
			self.f:SetRingAlpha(0)
		end
	end
end

function module:RemoveOldCP()
	self.parent:StopMetro(self.name .. "RemoveOldCP")
	self.RemoveOldCP_started = false
	self.oldPoints = 0
	self.f:SetRingAlpha(0)
end
