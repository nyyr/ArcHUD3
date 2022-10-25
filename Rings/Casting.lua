local moduleName = "Casting"
local module = ArcHUD:NewModule(moduleName)
module.version = "2.2 (@file-abbreviated-hash@)"

module.unit = "player"
module.noAutoAlpha = true

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		ShowSpell = true,
		ShowTime = true,
		IndLatency = false,
		IndSpellQueue = true,
		Side = 2,
		Level = -1,
	}
}
module.options = {
	{name = "ShowSpell", text = "SHOWSPELL", tooltip = "SHOWSPELL"},
	{name = "ShowTime", text = "SHOWTIME", tooltip = "SHOWTIME"},
	{name = "IndLatency", text = "INDLATENCY", tooltip = "INDLATENCY"},
	{name = "IndSpellQueue", text = "INDSPELLQ", tooltip = "INDSPELLQ"},
	nocolor = true,
	attach = true,
}
module.localized = true
module.disableEvents = {
	{frame = "PlayerCastingBarFrame", hide = TRUE, events = {"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_DELAYED",
														"UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED",
														"UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE",
														"UNIT_SPELLCAST_CHANNEL_STOP", "PLAYER_ENTERING_WORLD"}},
}

local UnitCastingInfo = ArcHUD.UnitCastingInfo
local UnitChannelInfo = ArcHUD.UnitChannelInfo

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)

	self.Text = self:CreateFontString(self.f, "BACKGROUND", {175, 14}, 10, "LEFT", {1.0, 1.0, 1.0}, {"TOP", "ArcHUDFrameCombo", "BOTTOM", 0, -14})
	self.Time = self:CreateFontString(self.f, "BACKGROUND", {40, 14}, 10, "RIGHT", {1.0, 1.0, 1.0}, {"TOPLEFT", self.Text, "TOPRIGHT", -56, 0})
	
	self:CreateStandardModuleOptions(15)
	
	self.f.casting = 0
	self.channeling = 0
	self.spellstart = GetTime()*1000
end

function module:OnModuleUpdate()
	if(self.db.profile.ShowSpell) then
		self.Text:Show()
	else
		self.Text:Hide()
	end

	if(self.db.profile.ShowTime) then
		self.Time:Show()
	else
		self.Time:Hide()
	end
	
	-- reset latency indicator
	self.f:SetSpark(-1, true)
end

local function Player_Casting(frame, elapsed)
	local self = frame.module
	if (self.f.casting == 1) then
		local status = (GetTime()*1000 - self.spellstart)
		local time_remaining = self.f.maxValue - status

		if ( self.channeling == 1) then
			status = time_remaining
		end

		if ( status > self.f.maxValue ) then
			status = self.f.maxValue
		end

		self.f:SetValue(status)
		self.f:SetSpark(status)

		if ( time_remaining < 0 ) then
			time_remaining = 0
		end

		local texttime = ""
		if((time_remaining/1000) > 60) then
			local minutes = math.floor(time_remaining/60000)
			local seconds = math.floor(((time_remaining/60000) - minutes) * 60)
			if(seconds < 10) then
				texttime = minutes..":0"..seconds
			else
				texttime = minutes..":"..seconds
			end
		else
			local intlength = string.len(string.format("%u",time_remaining/1000))
			texttime = strsub(string.format("%f",time_remaining/1000),1,intlength+2)
		end
		self.Time:SetText(texttime)
	end
end

function module:OnModuleEnable()
	self.f.fadeIn = 0.25
	self.f.fadeOut = 2

	self.f.dirty = true

	-- Register the events we will use
	self:RegisterUnitEvent("UNIT_SPELLCAST_START")
	self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED")
	self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START")
	self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")

	self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", 			"SpellcastStop")
	self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", 		"SpellcastFailed")
	self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", 	"SpellcastInterrupt")
	self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", 	"SpellcastChannelStop")

	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", 		"SpellcastSuccess")
	
	-- Add update hook
	self.f.UpdateHook = Player_Casting
	
	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
end

