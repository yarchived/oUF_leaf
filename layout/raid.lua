
local _, ns = ...
local oUF = ns.oUF or oUF
local leaf = ns.leaf

if leaf.noraid then return end

local class = leaf.class
local texture = [[Interface\AddOns\oUF_leaf\media\white]]
local glowTex = [[Interface\AddOns\oUF_leaf\media\glowTex]]
local backdrop = leaf.backdrop

-- Druid hots
local setupDruidHots
do
    local Hex = leaf.Hex

    local spell_dot = {
        [GetSpellInfo(8936)] = Hex(.5, 1, .5) .. '.', -- 愈合
        [GetSpellInfo(--[[53249]] 48438)] = Hex(.2, 1, .5) .. '.', -- 野性成长
    }
    local spell_bar = {
        --[GetSpellInfo(774)] = {color = {1, .3, .7}}, -- 回春
        [GetSpellInfo(774)] = {color = {.8, .25, 0}}, -- 回春
        [GetSpellInfo(33763)] = {color = {.4, 1, .1}, countable = true}, -- 生命绽放
    }

    --hooksecurefunc(GameTooltip, 'SetUnitAura', function(self, unit, index, filter)
    --    print(UnitAura(unit, index, filter))
    --end)

    local function UNIT_AURA(self, event, unit)
        if self.unit ~= unit then return end

        local dh = self.DruidHots

        local text = ''
        for spell, dot in next, spell_dot do
            local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura(unit, spell)
            if name and (unitCaster == 'player') then
                text = text .. dot
            end
        end
        dh.Dots:SetText(text)

        for spell, info in next, spell_bar do
            local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura(unit, spell)
            local bar = dh.Bars[spell]
            if name and (unitCaster == 'player') then
                bar.duration = expirationTime - GetTime()
                bar.maxTime = duration

                bar:SetMinMaxValues(0, duration)
                bar:SetValue(bar.duration)

                if bar.count then
                    bar.count:SetText(count)
                end

                bar:Show()
            else
                bar:Hide()
            end
        end
    end 

    local function OnUpdate(self, elps)
        self.duration = self.duration - elps
        if self.duration < 0 then
            self:Hide()
        else
            self:SetValue(self.duration)
        end
    end

    local function createBar(self, info)
        local bar = CreateFrame('StatusBar', nil, self)
        bar:Hide()
        bar:SetOrientation('VERTICAL')
        bar:SetStatusBarTexture(texture)
        bar:SetStatusBarColor(unpack(info.color))

        bar:SetScript('OnUpdate', OnUpdate)

        bar:SetWidth(1)

        if info.countable then
            bar.count = bar:CreateFontString(nil, 'OVERLAY')
            bar.count:SetFont(STANDARD_TEXT_FONT, 8, 'OUTLINE')
            bar.count:SetPoint('BOTTOM', self, 0, 0)
            bar.count:SetTextColor(unpack(info.color))
        end

        return bar
    end

    function setupDruidHots(self)
        local dh = {}

        local dots = self.Health:CreateFontString(nil, 'OVERLAY')
        dots:SetFont(STANDARD_TEXT_FONT, 36, 'OUTLINE')
        dots:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -3, -10)
        dh.Dots = dots

        local bars = {}
        for spell, info in next, spell_bar do
            local bar = createBar(self, info)

            if bar.count then
                bar:SetPoint('TOPLEFT', self, 'TOPRIGHT', 1, 0)
            else
                bar:SetPoint('TOPLEFT', self, 'TOPRIGHT', 3, 0)
            end
            bar:SetPoint('BOTTOM', self)

            bars[spell] = bar
        end
        dh.Bars = bars

        self.DruidHots = dh
        self:RegisterEvent('UNIT_AURA', UNIT_AURA)
    end
end


local function OverrideThreatUpdate(self, event, unit)
    if(unit ~= self.unit) then return end

    local threat = self.Threat

    local status = UnitThreatSituation(unit)

    if(status and status > 1) then
        local r, g, b = GetThreatStatusColor(status)
        threat:SetBackdropBorderColor(r, g, b)
        threat:Show()
    else
        threat:Hide()
    end
end

