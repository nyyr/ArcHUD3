local L = LibStub("AceLocale-3.0"):GetLocale("ArcHUD_Core")

---------------------------------------------------------------------------------------------------
-- Local functions to assist with widget creation
local function AH_CreateFrame(type, name, parent, size, point, strata)
	local f = CreateFrame(type, name, parent)
	local width, height = unpack(size)

	f:SetWidth(width)
	f:SetHeight(height)
	f:SetPoint(unpack(point))

	if(strata) then
		f:SetFrameStrata(strata)
	end

	f:Show()

	return f
end

local function AH_CreateFontString(parent, layer, size, fontsize, justify, color, point, name)
	local fs = parent:CreateFontString(name, layer)

	if(size) then
		local width, height = unpack(size)

		fs:SetWidth(width)
		fs:SetHeight(height)
	end
	fs:SetFont("Fonts\\"..L["FONT"], fontsize, "OUTLINE")
	if(color) then
		fs:SetTextColor(unpack(color))
	end
	fs:SetJustifyH(justify)
	fs:SetPoint(unpack(point))

	fs:Show()

	return fs
end

local function AH_CreateTexture(parent, layer, size, texture, point)
	local t = parent:CreateTexture(nil, layer)

	if(size) then
		local width, height = unpack(size)

		t:SetWidth(width)
		t:SetHeight(height)
	end
	if(texture) then
		t:SetTexture(texture)
	end
	if(point) then
		t:SetPoint(unpack(point))
	end

	t:Show()

	return t
end

-- Frame creation for specific purposes
local function AH_CreateBuffButton(parent, id, point)
	local f = CreateFrame("Button", nil, parent)

	f:SetPoint(unpack(point))
	f:SetID(id)

	local buffIconSize = ArcHUD.db.profile.BuffIconSize
	f:SetWidth(buffIconSize)
	f:SetHeight(buffIconSize)

	f.Icon = AH_CreateTexture(f, "ARTWORK", nil, "Interface\\Icons\\INV_Misc_Ear_Human_02")
	f.Icon:SetAllPoints(true)
	f.Icon:Show()

	f.Border = AH_CreateTexture(f, "OVERLAY", {buffIconSize+1, buffIconSize+1}, "Interface\\Buttons\\UI-Debuff-Overlays", {"CENTER", f, "CENTER"})
	f.Border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
	f.Border:Hide()

	f.Count = f:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
	f.Count:SetPoint("CENTER", f)
	f.Count:Show()

	f.Cooldown = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
	f.Cooldown:SetPoint("CENTER", 0, -1)

	f:SetScript("OnEnter", function(this) ArcHUD:SetAuraTooltip(this) end)
	f:SetScript("OnLeave", function() GameTooltip:Hide() end)

	f:Hide()

	return f
end

local function AH_CreateNameplate(parent, unit, size, point)
	local name
	if parent and parent:GetName() then
		name = parent:GetName() .. "_"
	else
		name = "ArcHUD_"
	end
	name = name .. unit
	
	-- be sure we don't create a frame with an existing name (should not happen)
	assert(not _G[name])
	
	ArcHUD:LevelDebug(1, "Creating unit frame "..name)
	
	local f = CreateFrame("Button", name, parent, "SecureUnitButtonTemplate")
	local width, height = unpack(size)

	f:SetWidth(width)
	f:SetHeight(height)

	f:SetPoint(unpack(point))

	ArcHUD:InitNameplate(f, unit)

	return f
end