function module:UNIT_SPELLCAST_START(event, arg1)
	if (arg1 == self.unit) then
		local spell, displayName, icon, startTime, endTime = UnitCastingInfo(self.unit)
		--self:Debug(3, "Casting:UNIT_SPELLCAST_START("..tostring(arg1).."): "..tostring(spell)..", "..tostring(startTime)..", "..tostring(endTime - startTime))
		if (spell) then
			self.f:UpdateColor({["r"] = 1.0, ["g"] = 0.7, ["b"] = 0})
			self.Text:SetText(displayName)
			self.channeling = 0
			self.f.casting = 1
			self.f:SetMax(endTime - startTime)
			self.spellstart = startTime
			if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
			else
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
			end
			
			-- latency indicator
			local sparkoffset = 0
			if (self.db.profile.IndLatency) then
				local _, _, _, latencyWorld = GetNetStats()
				sparkoffset = sparkoffset + latencyWorld
			end
			if (self.db.profile.IndSpellQueue) then
				sparkoffset = sparkoffset + GetMaxSpellStartRecoveryOffset()
			end
			-- consider GCD?
			local sparkval = self.f.maxValue - sparkoffset
			if (sparkoffset > 0 and sparkval > 0) then
				self.f:SetSpark(sparkval, true, 1.5)
			end
		end
	end
end

function module:UNIT_SPELLCAST_CHANNEL_START(event, arg1)
	if(arg1 == self.unit) then
		local spell, displayName, icon, startTime, endTime = UnitChannelInfo(self.unit)
		if (spell) then
			self.f:UpdateColor({["r"] = 0.3, ["g"] = 0.3, ["b"] = 1.0})
			self.Text:SetText(displayName)
			self.channeling = 1
			self.f.casting = 1
			self.f:SetMax(endTime - startTime)
			self.f:SetValue(endTime - startTime)
			self.spellstart = startTime
			if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
			else
				self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
			end
			
			if (self.db.profile.IndLatency) then
				local _, _, _, latencyWorld = GetNetStats()
				local sparkval = latencyWorld
				-- consider GCD?
				if (sparkval < self.f.maxValue) then
					self.f:SetSpark(sparkval, true, 1.5)
				end
			end
		end
	end
end

function module:UNIT_SPELLCAST_CHANNEL_UPDATE(event, arg1)
	if(arg1 == self.unit) then
		local spell, displayName, icon, startTime, endTime = UnitChannelInfo(arg1)
		if (spell == nil) then
			-- might be due to lag
			-- SpellcastChannelStop resets all
			self:SpellcastChannelStop(event, arg1)
			return
		end
		self.f:SetValue(self.f.startValue - (startTime - self.spellstart))
		self.spellstart = startTime
	end
end

function module:UNIT_SPELLCAST_DELAYED(event, arg1)
	if(arg1 == self.unit) then
		local spell, displayName, icon, startTime, endTime = UnitCastingInfo(arg1)
		if (spell == nil) then
			-- might be due to lag
			-- SpellcastChannelStop resets all
			self:SpellcastChannelStop(event, arg1)
			return
		end
		self.f:SetMax(endTime - self.spellstart)
	end
end

function module:SpellcastStop(event, arg1)
	if(arg1 == self.unit and self.f.casting == 1 and self.channeling == 0) then
		self.f:SetValue(self.f.maxValue)
		self.f.casting = 0
		if(self.spellStatus) then
			if(self.spellStatus == "success") then
				self.f:UpdateColor({["r"] = 0, ["g"] = 1.0, ["b"] = 0})
			elseif(self.spellStatus == "failed") then
				self.f:UpdateColor({["r"] = 1.0, ["g"] = 0, ["b"] = 0})
				self.Text:SetText(FAILED)
			elseif(self.spellStatus == "interrupted") then
				self.f:UpdateColor({["r"] = 1.0, ["g"] = 0, ["b"] = 0})
				self.Text:SetText(INTERRUPTED)
			end
		else
			self.f:UpdateColor({["r"] = 1.0, ["g"] = 0, ["b"] = 0})
		end
		self.spellStatus = nil
		self.Time:SetText("")
		self.f:SetRingAlpha(0)
	end
end

function module:SpellcastChannelStop(event, arg1)
	if(arg1 == self.unit and self.f.casting == 1) then
		self.f.casting = 0
		self.channeling = 0
		self.Text:SetText("")
		self.f:SetValue(0)

		self.spellStatus = nil
		self.Time:SetText("")
		self.f:SetRingAlpha(0)
	end
end

function module:SpellcastSuccess()
	self.spellStatus = "success"
end

function module:SpellcastFailed()
	self.spellStatus = "failed"
end

function module:SpellcastInterrupt()
	self.spellStatus = "interrupted"
end
