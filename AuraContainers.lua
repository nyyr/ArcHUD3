----------------------------------------------
-- Target aura display via AuraContainer (12.1+)
--
-- 12.1 (PTR 3, build 68412) made the index/slot/instanceID aura accessors raise a
-- Lua error while auras are secret, so TargetAuras' "for i = 1, 40 do
-- C_UnitAuras.GetBuffDataByIndex(...)" loop cannot work there. AuraContainer /
-- AuraButton are the sanctioned replacement.
--
-- The model: WE supply the widgets and hand them to the button; the engine drives
-- them from aura data that never reaches Lua. That is why every display feature
-- survives - including the cooldown sweep, via SetDurationCooldown.
--
-- Midnight-only. Classic flavours keep the index path in Core.lua untouched.
----------------------------------------------

-- Reuse the exact artwork the legacy buttons use (see AH_CreateBuffButton in
-- Frames.lua) so the look is preserved rather than reinvented.
local BORDER_TEXTURE = "Interface\\Buttons\\UI-Debuff-Overlays"
local BORDER_TEXCOORD = { 0.296875, 0.5703125, 0, 0.515625 }

local function styleAuraButton(button, isDebuff)
	local p = ArcHUD.db.profile
	local size = p.BuffIconSize or 20

	button:SetSize(size, size)

	if not button.ahIcon then
		button.ahIcon = button:CreateTexture(nil, "ARTWORK")
		button.ahIcon:SetAllPoints(button)

		button.ahBorder = button:CreateTexture(nil, "OVERLAY")
		button.ahBorder:SetTexture(BORDER_TEXTURE)
		button.ahBorder:SetTexCoord(unpack(BORDER_TEXCOORD))
		button.ahBorder:SetPoint("CENTER", button, "CENTER")
		-- textures are shown on creation; the legacy button creates this hidden and
		-- only reveals it for debuffs, otherwise buffs get a spurious outline
		button.ahBorder:Hide()

		button.ahCount = button:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
		button.ahCount:SetPoint("CENTER", button)

		button.ahCooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		button.ahCooldown:SetPoint("CENTER", 0, -1)
	end

	button.ahBorder:SetSize(size + 1, size + 1)

	-- These are our widgets, so the existing options still apply exactly as before
	button.ahCooldown:SetHideCountdownNumbers(p.HideBuffTimerText and true or false)
	button.ahCooldown:SetReverse(not p.ReverseBuffCooldowns)

	-- Hand the widgets over. Clear* is used rather than skipping the Set*, so that
	-- toggling an option off at runtime actually removes the element.
	button:SetIcon(button.ahIcon)

	if p.ShowBuffCount == false and button.ClearApplicationCount then
		button:ClearApplicationCount()
	else
		button:SetApplicationCount(button.ahCount)
	end

	if button.SetDurationCooldown then
		button:SetDurationCooldown(button.ahCooldown) -- the radial sweep
	end

	-- dispel-type border is only meaningful for debuffs, same as the legacy code
	if isDebuff and button.SetAuraBorder then
		-- PreserveAsset keeps OUR texture (UI-Debuff-Overlays with its tex coords)
		-- and only tints it per dispel type - exactly what the legacy code did with
		-- Border:SetVertexColor(DebuffTypeColor[...]).
		--
		-- The default style, BorderWithIcon, instead calls AuraUtil.SetAuraBorderAtlas
		-- and REPLACES the texture with a Blizzard atlas (forcing vertex colour to
		-- white), which rendered as blue/red horizontal bars across the icons.
		local opts
		local styles = Enum and Enum.CustomAuraButtonDispelTypeTextureStyle
		if styles then
			opts = {
				style = styles.PreserveAsset,
				-- legacy drew a border even with no dispel type (DebuffTypeColor["none"])
				showWithoutDispelType = true,
			}
		end
		button:SetAuraBorder(button.ahBorder, opts) -- engine owns visibility now
	else
		if button.ClearAuraBorder then button:ClearAuraBorder() end
		button.ahBorder:Hide()
	end

	if button.SetMouseMotionEnabled then
		button:SetMouseMotionEnabled(p.ShowBuffTooltips ~= false)
	end
	if button.SetHideTooltipInCombat then
		button:SetHideTooltipInCombat(p.HideBuffTooltipsIC and true or false)
	end
