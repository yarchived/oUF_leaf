local _, ns = ...
local oUF = ns.oUF or oUF


local MAX_TIME = 1/5

local objects = {}
local function SetValue(self, value)
	if self.SmoothUpdate_Value ~= value then
		--self.SmoothUpdate_Value = self:GetValue()
		self.SmoothUpdate_DiffValue = value - self.SmoothUpdate_Value
		objects[self] = value
	end
end

local function setup(self)
	if self and self.SmoothUpdate then
		self.SmoothUpdate_Value = self:GetValue()
		self.SmoothUpdate_SetValue = self.SetValue
		self.SetValue = SetValue
	end
end

local function enable(self)
	setup(self.Health)
	setup(self.Power)
end


local updateFrame = CreateFrame('Frame', 'oUF_SmoothUpdate', UIParent)
updateFrame:SetScript('OnUpdate', function(self, elps)
	local rate = elps/MAX_TIME
	
	for bar, value in next, objects do
		local new = bar.SmoothUpdate_Value + bar.SmoothUpdate_DiffValue * rate
		if (bar.SmoothUpdate_DiffValue>0 and new>=value) or (bar.SmoothUpdate_DiffValue<0 and new<=value) then
			new = value
			objects[bar] = nil
		end
		
		bar.SmoothUpdate_Value = new
		bar:SmoothUpdate_SetValue(new)
	end
end)

oUF:AddElement('SmoothUpdate', nil, enable)

