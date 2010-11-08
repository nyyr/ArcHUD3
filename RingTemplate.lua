-- ArcHUDRingTemplate_ Ring Template
----------------------------------------------------------------------
--
-- Template code for partial ring display
--
-- Divides the ring up into four quadrants:
--   Q1-TopRight Q2-BottomRight Q3-BottomLeft Q4-TopLeft
--
-- Other terminology:
--   self.radius - The outer radius of the ring (Also the texture width)
--   self.ringFactor - The ratio of inner radius/outer radius

---------------------------------------------------------------------------
-- QUADRANT MAPPING FUNCTIONS
--   The subsetting code is all written relative to the first quadrant, but
--   each quadrant has a pair of functions to manage mapping location and
--   texture operations from that 'normalized' coordinate system into the
--   appropriate one for the quadrant in question
--
-- SUBSET FUNCTION
--   self function displays a subset of a quadrant, using a subset of a
--   texture (The texture subsetting is optional, so the same function
--   can be used for slice stretching). Note self does not issue a
--   ClearAllPoints.
--
--   setSubsetFuncs[quadrant](tex, parname, radius, xlo, xhi, ylo, yhi, notex)
--
--   Parameters:
--     tex      - The texture object
--     parname  - The name of the texture's parent (for SetPoint use)
--     radius   - The outer radius of the ring (i.e. texture width & height)
--     xlo, xhi - X Coordinate bounds (from center of the ring)
--     ylo, yhi - Y Coordinate bounds (From center of the ring)
--     notex    - (OPTIONAL) If present and true, do not set texture coords.
--                just change points.
--
-- SLICE FUNCTION
--   self function sets the texture coordinates for a slice texture, so that
--   it's correctly oriented for the quadrant.
--
--   setSliceFuncs[quadrant](tex)
--
--   Parameters:
--     tex      - The slice texture object
--
local setSubsetFuncs = {}
local setSliceFuncs = {}
ArcHUDRingTemplate = {}

-- Q3: BOTTOM LEFT
setSubsetFuncs[1] = function(tex, parname, radius, xlo, xhi, ylo, yhi, notex)
	if (not notex) then
		tex:SetTexCoord(xhi, xlo, ylo, yhi)
	end
	tex:SetPoint("BOTTOMRIGHT", parname, "BOTTOMLEFT", -xlo*radius, -yhi*radius)
	tex:SetPoint("TOPLEFT", parname, "BOTTOMLEFT", -xhi*radius, -ylo*radius)
end

-- Q4: TOP LEFT
setSubsetFuncs[2] = function(tex, parname, radius, xlo, xhi, ylo, yhi, notex)
	if (not notex) then
		tex:SetTexCoord(yhi, ylo, xhi, xlo)
	end
	tex:SetPoint("BOTTOMLEFT", parname, "BOTTOMLEFT", -yhi*radius, xlo*radius)
	tex:SetPoint("TOPRIGHT", parname, "BOTTOMLEFT", -ylo*radius, xhi*radius)
end

-- Q1: TOP RIGHT
setSubsetFuncs[3] = function(tex, parname, radius, xlo, xhi, ylo, yhi, notex)
	if (not notex) then
		tex:SetTexCoord(xlo, xhi, yhi, ylo)
	end
	tex:SetPoint("TOPLEFT", parname, "BOTTOMLEFT", xlo*radius, yhi*radius)
	tex:SetPoint("BOTTOMRIGHT", parname, "BOTTOMLEFT", xhi*radius, ylo*radius)
end

-- Q2: BOTTOM RIGHT
setSubsetFuncs[4] = function(tex, parname, radius, xlo, xhi, ylo, yhi, notex)
	if (not notex) then
		tex:SetTexCoord(ylo, yhi, xlo, xhi)
	end
	tex:SetPoint("TOPRIGHT", parname, "BOTTOMLEFT", yhi*radius, -xlo*radius)
	tex:SetPoint("BOTTOMLEFT", parname, "BOTTOMLEFT", ylo*radius, -xhi*radius)
end

-- Slice text coord setting funcs
setSliceFuncs[1] = function(tex) tex:SetTexCoord(0, 1, 1, 0) end
setSliceFuncs[2] = function(tex) tex:SetTexCoord(1, 0, 1, 0) end
setSliceFuncs[3] = function(tex) tex:SetTexCoord(1, 0, 0, 1) end
setSliceFuncs[4] = function(tex) tex:SetTexCoord(0, 1, 0, 1) end

