local module = ArcHUD:NewModule("ManaBalanceDruid")
module.version = "5.0 (427bc14)"

module.unit = "player"
module.noAutoAlpha = nil

module.defaults = {
	profile = {
		Enabled = true,
		Outline = true,
		Flash = false,
		Side = 2,
		Level = 1,
		ShowSeparators = false,
		Color = PowerBarColor["MANA"],
		ShowTextHuge = false
	}
}
module.options = {
	attach = true
}
module.localized = true

module.class = "DRUID"
module.specs = nil -- array of SPEC_... constants; nil if this ring is available for all specs
module.powerType = Enum.PowerType.Mana
module.powerTypeString = "MANA"
module.flashAt = nil

function module:Initialize()
	self.InitializePowerRing = ArcHUD.templatePowerRing.InitializePowerRing
	self.OnModuleUpdate = ArcHUD.templatePowerRing.OnModuleUpdate
	self.OnModuleEnable = ArcHUD.templatePowerRing.OnModuleEnable
	self.UpdatePowerRing = ArcHUD.templatePowerRing.UpdatePowerRing
	self.UpdatePower = ArcHUD.templatePowerRing.UpdatePower
	self.UpdateActive = ArcHUD.templatePowerRing.UpdateActive

	self:InitializePowerRing()
end

--
-- Can be overridden in case more events must be registered (e.g., for detecting shapeshifts)
--
function module:OnActiveChanged(oldState, newState)
	if newState then
		-- Register additional events
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "UpdateActive")
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", "UpdateActive")
	else
		-- Unregister additional events
		self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM")
		self:UnregisterEvent("UPDATE_SHAPESHIFT_FORMS")
	end
end

--
-- Can be overridden in case other conditions apply (e.g., shapeshift form)
--
function module:CheckVisible()
	local powerType = UnitPowerType(self.unit)
	return powerType == Enum.PowerType.LunarPower
end