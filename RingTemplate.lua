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

local PI = 3.14159265
local TWOPI = (PI * 2)

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
--  A2   - The other angle within the quandrant (degrees, 0 <= A < 90)
-----------------------------------------------------------
function ArcHUDRingTemplate:DoQuadrantReversed(A, T, SS, A2)
	-- Grab local references to important textures
	local C1 = self.chip1  -- upper or left part
	local C2 = self.chip2  -- lower or right part
	local S1 = self.slice1 -- upper slice
	local S2 = self.slice2 -- lower slice
	
	if (not A2) then A2 = 0 end

	-- If no part of self quadrant is visible, just hide all the textures
	-- and be done.
	if ((A - A2) <= 0) then
		T:Hide()
		-- don't hide chips/slices if used by other quadrants
		if (self.angle == 180 or self.angle == 0) then
			C1:Hide(); S1:Hide()
		end
		if (self.startAngle == 0) then
			C2:Hide(); S2:Hide()
		end
		return
	end

	--        N    O
	--        |  I \ EO
	--        |   EI
	-- W      +------ E
	-- 
	-- 
	--        S
	
	-- Ring fills from E to N (N = 90°, E = 0°)
	-- Drawing scheme uses three/four locations
	--   E (Ex,Ey) - The start position of the arc (Ex=1, Ey=0 if start angle = 0) (towards East)
	--   O (Ox,Oy) - Intersection of angle line with Outer edge
	--   I (Ix,Iy) - Intersection of angle line with Inner edge

	-- Calculated locations:
	--   Arad  - Angle in radians
	--   Ox,Oy - O coordinates
	--   Ix,Iy - I coordinates
	local Ox; local Oy
	local Ix; local Iy
	local corr1 -- small correction (not sure why this is necessary)
	if (A < 90) then
		local RF = self.ringFactor1
		local Arad = math.rad(A)
		local cos_a = math.cos(Arad)
		corr1 = cos_a/128
		Ox = cos_a
		Oy = math.sin(Arad)
		Ix = Ox * RF - corr1
		Iy = Oy * RF - corr1
	else -- upper/left end is at North (angle == 90)
		Ox = 0; Oy = 1
		Ix = 0; Iy = 1
	end
	
	-- Same for start of arc
	local EOx; local EOy
	local EIx; local EIy
	local corr2 -- small correction (not sure why this is necessary)
	if (A2 > 0) then
		local SRF = self.ringFactor2
		local A2rad = math.rad(A2)
		local cos_a2 = math.cos(A2rad)
		corr2 = cos_a2/128
		EOx = cos_a2
		EOy = math.sin(A2rad)
		EIx = EOx * SRF - corr2
		EIy = EOy * SRF - corr2
	else -- lower/right end is at East (angle == 0)
		EOx = 1; EOy = 0
		EIx = 1; EIy = 0
	end

	local OR = self.radius
	
	-- roughly maximize main texture size
	if (A <= 45) then
		-- 'cut' textures horizontally
		if (A < 90) then
			-- Chip1 subset is from O to (EOx,Iy)
			SS(C1, self, OR, Ox, EOx, Iy, Oy)
		end
		-- Main subset is from I to EO
		SS(T, self, OR, Ix, EOx, EOy, Iy)
		if (A2 > 0) then
			-- Chip2 subset is from (Ix,EOy) to (EIx,EIy)
			SS(C2, self, OR, Ix, EIx, EIy, EOy)
		end
	else
		-- 'cut' textures vertically
		if (A < 90) then
			-- Chip1 subset is from I to (Ox,EIy)
			SS(C1, self, OR, Ix, Ox, EIy, Iy)
		end
		-- Main subset is from O to EI
		SS(T, self, OR, Ox, EIx, EIy, Oy)
		if (A2 > 0) then
			-- Chip2 subset is from (EIx,Oy) to EO
			SS(C2, self, OR, EIx, EOx, EOy, Oy)
		end
	end
	
	-- Strech slices between I and O
	if (A < 90) then
		SS(S1, self, OR, Ix, Ox, Iy, Oy, 1)
	end
	if (A2 > 0) then
		SS(S2, self, OR, EIx, EOx, EIy, EOy, 1)
	end
	
	T:Show()
end

