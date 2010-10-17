
-- Locale object
local L = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Core")
local LM = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Module")

-- Ace config libs
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Debugging levels
--   1 Warning
--   2 Info
--   3 Notice
--   4 Off
local debugLevels = {"warn", "info", "notice", "off"}
local d_warn = 1
local d_info = 2
local d_notice = 3

----------------------------------------------
-- Command line options
----------------------------------------------
ArcHUD.configOptionsTableCmd = {
	type = "group",
	name = "ArcHUD",
	args = {
		reset = {
			type 		= "group",
			name		= "reset",
			desc		= L["CMD_RESET"],
			args		= {
				confirm = {
					type	= "execute",
					name	= "CONFIRM",
					desc	= L["CMD_RESET_CONFIRM"],
					func	= function()
						ArcHUD:ResetOptionsConfirm()
					end
				}
			}
		},
		config = {
			type		= "execute",
			name		= "config",
			desc		= L["CMD_OPTS_FRAME"],
			func		= function()
				AceConfigDialog:Open("ArcHUD_Core")
			end,
		},
		debug = {
			type		= "select",
			name		= "debug",
			desc		= L["CMD_OPTS_DEBUG"],
			values		= {"off", "warn", "info", "notice"},
			get			= function()
				return debugLevels[ArcHUD:GetDebugLevel() or 4]
			end,
			set			= function(info, v)
				if (v == 1) then 
					ArcHUD:SetDebugLevel(nil)
					ArcHUD.db.profile.Debug = nil
				else 
					ArcHUD:SetDebugLevel(v - 1)
					ArcHUD.db.profile.Debug = v
				end
			end,
			order 		= -2,
		},
	},
}

