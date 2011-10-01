
local _, ns = ...
local oUF = ns.oUF or oUF
local leaf = ns.leaf

local curve1 = [[Interface\AddOns\oUF_leaf\media\curve1]]
local curve2 = [[Interface\AddOns\oUF_leaf\media\curve2]]

local xOffset, yOffset = 140, -50
local width, heigh = 100, 200
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
	self.tex:SetTexCoord(self.left and 1 or 0, self.left and 0 or 1, self.maxvalue == 0 and 1 or (1-value/self.maxvalue), 1)
end

local function GetValue(self)
	return self.value or 0
end

local function setupStatusbar(self, texture)
	local tex = self:CreateTexture(nil, 'BACKGROUND')
	tex:SetBlendMode('BLEND')
	tex:SetTexture(texture)
	tex:SetAllPoints(self)
	
	self:SetStatusBarTexture(tex)
	self.tex = tex
	
	self.SetMinMaxValues = SetMinMaxValues
	self.GetMinMaxValues = GetMinMaxValues
	self.SetValue = SetValue
	self.GetValue = GetValue
end

local function styleFunc(self, unit)
	self.Health = CreateFrame('StatusBar', nil, self)
	self.Health.left = unit == 'player'
	self.Health.frequentUpdates = true
	self.Health.colorSmooth = true
	
	self.Health:SetWidth(width)
	self.Health:SetHeight(heigh)
	
	if self.Health.left then
		self.Health:SetPoint('CENTER', UIParent, - xOffset, yOffset)
	else
		self.Health:SetPoint('CENTER', UIParent, xOffset, yOffset)
	end
	
	setupStatusbar(self.Health, curve1)
	
	local healthbg = self.Health:CreateTexture(nil, 'BORDER')
	healthbg:SetAllPoints(self.Health)
	healthbg:SetTexture(curve1)
	if self.Health.left then
		healthbg:SetTexCoord(1,0,0,1)
	end
	healthbg:SetAlpha(.3)
	
	self.Power = CreateFrame('StatusBar', nil, self)
	self.Power.left = unit == 'player'
	self.Power.frequentUpdates = true
	self.Power.colorPower = true
	
	self.Power:SetWidth(width)
	self.Power:SetHeight(heigh)
	if self.Power.left then
		self.Power:SetPoint('CENTER', UIParent, - xOffset - GAP, yOffset)
	else
		self.Power:SetPoint('CENTER', UIParent, xOffset + GAP, yOffset)
	end
	
	setupStatusbar(self.Power, curve2)
	
	local powerbg = self.Power:CreateTexture(nil, 'BORDER')
	powerbg:SetAllPoints(self.Power)
	powerbg:SetTexture(curve2)
	if self.Power.left then
		powerbg:SetTexCoord(1,0,0,1)
	end
	powerbg:SetAlpha(.3)
	
	local mp = self.Power:CreateFontString(nil, 'OVERLAY')
	mp:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
	if unit == 'player' then
		mp.frequentUpdates = 0.1
		mp:SetPoint('BOTTOMRIGHT', self.Health, 'BOTTOMRIGHT', -5, 15)
	else
		mp:SetPoint('BOTTOMLEFT', self.Health, 'BOTTOMLEFT', 5, 15)
	end
	self:Tag(mp, '[leaf:colorpower][leaf:perpp]')
	
	local hp = self.Health:CreateFontString(nil, 'OVERLAY')
	hp:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
	--hp.frequentUpdates = 0.5
	hp:SetPoint('BOTTOM', mp, 'TOP', 0, 5)
	self:Tag(hp, '|cff50a050[leaf:perhp]')
	
	self.ignoreHealComm = true
	
	if unit == 'target' then
		self.SpellRange = .5
		self.inRangeAlpha = 1
		self.outsideRangeAlpha = .4
	else
		self.Health.SmoothUpdate = true
		self.BarFade = true
	end
	
	--self:SetAttribute('initial-height', 0.000001)
	--self:SetAttribute('initial-width', 0.000001)
	
end

oUF:RegisterStyle('leafHud', styleFunc)
oUF:SetActiveStyle'leafHud'

oUF:Spawn('player')
oUF:Spawn('target')