-----------------------------------------------------------
-- Counter-part of DoQuadrantReversed()
-- also normalized to Q1
-----------------------------------------------------------
function ArcHUDRingTemplate:DoQuadrant(A, T, SS, A2)
	-- Grab local references to important textures
	local C1 = self.chip1  -- lower or right part
	local C2 = self.chip2  -- upper or left part
	local S1 = self.slice1 -- lower slice
	local S2 = self.slice2 -- upper slice
	
	if (not A2) then A2 = 0 end

	-- If no part of self quadrant is visible, just hide all the textures
	-- and be done.
	if ((A - A2) <= 0) then
		T:Hide()
		-- don't hide chips/slices if used by other quadrants
		if (self.angle == 180 or self.angle == 0) then
			C1:Hide(); S1:Hide()
		end
		if (self.startAngle == 0) then
			C2:Hide(); S2:Hide()
		end
		return
	end

	--        N    NO
	--        | NI \ O
	--        |    I
	-- W      +------ E
	-- 
	-- 
	--        S
	
	-- Ring fills from N to E (N = 0°, E = 90°)
	-- Drawing scheme uses three/four locations
	--   N (Nx,Ny) - The start position of the arc (Nx=0, Ny=1 if start angle = 0) (towards North)
	--   O (Ox,Oy) - Intersection of angle line with Outer edge
	--   I (Ix,Iy) - Intersection of angle line with Inner edge

	-- Calculated locations:
	--   Arad  - Angle in radians
	--   Ox,Oy - O coordinates
	--   Ix,Iy - I coordinates
	local Ox; local Oy
	local Ix; local Iy
	local corr1 -- small correction (not sure why this is necessary)
	if (A < 90) then
		local RF = self.ringFactor1
		local Arad = math.rad(A)
		local cos_a = math.cos(Arad)
		corr1 = cos_a/128
		Ox = math.sin(Arad)
		Oy = cos_a
		Ix = Ox * RF - corr1
		Iy = Oy * RF - corr1
	else -- lower/right end is at East (angle == 90)
		Ox = 1; Oy = 0
		Ix = 1; Iy = 0
	end
	
	-- Same for start of arc
	local NOx; local NOy
	local NIx; local NIy
	local corr2 -- small correction (not sure why this is necessary)
	if (A2 > 0) then
		local SRF = self.ringFactor2
		local A2rad = math.rad(A2)
		local cos_a2 = math.cos(A2rad)
		corr2 = cos_a2/128
		NOx = math.sin(A2rad)
		NOy = cos_a2
		NIx = NOx * SRF - corr2
		NIy = NOy * SRF - corr2
	else -- upper/left end is at North (angle == 0)
		NOx = 0; NOy = 1
		NIx = 0; NIy = 1
	end

	local OR = self.radius
	
	-- roughly maximize main texture size
	if (A > 45) then
		-- 'cut' textures horizontally
		if (A < 90) then
			-- Chip1 subset is from I to (NIx,Oy)
			SS(C1, self, OR, NIx, Ix, Iy, Oy)
		end
		-- Main subset is from O to NI
		SS(T, self, OR, NIx, Ox, Oy, NIy)
		if (A2 > 0) then
			-- Chip2 subset is from NO to (Ox,NIy)
			SS(C2, self, OR, NOx, Ox, NIy, NOy)
		end
	else
		-- 'cut' textures vertically
		if (A < 90) then
			-- Chip1 subset is from (Ix,NOy) to O
			SS(C1, self, OR, Ix, Ox, Oy, NOy)
		end
		-- Main subset is from NO to I
		SS(T, self, OR, NOx, Ix, Iy, NOy)
		if (A2 > 0) then
			-- Chip2 subset is from NI to (NOx,Iy)
			SS(C2, self, OR, NIx, NOx, Iy, NIy)
		end
	end
	
	-- Strech slices between I and O
	if (A < 90) then
		SS(S1, self, OR, Ix, Ox, Iy, Oy, 1)
	end
	if (A2 > 0) then
		SS(S2, self, OR, NIx, NOx, NIy, NOy, 1)
	end
	
	T:Show()
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
	if ((self.angle == angle) and not self.dirty) then
		return
	end
	
	-- Remember the angle for next time
	self.angle = angle
	if angle <= 90 then
		self.ringFactor = 0.9 + ((90 - angle) / (90/0.1))
	elseif angle <= 180 then
		self.ringFactor = 0.9 + ((angle - 90) / (90/0.1))
	end
	
	-- inverse fill?
	local angle1
	local angle2
	if self.inverseFill then
		angle1 = self.endAngle
		angle2 = angle
		self.ringFactor1 = self.endAngleRingFactor
		self.ringFactor2 = self.ringFactor
	else
		angle1 = angle
		angle2 = self.startAngle
		self.ringFactor1 = self.ringFactor
		self.ringFactor2 = self.startAngleRingFactor
	end
	
	-- adjust connected ring part
	if self.nextRingPart then
		self.nextRingPart:MoveBaseAngle(angle)
	end
	
	-- Hide ring completely if nothing can be shown
	if ((angle1 - angle2) <= 0) then
		self.quadrants[1]:Hide()
		self.quadrants[1]:ClearAllPoints()
		self.quadrants[2]:Hide()
		self.quadrants[2]:ClearAllPoints()
		self.chip1:Hide()
		self.chip1:ClearAllPoints()
		self.slice1:Hide()
		self.slice1:ClearAllPoints()
		self.chip2:Hide()
		self.chip2:ClearAllPoints()
		self.slice2:Hide()
		self.slice2:ClearAllPoints()
		return
	end
	
	-- Determine the quadrant, and angle within the quadrant
	-- (Quadrant 5 means 'all quadrants filled')
	local quad1 = math.floor(angle1 / 90) + 1
	local quad2 = math.floor(angle2 / 90) + 1
	local A1 = math.fmod(angle1, 90)
	local A2 = math.fmod(angle2, 90)
	local quadOfs = self.quadOffset or 0
	local effQuad1
	local effQuad2
	if (self.reversed) then
		effQuad1 = math.fmod((4-quad1)+quadOfs, 4)+1
		effQuad2 = math.fmod((4-quad2)+quadOfs, 4)+1
	else
		effQuad1 = math.fmod(quad1+quadOfs-1, 4)+1
		effQuad2 = math.fmod(quad2+quadOfs-1, 4)+1
	end
	
	-- Check to see if we've changed quandrants since the last time we were
	-- called. Quadrant changes re-configure some textures.
	if ((quad1 ~= self.lastQuad) or self.dirty) then
	
		-- Loop through all quadrants
		for i=1,2 do
			T=self.quadrants[i]
			if (self.reversed) then
				qi = math.fmod((4-i)+quadOfs, 4)+1
			else
				qi = math.fmod(i+quadOfs-1, 4)+1
			end
			
			if (i < quad1) then
				T:ClearAllPoints()
				if (i < quad2) then
					-- quadrant is not shown at all, hide it
					T:Hide()
				elseif (i == quad2) then
					-- start angle lies within this quadrant, end angle does not
					local SS = setSubsetFuncs[effQuad2]
					if (self.reversed) then
						self:DoQuadrantReversed(90, T, SS, A2)
					else
						self:DoQuadrant(90, T, SS, A2)
					end
					T:Show()
				else
					-- quadrant is fully shown, show all of the texture
					setSubsetFuncs[qi](T, self, self.radius, 0.0, 1.0, 0.0, 1.0)
					T:Show()
				end
				
			elseif (i == quad1) then
				-- If self quadrant is partially or fully shown, begin by
				-- showing all of the texture. Also configure the slice
				-- texture's orientation.
				T:ClearAllPoints()
				T:Show()
				if (self.reversed) then
					setSliceFuncs[math.fmod(qi+1,4)+1](self.slice1)
				else
					setSliceFuncs[qi](self.slice1)
				end

			else
				-- If self quadrant is not shown at all, hide it.
				T:Hide()
			end
			
			if (i == quad2) then
				if (self.reversed) then
					setSliceFuncs[effQuad2](self.slice2)
				else
					setSliceFuncs[math.fmod(effQuad2+1,4)+1](self.slice2)
				end
				self.chip2:Show()
				self.slice2:Show()
			end
		end
		
		-- Hide the chip and slice textures, and de-anchor them (They'll be
		-- re-anchored as necessary later).
		self.chip1:Hide()
		self.chip1:ClearAllPoints()
		self.slice1:Hide()
		self.slice1:ClearAllPoints()
		if (angle2 == 0) then
			self.chip2:Hide()
			self.chip2:ClearAllPoints()
			self.slice2:Hide()
			self.slice2:ClearAllPoints()
		end
		
		-- Remember self for next time
		self.lastQuad = quad1
	end
	
	-- Extra bounds check for paranoia (also handles quad 5 case)
	if ((quad1 < 1) or (quad1 > 2)) then
	   return
	end

	-- Get quadrant-specific elements
	local T = self.quadrants[quad1]
	local SS = setSubsetFuncs[effQuad1]
	
	-- Call the quadrant function to do the work
	if SS ~= nil then
		if (quad1 == quad2) then
			-- Start angle and end angle are within the same quadrant.		
			if (self.reversed) then
				self:DoQuadrantReversed(A1, T, SS, A2)
			else
				self:DoQuadrant(A1, T, SS, A2)
			end
		else
			if (self.reversed) then
				self:DoQuadrantReversed(A1, T, SS)
			else
				self:DoQuadrant(A1, T, SS)
			end
		end
	end
	
	if (angle1 == 180 or angle1 == 0) then
		self.chip1:Hide()
		self.slice1:Hide()
	else
		self.chip1:Show()
		self.slice1:Show()
	end
	
	if (angle2 == 0) then
		self.chip2:Hide()
		self.slice2:Hide()
	else
		self.chip2:Show()
		self.slice2:Show()
	end

	self.dirty = false
