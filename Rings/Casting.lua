local moduleName = "Casting"
local module = ArcHUD:NewModule(moduleName)
local _, _, rev = string.find("$Rev$", "([0-9]+)")
module.version = "1.0 (r"..rev..")"

module.unit = "player"
module.noAutoAlpha = true

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		ShowSpell = true,
		ShowTime = true,
		Side = 2,
		Level = -1,
	}
}
module.options = {
	{name = "ShowSpell", text = "SHOWSPELL", tooltip = "SHOWSPELL"},
	{name = "ShowTime", text = "SHOWTIME", tooltip = "SHOWTIME"},
	nocolor = true,
	attach = true,
}
module.localized = true
module.disableEvents = {
	{frame = "CastingBarFrame", hide = TRUE, events = {"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_DELAYED",
														"UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED",
														"UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE",
														"UNIT_SPELLCAST_CHANNEL_STOP", "PLAYER_ENTERING_WORLD"}},
}

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)

	self.Text = self:CreateFontString(self.f, "BACKGROUND", {175, 14}, 12, "LEFT", {1.0, 1.0, 1.0}, {"TOP", "ArcHUDFrameCombo", "BOTTOM", -28, 0})
	self.Time = self:CreateFontString(self.f, "BACKGROUND", {40, 14}, 12, "RIGHT", {1.0, 1.0, 1.0}, {"TOPLEFT", self.Text, "TOPRIGHT", 0, 0})

	-- Register timers
	--self.parent:RegisterMetro(self.name .. "CheckTaxi", self.CheckTaxi, 0.1, self)
	
	self:CreateStandardModuleOptions(15)
end

function module:Update()
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

local function Player_Casting(frame, elapsed)
	self = frame.module
	if ( self.f.casting == nil ) then
		self.f.casting = 0 end
	if ( self.channeling == nil ) then
		self.channeling = 0 end
	if ( self.spellstart == nil ) then
		self.spellstart = GetTime()*1000 end

	if ( self.f.casting == 1) then
		local status = (GetTime()*1000 - self.spellstart)
		local time_remaining = self.f.maxValue - status

		if ( self.channeling == 1) then
			status = time_remaining
		end

		if ( status > self.f.maxValue ) then
			status = self.f.maxValue
		end

		self.f:SetValue(status)

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
	self:RegisterEvent("UNIT_SPELLCAST_START")
	self:RegisterEvent("UNIT_SPELLCAST_DELAYED")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")

	self:RegisterEvent("UNIT_SPELLCAST_STOP", 			"SpellcastStop")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED", 		"SpellcastFailed")
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", 	"SpellcastInterrupt")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", 	"SpellcastChannelStop")

	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", 		"SpellcastSuccess")

	-- Do hooks for flight timers
--[[
	if(FlightMapTimes_BeginFlight and FlightMapTimes_EndFlight) then
		self:Debug(2, "Hooking FlightMap")
		self:Hook("FlightMapTimes_BeginFlight", "BeginFlight", true)
		self:Hook("FlightMapTimes_EndFlight", "EndFlight", true)
		self.using = "FlightMap"
	elseif(ToFu) then
		self:Debug(2, "Hooking ToFu")
		self:Hook("TakeTaxiNode", "BeginFlight", true)
		self.parent:StartMetro(self.name .. "CheckTaxi")
		self.using = "ToFu"
-- [ [	elseif(InFlight) then
		self:Debug(2, "Hooking InFlight")
		self:Hook(InFlight, "StartTimer", "BeginFlight", true)
		self:StartMetro(self.name .. "CheckTaxi")
		self.using = "InFlight" ] ]
	else
		self.using = "none"
	end
]]
	
	-- Add update hook
	self.f.UpdateHook = Player_Casting
	
	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
end

