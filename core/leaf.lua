
local _, ns = ...
local oUF = _NS.oUF or oUF

local leaf = ns.leaf

leaf.noraid = false
leaf.noarena = false
leaf.AuraWatch = true
leaf.auraWatchSize = 32

leaf.frameScale = 1.1 -- global scale
leaf.HealComm = true
leaf.raid_druid_hots = true
leaf.test_mod = false

leaf.units = {}

local _, class = UnitClass'player'
local playername = UnitName'player'
leaf.backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	insets = {top = -1, left = -1, bottom = -1, right = -1},
}

leaf.playerAuraFilter = class == 'DRUID' and {
	[GetSpellInfo(52610)] = true, -- Savage Roar
	[GetSpellInfo(48517)] = true, -- Eclipse
	[GetSpellInfo(50334)] = true, -- Berserk
	[GetSpellInfo(5217)] = true, -- Tiger's Fury
	[GetSpellInfo(16864)] = true, -- Omen of Clarity
	[GetSpellInfo(22812)] = true, -- Barkskin
	[GetSpellInfo(5229)] = true, -- Enrage
	[GetSpellInfo(22842)] = true, -- Frenzied Regeneration
	[GetSpellInfo(61336)] = true, -- Survival Instincts
}

-- color credit: caellian
local colors = setmetatable({
	power = setmetatable({
	--[[
		['MANA'] = {.3,.5,.85},
		['RAGE'] = {.9,.2,.3},
		['ENERGY'] = {1,.85,.1},
		['RUNIC_POWER'] = {0,.8,1},
	]]
		['MANA'] = {0.31, 0.45, 0.63},
		['RAGE'] = {0.69, 0.31, 0.31},
		['FOCUS'] = {0.71, 0.43, 0.27},
		['ENERGY'] = {0.65, 0.63, 0.35},
		['RUNES'] = {0.55, 0.57, 0.61},
		['RUNIC_POWER'] = {0, 0.82, 1},
		['AMMOSLOT'] = {0.8, 0.6, 0},
		['FUEL'] = {0, 0.55, 0.5},
		['POWER_TYPE_STEAM'] = {0.55, 0.57, 0.61},
		['POWER_TYPE_PYRITE'] = {0.60, 0.09, 0.17},
	--[[
		['MANA'] = {.31,.45,.63},
		['RAGE'] = {.69,.31,.31},
		['FOCUS'] = {.71,.43,.27},
		['ENERGY'] = {.65,.63,.35},
		['RUNIC_POWER'] = {0,.8,.9},
	]]
	}, {__index = oUF.colors.power}),
	--health = {.15,.15,.15},
	--disconnected = {.5,.5,.5},
	--tapped = {.5,.5,.5},
	--smooth = {1, 0, 0, 1, 1, 0, 0, 1, 0},
	happness = {
		[1] = {.69,.31,.31},
		[2] = {.65,.63,.35},
		[3] = {.33,.59,.33},
	},
	runes = {
		[1] = {0.69, 0.31, 0.31},
		[2] = {0.33, 0.59, 0.33},
		[3] = {0.31, 0.45, 0.63},
		[4] = {0.84, 0.75, 0.65},
	},
	tapped = {0.55, 0.57, 0.61},
	disconnected = {0.84, 0.75, 0.65},
	smooth = {0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.15, 0.15, 0.15},
}, {__index = oUF.colors})
leaf.colors = colors

--do
--	for _, addon in pairs{'Grid', 'Grid2', 'VuhDo', 'PerfectRaid', 'sRaidFrames', 'HealBot'} do
--		if IsAddOnLoaded(addon) then
--			leaf.noraid = true
--			break
--		end
--	end
--end

local function isLeader(unit)
	return (UnitInParty(unit) or UnitInRaid(unit)) and UnitIsPartyLeader(unit)
end
local function isAssistant(unit)
	return UnitInRaid(unit) and UnitIsRaidOfficer(unit) and not UnitIsPartyLeader(unit)
end