end

-----------------------------------------------------------
-- Method function to set the start angle to display
--
-- Param:
--  self  - The ring template instance
--  angle - The start angle in degrees (0 <= angle <= 180)
-----------------------------------------------------------
function ArcHUDRingTemplate:SetStartAngle(angle)
	-- Bounds checking on the angle so that it's between 0 and 180 (inclusive)
	if (angle < 0) then
		angle = 0
	end
	if (angle > 180) then
		angle = 180
	end

	-- Avoid duplicate work
	if ((self.startAngle == angle) and not self.dirty) then
		return
	end
	
	-- Determine the quadrant
	-- (Quadrant 5 means 'all quadrants filled')
	local quad = math.floor(angle / 90) + 1
	local quadOfs = self.quadOffset or 0
	local effQuad
	if (self.reversed) then
		effQuad = math.fmod((4-quad)+quadOfs, 4)+1
	else
		effQuad = math.fmod(quad+quadOfs-1, 4)+1
	end

	-- Check to see if we've changed quandrants since the last time we were
	-- called. Quadrant changes re-configure some textures.
	if ((quad ~= self.lastStartQuad) or self.dirty) then
		-- Configure the slice texture's orientation
		if (self.reversed) then
			setSliceFuncs[effQuad](self.slice2)
		else
			setSliceFuncs[math.fmod(effQuad+1,4)+1](self.slice2)
		end

		-- Hide the chip and slice textures, and de-anchor them
		self.chip2:Hide()
		self.chip2:ClearAllPoints()
		self.slice2:Hide()
		self.slice2:ClearAllPoints()

		-- Remember self for next time
		self.lastStartQuad = quad
	end
	
	-- Remember some values for later use
	if angle <= 90 then
		self.startAngleRingFactor = 0.9 + ((90 - angle) / (90/0.1))
	elseif angle <= 180 then
		self.startAngleRingFactor = 0.9 + ((angle - 90) / (90/0.1))
	end
	self.startAngle = angle
	self.startQuad = quad
	self.effStartQuad = effQuad
