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
		local unit = ArcHUD:strcap(self.unit).."FrameDropDown"
		local dd = getglobal(unit)
		if (dd) then
			ToggleDropDownMenu(1, nil, dd, "cursor", 0, 0)
		end
	end

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
	this.OnEvent = function(self, event)
		-- no change if disabled and if nameplates are active in combat anyway
		if(self.disabled or ArcHUD.db.profile.NameplateCombat) then return end
		
		if(event == "PLAYER_REGEN_ENABLED") then
			self:Enable()
		elseif(event == "PLAYER_REGEN_DISABLED") then
			self:Disable()
		end
	end

	this:SetScript("OnEnter", this.OnEnter)
	this:SetScript("OnLeave", this.OnLeave)
	this:SetScript("OnEvent", this.OnEvent)

	this:RegisterEvent("PLAYER_REGEN_ENABLED")
	this:RegisterEvent("PLAYER_REGEN_DISABLED")

	-- set up click casting
	ClickCastFrames = ClickCastFrames or {}
	ClickCastFrames[this] = true

	this.disabled = not ArcHUD.db.profile["Nameplate_"..unit]
	this.lock = false -- do not change enabled-state in any case
	this.state = true
	
	this.Enable = function(self)
		-- ArcHUD:LevelDebug(3, "Enable: unit "..self.unit..", state "..tostring(self.state)..", disabled "..tostring(self.disabled)..", lock "..tostring(self.lock)..", lockdown "..tostring(InCombatLockdown())..", npcombat "..tostring(ArcHUD.db.profile.NameplateCombat))
	
		if (InCombatLockdown() or self.state or self.disabled or self.lock) then return end
		
		if(self.unit == "player" or self.unit == "pet") then
			if (not MouseIsOver(ArcHUD.Nameplates[self.unit])) then
				-- happens after leaving combat or when pet happiness changes
				return
			end

			ArcHUDRingTemplate.SetRingAlpha(ArcHUD.Nameplates[self.unit], 1.0)
			if(ArcHUD.db.profile.HoverMsg) then
				ArcHUD:Print("Enabling mouse input for "..self.unit.." nameplate")
			end
		end
		
		self:EnableMouse(true)
		self:SetToplevel(true)

		self.state = true
	end
	
	this.Disable = function(self)
		if (InCombatLockdown() or (not self.state) or self.lock) then return end
		
		-- ArcHUD:LevelDebug(3, "Disable: unit "..self.unit..", state "..tostring(self.state)..", disabled "..tostring(self.disabled)..", lock "..tostring(self.lock))

		self:EnableMouse(false)
		self:SetToplevel(false)

		self.state = false
	end

	-- Add nameplate to list
	self.Nameplates[unit] = this
	
	-- Initial state
	if (this.disabled or unit == "player" or unit == "pet") then
		this:Disable()
	else
		this:Enable()
	end
end

-- For delayed clickable nameplates
function ArcHUD:RestartNamePlateTimers()
	local units = {"player", "pet"}
	local metrostarted = false

	for k,unit in pairs(units) do
		local this = self.Nameplates[unit]

		if(not this.disabled) then
			self:RegisterTimer("Enable_"..unit, this.Enable, self.db.profile.HoverDelay, this)

			this.started = true

			this.fadeIn = 0.25
			this.fadeOut = 0.25
			--if(not self:MetroStatus(unit.."Alpha")) then
			--	self:RegisterMetro(unit.."Alpha", ArcHUDRingTemplate.AlphaUpdate, 0.01, this)
			--end
			--self:StartMetro(unit.."Alpha")
			ArcHUDRingTemplate.SetRingAlpha(this, self.db.profile.FadeFull)

			metrostarted = true
		else
			this:Disable()
			this:SetAlpha(0)
		end
	end

	if(metrostarted) then
		self:LevelDebug(3, "Nameplates enabled. Showing frames and starting update timers")
		self:StartTimer("UpdatePetNamePlate")
		self:StartTimer("CheckNamePlateMouseOver")
	else
		self:LevelDebug(3, "Player and pet nameplates not enabled.")
	end
end

function ArcHUD:CheckNamePlateMouseOver()
	-- Check player nameplate
	if(MouseIsOver(self.Nameplates.player) and not self.Nameplates.player.disabled) then
		if(not self.Nameplates.player.started) then
			self.Nameplates.player.started = true
			self:StartTimer("Enable_player")
		end
	else
		if(self.Nameplates.player.started) then
			ArcHUDRingTemplate.SetRingAlpha(self.Nameplates.player, self.db.profile.FadeFull)
			self:StopTimer("Enable_player")
			self.Nameplates.player.started = false
			self.Nameplates.player:Disable()
		end
	end

	-- Check pet nameplate
	if(not UnitExists("pet")) then return end
	if(MouseIsOver(self.Nameplates.pet) and not self.Nameplates.pet.disabled) then
		if(not self.Nameplates.pet.started) then
			self.Nameplates.pet.started = true
			self:StartTimer("Enable_pet")
		end
	else
		if(self.Nameplates.pet.started) then
			if(self.db.profile.PetNamePlateFade and self.Nameplates.pet.alpha > 0) then
				ArcHUDRingTemplate.SetRingAlpha(self.Nameplates.pet, self.Nameplates.pet.alpha)
			else
				ArcHUDRingTemplate.SetRingAlpha(self.Nameplates.pet, self.db.profile.FadeFull)
			end
			self:StopTimer("Enable_pet")
			self.Nameplates.pet.started = false
			self.Nameplates.pet:Disable()
		end
	end
end

function ArcHUD:UpdateNameplateSetting(unit, value)
	ArcHUD.db.profile["Nameplate_"..unit] = value
	ArcHUD.Nameplates[unit].disabled = not value
	if (value) then
		ArcHUD.Nameplates[unit]:Enable()
	else
		ArcHUD.Nameplates[unit]:Disable()
	end
end
