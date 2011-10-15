
local _, ns = ...
local oUF = ns.oUF or oUF
local leaf = ns.leaf

local curve1 = [[Interface\AddOns\oUF_leaf\media\curve1]]
local curve2 = [[Interface\AddOns\oUF_leaf\media\curve2]]

local xOffset, yOffset = 170, -50
local width, height = 100, 200
local GAP = 15

local function SetMinMaxValues(self, min, max)
    self.maxvalue = max
    self.minvalue = min
end

local function GetMinMaxValues(self)
    return self.maxvalue or 0, self.minvalue or 0
end

local function SetValue(self, value)
    self.value = value

    local perc = (self.maxvalue==0) and 0 or value/(self.maxvalue-self.minvalue)
    self.tex:SetTexCoord(self.flip and 1 or 0, self.flip and 0 or 1, 1-perc, 1)
    self.tex:SetHeight(perc * self.height)
    --print('value', value, 'max', self.maxvalue, 'perc', perc, 'height', self.height)
end

local function GetValue(self)
    return self.value or 0
end

local function SetHeight(self, height)
    if(height) then
        self.height = height
    end
end

local function SetWidth(self, width)
    if(width) then
        self.width = width
    end
end

local function SetStatusBarColor(self, r, g, b)
    self.tex:SetVertexColor(r, g, b)
end

local function setupStatusbar(self, texture)
    local tex = self:CreateTexture(nil, 'BACKGROUND')
    tex:SetBlendMode('BLEND')
    tex:SetTexture(texture)
    --tex:SetAllPoints(self)
    tex:SetPoint'BOTTOMLEFT'
    tex:SetPoint'BOTTOMRIGHT'

    --self:SetStatusBarTexture(tex)
    self.tex = tex

    self.SetMinMaxValues = SetMinMaxValues
    self.GetMinMaxValues = GetMinMaxValues
    self.SetValue = SetValue
    self.GetValue = GetValue
    self.SetStatusBarColor = SetStatusBarColor

    hooksecurefunc(self, 'SetHeight', SetHeight)
    hooksecurefunc(self, 'SetWidth', SetWidth)
    self.width = self:GetWidth()
    self.height = self:GetHeight()
end

local function styleFunc(self, unit)
    self.Health = CreateFrame('Frame', nil, self)
    self.Health.flip = unit == 'player'
    self.Health.frequentUpdates = true
    self.Health.colorSmooth = true

    self.Health:SetWidth(width)
    self.Health:SetHeight(height)

    if self.Health.flip then
        self.Health:SetPoint('CENTER', UIParent, - xOffset, yOffset)
    else
        self.Health:SetPoint('CENTER', UIParent, xOffset, yOffset)
    end

    setupStatusbar(self.Health, curve1)

    local healthbg = self.Health:CreateTexture(nil, 'BORDER')
    healthbg:SetAllPoints(self.Health)
    healthbg:SetTexture(curve1)
    if self.Health.flip then
        healthbg:SetTexCoord(1,0,0,1)
    end
    healthbg:SetAlpha(.3)

    self.Power = CreateFrame('Frame', nil, self)
    self.Power.flip = unit == 'player'
    self.Power.frequentUpdates = true
    self.Power.colorPower = true

    self.Power:SetWidth(width)
    self.Power:SetHeight(height)
    if self.Power.flip then
        self.Power:SetPoint('CENTER', UIParent, - xOffset - GAP, yOffset)
    else
        self.Power:SetPoint('CENTER', UIParent, xOffset + GAP, yOffset)
    end

    setupStatusbar(self.Power, curve2)

    local powerbg = self.Power:CreateTexture(nil, 'BORDER')
    powerbg:SetAllPoints(self.Power)
    powerbg:SetTexture(curve2)
    if self.Power.flip then
        powerbg:SetTexCoord(1,0,0,1)
    end
    powerbg:SetAlpha(.3)

    --local mp = self.Power:CreateFontString(nil, 'OVERLAY')
    --mp:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
    --if unit == 'player' then
    --    mp.frequentUpdates = 0.1
    --    mp:SetPoint('BOTTOMRIGHT', self.Health, 'BOTTOMRIGHT', -5, 15)
    --else
    --    mp:SetPoint('BOTTOMLEFT', self.Health, 'BOTTOMLEFT', 5, 15)
    --end
    --self:Tag(mp, '[leaf:colorpower][leaf:perpp]')

    --local hp = self.Health:CreateFontString(nil, 'OVERLAY')
    --hp:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
    ----hp.frequentUpdates = 0.5
    --hp:SetPoint('BOTTOM', mp, 'TOP', 0, 5)
    --self:Tag(hp, '|cff50a050[leaf:perhp]')

    if unit == 'target' then
        self.SpellRange = .5
        self.inRangeAlpha = 1
        self.outsideRangeAlpha = .4
    else
        self.Health.SmoothUpdate = true
        self.BarFade = true

        self.combo = self.Health:CreateFontString(nil, 'ARTWORK')
        self.combo:SetFont(DAMAGE_TEXT_FONT, 40, 'OUTLINE')
        self.combo:SetPoint('CENTER', UIParent, 0, yOffset - height/2)
        self:Tag(self.combo, '[leaf:cp]')
    end

    --self:SetAttribute('initial-height', 0.000001)
    --self:SetAttribute('initial-width', 0.000001)
end

oUF:RegisterStyle('leaf-hud', styleFunc)
oUF:SetActiveStyle'leaf-hud'

oUF:Spawn('player')
oUF:Spawn('target')
