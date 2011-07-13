local _, ns = ...
local oUF = ns.oUF or oUF

if ns.leaf.nogcd then return end

local function OnUpdate(self, elapsed)
	self.duration = self.duration + elapsed
	if self.duration >= self.max then
		self:Hide()
	else
		self:SetValue(self.duration)
	end
end

local function Update(self, event, unit, spell, spellrank)
	if (self.unit ~= unit) or (not spell) then return end
	local startTime, duration = GetSpellCooldown(spell)
	if duration and duration > 0 and duration <= 1.5 then
		local bar = self.GCDBar
		bar.max = duration
		bar:SetMinMaxValues(0, duration)
		bar:SetValue(0)
		bar.duration = 0
		bar:Show()
	end
end

local function Enable(self, unit)
	local bar = self.GCDBar
	if bar and (unit == 'player') then
		self:RegisterEvent('UNIT_SPELLCAST_START', Update)
		self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', Update)
		bar:Hide()
		bar:SetScript('OnUpdate', OnUpdate)
		
		return true
	end
end

local function Disable(self, unit)
	local bar = self.GCDBar
	if bar then
		self:UnregisterEvent('UNIT_SPELLCAST_START', Update)
		self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', Update)
		bar:SetScript('OnUpdate', nil)
		bar:Hide()
	end
end

oUF:AddElement('GCDBar', Update, Enable, Disable)
