function ArcHUD:SplitString(s,p,n)
	local l,sp,ep = {},0
	while(sp) do
		sp,ep=strfind(s,p)
		if(sp) then
			tinsert(l,strsub(s,1,sp-1))
			s=strsub(s,ep+1)
		else
			tinsert(l,s)
			break
		end
		if(n) then n=n-1 end
		if(n and (n==0)) then tinsert(l,s) break end
	end
	return unpack(l)
end

function ArcHUD:strcap(str)
   return strupper(strsub(str, 1, 1)) .. strlower(strsub(str, 2))
end

-- Friendly/formatted int
function ArcHUD:fint(i)
	-- Use AbbreviateNumbers if available (works with both secret and non-secret values in 12.0+)
	if ArcHUD.isMidnight and AbbreviateNumbers and CreateAbbreviateConfig then
		-- Cache abbrevData so it's not recreated every time
		if not self.abbrevData then
			self.abbrevData = {
				breakpointData = {
				   {
					  breakpoint = 1e12,
					  abbreviation = "B", 
					  significandDivisor = 1e10,
					  fractionDivisor = 100,
					  abbreviationIsGlobal = false,
				   },
				   {
					  breakpoint = 1e11,
					  abbreviation = "B", 
					  significandDivisor = 1e9,
					  fractionDivisor = 1,
					  abbreviationIsGlobal = false,
				   },
				   {
					  breakpoint = 1e10,
					  abbreviation = "B", 
					  significandDivisor = 1e8,
					  fractionDivisor = 10,
					  abbreviationIsGlobal = false,
				   },
				   {
					  breakpoint = 1e9,
					  abbreviation = "B", 
					  significandDivisor = 1e7,
					  fractionDivisor = 100,
					  abbreviationIsGlobal = false,
				   },
				   {
					  breakpoint = 1e8,
					  abbreviation = "M", 
					  significandDivisor = 1e6,
					  fractionDivisor = 1,
					  abbreviationIsGlobal = false,
				   },
				   {
					  breakpoint = 1e7,
					  abbreviation = "M", 
					  significandDivisor = 1e5,
					  fractionDivisor = 10,
				  abbreviationIsGlobal = false,
				   },
				   {
					  breakpoint = 1e6,
					  abbreviation = "M", 
					  significandDivisor = 1e4,
					  fractionDivisor = 100,
					  abbreviationIsGlobal = false,
				   },
				   {
					  breakpoint = 1e5,
					  abbreviation = "k",
					  significandDivisor = 1000,
					  fractionDivisor = 1,
					  abbreviationIsGlobal = false,
				   },
				   {
					  breakpoint = 1e4,
					  abbreviation = "k",
					  significandDivisor = 100,
					  fractionDivisor = 10,
					  abbreviationIsGlobal = false,
				   },
				},
			 }
		end
		local success, result = pcall(function() 
			return AbbreviateNumbers(i, self.abbrevData)
		end)
		if success and result then
			return result
		end
	end
	
	-- For secret values, if AbbreviateNumbers failed or isn't available, use tostring
	if ArcHUD.isMidnight and issecretvalue and issecretvalue(i) then
		return tostring(i)
	end
	
	-- For non-secret numbers, use manual formatting as fallback
	if (type(i) == "number") then 
		if (i >= 1000000) then
			return string.format("%.1fM", i/1000000)
		elseif (i >= 100000) then
			return string.format("%.1fk", i/1000)
		else
			return tostring(i)
		end
	else
		return tostring(i or "")
	end
end

----------------------------------------------
-- 12.0.0+ (Midnight) Secret Value Protection
----------------------------------------------

-- Check if a value is secret (12.0.0+)
function ArcHUD:IsSecretValue(value)
	if not ArcHUD.isMidnight then return false end
	return issecretvalue and issecretvalue(value)
end

-- Safely check if we can do operations on a value
function ArcHUD:CanAccessValue(value)
	if not ArcHUD.isMidnight then return true end
	return not self:IsSecretValue(value)
end

-- Get health percentage using UnitHealthPercent API (0-1.0 range)
-- Returns usable percentage even with secret values
function ArcHUD:GetHealthPercent(unit, usePredicted)
	if ArcHUD.isMidnight and UnitHealthPercent then
		-- UnitHealthPercent returns 0-1.0 range directly
		local pct = UnitHealthPercent(unit, usePredicted or false)
		-- If result is still secret, we can't use it - try fallback
		if pct and not self:IsSecretValue(pct) and type(pct) == "number" then
			return pct
		end
	end
	-- Fallback: manual calculation (only if values are not secret)
	local health = UnitHealth(unit)
	local maxHealth = UnitHealthMax(unit)
	if not self:IsSecretValue(health) and not self:IsSecretValue(maxHealth) and 
	   type(health) == "number" and type(maxHealth) == "number" then
		if maxHealth and maxHealth > 0 then
			return health / maxHealth
		end
	end
	return 1.0 -- Default to 100% if we can't calculate
