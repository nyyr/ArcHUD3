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
ArcHUD:SetDefaultModuleLibraries("AceEvent-3.0", "AceHook-3.0")
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

function ArcHUD.modulePrototype:InitConfigOptions()
	if(self.defaults and type(self.defaults) == "table") then
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

--[[
function ArcHUD.modulePrototype:RegisterDewdropSettings()
	local t = {}

	table.insert(self.parent.dewdrop_menu.L1, {"text", self.L[self.name] or self.name, "hasArrow", true, "value", "L2_"..self.name})

	self.parent.dewdrop_menu["L2_"..self.name] = {
		{
			"text", self.L[self.name] or self.name,
			"isTitle", true
		},
		{
			"text", self.L["Version: "]..self.version,
			"notClickable", true
		},
		{
			"text", self.L["Author: "]..self.author,
			"notClickable", true
		},
		{},
		{
			"text", self.L["TEXT"]["ENABLED"],
			"tooltipTitle", self.L["TEXT"]["ENABLED"],
			"tooltipText", self.L["TOOLTIP"]["ENABLED"],
			"checked", false,
			"func", ArcHUD.modDB,
			"arg1", "toggle",
			"arg2", "Enabled",
			"arg3", self.name
		},
	}
	if(self.f) then
		table.insert(self.parent.dewdrop_menu["L2_"..self.name], {
			"text", self.L["TEXT"]["OUTLINE"],
			"tooltipTitle", self.L["TEXT"]["OUTLINE"],
			"tooltipText", self.L["TOOLTIP"]["OUTLINE"],
			"checked", false,
			"func", ArcHUD.modDB,
			"arg1", "toggle",
			"arg2", "Outline",
			"arg3", self.name
		})

		if(not self.options.nocolor) then
			t = {
				"text", self.L["TEXT"]["COLOR"],
				"tooltipTitle", self.L["TEXT"]["COLOR"],
				"tooltipText", self.L["TOOLTIP"]["COLOR"],
				"hasArrow", true,
				"value", "L3_"..self.name.."_color"
			}
			table.insert(self.parent.dewdrop_menu["L2_"..self.name], t)

			self.parent.dewdrop_menu["L3_"..self.name.."_color"] = { }
			if(self.options.hascolorfade) then
				t = {
					"text", self.L["TEXT"]["COLORFADE"],
					"tooltipTitle", self.L["TEXT"]["COLORFADE"],
					"tooltipText", self.L["TOOLTIP"]["COLORFADE"],
					"checked", false,
					"isRadio", true,
					"func", ArcHUD.modDB,
					"arg1", "set",
					"arg2", "ColorMode",
					"arg3", self.name,
					"arg4", "fade"
				}
				table.insert(self.parent.dewdrop_menu["L3_"..self.name.."_color"], t)
			end

			t = {
				"text", self.L["TEXT"]["COLORDEF"],
				"tooltipTitle", self.L["TEXT"]["COLORDEF"],
				"tooltipText", self.L["TOOLTIP"]["COLORDEF"],
				"checked", false,
				"isRadio", true,
				"func", ArcHUD.modDB,
				"arg1", "set",
				"arg2", "ColorMode",
				"arg3", self.name,
				"arg4", "default"
			}
			table.insert(self.parent.dewdrop_menu["L3_"..self.name.."_color"], t)

			t = {
				"text", self.L["TEXT"]["COLORCUST"],
				"tooltipTitle", self.L["TEXT"]["COLORCUST"],
				"tooltipText", self.L["TOOLTIP"]["COLORCUST"],
				"checked", false,
				"isRadio", true,
				"func", ArcHUD.modDB,
				"arg1", "set",
				"arg2", "ColorMode",
				"arg3", self.name,
				"arg4", "custom"
			}
			table.insert(self.parent.dewdrop_menu["L3_"..self.name.."_color"], t)

			table.insert(self.parent.dewdrop_menu["L3_"..self.name.."_color"], {})

			if(self.options.hasfriendfoe) then
				t = {
					"text", self.L["TEXT"]["COLORFRIEND"],
					"tooltipTitle", self.L["TEXT"]["COLORFRIEND"],
					"tooltipText", self.L["TOOLTIP"]["COLORFRIEND"],
					"hasColorSwatch", true,
					"r", 1,
					"g", 1,
					"b", 1,
					"colorFunc", function(val, mod, r, g, b, a) ArcHUD.modDB("set", val, mod, {r = r, g = g, b = b}) end,
					"colorArg1", "ColorFriend",
					"colorArg2", self.name
				}
				table.insert(self.parent.dewdrop_menu["L3_"..self.name.."_color"], t)

				t = {
					"text", self.L["TEXT"]["COLORFOE"],
					"tooltipTitle", self.L["TEXT"]["COLORFOE"],
					"tooltipText", self.L["TOOLTIP"]["COLORFOE"],
					"hasColorSwatch", true,
					"r", 1,
					"g", 1,
					"b", 1,
					"colorFunc", function(val, mod, r, g, b, a) ArcHUD.modDB("set", val, mod, {r = r, g = g, b = b}) end,
					"colorArg1", "ColorFoe",
					"colorArg2", self.name
				}
				table.insert(self.parent.dewdrop_menu["L3_"..self.name.."_color"], t)
			elseif(self.options.hasmanabar) then
				t = {
					"text", self.L["TEXT"]["COLORMANA"],
					"tooltipTitle", self.L["TEXT"]["COLORMANA"],
					"tooltipText", self.L["TOOLTIP"]["COLORMANA"],
					"hasColorSwatch", true,
					"r", 1,
					"g", 1,
					"b", 1,
					"colorFunc", function(val, mod, r, g, b, a) ArcHUD.modDB("set", val, mod, {r = r, g = g, b = b}) end,
					"colorArg1", "ColorMana",
					"colorArg2", self.name
				}
				table.insert(self.parent.dewdrop_menu["L3_"..self.name.."_color"], t)

				t = {
					"text", self.L["TEXT"]["COLORRAGE"],
					"tooltipTitle", self.L["TEXT"]["COLORRAGE"],
					"tooltipText", self.L["TOOLTIP"]["COLORRAGE"],
					"hasColorSwatch", true,
					"r", 1,
					"g", 1,
					"b", 1,
					"colorFunc", function(val, mod, r, g, b, a) ArcHUD.modDB("set", val, mod, {r = r, g = g, b = b}) end,
					"colorArg1", "ColorRage",
					"colorArg2", self.name
				}
				table.insert(self.parent.dewdrop_menu["L3_"..self.name.."_color"], t)

				t = {
					"text", self.L["TEXT"]["COLORFOCUS"],
					"tooltipTitle", self.L["TEXT"]["COLORFOCUS"],
					"tooltipText", self.L["TOOLTIP"]["COLORFOCUS"],
					"hasColorSwatch", true,
					"r", 1,
					"g", 1,
					"b", 1,
					"colorFunc", function(val, mod, r, g, b, a) ArcHUD.modDB("set", val, mod, {r = r, g = g, b = b}) end,
					"colorArg1", "ColorFocus",
					"colorArg2", self.name
				}
				table.insert(self.parent.dewdrop_menu["L3_"..self.name.."_color"], t)

				t = {
					"text", self.L["TEXT"]["COLORENERGY"],
					"tooltipTitle", self.L["TEXT"]["COLORENERGY"],
					"tooltipText", self.L["TOOLTIP"]["COLORENERGY"],
					"hasColorSwatch", true,
					"r", 1,
					"g", 1,
					"b", 1,
					"colorFunc", function(val, mod, r, g, b, a) ArcHUD.modDB("set", val, mod, {r = r, g = g, b = b}) end,
					"colorArg1", "ColorEnergy",
					"colorArg2", self.name
				}
				table.insert(self.parent.dewdrop_menu["L3_"..self.name.."_color"], t)
			else
				t = {
					"text", self.L["TEXT"]["COLORSET"],
					"tooltipTitle", self.L["TEXT"]["COLORSET"],
					"tooltipText", self.L["TOOLTIP"]["COLORSET"],
					"hasColorSwatch", true,
					"r", 1,
					"g", 1,
					"b", 1,
					"colorFunc", function(val, mod, r, g, b, a) ArcHUD.modDB("set", val, mod, {r = r, g = g, b = b}) end,
					"colorArg1", "Color",
					"colorArg2", self.name
				}
				table.insert(self.parent.dewdrop_menu["L3_"..self.name.."_color"], t)
			end
		end
	end

	for k,v in ipairs(self.options) do
		if(self.customlocals) then
			if(type(v) == "table") then
				t = {
					"text", v.text,
					"tooltipTitle", v.text,
					"tooltipText", v.tooltip,
					"checked", false,
					"func", ArcHUD.modDB,
					"arg1", "toggle",
					"arg2", v.name,
					"arg3", self.name
				}
				table.insert(self.parent.dewdrop_menu["L2_"..self.name], t)
			end
		else
			if(type(v) == "table") then
				t = {
					"text", self.L["TEXT"][v.text],
					"tooltipTitle", self.L["TEXT"][v.text],
					"tooltipText", self.L["TOOLTIP"][v.tooltip],
					"checked", false,
					"func", ArcHUD.modDB,
					"arg1", "toggle",
					"arg2", v.name,
					"arg3", self.name
				}
				table.insert(self.parent.dewdrop_menu["L2_"..self.name], t)
			end
		end
	end

	t = {
		"text", self.L["TEXT"]["SIDE"],
		"tooltipTitle", self.L["TEXT"]["SIDE"],
		"tooltipText", self.L["TOOLTIP"]["SIDE"],
		"disabled", (not self.options.attach),
		"hasArrow", true,
		"value", "L3_"..self.name
	}
	table.insert(self.parent.dewdrop_menu["L2_"..self.name], t)
	self.parent.dewdrop_menu["L3_"..self.name] = {
		{
			"text", self.L["SIDE"]["LEFT"],
			"isRadio", true,
			"checked", true,
			"func", ArcHUD.modDB,
			"arg1", "set",
			"arg2", "Side",
			"arg3", self.name,
			"arg4", 1
		},
		{
			"text", self.L["SIDE"]["RIGHT"],
			"isRadio", true,
			"checked", false,
			"func", ArcHUD.modDB,
			"arg1", "set",
			"arg2", "Side",
			"arg3", self.name,
			"arg4", 2
		},
	}
	t = {
		"text", self.L["TEXT"]["LEVEL"],
		"tooltipTitle", self.L["TEXT"]["LEVEL"],
		"tooltipText", self.L["TOOLTIP"]["LEVEL"],
		"disabled", (not self.options.attach),
		"hasArrow", true,
		"hasSlider", true,
		"sliderMin", -5,
		"sliderMax", 5,
		"sliderStep", 1,
		"sliderValue", 0,
		"sliderFunc", ArcHUD.modDB,
		"sliderArg1", "set",
		"sliderArg2", "Level",
		"sliderArg3", self.name
	}
	table.insert(self.parent.dewdrop_menu["L2_"..self.name], t)


end
]]--

