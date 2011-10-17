
local _, ns = ...
local oUF = ns.oUF or oUF
local leaf = ns.leaf

-- color credit: caellian
local colors = setmetatable({
	power = setmetatable({
	--[[
		['MANA'] = {.3,.5,.85},
		['RAGE'] = {.9,.2,.3},
		['ENERGY'] = {1,.85,.1},
		['RUNIC_POWER'] = {0,.8,1},
	]]
		['MANA'] = {0.31, 0.45, 0.63},
		['RAGE'] = {0.69, 0.31, 0.31},
		['FOCUS'] = {0.71, 0.43, 0.27},
		['ENERGY'] = {0.65, 0.63, 0.35},
		['RUNES'] = {0.55, 0.57, 0.61},
		['RUNIC_POWER'] = {0, 0.82, 1},
		['AMMOSLOT'] = {0.8, 0.6, 0},
		['FUEL'] = {0, 0.55, 0.5},
		['POWER_TYPE_STEAM'] = {0.55, 0.57, 0.61},
		['POWER_TYPE_PYRITE'] = {0.60, 0.09, 0.17},
	--[[
		['MANA'] = {.31,.45,.63},
		['RAGE'] = {.69,.31,.31},
		['FOCUS'] = {.71,.43,.27},
		['ENERGY'] = {.65,.63,.35},
		['RUNIC_POWER'] = {0,.8,.9},
	]]
	}, {__index = oUF.colors.power}),
	--health = {.15,.15,.15},
	--disconnected = {.5,.5,.5},
	--tapped = {.5,.5,.5},
	--smooth = {1, 0, 0, 1, 1, 0, 0, 1, 0},
    --class = setmetatable({}, {__index = oUF.colors.class}),
	runes = setmetatable({
		[1] = {0.69, 0.31, 0.31},
		[2] = {0.33, 0.59, 0.33},
		[3] = {0.31, 0.45, 0.63},
		[4] = {0.84, 0.75, 0.65},
	}, {__index = oUF.colors.runes}),
	tapped = {0.55, 0.57, 0.61},
	disconnected = {0.84, 0.75, 0.65},
	smooth = {0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.15, 0.15, 0.15},
}, {__index = oUF.colors})
leaf.colors = colors
