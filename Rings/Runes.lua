local module = ArcHUD:NewModule("Runes")
module.version = "4.0 (19d7aa8)"

module.unit = "player"
module.noAutoAlpha = nil

local shadingFactor = 0.4

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		Flash = true,
		Side = 2,
		Level = 1,
		ShowSeparators = true,
		SortRunes = true,
		Color = {r = 0.3, g = 0.4, b = 0.8},
		PartialColor = {r = 0.3 * shadingFactor, g = 0.4 * shadingFactor, b = 0.8 * shadingFactor},
		-- PartialColor = {r = 0, g = 0.5, b = 0.6},
		-- PartialColor = {r = 0, g = 1, b = 0},
		RingVisibility = 2, -- always fade out when out of combat, regardless of ring status
	}
}
module.options = {
	attach = true,
	hasseparators = true,
	{name = "SortRunes", text = "SORTRUNES", tooltip = "SORTRUNES"},
}
module.localized = true

local MAX_RUNES = 6
local MAX_RING_VALUE = 100

local RuneLastState = {
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true,
	[5] = true,
	[6] = true,
}

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)
	
	self:CreateStandardModuleOptions(55)
end

function module:OnModuleUpdate()
	local _, class = UnitClass(self.unit)
	if class ~= "DEATHKNIGHT" then return end
	
	self:UpdateRunes()

	if self.db.profile.SortRunes then
		self:UpdateRuneCooldown(arg1, arg2)
	end

	self:RefreshRuneRings()
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
		
		-- configure rune arcs
		for i=1,6 do
			self:AttachRing(self.frames[i])
			self.frames[i].linearFade = true
			self.frames[i].dirty = true
			self.frames[i].isRune = true
		end
	end

	self:RefreshRuneRings()

	-- un-register all previous events
	self:UnregisterAllEvents();
	
	-- Register the events we will use
		
	-- Runes
	self:RegisterEvent("RUNE_POWER_UPDATE", "UpdatePower")
	
	-- Unit Power
	self:RegisterUnitEvent("UNIT_POWER_UPDATE", "UpdatePower", self.unit)
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "UpdatePower", self.unit)

	-- Entering/Leaving Combat
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdatePower")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdatePower")
	
	-- Dying/Ressurecting/Insance Zoning
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdatePower")
	self:RegisterEvent("PLAYER_DEAD", "UpdatePower")
	self:RegisterEvent("PLAYER_UNGHOST", "UpdatePower")
	self:RegisterEvent("PLAYER_ALIVE", "UpdatePower")
	
	-- self:UpdateRunes()
	
	-- Activate ring timers
	self:StartRingTimers()
end

function module:UpdateRunes()
	-- update all runes
	if (self.frames) then
		for i=1,MAX_RUNES do
			local start, duration, runeReady = GetRuneCooldown(i)
			if not runeReady and start then
				self.frames[i]:UpdateColor(self.db.profile.PartialColor)
			else
				self.frames[i]:UpdateColor(self.db.profile.Color)
			end	
		end
	end
end

function module:GetRuneOrder() 

	local RemainingTime = {}
	local RuneOrder = {}
	local issorted = false
	local unsortedsize = MAX_RUNES-1
		
	for i = 1, MAX_RUNES do
		local start, duration, runeReady = GetRuneCooldown(i)
		if duration and start then 
			RemainingTime[i] = duration - start
			RuneOrder [i] = i
		end	
	end
	
	if RuneOrder == {} or RemainingTime == {} then 
		return 0
	end	
	
	while not issorted and unsortedsize ~= 0 do 
		issorted = true
		for i = 1, unsortedsize do 
			if RemainingTime[i] > RemainingTime[i+1] then 
				local tempval = RemainingTime[i];
				RemainingTime[i] = RemainingTime[i+1]
				RemainingTime[i+1] = tempval
				
				local tempval = RuneOrder[i];
				RuneOrder[i] = RuneOrder[i+1]
				RuneOrder[i+1] = tempval
				
				issorted = false
			end	
		end
		
		unsortedsize = unsortedsize - 1
		
	end 

	return (RuneOrder or 0)
	
end

function module:UpdateSortedRuneCooldown(runeIndex)

	for i=1,MAX_RUNES do

		local RuneOrder = self:GetRuneOrder()
		runeIndex = RuneOrder[i]
		
		if runeIndex then
			local start, duration, runeReady = GetRuneCooldown(runeIndex)
			
			if not runeReady then
				if start then
					self.frames[i]:UpdateColor(self.db.profile.PartialColor)
					self.frames[i]:SetValue(MAX_RING_VALUE, duration, start, 0)
					RuneLastState[i] = false
				end
			else
				self.frames[i]:UpdateColor(self.db.profile.Color)
				self.frames[i]:SetValue(MAX_RING_VALUE, 0)
				if RuneLastState[i] == false then 
					self.frames[i]:DoShine()
				end
				RuneLastState[i] = true
			end
		end
	end

end

function module:UpdateUnsortedRuneCooldown(runeIndex)

	-- FIXME: This method is also called with runeIndex = 'player'
	runeIndex = tonumber(runeIndex)

	if not runeIndex then 
		return
	end

	local start, duration, runeReady = GetRuneCooldown(runeIndex)
	
	--self:Debug(1, "R %s, S %s, D %s, RR %s", tostring(runeIndex), tostring(start), tostring(duration), tostring(runeReady))

	if not runeReady then
		if start then
			self.frames[runeIndex]:UpdateColor(self.db.profile.PartialColor)
			self.frames[runeIndex]:SetValue(MAX_RING_VALUE, duration, start, 0)
			RuneLastState[runeIndex] = false
		end
	else
		self.frames[runeIndex]:UpdateColor(self.db.profile.Color)
		self.frames[runeIndex]:SetValue(MAX_RING_VALUE, 0)
		if RuneLastState[runeIndex] == false then
			self.frames[runeIndex]:DoShine()
		end	
		RuneLastState[runeIndex] = true
	end

end

function module:UpdateRuneCooldown(runeIndex, isEnergize)

	if self.db.profile.SortRunes then
		-- update and sort all runes
		self:UpdateSortedRuneCooldown()
	else
		if not runeIndex then
			-- update all runes
			for i=1,MAX_RUNES do
				self:UpdateUnsortedRuneCooldown(i)
			end
		else
			-- just update the current rune
			self:UpdateUnsortedRuneCooldown(runeIndex)
		end	
	end
		
end

function module:UpdatePower(event, arg1, arg2)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UpdateRunes()
		self:UpdateRuneCooldown(arg1, arg2)
	elseif event == "RUNE_POWER_UPDATE" then
		self:UpdateRuneCooldown(arg1, arg2)
	else
		self:UpdateRuneCooldown(arg1, arg2)
	end
end

function module:RefreshRuneRings()
	if (self.frames) then
		-- refresh sparks & shine

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

		for i=1,6 do
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
			--self:Debug(1, "Rune %d set up (angle %f-%f)", i, angles[i].s, angles[i].e)
		end
		
		-- adjust shine for first and last rune
		self.frames[1]:SetShineAngle(angles[1].s + 12)
		self.frames[6]:SetShineAngle(angles[6].e - 12)
	end
end