
local _, ns = ...
ns.clickcast_data = {}


local SPELLS = {
    ['REBIRTH'] = 20484,
    ['REVIVE'] = 50769,
}
for n, id in next, SPELLS do
    SPELLS[n] = GetSpellInfo(id)
end

local bindings = {}
bindings.base = {
    shift = {
        [5] = 'assist',
    },
    ['ctrl-alt'] = {
        [2] = 'focus',
    },
}

bindings.DRUID = {
    alt = {
        [1] = 's|774',      -- 回春
        [2] = 's|8936',     -- 愈合
        [4] = 's|18562',    -- 迅癒
        --[5] = 's|29166',    -- 激活
    },

    ctrl = {
        [2] = 's|5185',     -- 治疗之触
        [4] = 's|48438',    -- 野性成长
        [5] = 'm|/cast [@mouseover,combat]' .. SPELLS.REBIRTH ..
            '\n/cast [@mouseover]' .. SPELLS.REVIVE,
    },

    shift = {
        [1] = 's|2782',     -- 净化腐蚀
        [2] = 's|33763',    -- 生命绽放
        [4] = 's|50464',    -- 滋補術
    },
}

ns.ClickCast:RegisterBindings(bindings.base, bindings[select(2, UnitClass'player')])

