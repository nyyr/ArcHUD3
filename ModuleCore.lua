-- localization
local LM = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Module")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

-- Debug levels
local d_warn = 1
local d_info = 2
local d_notice = 3

local _

-- Set libraries
ArcHUD:SetDefaultModuleLibraries("AceEvent-3.0")
ArcHUD.modulePrototype = {
	parent = ArcHUD
}

local basePowerTypeIsEmpty = {
	[Enum.PowerType.Rage] = true,
	[Enum.PowerType.RunicPower] = true,
	[Enum.PowerType.Insanity] = true,
	[Enum.PowerType.Fury] = true,
	[Enum.PowerType.Pain] = true,
	[Enum.PowerType.LunarPower] = true,
	[Enum.PowerType.Maelstrom] = true
}

----------------------------------------------
-- Debug function uses the core :Debug function
----------------------------------------------
function ArcHUD.modulePrototype:Debug(level, msg, ...)
	if(self.parent.LevelDebug) then
		self.parent:LevelDebug(level, "["..self.name.."] "..msg, ...)
	end
end

----------------------------------------------
-- Initialize config options
----------------------------------------------
function ArcHUD.modulePrototype:InitConfigOptions()
	if (self.isCustom) then
		-- Custom buff module
		self:Debug(d_notice, "Initializing custom buff module options")
		
		-- Register options
		if (self.optionsTable and type(self.optionsTable) == "table") then
			self.parent:AddCustomModuleOptionsTable(self.name, self.optionsTable)
		end
		
	elseif (self.defaults and type(self.defaults) == "table") then
		-- Add defaults to ArcHUD defaults table
		self:Debug(d_notice, "Acquiring ring DB namespace")
		self.db = self.parent.db:RegisterNamespace(self.name, self.defaults)
		if(not self.db) then
			self:Debug(d_warn, "Failed to acquire DB namespace")
		end

		-- Register options
		if (self.optionsTable and type(self.optionsTable) == "table") then
			self.parent:AddModuleOptionsTable(self.name, self.optionsTable)
		end
		
	end
end

----------------------------------------------
-- Enabling/Disabling
----------------------------------------------
function ArcHUD.modulePrototype:OnInitialize()
	-- Prevent double-initialization
	-- This might happen for custom modules loaded after the ADDON_LOADED event
	if (self.isInitialized) then return end
	self.isInitialized = true
	
	if(self.Initialize) then
		self:Initialize()
		self:Debug(d_notice, "Ring initialized")
		self:RegisterMessage("ARCHUD_MODULE_ENABLE")
		self:RegisterMessage("ARCHUD_MODULE_UPDATE")
	else
		self:Debug(d_warn, "Missing Initialize(). Aborting")
		return
	end
	
	self:InitConfigOptions()

	-- Add metadata for module if it doesn't exist
	if(not self.version) then
		self.version = self.parent.version
	end
	if(not self.author) then
		self.author = self.parent.author
	end
	if(not self.date) then
		self.date = self.parent.date
	end
	
	-- Check for necessary alpha updates
	if (not self.noAutoAlpha) then
		self:RegisterTimer("CheckAlpha", ArcHUD.modulePrototype.CheckAlpha, 0.1, self, true)
	end
	
	self:Debug(d_info, "Ring loaded")
end

----------------------------------------------
-- OnEnable
----------------------------------------------
function ArcHUD.modulePrototype:OnEnable()
	if(self.db.profile.Enabled) then
		if(self.disableEvents and (not self.disableEvents.option or self.disableEvents.option and self.db.profile[self.disableEvents.option])) then
			self:Debug(d_notice, "Disabling events:")
			for k,v in ipairs(self.disableEvents) do
				local f = getglobal(v.frame)
				if(f) then
					self:Debug(d_notice, "- Frame '"..f:GetName().."':")
					for _, event in pairs(v.events) do
						self:Debug(d_notice, "  * "..event)
						f:UnregisterEvent(event)
					end
					if(v.hide and f:IsVisible()) then
						self:Debug(d_notice, "- Frame '"..f:GetName().."' hiding")
						f:Hide()
					end
				end
			end
			self.eventsDisabled = TRUE
		end
		if (self.OnModuleEnable) then
			self:OnModuleEnable()
		else
			self:Debug(d_info, "Ring "..self:GetName().." has no OnModuleEnable() handler")
		end
		self:ARCHUD_MODULE_UPDATE("ARCHUD_MODULE_UPDATE", self:GetName())
		self:RegisterMessage("ARCHUD_MODULE_DISABLE")
		self:RegisterMessage("ARCHUD_MODULE_UPDATE")
		self:Debug(d_info, "Ring enabled")
	else
		self:Debug(d_notice, "Ring disabled as per user setting")
		self:Disable()
	end