-----------------------------------------------------------
-- The 'Work' function, which handles subset rendering for a single
-- quadrant (normalized to Q1)
--
-- Params:
--  self - The ring template instance
--  A    - The angle within the quadrant (degrees, 0 <= A < 90)
--  T    - The main texture for the quadrant
--  SS   - The texture subset mapping function for the quadrant
-----------------------------------------------------------
function ArcHUDRingTemplate:DoQuadrantReversed(A, T, SS)
	-- Grab local references to important textures
	local C = self.chip
	local S = self.slice

	-- If no part of self quadrant is visible, just hide all the textures
	-- and be done.
	if (A == 0) then
		T:Hide()
		C:Hide()
		S:Hide()
		return
	end

	-- More local references, grab the ring dimensions, and the frame name.
	local RF = self.ringFactor
	local OR = self.radius

	-- Drawing scheme uses three locations
	--   E (Ex,Ey) - The 'End' position (Nx=1, Ny=0)
	--   O (Ox,Oy) - Intersection of angle line with Outer edge
	--   I (Ix,Iy) - Intersection of angle line with Inner edge

	-- Calculated locations:
	--   Arad  - Angle in radians
	--   Ox,Oy - O coordinates
	--   Ix,Iy - I coordinates
	local Arad = math.rad(A)
	local Ox = math.cos(Arad)
	local Oy = math.sin(Arad)
	local Ix = Ox * RF
	local Iy = Oy * RF

	-- Treat first and last halves differently to maximize size of main
	-- texture subset.
	if (A <= 45) then
		-- Main subset is from N to I
		SS(T, self, OR, Ix, 1,  0, Iy)
		-- Chip is subset from (Ix,Oy) to (Ox,Ny) (Right edge of main)
		SS(C, self, OR, Ox, 1, Iy, Oy)
	else
		-- Main subset is from N to O
		SS(T, self, OR, Ox, 1,  0, Oy)
		-- Chip is subset from (Nx,Iy) to (Ix,Oy) (Bottom edge of main)
		SS(C, self, OR, Ix, Ox, 0, Iy)
	end
	-- Strech slice between I and O
	SS(S, self, OR, Ix, Ox, Iy, Oy, 1)
	-- All three textures are visible
	T:Show()
	C:Show()
	S:Show()
end

function ArcHUDRingTemplate:DoQuadrant(A, T, SS)
	-- Grab local references to important textures
	local C = self.chip
	local S = self.slice

	-- If no part of self quadrant is visible, just hide all the textures
	-- and be done.
	if (A == 0) then
		T:Hide()
		C:Hide()
		S:Hide()
		return
	end

	-- More local references, grab the ring dimensions, and the frame name.
	local RF = self.ringFactor
	local OR = self.radius

	-- Drawing scheme uses three locations
	--   N (Nx,Ny) - The 'Noon' position (Nx=0, Ny=1)
	--   O (Ox,Oy) - Intersection of angle line with Outer edge
	--   I (Ix,Iy) - Intersection of angle line with Inner edge

	-- Calculated locations:
	--   Arad  - Angle in radians
	--   Ox,Oy - O coordinates
	--   Ix,Iy - I coordinates
	local Arad = math.rad(A)
	local Ox = math.sin(Arad)
	local Oy = math.cos(Arad)
	local Ix = Ox * RF
	local Iy = Oy * RF

	-- Treat first and last halves differently to maximize size of main
	-- texture subset.
	if (A <= 45) then
		-- Main subset is from N to I
		SS(T, self, OR, 0, Ix, Iy, 1)
		-- Chip is subset from (Ix,Oy) to (Ox,Ny) (Right edge of main)
		SS(C, self, OR, Ix, Ox, Oy, 1)
	else
		-- Main subset is from N to O
		SS(T, self, OR, 0, Ox, Oy, 1)
		-- Chip is subset from (Nx,Iy) to (Ix,Oy) (Bottom edge of main)
		SS(C, self, OR, 0, Ix, Iy, Oy)
	end
	
	-- Strech slice between I and O
	SS(S, self, OR, Ix, Ox, Iy, Oy, 1)
	
	-- All three textures are visible
	T:Show()
	C:Show()
	S:Show()
end