end

-----------------------------------------------------------
-- Method function to set the end angle to display
--
-- Param:
--  self  - The ring template instance
--  angle - The start angle in degrees (0 <= angle <= 180)
-----------------------------------------------------------
function ArcHUDRingTemplate:SetEndAngle(angle)
	-- Bounds checking on the angle so that it's between 0 and 180 (inclusive)
	if (angle < 0) then
		angle = 0
	end
	if (angle > 180) then
		angle = 180
	end

	-- Avoid duplicate work
	if ((self.endAngle == angle) and not self.dirty) then
		return
	end
	
	-- Determine the quadrant
	-- (Quadrant 5 means 'all quadrants filled')
	local quad = math.floor(angle / 90) + 1
	local quadOfs = self.quadOffset or 0
	local effQuad
	if (self.reversed) then
		effQuad = math.fmod((4-quad)+quadOfs, 4)+1
	else
		effQuad = math.fmod(quad+quadOfs-1, 4)+1
	end

	-- Check to see if we've changed quandrants since the last time we were
	-- called. Quadrant changes re-configure some textures.
	if ((quad ~= self.lastEndQuad) or self.dirty) then
		-- Configure the slice texture's orientation
		if (self.reversed) then
			setSliceFuncs[effQuad](self.slice1)
		else
			setSliceFuncs[math.fmod(effQuad+1,4)+1](self.slice1)
		end

		-- Hide the chip and slice textures, and de-anchor them
		self.chip1:Hide()
		self.chip1:ClearAllPoints()
		self.slice1:Hide()
		self.slice1:ClearAllPoints()

		-- Remember self for next time
		self.lastEndQuad = quad
	end
	
	-- Remember some values for later use
	if angle <= 90 then
		self.endAngleRingFactor = 0.9 + ((90 - angle) / (90/0.1))
	elseif angle <= 180 then
		self.endAngleRingFactor = 0.9 + ((angle - 90) / (90/0.1))
	end
	self.endAngle = angle
	self.endQuad = quad
	self.effEndQuad = effQuad
end