end

----------------------------------------------
-- OnDisable
----------------------------------------------
function ArcHUD.modulePrototype:OnDisable()
	--self:Debug(d_info, "Disabling ring")
	if(self.disableEvents and self.eventsDisabled) then
		self:Debug(d_notice, "Re-enabling events:")
		for k,v in ipairs(self.disableEvents) do
			local f = getglobal(v.frame)
			if(f) then
				--self:Debug(d_notice, "- Frame '"..f:GetName().."':")
				for _, event in pairs(v.events) do
					self:Debug(d_notice, "  * "..event)
					f:RegisterEvent(event)
				end
			end
		end
		self.eventsDisabled = FALSE
	end
	if(self.f) then
		self.f:Hide()
	end
	self:StopRingTimers()
	if(self.OnModuleDisable) then
		self:OnModuleDisable()
	end
	if (not self.deleted) then
		self:RegisterMessage("ARCHUD_MODULE_ENABLE")
		self:RegisterMessage("ARCHUD_MODULE_UPDATE")
	end
	self:Debug(d_info, "Ring disabled")
end

----------------------------------------------
-- ARCHUD_MODULE_ENABLE
----------------------------------------------
function ArcHUD.modulePrototype:ARCHUD_MODULE_ENABLE()
	self:Enable()
end

----------------------------------------------
-- ARCHUD_MODULE_DISABLE
----------------------------------------------
function ArcHUD.modulePrototype:ARCHUD_MODULE_DISABLE()
	self:Disable()
end

----------------------------------------------
-- ARCHUD_MODULE_UPDATE
----------------------------------------------
function ArcHUD.modulePrototype:ARCHUD_MODULE_UPDATE(message, module)
	--self:Debug(1, "ARCHUD_MODULE_UPDATE("..tostring(message)..", "..tostring(module))
	if(module == self:GetName()) then
		if(self.db.profile.Enabled and not self:IsEnabled()) then
			self:Enable()
		elseif(not self.db.profile.Enabled and self:IsEnabled()) then
			self:Disable()
		elseif(self.db.profile.Enabled and self:IsEnabled()) then
			if (not self.f) then
				self.parent:LevelDebug(d_warn, "Frame for "..module.." not defined")
				return
			end
			
			if(self.f.BG) then
				if(self.db.profile.Outline) then
					self.f.BG:Show()
				else
					self.f.BG:Hide()
				end
			end

			if(not self.options.nocolor) then
				self.ColorMode = self.db.profile.ColorMode or "custom"
			end

			if self.name ~= "Anchors" then
				self:AttachRing() -- default frame
				if self.frames then -- any additional frames
					for i,v in ipairs(self.frames) do
						self:AttachRing(v)
					end
				end
			end

			if(self.OnModuleUpdate) then
				--self:Debug(d_notice, "Updating ring")
				self:OnModuleUpdate()
			end
		end
	end
end

----------------------------------------------
-- Ring frame creation and setup
----------------------------------------------
function ArcHUD.modulePrototype:CreateRing(hasBG, parent)
	-- Create frame
	local f = CreateFrame("Frame", "ArcHUD_"..self:GetName().."_Ring", parent, "ArcHUDRingTemplate")
	f.module = self
	
	if not hasBG then
		f.BG:Hide()
		f.oldBG = f.BG -- if needed later again
		f.BG = nil
	end

	return f
end