end

-- Get power percentage using UnitPowerPercent API (0-1.0 range)
function ArcHUD:GetPowerPercent(unit, powerType)
	if ArcHUD.isMidnight and UnitPowerPercent then
		local pct = UnitPowerPercent(unit, powerType)
		if pct and not self:IsSecretValue(pct) and type(pct) == "number" then
			return pct
		end
	end
	-- Fallback: manual calculation
	local power = UnitPower(unit, powerType)
	local maxPower = UnitPowerMax(unit, powerType)
	if not self:IsSecretValue(power) and not self:IsSecretValue(maxPower) and
	   type(power) == "number" and type(maxPower) == "number" then
		if maxPower and maxPower > 0 then
			return power / maxPower
		end
	end
	return 1.0
end

-- Format health percentage for display (handles secret values)
-- Returns string like "50%" or formatted secret value
-- Uses CurveConstants.ScaleTo100 to get 0-100 range directly
function ArcHUD:FormatHealthPercent(unit, usePredicted)
	if ArcHUD.isMidnight and UnitHealthPercent and C_CurveUtil then
		-- Try to use ScaleTo100 curve if available (from Blizzard_SharedXMLBase)
		local scaleTo100Curve = nil
		if CurveConstants and CurveConstants.ScaleTo100 then
			scaleTo100Curve = CurveConstants.ScaleTo100
		else
			-- Create our own ScaleTo100 curve if not available
			if not self.scaleTo100Curve then
				local curveType = Enum.LuaCurveType or Enum.CurveType
				if curveType then
					self.scaleTo100Curve = C_CurveUtil.CreateCurve(curveType.Linear)
					if self.scaleTo100Curve then
						self.scaleTo100Curve:AddPoint(0.0, 0)
						self.scaleTo100Curve:AddPoint(1.0, 100)
					end
				end
			end
			scaleTo100Curve = self.scaleTo100Curve
		end
		
		-- Use ScaleTo100 curve to get 0-100 range directly
		local pct = UnitHealthPercent(unit, usePredicted or true, scaleTo100Curve)
		-- If secret, format with string.format to limit to whole numbers
		if self:IsSecretValue(pct) then
			-- Secret value - use string.format to format as whole number
			-- Note: string.format may work with secret values in some contexts
			return string.format("%.0f%%", pct)
		elseif type(pct) == "number" then
			-- ScaleTo100 curve returns 0-100 range, format as whole number
			return string.format("%.0f%%", pct)
		end
	end
	-- Fallback: use 0-1 range and multiply
	local pct = self:GetHealthPercent(unit, usePredicted)
	if pct and not self:IsSecretValue(pct) and type(pct) == "number" then
		return string.format("%.0f%%", pct * 100)
	end
	return "100%"
end

-- Format power percentage for display (handles secret values)
-- Returns string like "50%" or formatted secret value
-- Uses CurveConstants.ScaleTo100 to get 0-100 range directly
function ArcHUD:FormatPowerPercent(unit, powerType)
	if ArcHUD.isMidnight and UnitPowerPercent and C_CurveUtil then
		-- Try to use ScaleTo100 curve if available (from Blizzard_SharedXMLBase)
		local scaleTo100Curve = nil
		if CurveConstants and CurveConstants.ScaleTo100 then
			scaleTo100Curve = CurveConstants.ScaleTo100
		else
			-- Create our own ScaleTo100 curve if not available
			if not self.scaleTo100Curve then
				local curveType = Enum.LuaCurveType or Enum.CurveType
				if curveType then
					self.scaleTo100Curve = C_CurveUtil.CreateCurve(curveType.Linear)
					if self.scaleTo100Curve then
						self.scaleTo100Curve:AddPoint(0.0, 0)
						self.scaleTo100Curve:AddPoint(1.0, 100)
					end
				end
			end
			scaleTo100Curve = self.scaleTo100Curve
		end
		
		-- Use ScaleTo100 curve to get 0-100 range directly (same as health)
		local pct = UnitPowerPercent(unit, powerType, false, scaleTo100Curve)
		-- If secret, format with string.format to limit to whole numbers
		if self:IsSecretValue(pct) then
			-- Secret value - use string.format to format as whole number
			return string.format("%.0f%%", pct)
		elseif type(pct) == "number" then
			-- ScaleTo100 curve returns 0-100 range, format as whole number (same as health)
			return string.format("%.0f%%", pct)
		end
	end
	-- Fallback: use 0-1 range and multiply
	local pct = self:GetPowerPercent(unit, powerType)
	if pct and not self:IsSecretValue(pct) and type(pct) == "number" then
		return string.format("%.0f%%", pct * 100)
	end
	return "100%"
