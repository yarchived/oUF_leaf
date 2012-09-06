
local _, ns = ...
local oUF = ns.oUF or oUF
local leaf = ns.leaf

local class = leaf.class
local texture =  [[Interface\AddOns\oUF_leaf\media\Minimalist]] --[[Interface\AddOns\oUF_leaf\media\FlatSmooth]]
local bubbleTex = [[Interface\AddOns\oUF_leaf\media\bubbleTex]]
local backdrop = leaf.backdrop
local noop = function() end

local function PostCreateIcon(icons, button)
    button.icon:SetTexCoord(.1, .9, .1, .9)
    button.overlay:SetTexture([=[Interface\AddOns\oUF_leaf\media\SmartName]=])
    button.overlay:SetTexCoord(0, 1, 0, 1)
    button.overlay:SetPoint('TOPLEFT', button, -1, 1)
    button.overlay:SetPoint('BOTTOMRIGHT', button, 1, -1)
    --button.overlay:SetVertexColor(.25, .25, .25)
    button.overlay.SetVertexColor = noop
    button.overlay.Hide = noop
--  button:SetBackdrop(backdrop)
--  button:SetBackdropColor(0, 0, 0)

    local parent = button:GetParent()
    if parent.noTooltip then
        button:EnableMouse(false)
        button:SetScript('OnEnter', nil)
        button:SetScript('OnLeave', nil)
        button:SetScript('OnClick', nil)
    end
end

local is_mine = {player = true, vehicle = true, pet = true}
local function PostUpdateIcon(icons, unit, icon, index, offset)
    if icon.isDebuff then
        if (not is_mine[icon.owner]) and UnitIsEnemy('player', unit) then
            --icon:SetBackdropColor(0, 0, 0)
            icon.icon:SetDesaturated(true)
        else
            --local name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID = UnitAura(unit, index, filter)
            --local _,_,_,_, dtype = UnitAura(unit, index, filter)
            --local c = DebuffTypeColor[dtype] or DebuffTypeColor.none
            --icon:SetBackdropColor(c.r, c.g, c.b)
            icon.icon:SetDesaturated(false)
        end
    end
end

local function PlayerAuraCustomFilter(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID)
    return leaf.playerAuraFilter and leaf.playerAuraFilter[name]
end

local function CustomTimeText(self, duration)
    if self.casting then
        self.Time:SetFormattedText('%.1f / %.1f', (self.max - duration), self.max)
    elseif self.channeling then
        self.Time:SetFormattedText('%.1f / %.1f', duration, self.max)
    end
end

local function CustomDelayText(self, duration)
    if self.casting then
        self.Time:SetFormattedText("%.1f / %.1f |cffff0000-%.1f|r", (self.max - duration), self.max, self.delay)
    else
        self.Time:SetFormattedText("%.1f / %.1f |cffff0000-%.1f|r", duration, self.max, self.delay)
    end
end

local function PostCastStart(castbar, unit, name, rank, castid)
    if castbar.interrupt then
        castbar.Text:SetTextColor(1,0,0)
    else
        castbar.Text:SetTextColor(1,1,1)
    end
end

local function PLAYER_TARGET_CHANGED()
    if UnitExists('target') then
        if( UnitIsEnemy('target', 'player') ) then
            PlaySound('igCreatureAggroSelect')
        elseif( UnitIsFriend('player', 'target') ) then
            PlaySound('igCharacterNPCSelect')
        else
            PlaySound('igCreatureNeutralSelect')
        end
    else
        PlaySound('INTERFACESOUND_LOSTTARGETUNIT')
    end
end

