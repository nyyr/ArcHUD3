local module = ArcHUD:NewModule("EnergyTick")
local _, _, rev = string.find("$Rev: 102 $", "([0-9]+)")
module.version = "2.1." .. rev
module.unit = "player"
module.defaults = {
	Enabled = false,
	Outline = true,
	ShowInCombat = false,
	ShowInStealth = false,
	ColorMode = "default",
	Color = PowerBarColor[3],
	Side = 2,
	Level = 3,
}
module.localized = true
module.options = {
	{name = "ShowInCombat", text = "SHOWINCOMBAT", tooltip = "SHOWINCOMBAT"},
	{name = "ShowInStealth", text = "SHOWINSTEALTH", tooltip = "SHOWINSTEALTH"},
	attach = true,
}

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)

	-- Register timers
	self:RegisterMetro(self.name .. "Casting", module.Casting, 0.01, self)
	self:RegisterMetro(self.name .. "DoTick", module.DoTick, 0.1, self)
end

function module:Update()
	self:UpdateColor()
end

function module:Enable()
	self.f.fadeIn = 0.25
	self.f.fadeOut = 2
	self.f:SetMax(2000)

	self.f.dirty = true

	self.lastTick = GetTime()
	self.stealthed = false
	self.tick = false

	-- Register the events we will use
	self:RegisterEvent("UNIT_ENERGY")
	self:RegisterEvent("UNIT_DISPLAYPOWER")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF",			"UpdateStealth")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS",	"UpdateStealth")

	-- Activate the timers
	self:StartMetro(self.name .. "Casting")
	self:StartMetro(self.name .. "Alpha")
	self:StartMetro(self.name .. "Fade")
	self:StartMetro(self.name .. "DoTick")

	self.f:Show()
end

function module:Casting()
	if ( self.f.casting == nil ) then
		self.casting = 0 end
	if ( self.spellstart == nil ) then
		self.spellstart = GetTime() end

	if ( self.f.casting == 1) then
		local status = (GetTime() - self.spellstart)*1000
		local time_remaining = self.f.maxValue - status

		if ( status > self.f.maxValue ) then
			status = self.f.maxValue
		end

		self.f:SetValue(status)
	end
end

function module:UNIT_ENERGY()
	if(arg1 ~= self.unit) then return end

	if (not self.oldEnergy) then
		self.oldEnergy = UnitMana(self.unit)
	end

	self.tick = false
	if (UnitMana(self.unit) < self.oldEnergy) then
		self.oldEnergy = UnitMana(self.unit)
	elseif(UnitMana(self.unit) > self.oldEnergy) then
		if(UnitMana(self.unit) < UnitManaMax(self.unit)) then
			self.tick = true
		end
	end
end

function module:UNIT_DISPLAYPOWER()
	if(arg1 ~= self.unit) then return end

	if(UnitPowerType(self.unit) == 3) then
		self.oldEnergy = UnitManaMax(self.unit)
	end
end

function module:DoTick()
	if(self.tick or (self.db.profile.ShowInCombat and self.parent.PlayerIsInCombat) or (self.db.profile.ShowInStealth and self.stealthed)) then
		if(self.tick or not self.tick and self.lastTick + 2 < GetTime()) then
			self:Debug(1, "start = ".. (self.f.startValue or "nil") ..", max = ".. (self.f.maxValue or "nil") ..", spellstart = ".. (self.spellstart or "nil"))
			self.f.casting = 1
			self.f:SetValue(0)
			self.spellstart = GetTime()
			self:Debug(1, "start = ".. (self.f.startValue or "nil") ..", max = ".. (self.f.maxValue or "nil") ..", spellstart = ".. (self.spellstart or "nil"))
			if(self.parent.db.profile.FadeIC > self.parent.db.profile.FadeOOC) then
				self.f:SetRingAlpha(self.parent.db.profile.FadeIC)
			else
				self.f:SetRingAlpha(self.parent.db.profile.FadeOOC)
			end

			self.lastTick = GetTime()
			self.tick = false
		end
	else
		-- UnitMana(self.unit) == UnitManaMax(self.unit)
		self.f.casting = 0
		self.f:SetRingAlpha(0)
	end
end

function module:UpdateStealth(arg1)
	if(arg1 == self.L["You gain Prowl."] or arg1 == self.L["You gain Stealth."]) then
		self.stealthed = true
	elseif(arg1 == self.L["Prowl fades from you."] or arg1 == self.L["Stealth fades from you."]) then
		self.stealthed = false
	end
end

function module:PLAYER_ENTERING_WORLD()
	self.stealthed = false
end
