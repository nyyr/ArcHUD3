-- localization
local LM = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Module")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

-- Debug levels
local d_warn = 1
local d_info = 2
local d_notice = 3

-- Set libraries
ArcHUD:SetDefaultModuleLibraries("AceEvent-3.0")
ArcHUD.modulePrototype = {
	parent = ArcHUD
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
		self:RegisterTimer("CheckAlpha", ArcHUDRingTemplate.CheckAlpha, 0.1, self, true)
	end
	
	self:Debug(d_info, "Ring loaded")
end

----------------------------------------------
-- OnEnable
----------------------------------------------
function ArcHUD.modulePrototype:OnEnable()
	--self:Debug(d_warn, "Received enable event")
	if(self.db.profile.Enabled) then
		--self:Debug(d_info, "Enabling ring")
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
		self:Debug(d_info, "Ring disabled as per user setting")
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

			-- Special treatment for Pet rings
			if(string.find(self.name, "Pet")) then
				self.options.attach = self.db.profile.Attach
			end

			if(self.options.attach) then
				local oldValue = self.f.endValue
				self.f:SetValue(0)
				-- Clear all points for the ring
				self.f:ClearAllPoints()
				if(self.db.profile.Side == 1) then
					-- Attach to left side
					self.f:SetPoint("TOPLEFT", self.parent:GetModule("Anchors").Left, "TOPLEFT", self.db.profile.Level * -15, 0)
					if(self.f.BG) then
						self.f.BG:SetReversed(false)
					end
					self.f:SetReversed(false)
				else
					-- Attach to right side
					self.f:SetPoint("TOPRIGHT", self.parent:GetModule("Anchors").Right, "TOPRIGHT", self.db.profile.Level * 15, 0)
					if(self.f.BG) then
						self.f.BG:SetReversed(true)
					end
					self.f:SetReversed(true)
				end
				if(self.f.BG) then
					self.f.BG:SetAngle(180)
				end
				self.f:SetValue(oldValue)
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

	return f
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

----------------------------------------------
-- Start ring timers (filling and alpha check)
----------------------------------------------
function ArcHUD.modulePrototype:StartRingTimers()
	if (self.f:GetAlpha() > 0) then
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
	self.f.fillUpdate:Stop()
	self:StopTimer("CheckAlpha")
end

----------------------------------------------
-- color_switch
----------------------------------------------
local color_switch = {
	-- friendfoe = {
		-- [1] = function(self) self.f:UpdateColor(self.ColorMode == "default" and self.defaults.profile.ColorFriend or self.db.profile.ColorFriend) end,
		-- [2] = function(self) self.f:UpdateColor(self.ColorMode == "default" and self.defaults.profile.ColorFoe or self.db.profile.ColorFoe) end,
	-- },
	-- manabar = {
		-- [0] = function(self) self.f:UpdateColor(self.ColorMode == "default" and self.defaults.profile.ColorMana or self.db.profile.ColorMana) end,
		-- [1] = function(self) self.f:UpdateColor(self.ColorMode == "default" and self.defaults.profile.ColorRage or self.db.profile.ColorRage) end,
		-- [2] = function(self) self.f:UpdateColor(self.ColorMode == "default" and self.defaults.profile.ColorFocus or self.db.profile.ColorFocus) end,
		-- [3] = function(self) self.f:UpdateColor(self.ColorMode == "default" and self.defaults.profile.ColorEnergy or self.db.profile.ColorEnergy) end,
	-- }
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
	return color_switch.manabar[powerType](self)
end

----------------------------------------------
-- Return power bar color (for text, thus readable colors)
----------------------------------------------
function ArcHUD.modulePrototype:GetPowerBarColorText(powerType)
	if (powerType == 0) then
		return { r = 0.00, g = 1.00, b = 1.00 }
	else
		return color_switch.manabar[powerType](self)
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
			side = {
				type		= "select",
				name		= LM["TEXT"]["SIDE"],
				desc		= LM["TOOLTIP"]["SIDE"],
				values		= {LM["SIDE"]["LEFT"], LM["SIDE"]["RIGHT"]},
				order		= 23,
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
				order		= 24,
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
					if (color) then
						color.r, color.g, color.b = default.r, default.g, default.b
					end
				end
				resetColor(self.db.profile.Color, self.defaults.profile.Color)
				resetColor(self.db.profile.ColorFriend, self.defaults.profile.ColorFriend)
				resetColor(self.db.profile.ColorFoe, self.defaults.profile.ColorFoe)
				resetColor(self.db.profile.ColorMana, self.defaults.profile.ColorMana)
				resetColor(self.db.profile.ColorRage, self.defaults.profile.ColorRage)
				resetColor(self.db.profile.ColorFocus, self.defaults.profile.ColorFocus)
				resetColor(self.db.profile.ColorEnergy, self.defaults.profile.ColorEnergy)
				resetColor(self.db.profile.ColorRunic, self.defaults.profile.ColorRunic)
				
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
