
local _, ns = ...

local oUF = ns.oUF or oUF
local tinsert = table.insert

local csets = {}
ns.ClickCastDB = csets
local add = function(set)
    tinsert(csets, set)
end

if(ns.leaf.class == 'DRUID') then
    -- {{{
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
        GetSpellInfo(20484) ..
        ';[target=mouseover]' ..
        GetSpellInfo(50769),
        -- 复生, 起死回生
    })
    --}}}
elseif(ns.leaf.class == 'PRIEST') then

end



local init, CreateClick

do
    local function createCastAttr(self, entry)
        local modifier = entry.modifier or ''
        local button = entry.button or ''

        self:SetAttribute(modifier..'type'..button, entry.type)

        local value = entry.value
        if(value) then
            local attr
            if(entry.type == 'spell') then
                -- spell id should work
                attr = 'spell'

            elseif( entry.type == 'assist' or
                entry.type == 'focus' or
                entry.type == 'targe'
                ) then
                attr = 'unit'

            elseif(entry.type == 'macro') then
                if(type(value) == 'number') then
                    attr = 'macro'
                elseif(type(value) == 'string') then
                    attr = 'macrotext'
                end
            end
            self:SetAttribute(modifier..attr..button, value)
        end
    end

    function CreateClick(self)
        self:RegisterForClicks('AnyDown')

        for _, entry in next, csets do
            createCastAttr(self, entry)
        end
    end
end

local objs = {}

local function init(self, event)
    -- I cheat a little bit, hence it should be run through the secure closure.
    -- But what the heck, it's easier to do.
    if(InCombatLockdown()) then
        return self:RegisterEvent('PLAYER_REGEN_ENABLED', init)
    elseif(evnet == 'PLAYER_REGEN_ENABLED') then
        self:UnregisterEvent('PLAYER_REGEN_ENABLED', init)
    end

    if(not self:GetAttribute'oUF-onlyProcessChildren') then
        if(not objs[self]) then
            CreateClick(self)
            objs[self] = true
        end
    end
end

oUF:RegisterInitCallback(init)