local function styleFunc(settings, self, unit)
    local style = settings['style']

    if(settings['initial-height'] and settings['initial-width']) then
        self:SetHeight(settings['initial-height'])
        self:SetWidth(settings['initial-width'])
    end
    self.colors = leaf.colors

    if (unit == 'player') or (unit == 'pet') or (unit == 'target') or (unit == 'focus') then
        self.menu = leaf.menu
        self:RegisterForClicks('AnyUp')
        self:SetAttribute('type2', 'menu')
    end

    self:SetScript('OnEnter', UnitFrame_OnEnter)
    self:SetScript('OnLeave', UnitFrame_OnLeave)
    --self:SetScript('OnLeave', function(...) UnitFrame_OnLeave(...); GameTooltip:Hide() end)

    self:SetBackdrop(backdrop)
    self:SetBackdropColor(0, 0, 0, .6)

    self.Health = CreateFrame('StatusBar', nil, self)
    self.Health:SetPoint('TOPRIGHT', self)
    self.Health:SetPoint('TOPLEFT', self)
    self.Health:SetStatusBarTexture(texture)
    self.Health:SetStatusBarColor(.15,.15,.15)
    self.Health:SetHeight(17)
    self.Health.bg = self.Health:CreateTexture(nil, 'BORDER')
    self.Health.bg:SetAllPoints(self.Health)
    self.Health.bg:SetTexture(texture)
    self.Health.bg.multiplier = .3

    self.Health.colorSmooth = true
    self.Health.colorTapping = true
    self.Health.colorDisconnected = true

    self.Power = CreateFrame('StatusBar', nil, self)
    self.Power:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT')
    self.Power:SetPoint('BOTTOMRIGHT', self)
    self.Power:SetStatusBarTexture(texture)

    self.Power.bg = self.Power:CreateTexture(nil, 'BORDER')
    self.Power.bg:SetAllPoints(self.Power)
    self.Power.bg:SetTexture(texture)
    self.Power.bg.multiplier = .3

    self.Power.colorClass = true
    self.Power.colorReaction = true

    local tag1 = self.Health:CreateFontString(nil, 'OVERLAY')
    tag1:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
    tag1:SetPoint('LEFT', self.Health, 2, 0)
    local tag2 = self.Health:CreateFontString(nil, 'OVERLAY')
    tag2:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
    tag2:SetPoint('RIGHT', self.Health, -2, 0)

    if unit == 'target' or unit == 'player' then
        self:Tag(tag2, '|cff50a050[leaf:curhp] - [leaf:perhp]%')
        if unit == 'player' then
            tag1.frequentUpdates = .1
            self:Tag(tag1, '[leaf:colorpower][leaf:curpp] - [leaf:perpp]%')
        else
            self:Tag(tag1, '[leaf:raidcolor][leaf:name] [leaf:difficulty][leaf:smartlevel]|r')
        end
    else
        if unit == 'pet' then
            self:Tag(tag1, '[leaf:threatcolor][leaf:name]')
        else
            self:Tag(tag1, '[leaf:raidcolor][leaf:name]')
        end
        self:Tag(tag2, '|cff50a050[leaf:perhp]%')
    end

    if unit == 'player' or unit == 'target' then
        self.Health:SetHeight(20)
        self.Power:SetHeight(4)

        self.Health.frequentUpdates = true
        self.Power.frequentUpdates = true
    end

    if(unit == 'player' or unit == 'target' or unit == 'focus' or unit == 'pet') then
        self.Castbar = CreateFrame('StatusBar', nil, self)
        self.Castbar:SetStatusBarTexture(texture)
        self.Castbar:SetStatusBarColor(.15,.15,.15)

        self.Castbar:SetBackdrop(backdrop)
        self.Castbar:SetBackdropColor(.3, .3, .3, .7)

        self.Castbar.Text = self.Castbar:CreateFontString(nil, 'OVERLAY')
        self.Castbar.Text:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
        self.Castbar.Text:SetPoint('LEFT', self.Castbar, 2, 0)

        self.Castbar.Time = self.Castbar:CreateFontString(nil, 'OVERLAY')
        self.Castbar.Time:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
        self.Castbar.Time:SetPoint('RIGHT', self.Castbar, -2, 0)

        if unit == 'player' then
            self.Castbar:SetWidth(280)
            self.Castbar:SetHeight(16)

            self.Castbar.SafeZone = self.Castbar:CreateTexture(nil,'BORDER')
            self.Castbar.SafeZone:SetPoint('TOPRIGHT')
            self.Castbar.SafeZone:SetPoint('BOTTOMRIGHT')
            self.Castbar.SafeZone:SetTexture(texture)
            self.Castbar.SafeZone:SetVertexColor(.8, .2, .2)

            self.Castbar.CustomTimeText = CustomTimeText
            self.Castbar.CustomDelayText = CustomDelayText

            self.Castbar:SetPoint('CENTER', UIParent, 0, -180)
        elseif unit == 'focus' or unit == 'target' then
            self.PostChannelStart = PostCastStart
            self.PostCastStart = PostCastStart
            self.Castbar:SetWidth(160)
            self.Castbar:SetHeight(14)

            if unit == 'target' then
                self.Castbar:SetPoint('CENTER', UIParent, 85, -155)
            else
                self.Castbar:SetPoint('CENTER', UIParent, -85, -155)
            end
        else -- pet
            self.Castbar:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 5)
            self.Castbar:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, 5)
            self.Castbar:SetHeight(14)
        end