local function OverrideUpdateHealth(self, event, unit)
    if(self.unit ~= unit) then return end

    local health = self.Health

    local min, max = UnitHealth(unit), UnitHealthMax(unit)
    local disconnected = not UnitIsConnected(unit)
    health:SetMinMaxValues(0, max)

    if(disconnected) then
        health:SetValue(max)
    else
        health:SetValue(min)
    end

    health.disconnected = disconnected
    health.unit = unit

    local color
    if disconnected or UnitIsDeadOrGhost(unit) then
        color = self.colors.disconnected
    else
        color = self.colors.class[select(2, UnitClass(unit))]
    end

    if(color) then
        self.health_bg:SetVertexColor(unpack(color))
    end
end

local HealCommUpdate = function(self, event, unit)
    if(self.unit ~= unit) then return end

    local bar = self.HealCommBar

    local inc = UnitGetIncomingHeals(unit) or 0
    local max, min = UnitHealthMax(unit), UnitHealth(unit)
    if(inc==0 or inc<(max*.05)) then
        bar:Hide()
        if(max ~= 0 and min/max < .8) then
            self.centertext:SetText('|cffe5334c-' .. leaf.truncate(max-min))
        else
            self.centertext:SetText(oUF.Tags['leaf:raid'](self.unit, self.realUnit))
        end
    else
        --if(bar.Vertical) then
        --    bar:SetHeight(bar.Height * inc/max)
        --    bar:ClearAllPoints()
        --    bar:SetPoint('BOTTOMLEFT', self.Health, 0, min/max * bar.Height)
        --else
        --    bar:SetWidth(bar.Width * inc/max)
        --    bar:ClearAllPoints()
        --    bar:SetPoint('BOTTOMLEFT', self.Health, min/max * bar.Width, 0)
        --end
        bar:SetMinMaxValues(0, max)
        bar:SetValue(inc)

        bar:Show()
        self.centertext:SetText('|cff50a050+' .. leaf.truncate(inc))
    end
end

local HealCommCreateBar = function(self)
    local bar = CreateFrame('StatusBar', nil, self.Health)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(1)
    bar:SetStatusBarTexture(self.Health:GetStatusBarTexture():GetTexture())
    bar:SetStatusBarColor(0, 1, 0, .5)
    bar:SetFrameStrata'TOOLTIP'

    local ori = self.Health:GetOrientation()
    bar:SetOrientation(ori)
    bar:SetHeight(self.Health:GetHeight())
    bar:SetWidth(self.Health:GetWidth())

    if(ori == 'VERTICAL') then
        bar:SetPoint('BOTTOM', self.Health:GetStatusBarTexture(), 'TOP')
    else
        bar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
    end

    bar:Hide()

    self.HealCommBar = bar
    self:RegisterEvent('UNIT_NAME_UPDATE',      HealCommUpdate)
    self:RegisterEvent('UNIT_CONNECTION',       HealCommUpdate)
    self:RegisterEvent('UNIT_HEALTH',           HealCommUpdate)
    self:RegisterEvent('UNIT_MAXHEALTH',        HealCommUpdate)
    self:RegisterEvent('UNIT_HEAL_PREDICTION',  HealCommUpdate)
    table.insert(self.__elements,               HealCommUpdate)

    return bar
end