-----------------------------------------------------------
-- Method function to set the angle to display
--
-- Param:
--  self  - The ring template instance
--  angle - The angle in degrees (0 <= angle <= 180)
-----------------------------------------------------------
function ArcHUDRingTemplate:SetAngle(angle)

	-- Bounds checking on the angle so that it's between 0 and 180 (inclusive)
	if (angle < 0) then
		angle = 0
	end
	if (angle > 180) then
		angle = 180
	end

	-- Avoid duplicate work
	if (self.angle == angle and not self.dirty) then
		return
	end

	-- Determine the quadrant, and angle within the quadrant
	-- (Quadrant 5 means 'all quadrants filled')
	local quad = math.floor(angle / 90) + 1
	local A = math.fmod(angle, 90)
	local quadOfs = self.quadOffset or 0
	local effQuad
	if (self.reversed) then
		effQuad = math.fmod((4-quad)+quadOfs, 4)+1
	else
		effQuad = math.fmod(quad+quadOfs-1, 4)+1
	end

	-- Check to see if we've changed quandrants since the last time we were
	-- called. Quadrant changes re-configure some textures.
	if (quad ~= self.lastQuad or self.dirty) then
		-- Loop through all quadrants
		for i=1,2 do
			T=self.quadrants[i]
			if (self.reversed) then
				qi = math.fmod((4-i)+quadOfs, 4)+1
			else
				qi = math.fmod(i+quadOfs-1, 4)+1
			end
			
			if (i < quad) then
				-- If self quadrant is full shown, then show all of the texture
				T:ClearAllPoints()
				setSubsetFuncs[qi](T, self, self.radius, 0.0, 1.0, 0.0, 1.0)
				T:Show()
				
			elseif (i == quad) then
				-- If self quadrant is partially or fully shown, begin by
				-- showing all of the texture. Also configure the slice
				-- texture's orientation.
				T:ClearAllPoints()
				setSubsetFuncs[qi](T, self, self.radius, 0.0, 0.8, 0.4, 1.0)
				T:Show()
				if (self.reversed) then
					setSliceFuncs[math.fmod(qi+1,4)+1](self.slice)
				else
					setSliceFuncs[qi](self.slice)
				end

			else
				-- If self quadrant is not shown at all, hide it.
				T:Hide()
			end
		end

		-- Hide the chip and slice textures, and de-anchor them (They'll be
		-- re-anchored as necessary later).
		self.chip:Hide()
		self.chip:ClearAllPoints()
		self.slice:Hide()
		self.slice:ClearAllPoints()

		-- Remember self for next time
		self.lastQuad = quad
	end

	-- Remember the angle for next time
	self.angle = angle

	-- Extra bounds check for paranoia (also handles quad 5 case)
	if ((quad < 1) or (quad > 2)) then
	   return
	end

	-- Get quadrant-specific elements
	local T = self.quadrants[quad]
	local SS = setSubsetFuncs[effQuad]

	-- Call the quadrant function to do the work
	if SS ~= nil then
		if (self.reversed) then
			self:DoQuadrantReversed(A, T, SS)
		else
			self:DoQuadrant(A, T, SS)
		end
	end
	self.dirty = false
end

-----------------------------------------------------------
-- StatsRingRingTemplate:CallTextureMethod(method, ...)
--
-- Invokes the named method on all of the textures in the ring,
-- passing in whatever arguments are given.
--
--  e.g. ring:CallTextureMethod("SetVertexColor", 1.0, 0.5, 0.2, 1.0)
-----------------------------------------------------------
function ArcHUDRingTemplate:CallTextureMethod(method, ...)
	self.quadrants[1][method](self.quadrants[1], ...)
	self.quadrants[2][method](self.quadrants[2], ...)
	self.chip[method](self.chip, ...)
	self.slice[method](self.slice, ...)
end

-----------------------------------------------------------
-- StatsRingRingTemplate:SetRingTextures(ringFactor,ringTexFile,sliceTexFile)
--
-- Sets the textures to use for self ring
--
-- Param:
--   ringFactor   - The ring factor (Inner Radius / Outer Radius)
--   ringTexFile  - The ring texture filename
--   sliceTexFile - The slice texture filename
-----------------------------------------------------------
function ArcHUDRingTemplate:SetRingTextures(ringFactor, ringTexture, sliceTexture)
	--DEFAULT_CHAT_FRAME:AddMessage("called setringtextures")
	local savedAngle = self.angle
	self.angle = nil
	self.lastQuad = nil

	self.ringFactor = ringFactor

	for i=1,2 do
		self.quadrants[i]:SetTexture(ringTexture)
	end
	self.chip:SetTexture(ringTexture)
	self.slice:SetTexture(sliceTexture)

	if (savedAngle) then
		self:SetAngle(savedAngle)
	end