-----------------------------------------------------------
-- MoveBaseAngle(angle)
-- Moves the arc so it starts from a new base angle
-- Note: the maximum angle is not touched, only start angle and current angle
-----------------------------------------------------------
function ArcHUDRingTemplate:MoveBaseAngle(angle)
	--if self.inverseFill then
		-- TODO
	--else
		local diff = angle - self.startAngle
		self.dirty = true
		self:SetStartAngle(angle)
		self:SetAngle(self.angle + diff)
	--end
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
	self.chip1[method](self.chip1, ...)
	self.chip2[method](self.chip2, ...)
	self.slice1[method](self.slice1, ...)
	self.slice2[method](self.slice2, ...)
end

-----------------------------------------------------------
-- Calculate angle for given value
-----------------------------------------------------------
function ArcHUDRingTemplate:GetAngle(value)
	local angle
	if self.inverseFill then
		angle = self.endAngle - self.startValue / self.maxValue * (self.endAngle - self.startAngle)
	else
		angle = self.startValue / self.maxValue * (self.endAngle - self.startAngle) + self.startAngle
	end
	return angle
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
	if (self.startAngle) then
		self:SetStartAngle(self.startAngle)
	end
end

-----------------------------------------------------------
-- Set maximum value for ring (i.e., value equivalent to 100%)
-----------------------------------------------------------
function ArcHUDRingTemplate:SetMax(max)
	if max == nil then max = 1 end
	if max <= 0 then max = 1 end
	if (self.startValue > max) then
		self.startValue = max
	end
	if (self.endValue > max) then
		self.endValue = max
	end
	if (max ~= self.maxValue) then
		self.maxValue = max
		self:RefreshSeparators()
	else
		self.maxValue = max
	end
end

-----------------------------------------------------------
-- Set current value for ring
--
-- value - Value to set
-- fadeTime - Time to fade to set value
-- 				nil: default (logarithmic)
--				0: immediate
--				else: time in seconds (linear fade)
-- startFadeTime - Absolute time when fade should have started / is going to start
-- startValue - Start value to use if startFadeTime is set
-----------------------------------------------------------
function ArcHUDRingTemplate:SetValue(value, fadeTime, startFadeTime, startValue)
	if value == nil then value = 0 end
	if value > self.maxValue then
		value = self.maxValue
	end
	if value <= 0 then
		value = self.maxValue / 10000 -- "small", not 0
	end
	if (self.casting == 1) or (fadeTime == 0) then
		self.startValue = value
	end
	self.endValue = value
	
	if (fadeTime and fadeTime > 0) then
		self.maxFadeTime = fadeTime
	end
	
	if startFadeTime then
		self.fadeTime = GetTime() - startFadeTime
		if startValue then
			if self.fadeTime > 0 then
				-- compute start offset
				local diff = (self.endValue - startValue) / self.maxFadeTime * self.fadeTime
				self.startValue = startValue + diff
			else
				self.startValue = startValue
				self:SetAngle(self:GetAngle(startValue))
			end
		end
	else
		self.fadeTime = 0
	end
	
	if (fadeTime == 0) then
		self.fadeTime = self.maxFadeTime
		self:SetAngle(self:GetAngle(self.endValue))
	end
end

-----------------------------------------------------------
-- Set a texture or frame at a given angle on the ring
--   tex - texture or frame to reposition
--   angle - angle in degrees
--   offset - offset from center of the ring (e.g. width/2)
--   rotate - true if the texture should be rotated according to angle
--   squeeze - 'squeeze' texture inside the arc area
-----------------------------------------------------------
function ArcHUDRingTemplate:SetTextureAngle(tex, angle, offset, rotate, squeeze)
	local ringFactor = 0.9
	if angle <= 90 then
		ringFactor = 0.9 + ((90 - angle) / (90/0.1))
	elseif angle <= 180 then
		ringFactor = 0.9 + ((angle - 90) / (90/0.1))
	end
	local angleR = math.rad(angle)
	local R = self.radius
	
	local sin_a = math.sin(angleR)
	local cos_a = math.cos(angleR)
	local Ox = R * sin_a
	local Oy = R * cos_a * -1
	local Ix = Ox * ringFactor
	local Iy = Oy * ringFactor
	
	local Mx = (Ox + Ix)/2
	local My = (Oy + Iy)/2
	
	if squeeze then
		offset = offset * sin_a
	end
	
	tex:ClearAllPoints()
	if (self.reversed) then -- right side
		if (angle <= 90) then
			Mx = Mx - 2*cos_a -- small correction (not sure why this is necessary)
			--tex:SetPoint("TOPLEFT", self, "BOTTOMLEFT", Ix-offset, Iy+offset)
			--tex:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", Ox+offset, Oy-offset)
		else
			Mx = Mx + 2*cos_a -- small correction (not sure why this is necessary)
			--tex:SetPoint("TOPLEFT", self, "BOTTOMLEFT", Ix-offset, Oy+offset)
			--tex:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", Ox+offset, Iy-offset)
		end
		--ArcHUD:LevelDebug(1, "M(%f,%f)", Mx, My)
		tex:SetPoint("TOPLEFT", self, "BOTTOMLEFT", Mx-offset, My+offset)
		tex:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", Mx+offset, My-offset)
		if rotate then
			tex:SetRotation(angleR)
		end
	else -- left side
		if (angle <= 90) then
			Mx = Mx - 2*cos_a -- small correction (not sure why this is necessary)
			--tex:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -Ox-offset, Iy+offset)
			--tex:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -Ix+offset, Oy-offset)
		else
			Mx = Mx + 2*cos_a -- small correction (not sure why this is necessary)
			--tex:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -Ox-offset, Oy+offset)
			--tex:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -Ix+offset, Iy-offset)
		end
		--ArcHUD:LevelDebug(1, "M(%f,%f)", Mx, My)
		tex:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -Mx-offset, My+offset)
		tex:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -Mx+offset, My-offset)
		if rotate then
			tex:SetRotation(TWOPI - angleR)
		end
	end
