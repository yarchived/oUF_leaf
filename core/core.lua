
local leaf = {}

leaf.noraid = false
leaf.noarena = false
leaf.nouf = false
leaf.AuraWatch = true
leaf.AuraWatchIconSize = 32

leaf.frameScale = 1.1 -- global scale
leaf.HealComm = true
leaf.test_mod = false



local _NAME, _NS = ...
local oUF = _NS.oUF or oUF

_G[_NAME] = leaf
_NS.leaf = leaf

for _, a in next, {'DarkDurance_UnitFrame'} do
    if( select(4, GetAddOnInfo(a)) ) then
        leaf.nouf = true
        break
    end
end


