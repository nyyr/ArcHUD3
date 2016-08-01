--
-- Show combo points / holy power / soul shards
--

local _
local class = ""

function ArcHUD:InitComboPointsFrame()
	 _, class = UnitClass("player")
	
	if ((class == "ROGUE") or (class == "DRUID")) then
		self:RegisterEvent("UNIT_POWER_FREQUENT", "UpdateComboPoints", "player");
		self:UpdateComboPointsFrame()
	end
	
	self.TargetHUD.Combo:SetTextColor(self.db.profile.ColorComboPoints.r, self.db.profile.ColorComboPoints.g, self.db.profile.ColorComboPoints.b)
	
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
	elseif (class == "MONK") then
		points = UnitPower("player", SPELL_POWER_CHI)
	elseif (class == "ROGUE" or class == "DRUID") then
		local powerType, powerToken = UnitPowerType("player");
		if (powerType == SPELL_POWER_ENERGY) then
			points = UnitPower("player", SPELL_POWER_COMBO_POINTS);
		end
	end
	self:SetComboPoints(points)
end

function ArcHUD:UpdateComboPoints(event, arg1, arg2)
	--self:LevelDebug(3, "UpdateComboPoints("..tostring(event)..", "..tostring(arg1)..")")
	if (event == "UNIT_POWER_FREQUENT") then
		if (arg1 == "player" and arg2 == "COMBO_POINTS") then
			self:UpdateComboPointsFrame()
		end
	else
		self:UpdateComboPointsFrame()
	end
end