----------------------------------------------
-- Enabling/Disabling
----------------------------------------------
function ArcHUD.modulePrototype:OnInitialize()
	if(self.Initialize) then
		self:Initialize()
		self:Debug(d_info, "Ring initialized")
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

	self:Debug(d_notice, "Registering Metrognome timers")
	if(not self.parent:MetroStatus(self.name .. "Alpha")) then
		self.parent:RegisterMetro(self.name .. "Alpha", ArcHUDRingTemplate.AlphaUpdate, 0.01, self.f)
	end
	if(not self.parent:MetroStatus(self.name .. "Fade")) then
		self.parent:RegisterMetro(self.name .. "Fade", ArcHUDRingTemplate.DoFadeUpdate, 0.01, self.f)
	end
	if(not self.parent:MetroStatus(self.name .. "Update")) then
		self.parent:RegisterMetro(self.name .. "Update", ArcHUDRingTemplate.UpdateAlpha, 0.05, self)
	end
	self:Debug(d_info, "Ring loaded")
end

----------------------------------------------
-- OnEnable
----------------------------------------------
function ArcHUD.modulePrototype:OnEnable()
	self:Debug(d_notice, "Received enable event")
	if(self.Enable and self.db.profile.Enabled) then
		self:Debug(d_info, "Enabling ring")
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
	self:Debug(d_info, "Disabling ring")
	if(self.disableEvents and self.eventsDisabled) then
		self:Debug(d_notice, "Re-enabling events:")
		for k,v in ipairs(self.disableEvents) do
			local f = getglobal(v.frame)
			if(f) then
				self:Debug(d_notice, "- Frame '"..f:GetName().."':")
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
	if(self.Disable) then
		self:Disable()
	end
	self:RegisterMessage("ARCHUD_MODULE_ENABLE")
	self:RegisterMessage("ARCHUD_MODULE_UPDATE")
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

			if(not self.nocolor) then
				self.ColorMode = self.db.profile.ColorMode
			end

			-- Special treatment for Pet rings
			if(string.find(self.name, "Pet")) then
				self.options.attach = self.db.profile.Attach
			end

			if(self.options.attach) then
				-- Clear all points for the ring
				self.f:ClearAllPoints()
				self.f:SetValue(0)
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
			end

			if(self.Update) then
				self:Debug(d_info, "Updating ring")
				self:Update()
			end
		end
	end
