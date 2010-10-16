

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