local function styleFunc(settings, self, unit)
    self.colors = leaf.colors
    self.menu = leaf.menu
    self:RegisterForClicks('AnyUp')
    --self:SetAttribute('type3', 'menu')
    --self:SetAttribute('*type2', nil)
    self:SetScript('OnEnter', UnitFrame_OnEnter)
    self:SetScript('OnLeave', UnitFrame_OnLeave)
    --self:SetAttribute('initial-height', settings['initial-height'])
    --self:SetAttribute('initial-width', settings['initial-width'])

    self:SetBackdrop(backdrop)
    self:SetBackdropColor(0, 0, 0, 1)

    self.Health = CreateFrame('StatusBar', nil, self)
    self.Health:SetOrientation('VERTICAL')
    self.Health:SetWidth(40)
    self.Health:SetPoint('TOPLEFT', self)
    self.Health:SetPoint('BOTTOMLEFT', self)
    self.Health:SetStatusBarTexture(texture)
    --self.Health:SetStatusBarColor(.15, .15, .15, .8)
    self.Health:SetStatusBarColor(0,0,0, .75)

    self.Health.frequentUpdates = true
    self.Health.Override = OverrideUpdateHealth

    self.health_bg = self.Health:CreateTexture(nil, 'BORDER')
    self.health_bg:SetAllPoints(self.Health)
    self.health_bg:SetTexture(texture)


    self.Power = CreateFrame('StatusBar', nil, self)
    self.Power:SetOrientation('VERTICAL')
    self.Power:SetStatusBarTexture(texture)

    self.Power.colorPower = true

    self.Power:SetPoint('TOPLEFT', self.Health, 'TOPRIGHT')
    self.Power:SetPoint'BOTTOMRIGHT'

    self.Power.bg = self.Power:CreateTexture(nil, 'BORDER')
    self.Power.bg:SetAllPoints(self.Power)
    self.Power.bg:SetTexture(texture)
    self.Power.bg.multiplier = .3

    self.centertext = self.Health:CreateFontString(nil, 'OVERLAY')
    self.centertext:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
    self.centertext:SetPoint('CENTER', self.Health, 1, 0)

    --[[local aggro = self.Health:CreateFontString(nil, 'OVERLAY')
    aggro:SetFont(STANDARD_TEXT_FONT, 36, 'OUTLINE')
    aggro:SetPoint('TOPLEFT', self.Health, 0, 22)
    self:Tag(aggro, '[leaf:threat]')]]

    if(class == 'DRUID') then
        setupDruidHots(self)
    end

    if leaf.HealComm then
        HealCommCreateBar(self)
    else
        self:Tag(self.centertext, '[leaf:raid]')
    end

    self.Range = {
        inRangeAlpha = 1,
        outsideRangeAlpha = .4,
    }

    if UnitGroupRolesAssigned and self:GetParent():GetName() == 'oUF_leaf_Group1' then
        self.LFDRole = self.Health:CreateTexture(nil, 'OVERLAY')
        self.LFDRole:SetPoint('TOPLEFT', self, 0, 0)
        self.LFDRole:SetHeight(12)
        self.LFDRole:SetWidth(12)
    end

    self.RaidIcon = self.Health:CreateTexture(nil, 'OVERLAY')
    self.RaidIcon:SetPoint('TOP', self, 0, 4)
    self.RaidIcon:SetHeight(12)
    self.RaidIcon:SetWidth(12)

    self.Leader = self.Health:CreateTexture(nil, 'OVERLAY')
    self.Leader:SetPoint('TOPLEFT', self, 0, 6)
    self.Leader:SetHeight(10)
    self.Leader:SetWidth(10)

    self.Assistant = self.Health:CreateTexture(nil, 'OVERLAY')
    self.Assistant:SetAllPoints(self.Leader)

    self.MasterLooter = self.Health:CreateTexture(nil, 'OVERLAY')
    self.MasterLooter:SetPoint('LEFT', self.Leader, 'RIGHT')
    self.MasterLooter:SetHeight(10)
    self.MasterLooter:SetWidth(10)

    self.ResurrectIcon = self.Health:CreateTexture(nil, 'OVERLAY')
    self.ResurrectIcon:SetPoint('TOP', self, 'CENTER', 0, -3)
    self.ResurrectIcon:SetHeight(10)
    self.ResurrectIcon:SetWidth(10)

    tinsert(self.__elements, leaf.updatemasterlooter)
    self:RegisterEvent('PARTY_LOOT_METHOD_CHANGED', leaf.updatemasterlooter)
    self:RegisterEvent('PARTY_MEMBERS_CHANGED', leaf.updatemasterlooter)
    self:RegisterEvent('PARTY_LEADER_CHANGED', leaf.updatemasterlooter)

    self.ReadyCheck = self.Health:CreateTexture(nil, 'OVERLAY')
    self.ReadyCheck:SetPoint('BOTTOM', self)
    self.ReadyCheck:SetHeight(12)
    self.ReadyCheck:SetWidth(12)

    self.Threat = CreateFrame('Frame', nil, self)
    self.Threat:SetPoint('TOPLEFT', self, 'TOPLEFT', -4, 4)
    self.Threat:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 4, -4)
    self.Threat:SetFrameStrata('LOW')
    self.Threat:SetBackdrop {
      edgeFile = glowTex, edgeSize = 5,
      insets = {left = 3, right = 3, top = 3, bottom = 3}
    }
    self.Threat:SetBackdropColor(0, 0, 0, 0)
    self.Threat:SetBackdropBorderColor(0, 0, 0, 1)  

    self.Threat.Override = OverrideThreatUpdate

    if(IsAddOnLoaded'oUF_RaidDebuffs') then
        self.RaidDebuffs = CreateFrame('Frame', nil, self)
        self.RaidDebuffs:SetHeight(18)
        self.RaidDebuffs:SetWidth(18)
        self.RaidDebuffs:SetPoint('CENTER', self)
        self.RaidDebuffs:SetFrameStrata'HIGH'

        self.RaidDebuffs:SetBackdrop(backdrop)

        self.RaidDebuffs.icon = self.RaidDebuffs:CreateTexture(nil, 'OVERLAY')
        self.RaidDebuffs.icon:SetTexCoord(.1,.9,.1,.9)
        self.RaidDebuffs.icon:SetAllPoints(self.RaidDebuffs)

        self.RaidDebuffs.cd = CreateFrame('Cooldown', nil, self.RaidDebuffs)
        self.RaidDebuffs.cd:SetAllPoints(self.RaidDebuffs)

        self.RaidDebuffs.ShowDispelableDebuff = true
        self.RaidDebuffs.FilterDispelableDebuff = true
        self.RaidDebuffs.MatchBySpellName = true
        self.RaidDebuffs.Debuffs = ns.raid_debuffs
        --self.RaidDebuffs.DispelPriority = {}
        --self.RaidDebuffs.DispelFilter = {}
        --self.RaidDebuffs.DispelColor = {}

        self.RaidDebuffs.count = self.RaidDebuffs:CreateFontString(nil, 'OVERLAY')
        self.RaidDebuffs.count:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE')
        self.RaidDebuffs.count:SetPoint('BOTTOMRIGHT', self.RaidDebuffs, 'BOTTOMRIGHT', 2, 0)
        self.RaidDebuffs.count:SetTextColor(1, .9, 0)
    end