--[[
function module:BeginFlight(duration, destination)
	local slot = duration
	if(self.using == "ToFu") then
		_, duration = ToFu:GetFlightData(ToFu.start, TaxiNodeName(slot))
		destination = ToFu:LessName(TaxiNodeName(slot))
	elseif(self.using == "Inflight") then
		-- hack to get flight data from InFlight
		local source
		for i = 1, NumTaxiNodes(), 1 do
			if TaxiNodeGetType(i) == "CURRENT" then
				source = ShortenName(TaxiNodeName(i))
				break
			end
		end
		destination = ShortenName(TaxiNodeName(slot))
		if(InFlightVars[UnitFactionGroup("player")][source][destination] > 0) then
			duration = InFlightVars[UnitFactionGroup("player")][source][destination]
		else
			duration = nil
		end
	end

	-- Set up casting bar for flight
	if(duration and duration > 0) then
		self.Text:SetText(destination)
	else
		self.Text:SetText(destination.. " - Timing")
	end

	self.InFlight = true
	self.channeling = 1
	self.f.casting = 1
	self.spellstart = GetTime()*1000
	self.f:SetMax(duration and duration > 0 and duration*1000 or 1)
	self.f:SetValue(duration and duration > 0  and duration*1000 or 1)
	self.f:UpdateColor({["r"] = 0.3, ["g"] = 0.3, ["b"] = 1.0})
	if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
		self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
	else
		self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
	end

	if(self.using == "ToFu" or self.using == "InFlight" and self.hooks.TakeTaxiNode) then
		return self.hooks.TakeTaxiNode(slot)
	end
end

function module:EndFlight()
	self.InFlight = false
	self.channeling = 0
	self.f:SetRingAlpha(0)
	self.f:SetValue(0)
	self.f.casting = 0
	self.Text:SetText("")
	self.Time:SetText("")
end

function module:CheckTaxi()
	if(self.InFlight) then
		if(not UnitOnTaxi("player") and (self.spellstart+5000) < (GetTime()*1000)) then
			self:EndFlight()
		end
	end
end
]]

function module:UNIT_SPELLCAST_START(event, arg1)
	if(arg1 == self.unit) then
		local spell, rank, displayName, icon, startTime, endTime = UnitCastingInfo(self.unit)
		self.f:UpdateColor({["r"] = 1.0, ["g"] = 0.7, ["b"] = 0})
		self.Text:SetText(displayName)
		self.startValue = 0
		self.f:SetMax(endTime - startTime)
		self.f.casting = 1
		self.channeling = 0
		self.spellstart = startTime
		self.stopSet = false
		if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
			self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
		else
			self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
		end
	end
end

function module:UNIT_SPELLCAST_CHANNEL_START(event, arg1)
	if(arg1 == self.unit) then
		local spell, rank, displayName, icon, startTime, endTime = UnitChannelInfo(self.unit)
		self.f:UpdateColor({["r"] = 0.3, ["g"] = 0.3, ["b"] = 1.0})
		self.Text:SetText(displayName)
		self.startValue = 0
		self.f:SetMax(endTime - startTime)
		self.f:SetValue(endTime - startTime)
		self.channeling = 1
		self.f.casting = 1
		self.spellstart = startTime
		if(ArcHUD.db.profile.FadeIC > ArcHUD.db.profile.FadeOOC) then
			self.f:SetRingAlpha(ArcHUD.db.profile.FadeIC)
		else
			self.f:SetRingAlpha(ArcHUD.db.profile.FadeOOC)
		end
	end
end

function module:UNIT_SPELLCAST_CHANNEL_UPDATE(event, arg1)
	if(arg1 == self.unit) then
		local spell, rank, displayName, icon, startTime, endTime = UnitChannelInfo(arg1)
		self.f:SetValue(self.f.startValue - (startTime - self.spellstart))
		self.spellstart = startTime
	end
end

function module:UNIT_SPELLCAST_DELAYED(event, arg1)
	if(arg1 == self.unit) then
		local spell, rank, displayName, icon, startTime, endTime = UnitCastingInfo(arg1)
		self.f:SetMax(endTime - self.spellstart)
	end
end

function module:SpellcastStop(event, arg1)
	if(arg1 == self.unit and self.f.casting == 1 and self.channeling == 0) then
		local spell, rank, displayName, icon, startTime, endTime = UnitCastingInfo(arg1)
		self.f:SetValue(self.f.maxValue)
		self.f.casting = 0
		if(self.spellStatus) then
			if(self.spellStatus == "success") then
				self.f:UpdateColor({["r"] = 0, ["g"] = 1.0, ["b"] = 0})
			elseif(self.spellStatus == "failed") then
				self.f:UpdateColor({["r"] = 1.0, ["g"] = 0, ["b"] = 0})
				self.Text:SetText("Failed")
			elseif(self.spellStatus == "interrupted") then
				self.f:UpdateColor({["r"] = 1.0, ["g"] = 0, ["b"] = 0})
				self.Text:SetText("Interrupted")
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
		local spell, rank, displayName, icon, startTime, endTime = UnitChannelInfo(arg1)
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


-- InFlight function
-- shorten name to lighten saved vars
local function ShortenName(name)
	local found = string.find(name, ", ")
	if found then
		name = string.sub(name, 1, found - 1)
	end
	return name
end