end

-----------------------------------------------------------
-- Method function to set whether or not ring growth is reversed.
--
-- Param:
--  self       - The ring template instance
--  isReversed - Whether to reverse or not
-----------------------------------------------------------
function ArcHUDRingTemplate:SetReversed(isReversed)
	if (isReversed) then
		isReversed = true
	else
		isReversed = nil
	end
	if (isReversed == self.reversed) then
		return
	end
	self.reversed = isReversed
	self.dirty = true
end

-----------------------------------------------------------
-- Set maximum value for ring (i.e., value equivalent to 100%)
-----------------------------------------------------------
function ArcHUDRingTemplate:SetMax(max)
	if max == nil then max = 1 end
	self.maxValue = max
end

-----------------------------------------------------------
-- Set current value for ring
-----------------------------------------------------------
function ArcHUDRingTemplate:SetValue(value)
	if value == nil then value = 0 end
	if value == 0 then
		value = self.maxValue / 10000
	end
	if self.casting == 1 then
		self.startValue = value
	end
	self.endValue = value
	self.fadeTime = 0
end

-----------------------------------------------------------
-- Update ring filling towards set value
-- Should be called at least every 40ms for smooth animation
-----------------------------------------------------------
function ArcHUDRingTemplate:DoFadeUpdate(tdelta)
	if (self.UpdateHook) then
		self:UpdateHook(tdelta)
	end
	if self.fadeTime < self.maxFadeTime then
		self.fadeTime = self.fadeTime + tdelta
		if self.fadeTime > self.maxFadeTime then
			self.fadeTime = self.maxFadeTime
		end
		local delta = self.endValue - self.startValue
		local diff = delta * (self.fadeTime / self.maxFadeTime)
		self.startValue = self.startValue + diff
		local angle = self.startValue / self.maxValue * 180
		if angle <= 90 then
			self.ringFactor = 0.9 + ((90 - angle) / (90/0.1))
		elseif angle <= 180 then
			self.ringFactor = 0.9 + ((angle - 90) / (90/0.1))
		end
		self:SetAngle((self.startValue / self.maxValue) * 180)
	end
end

-----------------------------------------------------------
-- Set ring alpha value
-----------------------------------------------------------
function ArcHUDRingTemplate:SetRingAlpha(destAlpha, instant)
	if (destAlpha < 0) then
		destAlpha = 0.0
	elseif (destAlpha > 1) then
		destAlpha = 1.0
	end

	if (instant or not self.applyAlpha) then
		self:SetAlpha(destAlpha)
		self.destAlpha = nil
		return
		
	elseif (self.destAlpha ~= destAlpha) then
		ArcHUD:LevelDebug(1, "ArcHUDRingTemplate:SetRingAlpha("..tostring(destAlpha).."), current "..tostring(self.destAlpha)..", name "..tostring(self:GetName()))
		self.destAlpha = destAlpha
		if (self.applyAlpha:IsPlaying()) then
			self.applyAlpha:Pause()
		end
		self.applyAlpha.alphaAnim:SetChange(destAlpha - self:GetAlpha())
		self.applyAlpha:Play()
	end
end

-----------------------------------------------------------
-- Set ring color
-----------------------------------------------------------
function ArcHUDRingTemplate:UpdateColor(color)
	if color == nil then
		color = {["r"] = 1, ["g"] = 0.6, ["b"] = 0.1}
	end
  	if (color) then
    	self:CallTextureMethod("SetVertexColor",color.r, color.g, color.b,1)
  	end
end

