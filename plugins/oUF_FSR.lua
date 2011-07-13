--[[
	Five-seconds-rule
	
	.FSR (frame)
	
	.FSR.Spark (texture)

]]

local _, ns = ...
local oUF = ns.oUF or oUF

if ns.leaf.nofsr then return end

local _,class = UnitClass'player'
if (class == 'DEATHKNIGHT') or (class == 'ROGUE') or (class == 'WARRIOR') then return end


local TOTAL = 5
local SHOW = true

local function OnUpdate(self,elps)
	spark = self.Spark
	self.duration = self.duration + elps
	
	
	if (not SHOW) or (self.duration >= TOTAL) then
		self:SetScript('OnUpdate', nil)
		spark:Hide()
	else
		local x = self.width*(self.duration/TOTAL)
		spark:SetPoint('CENTER', self, 'LEFT', x, 0)
	end
end

local function UPDATE_SHAPESHIFT_FORM()
	local powerType, powerTypeString = UnitPowerType('player')
	SHOW = powerTypeString == 'MANA'
end

local function Update(self, event, unit, spell, rank)
	if(self.unit == unit) and spell then
		if(class == 'DRUID') then
			UPDATE_SHAPESHIFT_FORM()
		end
		if (not SHOW) or (not spell) then return end
		
		local frame = self.FSR
		frame.duration = 0
		frame:SetScript('OnUpdate', OnUpdate)
		frame.Spark:Show()
	end
end

local function Enable(self, unit)
	local frame = self.FSR
	if frame and (unit == 'player') then
		local spark = frame.Spark
		spark:Hide()
		
		if not spark:GetTexture() then
			spark:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
		end
		
		self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', Update)
		
		if(class == 'DRUID') then
			self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', UPDATE_SHAPESHIFT_FORM)
			UPDATE_SHAPESHIFT_FORM()
		end
		return true
	end
end

local function Disable(self)
	local frame = self.FSR
	if frame then
		frame.Spark:Hide()
		
		frame:SetScript('OnUpdate', nil)
		self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', Update)
		if(class == 'DRUID') then
			self:UnregisterEvent('UPDATE_SHAPESHIFT_FORM', UPDATE_SHAPESHIFT_FORM)
		end
	end
end

oUF:AddElement('FSR', Update, Enable, Disable)
