local module = ArcHUD:NewModule("Chi")
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
		Color = PowerBarColor["CHI"],
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

module.class = "MONK"
if ArcHUD.isClassicMop then
	module.specs = nil -- array of SPEC_... constants; nil if this ring is available for all specs
else
	module.specs = { SPEC_MONK_WINDWALKER } -- array of SPEC_... constants; nil if this ring is available for all specs
end
module.powerType = Enum.PowerType.Chi
module.powerTypeString = "CHI"
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