-----------------------------------------------------------
-- Trigger update of alpha value (e.g. on entering combat)
-- TODO: maybe change to event-based triggers
-----------------------------------------------------------
function ArcHUDRingTemplate:CheckAlpha(elapsed)
	if (self.noAutoAlpha) then
		self:Debug(1, "WARN: noAutoAlpha, but CheckAlpha timer started!")
		return
	end

	local isInCombat = false
	local me = self:GetName()
	local unit = self.unit or self:GetParent().unit or "player"

	if (unit == "pet") then
		isInCombat = self.parent.PetIsInCombat
	else
		isInCombat = self.parent.PlayerIsInCombat
	end

	if(self.f.pulse) then
		self.f.alphaPulse = self.f.alphaPulse + (elapsed/2)
		local camt = math.cos(self.f.alphaPulse * self.f.twoPi) * 0.3
		self.f:SetAlpha(0.5-camt)
	else
		-- 1: Fade out when rings are full, regardless of combat status
		-- 2: Always fade out when out of combat, regardless of ring status
		-- 3: Fade out when out of combat or rings are full (default)
		if(self.parent.db.profile.RingVisibility == 1 or self.parent.db.profile.RingVisibility == 3) then
			if(self.parent.db.profile.RingVisibility == 3 and isInCombat) then
				if (not UnitExists(unit)) or (self.isPower and (UnitIsDead(unit) or self.f.maxValue == 0)) then
					self.f:SetRingAlpha(0)
				elseif (self.isHealth and UnitIsDead(unit)) then
					self.f:SetRingAlpha(self.parent.db.profile.FadeFull)
				else
					self.f:SetRingAlpha(self.parent.db.profile.FadeIC)
				end
			else
				local powerTypeId, _ = UnitPowerType(unit)
				-- powerTypeId: 1 = rage, 6 = runic_power
				if (self.isPower and unit ~= "pet" and (powerTypeId == 1 or powerTypeId == 6) and self.f.maxValue > 0) then
					if(math.floor(self.f.startValue) > 0 or math.floor(self.f.startValue) ~= math.floor(self.f.endValue)) then
						self.f:SetRingAlpha(self.parent.db.profile.FadeOOC)
					elseif(math.floor(self.f.startValue) == 0) then
						self.f:SetRingAlpha(self.parent.db.profile.FadeFull)
					end
				else
					if (not UnitExists(unit)) or (self.isPower and (UnitIsDead(unit) or self.f.maxValue == 0)) then
						self.f:SetRingAlpha(0)
					elseif (self.isHealth and UnitIsDead(unit)) then
						self.f:SetRingAlpha(self.parent.db.profile.FadeFull)
					else
						if(self.f.startValue < self.f.maxValue or math.floor(self.f.startValue) ~= math.floor(self.f.endValue)) then
							self.f:SetRingAlpha(self.parent.db.profile.FadeOOC)
						elseif(self.f.startValue == self.f.maxValue) then
							self.f:SetRingAlpha(self.parent.db.profile.FadeFull)
						end
					end
				end
			end

		elseif(self.parent.db.profile.RingVisibility == 2) then
		
			if ((not UnitExists(unit)) or (self.isPower and (UnitIsDead(unit) or self.f.maxValue == 0))) then
				self.f:SetRingAlpha(0)
			elseif (self.isHealth and UnitIsDead(unit)) then
				self.f:SetRingAlpha(self.parent.db.profile.FadeFull)
			else
				if(isInCombat) then
					self.f:SetRingAlpha(self.parent.db.profile.FadeIC)
				else
					self.f:SetRingAlpha(self.parent.db.profile.FadeFull)
				end
			end
			
		end
	end
end

-----------------------------------------------------------
-- (Un)set ghost mode
-----------------------------------------------------------
function ArcHUDRingTemplate:GhostMode(state, unit)
	local color = {["r"] = 0.75, ["g"] = 0.75, ["b"] = 0.75}
	local fh, fm
	if (unit == "player") then
		fh, fm = ArcHUD:GetModule("Health"), ArcHUD:GetModule("Power")
	else
		local capUnit = ArcHUD:strcap(unit)
		fh, fm = ArcHUD:GetModule(capUnit.."Health", true), ArcHUD:GetModule(capUnit.."Power", true)
		if (not fh or not fm) then
			return
		end
	end
	
	if(state) then
		-- Prepare health ring
		if(fh and not fh.f.pulse) then
			fh.f:UpdateColor(color)
			fh.f.alphaPulse = 0
			fh.f:SetMax(1)
			fh.f:SetValue(1)
			if(unit == "player") then
				fh.HPText:SetText(DEAD)
				fh.HPText:SetTextColor(1, 0, 0)
				fh.HPPerc:SetText("")
			else
				fh.HPPerc:SetText(DEAD)
			end
			-- Enable pulsing
			fh.f.pulse = true
		end

		-- Prepare mana ring
		if(fm and unit == "player" and not fm.f.pulse) then
			fm.f:UpdateColor(color)
			fm.f.alphaPulse = 0
			fm.f:SetMax(1)
			fm.f:SetValue(1)
			fm.MPText:SetText("")
			fm.MPPerc:SetText("")
			-- Enable pulsing
			fm.f.pulse = true
		end
	else
		if(fh and fh.f.pulse) then
			fh.f.pulse = false
			fh.f:SetMax(UnitHealthMax(unit))
			fh.f:SetValue(UnitHealth(unit))
		end
		if(fm and fm.f.pulse) then
			fm.f.pulse = false
			fm.f:SetMax(UnitPowerMax(unit))
			fm.f:SetValue(UnitPower(unit))
			fm.f:UpdateColor(PowerBarColor[UnitPowerType(unit)])
		end
	end
