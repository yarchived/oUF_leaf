
local TEST = nil
if(os) then
    TEST = 'on'
end

local _, ns = ...
local cc_data = ns.clickcast_data
ns.clickcast_data = nil

local getAttr = function(entry)
    local modifier = entry.modifier or ''
    local button = tostring(entry.button or '')

    local attr
    if(entry.type == 'spell') then
        attr = 'spell'
    elseif( entry.type == 'assist' or
            entry.type == 'focus' or
            entry.type == 'target') then

        attr = 'unit'
    elseif(entry.type == 'macro') then
        if(type(entry.value) == 'string') then
            attr = 'macrotext'
        else -- number
            attr = 'macro'
        end
    end

    return ( "self:SetAttribute('%stype%s', '%s')"):format(modifier, button, entry.type) .. ( (not attr) and '' or '\n'..
    (       ("self:SetAttribute('%s%s%s', '%s')"):format(modifier, attr, button, tostring(entry.value)))
    )
end

local ATTR_FUNC = ''
for id, entry in next, cc_data do
    local func = getAttr(entry)
    ATTR_FUNC = ATTR_FUNC .. '\n' .. func
end
ns.CLICKCAST_FUNC = ATTR_FUNC


local set_func
do
    local func_str = [[function(self)
        ]] .. ATTR_FUNC .. [[
            return self
        end]]

    local func, err = loadstring('return ' .. func_str)
    if(func) then
        set_func = func()
    else
        -- it should work, fix it NOW!
        print('\n================================================================')
        print(ATTR_FUNC)
        print('================================================================')
        print(debugstack(1))
        print('================================================================')
        print(err)
        print('================================================================\n')
    end
end

oUF:RegisterInitCallback(function(self)
    -- make sure it's not group unitbutton
    local parent = self:GetParent()
    if(parent and type(parent.GetAttribute) == 'function' and parent:GetAttribute'oUF-headerType') then
        return
    end
    
    return set_func(self)
end)

