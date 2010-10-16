local module = ArcHUD:NewModule("FocusHealth")
local _, _, rev = string.find("$Rev: 81 $", "([0-9]+)")
module.version = "2.1." .. rev
module.unit = "focus"
module.defaults = {
	Enabled = false,
	Outline = true,
	ShowPerc = true,
	ColorMode = "default",
	ColorFriend = {r = 0, g = 0.5, b = 1},
	ColorFoe = {r = 1, g = 0, b = 0},
	Side = 1,
	Level = 1,
}
module.options = {
	{name = "ShowPerc", text = "SHOWPERC", tooltip = "SHOWPERC"},
	hasfriendfoe = true,
	attach = true,
}
module.localized = true

function module:Initialize()
	-- Setup the frame we need
	self.f = self:CreateRing(true, ArcHUDFrame)
	self.f:SetAlpha(0)

	self.HPPerc = self:CreateFontString(self.f, "BACKGROUND", {40, 12}, 11, "RIGHT", {1.0, 1.0, 1.0}, {"TOPLEFT", self.f, "BOTTOMLEFT", -100, -115})
end

function module:Update()
	if(self.db.profile.ShowPerc) then
		self.HPPerc:Show()
	else
		self.HPPerc:Hide()
	end

	-- Clear all points for the percentage display
	self.HPPerc:ClearAllPoints()
	if(self.db.profile.Side == 1) then
		-- Attach to left side
		self.HPPerc:SetPoint("TOPLEFT", self.f, "BOTTOMLEFT", -100, -115)
	else
		-- Attach to right side
		self.HPPerc:SetPoint("TOPLEFT", self.f, "BOTTOMLEFT", 50, -115)
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

function module:Enable()
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
	self:RegisterEvent("UNIT_HEALTH",			"UpdateHealth")
	self:RegisterEvent("UNIT_MAXHEALTH",		"UpdateHealth")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")

	-- Activate the timers
	self:StartMetro(self.name .. "Alpha")
	self:StartMetro(self.name .. "Fade")
	self:StartMetro(self.name .. "Update")

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
			if (UnitIsTapped(self.unit) and not UnitIsTappedByPlayer(self.unit)) then
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
		end
	end
end

function module:UpdateHealth()
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
			if(not self.tapped and UnitIsTappedByPlayer(self.unit) and not UnitIsTappedByPlayer(self.unit)) then
				self:UpdateColor({r = 0.5, g = 0.5, b = 0.5})
				self.tapped = true
			elseif(not self.friend and UnitIsFriend("player", self.unit)) then
				self:UpdateColor(1)
				self.friend = true
			elseif(self.friend and not UnitIsFriend("player", self.unit)) then
				self:UpdateColor(2)
				self.friend = false
			end

			self.HPPerc:SetText(floor((UnitHealth(self.unit) / UnitHealthMax(self.unit)) * 100).."%")
			if (event == "UNIT_MAXHEALTH") then
				self.f:SetMax(UnitHealthMax(self.unit))
			else
				self.f:SetValue(UnitHealth(self.unit))
			end
		end
	end
end
