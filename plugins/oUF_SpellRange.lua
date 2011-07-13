--[[****************************************************************************
  * oUF_SpellRange by Saiket                                                   *
  * oUF_SpellRange.lua - Improved range element for oUF.                       *
  *                                                                            *
  * Elements handled: .SpellRange                                              *
  * Settings: (Either Update method or both alpha properties are required)     *
  *   - .SpellRange.Update( Frame, InRange ) - Callback fired when a unit      *
  *       either enters or leaves range. Overrides default alpha changing.     *
  *   OR                                                                       *
  *   - .SpellRange.insideAlpha - Frame alpha value for units in range.        *
  *   - .SpellRange.outsideAlpha - Frame alpha for units out of range.         *
  * Note that SpellRange will automatically disable Range elements of frames.  *
  ****************************************************************************]]

local _, ns = ...
local oUF = ns.oUF or oUF

local UpdateRate = 0.5

local UpdateFrame
local Objects = {}

local HelpID, HelpName
local HarmID, HarmName

local IsInRange
do
	local UnitIsConnected = UnitIsConnected
	local UnitCanAssist = UnitCanAssist
	local UnitCanAttack = UnitCanAttack
	local UnitIsUnit = UnitIsUnit
	local UnitPlayerOrPetInRaid = UnitPlayerOrPetInRaid
	local UnitIsDead = UnitIsDead
	local UnitOnTaxi = UnitOnTaxi
	local UnitInRange = UnitInRange
	local IsSpellInRange = IsSpellInRange
	local CheckInteractDistance = CheckInteractDistance
	function IsInRange ( UnitID )
		if ( UnitIsConnected( UnitID ) ) then
			if ( UnitCanAssist( "player", UnitID ) ) then
				if ( HelpName and not UnitIsDead( UnitID ) ) then
					return IsSpellInRange( HelpName, UnitID ) == 1
				elseif ( not UnitOnTaxi( "player" ) -- UnitInRange always returns nil while on flightpaths
					and ( UnitIsUnit( UnitID, "player" ) or UnitIsUnit( UnitID, "pet" )
						or UnitPlayerOrPetInParty( UnitID ) or UnitPlayerOrPetInRaid( UnitID ) )
				) then
					return UnitInRange( UnitID ) -- Fast checking for self and party members (38 yd range)
				end
			elseif ( HarmName and not UnitIsDead( UnitID ) and UnitCanAttack( "player", UnitID ) ) then
				return IsSpellInRange( HarmName, UnitID ) == 1
			end

			-- Fallback when spell not found or class uses none
			return CheckInteractDistance( UnitID, 4 ) -- Follow distance (28 yd range)
		end
	end
end

function UpdateRange ( self )
    local isInRange = not not IsInRange( self.unit )
    if(self.isInRange == isInRange) then return end

    self.isInRange = isInRange
    if(isInRange) then
        self:SetAlpha(self.inRangeAlpha or 1)
    else
        self:SetAlpha(self.outsideRangeAlpha or .25)
    end
end

local OnUpdate = function(self, elapsed)
    self.nextUpdate = self.nextUpdate - elapsed
    if(self.nextUpdate > 0) then return end
    self.nextUpdate = UpdateRate

    if(not HarmName and HarmID) then
        if(IsSpellKnown(HarmID)) then
            HarmName = GetSpellInfo(HarmID)
        end
    end
    if(not HelpName and HelpID) then
        if(IsSpellKnown(HelpID)) then
            HelpName = GetSpellInfo(HelpName)
        end
    end

    for obj in next, Objects do
        UpdateRange(obj)
    end
end

local Enable = function(self)
    if(not self.Range) then return end

    if(not UpdateFrame) then
        UpdateFrame = CreateFrame'Frame'
        UpdateFrame.nextUpdate = 1
        UpdateFrame:SetScript('OnUpdate', OnUpdate)
        UpdateFrame:Show()
    end

    Objects[self] = true

    return true
end

local function Update (self, event, unit)
	if ( event ~= 'OnTargetUpdate' ) then
		UpdateRange(self)
	end
end

do
    local class = select(2, UnitClass'player')
    HelpID = ({
        DRUID = 5185, -- Healing Touch
        MAGE = 1459, -- Arcane Intellect
        PALADIN = 635, -- Holy Light
        PRIEST = 2050, -- Lesser Heal
        SHAMAN = 331, -- Healing Wave
        WARLOCK = 5697, -- Unending Breath
    } )[ class ]
    HarmID = ( {
        DEATHKNIGHT = 52375, -- Death Coil
        DRUID = 5176, -- Wrath
        HUNTER = 75, -- Auto Shot
        MAGE = 133, -- Fireball
        PALADIN = 62124, -- Hand of Reckoning
        PRIEST = 585, -- Smite
        SHAMAN = 403, -- Lightning Bolt
        WARLOCK = 686, -- Shadow Bolt
        WARRIOR = 355, -- Taunt
    } )[ class ]
end

oUF:AddElement('SpellRange', Update, Enable, nil)

