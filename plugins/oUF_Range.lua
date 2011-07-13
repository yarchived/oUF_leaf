--[[
	
	.SpellRange [boolean] <or> [num] update rate
	.inRangeAlpha [num] - Frame alpha value for units in range.
	.outsideRangeAlpha [num] - Frame alpha for units out of range.
]]

local _, ns = ...
local oUF = ns.oUF or oUF

local updateRate = 0.3
local inRangeAlpha, outsideRangeAlpha = 1, .45

local objects = {}

local Harm, Help

do 
	local _, class = UnitClass('player')
	local HarmIDs = {
		['DRUID'] = 5176, -- ["Wrath"], -- 30 (Nature's Reach: 33, 36)
		['HUNTER'] = 75, -- ["Auto Shot"], -- 5-35 (Hawk Eye: 37, 39, 41)
		--['MAGE'] = 44614, -- ["Frostfire Bolt"], -- 40
        MAGE = 133, -- Fireball
		--['PALADIN'] = 24275, -- ["Hammer of Wrath"],  -- 30 (Glyph of Hammer of Wrath: +5)
		['PRIEST'] = 585, -- ["Smite"], -- 30 (Holy Reach: 33, 36)
		['ROGUE'] = 26679, -- ["Deadly Throw"], -- 30 (Glyph of Deadly Throw: +5)
		['SHAMAN'] = 403, -- ["Lightning Bolt"], -- 30 (Storm Reach: 33, 36)
		['WARRIOR'] = 355, -- ["Taunt"], -- 30
		['WARLOCK'] = 348, -- ["Immolate"], -- 30 (Destructive Reach: 33, 36)
		['DEATHKNIGHT'] = 47541, -- ["Death Coil"], -- 30
		
		
--	DEATHKNIGHT = { 47541 }; -- Death Coil (30yd) - Starter
--	DRUID = { 5176 }; -- Wrath (40yd) - Starter
--	HUNTER = { 75 }; -- Auto Shot (5-40yd) - Starter
--	MAGE = { 133 }; -- Fireball (40yd) - Starter
--	PALADIN = {
--		62124, -- Hand of Reckoning (30yd) - Lvl 14
--		879, -- Exorcism (30yd) - Lvl 18
--	};
--	PRIEST = { 589 }; -- Shadow Word: Pain (40yd) - Lvl 4
--	-- ROGUE = {};
--	SHAMAN = { 403 }; -- Lightning Bolt (30yd) - Starter
--	WARLOCK = { 686 }; -- Shadow Bolt (40yd) - Starter
--	WARRIOR = { 355 }; -- Taunt (30yd) - Lvl 12

		--[[
		DEATHKNIGHT = 52375; -- Death Coil
		DRUID = 5176; -- Wrath
		HUNTER = 75; -- Auto Shot
		MAGE = 133; -- Fireball
		PALADIN = 62124; -- Hand of Reckoning
		PRIEST = 585; -- Smite
		SHAMAN = 403; -- Lightning Bolt
		WARLOCK = 686; -- Shadow Bolt
		WARRIOR = 355; -- Taunt
		]]
	}
	local HelpIDs = {
		DRUID = 5185; -- Healing Touch
        DEATHKNIGHT = 47541, -- Death Coil
		MAGE = 1459; -- Arcane Intellect
        -- MAGE = 475 -- Remove Curse lvl 30
		PALADIN = 635; -- Holy Light
		--PRIEST = 2050; -- Lesser Heal
		PRIEST = 2061; -- Flash Heal
		SHAMAN = 331; -- Healing Wave
		WARLOCK = 5697; -- Unending Breath
	}
--	DEATHKNIGHT = { 47541 }; -- Death Coil (40yd) - Starter
--	DRUID = { 5185 }; -- Healing Touch (40yd) - Lvl 3
--	-- HUNTER = {};
--	MAGE = { 475 }; -- Remove Curse (40yd) - Lvl 30
--	PALADIN = { 85673 }; -- Word of Glory (40yd) - Lvl 9
--	PRIEST = { 2061 }; -- Flash Heal (40yd) - Lvl 3
--	-- ROGUE = {};
--	SHAMAN = { 331 }; -- Healing Wave (40yd) - Lvl 7
--	WARLOCK = { 5697 }; -- Unending Breath (30yd) - Lvl 16
--	-- WARRIOR = {};
--[[	local HarmIDs ={
	}]]
	
	Harm = HarmIDs[class] and GetSpellInfo(HarmIDs[class])
	Help = HelpIDs[class] and GetSpellInfo(HelpIDs[class])

end

local function update(self, isInRange)
	if self.IsInRange ~= isInRange then
		self.IsInRange = isInRange
		self:SetAlpha(isInRange and (self.inRangeAlpha or inRangeAlpha) or (self.outsideRangeAlpha or outsideRangeAlpha))
	end
end


local function isInRange(u)
	if (UnitCanAssist('player', u)) then
		if(Help and not UnitIsDead(u)) then
			return IsSpellInRange(Help, u) == 1
		elseif(not UnitOnTaxi('player') and UnitIsUnit('player', u) or
			UnitIsUnit('pet', u) or UnitPlayerOrPetInParty(u) or UnitPlayerOrPetInRaid(u)) then
			return UnitInRange(u)
		end
	elseif(Harm and not UnitIsDead(u) and UnitCanAttack('player', u)) then
		return IsSpellInRange(Harm, u) == 1
	else
		return CheckInteractDistance(u, 4)
	end
	return true
end

local function updateRange(self)
	update(self, isInRange(self.unit))
end

do
	local total = 0
	local function OnUpdate(self, elps)
		total = total - elps
		if total < 0 then
			total = updateRate
			
			for frame in next, objects do
				updateRange(frame)
			end
		end
	end
	
	local f = CreateFrame('Frame')
	f:SetScript('OnUpdate', OnUpdate)
	f:Show()
end

local function OnShow(self)
	objects[self] = true
end

local function OnHide(self)
	objects[self] = nil
end

local function Enable(self)
	if self.Range then
		if self:IsVisible() then
			OnShow(self)
		end
		self:HookScript('OnShow', OnShow)
		self:HookScript('OnHide', OnHide)
	end
end

oUF:AddElement('Range2', nil, Enable)
