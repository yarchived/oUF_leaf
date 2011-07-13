
local _, ns = ...
ns.raid_debuffs = {}

for k, v in ipairs{

    -- Vault of Archavon
    67332, -- Koralon the Flame Watcher
    71993, -- Koralon the Flame Watcher
    72098, -- Koralon the Flame Watcher
    72104, -- Koralon the Flame Watcher

    -- Trial of the Crusader
    66331, -- Gormok the Impaler
    67475, -- Gormok the Impaler
    66406, -- Gormok the Impaler
    67618, -- Jormungar Behemoth
    66869, -- Jormungar Behemoth
    67654, -- Icehowl
    66689, -- Icehowl
    66683, -- Icehowl
    66532, -- Lord Jaraxxus
    66237, -- Lord Jaraxxus
    66242, -- Lord Jaraxxus
    66197, -- Lord Jaraxxus
    66283, -- Lord Jaraxxus
    66209, -- Lord Jaraxxus
    66211, -- Lord Jaraxxus
    67906, -- Lord Jaraxxus
    65812, -- Faction Champions
    65960, -- Faction Champions
    65801, -- Faction Champions
    65543, -- Faction Champions
    66054, -- Faction Champions
    65809, -- Faction Champions
    67176, -- The Twin Val'kyr
    67222, -- The Twin Val'kyr
    67283, -- The Twin Val'kyr
    67298, -- The Twin Val'kyr
    67309, -- The Twin Val'kyr
    67574, -- Anub'arak
    66013, -- Anub'arak
    67847, -- Anub'arak
    66012, -- Anub'arak
    67863, -- Anub'arak

    -- The Ruby Sanctum
    13737, -- trash
    15621, -- trash
    75413, -- trash
    75418, -- trash
    74453, -- Saviana Ragefire
    74456, -- Saviana Ragefire
    74505, -- Baltharus the Warborn
    74509, -- Baltharus the Warborn
    74384, -- General Zarithrian
    74367, -- General Zarithrian
    74567, -- Halion
    74795, -- Halion

    -- Icecrown Citadel
    70980, -- trash
    69483, -- trash
    69969, -- trash
    71089, -- trash
    71127, -- trash
    71163, -- trash
    71103, -- trash
    71157, -- trash
    70645, -- trash
    70671, -- trash
    70432, -- trash
    70435, -- trash
    71257, -- trash
    71252, -- trash
    71327, -- trash
    36922, -- trash
    70823, -- Lord Marrowgar
    69065, -- Lord Marrowgar
    70835, -- Lord Marrowgar
    72109, -- Lady Deathwhisper
    71289, -- Lady Deathwhisper
    71204, -- Lady Deathwhisper
    67934, -- Lady Deathwhisper
    71237, -- Lady Deathwhisper
    72491, -- Lady Deathwhisper
    69651, -- Icecrown Gunship Battle
    72293, -- Deathbringer Saurfang
    72442, -- Deathbringer Saurfang
    72449, -- Deathbringer Saurfang
    72769, -- Deathbringer Saurfang
    71224, -- Rotface
    71215, -- Rotface
    69774, -- Rotface
    69279, -- Festergut
    71218, -- Festergut
    72219, -- Festergut
    70341, -- Professor Putricide
    72549, -- Professor Putricide
    71278, -- Professor Putricide
    70215, -- Professor Putricide
    70447, -- Professor Putricide
    72454, -- Professor Putricide
    70405, -- Professor Putricide
    72856, -- Professor Putricide
    70953, -- Professor Putricide
    72796, -- Blood Princes
    71822, -- Blood Princes
    70838, -- Blood-Queen Lana'thel
    72265, -- Blood-Queen Lana'thel
    71473, -- Blood-Queen Lana'thel
    71474, -- Blood-Queen Lana'thel
    73070, -- Blood-Queen Lana'thel
    71340, -- Blood-Queen Lana'thel
    71265, -- Blood-Queen Lana'thel
    70923, -- Blood-Queen Lana'thel
    70873, -- Valithria Dreamwalker
    71746, -- Valithria Dreamwalker
    71741, -- Valithria Dreamwalker
    71738, -- Valithria Dreamwalker
    71733, -- Valithria Dreamwalker
    71283, -- Valithria Dreamwalker
    71941, -- Valithria Dreamwalker
    69762, -- Sindragosa
    70106, -- Sindragosa
    69766, -- Sindragosa
    70126, -- Sindragosa
    70157, -- Sindragosa
    70127, -- Sindragosa
    70337, -- The Lich King
    72149, -- The Lich King
    70541, -- The Lich King
    69242, -- The Lich King
    69409, -- The Lich King
    72762, -- The Lich King
    68980, -- The Lich King

    -- The Eye of Eternity
    57407, -- Malygos
    56272, -- Malygos

    -- Naxxramas
    55314, -- trash
    28786, -- Anub'Rekhan
    28796, -- Grand Widow Faerlina
    28794, -- Grand Widow Faerlina
    28622, -- Maexxna
    54121, -- Maexxna
    29213, -- Noth the Plaguebringer
    29214, -- Noth the Plaguebringer
    29212, -- Noth the Plaguebringer
    29998, -- Heigan the Unclean
    29310, -- Heigan the Unclean
    28169, -- Grobbulus
    54378, -- Gluth
    29306, -- Gluth
    28084, -- Thaddius
    28059, -- Thaddius
    55550, -- Instructor Razuvious
    28522, -- Sapphiron
    28542, -- Sapphiron
    28410, -- Kel'Thuzad
    27819, -- Kel'Thuzad
    27808, -- Kel'Thuzad

    -- The Obsidian Sanctum
    39647, -- trash
    58936, -- trash
    60708, -- Sartharion
    57491, -- Sartharion

    -- Ulduar
    63612, -- trash
    63615, -- trash
    63169, -- trash
    64771, -- Razorscale
    62548, -- Ignis the Furnace Master
    62680, -- Ignis the Furnace Master
    62717, -- Ignis the Furnace Master
    63024, -- XT-002 Deconstructor
    63018, -- XT-002 Deconstructor
    61888, -- The Iron Council
    62269, -- The Iron Council
    61903, -- The Iron Council
    61912, -- The Iron Council
    64290, -- Kologarn
    63355, -- Kologarn
    62055, -- Kologarn
    62469, -- Hodir
    61969, -- Hodir
    62188, -- Hodir
    62042, -- Thorim
    62130, -- Thorim
    62526, -- Thorim
    62470, -- Thorim
    62331, -- Thorim
    62589, -- Freya
    62861, -- Freya
    63666, -- Mimiron
    62997, -- Mimiron
    64668, -- Mimiron
    63276, -- General Vezax
    63322, -- General Vezax
    63134, -- Yogg-Saron
    63138, -- Yogg-Saron
    63830, -- Yogg-Saron
    63802, -- Yogg-Saron
    63042, -- Yogg-Saron
    64156, -- Yogg-Saron
    64153, -- Yogg-Saron
    64157, -- Yogg-Saron
    64152, -- Yogg-Saron
    64125, -- Yogg-Saron
    63050, -- Yogg-Saron
    64412, -- Algalon the Observer


--    --Vault of Archavon
--    67332,
--    71993, 72098, 72104,
--
--    --Trial of the Crusader
--    66331, 67475, 66406, --Gormok the Impaler
--    67618, 66869, --Jormungar Behemoth
--    67654, 66689, 66683, --Icehowl
--    66532, 66237, 66242, 66197, 66283, 66209, 66211, 67906, --Lord Jaraxxus
--    65812, 65960, 65801, 65543, 66054, 65809, --Faction Champions
--    --[[67176,]] --[[67222,]] 67283, 67298, 67309, --The Twin Val'kyr
--    67574, 66013, 67847, 66012, 67863, 68509, --Anub'arak
--
--    --The Eye of Eternity
--    57407, 56272, --Malygos
--
--    --The Obsidian Sanctum
--    39647, 58936, --Trash
--    60708, 57491, --Sartharion
--
--    --Naxxramas
--    55314, --Trash
--    28786, --Anub'Rekhan
--    28796, 28794, --Grand Widow Faerlina
--    28622, 54121, --Maexxna
--    29213, 29214, 29212, --Noth the Plaguebringer
--    29998, 29310, --Heigan the Unclean
--    28169, --Grobbulus
--    54378, 29306, --Gluth
--    28084, 28059, --Thaddius
--    55550, --Instructor Razuvious
--    28522, 28542, --Sapphiron
--    28410, 27819, 27808, --Kel'Thuzad
--
--    --Ulduar
--    63612, 63615, 63169, --Trash
--    64771, --Razorscale
--    62548, 62680, 62717, --Ignis the Furnace Master
--    63024, 63018, --XT-002 Deconstructor
--    61888, 62269, 61903, 61912, --The Iron Council
--    64290, 63355, 62055, --Kologarn
--    62469, 61969, 62188, --Hodir
--    62042, 62130, 62526, 62470, 62331, --Thorim
--    62589, 62861, --Freya
--    63666, 62997, 64668, --Mimiron
--    63276, 63322, --General Vezax
--    63134, 63138, 63830, 63802, 63042, 64156, 64153, 64157, 64152, 64125, 63050, --Yogg-Saron
--    64412, --Algalon the Observer
--
--    --Icecrown Citadel
--    70980, 69483, 69969, --The Lower Spire
--    71089, 71127, 71163, 71103, 71157, --The Plagueworks
--    70645, 70671, 70432, 70435, --The Crimson Hall
--    71257, 71252, 71327, 36922, --Frostwing Hall
--    70823, 69065, 70835, --Lord Marrowgar
--    72109, 71289, 71204, 67934, 71237, 72491, --Lady Deathwhisper
--    69651, --Gunship Battle
--    72293, 72442, 72449, 72769, --Deathbringer Saurfang
--    71224, 71215, 69774, --Rotface
--    69279, 71218, 72219, --Festergut
--    70341, 72549, 71278, 70215, 70447, 72454, 70405, 72856, 70953, --Proffessor
--    72796, 71822, --Blood Princes
--    70838, 72265, 71473, 71474, 73070, 71340, 71265, 70923, --Blood-Queen Lana'thel
--    70873, 71746, 71741, 71738, 71733, 71283, 71941, --Valithria Dreamwalker
--    69762, 70106, 69766, 70126, 70157, 70127, --Sindragosa
--    70337, 72149, 70541, 69242, 69409, 72762, 68980, --The Lich King
} do
    local spell = GetSpellInfo(v)
    if(spell) then
        ns.raid_debuffs[spell] = k+10
    end
end