----------------------------------------------
-- Anchor ring frame according to config
----------------------------------------------
function ArcHUD.modulePrototype:AttachRing(ring)
	if (not ring) then
		ring = self.f
	end
	local oldValue = ring.endValue
	ring:SetValue(0)
	-- Clear all points for the ring
	ring:ClearAllPoints()
	
	if(self.db.profile.Side == 1) then
		-- Attach to left side
		if self.db.profile.InnerAnchor then
			ring:SetScale(0.6)
			ring:SetPoint("TOPLEFT", self.parent:GetModule("Anchors").Left, "LEFT", self.db.profile.Level * -9, 90)
		else
			ring:SetScale(1)
			ring:SetPoint("TOPLEFT", self.parent:GetModule("Anchors").Left, "TOPLEFT", self.db.profile.Level * -15, 0)
		end
		if(ring.BG) then
			ring.BG:SetReversed(false)
		end
		ring:SetReversed(false)
	else
		-- Attach to right side
		if self.db.profile.InnerAnchor then
			ring:SetScale(0.6)
			ring:SetPoint("TOPLEFT", self.parent:GetModule("Anchors").Right, "LEFT", self.db.profile.Level * 9, 90)
		else
			ring:SetScale(1)
			ring:SetPoint("TOPRIGHT", self.parent:GetModule("Anchors").Right, "TOPRIGHT", self.db.profile.Level * 15, 0)
		end
		if(ring.BG) then
			ring.BG:SetReversed(true)
		end
		ring:SetReversed(true)
	end
	if(ring.BG) then
		ring.BG:SetAngle(180)
	end
	
	-- separators
	if (self.db.profile.ShowSeparators) then
		ring.showSeparators = true
	end
	ring:RefreshSeparators()
	
	ring:SetValue(oldValue)
end

----------------------------------------------
-- CreateFontString
----------------------------------------------
function ArcHUD.modulePrototype:CreateFontString(parent, layer, size, fontsize, justify, color, point)
	local fs = parent:CreateFontString(nil, layer)
	local width, height = unpack(size)

	fs:SetWidth(width)
	fs:SetHeight(height)
	fs:SetFont("Fonts\\"..LM["FONT"], fontsize, "OUTLINE")
	if(color) then
		fs:SetTextColor(unpack(color))
	end
	fs:SetJustifyH(justify)
	fs:SetPoint(unpack(point))

	fs:Show()

	return fs
end

----------------------------------------------
-- CreateTexture
----------------------------------------------
function ArcHUD.modulePrototype:CreateTexture(parent, layer, size, texture, point)
	local t = parent:CreateTexture(nil, layer)
	local width, height = unpack(size)

	t:SetWidth(width)
	t:SetHeight(height)
	if(texture) then
		t:SetTexture(texture)
	end
	if(point) then
		t:SetPoint(unpack(point))
	end

	t:Show()

	return t
end

-----------------------------------------------------------
-- Update of alpha value for all frames
--
-- alpha - Alpha value to set
-- alpha2 - If not nil and ring not full/empty, use alpha2 instead of alpha
-----------------------------------------------------------
function ArcHUD.modulePrototype:SetFramesAlpha(alpha, alpha2)
	if (self.frames) then
		-- module with multiple frames
		for i,f in pairs(self.frames) do
			if (f.maxValue == 0) or f.isHidden then
				f:SetRingAlpha(0)
			elseif (alpha2) then
				if(f.startValue < f.maxValue or math.floor(f.startValue) ~= math.floor(f.endValue)) then
					f:SetRingAlpha(alpha2)
				elseif(self.f.startValue == self.f.maxValue) then
					f:SetRingAlpha(alpha)
				end
			else
				f:SetRingAlpha(alpha)
			end
		end
	elseif (self.f) then
		-- single/no frame
		local f = self.f
		if (f.maxValue == 0) or f.isHidden then
			f:SetRingAlpha(0)
		elseif (alpha2) then
			if(f.startValue < f.maxValue or math.floor(f.startValue) ~= math.floor(f.endValue)) then
				f:SetRingAlpha(alpha2)
			elseif(self.f.startValue == self.f.maxValue) then
				f:SetRingAlpha(alpha)
			end
		else
			f:SetRingAlpha(alpha)
		end
	end
end

