--
-- Show combo points / holy power / soul shards / ...
--

local _
local class = ""

function ArcHUD:InitComboPointsFrame()
	-- NOTE: Get Player's Class
	_, class = UnitClass("player")
	
	-- NOTE: Demon Hunter Events
	if class == "DEMONHUNTER" and not self.db.profile.ShowBuffs then 
		self:RegisterEvent("UNIT_AURA", "UpdateComboPoints");
	end	
	
	-- NOTE: Deathknight Events
	if class == "DEATHKNIGHT" then 
		self:RegisterEvent("RUNE_POWER_UPDATE", "UpdateComboPoints");
		self:RegisterEvent("RUNE_TYPE_UPDATE", "UpdateComboPoints");
	end
	
	-- NOTE: Unit Power
	if not self.db.profile.TargetFrame then
		self:RegisterEvent("UNIT_POWER_UPDATE", "UpdateComboPoints")
		self:RegisterEvent("UNIT_POWER_FREQUENT", "UpdateComboPoints")
	end
	
	-- NOTE: Dying/Ressurecting/Insance Zoning
	self:RegisterEvent("PLAYER_DEAD", "UpdateComboPoints")
	self:RegisterEvent("PLAYER_UNGHOST", "UpdateComboPoints")
	self:RegisterEvent("PLAYER_ALIVE", "UpdateComboPoints")
	
	self.TargetHUD.Combo:SetTextColor(self.db.profile.ColorComboPoints.r, self.db.profile.ColorComboPoints.g, self.db.profile.ColorComboPoints.b)
	
	-- NOTE: Show/Hide combopoints display
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
	
	if (class == "PALADIN") then
		points = UnitPower("player", SPELL_POWER_HOLY_POWER)
	elseif (class == "WARLOCK") then
		points = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
	elseif (class == "MONK") then
		points = UnitPower("player", SPELL_POWER_CHI)
	elseif (class == "DEATHKNIGHT") then
		points = self:get_active_runes()
	elseif (class == "DEMONHUNTER") then		
		local _, _, count = UnitAura("player", "Soul Fragments")
		if count then 
			points = count
		else 
			points = 0
		end
	elseif (class == "ROGUE" or class == "DRUID") then
		local powerType, powerToken = UnitPowerType("player");
		if (powerType == SPELL_POWER_ENERGY) then
			points = UnitPower("player", SPELL_POWER_COMBO_POINTS);
		end
	end
	self:SetComboPoints(points)
end

function ArcHUD:get_active_runes()
	local runecount = 0;
	for runeslot=1,6 do
		local _, _, runeready = GetRuneCooldown(runeslot);
		if (runeready) then
			runecount = runecount + 1;
		end
	end
	return runecount
end

function ArcHUD:UpdateComboPoints(event, arg1, arg2)
	if (not self:HasComboPoints(class)) then
		self:SetComboPoints(0)
	else
		self:UpdateComboPointsFrame()
	end
end

----------------------------------------------
-- Check whether to display combopoints
----------------------------------------------
function ArcHUD:HasComboPoints(class)
	return ((class == "ROGUE" or class == "DRUID") or
		(class == "PALADIN" and self.db.profile.ShowHolyPowerPoints) or
		(class == "WARLOCK" and self.db.profile.ShowSoulShardPoints) or
		(class == "MONK" and self.db.profile.ShowChiPoints) or
		(class == "DEATHKNIGHT" and self.db.profile.ShowRunePoints) or
		(class == "DEMONHUNTER" and self.db.profile.ShowSoulFragmentPoints))
end