
local _, ns = ...
ns.ClickCast = {}
ns.ClickCast.Bindings = {}

-- list of supported (tested) attributes
local typeTable = {
	s = 'spell',
	i = 'item',
	m = 'macro',

    -- these should work withou problem
    --      focus
    --      target
    --      assist
    --      mainassist
    --      maintank
}

local ATTR = function(prefix, attr, suffix, value)
    return ('\nself:SetAttribute("%s%s%s%s%s", %q)'):format(
        prefix or '',
        prefix and (#prefix>0) and '-' or '',
        attr,
        suffix and (#suffix>0) and (not tonumber(suffix)) and '-' or '',
        suffix or '',
        value
    )
end

local function get_attr_func(key, action, modkey)
    -- [+] map to help
    -- [-] map to harm
    local pre
    if(type(key) == 'string') then
        pre = key:sub(1, 1)
        if(pre == '+' or pre == '-') then
            key = key:sub(2)
        else
            pre = nil
        end
    else
        key = tostring(key)
    end

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

    --local block = ('self:SetAttribute("%stype%s", "%s")'):format(modkey, key, ty)

    local block
    if(pre) then
        local origkey = key
        if(pre == '+') then
            key = 'help'..key
            block = ATTR(modkey, 'helpbutton', origkey, key)
        elseif(pre == '-') then
            key = 'harm'..key
            block = ATTR(modkey, 'harmbutton', origkey, key)
        end
        block = block .. ATTR(modkey, 'type', key, ty)
    else
        block = ATTR(modkey, 'type', key, ty)
    end
    if(attr and action) then
        block = block.. ATTR(modkey, attr, key, tostring(action))
        --block = block.. ('\nself:SetAttribute("%s%s%s", %q)'):format(modkey, attr, key, tostring(action))
    end

    return block
end

local function make_binding_func()
    local BINDING_STR = ''
    for key, action in next, ns.ClickCast.Bindings do
        if(type(action) == 'table') then
            for modkey, modaction in next, action do
                BINDING_STR = BINDING_STR .. '\n' .. get_attr_func(modkey, modaction, key)
            end
        else
            BINDING_STR = BINDING_STR .. '\n' .. get_attr_func(key, action)
        end
    end

    --print(BINDING_STR)

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
                    if(not bindings[key]) then bindings[key] = {} end
                    for modkey, modaction in next, action do
                        bindings[key][modkey] = modaction
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

