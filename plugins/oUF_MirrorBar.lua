
local _, ns = ...
local oUF = ns.oUF or oUF

local PAUSED

local function formatTime(time)
	local hour = floor(time/3600)
	local min = floor(time/60)
	local sec = time%60
	
	if hour > 0 then
		return format('%d:%02d:%02d', hour, min, sec)
	elseif min> 0 then
		return format('%d:%02d', min, sec)
	else
		return sec
	end
end

local function OnUpdate(self, elps)
	if PAUSED then return end
	
	local time = GetMirrorTimerProgress(self.timer) / 1000
	time = (time < 0) and 0 or (time > self.maxvalue) and self.maxvalue or time
	self:SetValue(time)
	if self.Time then
		self.Time:SetText(formatTime(time))
	end
end

local function UpdateBar(self, timers, timer, value, maxvalue, scale, paused, label)
	PAUSED = paused > 0
	
	local bar = self.MirrorBar[timers]
	bar.timer = timer
	bar.value = value / 1000
	bar.maxvalue = maxvalue / 1000
	bar.scale = scale
	bar.label = label
	
	if bar.Text then
		bar.Text:SetText(label)
	end
	local c = self.MirrorBar.Color[timer]
	bar:SetStatusBarColor(c.r, c.g, c.b)
	
	bar:SetMinMaxValues(0, maxvalue/1000)
	bar:SetValue(value/1000)
	
	bar:SetScript('OnUpdate', OnUpdate)
	bar:Show()
end

local function MIRROR_TIMER_START(self, event, timer, value, maxvalue, scale, paused, label)
	local timers
	for i = 1, MIRRORTIMER_NUMTIMERS do
		if self.MirrorBar[i].timer == timer then
			timers = i
			break
		elseif not self.MirrorBar[i]:IsShown() then
			timers = timers or i
		end
	end
	UpdateBar(self, timers, timer, value, maxvalue, scale, paused, label)
end

local function MIRROR_TIMER_STOP(self, event, timer)
	for i = 1, MIRRORTIMER_NUMTIMERS do
		if self.MirrorBar[i].timer == timer then
			self.MirrorBar[i].timer = nil
			self.MirrorBar[i]:Hide()
		end
	end
end

local function MIRROR_TIMER_PAUSE(self, event, paused)
	PAUSED = paused > 0
end

local function Update(self, event, ...)
	local timers = 0
	for i = 1, MIRRORTIMER_NUMTIMERS do
		local timer, value, maxvalue, scale, paused, label = GetMirrorTimerInfo(i)
		if timer~= 'UNKNOWN' then
			timers = timers + 1
			UpdateBar(self, timers, timer, value, maxvalue, scale, paused, label)
		end
	end
	if timers < MIRRORTIMER_NUMTIMERS then
		for i = (timers + 1), MIRRORTIMER_NUMTIMERS do
			self.MirrorBar[i]:Hide()
		end
	end
end


local function Enable(self)
	if self.unit == 'player' and self.MirrorBar then
		self.MirrorBar.Color = self.MirrorBar.Color or MirrorTimerColors
		
		for i = 1, MIRRORTIMER_NUMTIMERS do
			local f = _G['MirrorTimer'..i]
			f:UnregisterAllEvents()
		end
		UIParent:UnregisterEvent'MIRROR_TIMER_START'
		
		for i = 1, MIRRORTIMER_NUMTIMERS do
			self.MirrorBar[i]:Hide()
		end
		
		self:RegisterEvent('MIRROR_TIMER_START', MIRROR_TIMER_START)
		self:RegisterEvent('MIRROR_TIMER_STOP', MIRROR_TIMER_STOP)
		self:RegisterEvent('MIRROR_TIMER_PAUSE', MIRROR_TIMER_PAUSE)
		
		return true
	end
end

local function Disable(self)
	if self.unit == 'player' and self.MirrorBar then
		UIParent:RegisterEvent'MIRROR_TIMER_START'
		for i = 1, MIRRORTIMER_NUMTIMERS do
			local f = _G['MirrorTimer'..i]
			f:RegisterAllEvents'MIRROR_TIMER_PAUSE'
			f:RegisterAllEvents'MIRROR_TIMER_STOP'
			f:RegisterAllEvents'PLAYER_ENTERING_WORLD'
		end
		
		self:UnregisterEvent('MIRROR_TIMER_START', MIRROR_TIMER_START)
		self:UnregisterEvent('MIRROR_TIMER_STOP', MIRROR_TIMER_STOP)
		self:UnregisterEvent('MIRROR_TIMER_PAUSE', MIRROR_TIMER_PAUSE)
	end
end

oUF:AddElement('MirrorBar', Update, Enable, Disable)
