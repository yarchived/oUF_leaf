
local _, ns = ...
local oUF = ns.oUF or oUF
local leaf = ns.leaf

local Hex = leaf.Hex
local utf8sub = leaf.utf8sub
local truncate = leaf.truncate
local colors = leaf.colors


oUF.Tags.Methods['leaf:difficulty']  = function(u) local l = UnitLevel(u); return Hex(GetQuestDifficultyColor((l > 0) and l or 99)) end

oUF.Tags.Methods['leaf:curhp'] = function(u) return truncate(UnitHealth(u)) end
oUF.Tags.Events['leaf:curhp'] = 'UNIT_HEALTH'

oUF.Tags.Methods['leaf:curpp'] = function(u) return truncate(UnitPower(u)) end
oUF.Tags.Events['leaf:curpp'] = 'UNIT_POWER'

oUF.Tags.Methods['leaf:maxhp'] = function(u) return truncate(UnitHealthMax(u)) end
oUF.Tags.Events['leaf:maxhp'] = 'UNIT_MAXHEALTH'

oUF.Tags.Methods['leaf:maxpp'] = function(u) return truncate(UnitPowerMax(u)) end
oUF.Tags.Events['leaf:maxpp'] = 'UNIT_MAXPOWER'

do
    local CC = setmetatable({}, {__index = function(t, i)
        local c = i and colors.class[i]
        t[i] = c and Hex(c)
        return t[i]
    end})
    oUF.Tags.Methods['leaf:raidcolor'] = function(u) local _, x = UnitClass(u); return CC[x or 'WARRIOR'] end
end

oUF.Tags.Methods['leaf:detail'] = function(u)
    if UnitIsPlayer(u) then
        return ('%s%s|r %s'):format(oUF.Tags.Methods['[leaf:raidcolor]'](u), UnitClass(u), UnitRace(u))
    else
        return UnitCreatureFamily(u) or UnitCreatureType(u)
    end
end

oUF.Tags.Methods['leaf:perhp'] = function(u)
    local m = UnitHealthMax(u)
    return m == 0 and 0 or floor(UnitHealth(u)/m*100+0.5)
end
oUF.Tags.Events['leaf:perhp'] = 'UNIT_HEALTH UNIT_MAXHEALTH'

oUF.Tags.Methods['leaf:perpp'] = function(u)
    local c, m = UnitPower(u), UnitPowerMax(u)
    return m == 0 and 0 or floor(c/m*100+0.5)
end
oUF.Tags.Events['leaf:perpp'] = 'UNIT_POWER UNIT_MAXPOWER'

oUF.Tags.Methods['leaf:smartpp'] = function(u)
    if (UnitPowerType(u) == SPELL_POWER_MANA) then
        oUF.Tags.Methods['leaf:perpp'](u)
    else
        return UnitPower(u)
    end
end
oUF.Tags.Events['leaf:smartpp'] = 'UNIT_POWER UNIT_MAXPOWER'

oUF.Tags.Methods['leaf:name'] = function(u, r)
    local name, realm = UnitName(r or u)
    if realm and (realm~='') then name = name .. '-' .. realm end
    return name
end
oUF.Tags.Events['leaf:name'] = 'UNIT_NAME_UPDATE'

local color_power = {}
for k, v in pairs(colors.power) do
    color_power[k] = Hex(v)
end
oUF.Tags.Methods['leaf:colorpower'] = function(u)
    -- local n,s = UnitPowerType(u) return color_power[s]
    return color_power[UnitPowerType(u)]
end

oUF.Tags.Methods['leaf:smartlevel'] = function(u)
    local c = UnitClassification(u)
    if(c == 'worldboss') then
        return '++'
    else
        local l  = UnitLevel(u)
        if(c == 'elite' or c == 'rareelite') then
            return (l > 0) and l..'+' or '+'
        else
            return (l > 0) and l or '??'
        end
    end
end

do
    local cp_color = {
        [1] = '|cffffffff1|r',
        [2] = '|cffffffff2|r',
        [3] = '|cffffffff3|r',
        [4] = '|cffffd8194|r',
        [5] = '|cffff00005|r',
    }
    oUF.Tags.Methods['leaf:cp'] = function(u)
        local cp = GetComboPoints(PlayerFrame.unit, 'target')
        return cp_color[cp]
    end
    oUF.Tags.Events['leaf:cp'] = 'UNIT_COMBO_POINTS UNIT_TARGET'
end

oUF.Tags.Methods['leaf:threat'] = function(u) local s = UnitThreatSituation(u) return s and (s>2) and '|cffff0000.|r' end
oUF.Tags.Events['leaf:threat'] = 'UNIT_THREAT_SITUATION_UPDATE'

do
    local ThreatStatusColor = {
        [1] = Hex(1, 1, .47),
        [2] = Hex(1, .6, 0),
        [3] = Hex(1, 0, 0),
    }
    oUF.Tags.Methods['leaf:threatcolor'] = function(u) return ThreatStatusColor[UnitThreatSituation(u)] or '|cffffffff' end
    oUF.Tags.Events['leaf:threatcolor'] = 'UNIT_THREAT_SITUATION_UPDATE'
end

oUF.Tags.Methods['leaf:status'] = function(u)
    return UnitIsDead(u) and 'Dead' or UnitIsGhost(u) and 'Ghost'
end
oUF.Tags.Events['leaf:status'] = 'UNIT_HEALTH'

do
    local _smooth = {
        0, 1, 0,
        1, 1, 0,
        1, 0, 0
    }

    oUF.Tags.Methods['leaf:threatpct'] = function(u)
        local isTanking, status, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation('player', 'target')
        if not threatpct then return end

        if isTanking then
            threatpct = 100
        else
            threatpct = min(100, ceil(threatpct))
        end

        local r,g,b = oUF.ColorGradient(threatpct/100, unpack(_smooth))
        return Hex(r,g,b) .. (isTanking and 'Aggro' or threatpct .. '%')
    end
    oUF.Tags.Events['leaf:threatpct'] = 'UNIT_THREAT_SITUATION_UPDATE'
end

oUF.Tags.Methods['leaf:druidpower'] = function(u)
    local mana = UnitPowerType(u) == SPELL_POWER_MANA
    local powerType = mana and SPELL_POWER_ENERGY or SPELL_POWER_MANA
    local min, max = UnitPower(u, mana and 3 or 0), UnitPowerMax(u, mana and 3 or 0)
    if min~=max then
        local r,g,b = unpack(colors.power[mana and 'ENERGY' or 'MANA'])
        local text = mana and format('%d', min) or format('%d%%', floor(min/max*100))
        return Hex(r,g,b) .. text
    end
end
oUF.Tags.Events['leaf:druidpower'] = 'UNIT_POWER UPDATE_SHAPESHIFT_FORM'


do
    local get_name = function(unit)
        local name = UnitName(unit)
        local color = oUF.Tags.Methods['leaf:raidcolor'](unit) or ''
        local eng = strbyte(name, 1) > 224
        return color .. utf8sub(name, eng and 5 or 3)
    end

    local cache = {}

    oUF.Tags.Methods['leaf:raid'] = function(unit, realUnit)
        local u = realUnit or unit
        local name = UnitName(u)
        local rname = cache[name]

        if(rname) then
            return rname
        else
            rname = get_name(u)
            cache[name] = rname
            return rname
        end
    end
    oUF.Tags.Events['leaf:raid'] = 'UNIT_NAME_UPDATE'
end

--local c_red = '|cffff8080'
--local c_green = '|cff559655'
--local c_gray = '|cffD7BEA5'