end

-- Legacy layout: 10 icons per row, 4 rows, growing outward from the centre and
-- downward (see the Buff1..Buff40 anchor chain in Frames.lua).
local ICONS_PER_ROW = 10
local ICON_SPACING = 1

-- Reproduce that with the container's flow layout.
--
-- The container gets AuraContainerFlowLayoutInboundMixin via
-- CustomAuraContainerTemplate, so SetFlowLayout* are addon-callable. Per-group
-- options (SetAuraGroupLayout) only carry spacing/size/ordering - the axis,
-- anchor and growth direction live on the container.
--
-- maximumLineSize is a PIXEL extent, not an icon count (Blizzard's target frame
-- passes 101 for its target-of-target rows), so derive it from the icon size.
local function applyAuraLayout(c, groupKey, flowAnchor, horizontalDirection)
	if not AnchorUtil then return end
	local size = (ArcHUD.db.profile.BuffIconSize or 20) + ICON_SPACING

	if c.SetFlowLayoutAxis and AnchorUtil.FlowLayoutAxis then
		pcall(c.SetFlowLayoutAxis, c, AnchorUtil.FlowLayoutAxis.Horizontal)
	end
	if c.SetFlowLayoutAnchorPoint then
		pcall(c.SetFlowLayoutAnchorPoint, c, flowAnchor)
	end
	if c.SetFlowLayoutGrowthDirection and AnchorUtil.FlowDirection then
		pcall(c.SetFlowLayoutGrowthDirection, c,
			horizontalDirection, AnchorUtil.FlowDirection.Down)
	end
	if c.SetFlowLayoutMaximumLineSize then
		pcall(c.SetFlowLayoutMaximumLineSize, c, ICONS_PER_ROW * size)
	end
	if c.SetAuraGroupLayout and groupKey then
		pcall(c.SetAuraGroupLayout, c, groupKey, {
			elementSpacing = ICON_SPACING,
			lineSpacing = ICON_SPACING,
		})
	end
end

local function buffFilter()
	if ArcHUD.db.profile.ShowOnlyBuffsCastByPlayer then
		return "HELPFUL|PLAYER"
	end
	return "HELPFUL"
end

----------------------------------------------
-- Create the two containers. Returns true if the client supports them.
----------------------------------------------
function ArcHUD:SetupAuraContainers()
	if not ArcHUD.isMidnight then return false end
	local hud = self.TargetHUD
	if not hud or not hud.HPText or not hud.MPText then return false end

	local function build(anchorPoint, anchorTo, relPoint, filter, isDebuff, key, hDir)
		local ok, c = pcall(CreateFrame, "AuraContainer", nil, hud,
			"CustomAuraContainerTemplate")
		if not ok or not c then return nil end
		-- AddAuraGroup comes from the template's mixin, not the widget type
		if not c.AddAuraGroup then return nil end

		c:SetSize(1, 1)
		c:SetPoint(anchorPoint, anchorTo, relPoint, 0, -2)
		c:SetUnit("target")

		local opts = {
			maxFrameCount = 40,
			initializeFrame = function(button)
				styleAuraButton(button, isDebuff)
			end,
		}
		local added = pcall(c.AddAuraGroup, c, key, filter, opts)
		if not added then return nil end

		if c.SetAuraGroupMaxFrameCount then
			pcall(c.SetAuraGroupMaxFrameCount, c, key, 40)
		end

		c.ahGroupKey = key
		c.ahFlowAnchor = anchorPoint
		c.ahHDir = hDir
		applyAuraLayout(c, key, anchorPoint, hDir)

		c:Show()
		return c
	end

	-- Match the legacy anchors and growth: buffs hang off HPText and grow LEFT,
	-- debuffs hang off MPText and grow RIGHT, both wrapping downward.
	local dirs = AnchorUtil and AnchorUtil.FlowDirection or {}
	self.auraBuffContainer = build("TOPRIGHT", hud.HPText, "BOTTOMRIGHT",
		buffFilter(), false, "archud_buffs", dirs.Left)
	self.auraDebuffContainer = build("TOPLEFT", hud.MPText, "BOTTOMLEFT",
		"HARMFUL", true, "archud_debuffs", dirs.Right)

	if not (self.auraBuffContainer or self.auraDebuffContainer) then
		return false
	end

	-- the containers replace the 40+40 hand-driven buttons
	for i = 1, 40 do
		local b, d = hud["Buff"..i], hud["Debuff"..i]
		if b then b:Hide() end
		if d then d:Hide() end
	end

	-- Drive unit changes from the event, not from TargetAuras' per-update calls.
	if not self.auraTargetWatcher then
		local w = CreateFrame("Frame")
		w:RegisterEvent("PLAYER_TARGET_CHANGED")
		w:SetScript("OnEvent", function()
			ArcHUD:RefreshAuraContainers()
		end)
		self.auraTargetWatcher = w
	end

	self:LevelDebug(2, "Aura containers active (12.1 aura API)")
	return true