-----------------------------------------------------------
-- Trigger update of alpha value (e.g. on entering combat)
-----------------------------------------------------------
function ArcHUD.modulePrototype:CheckAlpha()
	if (self.noAutoAlpha) then
		self:Debug(1, "CheckAlpha(): noAutoAlpha, but CheckAlpha timer started!")
		return
	end

	local AH_profile = self.parent.db.profile
	local isInCombat = false
	local me = self:GetName()
	local unit = self.unit or "player"

	if (unit == "pet") then
		isInCombat = self.parent.PetIsInCombat
	else
		isInCombat = self.parent.PlayerIsInCombat
	end

	-- 1: Fade out when rings are full, regardless of combat status
	-- 2: Always fade out when out of combat, regardless of ring status
	-- 3: Fade out when out of combat or rings are full (default)
	local RingVisibility = self.db.profile.RingVisibility -- ring config
	if (RingVisibility == nil) then
		RingVisibility = AH_profile.RingVisibility -- global config
	end
	if (RingVisibility == 1 or RingVisibility == 3) then
		if (RingVisibility == 3 and isInCombat) then
			if (not UnitExists(unit)) or (self.isPower and (UnitIsDead(unit) or self.f.maxValue == 0)) then
				self.f:SetRingAlpha(0)
			elseif (self.isHealth and UnitIsDead(unit)) then
				self.f:SetRingAlpha(AH_profile.FadeFull)
			else
				-- all other frames
				self:SetFramesAlpha(AH_profile.FadeIC) 
			end
		else
			local powerTypeId, _ = UnitPowerType(unit)
			-- powerTypeId: 1 = rage, 6 = runic_power, 17 = fury
			if (self.isPower and (unit ~= "pet") and basePowerTypeIsEmpty[powerTypeId] and (self.f.maxValue > 0)) then
				if(math.floor(self.f.startValue) > 0 or math.floor(self.f.startValue) ~= math.floor(self.f.endValue)) then
					self.f:SetRingAlpha(AH_profile.FadeOOC)
				elseif(math.floor(self.f.startValue) == 0) then
					self.f:SetRingAlpha(AH_profile.FadeFull)
				end
			else
				if (not UnitExists(unit)) or (self.isPower and (UnitIsDead(unit) or self.f.maxValue == 0)) then
					self.f:SetRingAlpha(0)
				elseif (self.isHealth and UnitIsDead(unit)) then
					self.f:SetRingAlpha(AH_profile.FadeFull)
				else
					-- all other frames
					self:SetFramesAlpha(AH_profile.FadeFull, AH_profile.FadeOOC)
				end
			end
		end

	elseif (RingVisibility == 2) then
	
		if ((not UnitExists(unit)) or (self.isPower and (UnitIsDead(unit) or self.f.maxValue == 0))) then
			self.f:SetRingAlpha(0)
		elseif (self.isHealth and UnitIsDead(unit)) then
			self.f:SetRingAlpha(AH_profile.FadeFull)
		else
			-- all other frames
			if(isInCombat) then
				self:SetFramesAlpha(AH_profile.FadeIC)
			else
				self:SetFramesAlpha(AH_profile.FadeFull)
			end
		end
		
	end
end

----------------------------------------------
-- Start ring timers (filling and alpha check)
----------------------------------------------
function ArcHUD.modulePrototype:StartRingTimers()
	if (self.frames) then
		-- module with multiple frames
		for i,f in pairs(self.frames) do
			f.fillUpdate:Play()
		end
	elseif (self.f and self.f:GetAlpha() > 0) then
		-- module with single or no frame
		self.f.fillUpdate:Play()
	end
	if (not self.noAutoAlpha) then
		self:StartTimer("CheckAlpha")
	end
end

----------------------------------------------
-- Stop ring timers
----------------------------------------------
function ArcHUD.modulePrototype:StopRingTimers()
	if (self.frames) then
		-- module with multiple frames
		for i,f in pairs(self.frames) do
			f.fillUpdate:Stop()
		end
	elseif (self.f) then
		-- module with single or no frame
		self.f.fillUpdate:Stop()
	end
	self:StopTimer("CheckAlpha")
end