end

-----------------------------------------------------------
-- Set position of spark (can be used as an indicator)
--   value - value on arc
--   red   - true: set red spark, false: set yellow spark
--   scale - scaling factor for size of spark
-----------------------------------------------------------
function ArcHUDRingTemplate:SetSpark(value, red, scale)
	local spark = self.spark
	if (red) then
		spark = self.sparkRed
	end
	
	if (value <= 0 or value >= self.maxValue) then
		spark:Hide()
		return
	end
	
	local angle = value / self.maxValue * (self.endAngle - self.startAngle) + self.startAngle
	local offset = 16
	if (scale) then
		offset = offset * scale
	end
	
	self:SetTextureAngle(spark, angle, offset, true)
	
	spark:Show()
end

-----------------------------------------------------------
-- Set angle of shine texture
-----------------------------------------------------------
function ArcHUDRingTemplate:SetShineAngle(angle, scale)
	-- Bounds checking on the angle so that it's between 0 and 180 (inclusive)
	if (angle < 0) then
		angle = 0
	end
	if (angle > 180) then
		angle = 180
	end
	
	local offset = 25
	if (scale) then
		offset = offset * scale
	end
	
	self:SetTextureAngle(self.shine, angle, offset)
end

-----------------------------------------------------------
-- Do shine (fade in and out)
-----------------------------------------------------------
function ArcHUDRingTemplate:DoShine()
	if self.shining then return end
	local fadeInfo = {
		mode = "IN",
		timeToFade = 0.5,
		finishedFunc = ArcHUDRingTemplate.ShineFadeOut,
		finishedArg1 = self,
	}
	self.shining = true
	UIFrameFade(self.shine, fadeInfo)
end

-----------------------------------------------------------
-- Handle end of fade in
-----------------------------------------------------------
function ArcHUDRingTemplate:ShineFadeOut()
	self.shining = false
	UIFrameFadeOut(self.shine, 0.5)
end

----------------------------------------------
-- Shows separators if needed
----------------------------------------------
function ArcHUDRingTemplate:RefreshSeparators()
	if (self.sep) then
		-- hide all
		for i,s in ipairs(self.sep) do
			s:Hide()
		end
	end
	
	if (self.showSeparators) then
		if (not self.sep) then
			self.sep = {}
		end
		if (self.maxValue > 1) and (self.maxValue <= 20) then
			local anglestep = (self.endAngle-self.startAngle)/self.maxValue
			local angle = self.startAngle + anglestep
			for i=1,(self.maxValue-1) do
				if (not self.sep[i]) then
					self.sep[i] = self:CreateTexture(nil, "OVERLAY")
					self.sep[i]:SetTexture("Interface\\Addons\\ArcHUD3\\Icons\\Separator")
					self.sep[i]:SetVertexColor(0, 0, 0)
				end
				self:SetTextureAngle(self.sep[i], angle, 12, true, true)
				self.sep[i]:Show()
				angle = angle + anglestep
			end
		end
	end
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
		if self.fadeTime < 0 then
			return -- do not start fading yet
		end
		if self.fadeTime > self.maxFadeTime then
			self.fadeTime = self.maxFadeTime
		end
		local delta = self.endValue - self.startValue
		local diff
		if self.linearFade then -- linear fade
			local dt = self.maxFadeTime - self.fadeTime
			if dt > 0 then
				diff = delta / dt * tdelta
			else
				diff = delta
			end
		else -- logarithmic fade
			diff = delta * self.fadeTime / self.maxFadeTime
		end
		self.startValue = self.startValue + diff
		self:SetAngle(self:GetAngle(self.startValue))
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
	-- cut decimals
	destAlpha = math.floor(destAlpha*100 + 0.5)/100

	if (instant or not self.applyAlpha) then
		self:SetAlpha(destAlpha)
		self.destAlpha = destAlpha
		return
		
	elseif (self.destAlpha ~= destAlpha) then
		--ArcHUD:LevelDebug(1, "ArcHUDRingTemplate:SetRingAlpha("..tostring(destAlpha).."), current "..tostring(self.destAlpha)..", name "..tostring(self:GetName()))
		self.destAlpha = destAlpha
		if (self.applyAlpha:IsPlaying()) then
			self.applyAlpha:Stop()
		end
		self.applyAlpha.alphaAnim:SetFromAlpha(self:GetAlpha())
		self.applyAlpha.alphaAnim:SetToAlpha(destAlpha)
		self.applyAlpha:Play()
	end