end

----------------------------------------------
-- Ring frame creation and setup
----------------------------------------------
function ArcHUD.modulePrototype:CreateRing(hasBG, parent)
	-- Create frame
	local f = CreateFrame("Frame", nil, parent)
	f:SetFrameStrata("BACKGROUND")
	f:SetFrameLevel(10)
	f:SetWidth(256)
	f:SetHeight(256)

	-- Set up textures
	local t

	f.quadrants = {}

	t = f:CreateTexture(nil, "ARTWORK")
	t:SetTexture("Interface\\Addons\\ArcHUD3\\Icons\\Ring.tga")
	t:SetAllPoints(f)
	f.quadrants[1] = t

	t = f:CreateTexture(nil, "ARTWORK")
	t:SetTexture("Interface\\Addons\\ArcHUD3\\Icons\\Ring.tga")
	t:SetAllPoints(f)
	f.quadrants[2] = t

	t = f:CreateTexture(nil, "ARTWORK")
	t:SetTexture("Interface\\Addons\\ArcHUD3\\Icons\\Ring.tga")
	t:SetAllPoints(f)
	f.chip = t

	t = f:CreateTexture(nil, "ARTWORK")
	t:SetTexture("Interface\\Addons\\ArcHUD3\\Icons\\Slice.tga")
	t:SetAllPoints(f)
	f.slice = t

	-- Set up frame
	ArcHUDRingTemplate:OnLoad(f)

	if(hasBG) then
		-- Create frame
		local fBG = CreateFrame("Frame", nil, f)
		fBG:SetFrameLevel(0)
		fBG:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
		fBG:SetWidth(256)
		fBG:SetHeight(256)

		-- Set up textures
		fBG.quadrants = {}
		t = fBG:CreateTexture(nil, "BACKGROUND")
		t:SetTexture("Interface\\Addons\\ArcHUD3\\Icons\\RingBG.tga")
		t:SetAllPoints(fBG)
		fBG.quadrants[1] = t

		t = fBG:CreateTexture(nil, "BACKGROUND")
		t:SetTexture("Interface\\Addons\\ArcHUD3\\Icons\\RingBG.tga")
		t:SetAllPoints(fBG)
		fBG.quadrants[2] = t

		t = fBG:CreateTexture(nil, "BACKGROUND")
		t:SetTexture("Interface\\Addons\\ArcHUD3\\Icons\\RingBG.tga")
		t:SetAllPoints(fBG)
		fBG.chip = t

		t = fBG:CreateTexture(nil, "BACKGROUND")
		t:SetTexture("Interface\\Addons\\ArcHUD3\\Icons\\Slice.tga")
		t:SetAllPoints(fBG)
		fBG.slice = t

		-- Set up frame
		ArcHUDRingTemplate:OnLoadBG(fBG)

		f.BG = fBG
	end

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
-- color_switch
----------------------------------------------
local color_switch = {
	friendfoe = {
		[1] = function(self) self.f:UpdateColor(self.ColorMode == "default" and self.defaults.ColorFriend or self.db.profile.ColorFriend) end,
		[2] = function(self) self.f:UpdateColor(self.ColorMode == "default" and self.defaults.ColorFoe or self.db.profile.ColorFoe) end,
	},
	manabar = {
		[0] = function(self) self.f:UpdateColor(self.ColorMode == "default" and self.defaults.ColorMana or self.db.profile.ColorMana) end,
		[1] = function(self) self.f:UpdateColor(self.ColorMode == "default" and self.defaults.ColorRage or self.db.profile.ColorRage) end,
		[2] = function(self) self.f:UpdateColor(self.ColorMode == "default" and self.defaults.ColorFocus or self.db.profile.ColorFocus) end,
		[3] = function(self) self.f:UpdateColor(self.ColorMode == "default" and self.defaults.ColorEnergy or self.db.profile.ColorEnergy) end,
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
				color_switch.friendfoe[color](self)
			end
		elseif(self.options.hasmanabar) then
			-- Mana / Rage / Focus / Energy = 0 / 1 / 2 / 3
			if(color_switch.manabar[color]) then
				color_switch.manabar[color](self)
			end
		end
	else
		if(self.ColorMode == "fade") then return end
		self.f:UpdateColor(self.ColorMode == "default" and self.defaults.Color or self.db.profile.Color)
	end
end

----------------------------------------------
-- Return power bar color
----------------------------------------------
function ArcHUD.modulePrototype:GetPowerBarColor(powerType)
	return PowerBarColor[powerType]
end

----------------------------------------------
-- Return power bar color (for text, thus readable colors)
----------------------------------------------
function ArcHUD.modulePrototype:GetPowerBarColorText(powerType)
	if (powerType == 0) then
		return { r = 0.00, g = 1.00, b = 1.00 }
	else
		return PowerBarColor[powerType]
	end
end

function ArcHUD.modulePrototype:CreateStandardModuleOptions(order)
	self.optionsTable = {
		type		= "group",
		name		= LM[self:GetName()],
		order		= order or 100,
		args 		= {
			header = {
				type		= "header",
				name		= LM[self:GetName()] .. " v" .. self.version,
				order		= 0,
			},
			enabled = {
				type		= "toggle",
				name		= LM["TEXT"]["ENABLED"],
				desc		= LM["TOOLTIP"]["ENABLED"],
				order		= 1,
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
			side = {
				type		= "select",
				name		= LM["TEXT"]["SIDE"],
				desc		= LM["TOOLTIP"]["SIDE"],
				values		= {LM["SIDE"]["LEFT"], LM["SIDE"]["RIGHT"]},
				order		= 2,
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
				order		= 3,
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
				order		= 20,
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
	
	-- doesn't work if color mode is "fade"
	if (self.options.hascolor) then
		-- Color
		t = {
			type		= "color",
			name		= LM["TEXT"]["COLOR"],
			desc		= LM["TOOLTIP"]["COLOR"],
			order		= 21,
			get			= function ()
				return self.db.profile.Color.r, self.db.profile.Color.g, self.db.profile.Color.b
			end,
			set			= function (info, r, g, b, a)
				self.db.profile.Color.r, self.db.profile.Color.g, self.db.profile.Color.b = r, g, b
				self:UpdateColor(self.db.profile.Color)
				self:SendMessage("ARCHUD_MODULE_UPDATE", self:GetName())
			end,
		}
		self.optionsTable.args.color = t
		
		-- Reset to default
		t = {
			type		= "execute",
			name		= LM["TEXT"]["COLORRESET"],
			desc		= LM["TOOLTIP"]["COLORRESET"],
			order		= 22,
			func		= function ()
				self.db.profile.Color.r, self.db.profile.Color.g, self.db.profile.Color.b = 
					self.defaults.profile.Color.r, self.defaults.profile.Color.g, self.defaults.profile.Color.b
				self:UpdateColor(self.db.profile.Color)
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
