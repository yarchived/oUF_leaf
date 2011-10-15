
local TEST = nil
if(os) then
    TEST = 'on'
end

local _, ns = ...

local SPELLS = {
    ['REBIRTH'] = 20484,
    ['REVIVE'] = 50769,
}
for n, id in next, SPELLS do
    SPELLS[n] = TEST and n or GetSpellInfo(id)
end

local cc_data = {}
ns.clickcast_data = cc_data
local class = TEST and 'DRUID' or select(2, UnitClass'player')
local function add(tbl)
    table.insert(cc_data, tbl)
end

if(class == 'DRUID') then
    add({
        ['type'] = 'spell',
        ['modifier'] = 'Alt-',
        ['button'] = 1,
        ['value'] = 774, --回春术
    })
    add({
        ['type'] = 'spell',
        ['modifier'] = 'Ctrl-',
        ['button'] = 2,
        ['value'] = 5185, --治疗之触
    })
    add({
        ['type'] = 'spell',
        ['modifier'] = 'Shift-',
        ['button'] = 1,
        ['value'] = 2782, --解除诅咒
    })
    add({
        ['type'] = 'spell',
        ['modifier'] = 'Ctrl-',
        ['button'] = 4,
        ['value'] = 48438, --野性成长
    })
    add({
        ['type'] = 'spell',
        ['modifier'] = 'Shift-',
        ['button'] = 4,
        ['value'] = 50464, --滋補術
    })
    add({
        ['type'] = 'spell',
        ['modifier'] = 'Ctrl-',
        ['button'] = 1,
        ['value'] = 2893, --驱毒术
    })
    add({
        ['type'] = 'spell',
        ['modifier'] = 'Alt-',
        ['button'] = 2,
        ['value'] = 8936, --'愈合'
    })
    add({
        ['type'] = 'spell',
        ['modifier'] = 'Shift-',
        ['button'] = 2,
        ['value'] = 33763, --'生命绽放'
    })
    add({
        ['type'] = 'spell',
        ['modifier'] = 'Alt-',
        ['button'] = 5,
        ['value'] = 29166, -- 激活
    })
    add({
        ['type'] = 'spell',
        ['modifier'] = 'Alt-',
        ['button'] = 4,
        ['value'] = 18562, -- 迅癒
    })
    add({
        ['type'] = 'assist',
        ['modifier'] = 'Shift-',
        ['button'] = 5,
    })
    add({
        ['type'] = 'focus',
        ['modifier'] = 'Alt-Ctrl-',
        ['button'] = 2,
    })
    add({
        ['type'] = 'macro',
        ['modifier'] = 'Ctrl-',
        ['button'] = 5,
        ['value'] = '/cast [target=mouseover,combat]' ..
        SPELLS.REBIRTH ..
        ';[target=mouseover]' ..
        SPELLS.REVIVE,
    })
elseif(class == 'PRIEST') then

end