local function AH_CreateMoverFrame(parent, name, size, point, origpoint)
	local f = CreateFrame("Button", nil, parent)
	local width, height = unpack(size)

	f:SetWidth(width)
	f:SetHeight(height)

	f:SetPoint(unpack(point))
	f:SetToplevel(true)
	f:GetParent():SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")

	f:SetScript("OnDragStart", function(self)
		if(not self:GetParent().locked) then
			self:GetParent():ClearAllPoints()
			self:GetParent():StartMoving()
		end
	end)

	f:SetScript("OnDragStop", function(self)
		self:GetParent():StopMovingOrSizing()
		self:GetParent().moved = true
		--ArcHUD:LevelDebug(1, "Sending ARCHUD_FRAME_MOVED")
		ArcHUD:SendMessage("ARCHUD_FRAME_MOVED")
	end)

	parent.ResetPos = function(self, newpoint)
		self:ClearAllPoints()
		if(newpoint) then
			self:SetPoint(unpack(newpoint))
		else
			self:SetPoint(unpack(self.origpoint))
		end
		self:Lock()

		self.reset = true
		ArcHUD:SendMessage("ARCHUD_FRAME_MOVED")
	end
	parent.Lock = function(self)
		if(self.locked) then return end

		self.locked = true
		self.mover:Hide()
		if(self.prevAlpha) then
			self:SetAlpha(self.prevAlpha)
			self.prevAlpha = nil
		end
	end
	parent.Unlock = function(self)
		if(not self.locked) then return end

		self.locked = false
		self.moved = false
		self.mover:Show()
		if(self:GetAlpha() < 0.5) then
			self.prevAlpha = self:GetAlpha()
			self:SetAlpha(1)
		else
			self.prevAlpha = nil
		end
	end

	f:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			tile = true, tileSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 }})
	f:SetBackdropColor(0,0,0,0.5)

	f:Hide()

	parent.locked = true
	parent.moved = false
	parent.origpoint = origpoint
	parent.mover = f

	-- Add to moveableFrames table
	ArcHUD.movableFrames[name] = parent
end

