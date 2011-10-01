local _, ns = ...
local oUF = ns.oUF or oUF
local db

local attr = {
	macro = function(v)
		if type(v) == 'number' then
			return 'macro'
		else -- string
			return 'macrotext'
		end
	end,
	spell = 'spell',
	assist = 'unit',
	focus = 'unit',
	target = 'unit',
}

local attrFuncs = {}
for k, v in next, attr do
	if type(v) ~= 'function' then
		attrFuncs[k] = function() return v end
	else
		attrFuncs[k] = v
	end
end

local function hook(self)
	db = db or ns.ClickCastDB or ClickCastDB
	if not db then return end
	
	--self:RegisterForClicks('AnyUp')
	self:RegisterForClicks('AnyDown') -- that's the speedy
	
	for _, s in next, db do
		self:SetAttribute(s.modifier .. 'type' .. s.button, s.type)
		if s.value then
			local get = attrFuncs[s.type]
            if(s.type == 'spell') then
                local spell = s.value
                if(type(spell) == 'number') then
                    spell = GetSpellInfo(spell)
                end
                self:SetAttribute(s.modifier .. get(s.value) .. s.button, spell)
            else
                self:SetAttribute(s.modifier .. get(s.value) .. s.button, s.value)
            end
		end
	end
end

local function PLAYER_REGEN_ENABLED(self)
	self:UnregisterEvent('PLAYER_REGEN_ENABLED', PLAYER_REGEN_ENABLED)
	hook(self)
end

local function Enable(self)
	if(not self.NoClickCast) then
        if InCombatLockdown() then
            self:RegisterEvent('PLAYER_REGEN_ENABLED', PLAYER_REGEN_ENABLED)
        else
            hook(self)
        end
    end
end

-- enable, not update
oUF:AddElement('ClickCast', nil, Enable, nil)

