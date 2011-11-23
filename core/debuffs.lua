
local _, ns = ...
ns.raid_debuffs = {}

for k, v in ipairs{
} do
    local spell = GetSpellInfo(v)
    if(spell) then
        ns.raid_debuffs[spell] = k+10
    end
end

