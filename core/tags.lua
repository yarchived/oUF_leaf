
local _, ns = ...
local oUF = ns.oUF or oUF
local leaf = ns.leaf

local Hex = leaf.Hex
local utf8sub = leaf.utf8sub
local truncate = leaf.truncate
local colors = leaf.colors

oUF.Tags['leaf:difficulty']  = function(u) local l = UnitLevel(u); return Hex(GetQuestDifficultyColor((l > 0) and l or 99)) end

oUF.Tags['leaf:curhp'] = function(u) return truncate(UnitHealth(u)) end
oUF.TagEvents['leaf:curhp'] = 'UNIT_HEALTH'

oUF.Tags['leaf:curpp'] = function(u) return truncate(UnitPower(u)) end
oUF.TagEvents['leaf:curpp'] = 'UNIT_POWER'

oUF.Tags['leaf:maxhp'] = function(u) return truncate(UnitHealthMax(u)) end
oUF.TagEvents['leaf:maxhp'] = 'UNIT_MAXHEALTH'

oUF.Tags['leaf:maxpp'] = function(u) return truncate(UnitPowerMax(u)) end
oUF.TagEvents['leaf:maxpp'] = 'UNIT_MAXPOWER'

do
    local CC = setmetatable({}, {__index = function(t, i)
        local c = i and colors.class[i]
        t[i] = c and Hex(c)
        return t[i]
    end})
    oUF.Tags['leaf:raidcolor'] = function(u) local _, x = UnitClass(u); return CC[x or 'WARRIOR'] end
end

oUF.Tags['leaf:detail'] = function(u)
	if UnitIsPlayer(u) then
		return ('%s%s|r %s'):format(oUF.Tags['[leaf:raidcolor]'](u), UnitClass(u), UnitRace(u))
	else
		return UnitCreatureFamily(u) or UnitCreatureType(u)
	end
end

oUF.Tags['leaf:perhp'] = function(u)
	local m = UnitHealthMax(u)
	return m == 0 and 0 or floor(UnitHealth(u)/m*100+0.5)
end
oUF.TagEvents['leaf:perhp'] = 'UNIT_HEALTH UNIT_MAXHEALTH'

oUF.Tags['leaf:perpp'] = function(u)
	local c, m = UnitPower(u), UnitPowerMax(u)
	return m == 0 and 0 or floor(c/m*100+0.5)
end
oUF.TagEvents['leaf:perpp'] = 'UNIT_POWER UNIT_MAXPOWER'

oUF.Tags['leaf:smartpp'] = function(u)
	if select(2,UnitPowerType(u)) == 'MANA' then
		oUF.Tags['leaf:perpp'](u)
	else
		return UnitPower(u)
	end
end
oUF.TagEvents['leaf:smartpp'] = 'UNIT_POWER UNIT_MAXPOWER'

oUF.Tags['leaf:name'] = function(u, r)
	local name, realm = UnitName(r or u)
	if realm and (realm~='') then name = name .. '-' .. realm end
	return name
end
oUF.TagEvents['leaf:name'] = 'UNIT_NAME_UPDATE'

local color_power = {}
for k, v in pairs(colors.power) do
	color_power[k] = Hex(v)
end
oUF.Tags['leaf:colorpower'] = function(u) local n,s = UnitPowerType(u) return color_power[s] end

oUF.Tags['leaf:smartlevel'] = function(u)
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
	oUF.Tags['leaf:cp'] = function(u)
		local cp = GetComboPoints(PlayerFrame.unit, 'target')
		return cp_color[cp]
	end
	oUF.TagEvents['leaf:cp'] = 'UNIT_COMBO_POINTS UNIT_TARGET'
end

oUF.Tags['leaf:threat'] = function(u) local s = UnitThreatSituation(u) return s and (s>2) and '|cffff0000.|r' end
oUF.TagEvents['leaf:threat'] = 'UNIT_THREAT_SITUATION_UPDATE'

do
	local ThreatStatusColor = {
		[1] = Hex(1, 1, .47),
		[2] = Hex(1, .6, 0),
		[3] = Hex(1, 0, 0),
	}
	oUF.Tags['leaf:threatcolor'] = function(u) return ThreatStatusColor[UnitThreatSituation(u)] or '|cffffffff' end
	oUF.TagEvents['leaf:threatcolor'] = 'UNIT_THREAT_SITUATION_UPDATE'
end

oUF.Tags['leaf:status'] = function(u)
	return UnitIsDead(u) and 'Dead' or UnitIsGhost(u) and 'Ghost'
end
oUF.TagEvents['leaf:status'] = 'UNIT_HEALTH'

do
	local _smooth = {
		0, 1, 0,
		1, 1, 0,
		1, 0, 0
	}

	oUF.Tags['leaf:threatpct'] = function(u)
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
	oUF.TagEvents['leaf:threatpct'] = 'UNIT_THREAT_SITUATION_UPDATE'
end

oUF.Tags['leaf:druidpower'] = function(u)
	local mana = UnitPowerType(u) == 0
	local min, max = UnitPower(u, mana and 3 or 0), UnitPowerMax(u, mana and 3 or 0)
	if min~=max then
		local r,g,b = unpack(colors.power[mana and 'ENERGY' or 'MANA'])
		local text = mana and format('%d', min) or format('%d%%', floor(min/max*100))
		return Hex(r,g,b) .. text
	end
end
oUF.TagEvents['leaf:druidpower'] = 'UNIT_POWER UPDATE_SHAPESHIFT_FORM'

local raidtag_cache = {}
local function cache_tag(u)
	local name = UnitName(u)
	if not name then return end
	local c = oUF.Tags['leaf:raidcolor'](u) or ''
	local str
	if (strbyte(name,1) > 224) then
		str = utf8sub(name, 3)
	else
		str = utf8sub(name, 5)
	end
	
	raidtag_cache[name] = c .. str
	return raidtag_cache[name]
end

--local c_red = '|cffff8080'
--local c_green = '|cff559655'
--local c_gray = '|cffD7BEA5'

oUF.Tags['leaf:raid'] = function(unit, realUnit)
	return raidtag_cache[UnitName(realUnit or unit)] or cache_tag(realUnit or unit)
end
oUF.TagEvents['leaf:raid'] = 'UNIT_NAME_UPDATE'

