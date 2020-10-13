local module = ArcHUD:NewModule("ComboPointsDruid")
module.version = "5.0 (243459a)"

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
		Color = PowerBarColor["COMBO_POINTS"],
		RingVisibility = 2, -- always fade out when out of combat, regardless of ring status
		ShowTextHuge = true
	}
}
module.options = {
	{name = "Flash", text = "FLASH", tooltip = "FLASH"},
	{name = "ShowTextHuge", text = "SHOWTEXTHUGE", tooltip = "SHOWTEXTHUGE"}, -- fka "combo points"
	attach = true,
	hasseparators = true,
}
module.localized = true

module.class = "DRUID"
module.specs = nil -- array of SPEC_... constants; nil if this ring is available for all specs
module.powerType = Enum.PowerType.ComboPoints
module.powerTypeString = "COMBO_POINTS"
module.flashAt = nil -- flash when full

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
	local formId = GetShapeshiftFormID()
	return formId == CAT_FORM
end