----------------------------------------------
-- color_switch
----------------------------------------------
local color_switch = {
	friendfoe = {
		[1] = function(self) return self.db.profile.ColorFriend end,
		[2] = function(self) return self.db.profile.ColorFoe end,
	},
	manabar = {
		[0] = function(self) return self.db.profile.ColorMana end,
		[1] = function(self) return self.db.profile.ColorRage end,
		[2] = function(self) return self.db.profile.ColorFocus end,
		[3] = function(self) return self.db.profile.ColorEnergy end,
		[6] = function(self) return self.db.profile.ColorRunic end,
	}
}



----------------------------------------------
-- UpdateColor
----------------------------------------------
function ArcHUD.modulePrototype:UpdateColor(color)
	if(color and type(color) == "table") then
		self.f:UpdateColor(color)
	elseif(color and type(color) == "number") then
		if(self.options.hasfriendfoe) then
			-- Friend / Foe = 1 / 2
			if(color_switch.friendfoe[color]) then
				self.f:UpdateColor(color_switch.friendfoe[color](self))
			end
		elseif(self.options.hasmanabar) then
			-- Mana / Rage / Focus / Energy / Runic = 0 / 1 / 2 / 3 / 6
			if(color_switch.manabar[color]) then
				self.f:UpdateColor(color_switch.manabar[color](self))
			elseif(PowerBarColor[color]) then
				self.f:UpdateColor(PowerBarColor[color])
			end
		end
	else
		if (self.ColorMode == "fade") then return end
		self.f:UpdateColor(self.db.profile.Color)
	end
end

----------------------------------------------
-- Return power bar color
----------------------------------------------
function ArcHUD.modulePrototype:GetPowerBarColor(powerType)
	if (color_switch.manabar[powerType]) then
		return color_switch.manabar[powerType](self)
	else
		return PowerBarColor[powerType]
	end
end

----------------------------------------------
-- Return power bar color (for text, thus readable colors)
----------------------------------------------
function ArcHUD.modulePrototype:GetPowerBarColorText(powerType)
	if (powerType == 0) then
		return { r = 0.00, g = 1.00, b = 1.00 }
	elseif (color_switch.manabar[powerType]) then
		return color_switch.manabar[powerType](self)
	else
		return PowerBarColor[powerType]
	end
end

----------------------------------------------
-- Register a timer
----------------------------------------------
function ArcHUD.modulePrototype:RegisterTimer(name, callback, delay, arg, repeating)
	self.parent:RegisterTimer(self.name..name, callback, delay, arg, repeating)
end

----------------------------------------------
-- Start a registered timer
----------------------------------------------
function ArcHUD.modulePrototype:StartTimer(name)
	self.parent:StartTimer(self.name..name)
end

----------------------------------------------
-- Stop a registered timer
----------------------------------------------
function ArcHUD.modulePrototype:StopTimer(name)
	self.parent:StopTimer(self.name..name)
end

----------------------------------------------
-- Register a unit event (not supported by AceEvent)
-- Requires a module frame (module.f)
----------------------------------------------
function ArcHUD.modulePrototype:RegisterUnitEvent(event, callback, unit)
	if (not self.f) then
		self:Debug(1, "No frame to register a unit event on!")
		return
	end
	
	if (not self.f.unitEvents) then
		self.f.unitEvents = {}
	end
	
	if (self.f.unitEvents[event]) then
		self:Debug(1, "Unit event %s already registered!", tostring(event))
		return
	end
	
	if (not callback) then
		callback = event
	end
	
	if (not unit) then
		unit = self.unit
	end
	
	local unit2 = nil
	if (unit == "player") then
		unit2 = "vehicle"
	end
	
	self.f.unitEvents[event] = { cb = callback, module = self }
	
	if (self.f.RegisterUnitEvent) then
		-- introduced in WoW 5.x
		self.f:RegisterUnitEvent(event, unit, unit2)
	else
		-- for backward compatibility (WoW 4.x)
		self:RegisterEvent(event, callback)
	end
end

