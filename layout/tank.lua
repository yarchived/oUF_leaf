
local _, ns = ...
local oUF = ns.oUF or oUF
local leaf = ns.leaf

oUF:SetActiveStyle'leaf-Tank'

local mt_max = 5
local ma_max = 2
local pt_max = 5
local ora_max = 10

local no_target = '<no target>'
local addon = CreateFrame('Frame', 'oUF_leaf_PT_Menu_Frame', UIParent)
addon:SetScript('OnEvent', function(self, event, ...)
    self[event](self, event, ...)
end)
local menu = {}
local pendingUpdate = true

local function spawn(name, num, ...)
    local header = oUF:SpawnHeader(name, nil, nil,
    'showRaid', true,
    'yOffset', -5,
    'template', 'oUF_leaf_HeaderTarget',
    'unitsPerColumn', num,
    'oUF-initialConfigFunction', [[
        self:SetWidth(130)
        self:SetHeight(20)
    ]] .. (ns.ClickCast and ns.ClickCast.BINDING_STR or '')
    , ...)
    return header
end

local mt = spawn('oUF_leaf_MainTank', mt_max, 'groupFilter', 'MAINTANK')
mt:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 10, -25)
mt:Show()

local ma = spawn('oUF_leaf_MainAssist', ma_max, 'groupFilter', 'MAINASSIST')
ma:SetPoint('TOPLEFT', mt, 'BOTTOMLEFT', 0, -10)
ma:Show()

local pt = spawn('oUF_leaf_PlayerTarget', pt_max, 'nameList', '')
pt:SetPoint('TOPLEFT', ma, 'BOTTOMLEFT', 0, -10)
pt:Show()

leaf.units.mt = mt
leaf.units.ma = ma
leaf.units.pt = pt

leaf.units.mt:SetScale(leaf.frameScale)
leaf.units.ma:SetScale(leaf.frameScale)
leaf.units.pt:SetScale(leaf.frameScale)

pt.list = {}

local function output(...)
    DEFAULT_CHAT_FRAME:AddMessage('|cff33ff99oUF leaf:|r ' .. tostringall(...))
end

local function refreshPT()
    pendingUpdate = true

    local listed = ''
    for i = 1, pt_max do
        if pt.list[i] then
            listed = listed .. ',' .. pt.list[i]
        end
    end

    pt:SetAttribute('nameList', listed)
    pt:Show()
end

StaticPopupDialogs['OUF_LEAF_WIPE_PTLIST_CONFIRM'] = {
    text = 'Are you sure to wipe oUF leaf PT list?',
    button1 = OKAY,
    button2 = CANCEL,
    OnAccept = function()
        wipe(pt.list)
        refreshPT()
        output('PT list wiped')
    end,
    timeout = 10,
    whileDead = 1,
    hideOnEscape = 1,
}

local function isInGroup(unit)
    return UnitPlayerOrPetInParty(unit) or UnitPlayerOrPetInRaid(unit)
end

local function handleClick(i)
    if InCombatLockdown() then
        output('cannot set PT during combat')
    else
        if UnitExists('target') then
            local name, realm = UnitName'target'
            if isInGroup('target') and name and (name ~= '') and (name ~= UNKNOWNOBJECT) then
                if realm and (realm~='') then name = name..'-'..realm end
                for j = 1, pt_max do
                    if pt.list[j] == name then
                        pt.list[j] = nil
                    end
                end
                pt.list[i] = name

                refreshPT()
                output(name .. ' has been added to PT list')
            else
                output('target cannot be added into PT list')
            end
        else
            if not pt.list[i] then return end
            output(pt.list[i] .. ' has been removed from PT list')
            pt.list[i] = nil
            refreshPT()
        end
    end
end

local function updateMenu()
    pendingUpdate = false
    menu = wipe(menu)

    local title = {text = 'PT list\n ', isTitle = true, notCheckable = 1, }
    tinsert(menu, title)

    for i = 1, pt_max do
        tinsert(menu, {
            text = i..'. '..(pt.list[i] or no_target),
            func = function() handleClick(i) end,
            notCheckable = 1,
        })
    end

    tinsert(menu, {text = '', disabled = true, notCheckable = 1})
    tinsert(menu, {
        text = '|cffff0000Wipe PT list|r',
        func = function() StaticPopup_Show('OUF_LEAF_WIPE_PTLIST_CONFIRM') end,
        notCheckable = 1,
    })

    tinsert(menu, {text = '', disabled = true, notCheckable = 1,})
    tinsert(menu, {text = '|cff00ff00Click to set or remove PT|r', disabled = true, notCheckable = 1})
end

local dataobj = LibStub('LibDataBroker-1.1'):NewDataObject('oUF_leaf',{
    type = 'data source',
    text = 'oUF leaf',
    icon = [[Interface\Icons\spell_holy_devotionaura]]
})

function dataobj.OnClick(self, button)
    if button == 'RightButton' then
        local onleave = self:GetScript'OnLeave'
        if onleave then
            onleave(self)
        end
        if pendingUpdate then
            updateMenu()
        end
		return ToggleDropDownMenu(1, nil, addon, self, 0, 0)
    elseif button == 'LeftButton' then
        refreshPT()
        output('PT list refreshed')
    end
end

function dataobj.OnTooltipShow(tooltip)
    if not tooltip or not tooltip.AddLine then return end

    tooltip:AddLine('|cffff8800oUF leaf PT|r')
    tooltip:AddLine('\n')

    for i = 1, pt_max do
        tooltip:AddLine(i..'. '..(pt.list[i] or no_target), 1,1,1)
    end

    tooltip:AddLine('\n')
    tooltip:AddDoubleLine('LeftClick', 'Refresh PT')
    tooltip:AddDoubleLine('RightClick', 'Toggle menu')
end

local function createMenu()
    for _, m in ipairs(menu) do
		UIDropDownMenu_AddButton(m)
    end
end

addon.initialize = createMenu
addon.displayMode = 'MENU'


do
    local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo'oRA3'
    if not (name and enabled) then return end
end


local ora = spawn('oUF_leaf_oRA_Tank', ora_max, 'nameList', '')
ora:SetPoint('TOPLEFT', leaf.units.pt, 'BOTTOMLEFT', 0, -10)
leaf.units.ora = ora
ora:SetScale(leaf.frameScale)

function addon:OnTanksUpdated(event, tanks)
    if InCombatLockdown() then
        return self:RegisterEvent'PLAYER_REGEN_ENABLED'
    end
    if(oRA3.GetSortedTanks) then
        ora:SetAttribute('nameList', table.concat(oRA3:GetSortedTanks(), ','))
    end
end

function addon:PLAYER_REGEN_ENABLED(event)
    self:UnregisterEvent(event)
    self:OnTanksUpdated(event)
end

addon:RegisterEvent'ADDON_LOADED'
function addon:ADDON_LOADED(event, addonName)
    if strlower(addonName) ~= 'ora3' then return end
    self:UnregisterEvent(event)
    self.ADDON_LOADED = nil
    if oRA3 then
        oRA3.RegisterCallback(self, 'OnTanksUpdated')
    end
end

