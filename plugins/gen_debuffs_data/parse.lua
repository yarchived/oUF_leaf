
local _boss = 'trash'
local data = {}
local da = {}
local _zone = 'Unknown'

GridStatusRaidDebuff = {
    BossName = function(self, zone, _, bossName)
        _boss = bossName
        _zone = zone
    end,
    Debuff = function(self, zone, id)
        _zone = zone

        local d = {
            zone = _zone,
            boss = _boss,
            id = id,
        }

        table.insert(data, d)

    end,
}


dofile(arg[1])

do
    local _zone
    for _, t in ipairs(data) do
        if(_zone ~= t.zone) then
            print('\n-- ' .. t.zone)
            _zone = t.zone
        end
        print(t.id .. ', -- ' .. t.boss)
    end
end

