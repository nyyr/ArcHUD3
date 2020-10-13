local moduleName = "FocusCasting"
local module = ArcHUD:NewModule(moduleName)
module.version = "2.1 (8456d64)"

module.unit = "focus"
module.noAutoAlpha = true

module.defaults = {
	profile = {
		Enabled = false,
		Outline = true,
		ShowSpell = true,
		ShowTime = true,
		ColorFriend = {r = 0, g = 1, b = 0},
		ColorFoe = {r = 1, g = 0, b = 0},
		Side = 1,
		Level = 4,
		IndicateInterruptible = true,
		ColorInterruptible = {r = 1, g = 1, b = 0},
	}
}
module.options = {
	{name = "ShowSpell", text = "SHOWSPELL", tooltip = "SHOWSPELL"},
	{name = "ShowTime", text = "SHOWTIME", tooltip = "SHOWTIME"},
	{name = "IndicateInterruptible", text = "INDINTERRUPT", tooltip = "INDINTERRUPT"},
	hasfriendfoe = true,
	attach = true,
}
module.localized = true

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)

	self.Text = self:CreateFontString(self.f, "BACKGROUND", {175, 14}, 10, "LEFT", {1.0, 1.0, 1.0}, {"TOP", "ArcHUDFrameCombo", "BOTTOM", 0, -26})
	self.Time = self:CreateFontString(self.f, "BACKGROUND", {40, 14}, 10, "RIGHT", {1.0, 1.0, 1.0}, {"TOPLEFT", self.Text, "TOPRIGHT", -56, 0})
	
	self:CreateStandardModuleOptions(42)
	
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
end

local function Focus_Casting(frame, elapsed)
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
		if(time_remaining == 0) then
			self:SpellcastStop(self.unit)
		end
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
	self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
	self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")

	self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", 			"SpellcastStop")
	self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", 	"SpellcastChannelStop")

	self:RegisterEvent("PLAYER_FOCUS_CHANGED")

	-- Add update hook
	self.f.UpdateHook = Focus_Casting
	
	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
end

function module:PLAYER_FOCUS_CHANGED()
	local casting = UnitCastingInfo(self.unit)
	local channel = UnitChannelInfo(self.unit)
	if(casting) then
		self:UNIT_SPELLCAST_START("PLAYER_FOCUS_CHANGED", self.unit)
	elseif(channel) then
		self:UNIT_SPELLCAST_CHANNEL_START("PLAYER_FOCUS_CHANGED", self.unit)
	else
		self:SpellcastStop("PLAYER_FOCUS_CHANGED", self.unit, true)
		self:SpellcastChannelStop("PLAYER_FOCUS_CHANGED", self.unit, true)
	end
end

function module:UNIT_SPELLCAST_START(event, arg1)
	if (arg1 == self.unit) then
		--self:Debug(3, "FocusCasting:UNIT_SPELLCAST_START("..tostring(arg1)..")")
		local spell, displayName, icon, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(self.unit)
		if (spell) then 
			if(UnitIsFriend("player", self.unit)) then
				self:UpdateColor(1)
				self.Text:SetTextColor(1, 1, 1)
				self.Time:SetTextColor(1, 1, 1)
			else
				self:UpdateColor(2)
				if (self.db.profile.IndicateInterruptible and not notInterruptible) then
					self.f:UpdateColor(self.db.profile.ColorInterruptible)
					self.f.BG:UpdateColor(self.db.profile.ColorInterruptible)
					self.Text:SetTextColor(1, 1, 0)
					self.Time:SetTextColor(1, 1, 0)
				else
					self.Text:SetTextColor(1, 0, 0)
					self.Time:SetTextColor(1, 0, 0)
				end
			end
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
		end
	end
end