--      if unit == 'player' and class == 'HUNTER' then
--          self.Swing = CreateFrame('StatusBar', nil, self)
--          self.Swing:SetHeight(2)
--          self.Swing:SetPoint('BOTTOMLEFT', self.Castbar, 'TOPLEFT', 0, 1)
--          self.Swing:SetPoint('RIGHT', self.Castbar)

--          self.Swing:SetStatusBarTexture(texture)
--          self.Swing:SetStatusBarColor(.15,.15,.15)
--          self.Swing:SetBackdrop(backdrop)
--          self.Swing:SetBackdropColor(.15,.15,.15, .3)
--          self.Swing.disableMelee = true

--          self.Swing.Text = self.Swing:CreateFontString(nil, 'OVERLAY')
--          self.Swing.Text:SetFont(STANDARD_TEXT_FONT, 8, 'OUTLINE')
--          self.Swing.Text:SetPoint('TOPRIGHT', self.Swing, 'BOTTOMRIGHT', 0, -3)
--      end

        --[[self.MirrorBar = {}
        for i = 1, MIRRORTIMER_NUMTIMERS do
            self.MirrorBar[i] = CreateFrame('StatusBar', nil, UIParent)
            self.MirrorBar[i]:SetHeight(15)
            self.MirrorBar[i]:SetWidth(200)
            self.MirrorBar[i]:SetStatusBarTexture(texture)
            self.MirrorBar[i]:SetBackdrop(backdrop)
            self.MirrorBar[i]:SetBackdropColor(.5,.5,.5,.5)

            if i == 1 then
                self.MirrorBar[i]:SetPoint('TOP', UIParent, 0, -100)
            else
                self.MirrorBar[i]:SetPoint('TOP', self.MirrorBar[i-1], 'BOTTOM', 0, -5)
            end

            self.MirrorBar[i].Text = self.MirrorBar[i]:CreateFontString(nil, 'OVERLAY')
            self.MirrorBar[i].Text:SetFont(STANDARD_TEXT_FONT, 9, 'OUTLINE')
            self.MirrorBar[i].Text:SetPoint('CENTER', self.MirrorBar[i])

            self.MirrorBar[i].Time = self.MirrorBar[i]:CreateFontString(nil, 'OVERLAY')
            self.MirrorBar[i].Time:SetFont(STANDARD_TEXT_FONT, 9, 'OUTLINE')
            self.MirrorBar[i].Time:SetPoint('RIGHT', self.MirrorBar[i], -2, 0)
        end]]
    end

    if unit == 'pet' then
        self.Auras = CreateFrame('Frame', nil, self)
        self.Auras:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 5)
        self.Auras:SetHeight(22)
        self.Auras:SetWidth(190)
        self.Auras.size = 16
        self.Auras.spacing = 3
        self.Auras.gap = true
        self.Auras['growth-x'] = 'RIGHT'
        self.Auras['growth-y'] = 'UP'
        self.Auras.initialAnchor = 'BOTTOMLEFT'
        self.Auras.numBuffs = 17
        self.Auras.numDebuffs = 12
    elseif unit == 'targettarget' or unit == 'focus' then
        self.Debuffs = CreateFrame('Frame', nil, self)
        self.Debuffs:SetHeight(20)
        self.Debuffs:SetWidth(200)
        self.Debuffs.size = 20
        self.Debuffs.spacing = 4
        self.Debuffs.num = 2

        if unit == 'focus' then
            self.Debuffs.initialAnchor = 'TOPLEFT'
            self.Debuffs['growth-x'] = 'RIGHT'
            self.Debuffs:SetPoint('TOPLEFT', self, 'TOPRIGHT', 4, 0)
        else
            self.Debuffs.initialAnchor = 'TOPRIGHT'
            self.Debuffs['growth-x'] = 'LEFT'
            self.Debuffs:SetPoint('TOPRIGHT', self, 'TOPLEFT', -4, 0)
        end
    elseif unit == 'target' then
        self.Buffs = CreateFrame('Frame', nil, self)
        self.Buffs:SetPoint('TOPLEFT', self, 'TOPRIGHT', 5, 0)
        self.Buffs:SetHeight(22)
        self.Buffs:SetWidth(230)
        self.Buffs.size = 20
        self.Buffs.spacing = 3
        self.Buffs.initialAnchor = 'TOPLEFT'
        self.Buffs['growth-x'] = 'RIGHT'
        self.Buffs['growth-y'] = 'DOWN'

        self.Debuffs = CreateFrame('Frame', nil, self)
        self.Debuffs:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 5)
        self.Debuffs:SetHeight(22)
        self.Debuffs:SetWidth(230)
        self.Debuffs.size = 20
        self.Debuffs.spacing = 3
        self.Debuffs.initialAnchor = 'BOTTOMLEFT'
        self.Debuffs['growth-x'] = 'RIGHT'
        self.Debuffs['growth-y'] = 'UP'

        self.Debuffs.PostUpdateIcon = PostUpdateIcon

        self.QuestIcon = self.Health:CreateTexture(nil, 'OVERLAY')
        self.QuestIcon:SetHeight(14)
        self.QuestIcon:SetHeight(14)
        self.QuestIcon:SetPoint('CENTER', self, 'TOPLEFT')

        if(leaf.AuraWatch) then
            local iconSize = leaf.AuraWatchIconSize
            self.Auras = CreateFrame('Frame', nil, self)
            self.Auras:SetPoint('BOTTOMRIGHT', leaf.units.player.Auras, 'TOPRIGHT', 0, 5)
            self.Auras:SetHeight(iconSize)
            self.Auras:SetWidth((iconSize+4+.5)*8)
            self.Auras.size = iconSize
            self.Auras.initialAnchor = 'BOTTOMRIGHT'
            self.Auras['growth-x'] = 'LEFT'
            self.Auras['growth-y'] = 'UP'
            self.Auras.spacing = 4
            self.Auras.onlyShowPlayer = true
            self.Auras.numBuffs = 0
            self.Auras.numDebuffs = 8

            self.Auras.noTooltip = true
        end
        --[==[
        self.CPoints.PostUpdate = function() end

        local bg = [[Interface\ComboFrame\ComboFrameBackground]]

        ]==]

    elseif unit == 'player' then
        if(leaf.AuraWatch) then
            local iconSize = leaf.AuraWatchIconSize

            self.Auras = CreateFrame('Frame', nil, self)
            self.Auras:SetPoint('TOPRIGHT', self, 'TOPRIGHT', 0, 150)
            self.Auras:SetHeight(iconSize)
            self.Auras:SetWidth((iconSize+4+.5)*8)
            self.Auras.size = iconSize
            self.Auras.spacing = 4
            self.Auras.initialAnchor = 'BOTTOMRIGHT'
            self.Auras['growth-x'] = 'LEFT'
            self.Auras['growth-y'] = 'UP'
            self.Auras.numBuffs = 8
            self.Auras.numDebuffs = 0

            self.Auras.noTooltip = true

            self.Auras.CustomFilter = leaf.PlayerAuraCustomFilter
        end

        self.Leader = self.Health:CreateTexture(nil, 'OVERLAY')
        self.Leader:SetPoint('TOPLEFT', self, 0, 8)
        self.Leader:SetHeight(12)
        self.Leader:SetWidth(12)

        self.Assistant = self.Health:CreateTexture(nil, 'OVERLAY')
        self.Assistant:SetAllPoints(self.Leader)

        self.MasterLooter = self.Health:CreateTexture(nil, 'OVERLAY')
        self.MasterLooter:SetPoint('LEFT', self.Leader, 'RIGHT')
        self.MasterLooter:SetHeight(12)
        self.MasterLooter:SetWidth(12)

        table.insert(self.__elements, leaf.updatemasterlooter)
        self:RegisterEvent('PARTY_LOOT_METHOD_CHANGED', leaf.updatemasterlooter)
        self:RegisterEvent('PARTY_MEMBERS_CHANGED', leaf.updatemasterlooter)
        self:RegisterEvent('PARTY_LEADER_CHANGED', leaf.updatemasterlooter)

        if UnitLevel'player' ~= MAX_PLAYER_LEVEL then
            self.Resting = self.Health:CreateTexture(nil, 'OVERLAY')
            self.Resting:SetHeight(14)
            self.Resting:SetWidth(14)
            self.Resting:SetPoint('CENTER', self, 'BOTTOMLEFT')
            self.Resting:SetTexture[[Interface\CharacterFrame\UI-StateIcon]]
            self.Resting:SetTexCoord(.08, .41, .08, 0.41)
        end

        self.Combat = self.Health:CreateTexture(nil, 'OVERLAY')
        self.Combat:SetHeight(14)
        self.Combat:SetWidth(14)
        self.Combat:SetPoint('CENTER', self, 'BOTTOMLEFT')
        self.Combat:SetTexture('Interface\\CharacterFrame\\UI-StateIcon')
        self.Combat:SetTexCoord(0.58, 0.90, 0.08, 0.41)

        self.threatpct = self.Health:CreateFontString(nil, 'OVERLAY')
        self.threatpct:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
        self.threatpct:SetPoint('CENTER', self.Health, 0, 1)
        self.threatpct:SetJustifyV('CENTER')
        self.threatpct:SetJustifyH('MIDDLE')
        self.threatpct.frequentUpdates = .2
        self:Tag(self.threatpct, '[leaf:threatpct]')

        if(class == 'DRUID') then
            --local druidPower = self.Health:CreateFontString(nil, 'OVERLAY')
            --druidPower:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
            --druidPower:SetPoint('BOTTOM', self.Power)
            --self:Tag(druidPower, '[leaf:druidpower]')

            local manaBar = CreateFrame('StatusBar', nil, self)
            manaBar:SetStatusBarTexture(texture)
            manaBar:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 6)
            manaBar:SetPoint('RIGHT', self)
            manaBar:SetHeight(4)

            --manaBar.colorClass = true
            manaBar.frequentUpdates = true

            manaBar.bg = manaBar:CreateTexture(nil, 'BORDER')
            manaBar.bg:SetAllPoints(manaBar)
            manaBar.bg:SetTexture(texture)

            local r, g, b = unpack(self.colors.class[class])
            manaBar:SetStatusBarColor(r, g, b)
            manaBar.bg:SetVertexColor(r*.3, g*.3, b*.3)
            self.DruidMana = manaBar


            local lunarBar = CreateFrame('StatusBar', nil, self)
            local solarBar = CreateFrame('StatusBar', nil, self)
            lunarBar.color = { 0, .6, .8 }
            solarBar.color = { 1, .8, 0 }

            for _, bar in next, { lunarBar, solarBar } do
                bar:SetStatusBarTexture(texture)
                bar:SetHeight(4)
                bar:SetWidth(settings['initial-width'] / 2)

                bar.bg = bar:CreateTexture(nil, 'BORDER')
                bar.bg:SetAllPoints(bar)
                bar.bg:SetTexture(texture)

                local r, g, b = unpack(bar.color)
                bar:SetStatusBarColor(r, g, b)
                bar.bg:SetVertexColor(r*.3, g*.3, b*.3)
            end

            lunarBar:SetPoint('TOPLEFT', self.DruidMana)
            solarBar:SetPoint('LEFT', lunarBar, 'RIGHT')

            self.EclipseBar = {
                LunarBar = lunarBar,
                SolarBar = solarBar,
                Hide = function()
                    lunarBar:Hide()
                    solarBar:Hide()
                end,
                Show = function()
                    lunarBar:Show()
                    solarBar:Show()
                end,
            }
        end
    end

    if( ( class == 'MONK' or class == 'PALADIN' or class == 'PRIEST' or class == 'WARLOCK' )
        and unit == 'player' ) or ( unit == 'target' ) then
        local cpoints = {}
        for i = 1, 5 do
            cpoints[i] = self.Power:CreateTexture(nil, 'OVERLAY')
            cpoints[i]:SetHeight(8)
            cpoints[i]:SetWidth(8)
            cpoints[i]:SetTexture(bubbleTex)
            if i == 1 then
                cpoints[i]:SetPoint('BOTTOMLEFT', unit == 'player' and 5 or 1, 0)
            else
                cpoints[i]:SetPoint('LEFT', cpoints[i-1], 'RIGHT', 1)
            end
        end

        cpoints[1]:SetVertexColor(0.69, 0.31, 0.31)
        cpoints[2]:SetVertexColor(0.69, 0.31, 0.31)
        cpoints[3]:SetVertexColor(0.65, 0.63, 0.35)
        cpoints[4]:SetVertexColor(0.65, 0.63, 0.35)
        cpoints[5]:SetVertexColor(0.33, 0.59, 0.33)

        cpoints.UpdateTexture = function() end
        self.ClassIcons = cpoints
    end

    self.RaidIcon = self.Health:CreateTexture(nil, 'OVERLAY')
    self.RaidIcon:SetPoint('TOP', self, 0, 8)
    self.RaidIcon:SetHeight(16)
    self.RaidIcon:SetWidth(16)

    if (unit=='player' or unit=='pet' or unit=='target') then
        self.Health.SmoothUpdate = true
        self.Power.SmoothUpdate = true
    end

    if (unit == 'pet') or (unit == 'player') then
        self.BarFader = true
        self.BarFaderAlpha = .4
    end

    if (unit ~= 'player') then
        self.Range = leaf.Range
    end

    if unit == 'player' then
        self:RegisterEvent('PLAYER_TARGET_CHANGED', PLAYER_TARGET_CHANGED)
    end

    self.ignoreHealComm = true

    for _, v in next, {'Buffs', 'Debuffs', 'Auras'} do
        local containor = self[v]
        if containor then
            containor.PostCreateIcon = PostCreateIcon
        end
    end

    return self
