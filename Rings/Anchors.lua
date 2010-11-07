local module = ArcHUD:NewModule("Anchors")

module.noAutoAlpha = true

module.defaults = {
	profile = {
		Enabled = true
	}
}

function module:Initialize()
	-- Setup the frames we need
	self:Debug(3, "Setting up anchor frames")
	self.Left = self:CreateRing(false, ArcHUDFrame)
	self.Right = self:CreateRing(false, ArcHUDFrame)

	self.Left:SetAlpha(0)

	self.Right:SetReversed(true)
	self.Right:SetAlpha(0)
end
