
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
		modules = {
			type		= "execute",
			name		= "config",
			desc		= L["CMD_OPTS_MODULES"],
			func		= function()
				AceConfigDialog:Open("ArcHUD_Modules")
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
		info1 = {
			type		= "description",
			name		= "Version "..ArcHUD.version..", code name "..ArcHUD.codename,
			order		= 0,
		},
		info2 = {
			type		= "description",
			name		= "Authors: "..ArcHUD.authors,
			order		= 1,
		},
		header = {
			type		= "header",
			name		= "General settings",
			order		= 2,
		},
		display = {
			type		= "group",
			name		= L["TEXT"]["DISPLAY"],
			order		= 10,
			args		= {
				-- Target Frame
				targetFrame = {
					type		= "toggle",
					name		= L["TEXT"]["TARGETFRAME"],
					desc		= L["TOOLTIP"]["TARGETFRAME"],
					order		= 0,
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
					order		= 1,
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
					order		= 2,
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
					order		= 3,
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
					order		= 4,
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
					order		= 5,
					get			= function ()
						return ArcHUD.db.profile.ShowBuffs
					end,
					set			= function (info, v)
						ArcHUD.db.profile.ShowBuffs = v
						if(ArcHUD.db.profile.ShowBuffs) then
							ArcHUD:RegisterEvent("UNIT_AURA", "TargetAuras")
						else
							ArcHUD:UnregisterEvent("UNIT_AURA")
							for i=1,16 do
								ArcHUD.TargetHUD["Buff"..i]:Hide()
								ArcHUD.TargetHUD["Debuff"..i]:Hide()
							end
						end
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Show PvP flag
				showPVP = {
					type		= "toggle",
					name		= L["TEXT"]["SHOWPVP"],
					desc		= L["TOOLTIP"]["SHOWPVP"],
					order		= 6,
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
					order		= 7,
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
					order		= 8,
					get			= function ()
						return ArcHUD.db.profile.TargetTargetTarget
					end,
					set			= function (info, v)
						ArcHUD.db.profile.TargetTargetTarget = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Blizzard player frame
				blizzPlayer = {
					type		= "toggle",
					name		= L["TEXT"]["BLIZZPLAYER"],
					desc		= L["TOOLTIP"]["BLIZZPLAYER"],
					order		= 9,
					get			= function ()
						return ArcHUD.db.profile.BlizzPlayer
					end,
					set			= function (info, v)
						ArcHUD.db.profile.BlizzPlayer = v
						ArcHUD:HideBlizzardPlayer(v)
					end,
				},
				-- Blizzard target frame
				blizzTarget = {
					type		= "toggle",
					name		= L["TEXT"]["BLIZZTARGET"],
					desc		= L["TOOLTIP"]["BLIZZTARGET"],
					order		= 10,
					get			= function ()
						return ArcHUD.db.profile.BlizzTarget
					end,
					set			= function (info, v)
						ArcHUD.db.profile.BlizzTarget = v
						ArcHUD:HideBlizzardTarget(v)
					end,
				},
				-- Blizzard focus frame
				blizzFocus = {
					type		= "toggle",
					name		= L["TEXT"]["BLIZZFOCUS"],
					desc		= L["TOOLTIP"]["BLIZZFOCUS"],
					order		= 10,
					get			= function ()
						return ArcHUD.db.profile.BlizzFocus
					end,
					set			= function (info, v)
						ArcHUD.db.profile.BlizzFocus = v
						ArcHUD:HideBlizzardFocus(v)
					end,
				},
			},
		}, -- display
		
		comboPoints = {
			type		= "group",
			name		= L["TEXT"]["COMBOPOINTS"],
			order		= 11,
			args		= {
				-- Show Combo Points
				showComboPoints = {
					type		= "toggle",
					name		= L["TEXT"]["SHOWCOMBO"],
					desc		= L["TOOLTIP"]["SHOWCOMBO"],
					order		= 0,
					get			= function ()
						return ArcHUD.db.profile.ShowComboPoints
					end,
					set			= function (info, v)
						ArcHUD.db.profile.ShowComboPoints = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				comboPointsDecay = {
					type		= "range",
					name		= L["TEXT"]["COMBODECAY"],
					desc		= L["TOOLTIP"]["COMBODECAY"],
					min			= 0.0,
					max			= 10.0,
					step		= 0.1,
					order		= 1,
					get			= function ()
						return ArcHUD.db.profile.OldComboPointsDecay
					end,
					set			= function (info, v)
						ArcHUD.db.profile.OldComboPointsDecay = v
						ArcHUD:UnregisterMetro("RemoveOldComboPoints")
						ArcHUD:RegisterMetro("RemoveOldComboPoints", ArcHUD.RemoveOldComboPoints, ArcHUD.db.profile.OldComboPointsDecay, ArcHUD)
						ArcHUD:SendMessage("ARCHUD_MODULE_UPDATE", "ComboPoints")
					end,
				},
				-- Holy Power as Combo Points
				ShowHolyPowerPoints = {
					type		= "toggle",
					name		= L["TEXT"]["HOLYPOWERCOMBO"],
					desc		= L["TOOLTIP"]["HOLYPOWERCOMBO"],
					order		= 10,
					get			= function ()
						return ArcHUD.db.profile.ShowHolyPowerPoints
					end,
					set			= function (info, v)
						ArcHUD.db.profile.ShowHolyPowerPoints = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Soul Shards as Combo Points
				ShowSoulShardPoints = {
					type		= "toggle",
					name		= L["TEXT"]["SOULSHARDCOMBO"],
					desc		= L["TOOLTIP"]["SOULSHARDCOMBO"],
					order		= 11,
					get			= function ()
						return ArcHUD.db.profile.ShowSoulShardPoints
					end,
					set			= function (info, v)
						ArcHUD.db.profile.ShowSoulShardPoints = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
			},
			
		}, -- comboPoints
		
		nameplates = {
			type		= "group",
			name		= L["TEXT"]["NAMEPLATES"],
			order		= 12,
			args		= {
				-- Nameplates in combat
				NameplateCombat = {
					type		= "toggle",
					name		= L["TEXT"]["NPCOMBAT"],
					desc		= L["TOOLTIP"]["NPCOMBAT"],
					order		= 10,
					get			= function ()
						return ArcHUD.db.profile.NameplateCombat
					end,
					set			= function (info, v)
						ArcHUD.db.profile.NameplateCombat = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Separator
				NameplatePlayerSep = {
					type		= "header",
					name		= L["TEXT"]["NPPLAYEROPT"],
					order		= 11,
				},
				-- Player nameplate
				NameplatePlayer = {
					type		= "toggle",
					name		= L["TEXT"]["NPPLAYER"],
					desc		= L["TOOLTIP"]["NPPLAYER"],
					order		= 12,
					get			= function ()
						return ArcHUD.db.profile.Nameplate_player
					end,
					set			= function (info, v)
						ArcHUD:UpdateNameplateSetting("player", v)
					end,
				},
				-- Pet nameplate
				NameplatePet = {
					type		= "toggle",
					name		= L["TEXT"]["NPPET"],
					desc		= L["TOOLTIP"]["NPPET"],
					order		= 13,
					get			= function ()
						return ArcHUD.db.profile.Nameplate_pet
					end,
					set			= function (info, v)
						ArcHUD:UpdateNameplateSetting("pet", v)
					end,
				},
				-- Pet nameplate
				PetNameplateFade = {
					type		= "toggle",
					name		= L["TEXT"]["PETNPFADE"],
					desc		= L["TOOLTIP"]["PETNPFADE"],
					order		= 14,
					get			= function ()
						return ArcHUD.db.profile.PetNameplateFade
					end,
					set			= function (info, v)
						ArcHUD.db.profile.PetNameplateFade = v
						if ((not ArcHUD.Nameplates.pet.state) and ArcHUD.db.profile.PetNameplateFade and (self.Nameplates.pet.alpha > 0)) then
							ArcHUDRingTemplate.SetRingAlpha(self.Nameplates.pet, alpha)
						end
					end,
				},
				-- Player/pet nameplates hover delay
				NameplateHoverMsg = {
					type		= "toggle",
					name		= L["TEXT"]["HOVERMSG"],
					desc		= L["TOOLTIP"]["HOVERMSG"],
					order		= 15,
					get			= function ()
						return ArcHUD.db.profile.HoverMsg
					end,
					set			= function (info, v)
						ArcHUD.db.profile.HoverMsg = v
					end,
				},
				-- Player/pet nameplates hover delay
				NameplateHoverDelay = {
					type		= "range",
					name		= L["TEXT"]["HOVERDELAY"],
					desc		= L["TOOLTIP"]["HOVERDELAY"],
					min			= 0,
					max			= 5,
					step		= 0.1,
					order		= 16,
					get			= function ()
						return ArcHUD.db.profile.HoverDelay
					end,
					set			= function (info, v)
						ArcHUD.db.profile.HoverDelay = v
						ArcHUD:RestartNamePlateTimers()
					end,
				},
				-- Separator
				NameplateTargetSep = {
					type		= "header",
					name		= L["TEXT"]["NPTARGETOPT"],
					order		= 20,
				},
				-- Target nameplate
				NameplateTarget = {
					type		= "toggle",
					name		= L["TEXT"]["NPTARGET"],
					desc		= L["TOOLTIP"]["NPTARGET"],
					order		= 21,
					get			= function ()
						return ArcHUD.db.profile.Nameplate_target
					end,
					set			= function (info, v)
						ArcHUD:UpdateNameplateSetting("target", v)
					end,
				},
				-- Target of target nameplate
				NameplateTargettarget = {
					type		= "toggle",
					name		= L["TEXT"]["NPTOT"],
					desc		= L["TOOLTIP"]["NPTOT"],
					order		= 22,
					get			= function ()
						return ArcHUD.db.profile.Nameplate_targettarget
					end,
					set			= function (info, v)
						ArcHUD:UpdateNameplateSetting("targettarget", v)
					end,
				},
				-- Target of target of target nameplate
				NameplateTargettargettarget = {
					type		= "toggle",
					name		= L["TEXT"]["NPTOTOT"],
					desc		= L["TOOLTIP"]["NPTOTOT"],
					order		= 23,
					get			= function ()
						return ArcHUD.db.profile.Nameplate_targettargettarget
					end,
					set			= function (info, v)
						ArcHUD:UpdateNameplateSetting("targettargettarget", v)
					end,
				},
			},
		}, -- nameplates
		
		fade = {
			type		= "group",
			name		= L["TEXT"]["FADE"],
			order		= 13,
			args		= {
				-- FadeIC
				FadeIC = {
					type		= "range",
					min			= 0.0,
					max			= 1.0,
					step		= 0.1,
					name		= L["TEXT"]["FADE_IC"],
					desc		= L["TOOLTIP"]["FADE_IC"],
					order		= 0,
					get			= function ()
						return ArcHUD.db.profile.FadeIC
					end,
					set			= function (info, v)
						ArcHUD.db.profile.FadeIC = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- FadeOOC
				FadeOOC = {
					type		= "range",
					min			= 0.0,
					max			= 1.0,
					step		= 0.1,
					name		= L["TEXT"]["FADE_OOC"],
					desc		= L["TOOLTIP"]["FADE_OOC"],
					order		= 1,
					get			= function ()
						return ArcHUD.db.profile.FadeOOC
					end,
					set			= function (info, v)
						ArcHUD.db.profile.FadeOOC = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- FadeFull
				FadeFull = {
					type		= "range",
					min			= 0.0,
					max			= 1.0,
					step		= 0.1,
					name		= L["TEXT"]["FADE_FULL"],
					desc		= L["TOOLTIP"]["FADE_FULL"],
					order		= 2,
					get			= function ()
						return ArcHUD.db.profile.FadeFull
					end,
					set			= function (info, v)
						ArcHUD.db.profile.FadeFull = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
			},
		}, -- fade
		
		misc = {
			type		= "group",
			name		= L["TEXT"]["MISC"],
			order		= 14,
			args		= {
				-- Scaling
				Scale = {
					type		= "range",
					min			= 0.2,
					max			= 2.0,
					step		= 0.1,
					name		= L["TEXT"]["SCALE"],
					desc		= L["TOOLTIP"]["SCALE"],
					order		= 0,
					get			= function ()
						return ArcHUD.db.profile.Scale
					end,
					set			= function (info, v)
						ArcHUD.db.profile.Scale = v
						ArcHUDFrame:SetScale(v)
					end,
				},
				-- YLoc
				YLoc = {
					type		= "range",
					min			= -500,
					max			= 500,
					step		= 1,
					name		= L["TEXT"]["YLOC"],
					desc		= L["TOOLTIP"]["YLOC"],
					order		= 1,
					get			= function ()
						return ArcHUD.db.profile.YLoc
					end,
					set			= function (info, v)
						ArcHUD.db.profile.YLoc = v
						ArcHUDFrame:ClearAllPoints()
						ArcHUDFrame:SetPoint("CENTER", WorldFrame, "CENTER", ArcHUD.db.profile.XLoc, ArcHUD.db.profile.YLoc)
					end,
				},
				-- XLoc
				XLoc = {
					type		= "range",
					min			= -500,
					max			= 500,
					step		= 1,
					name		= L["TEXT"]["XLOC"],
					desc		= L["TOOLTIP"]["XLOC"],
					order		= 2,
					get			= function ()
						return ArcHUD.db.profile.XLoc
					end,
					set			= function (info, v)
						ArcHUD.db.profile.XLoc = v
						ArcHUDFrame:ClearAllPoints()
						ArcHUDFrame:SetPoint("CENTER", WorldFrame, "CENTER", ArcHUD.db.profile.XLoc, ArcHUD.db.profile.YLoc)
					end,
				},
				-- Width
				Width = {
					type		= "range",
					min			= 0,
					max			= 500,
					step		= 1,
					name		= L["TEXT"]["WIDTH"],
					desc		= L["TOOLTIP"]["WIDTH"],
					order		= 3,
					get			= function ()
						return ArcHUD.db.profile.Width
					end,
					set			= function (info, v)
						ArcHUD.db.profile.Width = v
						-- Position the HUD according to user settings
						anchorModule = ArcHUD:GetModule("Anchors", true)
						if not (anchorModule == nil) then
							ArcHUD:GetModule("Anchors").Left:ClearAllPoints()
							ArcHUD:GetModule("Anchors").Left:SetPoint("TOPLEFT", ArcHUDFrame, "TOPLEFT", 0-ArcHUD.db.profile.Width, 0)
							ArcHUD:GetModule("Anchors").Right:ClearAllPoints()
							ArcHUD:GetModule("Anchors").Right:SetPoint("TOPLEFT", ArcHUDFrame, "TOPRIGHT", ArcHUD.db.profile.Width, 0)
						end
					end,
				},
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
	self.configFrameCore = AceConfigDialog:AddToBlizOptions("ArcHUD_Core", "ArcHUD ("..ArcHUD.codename..")")
	
	-- Set up modules config options
	AceConfig:RegisterOptionsTable("ArcHUD_Modules", self.configOptionsTableModules)
	self.configFrameModules = AceConfigDialog:AddToBlizOptions("ArcHUD_Modules", LM["TEXT"]["TITLE"], "ArcHUD_Core")
end

function ArcHUD:AddModuleOptionsTable(moduleName, optionsTable)
	self:LevelDebug(d_notice, "Inserting config options for "..moduleName)
	ArcHUD.configOptionsTableModules.args[moduleName] = optionsTable
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