function module:UNIT_SPELLCAST_CHANNEL_START(event, arg1)
	if (arg1 == self.unit) then
		--self:Debug(3, "FocusCasting:UNIT_SPELLCAST_CHANNEL_START("..tostring(arg1)..")")
		local spell, displayName, icon, startTime, endTime, _, notInterruptible = UnitChannelInfo(self.unit)
		if (spell) then 
			if(UnitIsFriend("player", self.unit)) then
				self:UpdateColor(1)
				self.Text:SetTextColor(1, 1, 1)
				self.Time:SetTextColor(1, 1, 1)
			else
				self:UpdateColor(2)
				if (self.db.profile.IndicateInterruptible and not notInterruptible) then
					self.f:UpdateColor(self.db.profile.ColorInterruptible)
					self.f.BG:UpdateColor(self.db.profile.ColorInterruptible)
					self.Text:SetTextColor(1, 1, 0)
					self.Time:SetTextColor(1, 1, 0)
				else
					self.Text:SetTextColor(1, 0, 0)
					self.Time:SetTextColor(1, 0, 0)
				end
			end
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
		end
	end
end

function module:UNIT_SPELLCAST_CHANNEL_UPDATE(event, arg1)
	if (arg1 == self.unit) then
		--self:Debug(3, "FocusCasting:UNIT_SPELLCAST_CHANNEL_UPDATE("..tostring(arg1)..")")
		local spell, displayName, icon, startTime, endTime = UnitChannelInfo(arg1)
		if (spell == nil) then
			-- might be due to lag
			-- SpellcastChannelStop resets all
			self:SpellcastChannelStop(event, arg1, true)
			return
		end
		self.f:SetValue(self.f.startValue - (startTime - self.spellstart))
		self.spellstart = startTime
	end
end

function module:UNIT_SPELLCAST_DELAYED(event, arg1)
	if (arg1 == self.unit) then
		--self:Debug(3, "FocusCasting:UNIT_SPELLCAST_DELAYED("..tostring(arg1)..")")
		local spell, displayName, icon, startTime, endTime = UnitCastingInfo(arg1)
		if (spell == nil) then
			-- might be due to lag
			-- SpellcastChannelStop resets all
			self:SpellcastChannelStop(event, arg1, true)
			return
		end
		self.f:SetMax(endTime - self.spellstart)
	end
end

function module:UNIT_SPELLCAST_INTERRUPTIBLE(event, arg1)
	if ((arg1 == self.unit) and self.db.profile.IndicateInterruptible) then
		--self:Debug(3, "FocusCasting:UNIT_SPELLCAST_INTERRUPTIBLE("..tostring(arg1)..")")
		self.f.BG:UpdateColor(self.db.profile.ColorInterruptible)
		self.Text:SetTextColor(1, 1, 0)
		self.Time:SetTextColor(1, 1, 0)
	end
end

function module:UNIT_SPELLCAST_NOT_INTERRUPTIBLE(event, arg1)
	if ((arg1 == self.unit) and self.db.profile.IndicateInterruptible) then
		--self:Debug(3, "FocusCasting:UNIT_SPELLCAST_NOT_INTERRUPTIBLE("..tostring(arg1)..")")
		self.f.BG:UpdateColor({r = 0, g = 0, b = 0})
		self.Text:SetTextColor(1, 0, 0)
		self.Time:SetTextColor(1, 0, 0)
	end
end

function module:SpellcastStop(event, arg1, force)
	if ((arg1 == self.unit) and ((self.f.casting == 1 and self.channeling == 0) or (force == true))) then
		--self:Debug(3, "FocusCasting:SpellcastStop("..tostring(arg1)..", "..tostring(force)..")")
		self.f:SetValue(self.f.maxValue)
		self.f.casting = 0
		self.f:SetRingAlpha(0)
		self.f.BG:UpdateColor({r = 0, g = 0, b = 0})
		self.Time:SetText("")
	end
end

function module:SpellcastChannelStop(event, arg1, force)
	if ((arg1 == self.unit) and ((self.f.casting == 1) or (force == true))) then
		--self:Debug(3, "FocusCasting:SpellcastChannelStop("..tostring(arg1)..", "..tostring(force)..")")
		self.f.casting = 0
		self.channeling = 0
		self.Text:SetText("")
		self.Time:SetText("")
		self.f:SetValue(0)
		self.f:SetRingAlpha(0)
		self.f.BG:UpdateColor({r = 0, g = 0, b = 0})
	end
end
