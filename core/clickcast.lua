
local _, ns = ...
ns.ClickCast = {}
ns.ClickCast.Bindings = {}

local typeTable = {
	s = 'spell',
	i = 'item',
	m = 'macro',
}

local function get_attr_func(key, action, modkey)
    modkey = modkey and (modkey..'-') or ''
    key = tostring(key)
    local ty, action = string.split('|', action, 2)
    ty = typeTable[ty] or ty

    local attr
    if(ty == 'spell' or ty == 'item' or ty == 'macro') then
        if(not action) then return '' end
    end

    if(ty == 'spell' or ty == 'item') then
        attr = ty
    elseif(ty == 'macro') then
        attr = 'macrotext'
    elseif(ty == 'assist' or ty == 'focus' or ty == 'target') then
        if(action) then
            attr = 'unit'
        end
    end

    local block = ('self:SetAttribute("%stype%s", "%s")'):format(modkey, key, ty)
    if(attr and action) then
        block = block.. ('\nself:SetAttribute("%s%s%s", [[%s]])'):format(modkey, attr, key, tostring(action))
    end

    return block
end

local function make_binding_func()
    local BINDING_STR = ''
    for modkey, modaction in next, ns.ClickCast.Bindings do
        if(type(modaction) == 'table') then
            for key, action in next, modaction do
                BINDING_STR = BINDING_STR .. '\n' .. get_attr_func(key, action, modkey)
            end
        else
            BINDING_STR = BINDING_STR .. '\n' .. get_attr_func(modkey, modaction)
        end
    end

    local func, err = loadstring([[return function(self)
        ]] .. BINDING_STR .. [[
            return self
        end ]])
    if(func) then
        ns.ClickCast.BindingFunc = func()
        ns.ClickCast.BINDING_STR = BINDING_STR
    else
        -- it should work, fix it NOW!
        print('\n================================================================')
        print(BINDING_STR)
        print('================================================================')
        print(debugstack(1, 50, 50))
        print('================================================================')
        print(err)
        print('================================================================\n')
    end
end

function ns.ClickCast:RegisterBindings(...)
    local bindings = ns.ClickCast.Bindings
    for i = 1, select('#', ...) do
        local tbl = select(i, ...)
        if(tbl) then
            for key, action in next, tbl do
                if(type(action) == 'table') then
                    for actualkey, actualact in next, action do
                        if(not bindings[key]) then bindings[key] = {} end
                        bindings[key][actualkey] = actualact
                    end
                else
                    bindings[key] = action
                end
            end
        end
    end

    make_binding_func()
end

oUF:RegisterInitCallback(function(self)
    -- make sure it's not group unitbutton
    local parent = self:GetParent()
    if(parent and type(parent.GetAttribute) == 'function' and parent:GetAttribute'oUF-headerType') then
        return
    end

    return ns.ClickCast.BindingFunc and ns.ClickCast.BindingFunc(self)
end)












--local ATTR_FUNC = ''
--for id, entry in next, cc_data do
--    local func = getAttr(entry)
--    ATTR_FUNC = ATTR_FUNC .. '\n' .. func
--end
--ns.CLICKCAST_FUNC = ATTR_FUNC
--
--
--local set_func
--do
--    local func_str = [[function(self)
--        ]] .. ATTR_FUNC .. [[
--            return self
--        end]]
--
--    local func, err = loadstring('return ' .. func_str)
--    if(func) then
--        set_func = func()
--    else
--        -- it should work, fix it NOW!
--        print('\n================================================================')
--        print(ATTR_FUNC)
--        print('================================================================')
--        print(debugstack(1))
--        print('================================================================')
--        print(err)
--        print('================================================================\n')
--    end
--end
--