----------------------------------------------
-- Unregister a unit event (not supported by AceEvent)
----------------------------------------------
function ArcHUD.modulePrototype:UnregisterUnitEvent(event)
	if (not self.f) then
		self:Debug(1, "No frame to unregister a unit event from!")
		return
	end
	
	if (not self.f.unitEvents) then
		self:Debug(1, "UnregisterUnitEvent(): No unit events registered yet!")
		return
	end
	
	if (not self.f.unitEvents[event]) then
		self:Debug(1, "UnregisterUnitEvent(): Unit event %s not registered!", tostring(event))
		return
	end
	
	self.f:UnregisterEvent(event)
	self.f.unitEvents[event] = nil
end

----------------------------------------------
-- Create standard module options
----------------------------------------------
function ArcHUD.modulePrototype:CreateStandardModuleOptions(order)
	local t
	local name
	
	if (self.isCustom) then
		name = self.db.profile.BuffName .. " (" .. self.db.profile.Unit .. ")"
	else
		name = LM[self:GetName()]
	end
	
	self.optionsTable = {
		type		= "group",
		name		= name,
		order		= order or 100,
		args 		= {
			header = {
				type		= "header",
				name		= "v" .. self.version,
				order		= 0,
			},
			enabled = {
				type		= "toggle",
				name		= LM["TEXT"]["ENABLED"],
				desc		= LM["TOOLTIP"]["ENABLED"],
				order		= 21,
				get			= function ()
					return self.db.profile.Enabled
				end,
				set			= function (info, v)
					self.db.profile.Enabled = v
					if (v) then
						self:Enable()
					else
						self:Disable()
					end
				end,
			},
			outline = {
				type		= "toggle",
				name		= LM["TEXT"]["OUTLINE"],
				desc		= LM["TOOLTIP"]["OUTLINE"],
				order		= 22,
				get			= function ()
					return self.db.profile.Outline
				end,
				set			= function (info, v)
					self.db.profile.Outline = v
					self:SendMessage("ARCHUD_MODULE_UPDATE", self:GetName())
				end,
			},
			inneranchor = {
				type		= "toggle",
				name		= LM["TEXT"]["INNERANCHOR"],
				desc		= LM["TOOLTIP"]["INNERANCHOR"],
				order		= 23,
				get			= function ()
					return self.db.profile.InnerAnchor
				end,
				set			= function (info, v)
					self.db.profile.InnerAnchor = v
					self:SendMessage("ARCHUD_MODULE_UPDATE", self:GetName())
				end,
			},
			side = {
				type		= "select",
				name		= LM["TEXT"]["SIDE"],
				desc		= LM["TOOLTIP"]["SIDE"],
				values		= {LM["SIDE"]["LEFT"], LM["SIDE"]["RIGHT"]},
				order		= 24,
				get			= function ()
					return self.db.profile.Side
				end,
				set			= function (info, v)
					self.db.profile.Side = v
					self:SendMessage("ARCHUD_MODULE_UPDATE", self:GetName())
				end,
			},
			level = {
				type		= "range",
				name		= LM["TEXT"]["LEVEL"],
				desc		= LM["TOOLTIP"]["LEVEL"],
				min			= -5,
				max			= 5,
				step		= 1,
				order		= 25,
				get			= function ()
					return self.db.profile.Level
				end,
				set			= function (info, v)
					self.db.profile.Level = v
					self:SendMessage("ARCHUD_MODULE_UPDATE", self:GetName())
				end,
			},
		},
	}
	
	if (self.options.hasseparators) then
		t = {
			type		= "toggle",
			name		= LM["TEXT"]["SEPARATORS"],
			desc		= LM["TOOLTIP"]["SEPARATORS"],
			order		= 30,
			get			= function ()
				return self.db.profile.ShowSeparators
			end,
			set			= function (info, val)
				self.db.profile.ShowSeparators = val
				self:SendMessage("ARCHUD_MODULE_UPDATE", self:GetName())
			end,
		}
		self.optionsTable.args.ShowSeparators = t
	end
	
	for k,v in ipairs(self.options) do
		if(type(v) == "table") then
			t = {
				type		= "toggle",
				name		= LM["TEXT"][v.text],
				desc		= LM["TOOLTIP"][v.tooltip],
				order		= 40,
				get			= function ()
					return self.db.profile[v.name]
				end,
				set			= function (info, val)
					self.db.profile[v.name] = val
					self:SendMessage("ARCHUD_MODULE_UPDATE", self:GetName())
				end,
			}
			self.optionsTable.args[v.name] = t
		end
	end
	
	local colorOption = function(self, caption, colorName)
		return {
			type		= "color",
			name		= LM["TEXT"][caption],
			desc		= LM["TOOLTIP"][caption],
			order		= 41,
			get			= function ()
				return self.db.profile[colorName].r, self.db.profile[colorName].g, self.db.profile[colorName].b
			end,
			set			= function (info, r, g, b, a)
				self.db.profile[colorName] = {["r"] = r, ["g"] = g, ["b"] = b}
				self:SendMessage("ARCHUD_MODULE_UPDATE", self:GetName())
			end,
		}
	end
	
	if (not self.options.nocolor) then
	
		if (self.options.hasmanabar) then
			
			self.optionsTable.args.colorMana = colorOption(self, "COLORMANA", "ColorMana")
			self.optionsTable.args.colorRage = colorOption(self, "COLORRAGE", "ColorRage")
			self.optionsTable.args.colorFocus = colorOption(self, "COLORFOCUS", "ColorFocus")
			self.optionsTable.args.colorEnergy = colorOption(self, "COLORENERGY", "ColorEnergy")
			self.optionsTable.args.colorRunic = colorOption(self, "COLORRUNIC", "ColorRunic")
		
		elseif (self.options.hasfriendfoe) then
		
			self.optionsTable.args.colorFriend = colorOption(self, "COLORFRIEND", "ColorFriend")
			self.optionsTable.args.colorFoe = colorOption(self, "COLORFOE", "ColorFoe")
		
		elseif (self.options.hascolorfade) then
		
			-- Color mode
			t = {
				type		= "select",
				name		= LM["TEXT"]["COLOR"],
				desc		= LM["TOOLTIP"]["COLOR"],
				order		= 41,
				values		= {["fade"] = LM["TEXT"]["COLORFADE"], ["custom"] = LM["TEXT"]["COLORCUST"]},
				get			= function ()
					return self.db.profile.ColorMode or "custom"
				end,
				set			= function (info, v)
					self.db.profile.ColorMode = v
					if (self.db.profile.ColorMode == "custom") then
						self:UpdateColor(self.db.profile.Color)
					end
					self:SendMessage("ARCHUD_MODULE_UPDATE", self:GetName())
				end,
			}
			self.optionsTable.args.colormode = t
		
			-- Color
			self.optionsTable.args.color = colorOption(self, "COLORSETFADE", "Color")
			
		elseif (self.options.customcolors) then
		
			for i,v in ipairs(self.options.customcolors) do
				self.optionsTable.args[v.name] = colorOption(self, v.text, v.name)
			end
		
		else
			
			-- Color
			self.optionsTable.args.color = colorOption(self, "COLORSET", "Color")
			
		end
		
		-- Reset to default
		t = {
			type		= "execute",
			name		= LM["TEXT"]["COLORRESET"],
			desc		= LM["TOOLTIP"]["COLORRESET"],
			order		= 45,
			func		= function ()
				local resetColor = function(color, default)
					if (color and default) then
						color.r, color.g, color.b = default.r, default.g, default.b
					end
				end
				
				for k,v in pairs(self.db.profile) do
					if (k ~= "ColorMode") and (strsub(k, 1, 5) == "Color") then
						resetColor(self.db.profile[k], self.defaults.profile[k])
					end
				end

				if (self.db.profile.ColorMode) then
					self.db.profile.ColorMode = self.defaults.profile.ColorMode
				end
				
				self:SendMessage("ARCHUD_MODULE_UPDATE", self:GetName())
				AceConfigRegistry:NotifyChange("ArcHUD_Modules")
			end,
		}
		self.optionsTable.args.colorReset = t
	end
end

function ArcHUD.modulePrototype:AppendModuleOptions(optionsTable)
	if not (self.optionsTable) then
		self:Debug(d_warn, "Cannot append options, options table not initialized.")
		return
	end
	for k, o in pairs(optionsTable) do
		self.optionsTable.args[k] = o
	end
end

ArcHUD:SetDefaultModulePrototype(ArcHUD.modulePrototype)