end

-----------------------------------------------------------
-- Pulsing if necessary
-----------------------------------------------------------
function ArcHUDRingTemplate:applyAlpha_OnFinished()
	local curAlpha = math.floor(self:GetAlpha()*100 + 0.5)/100
	if (self.pulse) then
		--self.module:Debug(1, "%s:applyAlpha pulsing", self.module:GetName())
		local pulseMax = 1.0
		local pulseMin = 0.25
		if (curAlpha < pulseMax) then
			self.applyAlpha.alphaAnim:SetFromAlpha(self:GetAlpha())
			self.applyAlpha.alphaAnim:SetToAlpha(pulseMax)
		else
			self.applyAlpha.alphaAnim:SetFromAlpha(self:GetAlpha())
			self.applyAlpha.alphaAnim:SetToAlpha(pulseMin)
		end
		self.applyAlpha:Play()
	else
		--ArcHUD:LevelDebug(1, "curAlpha "..curAlpha..", destAlpha "..self.destAlpha)
		if (curAlpha ~= self.destAlpha) then
			self.applyAlpha.alphaAnim:SetFromAlpha(self:GetAlpha())
			self.applyAlpha.alphaAnim:SetToAlpha(self.destAlpha)
			self.applyAlpha:Play()
		else
			self:SetAlpha(self.destAlpha)
			if (self.destAlpha == 0 and self.fillUpdate:IsPlaying()) then
				self.fillUpdate:Stop();
			end
		end
	end
end

-----------------------------------------------------------
-- Start pulsing of ring
-----------------------------------------------------------
function ArcHUDRingTemplate:StartPulse()
	self.pulse = true
	if (not self.applyAlpha:IsPlaying()) then
		--self.module:Debug(1, "StartPulse()")
		local pulseMax = 1.0
		local pulseMin = 0.25
		local curAlpha = math.floor(self:GetAlpha()*100 + 0.5)/100
		if (curAlpha < pulseMax) then
			self.applyAlpha.alphaAnim:SetFromAlpha(self:GetAlpha())
			self.applyAlpha.alphaAnim:SetToAlpha(pulseMax)
		else
			self.applyAlpha.alphaAnim:SetFromAlpha(self:GetAlpha())
			self.applyAlpha.alphaAnim:SetToAlpha(pulseMin)
		end
		self.applyAlpha:Play()
	end
end

-----------------------------------------------------------
-- Stop pulsing of ring
-----------------------------------------------------------
function ArcHUDRingTemplate:StopPulse()
	self.pulse = false
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
			fh.f.syncPulse:Play()
		end

		-- Prepare mana ring
		if(fm and unit == "player" and not fm.f.pulse) then
			fm.f:UpdateColor(color)
			fm.f:SetMax(1)
			fm.f:SetValue(1)
			fm.MPText:SetText("")
			fm.MPPerc:SetText("")
			-- Enable pulsing
			fm.f.syncPulse:Play()
		end
	else
		if(fh and fh.f.syncPulse:IsPlaying()) then
			fh.f.syncPulse:Stop()
			fh.f:SetMax(UnitHealthMax(unit))
			fh.f:SetValue(UnitHealth(unit))
		end
		if(fm and fm.f.syncPulse:IsPlaying()) then
			fm.f.syncPulse:Stop()
			fm.f:SetMax(UnitPowerMax(unit))
			fm.f:SetValue(UnitPower(unit))
			fm.f:UpdateColor(PowerBarColor[UnitPowerType(unit)])
		end
	end
end

