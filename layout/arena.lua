
local _, ns = ...
local oUF = ns.oUF or oUF
local leaf = ns.leaf

if leaf.noarena then return end

local texture = [=[Interface\AddOns\oUF_leaf\media\FlatSmooth]=]

local function CustomTimeText(self, duration)
    if self.casting then
        self.Time:SetFormattedText('%.1f', self.max - duration)
    elseif self.channeling then
        self.Time:SetFormattedText('%.1f', duration)
    end
end


local debuff_data = {
}


local function styleFunc(settings, self, unit)
    self.colors = leaf.colors
    self:SetScript('OnEnter', UnitFrame_OnEnter)
    self:SetScript('OnLeave', UnitFrame_OnLeave)
    self:SetBackdrop(leaf.backdrop)
    self:SetBackdropColor(0, 0, 0, .6)
    self:SetAttribute('initial-height', settings['initial-height'])
    self:SetAttribute('initial-width', settings['initial-width'])

    self.Health = CreateFrame('StatusBar', nil, self)
    self.Health:SetPoint('TOPRIGHT', self)
    self.Health:SetPoint('TOPLEFT', self)
    self.Health:SetStatusBarTexture(texture)
    self.Health:SetHeight(20)

    self.Health.frequentUpdates = true
    self.Health.colorClass = true
    self.Health.colorClassPet = true
    self.Health.colorDisconnected = true

    self.Health.bg = self.Health:CreateTexture(nil, 'BORDER')
    self.Health.bg:SetAllPoints(self.Health)
    self.Health.bg:SetTexture(texture)
    self.Health.bg:SetAlpha(.5)
    self.Health.bg.multiplier = .3

    self.Power = CreateFrame('StatusBar', nil, self)
    self.Power:SetStatusBarTexture(texture)

    self.Power.frequentUpdates = true
    self.Power.colorPower = true

    self.Power.bg = self.Power:CreateTexture(nil, 'BORDER')
    self.Power.bg:SetAllPoints(self.Power)
    self.Power.bg:SetTexture(texture)
    self.Power.bg:SetAlpha(.5)
    self.Power.bg.multiplier = .3

    self.RaidIcon = self.Health:CreateTexture(nil, 'OVERLAY')
    self.RaidIcon:SetPoint('TOP', self, 0, 8)
    self.RaidIcon:SetHeight(16)
    self.RaidIcon:SetWidth(16)

    self.SpellRange = .5
    self.inRangeAlpha = 1
    self.outsideRangeAlpha = .4

    local tag1 = self.Health:CreateFontString(nil, 'OVERLAY')
    tag1:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
    tag1:SetPoint('RIGHT', self.Health, -2, 0)
    self:Tag(tag1, '|cff50a050[leaf:perhp]|r%')

    if settings.style ~= 'pet' then
        local tag2 = self.Health:CreateFontString(nil, 'OVERLAY')
        tag2:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
        tag2:SetPoint('LEFT', self.Health, 2, 0)
        self:Tag(tag2, '[leaf:perhp]')
    end

    if settings.style == 'pet' then
        self.Health:SetHeight(9)
        self.Power:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT')
        self.Power:SetPoint('BOTTOMRIGHT', self)
    elseif settings.style == 'target' then
        self.Health:SetHeight(19)
        self.Power:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT')
        self.Power:SetPoint('BOTTOMRIGHT', self)
    elseif settings.style == 'normal' then
        self.Power:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT')
        self.Power:SetPoint('RIGHT', self)
        self.Power:SetHeight(7)

        --[[self.Buffs = CreateFrame('Frame', nil, self)
        self.Buffs:SetHeight(20)
        self.Buffs:SetWidth(20)
        self.Buffs:SetPoint('TOPRIGHT', self, 'TOPLEFT', 2, 0)
        self.Buffs.num = 1
        self.Buffs.size = settings['initial-height']
        self.Buffs.initialAnchor = 'TOPRIGHT'
        self.Buffs['growth-x'] = 'LEFT'

        self.Debuffs = CreateFrame('Frame', nil, self)
        self.Debuffs:SetHeight(20)
        self.Debuffs:SetWidth(20)
        self.Debuffs:SetPoint('TOPRIGHT', self, 'TOPLEFT', 2, 0)
        self.Debuffs.num = 1
        self.Debuffs.size = settings['initial-height']
        self.Debuffs.initialAnchor = 'TOPRIGHT'
        self.Debuffs['growth-x'] = 'LEFT'

        self.CustomAuraFilter = CustomAuraFilter
        self.PostCreateAuraIcon = PostCreateAuraIcon]]

        self.RaidDebuffs = CreateFrame('Frame', nil, self)
        self.RaidDebuffs:SetHeight(20)
        self.RaidDebuffs:SetWidth(20)
        self.RaidDebuffs:SetPoint('TOPRIGHT', self, 'TOPLEFT', 2, 0)
        self.RaidDebuffs:SetFrameStrata'HIGH'

        self.RaidDebuffs:SetBackdrop(backdrop)
        self.RaidDebuffs.icon = self.RaidDebuffs:CreateTexture(nil, 'OVERLAY')
        self.RaidDebuffs.icon:SetTexCoord(.1, .9, .1, .9)
        self.RaidDebuffs.icon:SetAllPoints(self.RaidDebuffs)

        self.RaidDebuffs.cd = CreateFrame('Cooldown', nil, self.RaidDebuffs)
        self.RaidDebuffs.cd:SetAllPoints(self.RaidDebuffs)

        self.RaidDebuffs.MatchBySpellName = true
        self.RaidDebuffs.Debuffs = debuff_data

        self.Castbar = CreateFrame('StatusBar', nil, self)
        self.Castbar:SetStatusBarTexture(texture)
        self.Castbar:SetStatusBarColor(1,.8,0)

        self.Castbar:SetPoint('TOPLEFT', self.Power, 'BOTTOMLEFT')
        self.Castbar:SetPoint('BOTTOMRIGHT', self)

        self.Castbar.Icon = self.Castbar:CreateTexture(nil, 'ARTWORK')
        self.Castbar.Icon:SetHeight(settings['initial-height'])
        self.Castbar.Icon:SetWidth(settings['initial-height'])
        self.Castbar.Icon:SetPoint('TOPRIGHT', self, 'TOPLEFT', -2, 0)
        self.Castbar.Icon:SetTexCoord(.1,.9,.1,.9)

        self.Castbar.Text = self.Castbar:CreateFontString(nil, 'OVERLAY')
        self.Castbar.Text:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
        self.Castbar.Text:SetPoint('LEFT', self.Castbar, 2, 0)

        self.Castbar.Time = self.Castbar:CreateFontString(nil, 'OVERLAY')
        self.Castbar.Time:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
        self.Castbar.Time:SetPoint('RIGHT', self.Castbar, -2, 0)

        self.Castbar.CustomTimeText = CustomTimeText
    end

    self.ignoreHealComm = true
