local moduleName = "FocusHealth"
local module = ArcHUD:NewModule(moduleName)
module.version = "2.1 (01920a3)"

module.unit = "focus"
module.isHealth = true
module.healPrediction = 0

module.defaults = {
	profile = {
		Enabled = false,
		Outline = true,
		ShowPerc = true,
		ColorFriend = {r = 0, g = 0.5, b = 1},
		ColorFoe = {r = 1, g = 0, b = 0},
		Side = 1,
		Level = 3,
	},
}
module.options = {
	{name = "ShowPerc", text = "SHOWPERC", tooltip = "SHOWPERC"},
	{name = "ShowIncoming", text = "INCOMINGHEALS", tooltip = "INCOMINGHEALS"},
	hasfriendfoe = true,
	attach = true,
}
module.localized = true

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)

	self.HPPerc = self:CreateFontString(self.f, "BACKGROUND", {40, 12}, 10, "CENTER", {1.0, 1.0, 1.0}, {"TOP", self.f, "BOTTOMLEFT", 20, -130})
	
	self:CreateStandardModuleOptions(40)
end

function module:OnModuleUpdate()
	if(self.db.profile.ShowPerc) then
		self.HPPerc:Show()
	else
		self.HPPerc:Hide()
	end

	-- Clear all points for the percentage display
	self.HPPerc:ClearAllPoints()
	if(self.db.profile.Side == 1) then
		-- Attach to left side
		self.HPPerc:SetPoint("TOP", self.f, "BOTTOMLEFT", -20, -130)
	else
		-- Attach to right side
		self.HPPerc:SetPoint("TOP", self.f, "BOTTOMLEFT", 20, -130)
	end
	if(UnitExists(self.unit)) then
		self.f:SetValue(UnitHealth(self.unit))
		if(UnitIsFriend("player", self.unit)) then
			self:UpdateColor(1)
		else
			self:UpdateColor(2)
		end
	else
		self:UpdateColor(2)
	end
end

function module:OnModuleEnable()
	if not UnitExists(self.unit) then
		self.f:SetMax(100)
		self.f:SetValue(0)
		self.HPPerc:SetText("")
	else
		self.f:SetMax(UnitHealthMax(self.unit))
		self.f:SetValue(UnitHealth(self.unit))
		self.HPPerc:SetText(floor((UnitHealth(self.unit) / UnitHealthMax(self.unit)) * 100).."%")
	end

	-- Register the events we will use
	self:RegisterUnitEvent("UNIT_HEALTH",		"UpdateHealth")
	self:RegisterUnitEvent("UNIT_MAXHEALTH",	"UpdateHealth")
	self:RegisterUnitEvent("UNIT_HEAL_PREDICTION")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")

	-- Activate ring timers
	self:StartRingTimers()

	self.f:Show()
end


function module:PLAYER_FOCUS_CHANGED()
	self.f.alphaState = -1
	if not UnitExists(self.unit) then
		self.f.pulse = false
		self.f:SetMax(100)
		self.f:SetValue(0)
		self.HPPerc:SetText("")
	else
		self.f.pulse = false
		self.tapped = false
		self.friend = false
		self.f:SetMax(UnitHealthMax(self.unit))
		if(UnitIsDead(self.unit)) then
			self.f:GhostMode(false, self.unit)
			self.f:SetValue(0)
			self.HPPerc:SetText("Dead")
		elseif(UnitIsGhost(self.unit)) then
			self.f:GhostMode(true, self.unit)
		else
			self.f:GhostMode(false, self.unit)
			if UnitIsTapDenied(self.unit) then
				self:UpdateColor({r = 0.5, g = 0.5, b = 0.5})
				self.tapped = true
			elseif (UnitIsFriend("player", self.unit)) then
				self:UpdateColor(1)
				self.friend = true
			else
				self:UpdateColor(2)
			end
			self.f:SetValue(UnitHealth(self.unit))
			self.HPPerc:SetText(floor((UnitHealth(self.unit) / UnitHealthMax(self.unit)) * 100).."%")
			
			self:UNIT_HEAL_PREDICTION(nil, self.unit)
		end
	end
end

function module:UpdateHealth(event, arg1)
	if(arg1 == self.unit) then
		if(UnitIsDead(self.unit)) then
			self.f:GhostMode(false, self.unit)
			self.f:SetValue(0)
			self.HPPerc:SetText("Dead")
		elseif(UnitIsGhost(self.unit)) then
			self.f:GhostMode(true, self.unit)
		else
			self.f:GhostMode(false, self.unit)

			-- Update ring color based on target status
			if (not self.tapped and UnitIsTapDenied(self.unit)) then
				self:UpdateColor({r = 0.5, g = 0.5, b = 0.5})
				self.tapped = true
			elseif(not self.friend and UnitIsFriend("player", self.unit)) then
				self:UpdateColor(1)
				self.friend = true
			elseif(self.friend and not UnitIsFriend("player", self.unit)) then
				self:UpdateColor(2)
				self.friend = false
			end

			local health, maxHealth = UnitHealth(self.unit), UnitHealthMax(self.unit)
			self.HPPerc:SetText(floor((health / maxHealth) * 100).."%")
			if (event == "UNIT_MAXHEALTH") then
				self.f:SetMax(maxHealth)
			else
				self.f:SetValue(health)
			end
			
			if self.healPrediction > 0 then
				local ih = self.healPrediction
				if health + ih >= maxHealth then
					ih = maxHealth - health - 1 -- spark will be hidden if <= 0 or >= max
				end
				self.f:SetSpark(health + ih)
			end
		end
	end
end

----------------------------------------------
-- UNIT_HEALTH_PREDICTION
----------------------------------------------
function module:UNIT_HEAL_PREDICTION(event, arg1)
	if self.db.profile.ShowIncoming and (arg1 == self.unit) then
		local ih = UnitGetIncomingHeals(self.unit)
		--self:Debug(1, "ih: %s", tostring(ih))
		if (not ih) or (ih == 0) then
			self.healPrediction = 0
			self.f:SetSpark(0) -- hide
		else
			self.healPrediction = ih
			local health, maxHealth = self.f.endValue, self.f.maxValue
			if health + ih >= maxHealth then
				ih = maxHealth - health - 1 -- spark will be hidden if <= 0 or >= max
			end
			--self:Debug(1, "spark: %s", tostring(health+ih))
			self.f:SetSpark(health + ih)
		end
	end
end
