
-- Locale object
local L = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Core")
local LM = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Module")

-- Ace config libs
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

-- List of profiles
local profilesTable = {}
local function ArcHUD_updateProfilesTable()
	while #profilesTable > 1 do
		table.remove(profilesTable)
	end
	local pt = ArcHUD.db:GetProfiles()
	for i,p in ipairs(pt) do
		if not (p == "profile") then
			table.insert(profilesTable, p)
		end
	end
end

-- Debugging levels
--   1 Warning
--   2 Info
--   3 Notice
--   4 Off
local debugLevels = {"warn", "info", "notice", "off"}
local d_warn = 1
local d_info = 2
local d_notice = 3

local testSwitch = false

----------------------------------------------
-- Command line options
----------------------------------------------
ArcHUD.configOptionsTableCmd = {
	type = "group",
	name = "ArcHUD",
	args = {
		config = {
			type		= "execute",
			name		= "config",
			desc		= L["CMD_OPTS_FRAME"],
			order		= 0,
			func		= function()
				AceConfigDialog:Open("ArcHUD_Core")
			end,
		},
		modules = {
			type		= "execute",
			name		= "modules",
			desc		= L["CMD_OPTS_MODULES"],
			order		= 1,
			func		= function()
				AceConfigDialog:Open("ArcHUD_Modules")
			end,
		},
		custom = {
			type		= "execute",
			name		= "custom",
			desc		= L["CMD_OPTS_CUSTOM"],
			order		= 2,
			func		= function()
				AceConfigDialog:Open("ArcHUD_CustomModules")
			end,
		},
		toggle = {
			type		= "execute",
			name		= "toggle",
			desc		= L["CMD_OPTS_TOGGLE"],
			order		= 3,
			func		= function()
				if ArcHUDFrame:IsVisible() then
					ArcHUDFrame:Hide()
				else
					ArcHUDFrame:Show()
				end
			end,
		},
		reset = {
			type 		= "group",
			name		= "reset",
			desc		= L["CMD_RESET"],
			order		= 4,
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
		debug = {
			type		= "select",
			name		= "debug",
			desc		= L["CMD_OPTS_DEBUG"],
			order		= 5,
			values		= {"warn", "info", "notice", "off"},
			get			= function()
				return debugLevels[ArcHUD:GetDebugLevel() or 4]
			end,
			set			= function(info, v)
				if (v == 1) then 
					ArcHUD:SetDebugLevel(nil)
					ArcHUD.db.profile.Debug = nil
				else 
					ArcHUD:SetDebugLevel(v)
					ArcHUD.db.profile.Debug = v
				end
			end,
		},
--[[		perf = {
			type		= "execute",
			name		= "config",
			desc		= "Show performance infos on timers (developers only!)",
			order		= 10,
			func		= function()
				ArcHUD:TimersPrintPerf()
			end,
		},
		test = {
			type		= "execute",
			name		= "test",
			desc		= "Internal testing of some functions (developers only!)",
			order		= 11,
			func		= function()
				if ArcHUD.UnitFrames then
					if (not testSwitch) then
						if not (ArcHUD.UnitFrames["target"]) then
							ArcHUD:UF_Create("target")
						end
						for k,v in pairs(ArcHUD.UnitFrames) do
							v:Show()
						end
					else
						for k,v in pairs(ArcHUD.UnitFrames) do
							v:Hide()
						end
					end
					testSwitch = not testSwitch
				end
			end,
		},]]
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
			name		= L["Version"].." "..ArcHUD.version..", code name "..ArcHUD.codename,
			order		= 0,
		},
		info2 = {
			type		= "description",
			name		= L["Authors"]..": "..ArcHUD.authors,
			order		= 1,
		},
		header = {
			type		= "header",
			name		= L["TEXT"]["GENERAL"],
			order		= 2,
		},
		profiles = {
			type		= "group",
			name		= L["TEXT"]["PROFILES"],
			order		= 9,
			args		= {
				selectProfile = {
					type	= "select",
					name	= L["TEXT"]["PROFILES_SELECT"],
					desc	= L["TOOLTIP"]["PROFILES_SELECT"],
					order	= 1,
					values	= profilesTable,
					get		= function (info)
						local p = ArcHUD.db:GetCurrentProfile()
						if p == "profile" then
							return 1
						else
							for i,v in ipairs(profilesTable) do
								if v == p then
									return i
								end
							end
						end
					end,
					set		= function (info, value)
						if value == 1 then
							ArcHUD.db:SetProfile("profile")
						else
							ArcHUD.db:SetProfile(profilesTable[value])
						end
					end,
				},
				createProfile = {
					type	= "input",
					name	= L["TEXT"]["PROFILES_CREATE"],
					desc	= L["TOOLTIP"]["PROFILES_CREATE"],
					order	= 2,
					get		= function ()
						return ""
					end,
					set		= function (info, value)
						if value and not (value == "") then
							if value == "profile" then -- default profile
								ArcHUD:Print(L["TEXT"]["PROFILES_EXISTS"])
								return
							end
							for i,v in ipairs(profilesTable) do
								if v == value then
									ArcHUD:Print(L["TEXT"]["PROFILES_EXISTS"])
									return
								end
							end
							local oldprofile = ArcHUD.db:GetCurrentProfile()
							ArcHUD.db:SetProfile(value)
							ArcHUD.db:CopyProfile(oldprofile)
							ArcHUD_updateProfilesTable()
						end
					end,
				},
				deleteProfile = {
					type	= "execute",
					name	= L["TEXT"]["PROFILES_DELETE"],
					desc	= L["TOOLTIP"]["PROFILES_DELETE"],
					order	= 3,
					func	= function ()
						local oldprofile = ArcHUD.db:GetCurrentProfile()
						if (oldprofile == "profile") then
							ArcHUD:Print(L["TEXT"]["PROFILES_CANNOTDELETE"])
						else
							ArcHUD.db:SetProfile("profile") -- default profile
							ArcHUD.db:DeleteProfile(oldprofile)
							ArcHUD_updateProfilesTable()
						end
					end,
				},
			},
		},
		display = {
			type		= "group",
			name		= L["TEXT"]["DISPLAY"],
			order		= 10,
			args		= {
				-- Player Frame
				playerFrame = {
					type		= "toggle",
					name		= L["TEXT"]["PLAYERFRAME"],
					desc		= L["TOOLTIP"]["PLAYERFRAME"],
					order		= 0,
					get			= function ()
						return ArcHUD.db.profile.PlayerFrame
					end,
					set			= function (info, v)
						ArcHUD.db.profile.PlayerFrame = v
						if (v) then
							ArcHUD.Nameplates.player:Show()
							ArcHUD.Nameplates.pet:Show()
						else
							ArcHUD.Nameplates.player:Hide()
							ArcHUD.Nameplates.pet:Hide()
						end
					end,
				},
				-- Target Frame
				targetFrame = {
					type		= "toggle",
					name		= L["TEXT"]["TARGETFRAME"],
					desc		= L["TOOLTIP"]["TARGETFRAME"],
					order		= 1,
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
					order		= 2,
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
					order		= 3,
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
					order		= 4,
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
					order		= 5,
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
					order		= 6,
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
				-- Show only buffs cast by player
				showOnlyBuffsCastByPlayer = {
					type		= "toggle",
					name		= L["TEXT"]["SHOWONLYBUFFSCASTBYPLAYER"],
					desc		= L["TOOLTIP"]["SHOWONLYBUFFSCASTBYPLAYER"],
					order		= 7,
					get			= function ()
						return ArcHUD.db.profile.ShowOnlyBuffsCastByPlayer
					end,
					set			= function (info, v)
						ArcHUD.db.profile.ShowOnlyBuffsCastByPlayer = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Show Buff tooltips
				showBuffTooltips = {
					type		= "toggle",
					name		= L["TEXT"]["SHOWBUFFTT"],
					desc		= L["TOOLTIP"]["SHOWBUFFTT"],
					order		= 8,
					get			= function ()
						return ArcHUD.db.profile.ShowBuffTooltips
					end,
					set			= function (info, v)
						ArcHUD.db.profile.ShowBuffTooltips = v
					end,
				},
				-- Hide Buff tooltips in combat
				hideBuffTooltipsIC = {
					type		= "toggle",
					name		= L["TEXT"]["HIDEBUFFTTIC"],
					desc		= L["TOOLTIP"]["HIDEBUFFTTIC"],
					order		= 9,
					get			= function ()
						return ArcHUD.db.profile.HideBuffTooltipsIC
					end,
					set			= function (info, v)
						ArcHUD.db.profile.HideBuffTooltipsIC = v
					end,
				},
				-- Buff icon size
				buffIconSize = {
					type		= "range",
					name		= L["TEXT"]["BUFFICONSIZE"],
					desc		= L["TOOLTIP"]["BUFFICONSIZE"],
					min			= 16,
					max			= 40,
					step		= 4,
					order		= 10,
					get			= function ()
						return ArcHUD.db.profile.BuffIconSize
					end,
					set			= function (info, v)
						ArcHUD.db.profile.BuffIconSize = v
						-- update buff icons
						for i=1,16 do
							ArcHUDFrame.TargetHUD["Buff"..i]:SetWidth(v)
							ArcHUDFrame.TargetHUD["Buff"..i]:SetHeight(v)
						end
						for i=1,16 do
							ArcHUDFrame.TargetHUD["Debuff"..i]:SetWidth(v)
							ArcHUDFrame.TargetHUD["Debuff"..i]:SetHeight(v)
						end
					end,
				},
				-- Show PvP flag
				showPVP = {
					type		= "toggle",
					name		= L["TEXT"]["SHOWPVP"],
					desc		= L["TOOLTIP"]["SHOWPVP"],
					order		= 11,
					get			= function ()
						return ArcHUD.db.profile.ShowPVP
					end,
					set			= function (info, v)
						ArcHUD.db.profile.ShowPVP = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Show health/power maximum text
				ShowHealthPowerTextMax = {
					type		= "toggle",
					name		= L["TEXT"]["SHOWTEXTMAX"],
					desc		= L["TOOLTIP"]["SHOWTEXTMAX"],
					order		= 12,
					get			= function ()
						return ArcHUD.db.profile.ShowHealthPowerTextMax
					end,
					set			= function (info, v)
						ArcHUD.db.profile.ShowHealthPowerTextMax = v
						ArcHUD:UpdateTargetHUD()
					end,
				},
				-- Target of target
				targetTarget = {
					type		= "toggle",
					name		= L["TEXT"]["TOT"],
					desc		= L["TOOLTIP"]["TOT"],
					order		= 13,
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
					order		= 14,
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
			order		= 11,
			args		= {
				-- Hint
				NameplateHint = {
					type		= "description",
					name		= L["TEXT"]["NPHINT"],
					order		= 1,
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
			order		= 12,
			args		= {
				-- Fade behaviour
				ringvis = {
					type		= "select",
					name		= L["TEXT"]["RINGVIS"],
					desc		= L["TOOLTIP"]["RINGVIS"],
					values		= {L["TEXT"]["RINGVIS_1"], L["TEXT"]["RINGVIS_2"], L["TEXT"]["RINGVIS_3"]},
					order		= 0,
					get			= function ()
						return ArcHUD.db.profile.RingVisibility
					end,
					set			= function (info, v)
						ArcHUD.db.profile.RingVisibility = v
					end,
				},
				-- FadeIC
				FadeIC = {
					type		= "range",
					min			= 0.0,
					max			= 1.0,
					step		= 0.05,
					name		= L["TEXT"]["FADE_IC"],
					desc		= L["TOOLTIP"]["FADE_IC"],
					order		= 1,
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
					step		= 0.05,
					name		= L["TEXT"]["FADE_OOC"],
					desc		= L["TOOLTIP"]["FADE_OOC"],
					order		= 2,
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
					step		= 0.05,
					name		= L["TEXT"]["FADE_FULL"],
					desc		= L["TOOLTIP"]["FADE_FULL"],
					order		= 3,
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
		
		positioning = {
			type		= "group",
			name		= L["TEXT"]["POSITIONING"],
			order		= 13,
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
				-- Scaling of TargetFrame
				ScaleTargetFrame = {
					type		= "range",
					min			= 0.2,
					max			= 2.0,
					step		= 0.1,
					name		= L["TEXT"]["SCALETARGETFRAME"],
					desc		= L["TOOLTIP"]["SCALETARGETFRAME"],
					order		= 1,
					get			= function ()
						return ArcHUD.db.profile.ScaleTargetFrame
					end,
					set			= function (info, v)
						ArcHUD.db.profile.ScaleTargetFrame = v
						ArcHUD.TargetHUD:SetScale(v)
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
					order		= 2,
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
					order		= 3,
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
					order		= 4,
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
				header1 = {
					type		= "header",
					name		= L["TEXT"]["TARGETFRAME"],
					order		= 10,
				},
				-- Attach to top
				attachTop = {
					type		= "toggle",
					name		= L["TEXT"]["ATTACHTOP"],
					desc		= L["TOOLTIP"]["ATTACHTOP"],
					order		= 11,
					get			= function ()
						return ArcHUD.db.profile.AttachTop
					end,
					set			= function (info, v)
						ArcHUD.db.profile.AttachTop = v
						if (v) then
							ArcHUD.TargetHUD:ClearAllPoints()
							ArcHUD.TargetHUD:SetPoint("BOTTOM", ArcHUD.TargetHUD:GetParent(), "TOP", 0, -100)
						else
							ArcHUD.TargetHUD:ClearAllPoints()
							ArcHUD.TargetHUD:SetPoint("TOP", ArcHUD.TargetHUD:GetParent(), "BOTTOM", 0, -60)
						end
					end,
				},
				-- Unlock frames
				unlock = {
					type		= "toggle",
					name		= L["TEXT"]["MFUNLOCK"],
					desc		= L["TOOLTIP"]["MFUNLOCK"],
					order		= 12,
					get			= function ()
						return not ArcHUD.TargetHUD.locked
					end,
					set			= function (info, v)
						if (v) then
							ArcHUD.TargetHUD:Unlock()
							ArcHUD.TargetHUD.Target:Unlock()
							ArcHUD.TargetHUD.TargetTarget:Unlock()
						else
							ArcHUD.TargetHUD:Lock()
							ArcHUD.TargetHUD.Target:Lock()
							ArcHUD.TargetHUD.TargetTarget:Lock()
						end
					end,
				},
				-- Reset frames
				reset = {
					type		= "execute",
					name		= L["TEXT"]["MFRESET"],
					desc		= L["TOOLTIP"]["MFRESET"],
					order		= 13,
					func		= function ()
						ArcHUD.TargetHUD:ResetPos()
						ArcHUD.TargetHUD.Target:ResetPos()
						ArcHUD.TargetHUD.TargetTarget:ResetPos()
					end,
				},
			},
		}, -- positioning
		
		comboPoints = {
			type		= "group",
			name		= L["TEXT"]["COMBOPOINTS"],
			order		= 14,
			args		= {
				info1 = {
					type		= "description",
					name		= L["TEXT"]["COMBOPOINTSSETTINGS1"],
					order		= 0,
				},
				info2 = {
					type		= "description",
					name		= L["TEXT"]["COMBOPOINTSSETTINGS2"],
					order		= 1,
				},
			},			
		}, -- comboPoints
		
		misc = {
			type		= "group",
			name		= L["TEXT"]["MISC"],
			order		= 20,
			args		= {
				-- Blizzard player frame
				blizzPlayer = {
					type		= "toggle",
					name		= L["TEXT"]["BLIZZPLAYER"],
					desc		= L["TOOLTIP"]["BLIZZPLAYER"],
					order		= 0,
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
					order		= 1,
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
					order		= 2,
					get			= function ()
						return ArcHUD.db.profile.BlizzFocus
					end,
					set			= function (info, v)
						ArcHUD.db.profile.BlizzFocus = v
						ArcHUD:HideBlizzardFocus(v)
					end,
				},
				-- Blizzard Spell Activation Center on ArcHUD
				blizzSpellActCenter = {
					type		= "toggle",
					name		= L["TEXT"]["BLIZZSPELLACT_CENTER"],
					desc		= L["TOOLTIP"]["BLIZZSPELLACT_CENTER"],
					order		= 10,
					get			= function ()
						return ArcHUD.db.profile.BlizzSpellActCenter
					end,
					set			= function (info, v)
						ArcHUD.db.profile.BlizzSpellActCenter = v
						if v then
							SpellActivationOverlayFrame:ClearAllPoints()
							SpellActivationOverlayFrame:SetPoint("CENTER", ArcHUDFrame, "CENTER", 0, -175)
						else
							SpellActivationOverlayFrame:ClearAllPoints()
							SpellActivationOverlayFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
						end
					end,
				},
				-- Blizzard Spell Activation Opacity
				blizzSpellActScale = {
					type		= "range",
					name		= L["TEXT"]["BLIZZSPELLACT_SCALE"],
					desc		= L["TOOLTIP"]["BLIZZSPELLACT_SCALE"],
					min			= 0.2,
					max			= 2.0,
					step		= 0.1,
					order		= 11,
					get			= function ()
						return ArcHUD.db.profile.BlizzSpellActScale
					end,
					set			= function (info, v)
						ArcHUD.db.profile.BlizzSpellActScale = v
						SpellActivationOverlayFrame:SetScale(v)
						if ArcHUD.db.profile.BlizzSpellActCenter then
							SpellActivationOverlayFrame:ClearAllPoints()
							SpellActivationOverlayFrame:SetPoint("CENTER", ArcHUDFrame, "CENTER", 0, -87)
						else
							SpellActivationOverlayFrame:ClearAllPoints()
							SpellActivationOverlayFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
						end
					end,
				},
				-- Blizzard Spell Activation Opacity
				blizzSpellActOpacity = {
					type		= "range",
					name		= L["TEXT"]["BLIZZSPELLACT_OPAC"],
					desc		= L["TOOLTIP"]["BLIZZSPELLACT_OPAC"],
					min			= 0.2,
					max			= 1.0,
					step		= 0.1,
					order		= 12,
					get			= function ()
						return ArcHUD.db.profile.BlizzSpellActOpacity
					end,
					set			= function (info, v)
						ArcHUD.db.profile.BlizzSpellActOpacity = v
						ArcHUD:HookBlizzardSpellActivation((ArcHUD.db.profile.BlizzSpellActOpacity < 1.0))
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
-- Custom modules options
----------------------------------------------
ArcHUD.configOptionsTableCustomModules = {
	type = "group",
	name = LM["TEXT"]["CUSTOM"],
	args = {
		-- new custom arc
		new = {
			type		= "execute",
			name		= LM["TEXT"]["CUSTNEW"],
			desc		= LM["TOOLTIP"]["CUSTNEW"],
			order		= 1,
			func		= function ()
				ArcHUD:CreateCustomBuffModule()
				ArcHUD:SyncCustomModuleSettings()
			end,
		},
	},
}

local function ArcHUD_adjustConfig(group)
	if group.args == nil then return end
	-- adjust controls to full width	
	for k,v in pairs(group.args) do
		v["width"] = "full"
		if not (v.args == nil) then
			ArcHUD_adjustConfig(v)
		end
	end
end

----------------------------------------------
-- Initialize config tools
----------------------------------------------
function ArcHUD:InitConfig()
	-- Get profiles
	profilesTable[1] = L["TEXT"]["PROFILES_DEFAULT"]
	ArcHUD_updateProfilesTable()

	-- Set up chat commands
	AceConfig:RegisterOptionsTable("ArcHUD", self.configOptionsTableCmd, {"archud", "ah"})
	
	-- Set up core config options
	ArcHUD_adjustConfig(self.configOptionsTableCore)
	AceConfig:RegisterOptionsTable("ArcHUD_Core", self.configOptionsTableCore)
	self.configFrameCore = AceConfigDialog:AddToBlizOptions("ArcHUD_Core", "ArcHUD")
	
	-- Set up modules config options
	ArcHUD_adjustConfig(self.configOptionsTableModules)
	AceConfig:RegisterOptionsTable("ArcHUD_Modules", self.configOptionsTableModules)
	self.configFrameModules = AceConfigDialog:AddToBlizOptions("ArcHUD_Modules", LM["TEXT"]["TITLE"], "ArcHUD")
	
	-- Set up custom ring options
	--ArcHUD_adjustConfig(self.configOptionsTableCustomModules)
	AceConfig:RegisterOptionsTable("ArcHUD_CustomModules", self.configOptionsTableCustomModules)
	self.configFrameModules = AceConfigDialog:AddToBlizOptions("ArcHUD_CustomModules", LM["TEXT"]["CUSTOM"], "ArcHUD")
end

----------------------------------------------
-- Add options for a module
----------------------------------------------
function ArcHUD:AddModuleOptionsTable(moduleName, optionsTable)
	self:LevelDebug(d_notice, "Inserting config options for "..moduleName)
	ArcHUD_adjustConfig(optionsTable)
	ArcHUD.configOptionsTableModules.args[moduleName] = optionsTable
end

----------------------------------------------
-- Add options for a custom module
----------------------------------------------
function ArcHUD:AddCustomModuleOptionsTable(moduleName, optionsTable)
	self:LevelDebug(d_notice, "Inserting config options for custom module "..moduleName)
	ArcHUD_adjustConfig(optionsTable)
	ArcHUD.configOptionsTableCustomModules.args[moduleName] = optionsTable
	
	AceConfigRegistry:NotifyChange("ArcHUD_CustomModules")
end

----------------------------------------------
-- Add options for a custom module
----------------------------------------------
function ArcHUD:RemoveCustomModuleOptionsTable(moduleName)
	self:LevelDebug(d_notice, "Removing config options for custom module "..moduleName)
	ArcHUD.configOptionsTableCustomModules.args[moduleName] = nil
	
	AceConfigRegistry:NotifyChange("ArcHUD_CustomModules")
end
