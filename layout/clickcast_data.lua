
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

    -- order: alt-ctrl-shift-
    ['alt-ctrl'] = {
        [2] = 'focus',
    },
}

bindings.DRUID = {
    alt = {
        ['+1'] = 's|774',       -- 回春
        -- ['-1'] = 's|8921',      -- 月火
        [2] = 's|8936',         -- 愈合
        [4] = 's|18562',        -- 迅癒
        -- [5] = 's|29166',        -- 激活
    },

    ctrl = {
        [1] = 's|102342',   -- 铁木树皮
        [2] = 's|5185',     -- 治疗之触
        [4] = 's|48438',    -- 野性成长
        [5] = 'm|/cast [@mouseover,combat]' .. SPELLS.REBIRTH ..
        '\n/cast [@mouseover]' .. SPELLS.REVIVE,
    },

    shift = {
        [1] = 's|88423',    -- 自然之愈
        [2] = 's|33763',    -- 生命绽放
        [4] = 's|50464',    -- 滋养
    },
}

ns.ClickCast:RegisterBindings(bindings.base, bindings[select(2, UnitClass'player')])

