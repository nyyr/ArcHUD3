
ArcHUD.templatePowerRing = {}
local module = ArcHUD.templatePowerRing

module.version = "5.0 (@file-abbreviated-hash@)"

module.unit = "player"
module.noAutoAlpha = nil

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		Flash = true,
		Side = 2,
		Level = 1,
		ShowSeparators = true,
		Color = {r = 1, g = 1, b = 0},
		RingVisibility = 2, -- always fade out when out of combat, regardless of ring status
		ShowTextHuge = false
	}
}
module.options = {
	{name = "Flash", text = "FLASH", tooltip = "FLASH"},
	{name = "ShowTextHuge", text = "SHOWTEXTHUGE", tooltip = "SHOWTEXTHUGE"}, -- fka "combo points"
	attach = true,
	hasseparators = true,
}
module.localized = true

module.class = ""
module.specs = nil -- array of SPEC_... constants; nil if this ring is available for all specs
module.powerType = 0
module.powerTypeString = ""
module.flashAt = nil -- flash when full

function module:InitializePowerRing()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)
	self.f:Hide()

	self.TextHuge = self:CreateFontString(self.f, "BACKGROUND", {40, 30}, 30, "CENTER", 
						{ self.defaults.profile.Color.r, self.defaults.profile.Color.g, self.defaults.profile.Color.b },
						{ "BOTTOM", ArcHUDFrame, "BOTTOM" })
	self.TextHuge:Hide()
	
	self:CreateStandardModuleOptions(55)

	self.active = false
end

function module:OnModuleUpdate()
	self:UpdateColor(self.db.profile.Color)
	self.TextHuge:SetTextColor(self.db.profile.Color.r, self.db.profile.Color.g, self.db.profile.Color.b)

	if (self.db.profile.ShowTextHuge) then
		self.TextHuge:Show()
	else
		self.TextHuge:Hide()
	end

	self.f:StopPulse()
	self:UpdatePowerRing()
end

function module:OnModuleEnable()
	local _, class = UnitClass(self.unit)
	if (class ~= self.class) then return end

	self.f.dirty = true
	self.f.fadeIn = 0.25

	-- If we are limited to certain specs, make sure we look for spec changes
	if self.specs and not ArcHUD.classic then
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "UpdateActive")
	end

	-- Register/unregister events
	self:UpdateActive()

	-- Refresh settings
	self:OnModuleUpdate()
end

function module:UpdatePowerRing()
	local maxPower = UnitPowerMax(self.unit, self.powerType);
	local num = UnitPower(self.unit, self.powerType)
	self.f:SetMax(maxPower)
	self.f:SetValue(num)

	if self.db.profile.ShowTextHuge then
		if (num > 0) then
			self.TextHuge:SetText(num)
		else
			self.TextHuge:SetText("")
		end
	end
	
	if self.db.profile.Flash then
		local flashAt = self.flashAt or maxPower
		if (num >= flashAt) then
			self.f:StartPulse()
		else
			self.f:StopPulse()
		end
	end
end

function module:UpdatePower(event, arg1, arg2)
	if (event == "UNIT_POWER_FREQUENT") then
		if (arg1 == self.unit and arg2 == self.powerTypeString) then
			self:UpdatePowerRing()
		end
	else
		self:UpdatePowerRing()
	end
end

--
-- Update whether this power ring is active
--
function module:UpdateActive(event, arg1)
	local isActive = false

	if not self.specs then
		isActive = true
	else
		local spec = GetSpecialization()
		for i,s in ipairs(self.specs) do
			if s == spec then
				isActive = true
				break
			end
		end
	end

	if self.active ~= isActive then
		if isActive then
			-- Register the events we will use
			self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdatePower")
			if (not ArcHUD.classic) then
				self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "UpdateActive")
			end
			self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "UpdatePower", self.unit)
			self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "UpdatePower", self.unit)

			-- Activate ring timers
			self:StartRingTimers()
		else
			-- Unregister the events if we are in the wrong specialization
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
			if (not ArcHUD.classic) then
				self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")
			end
			self:UnregisterUnitEvent("UNIT_POWER_FREQUENT")
			self:UnregisterUnitEvent("UNIT_DISPLAYPOWER")

			-- Deactivate ring timers
			self:StopRingTimers()
		end
		if self.OnActiveChanged then
			self:OnActiveChanged(self.active, isActive)
		end
		self.active = isActive
	end
	
	self.f:SetShown(isActive and ((not self.CheckVisible) or self:CheckVisible()))
end

--
-- Can be overridden in case more events must be registered (e.g., for detecting shapeshifts)
--
function module:OnActiveChanged(oldState, newState)
	
end

--
-- Can be overridden in case other conditions apply (e.g., shapeshift form)
--
function module:CheckVisible()
	return true
end