end

-- The OnLoad method, call self for each template object to set it up and
-- get things going
function ArcHUDRingTemplate:OnLoad(frame)

	frame.quadrants = {}
	frame.quadrants[1] = frame.ringQuadrant1
	frame.quadrants[2] = frame.ringQuadrant2

	--  Just do global self resolution once.
	--local self = self

	-- Grab texture references and frame name
	--frame.name = frame
	-- if(not frame.quadrants) then
		-- frame.quadrants = {}
		-- frame.quadrants[1] = getglobal(frame.name .. "TQ1")
		-- frame.quadrants[2] = getglobal(frame.name .. "TQ2")
		-- frame.chip         = getglobal(frame.name .. "TC")
		-- frame.slice        = getglobal(frame.name .. "TS")
	-- end

	-- Initialize size and default texture ringFactor
	frame.radius = (frame:GetWidth() * 0.5)
	frame.ringFactor = 0.94

	-- Add ring methods
	frame.DoQuadrant				= self.DoQuadrant
	frame.DoQuadrantReversed		= self.DoQuadrantReversed
	frame.SetAngle          		= self.SetAngle
	frame.CallTextureMethod 		= self.CallTextureMethod
	frame.SetRingTextures   		= self.SetRingTextures
	frame.SetMax					= self.SetMax
	frame.SetValue					= self.SetValue
	frame.Update					= self.Update
	frame.AddUpdateFunction			= self.AddUpdateFunction
	frame.RemoveUpdateFunction		= self.RemoveUpdateFunction
	frame.UpdateColor				= self.UpdateColor
	frame.SetReversed				= self.SetReversed
	frame.SetRingAlpha				= self.SetRingAlpha
	frame.GhostMode					= self.GhostMode

	frame.startValue = 0
	frame.endValue = 0
	frame.maxValue = 0
	frame.fadeTime = 0
	frame.maxFadeTime = 1
	frame.alphaState = -1
	frame.PI = 3.14159265
	frame.twoPi = (frame.PI * 2)
	frame.pulse = false
	frame.alphaPulse = 0
	
	-- Animation groups
	frame.fillUpdate = frame.fillUpdateFrame.fillUpdate

	-- Set angle to zero (initializes texture visibility)
	frame:SetAngle(0)
end

function ArcHUDRingTemplate:OnLoadBG(frame)

	frame.quadrants = {}
	frame.quadrants[1] = frame.ringQuadrant1
	frame.quadrants[2] = frame.ringQuadrant2

	-- Grab texture references and frame name
	--frame.name = frame
--	frame.name = frame
	-- if(not frame.quadrants) then
		-- frame.quadrants = {}
		-- frame.quadrants[1] = getglobal(frame.name .. "TQ1")
		-- frame.quadrants[2] = getglobal(frame.name .. "TQ2")
		-- frame.chip         = getglobal(frame.name .. "TC")
		-- frame.slice        = getglobal(frame.name .. "TS")
	-- end

	-- Initialize size and default texture ringFactor
	frame.radius = (frame:GetWidth() * 0.5)
	frame.ringFactor = 0.94

	-- Add ring methods
	frame.DoQuadrant				= self.DoQuadrant
	frame.DoQuadrantReversed		= self.DoQuadrantReversed
	frame.SetAngle          		= self.SetAngle
	frame.CallTextureMethod 		= self.CallTextureMethod
	frame.UpdateColor				= self.UpdateColor
	frame.SetReversed				= self.SetReversed

	-- Set angle to 180 degrees (initializes texture visibility)
	frame:SetAngle(180)

	-- Set color and then remove the method again
	frame:UpdateColor({r = 0, g = 0, b = 0})
	frame.UpdateColor = nil
	frame.CallTextureMethod = nil
end