-----------------------------------------------------------
-- Event handler for unit events
-----------------------------------------------------------
function ArcHUDRingTemplate:OnEvent(event, ...)
	if (self.unitEvents) then
		local ue = self.unitEvents[event]
		if (ue) then
			ue.module[ue.cb](ue.module, event, ...)
		end
	end
end

-- The OnLoad method, call self for each template object to set it up and
-- get things going
function ArcHUDRingTemplate:OnLoad(frame)
	frame.quadrants = {}
	frame.quadrants[1] = frame.ringQuadrant1
	frame.quadrants[2] = frame.ringQuadrant2

	-- Initialize size and default texture ringFactor
	frame.radius = (frame:GetWidth() * 0.5)
	frame.ringFactor = 0.94

	-- Add ring methods
	frame.DoQuadrant				= self.DoQuadrant
	frame.DoQuadrantReversed		= self.DoQuadrantReversed
	frame.SetAngle          		= self.SetAngle
	frame.SetStartAngle          	= self.SetStartAngle
	frame.SetEndAngle	          	= self.SetEndAngle
	frame.MoveBaseAngle	          	= self.MoveBaseAngle
	frame.CallTextureMethod 		= self.CallTextureMethod
	frame.SetRingTextures   		= self.SetRingTextures
	frame.SetMax					= self.SetMax
	frame.SetValue					= self.SetValue
	frame.Update					= self.Update
	frame.UpdateColor				= self.UpdateColor
	frame.SetReversed				= self.SetReversed
	frame.SetRingAlpha				= self.SetRingAlpha
	frame.GhostMode					= self.GhostMode
	frame.StartPulse				= self.StartPulse
	frame.StopPulse					= self.StopPulse
	frame.applyAlpha_OnFinished		= self.applyAlpha_OnFinished
	frame.SetSpark					= self.SetSpark
	frame.OnEvent					= self.OnEvent
	frame.SetShineAngle				= self.SetShineAngle
	frame.DoShine					= self.DoShine
	frame.ShineFadeOut				= self.ShineFadeOut
	frame.GetAngle					= self.GetAngle
	frame.SetTextureAngle			= self.SetTextureAngle
	frame.RefreshSeparators			= self.RefreshSeparators

	frame.startValue = 0
	frame.endValue = 0
	frame.maxValue = 1
	frame.fadeTime = 0
	frame.maxFadeTime = 1
	frame.alphaState = -1
	frame.pulse = false
	frame.alphaPulse = 0
	
	frame:SetScript("OnEvent", frame.OnEvent)
	
	-- Animation groups
	frame.fillUpdate = frame.fillUpdateFrame.fillUpdate

	-- Hide the chip and slice textures, and de-anchor them
	frame.chip1:Hide()
	frame.chip1:ClearAllPoints()
	frame.chip2:Hide()
	frame.chip2:ClearAllPoints()
	frame.slice1:Hide()
	frame.slice1:ClearAllPoints()
	frame.slice2:Hide()
	frame.slice2:ClearAllPoints()
	
	-- Set angle to zero (initializes texture visibility)
	frame:SetStartAngle(0)
	frame:SetEndAngle(180)
	frame:SetAngle(0)
	frame:SetSpark(-1)
	frame:SetSpark(-1, true)
end

function ArcHUDRingTemplate:OnLoadBG(frame)
	frame.quadrants = {}
	frame.quadrants[1] = frame.ringQuadrant1
	frame.quadrants[2] = frame.ringQuadrant2

	-- Initialize size and default texture ringFactor
	frame.radius = (frame:GetWidth() * 0.5)
	frame.ringFactor = 0.94

	-- Add ring methods
	frame.DoQuadrant				= self.DoQuadrant
	frame.DoQuadrantReversed		= self.DoQuadrantReversed
	frame.SetAngle          		= self.SetAngle
	frame.SetStartAngle          	= self.SetStartAngle
	frame.SetEndAngle         	 	= self.SetEndAngle
	frame.CallTextureMethod 		= self.CallTextureMethod
	frame.UpdateColor				= self.UpdateColor
	frame.SetReversed				= self.SetReversed

	-- Hide the chip and slice textures, and de-anchor them
	frame.chip1:Hide()
	frame.chip1:ClearAllPoints()
	frame.chip2:Hide()
	frame.chip2:ClearAllPoints()
	frame.slice1:Hide()
	frame.slice1:ClearAllPoints()
	frame.slice2:Hide()
	frame.slice2:ClearAllPoints()
	
	-- Set angle to 180 degrees (initializes texture visibility)
	frame:SetStartAngle(0)
	frame:SetEndAngle(180)
	frame:SetAngle(180)

	-- Set color
	frame:UpdateColor({r = 0, g = 0, b = 0})
end