end

----------------------------------------------
-- Show/hide both containers (the ShowBuffs option)
----------------------------------------------
function ArcHUD:SetAuraContainersShown(shown)
	if not self.auraContainersActive then return end
	for _, c in ipairs({ self.auraBuffContainer, self.auraDebuffContainer }) do
		if c then
			if shown then c:Show() else c:Hide() end
		end
	end
end

----------------------------------------------
-- Re-apply settings after an options change, without rebuilding
----------------------------------------------
function ArcHUD:UpdateAuraContainers()
	if not self.auraContainersActive then return end

	local c = self.auraBuffContainer
	if c and c.SetAuraGroupFilterString and c.ahGroupKey then
		pcall(c.SetAuraGroupFilterString, c, c.ahGroupKey, buffFilter())
	end

	-- restyle live buttons so BuffIconSize / timer-text / sweep-direction and the
	-- tooltip options take effect immediately
	for _, container in ipairs({ self.auraBuffContainer, self.auraDebuffContainer }) do
		-- BuffIconSize feeds the row width, so the layout has to be recomputed too
		if container then
			applyAuraLayout(container, container.ahGroupKey,
				container.ahFlowAnchor, container.ahHDir)
		end
		if container and container.GetAuraGroupFrameCount and container.GetAuraGroupFrame then
			local okCount, count = pcall(container.GetAuraGroupFrameCount, container)
			if okCount and type(count) == "number" then
				for i = 1, count do
					local okF, f = pcall(container.GetAuraGroupFrame, container, i)
					if okF and f then
						pcall(styleAuraButton, f, container == self.auraDebuffContainer)
					end
				end
			end
		end
		if container and container.UpdateAllAuras then
			pcall(container.UpdateAllAuras, container)
		end
	end
end

----------------------------------------------
-- Point the containers at the current target.
--
-- ONLY call this on an actual target change. The container tracks the unit and
-- its auras itself; re-running SetUnit/UpdateAllAuras on every TargetAuras call
-- (which fires on UNIT_AURA and on the TargetUpdate timer) re-assigns every aura
-- continuously, which replays each Cooldown's "ready" bling and thrashes the
-- portrait model's effects.
----------------------------------------------
function ArcHUD:RefreshAuraContainers()
	if not self.auraContainersActive then return end
	for _, c in ipairs({ self.auraBuffContainer, self.auraDebuffContainer }) do
		if c then
			pcall(function()
				c:SetUnit("target")
				if c.UpdateAllAuras then c:UpdateAllAuras() end
			end)
		end
	end
end

----------------------------------------------
-- One-shot init, driven from TargetAuras so it runs once TargetHUD exists
----------------------------------------------
function ArcHUD:EnsureAuraContainers()
	if self.auraContainersTried then return self.auraContainersActive end
	self.auraContainersTried = true
	local ok, active = pcall(self.SetupAuraContainers, self)
	self.auraContainersActive = (ok and active) or false
	if not self.auraContainersActive then
		self:LevelDebug(2, "Aura containers unavailable; using index enumeration")
	end
	return self.auraContainersActive
end