end

oUF:RegisterStyle('leaf-Raid', setmetatable({
--  ['initial-height'] = 35,
--  ['initial-width'] = 45,
    ['style'] = 'raid',
}, {__call = styleFunc}))
oUF:SetActiveStyle'leaf-Raid'

local raid = {}
leaf.units.raid = raid

for i = 1, 8 do
    local group = oUF:SpawnHeader(
        'oUF_leaf_Group'..i, nil, nil,
        'groupFilter', tostring(i),
        'showRaid', true,
        'yOffset', -5,
        'showParty', i == 1,
        'showPlayer', i == 1,
        'showSolo', i == 1,
        'oUF-initialConfigFunction', [[
            self:SetHeight(35)
            self:SetWidth(45)
            self:SetAttribute('type3', 'menu')
            self:SetAttribute('*type2', nil)
        ]] .. ns.CLICKCAST_FUNC
        )
    group.SetManyAttributes = leaf.SetManyAttributes
    raid[i] = group
    group:SetScale(leaf.frameScale)

    if(i == 1) then
        group:SetPoint('BOTTOMRIGHT', UIParent, -10, 10)
    else
        group:SetPoint('BOTTOMRIGHT', raid[i-1], 'BOTTOMLEFT', -5, 0)
    end
end

-- just make it damn easy, crappy API
local f = CreateFrame'Frame'
f:RegisterEvent'PLAYER_ENTERING_WORLD'
f:SetScript('OnEvent', function(self, event, ...)
    if InCombatLockdown() then
        return self:RegisterEvent'PLAYER_REGEN_ENABLED'
    elseif self:IsEventRegistered'PLAYER_REGEN_ENABLED' then
        self:UnregisterEvent'PLAYER_REGEN_ENABLED'
    end

    local mod
    local inInstance, instanceType = IsInInstance()

    if instanceType == 'raid' then
        mod = 25
    else
        mod = 40
    end

    for i = 1, 8 do
        local header = raid[i]
        if i <= mod/5 then
            header:Show()
        else
            header:Hide()
        end
    end
end)

--[[
if leaf.test_mod then
    oUF:Spawn('player'):SetPoint('CENTER', UIParent)
    oUF:Spawn('target'):SetPoint('CENTER', UIParent,55,0)
end
]]