end

oUF:RegisterStyle('leafArena', setmetatable({
    ['initial-width'] = 180,
    ['initial-height'] = 40,
    ['style'] = 'normal',
}, {__call = styleFunc}))

oUF:RegisterStyle('leafArena - pet', setmetatable({
    ['initial-width'] = 120,
    ['initial-height'] = 12,
    ['style'] = 'pet',
}, {__call = styleFunc}))

oUF:RegisterStyle('leafArena - target', setmetatable({
    ['initial-width'] = 120,
    ['initial-height'] = 23,
    ['style'] = 'target',
}, {__call = styleFunc}))

if leaf.test_mod then
    oUF:SetActiveStyle'leafArena'
    local player = oUF:Spawn'player'
    player:SetPoint('TOPRIGHT', UIParent, 'BOTTOMRIGHT', -200, 230)

    oUF:SetActiveStyle'leafArena - pet'
    local pet = oUF:Spawn'player'
    pet:SetPoint('BOTTOMLEFT', player, 'BOTTOMRIGHT', 5, 0)

    oUF:SetActiveStyle'leafArena - target'
    local target = oUF:Spawn'player'
    target:SetPoint('TOPLEFT', player, 'TOPRIGHT', 5, 0)
end

local f = CreateFrame'Frame'
f:RegisterEvent'PLAYER_ENTERING_WORLD'
f:SetScript('OnEvent', function(self)
    local isIn, instanceType = IsInInstance()
    if instanceType ~= 'arena' then return end

    self:UnregisterAllEvents()
    self:SetScript('OnEvent', nil)

    SetCVar('showArenaEnemyFrames', '0')

    if ArenaEnemyFrames then
        ArenaEnemyFrames:UnregisterAllEvents()
        ArenaEnemyFrames:Hide()

        hooksecurefunc('ArenaEnemyFrame_OnLoad', function(self) self:UnregisterAllEvents() end)
        hooksecurefunc('ArenaEnemyPetFrame_OnLoad', function(self) self:UnregisterAllEvents() end)
    end

    local arenas = {}

    oUF:SetActiveStyle('leafArena')
    for i = 1, 5 do
        local unit = 'arena' .. i
        local frame = oUF:Spawn(unit)
        arenas[unit] = frame

        if i == 1 then
            frame:SetPoint('TOPRIGHT', UIParent, 'BOTTOMRIGHT', -200, 230)
        else
            frame:SetPoint('TOPLEFT', arenas['arena' .. (i - 1)], 'BOTTOMLEFT', 0, -5)
        end
    end

    oUF:SetActiveStyle('leafArena - target')
    for i = 1, 5 do
        local unit = 'arena' .. i .. 'target'
        local frame = oUF:Spawn(unit)
        arenas[unit] = frame
        frame:SetPoint('TOPLEFT', arenas['arena' .. i], 'TOPRIGHT', 5, 0)
    end

    oUF:SetActiveStyle('leafArena - pet')
    for i = 1, 5 do
        local unit = 'arenapet' .. i
        local frame = oUF:Spawn(unit)
        arenas[unit] = frame
        frame:SetPoint('BOTTOMLEFT', arenas['arena' .. i], 'BOTTOMRIGHT', 5, 0)
    end



    leaf.units.arenas = {}
    for i = 1, 5 do
        oUF:SetActiveStyle('leafArena')
        local f = oUF:Spawn('arena'..i)
        oUF:SetActiveStyle('leafArena - target')
        local t = oUF:Spawn('arena' .. i .. 'target')
        oUF:SetActiveStyle('leafArena - pet')
        local p = oUF:Spawn('arenapet' .. i)

        leaf.units.arenas['arena' .. i] = f
        leaf.units.arenas['arena'..i..'target'] = t
        leaf.units.arenas['arenapet'..i] = p

        f:SetScale(leaf.frameScale)
        t:SetScale(leaf.frameScale)
        p:SetScale(leaf.frameScale)

        if(i==1) then
            f:SetPoint('TOPRIGHT', UIParent, 'BOTTOMRIGHT', -200, 230)
        else
            f:SetPoint('TOPLEFT', leaf.units.arenas['arena'..(i-1)], 'BOTTOMLEFT', 0, -5)
        end

        t:SetPoint('TOPLEFT', f, 'TOPRIGHT', 5, 0)
        p:SetPoint('BOTTOMLEFT', f, 'BOTTOMRIGHT', 5, 0)
    end
end)