---------------------------------------------------------------------------------------------------
-- Main frame creation function
function ArcHUD:CreateHUDFrames()
	-- Main frame (defined in Frames.xml)
	local main = ArcHUDFrame
	local targethud = ArcHUDFrame.TargetHUD
	
	AH_CreateMoverFrame(targethud, "targethud", {320, 120}, {"TOPLEFT", -10, 10}, {"TOP", main, "BOTTOM", 0, -60})

	-- Set up font strings
	targethud.Combo = AH_CreateFontString(main, "BACKGROUND", {40, 30}, 30, "CENTER", {1, 1, 0}, {"BOTTOM", main, "BOTTOM"}, "ArcHUDFrameCombo")
	targethud.Name = AH_CreateFontString(targethud, "OVERLAY", {400, 16}, 15, "CENTER", {1, 1, 1}, {"TOP", targethud, "TOP"})
	targethud.HPText = AH_CreateFontString(targethud, "OVERLAY", {200, 14}, 13, "RIGHT", {1, 1, 1}, {"TOPLEFT", targethud.Name, "BOTTOMLEFT", -50, 0})
	targethud.MPText = AH_CreateFontString(targethud, "OVERLAY", {200, 14}, 13, "LEFT", {1, 1, 1}, {"TOPRIGHT", targethud.Name, "BOTTOMRIGHT", 50 , 0})
	targethud.Level = AH_CreateFontString(targethud, "OVERLAY", {100, 13}, 11, "CENTER", {1, 1, 1}, {"BOTTOMLEFT", targethud.HPText, "BOTTOMRIGHT", 0, 1})

	targethud.LeaderIcon = AH_CreateTexture(targethud, "OVERLAY", {16, 16}, "Interface\\GroupFrame\\UI-Group-LeaderIcon", {"TOPRIGHT", targethud.Level, "BOTTOMRIGHT", -5, 0})
	targethud.LeaderIcon:Hide()

	targethud.PVPFrame = AH_CreateFrame("Frame", nil, targethud, {64, 64}, {"TOPLEFT", targethud.Level, "BOTTOMLEFT", 3, 0})
	targethud.PVPFrame:SetScale(0.6)
	targethud.PVPIcon = AH_CreateTexture(targethud.PVPFrame, "OVERLAY", {64, 64}, nil, {"TOPLEFT", targethud.PVPFrame, "TOPLEFT"})
	targethud.PVPIcon:Hide()

	targethud.RaidTargetFrame = AH_CreateFrame("Frame", nil, targethud, {26, 26}, {"TOPLEFT", targethud.Level, "BOTTOMLEFT", 35, -3})
	targethud.RaidTargetFrame:SetScale(0.75)
	targethud.RaidTargetIcon = AH_CreateTexture(targethud.RaidTargetFrame, "OVERLAY", {26, 26}, "Interface\\TargetingFrame\\UI-RaidTargetingIcons", {"TOPLEFT", targethud.RaidTargetFrame, "TOPLEFT"})
	targethud.RaidTargetIcon:Hide()

	targethud.MLFrame = nil
	targethud.MLIcon = nil

	targethud.Target = AH_CreateFrame("Frame", targethud:GetName().."TT", targethud, {100, 30}, {"TOPLEFT", targethud, "TOPLEFT", 0, -70})
	AH_CreateMoverFrame(targethud.Target, "targettarget", {120, 50}, {"TOPLEFT", -10, 10}, {"TOPLEFT", targethud, "TOPLEFT", 0, -70})
	targethud.Target.Name = AH_CreateFontString(targethud.Target, "ARTWORK", {100, 14}, 13, "RIGHT", {1, 1, 1}, {"TOPLEFT", targethud.Target, "TOPLEFT"})
	targethud.Target.HPText = AH_CreateFontString(targethud.Target, "ARTWORK", {50, 11}, 10, "RIGHT", {1, 1, 1}, {"TOPRIGHT", targethud.Target.Name, "BOTTOMRIGHT", 0, -5})
	targethud.Target.MPText = AH_CreateFontString(targethud.Target, "ARTWORK", {50, 11}, 10, "LEFT", {1, 1, 1}, {"TOPLEFT", targethud.Target.Name, "BOTTOMLEFT", 0, -5})

	targethud.TargetTarget = AH_CreateFrame("Frame", targethud:GetName().."TTT", targethud, {100, 30}, {"TOPRIGHT", targethud, "TOPRIGHT", 0, -70})
	AH_CreateMoverFrame(targethud.TargetTarget, "targettargettarget", {120, 50}, {"TOPLEFT", -10, 10}, {"TOPRIGHT", targethud, "TOPRIGHT", 0, -70})
	targethud.TargetTarget.Name = AH_CreateFontString(targethud.TargetTarget, "ARTWORK", {100, 14}, 13, "LEFT", {1, 1, 1}, {"TOPLEFT", targethud.TargetTarget, "TOPLEFT"})
	targethud.TargetTarget.HPText = AH_CreateFontString(targethud.TargetTarget, "ARTWORK", {50, 11}, 10, "LEFT", {1, 1, 1}, {"TOPLEFT", targethud.TargetTarget.Name, "BOTTOMLEFT", 0, -5})
	targethud.TargetTarget.MPText = AH_CreateFontString(targethud.TargetTarget, "ARTWORK", {50, 11}, 10, "RIGHT", {1, 1, 1}, {"TOPRIGHT", targethud.TargetTarget.Name, "BOTTOMRIGHT", 0, -5})

	-- 3d model
	targethud.Model = AH_CreateFrame("PlayerModel", nil, targethud, {100, 100}, {"TOP", targethud.Name, "BOTTOM"}, "BACKGROUND")
	targethud.Model:RegisterEvent("DISPLAY_SIZE_CHANGED")
	targethud.Model:RegisterEvent("UNIT_MODEL_CHANGED")
	targethud.Model:SetScript("OnEvent", self.Refresh3dUnitModel)

	-- Create nameplates
	local np = AH_CreateNameplate(main, "player", {50, 14}, {"BOTTOM", main, "BOTTOM", 0, 60})
	np.Text = AH_CreateFontString(np, "OVERLAY", {150, 15}, 14, "CENTER", {1, 1, 1}, {"TOP", np, "TOP"})
	np.Resting = AH_CreateFontString(np, "BACKGROUND", {75, 12}, 11, "CENTER", {1, 1, 1}, {"BOTTOM", np.Text, "TOP"})

	local np = AH_CreateNameplate(main, "pet", {50, 12}, {"BOTTOM", main, "BOTTOM", 0, 45})
	np.Text = AH_CreateFontString(np, "OVERLAY", {150, 13}, 12, "CENTER", {1, 1, 1}, {"TOP", np, "TOP"})

	AH_CreateNameplate(targethud, "target", {400, 15}, {"TOP", targethud, "TOP"})
	AH_CreateNameplate(targethud.Target, "targettarget", {100, 14}, {"TOPLEFT", targethud.Target, "TOPLEFT"})
	AH_CreateNameplate(targethud.TargetTarget, "targettargettarget", {100, 14}, {"TOPLEFT", targethud.TargetTarget, "TOPLEFT"})

	-- Create buffframes
	targethud.Buff1 = AH_CreateBuffButton(targethud, 1, {"TOPRIGHT", targethud.HPText, "BOTTOMRIGHT", 0, -2}, "Buff")
	for i=2,10 do
		targethud["Buff"..i] = AH_CreateBuffButton(targethud, i, {"RIGHT", targethud["Buff"..(i-1)], "LEFT", -1, 0}, "Buff")
	end
	targethud.Buff11 = AH_CreateBuffButton(targethud, 11, {"TOPRIGHT", targethud.Buff1, "BOTTOMRIGHT", 0, -1}, "Buff")
	for i=12,20 do
		targethud["Buff"..i] = AH_CreateBuffButton(targethud, i, {"RIGHT", targethud["Buff"..(i-1)], "LEFT", -1, 0}, "Buff")
	end
	targethud.Buff21 = AH_CreateBuffButton(targethud, 21, {"TOPRIGHT", targethud.Buff11, "BOTTOMRIGHT", 0, -1}, "Buff")
	for i=22,30 do
		targethud["Buff"..i] = AH_CreateBuffButton(targethud, i, {"RIGHT", targethud["Buff"..(i-1)], "LEFT", -1, 0}, "Buff")
	end
	targethud.Buff31 = AH_CreateBuffButton(targethud, 31, {"TOPRIGHT", targethud.Buff21, "BOTTOMRIGHT", 0, -1}, "Buff")
	for i=32,40 do
		targethud["Buff"..i] = AH_CreateBuffButton(targethud, i, {"RIGHT", targethud["Buff"..(i-1)], "LEFT", -1, 0}, "Buff")
	end

	-- Create debuffframes
	targethud.Debuff1 = AH_CreateBuffButton(targethud, 1, {"TOPLEFT", targethud.MPText, "BOTTOMLEFT", 0, -2}, "DeBuff")
	for i=2,10 do
		targethud["Debuff"..i] = AH_CreateBuffButton(targethud, i, {"LEFT", targethud["Debuff"..(i-1)], "RIGHT", -1, 0}, "DeBuff")
	end
	targethud.Debuff11 = AH_CreateBuffButton(targethud, 11, {"TOPLEFT", targethud.Debuff1, "BOTTOMLEFT", 0, -1}, "DeBuff")
	for i=12,20 do
		targethud["Debuff"..i] = AH_CreateBuffButton(targethud, i, {"LEFT", targethud["Debuff"..(i-1)], "RIGHT", -1, 0}, "DeBuff")
	end
	targethud.Debuff21 = AH_CreateBuffButton(targethud, 21, {"TOPLEFT", targethud.Debuff11, "BOTTOMLEFT", 0, -1}, "DeBuff")
	for i=22,30 do
		targethud["Debuff"..i] = AH_CreateBuffButton(targethud, i, {"LEFT", targethud["Debuff"..(i-1)], "RIGHT", -1, 0}, "DeBuff")
	end
	targethud.Debuff31 = AH_CreateBuffButton(targethud, 31, {"TOPLEFT", targethud.Debuff21, "BOTTOMLEFT", 0, -1}, "DeBuff")
	for i=32,40 do
		targethud["Debuff"..i] = AH_CreateBuffButton(targethud, i, {"LEFT", targethud["Debuff"..(i-1)], "RIGHT", -1, 0}, "DeBuff")
	end


	return targethud
end

function ArcHUD:CheckFrames()
	--ArcHUD:LevelDebug(1, "CheckFrames")
	for id, frame in pairs(self.movableFrames) do
		if(frame.moved) then
			--ArcHUD:LevelDebug(1, "Update of "..id)
			self.db.profile.Positions[id] = {
				x = frame:GetLeft(),
				y = frame:GetBottom(),
			}
			frame.moved = false
		elseif(frame.reset) then
			self.db.profile.Positions[id] = nil
			frame.reset = nil
		end
	end
end

function ArcHUD:Refresh3dUnitModel(event, arg1)
	--ArcHUD:LevelDebug(3, "ArcHUD:Refresh3dUnitModel("..tostring(event)..", "..tostring(arg1)..")")
	if (ArcHUD.db.profile.TargetFrame) then
		if ((event ~= "UNIT_MODEL_CHANGED" and UnitExists("target")) or
			(event == "UNIT_MODEL_CHANGED" and arg1 == "target")) then
			if ((ArcHUD.db.profile.PlayerModel and UnitIsPlayer("target")) or 
				(ArcHUD.db.profile.MobModel and not UnitIsPlayer("target"))) then
				ArcHUD.TargetHUD.Model:RefreshUnit()
			end
		end
	end
end