----------------------------------------------
-- Core options
----------------------------------------------
ArcHUD.configOptionsTableCore = {
	type = "group",
	name = L["TEXT"]["TITLE"],
	args = {
		display = {
			type		= "group",
			name		= L["TEXT"]["DISPLAY"],
			order		= 0,
			args		= {
				-- Target Frame
				targetFrame = {
					type		= "toggle",
					name		= L["TEXT"]["TARGETFRAME"],
					desc		= L["TOOLTIP"]["TARGETFRAME"],
					get			= function ()
						return ArcHUD.db.profile.TargetFrame
					end,
					set			= function (info, v)
						ArcHUD.db.profile.TargetFrame = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Player 3d Model
				playerModel = {
					type		= "toggle",
					name		= L["TEXT"]["PLAYERMODEL"],
					desc		= L["TOOLTIP"]["PLAYERMODEL"],
					get			= function ()
						return ArcHUD.db.profile.PlayerModel
					end,
					set			= function (info, v)
						ArcHUD.db.profile.PlayerModel = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Mob 3d Model
				mobModel = {
					type		= "toggle",
					name		= L["TEXT"]["MOBMODEL"],
					desc		= L["TOOLTIP"]["MOBMODEL"],
					get			= function ()
						return ArcHUD.db.profile.MobModel
					end,
					set			= function (info, v)
						ArcHUD.db.profile.MobModel = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Show Guild
				showGuild = {
					type		= "toggle",
					name		= L["TEXT"]["SHOWGUILD"],
					desc		= L["TOOLTIP"]["SHOWGUILD"],
					get			= function ()
						return ArcHUD.db.profile.ShowGuild
					end,
					set			= function (info, v)
						ArcHUD.db.profile.ShowGuild = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Show Class
				showClass = {
					type		= "toggle",
					name		= L["TEXT"]["SHOWCLASS"],
					desc		= L["TOOLTIP"]["SHOWCLASS"],
					get			= function ()
						return ArcHUD.db.profile.ShowClass
					end,
					set			= function (info, v)
						ArcHUD.db.profile.ShowClass = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Show Buffs
				showBuffs = {
					type		= "toggle",
					name		= L["TEXT"]["SHOWBUFFS"],
					desc		= L["TOOLTIP"]["SHOWBUFFS"],
					get			= function ()
						return ArcHUD.db.profile.ShowBuffs
					end,
					set			= function (info, v)
						ArcHUD.db.profile.ShowBuffs = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Show Combo Points
				showComboPoints = {
					type		= "toggle",
					name		= L["TEXT"]["SHOWCOMBO"],
					desc		= L["TOOLTIP"]["SHOWCOMBO"],
					get			= function ()
						return ArcHUD.db.profile.ShowComboPoints
					end,
					set			= function (info, v)
						ArcHUD.db.profile.ShowComboPoints = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Show PvP flag
				showPVP = {
					type		= "toggle",
					name		= L["TEXT"]["SHOWPVP"],
					desc		= L["TOOLTIP"]["SHOWPVP"],
					get			= function ()
						return ArcHUD.db.profile.ShowPVP
					end,
					set			= function (info, v)
						ArcHUD.db.profile.ShowPVP = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Target of target
				targetTarget = {
					type		= "toggle",
					name		= L["TEXT"]["TOT"],
					desc		= L["TOOLTIP"]["TOT"],
					get			= function ()
						return ArcHUD.db.profile.TargetTarget
					end,
					set			= function (info, v)
						ArcHUD.db.profile.TargetTarget = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Target of target of target
				targetTargetTarget = {
					type		= "toggle",
					name		= L["TEXT"]["TOTOT"],
					desc		= L["TOOLTIP"]["TOTOT"],
					get			= function ()
						return ArcHUD.db.profile.TargetTargetTarget
					end,
					set			= function (info, v)
						ArcHUD.db.profile.TargetTargetTarget = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
			},
		}, -- display
		
		nameplates = {
			type		= "group",
			name		= L["TEXT"]["NAMEPLATES"],
			order		= 1,
			args		= {
				-- Player nameplate
				NameplatePlayer = {
					type		= "toggle",
					name		= L["TEXT"]["NPPLAYER"],
					desc		= L["TOOLTIP"]["NPPLAYER"],
					get			= function ()
						return ArcHUD.db.profile.NameplatePlayer
					end,
					set			= function (info, v)
						ArcHUD.db.profile.NameplatePlayer = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Pet nameplate
				NameplatePet = {
					type		= "toggle",
					name		= L["TEXT"]["NPPET"],
					desc		= L["TOOLTIP"]["NPPET"],
					get			= function ()
						return ArcHUD.db.profile.NameplatePet
					end,
					set			= function (info, v)
						ArcHUD.db.profile.NameplatePet = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Target nameplate
				NameplateTarget = {
					type		= "toggle",
					name		= L["TEXT"]["NPTARGET"],
					desc		= L["TOOLTIP"]["NPTARGET"],
					get			= function ()
						return ArcHUD.db.profile.NameplateTarget
					end,
					set			= function (info, v)
						ArcHUD.db.profile.NameplateTarget = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Target of target nameplate
				NameplateTargettarget = {
					type		= "toggle",
					name		= L["TEXT"]["NPTOT"],
					desc		= L["TOOLTIP"]["NPTOT"],
					get			= function ()
						return ArcHUD.db.profile.NameplateTargettarget
					end,
					set			= function (info, v)
						ArcHUD.db.profile.NameplateTargettarget = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Target of target of target nameplate
				NameplateTargettargettarget = {
					type		= "toggle",
					name		= L["TEXT"]["NPTOTOT"],
					desc		= L["TOOLTIP"]["NPTOTOT"],
					get			= function ()
						return ArcHUD.db.profile.NameplateTargettargettarget
					end,
					set			= function (info, v)
						ArcHUD.db.profile.NameplateTargettargettarget = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Target of target of target nameplate
				NameplateCombat = {
					type		= "toggle",
					name		= L["TEXT"]["NPCOMBAT"],
					desc		= L["TOOLTIP"]["NPCOMBAT"],
					get			= function ()
						return ArcHUD.db.profile.NameplateCombat
					end,
					set			= function (info, v)
						ArcHUD.db.profile.NameplateCombat = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
			},
		}, -- nameplates
		
		fade = {
			type		= "group",
			name		= L["TEXT"]["FADE"],
			order		= 2,
			args		= {
			},
		}, -- fade
		
		misc = {
			type		= "group",
			name		= L["TEXT"]["MISC"],
			order		= 3,
			args		= {
			},
		}, -- misc
	},
}

----------------------------------------------
-- Module options
----------------------------------------------
ArcHUD.configOptionsTableModules = {
	type = "group",
	name = LM["TEXT"]["TITLE"],
	args = {},
}

----------------------------------------------
-- Initialize config tools
----------------------------------------------
function ArcHUD:InitConfig()
	-- Set up chat commands
	AceConfig:RegisterOptionsTable("ArcHUD", self.configOptionsTableCmd, {"archud", "ah"})
	
	-- Set up core config options
	AceConfig:RegisterOptionsTable("ArcHUD_Core", self.configOptionsTableCore)
	self.configFrameCore = AceConfigDialog:AddToBlizOptions("ArcHUD_Core", "ArcHUD")
	
	-- Set up modules config options
	AceConfig:RegisterOptionsTable("ArcHUD_Modules", self.configOptionsTableModules)
	self.configFrameModules = AceConfigDialog:AddToBlizOptions("ArcHUD_Modules", LM["TEXT"]["TITLE"], self.configFrameCore)
end

function ArcHUD:AddModuleOptionsTable(moduleName, optionsTable)
	self:LevelDebug(d_notice, "Inserting config options for "..moduleName)
	ArcHUD.configOptionsTableModules.args[moduleName] = optionsTable
end

function ArcHUD:GenerateModuleOption_Enabled(moduleName)
	return {
		type		= "toggle",
		name		= LM["TEXT"]["ENABLED"],
		get			= function ()
			return ArcHUD:GetModule(moduleName).db.profile.Enabled
		end,
		set			= function (info, v)
			ArcHUD:GetModule(moduleName).db.profile.Enabled = v
			if (v) then
				ArcHUD:GetModule(moduleName):Enable()
			else
				ArcHUD:GetModule(moduleName):Disable()
			end
		end,
	}
end

--[[
----------------------------------------------
-- Support Functions
--
function ArcHUD.modDB(action, key, namespace, value)
	if(not action or not key) then return end
	if(namespace and not value and not ArcHUD:HasModule(namespace)) then
		value = namespace
		namespace = nil
	end

	if(action == "toggle") then
		ArcHUD:LevelDebug(d_notice, "Toggling key '%s'", key)
		if(namespace) then
			ArcHUD:AcquireDBNamespace(namespace).profile[key] = not ArcHUD:AcquireDBNamespace(namespace).profile[key]
		else
			ArcHUD.db.profile[key] = not ArcHUD.db.profile[key]
		end
	elseif(action == "set") then
		ArcHUD:LevelDebug(d_notice, "Setting new value for key '%s' = '%s'", key, value)
		if(namespace) then
			if(tonumber(value)) then
				ArcHUD:AcquireDBNamespace(namespace).profile[key] = tonumber(value)
			else
				ArcHUD:AcquireDBNamespace(namespace).profile[key] = value
			end
		else
			if(tonumber(value)) then
				ArcHUD.db.profile[key] = tonumber(value)
			else
				ArcHUD.db.profile[key] = value
			end
		end
	end

	ArcHUD.updating = true
	if(namespace) then
		ArcHUD:TriggerEvent("ARCHUD_MODULE_UPDATE", namespace)
	else
		ArcHUD:OnProfileDisable()
		ArcHUD:OnProfileEnable()
	end
	ArcHUD.updating = nil
end
function ArcHUD.toggleLock(frame)
	if(ArcHUD.movableFrames[frame]) then
		if(ArcHUD.movableFrames[frame].locked) then
			ArcHUD.movableFrames[frame]:Unlock()
		else
			ArcHUD.movableFrames[frame]:Lock()
		end
	end
end
function ArcHUD.resetFrame(frame)
	if(ArcHUD.movableFrames[frame]) then
		ArcHUD.movableFrames[frame]:ResetPos()
	end
end
function ArcHUD.createDDMenu(level, menu, skipfirst)
	if(level == 1) then
		for k,v in ipairs(ArcHUD.dewdrop_menu["L1"]) do
			if(k == 1 and not skipfirst or k > 1) then
				if(type(v) == "table") then
					ArcHUD:LevelDebug(d_notice, "Creating button on level %s", level)
					dewdrop:AddLine(unpack(v))
				else
					ArcHUD:LevelDebug(d_warn, "Error in createDDMenu in level %d (table expected, got %s)", level, type(v))
				end
			end
		end
	else
		if(ArcHUD.dewdrop_menu[menu]) then
			local id, val, arg3, arg4, isradio, iscolor, color_r, color_g, color_b, isdisabled, disabled

			if(menu == "L2_movable") then
				for _,v in ipairs(ArcHUD.dewdrop_menu[menu]) do
					if(type(v) == "table") then
						ArcHUD:LevelDebug(d_notice, "Creating button on level %s in menu %s", level, menu)
						id, val, arg3, arg4, isradio = nil, nil, nil, nil, nil
						for a,b in ipairs(v) do
							if(b == "checked") then
								id = a+1
							elseif(b == "arg1") then
								val = v[a+1]
							end
						end
						if(id) then
							ArcHUD:LevelDebug(d_notice, "  Found value on '%d', setting name '%s'", id, val)
							v[id] = not ArcHUD.movableFrames[val].locked
							ArcHUD:LevelDebug(d_notice, "  Value set to '%s'", v[id])
						end
						dewdrop:AddLine(unpack(v))
					else
						ArcHUD:LevelDebug(d_warn, "Error in createDDMenu in level %d (table expected, got %s)", level, type(v))
					end
				end
			else
				for _,v in ipairs(ArcHUD.dewdrop_menu[menu]) do
					if(type(v) == "table") then
						ArcHUD:LevelDebug(d_notice, "Creating button on level %s in menu %s", level, menu)
						id, val, arg3, arg4, isradio, iscolor, color_r, color_g, color_b, disabled = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
						for a,b in ipairs(v) do
							--ArcHUD:LevelDebug(d_notice, "  ID: %d, Value: %s", a, (type(b) == "function" and "function" or b))
							if(b == "checked" or b == "sliderValue") then
								id = a+1
							elseif(b == "r") then
								color_r = a+1
							elseif(b == "g") then
								color_g = a+1
							elseif(b == "b") then
								color_b = a+1
							elseif(b == "isRadio" and v[a+1]) then
								isradio = true
							elseif(b == "hasColorSwatch" and v[a+1]) then
								iscolor = true
							elseif(b == "arg2" or b == "sliderArg2" or b == "colorArg1") then
								val = v[a+1]
							elseif(b == "arg3" or b == "sliderArg3" or b == "colorArg2") then
								arg3 = v[a+1]
							elseif(b == "arg4" or b == "sliderArg4") then
								arg4 = v[a+1]
							elseif(b == "disabled") then
								disabled = a+1
							end
						end
						if(id) then
							ArcHUD:LevelDebug(d_notice, "  Found value on '%d', setting name '%s'", id, val)
							if(isradio) then
								if(arg4) then
									ArcHUD:LevelDebug(d_notice, "  Using namespace '%s'", arg3)
									v[id] = (ArcHUD:AcquireDBNamespace(arg3).profile[val] == arg4 and true or false)
									ArcHUD:LevelDebug(d_notice, "  Value set to '%s'", v[id])
								else
									v[id] = (ArcHUD.db.profile[val] == arg3 and true or false)
									ArcHUD:LevelDebug(d_notice, "  Value set to '%s'", v[id])
								end
							else
								if(arg3) then
									ArcHUD:LevelDebug(d_notice, "  Using namespace '%s'", arg3)
									v[id] = ArcHUD:AcquireDBNamespace(arg3).profile[val]
									-- Special treatment for Pet rings
									if(string.find(menu, "Pet") and val == "Attach") then
										isdisabled = not ArcHUD:AcquireDBNamespace(arg3).profile[val]
									end
									ArcHUD:LevelDebug(d_notice, "  Value set to '%s'", v[id])
								else
									v[id] = ArcHUD.db.profile[val]
									ArcHUD:LevelDebug(d_notice, "  Value set to '%s'", v[id])
								end
							end
						elseif(iscolor and color_r and color_g and color_b) then
							ArcHUD:LevelDebug(d_notice, "  Found values on '%d/%d/%d', setting name '%s'", color_r, color_g, color_b, val)
							if(arg3) then
								ArcHUD:LevelDebug(d_notice, "  Using namespace '%s'", arg3)
								v[color_r] = ArcHUD:AcquireDBNamespace(arg3).profile[val].r
								v[color_g] = ArcHUD:AcquireDBNamespace(arg3).profile[val].g
								v[color_b] = ArcHUD:AcquireDBNamespace(arg3).profile[val].b
								ArcHUD:LevelDebug(d_notice, "  Value set to '%d/%d/%d'", v[color_r], v[color_g], v[color_b])
							else
								v[color_r] = ArcHUD.db.profile[val].r
								v[color_g] = ArcHUD.db.profile[val].g
								v[color_b] = ArcHUD.db.profile[val].b
								ArcHUD:LevelDebug(d_notice, "  Value set to '%d/%d/%d'", v[color_r], v[color_g], v[color_b])
							end
						end

						-- Special treatment for Pet rings
						if(string.find(menu, "Pet") and disabled) then
							v[disabled] = isdisabled
						end
						dewdrop:AddLine(unpack(v))
					else
						ArcHUD:LevelDebug(d_warn, "Error in createDDMenu in level %d (table expected, got %s)", level, type(v))
					end
				end
			end
		end
	end
end
]]--