end

oUF:RegisterStyle('leaf-Nomarl', setmetatable({
    ['initial-height'] = 24,
    ['initial-width'] = 230,
    ['style'] = 'normal',
}, {__call = styleFunc}))
oUF:RegisterStyle('leaf-Pet', setmetatable({
    ['initial-height'] = 20,
    ['initial-width'] = 190,
    ['style'] = 'pet',
}, {__call = styleFunc}))
oUF:RegisterStyle('leaf-Tiny', setmetatable({
    ['initial-height'] = 20,
    ['initial-width'] = 180,
    ['style'] = 'tiny',
}, {__call = styleFunc}))
oUF:RegisterStyle('leaf-Tank', setmetatable({
--  ['initial-height'] = 20,
--  ['initial-width'] = 130,
    ['style'] = 'tank',
}, {__call = styleFunc}))
oUF:RegisterStyle('leaf-Boss', setmetatable({
    ['initial-height'] = 20,
    ['initial-width'] = 130,
    ['style'] = 'boss',
}, {__call = styleFunc}))

if(leaf.nouf) then return end

local units = leaf.units

local xoffset, yoffset = 300, -130
oUF:SetActiveStyle'leaf-Nomarl'
local player = oUF:Spawn('player', 'oUF_leaf_Player')
player:SetPoint('CENTER', UIParent, -xoffset, yoffset)
units.player = player

units.target = oUF:Spawn('target', 'oUF_leaf_Target')
units.target:SetPoint('CENTER', UIParent, xoffset, yoffset)

oUF:SetActiveStyle'leaf-Tiny'
units.tot = oUF:Spawn('targettarget', 'oUF_leaf_ToT')
units.tot:SetPoint('TOPRIGHT', units.target, 'BOTTOMRIGHT', 0, -5)

units.focus = oUF:Spawn('focus', 'oUF_leaf_Focus')
units.focus:SetPoint('TOPLEFT', units.player, 'BOTTOMLEFT', 0, -5)

oUF:SetActiveStyle'leaf-Pet'
units.pet = oUF:Spawn('pet', 'oUF_leaf_Pet')
units.pet:SetPoint('BOTTOMLEFT', units.player, 'TOPLEFT', 0, 5)

units.player:SetScale(leaf.frameScale)
units.target:SetScale(leaf.frameScale)
units.tot:SetScale(leaf.frameScale)
units.focus:SetScale(leaf.frameScale)
units.pet:SetScale(leaf.frameScale)

