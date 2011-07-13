--[[
=============================================================================
Copyright (c) 2010 yaroot (@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
=============================================================================
    DruidPowerBar
        - showEnergy                Boolean
        - showMana                  Boolean
        - hideWhenFull              Boolean
        - CustomColor               Function
        - PreUpdate                 Function
        - PostUpdate                Function
--]]

if(select(2, UnitClass'player') ~= 'DRUID') then return end
local parent, ns = ...
local oUF = ns.oUF or oUF

local UpdateColor = function(bar, ptype, ptoken, cur, max, altR, altG, altB)
    local r, g, b, t
    if(bar.colorPower) then
        t = bar.__owner.colors.power[ptoken]
    elseif(bar.colorClass) then
        t = bar.__owner.colors.class.DRUID
    end

    if(t) then
        r, g, b = t[1], t[2], t[3]
    end
    if(not b and altB) then
        r, g, b = altR, altG, altB
    end

    if(b) then
        bar:SetStatusBarColor(r, g, b)

        local bg = bar.bg
        if(bg) then
            local mu = bg.mutiplier or 1
            bg:SetVertexColor(r * mu, g * mu, b * mu)
        end
    end
end

local GetVisibility = function(bar, ptype, ptoken, cur, max)
    if(bar.hideWhenFull) then
        return cur ~= max
    end
    return true
end

local Update = function(self, event, unit)
    if(unit ~= self.unit) then return end
    local bar = self.DruidPowerBar
    if(bar.PreUpdate) then bar:PreUpdate(unit) end

    local ptype, ptoken, altR, altG, altB = UnitPowerType(unit)
    local cur, max
    if(ptoken~='MANA' and bar.showMana) then
        cur, max = UnitPower(unit, 0), UnitPowerMax(unit, 0)
    elseif(ptoken=='MANA' and bar.showEnergy) then
        cur, max = UnitPower(unit, 3), UnitPowerMax(unit, 3)
    end

    local show = cur and max and (bar.CustomVisibility or GetVisibility) (bar, ptype, ptoken, cur, max)
    if(show) then
        if(bar.maxval ~= max) then
            bar:SetMinMaxValues(0, max)
        end
        bar:SetValue(cur)

        local colorFunc = bar.CustomColor or UpdateColor
        colorFunc(bar, ptype, ptoken, cur, max, altR, altG, altB)

        if(not bar:IsShown()) then
            bar:Show()
        end
    else
        if(bar:IsShown()) then
            bar:Hide()
        end
    end

    if(bar.PostUpdate) then bar:PostUpdate(ptype, ptoken, cur, max) end
end

local Path = function(self, ...)
    return (self.DruidPowerBar.Override or Update)(self, ...)
end

local UnitlessPath = function(self, event, ...)
    return (self.DruidPowerBar.Override or Update)(self, event, 'player')
end

local ForceUpdate = function(element)
    return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self)
    local bar = self.DruidPowerBar
    if(bar) then
        self:RegisterEvent('UNIT_POWER', Path)
        self:RegisterEvent('UNIT_MAXPOWER', Path)
        self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', UnitlessPath)
        bar.__owner = self
        bar:Hide()
        bar.maxval = -1

        return true
    end
end

local Disable = function(self)
    local bar = self.DruidPowerBar
    if(bar) then
        self:UnregisterEvent('UNIT_POWER', Path)
        self:UnregisterEvent('UNIT_MAXPOWER', Path)
        self:UnregisterEvent('UPDATE_SHAPESHIFT_FORM', UnitlessPath)
        bar:Hide()
        bar.__owner = nil
        bar.maxval = nil
    end
end

oUF:AddElement('DruidPowerBar', Path, Enable, Disable)

