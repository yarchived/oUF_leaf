
local _, ns = ...
local oUF = ns.oUF or oUF

local function Fade(self, unit)
    if(not UnitIsConnected(unit)) then
        return true
    end

    if InCombatLockdown() or
       UnitCastingInfo(unit) or
       UnitChannelInfo(unit) or
       UnitIsDeadOrGhost(unit) or
       UnitExists(unit..'target') then
        return false
    end

--    if( unit == 'pet') then
--        local happiness = GetPetHappiness()
--        if(happiness and happiness ~= 3) then
--            return false
--        end
--    end

    if(UnitHealth(unit)~=UnitHealthMax(unit)) then
        return false
    end

    do
        local min, max = UnitPower(unit), UnitPowerMax(unit)
        if(UnitPowerType(unit) == 1) then -- rage
            if(min > 0) then
                return false
            end
        else
            if(min ~= max) then
                return false
            end
        end
    end

    return true
end

local function Update(self, event, unit)
	if(unit ~= self.unit) then return end

    if(Fade(self, unit)) then
        if(not self.BarFaded) then
            self:SetAlpha(self.BarFaderAlpha or .4)
            self.BarFaded = true
        end
    else
        if(self.BarFaded) then
            self:SetAlpha(1)
            self.BarFaded = false
        end
    end
end

local events = {
    'UNIT_CONNECTION',
    'UNIT_COMBAT',
    'UNIT_TARGET',
    'UNIT_POWER',
    'UNIT_MAXPOWER',
    'UNIT_HEALTH',
    'UNIT_MAXHEALTH',
    'UNIT_SPELLCAST_START',
    'UNIT_SPELLCAST_FAILED',
    'UNIT_SPELLCAST_STOP',
    'UNIT_SPELLCAST_INTERRUPTED',
    'UNIT_SPELLCAST_INTERRUPTIBLE',
    'UNIT_SPELLCAST_NOT_INTERRUPTIBLE',
    'UNIT_SPELLCAST_DELAYED',
    'UNIT_SPELLCAST_CHANNEL_START',
    'UNIT_SPELLCAST_CHANNEL_UPDATE',
    'UNIT_SPELLCAST_CHANNEL_STOP',
}

local function Enable(self, unit)
	if(unit and self.BarFader) then
        for k, v in ipairs(events) do
            self:RegisterEvent(v, Update)
        end

		return true
    end
end

local function Disable(self)
	if(self.BarFader) then
        for k, v in ipairs(events) do
            self:UnregisterEvent(v, Update)
        end
	end
end

oUF:AddElement('BarFader', Update, Enable, Disable)

