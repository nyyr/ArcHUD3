--
-- Show combo points / holy power / soul shards
--

local oldComboPoints = 0

function ArcHUD:InitComboPointsFrame()
	self:RegisterEvent("UNIT_COMBO_POINTS", "UpdateComboPoints")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateComboPoints")
	
	-- Show/Hide combopoints display
	if(self.db.profile.ShowComboPoints) then
		self.TargetHUD.Combo:Show()
	else
		self.TargetHUD.Combo:Hide()
	end
end

function ArcHUD:SetComboPoints(points)
	if (points > 0) then
		self.TargetHUD.Combo:SetText(points)
	else
		self.TargetHUD.Combo:SetText("")
	end
end

function ArcHUD:UpdateComboPointsFrame()
	local points = 0
	local _, class = UnitClass("player")
	if (class == "PALADIN") then
		points = UnitPower("player", SPELL_POWER_HOLY_POWER)
	elseif (class == "WARLOCK") then
		points = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
	else
		points = GetComboPoints("player")
	end
	self:SetComboPoints(points)
end

function ArcHUD:UpdateComboPoints(event, arg1)
	if ((arg1 == "player") or
		(event == "PLAYER_TARGET_CHANGED" and GetComboPoints("player") > 0)) then
		
		self.TargetHUD.Combo:SetTextColor(
			self.db.profile.ColorComboPoints.r, 
			self.db.profile.ColorComboPoints.g, 
			self.db.profile.ColorComboPoints.b)
		
		oldComboPoints = GetComboPoints("player")
		self:SetComboPoints(oldComboPoints)
	else
		-- we have still some points on previous target
		self.TargetHUD.Combo:SetTextColor(
			self.db.profile.ColorOldComboPoints.r, 
			self.db.profile.ColorOldComboPoints.g, 
			self.db.profile.ColorOldComboPoints.b)
	end
end

