local moduleName = "FocusCasting"
local module = ArcHUD:NewModule(moduleName)
module.version = "2.1 (@file-abbreviated-hash@)"

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

	-- Create StatusBar for Midnight (12.0.0+)
	if ArcHUD.isMidnight then
		self.statusBar = self.parent:CreateStatusBarArc(self.f, self.name)
		if self.statusBar then
			self.statusBar:Hide()
			self.f:HideAllButOutline()
		end
	end
	
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

	if (self.db.profile.Side) then
		if self.statusBar then
			self.parent:UpdateStatusBarSide(self.statusBar, self.db.profile.Side)
		end
	end
end

local function Focus_Casting(frame, elapsed)
	local self = frame.module
	if (self.f.casting == 1) then
		if ArcHUD.isMidnight then
			-- Midnight: StatusBar handles timing automatically
			-- For time text, we need to get it from the DurationObject
			-- For now, we'll skip manual updates in Midnight
			return
		else
			-- Legacy: Manual calculation
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

function module:OnModuleDisable()
	-- Clean up any active casting state
	if self.f.casting == 1 then
		self:SpellcastStop("OnModuleDisable", self.unit, true)
		self:SpellcastChannelStop("OnModuleDisable", self.unit, true)
	end

	-- Hide StatusBar in Midnight mode
	if ArcHUD.isMidnight and self.statusBar then
		self.statusBar:Hide()
	end
end

function module:PLAYER_FOCUS_CHANGED()
	local casting = UnitCastingInfo(self.unit)
	local channel = UnitChannelInfo(self.unit)
	if(casting) then
		self:UNIT_SPELLCAST_START("PLAYER_FOCUS_CHANGED", self.unit)
	elseif(channel) then
		self:UNIT_SPELLCAST_CHANNEL_START("PLAYER_FOCUS_CHANGED", self.unit)
	else
		-- Clean up any existing casting/channeling state
		self:SpellcastStop("PLAYER_FOCUS_CHANGED", self.unit, true)
		self:SpellcastChannelStop("PLAYER_FOCUS_CHANGED", self.unit, true)

		-- Ensure StatusBar is hidden when focus changes and no casting
		if ArcHUD.isMidnight and self.statusBar then
			self.statusBar:Hide()
		end
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

			if ArcHUD.isMidnight then
				-- Midnight: Use UnitCastingDuration and StatusBar SetTimerDuration
				local durationObj = UnitCastingDuration(self.unit)
				if durationObj and self.statusBar then
					-- Set up StatusBar with DurationObject
					-- Use Elapsed direction for casting (fills from 0 to max)
					local direction = Enum.StatusBarTimerDirection and Enum.StatusBarTimerDirection.ElapsedTime or nil
					local interpolation = Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.ExponentialEaseOut or nil
					self.statusBar:SetTimerDuration(durationObj, interpolation, direction)

					-- Set color based on friend/foe and interruptibility
					if(UnitIsFriend("player", self.unit)) then
						self.statusBar:SetStatusBarColor(0, 1, 0) -- Green for friendly
					else
						-- Protect against secret value boolean test (12.0.0+)
						local notInterruptibleSecret = ArcHUD.isMidnight and issecretvalue and issecretvalue(notInterruptible)
						if (self.db.profile.IndicateInterruptible and not notInterruptibleSecret and not notInterruptible) then
							self.statusBar:SetStatusBarColor(1, 1, 0) -- Yellow for interruptible
						else
							self.statusBar:SetStatusBarColor(1, 0, 0) -- Red for non-interruptible
						end
					end

					self.statusBar:Show()
					-- Keep original ring empty in Midnight
					self.f:SetMax(1)
					self.f:SetValue(0)
				end
			else
				-- Legacy: Manual calculation
				self.f:SetMax(endTime - startTime)
				self.spellstart = startTime
			end

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

			if ArcHUD.isMidnight then
				-- Midnight: Use UnitChannelDuration and StatusBar SetTimerDuration
				local durationObj = UnitChannelDuration(self.unit)
				if durationObj and self.statusBar then
					-- Set up StatusBar with DurationObject
					-- Use Remaining direction for channeling (drains from max to 0)
					local direction = Enum.StatusBarTimerDirection and Enum.StatusBarTimerDirection.RemainingTime or nil
					local interpolation = Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.ExponentialEaseOut or nil
					self.statusBar:SetTimerDuration(durationObj, interpolation, direction)

					-- Set color based on friend/foe and interruptibility
					if(UnitIsFriend("player", self.unit)) then
						self.statusBar:SetStatusBarColor(0, 1, 0) -- Green for friendly
					else
						-- Protect against secret value boolean test (12.0.0+)
						local notInterruptibleSecret = ArcHUD.isMidnight and issecretvalue and issecretvalue(notInterruptible)
						if (self.db.profile.IndicateInterruptible and not notInterruptibleSecret and not notInterruptible) then
							self.statusBar:SetStatusBarColor(1, 1, 0) -- Yellow for interruptible
						else
							self.statusBar:SetStatusBarColor(1, 0, 0) -- Red for non-interruptible
						end
					end

					self.statusBar:Show()
					-- Keep original ring empty in Midnight
					self.f:SetMax(1)
					self.f:SetValue(0)
				end
			else
				-- Legacy: Manual calculation
				self.f:SetMax(endTime - startTime)
				self.f:SetValue(endTime - startTime)
				self.spellstart = startTime
			end

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
		if not ArcHUD.isMidnight then
			-- Legacy: Manual calculation
			self.f:SetValue(self.f.startValue - (startTime - self.spellstart))
		end
		-- For Midnight, StatusBar handles timing automatically
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
		if not ArcHUD.isMidnight then
			-- Legacy: Manual calculation
			self.f:SetMax(endTime - self.spellstart)
		end
		-- For Midnight, StatusBar handles timing automatically
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

		-- Hide StatusBar in Midnight mode
		if ArcHUD.isMidnight and self.statusBar then
			self.statusBar:Hide()
		end
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

		-- Hide StatusBar in Midnight mode
		if ArcHUD.isMidnight and self.statusBar then
			self.statusBar:Hide()
		end
	end
end
