--
-- Show combo points / holy power / soul shards
--

function ArcHUD:InitComboPointsFrame()
	self:RegisterEvent("UNIT_COMBO_POINTS")
	
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
	local _, class = UnitClass("player");
	if (class == "PALADIN") then
		points = UnitPower("player", SPELL_POWER_HOLY_POWER);
	elseif (class == "WARLOCK") then
		points = UnitPower("player", SPELL_POWER_SOUL_SHARDS);
	else
		points = GetComboPoints("player")
	end
	self:SetComboPoints(points)
end

function ArcHUD:UNIT_COMBO_POINTS(event, arg1)
	if (arg1 == "player") then
		self:SetComboPoints(GetComboPoints("player"))
	end
end