end

-- Format health text (current/max) - handles secret values
function ArcHUD:FormatHealthText(unit)
	local health = UnitHealth(unit)
	local maxHealth = UnitHealthMax(unit)
	
	-- Always use fint for both values - it handles secret values with AbbreviateNumbers
	local healthStr = self:fint(health)
	local maxHealthStr = self:fint(maxHealth)
	return healthStr .. "/" .. maxHealthStr
end

-- Format power text (current/max) - handles secret values
function ArcHUD:FormatPowerText(unit, powerType)
	local power = UnitPower(unit, powerType)
	local maxPower = UnitPowerMax(unit, powerType)
	
	-- Always use fint for both values - it handles secret values with AbbreviateNumbers
	local powerStr = self:fint(power)
	local maxPowerStr = self:fint(maxPower)
	return powerStr .. "/" .. maxPowerStr
end

-- Get health color using ColorCurveObject (12.0.0+)
-- Returns r, g, b, a values
-- Get health color - returns ColorMixin object in Midnight, or r, g, b, a in legacy
-- In Midnight, ColorMixin can contain secret values that must be used directly
function ArcHUD:GetHealthColorFromUnit(unit)
	if ArcHUD.isMidnight and C_CurveUtil and UnitHealthPercent and CreateColor then
		-- Try to create color curve if not already cached
		if not self.healthColorCurve then
			local curveType = Enum.LuaCurveType or Enum.CurveType
			if curveType then
				-- Create ColorCurveObject using proper API
				-- Create smooth gradient matching pre-Midnight behavior:
				-- Red (0%) -> Orange (25%) -> Yellow (50%) -> Yellow-Green (75%) -> Green (100%)
				self.healthColorCurve = C_CurveUtil.CreateColorCurve()
				if self.healthColorCurve then
					self.healthColorCurve:SetType(curveType.Linear)
					self.healthColorCurve:AddPoint(0.0, CreateColor(1, 0, 0))      -- Red at 0%
					self.healthColorCurve:AddPoint(0.25, CreateColor(1, 0.5, 0))   -- Orange at 25%
					self.healthColorCurve:AddPoint(0.5, CreateColor(1, 1, 0))      -- Yellow at 50%
					self.healthColorCurve:AddPoint(0.75, CreateColor(0.5, 1, 0))  -- Yellow-Green at 75%
					self.healthColorCurve:AddPoint(1.0, CreateColor(0, 1, 0))    -- Green at 100%
				end
			end
		end
		if self.healthColorCurve then
			-- UnitHealthPercent with ColorCurveObject returns a ColorMixin object
			-- Use usePredicted=true to get immediate color updates
			-- ColorMixin may contain secret values - return it directly for use in APIs
			local color = UnitHealthPercent(unit, true, self.healthColorCurve)
			if color and type(color) == "table" and color.GetRGB then
				-- Return ColorMixin object directly - can contain secret values
				return color
			end
		end
	end
	-- Fallback: calculate from percentage (for classic versions)
	-- Create a ColorMixin object from RGB values for consistency
	local pct = self:GetHealthPercent(unit)
	if not self:IsSecretValue(pct) and type(pct) == "number" then
		local r, g = 1, 1
		if pct > 0.5 then
			r = (1.0 - pct) * 2
			g = 1.0
		else
			r = 1.0
			g = pct * 2
		end
		if r < 0 then r = 0 elseif r > 1 then r = 1 end
		if g < 0 then g = 0 elseif g > 1 then g = 1 end
		-- Create ColorMixin from RGB values for legacy mode
		if CreateColor then
			return CreateColor(r, g, 0)
		else
			-- Fallback: return as table with GetRGB method for compatibility
			return {GetRGB = function() return r, g, 0 end}
		end
	end
	-- Default: yellow
	if CreateColor then
		return CreateColor(1, 1, 0)
	else
		return {GetRGB = function() return 1, 1, 0 end}
	end
end

----------------------------------------------
-- StatusBar Arc System (12.0.0+)
----------------------------------------------