function leaf.updatemasterlooter(self)
	self.MasterLooter:ClearAllPoints()
	if isLeader(self.unit) or isAssistant(self.unit) then
		self.MasterLooter:SetPoint('LEFT', self.Leader, 'RIGHT')
	else
		self.MasterLooter:SetPoint('TOPLEFT', self.Leader)
	end
end

--[[local function menu(self)
	local unit = string.gsub(self.unit, '(.)', string.upper, 1)
	if(_G[unit..'FrameDropDown']) then
		ToggleDropDownMenu(1, nil, _G[unit..'FrameDropDown'], 'cursor')
	end
end]]
local function menu(self)
	local unit = self.unit:gsub('(.)', string.upper, 1)
	if _G[unit..'FrameDropDown'] then
		ToggleDropDownMenu(1, nil, _G[unit..'FrameDropDown'], 'cursor')
	elseif (self.unit:match('party')) then
		ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor')
	else
		FriendsDropDown.unit = self.unit
		FriendsDropDown.id = self.id
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
		ToggleDropDownMenu(1, nil, FriendsDropDown, 'cursor')
	end
end
leaf.menu = menu


local function SetManyAttributes(header, ...)
	for i=1, select("#", ...), 2 do
		local att, val = select(i, ...)
		if(not att) then break end
		header:SetAttribute(att, val)
	end
end
leaf.SetManyAttributes = SetManyAttributes

local function utf8sub(str, num)
	local i = 1
	while num > 0 and i <= #str do
		local c = strbyte(str, i)
		if(c >= 0 and c <= 127) then
			i = i + 1
		elseif(c >= 194 and c <= 223) then
			i = i + 2
		elseif(c >= 224 and c <= 239) then
			i = i + 3
		elseif(c >= 240 and c <= 224) then
			i = i + 4
		end
		num = num - 1
	end

	return str:sub(1, i - 1)
end
leaf.utf8sub = utf8sub

local function Hex(r, g, b)
	if(type(r) == 'table') then
		if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	
	if(not r or not g or not b) then
		r, g, b = 1, 1, 1
	end
	
	return format('|cff%02x%02x%02x', r*255, g*255, b*255)
end
leaf.hex = Hex

local function truncate(value)
	if(value >= 1e6) then
		value = format('%.1fm', value / 1e6)
	elseif(value >= 1e3) then
		value = format('%.1fk', value / 1e3)
	end
	return gsub(value, '%.?0+([km])$', '%1')
end
leaf.truncate = truncate

local classColors = {}
do
	for class, c in pairs(CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS) do
		classColors[class] = format('|cff%02x%02x%02x', c.r*255, c.g*255, c.b*255)
	end
end

---------------------------------------------------------------------

oUF.Tags['leaf:difficulty']  = function(u) local l = UnitLevel(u); return Hex(GetQuestDifficultyColor((l > 0) and l or 99)) end

oUF.Tags['leaf:curhp'] = function(u) return truncate(UnitHealth(u)) end
oUF.TagEvents['leaf:curhp'] = 'UNIT_HEALTH'

oUF.Tags['leaf:curpp'] = function(u) return truncate(UnitPower(u)) end
oUF.TagEvents['leaf:curpp'] = 'UNIT_POWER'

oUF.Tags['leaf:maxhp'] = function(u) return truncate(UnitHealthMax(u)) end
oUF.TagEvents['leaf:maxhp'] = 'UNIT_MAXHEALTH'

oUF.Tags['leaf:maxpp'] = function(u) return truncate(UnitPowerMax(u)) end
oUF.TagEvents['leaf:maxpp'] = 'UNIT_MAXPOWER'

oUF.Tags['leaf:raidcolor'] = function(u) local _, x = UnitClass(u); return classColors[x or 'WORRIOR'] end

oUF.Tags['leaf:detail'] = function(u)
	if UnitIsPlayer(u) then
		return ('%s%s|r %s'):format(oUF.Tags['[leafraidcolor]'](u), UnitClass(u), UnitRace(u))
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

oUF.Tags['leaf:name'] = function(u, ru)
	local name, realm = UnitName(ru or u)
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

