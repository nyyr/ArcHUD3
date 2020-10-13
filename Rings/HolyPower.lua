local module = ArcHUD:NewModule("HolyPower")
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
		Color = PowerBarColor["HOLY_POWER"],
		RingVisibility = 2, -- always fade out when out of combat, regardless of ring status
		ShowTextHuge = false
	}
}
module.options = {
	{name = "Flash", text = "FLASH_HP", tooltip = "FLASH_HP"},
	{name = "ShowTextHuge", text = "SHOWTEXTHUGE", tooltip = "SHOWTEXTHUGE"}, -- fka "combo points"
	attach = true,
	hasseparators = true,
}
module.localized = true

module.class = "PALADIN"
module.specs = { SPEC_PALADIN_RETRIBUTION } -- array of SPEC_... constants; nil if this ring is available for all specs
module.powerType = Enum.PowerType.HolyPower
module.powerTypeString = "HOLY_POWER"
module.flashAt = 3

function module:Initialize()
	self.InitializePowerRing = ArcHUD.templatePowerRing.InitializePowerRing
	self.OnModuleUpdate = ArcHUD.templatePowerRing.OnModuleUpdate
	self.OnModuleEnable = ArcHUD.templatePowerRing.OnModuleEnable
	self.UpdatePowerRing = ArcHUD.templatePowerRing.UpdatePowerRing
	self.UpdatePower = ArcHUD.templatePowerRing.UpdatePower
	self.UpdateActive = ArcHUD.templatePowerRing.UpdateActive

	self:InitializePowerRing()
end
