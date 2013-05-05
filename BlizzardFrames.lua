
----------------------------------------------
-- Blizzard Frame functions
-- Hide/show player & pet frame
----------------------------------------------
function ArcHUD:HideBlizzardPlayer(show)
	self.BlizzPlayerHidden = not show
	if not show then
		PlayerFrame:UnregisterAllEvents()
		PlayerFrame:Hide()

		PetFrame:UnregisterAllEvents()
		PetFrame:Hide()
		
		RuneFrame:Hide()
	else
		PlayerFrame:RegisterAllEvents()
		PlayerFrame:Show()
		PlayerFrame_Update()
		
		PetFrame:RegisterAllEvents()
		PetFrame_Update(PetFrame, true)
		
		local _, class = UnitClass("player")
		if ( class == "DEATHKNIGHT" ) then
			RuneFrame:Show()
		end
	end
end

----------------------------------------------
-- Blizzard Frame functions
-- Hide/show target frame
----------------------------------------------
function ArcHUD:HideBlizzardTarget(show)
	self.BlizzTargetHidden = not show
	if not show then
		TargetFrame:UnregisterAllEvents()
		TargetFrame:Hide()
		
		ComboFrame:UnregisterAllEvents()
		ComboFrame:Hide()
	else
		TargetFrame:RegisterAllEvents()
		TargetFrame_Update(TargetFrame)
		
		ComboFrame:RegisterAllEvents()
		ComboFrame_Update()
	end
end

----------------------------------------------
-- Blizzard Frame functions
-- Hide/show focus frame
----------------------------------------------
function ArcHUD:HideBlizzardFocus(show)
	self.BlizzFocusHidden = not show
	if not show then
		FocusFrame:UnregisterAllEvents()
		FocusFrame:Hide()
	else
		FocusFrame:RegisterAllEvents()
		-- TODO: need to refresh focus frame
	end
end

----------------------------------------------
-- Blizzard Frame functions
-- Spell Activation - FadeInPlay
----------------------------------------------
function ArcHUD_SpellActivationOverlayTexture_OnFadeInPlay(animGroup)
	animGroup:GetParent():SetAlpha(0)
	
	local alphaAnim, _ = animGroup:GetAnimations()
	alphaAnim:SetChange(ArcHUD.db.profile.BlizzSpellActOpacity)
	
	alphaAnim, _ = animGroup:GetParent().animOut:GetAnimations()
	alphaAnim:SetChange(-1 * ArcHUD.db.profile.BlizzSpellActOpacity)
end

----------------------------------------------
-- Blizzard Frame functions
-- Spell Activation - FadeInFinished
----------------------------------------------
function ArcHUD_SpellActivationOverlayTexture_OnFadeInFinished(animGroup)
	local overlay = animGroup:GetParent()
	overlay:SetAlpha(ArcHUD.db.profile.BlizzSpellActOpacity)
	overlay.pulse:Play()
end

----------------------------------------------
-- Blizzard Frame functions
-- Spell Activation Hook
----------------------------------------------
function ArcHUD:HookBlizzardSpellActivation(hook)
	if (not self.BlizzSpellActivationHooked) and hook then
		self.BlizzSpellActivationOverlayTexture_OnFadeInPlay = SpellActivationOverlayTexture_OnFadeInPlay
		self.BlizzSpellActivationOverlayTexture_OnFadeInFinished = SpellActivationOverlayTexture_OnFadeInFinished
		SpellActivationOverlayTexture_OnFadeInPlay = ArcHUD_SpellActivationOverlayTexture_OnFadeInPlay
		SpellActivationOverlayTexture_OnFadeInFinished = ArcHUD_SpellActivationOverlayTexture_OnFadeInFinished
		self.BlizzSpellActivationHooked = true
		
	elseif self.BlizzSpellActivationHooked and (not hook) then
		SpellActivationOverlayTexture_OnFadeInPlay = self.BlizzSpellActivationOverlayTexture_OnFadeInPlay
		SpellActivationOverlayTexture_OnFadeInFinished = self.BlizzSpellActivationOverlayTexture_OnFadeInFinished
		self.BlizzSpellActivationHooked = nil
	end
end

