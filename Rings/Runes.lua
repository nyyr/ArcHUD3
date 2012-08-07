local module = ArcHUD:NewModule("Runes")
local _, _, rev = string.find("$Rev$", "([0-9]+)")
module.version = "2.0 (r" .. rev .. ")"

module.unit = "player"
module.noAutoAlpha = nil
module.noAutoAlpha = nil

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		Flash = true,
		Side = 2,
		Level = 1,
		ColorBloodRune  = {r = 0.7, g = 0,   b = 0},
		ColorFrostRune  = {r = 0,   g = 0.6, b = 0.7},
		ColorUnholyRune = {r = 0,   g = 0.6, b = 0},
		ColorDeathRune  = {r = 0.8, g = 0.1, b = 1},
		--RingVisibility = 2, -- always fade out when out of combat, regardless of ring status
	}
}
module.options = {
	--{name = "Flash", text = "FLASH", tooltip = "FLASH"},
	attach = true,
	customcolors = {
		{name = "ColorBloodRune", text = "COLORBLOODRUNE"},
		{name = "ColorFrostRune", text = "COLORFROSTRUNE"},
		{name = "ColorUnholyRune", text = "COLORUNHOLYRUNE"},
		{name = "ColorDeathRune", text = "COLORDEATHRUNE"},
	}
}
module.localized = true

local MAX_RUNES = 6
local MAX_RING_VALUE = 100

local RUNETYPE_BLOOD = 1
local RUNETYPE_UNHOLY = 2
local RUNETYPE_FROST = 3
local RUNETYPE_DEATH = 4

local runeColors = {
	[RUNETYPE_BLOOD]  = {r = 0.7, g = 0,   b = 0},
	[RUNETYPE_UNHOLY] = {r = 0,   g = 0.6, b = 0},
	[RUNETYPE_FROST]  = {r = 0,   g = 0.6, b = 0.7},
	[RUNETYPE_DEATH]  = {r = 0.8, g = 0.1, b = 1},
}

local colorByIndex = {
	[1] = runeColors[RUNETYPE_BLOOD],
	[2] = runeColors[RUNETYPE_BLOOD],
	[3] = runeColors[RUNETYPE_UNHOLY],
	[4] = runeColors[RUNETYPE_UNHOLY],
	[5] = runeColors[RUNETYPE_FROST],
	[6] = runeColors[RUNETYPE_FROST],
}

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)
	
	self:CreateStandardModuleOptions(55)
end

function module:OnModuleUpdate()
	runeColors[RUNETYPE_BLOOD] = self.db.profile.ColorBloodRune
	runeColors[RUNETYPE_FROST] = self.db.profile.ColorFrostRune
	runeColors[RUNETYPE_UNHOLY] = self.db.profile.ColorUnholyRune
	runeColors[RUNETYPE_DEATH] = self.db.profile.ColorDeathRune

	if (self.frames) then
		self:UpdateRunes()
	end
end

function module:OnModuleEnable()
	local _, class = UnitClass(self.unit)
	if (class ~= "DEATHKNIGHT") then return end
	
	if (not self.frames) then
		-- create frame for each rune
		self.frames = {}
		self.frames[1] = self.f
		for i=2,6 do
			self.frames[i] = self:CreateRing(false, ArcHUDFrame)
			self.frames[i]:SetAlpha(0)
		end
		
		-- set angles
		local angles = {
			[1] = { e = 180, s = 135 },
			[2] = { e = 135, s = 112 },
			[3] = { e = 112, s = 90 },
		}
		for i=4,6 do
			angles[i] = {
				e = 180 - angles[3-math.fmod(i-1,3)].s,
				s = 180 - angles[3-math.fmod(i-1,3)].e,
			}
		end
		
		-- configure rune arcs
		for i=1,6 do
			self:AttachRing(self.frames[i])
			if i <= 1 then
				self.frames[i].inverseFill = true
			end
			self.frames[i].linearFade = true
			self.frames[i]:SetEndAngle(angles[i].e)
			self.frames[i]:SetStartAngle(angles[i].s)
			self.frames[i]:SetShineAngle((angles[i].e + angles[i].s)/2)
			self.frames[i]:SetMax(MAX_RING_VALUE)
			self.frames[i]:SetValue(MAX_RING_VALUE, 0)
			if (i > 1) then
				self.frames[i].sparkRed:SetVertexColor(0.5, 0.5, 0.5)
				self.frames[i]:SetSpark(99.9, true)
			end
			self.frames[i].dirty = true
			self.frames[i].isRune = true
			--self:Debug(1, "Rune %d set up (angle %f-%f)", i, angles[i].s, angles[i].e)
		end
		
		-- adjust shine for first and last rune
		self.frames[1]:SetShineAngle(angles[1].s + 12)
		self.frames[6]:SetShineAngle(angles[6].e - 12)
		
		-- reorder frost/unholy runes
		local tmpRing = self.frames[3]
		self.frames[3] = self.frames[5]
		self.frames[5] = tmpRing
		tmpRing = self.frames[4]
		self.frames[4] = self.frames[6]
		self.frames[6] = tmpRing
	end

	self:RegisterEvent("RUNE_POWER_UPDATE", "UpdatePower")
	self:RegisterEvent("RUNE_TYPE_UPDATE", "UpdatePower")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdatePower")
	
	self:UpdateRunes()
	
	-- Activate ring timers
	self:StartRingTimers()
end

function module:UpdateRunes(runeIndex)
	if (not runeIndex) then
		-- update all runes
		for i=1,MAX_RUNES do
			self:UpdateRunes(i)
		end
		return
	end
	
	local runeType = GetRuneType(runeIndex)
	
	--self:Debug(1, "R %s, RT %s", tostring(runeIndex), tostring(runeType))
	
	self.frames[runeIndex]:UpdateColor(runeColors[runeType])
end

function module:UpdateRuneCooldown(runeIndex, isEnergize)
	if (not runeIndex) then
		-- update all runes
		for i=1,MAX_RUNES do
			self:UpdateRuneCooldown(i)
		end
		return
	end
	
	local start, duration, runeReady = GetRuneCooldown(runeIndex)
	
	--self:Debug(1, "R %s, S %s, D %s, RR %s", tostring(runeIndex), tostring(start), tostring(duration), tostring(runeReady))
			
	if not runeReady then
		if start then
			self.frames[runeIndex]:SetValue(MAX_RING_VALUE, duration, start, 0)
		end
		--runeButton.energize:Stop();
	else
		self.frames[runeIndex]:SetValue(MAX_RING_VALUE, 0)
		self.frames[runeIndex]:DoShine()
	end
	
	if isEnergize  then
		--runeButton.energize:Play();
	end
end

function module:UpdatePower(event, arg1, arg2)
	if (event == "PLAYER_ENTERING_WORLD") then
		self:UpdateRunes()
	elseif (event == "RUNE_POWER_UPDATE") then
		self:UpdateRuneCooldown(arg1, arg2)
	elseif (event == "RUNE_TYPE_UPDATE") then
		self:UpdateRunes(arg1)
	end
end

