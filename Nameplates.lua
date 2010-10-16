----------------------------------------------
-- NamePlate Functions
--

function ArcHUD:InitNameplate(this, unit)

	this.unit = unit

	this:RegisterForClicks("AnyUp")
	this:SetAttribute("*type1", "target")
	this:SetAttribute("*type2", "menu")
	this:SetAttribute("unit", this.unit)
	this.menu = function(self)
		ToggleDropDownMenu(1, nil, getglobal(ArcHUD:strcap(self:GetAttribute("unit")).."FrameDropDown"), "cursor", 0, 0)
	end

	this:EnableMouse(false)
	this:SetToplevel(false)

	this.OnEnter = function(self)
		if(SpellIsTargeting()) then
			if (SpellCanTargetUnit(self.unit)) then
				SetCursor("CAST_CURSOR")
			else
				SetCursor("CAST_ERROR_CURSOR")
			end
		end
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 20)
		GameTooltip:SetUnit(self.unit)
		GameTooltip:Show()
	end
	this.OnLeave = function(self)
		if(SpellIsTargeting()) then
			SetCursor("CAST_ERROR_CURSOR")
		end
		if(GameTooltip:IsOwned(self)) then
			GameTooltip:Hide()
		end
	end
	this.OnEvent = function(self)
		if(self.disabled or not ArcHUD.db.profile.NameplateCombat) then return end

		if(event == "PLAYER_REGEN_ENABLED") then
			self:Disable(true)
		elseif(event == "PLAYER_REGEN_DISABLED") then
			self:Enable(true)
		end
	end

	this:SetScript("OnEnter", function() this:OnEnter() end)
	this:SetScript("OnLeave", function() this:OnLeave() end)
	this:SetScript("OnEvent", function() this:OnEvent() end)

	this:RegisterEvent("PLAYER_REGEN_ENABLED")
	this:RegisterEvent("PLAYER_REGEN_DISABLED")

	-- set up click casting
	ClickCastFrames = ClickCastFrames or {}
	ClickCastFrames[this] = true

	self.state = false
	this.Enable = function(self, lock)
		if(InCombatLockdown() or self.state or self.disabled or self.lock) then return end

		self.lock = (lock==true and true or false)

		self:EnableMouse(true)
		self:SetToplevel(true)

		if(not self.lock and (self.unit == "player" or self.unit == "pet")) then
			ArcHUD:StopMetro("Enable_"..self.unit)
			if(ArcHUD.db.profile.HoverMsg) then
				ArcHUD:Print("Enabling mouse input for "..self.unit)
			end
		end

		self.state = true
	end
	this.Disable = function(self, lock)
		if(InCombatLockdown() or not self.state or (self.lock and not lock)) then return end

		self:EnableMouse(false)
		self:SetToplevel(false)

		self.lock = false
		self.state = false
	end

	this.disabled = not ArcHUD.db.profile["Nameplate_"..unit]

	-- Add nameplate to list
	self.Nameplates[unit] = this
end

function ArcHUD:StartNamePlateTimers()
	local units = {"player", "pet"}
	local metrostarted = false

	for k,unit in pairs(units) do
		local this = self.Nameplates[unit]

		if(not this.disabled) then
			self:UnregisterMetro("Enable_"..unit)
			self:RegisterMetro("Enable_"..unit, this.Enable, self.db.profile.HoverDelay, this)

			this.started = true

			if(not self:MetroStatus(unit.."Alpha")) then
				self:RegisterMetro(unit.."Alpha", ArcHUDRingTemplate.AlphaUpdate, 0.01, this)
			end
			self:StartMetro(unit.."Alpha")

			this.fadeIn = 0.25
			this.fadeOut = 0.25

			ArcHUDRingTemplate.SetRingAlpha(this, self.db.profile.FadeFull)

			metrostarted = true
		else
			self:UnregisterMetro("Enable_"..unit)
			this:Disable()
			this:SetAlpha(0)
		end
	end

	if(metrostarted) then
		self:LevelDebug(3, "Nameplates enabled. Showing frames and starting update timers")
		self:StartMetro("UpdatePetNamePlate")
		self:StartMetro("CheckNamePlateMouseOver")
	else
		self:LevelDebug(3, "Player and pet nameplates not enabled.")
	end
end

function ArcHUD:CheckNamePlateMouseOver()
	-- Check player nameplate
	if(MouseIsOver(self.Nameplates.player) and not self.Nameplates.player.disabled) then
		if(not self.Nameplates.player.started) then
			ArcHUDRingTemplate.SetRingAlpha(self.Nameplates.player, 1.0)
			self.Nameplates.player.started = true
			self:StartMetro("Enable_player")
		end
	else
		if(self.Nameplates.player.started) then
			ArcHUDRingTemplate.SetRingAlpha(self.Nameplates.player, self.db.profile.FadeFull)
			self:StopMetro("Enable_player")
			self.Nameplates.player.started = false
			self.Nameplates.player:Disable()
		end
	end

	-- Check pet nameplate
	if(not UnitExists("pet")) then
		return
	end
	if(MouseIsOver(self.Nameplates.pet) and not self.Nameplates.pet.disabled) then
		if(not self.Nameplates.pet.started) then
			ArcHUDRingTemplate.SetRingAlpha(self.Nameplates.pet, 1.0)
			self.Nameplates.pet.started = true
			self:StartMetro("Enable_pet")
		end
	else
		if(self.Nameplates.pet.started) then
			if(self.db.profile.PetNamePlateFade and self.Nameplates.pet.alpha > 0) then
				ArcHUDRingTemplate.SetRingAlpha(self.Nameplates.pet, self.Nameplates.pet.alpha)
			else
				ArcHUDRingTemplate.SetRingAlpha(self.Nameplates.pet, self.db.profile.FadeFull)
			end
			self:StopMetro("Enable_pet")
			self.Nameplates.pet.started = false
			self.Nameplates.pet:Disable()
		end
	end
end
