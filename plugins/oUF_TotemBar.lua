--[[
	yleaf (yaroot@gmail.com)
	
	Documentation:
	
		Element handled:
			.TotemBar (must be a table with statusbar inside)
		
		.TotemBar only:
			.delay : The interval for updates (Default: 0.1)
			.colors : The color for the statusbar
			.destroy : Destroys the totem on right click
			
		.TotemBar.bg only:
			.multiplier : Sets the multiplier for the text or the background (can be two differents multipliers)

--]]

if select(2, UnitClass("player")) ~= 'SHAMAN' then return end

local _, ns = ...
local oUF = ns.oUF or oUF

local delay, colors = 1, {
	[1] = {0.752,0.172,0.02},
	[2] = {0.741,0.580,0.04},		
	[3] = {0,0.443,0.631},
	[4] = {0.6,1,0.945},	
}

function OnUpdate(self, elapsed)
	self.total = self.total + elapsed
	if self.total >= delay then
		self.total = 0
		local timeLeft = self.endTime - GetTime()
		
		if (timeLeft <= 0) then
			self:SetValue(0)
			self:SetScript('OnUpdate', nil)
		else
			self:SetValue(timeLeft / self.duration)
		end
	end
end

local function Update(self, event, slot)
	local haveTotem, name, startTime, duration, totemIcon = GetTotemInfo(slot)
	local bar = self.TotemBar[slot]
	
	if (not name) or (name == '') then
		bar:SetScript('OnUpdate', nil)
		bar:SetValue(0)
	else
		bar.endTime = startTime + duration
		bar.duration = duration
		bar.total = 0
		bar:SetScript('OnUpdate', OnUpdate)
	end
end

local function Enable(self, unit)
	if unit ~= 'player' then return end
	local totem = self.TotemBar
	if(totem) then
		self:RegisterEvent("PLAYER_TOTEM_UPDATE" ,Update)
		colors = totem.colors or colors
		delay = totem.delay or delay
		local destroy = totem.destroy
		
		for i = 1, 4 do
			local bar = totem[i]
			local r,g,b = unpack(colors[i])
			bar:SetStatusBarColor(r,g,b)
			if bar.bg then
				local mu = bar.bg.multiplier or 1
				bar.bg:SetVertexColor(r*mu, g*mu, b*mu)
			end
			bar.total = 0
			Update(self, 'Update', i)
			if destroy then
				bar:EnableMouse(true)
				bar:SetScript('OnMouseUp', function(self, button) if button == 'RightButton' then DestroyTotem(i) end end)
			end
		end
		
		--TotemFrame:UnregisterAllEvents()
		return true
	end	
end

local function Disable(self,unit)
	local totem = self.TotemBar
	if(totem) then
		self:UnregisterEvent("PLAYER_TOTEM_UPDATE", Update)
		
		--TotemFrame:Show()
	end
end

oUF:AddElement("TotemBar", function(self)
	for i = 1, 4 do Update(self, 'Update', i) end
end, Enable, Disable)

