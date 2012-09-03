
local _, ns = ...
local oUF = ns.oUF or oUF
local leaf = ns.leaf

leaf.units = {}

leaf.class = select(2, UnitClass'player')

leaf.Range = {
    insideAlpha = 1,
    outsideAlpha = .4,
}

leaf.backdrop = {
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {top = -1, left = -1, bottom = -1, right = -1},
}

function leaf.updatemasterlooter(self)
    local unit = self.unit
	self.MasterLooter:ClearAllPoints()
    if(UnitIsGroupLeader(unit) or UnitIsGroupAssistant(unit)) then
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


local function truncate(value)
	if(value >= 1e6) then
		value = format('%.1fm', value / 1e6)
	elseif(value >= 1e3) then
		value = format('%.1fk', value / 1e3)
	end
	return gsub(value, '%.?0+([km])$', '%1')
end
leaf.truncate = truncate


local _ENV = getfenv(oUF.Tags.Methods['level'])
rawset(_ENV, 'utf8sub', utf8sub)
rawset(_ENV, 'truncate', truncate)
leaf.Hex = rawget(_ENV, 'Hex')