-- Create a StatusBar-based arc for a ring frame
-- parent: The ring frame to attach to
-- maskTexture: Path to mask texture (optional, defaults to arc_outline.png)
-- moduleName: Optional module name to determine side (defaults to checking parent.module)
-- Returns: StatusBar frame
function ArcHUD:CreateStatusBarArc(parent, maskTexture, moduleName)
	if not ArcHUD.isMidnight then return nil end
	
	-- Determine side: health modules are left (Side=1), power modules are right (Side=2)
	local side = 1 -- default to left
	if moduleName then
		-- Check module name for "Power" to determine right side
		if string.find(moduleName, "Power") then
			side = 2
		end
	elseif parent.module and parent.module.db and parent.module.db.profile then
		-- Try to get side from module
		side = parent.module.db.profile.Side or 1
	elseif parent.module and parent.module.name then
		-- Check module name
		if string.find(parent.module.name, "Power") then
			side = 2
		end
	end
	
	local sb = CreateFrame("StatusBar", nil, parent)
	sb:ClearAllPoints()
	-- Match the parent ring frame exactly
	-- StatusBar should inherit parent's size, position, and scale
	sb:SetAllPoints(parent)
	
	-- Use the original ArcHUD arc texture directly
	local texturePath = "Interface\\AddOns\\ArcHUD3\\Icons\\RingFullLeft.png"
	if side == 2 then
		texturePath = "Interface\\AddOns\\ArcHUD3\\Icons\\RingFullRight.png"
	end

	sb:SetStatusBarTexture(texturePath)
	sb:SetMinMaxValues(0, 1)
	sb:SetValue(0)
	sb:SetOrientation("VERTICAL")

	-- StatusBar inherits parent's scale automatically via SetAllPoints
	-- Don't set scale manually to avoid double-scaling

	-- Set frame level to be above background but below text
	sb:SetFrameLevel(parent:GetFrameLevel() + 1)

	-- Store reference to parent ring for alpha syncing
	sb.parentRing = parent
	
	sb:Hide()
	return sb
end

-- Update StatusBar arc value from unit health
-- Can accept secret values directly for SetValue
function ArcHUD:UpdateStatusBarArcHealth(sb, unit)
	if not ArcHUD.isMidnight or not sb then return end
	-- Try to get percentage - can be secret value
	local pct
	if UnitHealthPercent then
		pct = UnitHealthPercent(unit)
	else
		pct = self:GetHealthPercent(unit)
	end
	-- SetValue can handle secret values directly
	sb:SetValue(pct)
	sb:Show()
end

-- Update StatusBar arc value from unit power
-- Can accept secret values directly for SetValue
function ArcHUD:UpdateStatusBarArcPower(sb, unit, powerType)
	if not ArcHUD.isMidnight or not sb then return end
	-- Try to get percentage - can be secret value
	local pct
	if UnitPowerPercent then
		pct = UnitPowerPercent(unit, powerType)
	else
		pct = self:GetPowerPercent(unit, powerType)
	end
	-- SetValue can handle secret values directly
	sb:SetValue(pct)
	sb:Show()
end

-- Set StatusBar arc color
-- Accepts either a ColorMixin object (Midnight) or r, g, b, a values (legacy)
-- ColorMixin may contain secret values that must be used directly
function ArcHUD:SetStatusBarArcColor(sb, colorOrR, g, b, a)
	if not ArcHUD.isMidnight or not sb then return end
	
	-- Check if first argument is a ColorMixin object (has GetRGB method)
	if colorOrR and type(colorOrR) == "table" and colorOrR.GetRGB then
		-- ColorMixin object - use GetRGB() directly in SetVertexColor
		-- GetRGB() may return secret values, but SetVertexColor can handle them
		local statusBarTexture = sb:GetStatusBarTexture()
		if statusBarTexture then
			statusBarTexture:SetVertexColor(colorOrR:GetRGB())
		end
	else
		-- Legacy mode: r, g, b, a values (for non-Midnight or fallback)
		local safeR = colorOrR or 1
		local safeG = g or 1
		local safeB = b or 0
		local safeA = a or 1
		
		-- Protect against secret values
		if self:IsSecretValue(safeR) then safeR = 1 end
		if self:IsSecretValue(safeG) then safeG = 1 end
		if self:IsSecretValue(safeB) then safeB = 0 end
		if self:IsSecretValue(safeA) then safeA = 1 end
		
		-- Ensure values are in valid range
		if type(safeR) == "number" then safeR = math.max(0, math.min(1, safeR)) else safeR = 1 end
		if type(safeG) == "number" then safeG = math.max(0, math.min(1, safeG)) else safeG = 1 end
		if type(safeB) == "number" then safeB = math.max(0, math.min(1, safeB)) else safeB = 0 end
		if type(safeA) == "number" then safeA = math.max(0, math.min(1, safeA)) else safeA = 1 end
		
		-- SetStatusBarColor takes separate r, g, b, a arguments
		sb:SetStatusBarColor(safeR, safeG, safeB, safeA)
	end
end
