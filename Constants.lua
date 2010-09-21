--[[
	Below are constants needed for DB storage and retrieval
	The core of gathermate handles adding new node that collector finds
	data shared between Collector and Display also live in GatherMate for sharing like zone_data for sizes, and node ids with reverses for display and comparison
	Credit to Astrolabe (http://www.gathereraddon.com) for lookup tables used in GatherMate. Astrolabe is licensed LGPL
]]
local GatherMate = LibStub("AceAddon-3.0"):GetAddon("GatherMate2")
local NL = LibStub("AceLocale-3.0"):GetLocale("GatherMate2Nodes",true)
local L = LibStub("AceLocale-3.0"):GetLocale("GatherMate2")

GatherMate.mapData = LibStub("LibMapData-1.0")

--[[
	Node Identifiers
]]
local node_ids = {
	["Fishing"] = {
		[NL["Floating Wreckage"]] 				= 101, -- treasure.tga
		[NL["Patch of Elemental Water"]] 		= 102, -- purewater.tga
		[NL["Floating Debris"]] 				= 103, -- debris.tga
		[NL["Oil Spill"]] 						= 104, -- oilspill.tga
		[NL["Firefin Snapper School"]] 			= 105, -- firefin.tga
		[NL["Greater Sagefish School"]] 		= 106, -- greatersagefish.tga
		[NL["Oily Blackmouth School"]] 			= 107, -- oilyblackmouth.tga
		[NL["Sagefish School"]] 				= 108, -- sagefish.tga
		[NL["School of Deviate Fish"]] 			= 109, -- firefin.tga
		[NL["Stonescale Eel Swarm"]] 			= 110, -- eel.tga
		[NL["Muddy Churning Water"]] 			= 111, -- ZG only fishing node
		[NL["Highland Mixed School"]] 			= 112, -- fishhook.tga
		[NL["Pure Water"]] 						= 113, -- purewater.tga
		[NL["Bluefish School"]] 				= 114, -- bluefish,tga
		[NL["Feltail School"]] 					= 115, -- feltail.tga
		[NL["Brackish Mixed School"]]         	= 115, -- feltail.tga
		[NL["Mudfish School"]] 					= 116, -- mudfish.tga
		[NL["School of Darter"]] 				= 117, -- darter.tga
		[NL["Sporefish School"]] 				= 118, -- sporefish.tga
		[NL["Steam Pump Flotsam"]] 				= 119, -- steampump.tga
		[NL["School of Tastyfish"]] 			= 120, -- net.tga
		[NL["Borean Man O' War School"]]        = 121,
		[NL["Deep Sea Monsterbelly School"]]	= 122,
		[NL["Dragonfin Angelfish School"]]		= 123,
		[NL["Fangtooth Herring School"]]		= 124,
		[NL["Floating Wreckage Pool"]]			= 125,
		[NL["Glacial Salmon School"]]			= 126,
		[NL["Glassfin Minnow School"]]			= 127,
		[NL["Imperial Manta Ray School"]]		= 128,
		[NL["Moonglow Cuttlefish School"]]		= 129,
		[NL["Musselback Sculpin School"]]		= 130,
		[NL["Nettlefish School"]]				= 131,
		[NL["Strange Pool"]]					= 132,
		[NL["Schooner Wreckage"]]				= 133,
		[NL["Waterlogged Wreckage"]]			= 134,
		[NL["Bloodsail Wreckage"]]				= 135,
		-- Begin tediuous prefix mapping
		[NL["Lesser Sagefish School"]]			= 136, -- sagefish.tga
		[NL["Lesser Oily Blackmouth School"]] 	= 137, -- oilyblackmouth.tga
		[NL["Sparse Oily Blackmouth School"]] 	= 138, -- oilyblackmouth.tga
		[NL["Abundant Oily Blackmouth School"]]	= 139, -- oilyblackmouth.tga
		[NL["Teeming Oily Blackmouth School"]]	= 140, -- oilyblackmouth.tga
		[NL["Lesser Firefin Snapper School"]] 	= 141, -- firefin.tga
		[NL["Sparse Firefin Snapper School"]] 	= 142, -- firefin.tga
		[NL["Abundant Firefin Snapper School"]]	= 143, -- firefin.tga
		[NL["Teeming Firefin Snapper School"]] 	= 144, -- firefin.tga
		[NL["Lesser Floating Debris"]] 			= 145, -- debris.tga
		[NL["Sparse Schooner Wreckage"]]		= 146,
		[NL["Abundant Bloodsail Wreckage"]]		= 147,
		[NL["Teeming Floating Wreckage"]]		= 148,
	},
	["Mining"] = {
		[NL["Copper Vein"]] 					= 201,
		[NL["Tin Vein"]] 						= 202,
		[NL["Iron Deposit"]] 					= 203,
		[NL["Silver Vein"]] 					= 204,
		[NL["Gold Vein"]] 						= 205,
		[NL["Mithril Deposit"]] 				= 206,
		[NL["Ooze Covered Mithril Deposit"]]	= 207,
		[NL["Truesilver Deposit"]] 				= 208,
		[NL["Ooze Covered Silver Vein"]] 		= 209,
		[NL["Ooze Covered Gold Vein"]] 			= 210,
		[NL["Ooze Covered Truesilver Deposit"]] = 211,
		[NL["Ooze Covered Rich Thorium Vein"]] 	= 212,
		[NL["Ooze Covered Thorium Vein"]] 		= 213,
		[NL["Small Thorium Vein"]] 				= 214,
		[NL["Rich Thorium Vein"]] 				= 215,
		--[NL["Hakkari Thorium Vein"]] 			= 216, -- found on in ZG
		[NL["Dark Iron Deposit"]] 				= 217,
		[NL["Lesser Bloodstone Deposit"]] 		= 218,
		[NL["Incendicite Mineral Vein"]] 		= 219,
		[NL["Indurium Mineral Vein"]]			= 220,
		[NL["Fel Iron Deposit"]] 				= 221,
		[NL["Adamantite Deposit"]] 				= 222,
		[NL["Rich Adamantite Deposit"]] 		= 223,
		[NL["Khorium Vein"]] 					= 224,
		[NL["Large Obsidian Chunk"]] 			= 225, -- found only in AQ20/40
		[NL["Small Obsidian Chunk"]] 			= 226, -- found only in AQ20/40
		[NL["Nethercite Deposit"]] 				= 227,
		[NL["Cobalt Deposit"]]					= 228,
		[NL["Rich Cobalt Deposit"]]				= 229,
		[NL["Titanium Vein"]]					= 230,
		[NL["Saronite Deposit"]]				= 231,
		[NL["Rich Saronite Deposit"]]			= 232,
-- Cata nodes
		[NL["Obsidium Deposit"]]				= 233,
		[NL["Huge Obsidian Slab"]]				= 234,
		[NL["Pure Saronite Deposit"]] 			= 235,
		[NL["Elementium Vein"]]					= 236,
		[NL["Rich Elementium Vein"]]			= 237,
		[NL["Pyrite Deposit"]]					= 238,
	},
	["Extract Gas"] = {
		[NL["Windy Cloud"]] 					= 301,
		[NL["Swamp Gas"]] 						= 302,
		[NL["Arcane Vortex"]] 					= 303,
		[NL["Felmist"]] 						= 304,
		[NL["Steam Cloud"]]					    = 305,
		[NL["Cinder Cloud"]]					= 306,
		[NL["Arctic Cloud"]]					= 307,
	},
	["Herb Gathering"] = {
		[NL["Peacebloom"]] 						= 401,
		[NL["Silverleaf"]] 						= 402,
		[NL["Earthroot"]] 						= 403,
		[NL["Mageroyal"]] 						= 404,
		[NL["Briarthorn"]] 						= 405,
		--[NL["Swiftthistle"]] 					= 406, -- found it briathorn nodes
		[NL["Stranglekelp"]] 					= 407,
		[NL["Bruiseweed"]] 						= 408,
		[NL["Wild Steelbloom"]] 				= 409,
		[NL["Grave Moss"]] 						= 410,
		[NL["Kingsblood"]] 						= 411,
		[NL["Liferoot"]] 						= 412,
		[NL["Fadeleaf"]] 						= 413,
		[NL["Goldthorn"]] 						= 414,
		[NL["Khadgar's Whisker"]] 				= 415,
		[NL["Wintersbite"]] 					= 416,
		[NL["Firebloom"]] 						= 417,
		[NL["Purple Lotus"]] 					= 418,
		--[NL["Wildvine"]] 						= 419, -- found in purple lotus nodes
		[NL["Arthas' Tears"]] 					= 420,
		[NL["Sungrass"]] 						= 421,
		[NL["Blindweed"]] 						= 422,
		[NL["Ghost Mushroom"]] 					= 423,
		[NL["Gromsblood"]] 						= 424,
		[NL["Golden Sansam"]] 					= 425,
		[NL["Dreamfoil"]] 						= 426,
		[NL["Mountain Silversage"]] 			= 427,
		[NL["Plaguebloom"]] 					= 428,
		[NL["Icecap"]] 							= 429,
		[NL["Bloodvine"]] 						= 430, -- zg bush loot
		[NL["Black Lotus"]] 					= 431,
		[NL["Felweed"]] 						= 432,
		[NL["Dreaming Glory"]] 					= 433,
		[NL["Terocone"]] 						= 434,
		[NL["Ancient Lichen"]] 					= 435, -- instance only node
		[NL["Bloodthistle"]] 					= 436,
		[NL["Mana Thistle"]] 					= 437,
		[NL["Netherbloom"]] 					= 438,
		[NL["Nightmare Vine"]] 					= 439,
		[NL["Ragveil"]] 						= 440,
		[NL["Flame Cap"]] 						= 441,
		[NL["Netherdust Bush"]] 				= 442,
		[NL["Adder's Tongue"]]					= 443,
		--[NL["Constrictor Grass"]]				= 444, -- drop form others
		--[NL["Deadnettle"]]						= 445, --looted from other plants
		[NL["Goldclover"]]						= 446,
		[NL["Icethorn"]]						= 447,
		[NL["Lichbloom"]]						= 448,
		[NL["Talandra's Rose"]]					= 449,
		[NL["Tiger Lily"]]						= 450,
		[NL["Firethorn"]]						= 451,
		[NL["Frozen Herb"]]						= 452,
		[NL["Frost Lotus"]]						= 453, -- found in lake wintergrasp only
-- cata nodes
		[NL["Dragon's Teeth"]]					= 454,
		[NL["Sorrowmoss"]]						= 455,
		[NL["Azshara's Veil"]]					= 456,
		[NL["Cinderbloom"]]						= 457,
		[NL["Stormvine"]]						= 458,
		[NL["Heartblossom"]]					= 459,
		[NL["Twilight Jasmine"]]				= 460,
	},
	["Treasure"] = {
		[NL["Giant Clam"]] 						= 501,
		[NL["Battered Chest"]] 					= 502,
		[NL["Tattered Chest"]] 					= 503,
		[NL["Solid Chest"]] 					= 504,
		[NL["Large Iron Bound Chest"]] 			= 505,
		[NL["Large Solid Chest"]] 				= 506,
		[NL["Large Battered Chest"]]			= 507,
		[NL["Buccaneer's Strongbox"]] 			= 508,
		[NL["Large Mithril Bound Chest"]] 		= 509,
		[NL["Large Darkwood Chest"]] 			= 510,
		[NL["Un'Goro Dirt Pile"]] 				= 511,
		[NL["Bloodpetal Sprout"]] 				= 512,
		[NL["Blood of Heroes"]] 				= 513,
		[NL["Practice Lockbox"]] 				= 514,
		[NL["Battered Footlocker"]] 			= 515,
		[NL["Waterlogged Footlocker"]] 			= 516,
		[NL["Dented Footlocker"]] 				= 517,
		[NL["Mossy Footlocker"]] 				= 518,
		[NL["Scarlet Footlocker"]] 				= 519,
		[NL["Burial Chest"]] 					= 520,
		[NL["Fel Iron Chest"]] 					= 521,
		[NL["Heavy Fel Iron Chest"]] 			= 522,
		[NL["Adamantite Bound Chest"]] 			= 523,
		[NL["Felsteel Chest"]] 					= 524,
		[NL["Glowcap"]] 						= 525,
		[NL["Wicker Chest"]] 					= 526,
		[NL["Primitive Chest"]] 				= 527,
		[NL["Solid Fel Iron Chest"]] 			= 528,
		[NL["Bound Fel Iron Chest"]] 			= 529,
		[NL["Bound Adamantite Chest"]] 		    = 530, -- instance only node
		[NL["Netherwing Egg"]] 					= 531,
		[NL["Everfrost Chip"]]					= 532,
		[NL["Brightly Colored Egg"]]			= 533,
	},
	["Archaeology"] = {
		-- cata archeolgy objects
		[NL["Night Elf Archaeology Find"]]      = 601,
		[NL["Troll Archaeology Find"]]          = 602,
		[NL["Dwarf Archaeology Find"]]          = 603,
		[NL["Fossil Archaeology Find"]]         = 604,
		[NL["Draenei Archaeology Find"]]        = 605,
		[NL["Orc Archaeology Find"]]            = 606,
		[NL["Nerubian Archaeology Find"]]       = 607,
		[NL["Vrykul Archaeology Find"]]         = 608,
		[NL["Tol'vir Archaeology Find"]]        = 609,
		[NL["Other Archaeology Find"]]          = 610,
	}
}
GatherMate.nodeIDs = node_ids
local reverse = {}
for k,v in pairs(node_ids) do
	reverse[k] = GatherMate:CreateReversedTable(v)
end
GatherMate.reverseNodeIDs = reverse
-- Special fix because "Battered Chest" (502) and "Tattered Chest" (503) both translate to "Ramponierte Truhe" in deDE
if GetLocale() == "deDE" then GatherMate.reverseNodeIDs["Treasure"][502] = "Ramponierte Truhe" end

--[[
	Collector data for rare spawn determination
]]
local Collector = GatherMate:GetModule("Collector")
--[[
	Rare spawns are formatted as such the rareid = [nodes it replaces]
]]
local rare_spawns = {
	[204] = {[202]=true,[203]=true}, -- silver
	[205] = {[203]=true,[206]=true}, -- gold
	[208] = {[206]=true,[214]=true,[215]=true}, -- truesilver
	[209] = {[212]=true,[213]=true,[207]=true}, -- oozed covered silver
	[210] = {[212]=true,[213]=true,[207]=true}, -- ooze covered gold
	[211] = {[212]=true,[213]=true,[207]=true}, -- oozed covered true silver
	[217] = {[206]=true,[214]=true,[215]=true}, -- dark iron
	[224] = {[222]=true,[223]=true,[221]=true}, -- khorium
	[223] = {[222]=true}, -- rich adamantite
	[229] = {[228]=true}, -- rich cobalt node
	[232] = {[231]=true}, -- rich saronite node
	[230] = {[231]=true}, -- titanium node
	[441] = {[440]=true}, --flame cap
	[136] = {[108]=true}, -- sage fish
	[137] = {[107]=true}, --oily
	[138] = {[107]=true}, --oily
	[139] = {[107]=true}, --oily
	[140] = {[107]=true}, --oily
	[141] = {[105]=true}, --snapper
	[142] = {[105]=true}, --snapper
	[143] = {[105]=true}, --snapper
	[144] = {[105]=true}, --snapper
	[145] = {[103]=true}, --debris
	[146] = {[133]=true}, --schooner
	[147] = {[135]=true}, --bloodsail
	[148] = {[101]=true}, -- floating wreckage
	[233] = {[234]=true}, -- obsidian
	[236] = {[237]=true}, -- elementium
}
Collector.rareNodes = rare_spawns
-- Format zone = { "Database", "new node id"}
local nodeRemap = {
	[78] = { ["Herb Gathering"] = 452},
	[73] = { ["Herb Gathering"] = 452},
}
Collector.specials = nodeRemap
--[[
	Below are Display Module Constants
]]
local Display = GatherMate:GetModule("Display")
local icon_path = "Interface\\AddOns\\GatherMate2\\Artwork\\"
Display.trackingCircle = icon_path.."track_circle.tga"
-- Find xxx spells
Display:SetTrackingSpell("Mining", 2580)
Display:SetTrackingSpell("Herb Gathering", 2383)
Display:SetTrackingSpell("Fishing", 43308)
Display:SetTrackingSpell("Treasure", 2481) -- Left this in, however it appears that the spell no longer exists. Maybe added as a potion TreasureFindingPotion
-- Profession markers
Display:SetSkillProfession("Herb Gathering", L["Herbalism"])
Display:SetSkillProfession("Mining", L["Mining"])
Display:SetSkillProfession("Fishing", L["Fishing"])
Display:SetSkillProfession("Extract Gas", L["Engineering"])
Display:SetSkillProfession("Archaeology", L["Archaeology"])

--[[
	Textures for display
]]
local node_textures = {
	["Fishing"] = {
		[101] = icon_path.."Fish\\treasure.tga",
		[102] = icon_path.."Fish\\purewater.tga",
		[103] = icon_path.."Fish\\debris.tga",
		[104] = icon_path.."Fish\\oilspill.tga",
		[105] = icon_path.."Fish\\firefin.tga",
		[106] = icon_path.."Fish\\greater_sagefish.tga",
		[107] = icon_path.."Fish\\oilyblackmouth.tga",
		[108] = icon_path.."Fish\\sagefish.tga",
		[109] = icon_path.."Fish\\firefin.tga",
		[110] = icon_path.."Fish\\eel.tga",
		[111] = icon_path.."Fish\\net.tga",
		[112] = icon_path.."Fish\\fish_hook.tga",
		[113] = icon_path.."Fish\\purewater.tga",
		[114] = icon_path.."Fish\\bluefish.tga",
		[115] = icon_path.."Fish\\feltail.tga",
		[116] = icon_path.."Fish\\mudfish.tga",
		[117] = icon_path.."Fish\\darter.tga",
		[118] = icon_path.."Fish\\sporefish.tga",
		[119] = icon_path.."Fish\\steampump.tga",
		[120] = icon_path.."Fish\\net.tga",
		[121] = icon_path.."Fish\\manowar.tga",
		[122] = icon_path.."Fish\\net.tga",
		[123] = icon_path.."Fish\\anglefish.tga",
		[124] = icon_path.."Fish\\herring.tga",
		[125] = icon_path.."Fish\\treasure.tga",
		[126] = icon_path.."Fish\\salmon.tga",
		[127] = icon_path.."Fish\\minnow.tga",
		[128] = icon_path.."Fish\\manta.tga",
		[129] = icon_path.."Fish\\bonescale.tga",
		[130] = icon_path.."Fish\\musselback.tga",
		[131] = icon_path.."Fish\\nettlefish.tga",
		[132] = icon_path.."Fish\\purewater.tga",
		[133] = icon_path.."Fish\\treasure.tga",
		[134] = icon_path.."Fish\\treasure.tga",
		[135] = icon_path.."Fish\\treasure.tga",
		[136] = icon_path.."Fish\\sagefish.tga",
		[137] = icon_path.."Fish\\oilyblackmouth.tga",
		[138] = icon_path.."Fish\\oilyblackmouth.tga",
		[139] = icon_path.."Fish\\oilyblackmouth.tga",
		[140] = icon_path.."Fish\\oilyblackmouth.tga",
		[141] = icon_path.."Fish\\firefin.tga",
		[142] = icon_path.."Fish\\firefin.tga",
		[143] = icon_path.."Fish\\firefin.tga",
		[144] = icon_path.."Fish\\firefin.tga",
		[145] = icon_path.."Fish\\debris.tga",
		[146] = icon_path.."Fish\\treasure.tga",
		[147] = icon_path.."Fish\\treasure.tga",
		[148] = icon_path.."Fish\\treasure.tga",
	},
	["Mining"] = {
		[201] = icon_path.."Mine\\copper.tga",
		[202] = icon_path.."Mine\\tin.tga",
		[203] = icon_path.."Mine\\iron.tga",
		[204] = icon_path.."Mine\\silver.tga",
		[205] = icon_path.."Mine\\gold.tga",
		[206] = icon_path.."Mine\\mithril.tga",
		[207] = icon_path.."Mine\\mithril.tga",
		[208] = icon_path.."Mine\\truesilver.tga",
		[209] = icon_path.."Mine\\silver.tga",
		[210] = icon_path.."Mine\\gold.tga",
		[211] = icon_path.."Mine\\truesilver.tga",
		[212] = icon_path.."Mine\\rich_thorium.tga",
		[213] = icon_path.."Mine\\thorium.tga",
		[214] = icon_path.."Mine\\thorium.tga",
		[215] = icon_path.."Mine\\rich_thorium.tga",
		[216] = icon_path.."Mine\\rich_thorium.tga",
		[217] = icon_path.."Mine\\darkiron.tga",
		[218] = icon_path.."Mine\\blood_iron.tga",
		[219] = icon_path.."Mine\\darkiron.tga",
		[220] = icon_path.."Mine\\blood_iron.tga",
		[221] = icon_path.."Mine\\feliron.tga",
		[222] = icon_path.."Mine\\adamantium.tga",
		[223] = icon_path.."Mine\\rich_adamantium.tga",
		[224] = icon_path.."Mine\\khorium.tga",
		[225] = icon_path.."Mine\\ethernium.tga",
		[226] = icon_path.."Mine\\ethernium.tga",
		[227] = icon_path.."Mine\\ethernium.tga",
		-- place holder graphic
		[228] = icon_path.."Mine\\cobalt.tga",
		[229] = icon_path.."Mine\\cobalt.tga",
		[230] = icon_path.."Mine\\titanium.tga",
		[231] = icon_path.."Mine\\saronite.tga",
		[232] = icon_path.."Mine\\saronite.tga",
		[233] = icon_path.."Mine\\obsidian.tga",
		[234] = icon_path.."Mine\\store_tablet.tga",
		[235] = icon_path.."Mine\\saronite.tga",
		[236] = icon_path.."Mine\\elementium.tga",
		[237] = icon_path.."Mine\\elementium.tga",
		[238] = icon_path.."Mine\\pyrite.tga",
	},
	["Extract Gas"] = {
		[301] = icon_path.."Gas\\windy_cloud.tga",
		[302] = icon_path.."Gas\\swamp_gas.tga",
		[303] = icon_path.."Gas\\arcane_vortex.tga",
		[304] = icon_path.."Gas\\felmist.tga",
		[305] = icon_path.."Gas\\steam.tga",
		[306] = icon_path.."Gas\\cinder.tga",
		[307] = icon_path.."Gas\\arctic.tga",
	},
	["Herb Gathering"] = {
		[401] = icon_path.."Herb\\peacebloom.tga",
		[402] = icon_path.."Herb\\silverleaf.tga",
		[403] = icon_path.."Herb\\earthroot.tga",
		[404] = icon_path.."Herb\\mageroyal.tga",
		[405] = icon_path.."Herb\\briarthorn.tga",
		[406] = icon_path.."Herb\\earthroot.tga",
		[407] = icon_path.."Herb\\stranglekelp.tga",
		[408] = icon_path.."Herb\\bruiseweed.tga",
		[409] = icon_path.."Herb\\wild_steelbloom.tga",
		[410] = icon_path.."Herb\\grave_moss.tga",
		[411] = icon_path.."Herb\\kingsblood.tga",
		[412] = icon_path.."Herb\\liferoot.tga",
		[413] = icon_path.."Herb\\fadeleaf.tga",
		[414] = icon_path.."Herb\\goldthorn.tga",
		[415] = icon_path.."Herb\\khadgars_whisker.tga",
		[416] = icon_path.."Herb\\wintersbite.tga",
		[417] = icon_path.."Herb\\firebloom.tga",
		[418] = icon_path.."Herb\\purple_lotus.tga",
		[419] = icon_path.."Herb\\purple_lotus.tga",
		[420] = icon_path.."Herb\\arthas_tears.tga",
		[421] = icon_path.."Herb\\sungrass.tga",
		[422] = icon_path.."Herb\\blindweed.tga",
		[423] = icon_path.."Herb\\ghost_mushroom.tga",
		[424] = icon_path.."Herb\\gromsblood.tga",
		[425] = icon_path.."Herb\\golden_sansam.tga",
		[426] = icon_path.."Herb\\dreamfoil.tga",
		[427] = icon_path.."Herb\\mountain_silversage.tga",
		[428] = icon_path.."Herb\\plaguebloom.tga",
		[429] = icon_path.."Herb\\icecap.tga",
		[430] = icon_path.."Herb\\purple_lotus.tga",
		[431] = icon_path.."Herb\\black_lotus.tga",
		[432] = icon_path.."Herb\\felweed.tga",
		[433] = icon_path.."Herb\\dreaming_glory.tga",
		[434] = icon_path.."Herb\\terocone.tga",
		[435] = icon_path.."Herb\\ancient_lichen.tga",
		[436] = icon_path.."Herb\\stranglekelp.tga",
		[437] = icon_path.."Herb\\mana_thistle.tga",
		[438] = icon_path.."Herb\\netherbloom.tga",
		[439] = icon_path.."Herb\\nightmare_vine.tga",
		[440] = icon_path.."Herb\\ragveil.tga",
		[441] = icon_path.."Herb\\flame_cap.tga",
		[442] = icon_path.."Herb\\netherdust.tga",
		-- place holder graphic
		[443] = icon_path.."Herb\\evergreen.tga",
		[444] = icon_path.."Herb\\constrictor.tga",
		[445] = icon_path.."Herb\\constrictor.tga",
		[446] = icon_path.."Herb\\goldclover.tga",
		[447] = icon_path.."Herb\\icethorn.tga",
		[448] = icon_path.."Herb\\whispervine.tga",
		[449] = icon_path.."Herb\\trose.tga",
		[450] = icon_path.."Herb\\tigerlily.tga",
		[451] = icon_path.."Herb\\briarthorn.tga",
		[452] = icon_path.."Herb\\misc_flower.tga",
		[453] = icon_path.."Herb\\frostlotus.tga",
		[454] = icon_path.."Herb\\dragonsteeth.tga",
		[455] = icon_path.."Herb\\whiptail.tga",
		[456] = icon_path.."Herb\\azsharasveil.tga",
		[457] = icon_path.."Herb\\cinderbloom.tga",
		[458] = icon_path.."Herb\\stormvine.tga",
		[459] = icon_path.."Herb\\heartblossom.tga",
		[460] = icon_path.."Herb\\twilightjasmine.tga",
	},
	["Treasure"] = {
		[501] = icon_path.."Treasure\\clam.tga",
		[502] = icon_path.."Treasure\\chest.tga",
		[503] = icon_path.."Treasure\\chest.tga",
		[504] = icon_path.."Treasure\\chest.tga",
		[505] = icon_path.."Treasure\\chest.tga",
		[506] = icon_path.."Treasure\\chest.tga",
		[507] = icon_path.."Treasure\\hest.tga",
		[508] = icon_path.."Treasure\\chest.tga",
		[509] = icon_path.."Treasure\\chest.tga",
		[510] = icon_path.."Treasure\\chest.tga",
		[511] = icon_path.."Treasure\\soil.tga",
		[512] = icon_path.."Treasure\\sprout.tga",
		[513] = icon_path.."Treasure\\blood.tga",
		[514] = icon_path.."Treasure\\footlocker.tga",
		[515] = icon_path.."Treasure\\footlocker.tga",
		[516] = icon_path.."Treasure\\footlocker.tga",
		[517] = icon_path.."Treasure\\footlocker.tga",
		[518] = icon_path.."Treasure\\footlocker.tga",
		[519] = icon_path.."Treasure\\footlocker.tga",
		[520] = icon_path.."Treasure\\chest.tga",
		[521] = icon_path.."Treasure\\treasure.tga",
		[522] = icon_path.."Treasure\\treasure.tga",
		[523] = icon_path.."Treasure\\treasure.tga",
		[524] = icon_path.."Treasure\\treasure.tga",
		[525] = icon_path.."Treasure\\mushroom.tga",
		[526] = icon_path.."Treasure\\treasure.tga",
		[527] = icon_path.."Treasure\\treasure.tga",
		[528] = icon_path.."Treasure\\tresure.tga",
		[529] = icon_path.."Treasure\\treasure.tga",
		[530] = icon_path.."Treasure\\treasure.tga",
		[531] = icon_path.."Treasure\\egg.tga",
		[532] = icon_path.."Treasure\\everfrost.tga",
		[533] = icon_path.."Treasure\\egg.tga",
	},
	["Archaeology"] = {
		[601] = icon_path.."Archaeology\\shovel.tga",
		[602] = icon_path.."Archaeology\\shovel.tga",
		[603] = icon_path.."Archaeology\\shovel.tga",
		[604] = icon_path.."Archaeology\\shovel.tga",
		[605] = icon_path.."Archaeology\\shovel.tga",
		[606] = icon_path.."Archaeology\\shovel.tga",
		[607] = icon_path.."Archaeology\\shovel.tga",
		[608] = icon_path.."Archaeology\\shovel.tga",
		[609] = icon_path.."Archaeology\\shovel.tga",
		[610] = icon_path.."Archaeology\\shovel.tga",
	},
}
GatherMate.nodeTextures = node_textures
--[[
	Min level to harvest
]]
local node_minharvest = {
	["Fishing"] = {
	},
	["Mining"] = {
		[201] = 1,
		[202] = 65,
		[203] = 125,
		[204] = 75,
		[205] = 155,
		[206] = 175,
		[207] = 175,
		[208] = 230,
		[209] = 75,
		[210] = 155,
		[211] = 230,
		[212] = 255,
		[213] = 230,
		[214] = 230,
		[215] = 255,
		[216] = 255,
		[217] = 230,
		[218] = 75,
		[219] = 65,
		[220] = 150,
		[221] = 275,
		[222] = 325,
		[223] = 350,
		[224] = 375,
		[225] = 305,
		[226] = 305,
		[227] = 275,
		[228] = 350,
		[229] = 375,
		[230] = 450,
		[231] = 400,
		[232] = 425,
		[233] = 450,
		[234] = 450,
		[235] = 500,
		[236] = 450,
		[237] = 500,
		[238] = 525,
	},
	["Extract Gas"] = {
		[301] = 305,
		[302] = 305,
		[303] = 305,
		[304] = 305,
		[305] = 305,
		[306] = 305,
		[307] = 305,
	},
	["Herb Gathering"] = {
		[401] = 1,
		[402] = 1,
		[403] = 15,
		[404] = 50,
		[405] = 70,
		[406] = 15,
		[407] = 85,
		[408] = 100,
		[409] = 115,
		[410] = 120,
		[411] = 125,
		[412] = 150,
		[413] = 160,
		[414] = 170,
		[415] = 185,
		[416] = 195,
		[417] = 205,
		[418] = 210,
		[419] = 210,
		[420] = 220,
		[421] = 230,
		[422] = 235,
		[423] = 245,
		[424] = 250,
		[425] = 260,
		[426] = 270,
		[427] = 280,
		[428] = 285,
		[429] = 290,
		[430] = 300,
		[431] = 300,
		[432] = 300,
		[433] = 315,
		[434] = 325,
		[435] = 340,
		[436] = 1,
		[437] = 375,
		[438] = 350,
		[439] = 365,
		[440] = 325,
		[441] = 335,
		[442] = 350,
		[443] = 400,
		--[444] = ??, Constrictor Grass
		--[445] = ??, Deadnettle
		[446] = 350,
		[447] = 435,
		[448] = 425,
		[449] = 385,
		[450] = 375,
		[451] = 360,
		[452] = 415,
		[452] = 425,
		[453] = 425,
		[454] = 195,
		[455] = 285,
		[456] = 425,
		[457] = 425,
		[458] = 425,
		[459] = 475,
		[460] = 525,
	},
	["Treasure"] = {
	},
	["Archaeology"] = {
	},
}
GatherMate.nodeMinHarvest = node_minharvest
--[[
	Minimap scale settings for zoom
]]
local minimap_size = {
	indoor = {
		[0] = 300, -- scale
		[1] = 240, -- 1.25
		[2] = 180, -- 5/3
		[3] = 120, -- 2.5
		[4] = 80,  -- 3.75
		[5] = 50,  -- 6
	},
	outdoor = {
		[0] = 466 + 2/3, -- scale
		[1] = 400,       -- 7/6
		[2] = 333 + 1/3, -- 1.4
		[3] = 266 + 2/6, -- 1.75
		[4] = 200,       -- 7/3
		[5] = 133 + 1/3, -- 3.5
	},
}
Display.minimapSize = minimap_size
--[[
	Minimap shapes lookup table to determine round of not
	borrowed from strolobe for faster lookups
]]
local minimap_shapes = {
	-- { upper-left, lower-left, upper-right, lower-right }
	["SQUARE"]                = { false, false, false, false },
	["CORNER-TOPLEFT"]        = { true,  false, false, false },
	["CORNER-TOPRIGHT"]       = { false, false, true,  false },
	["CORNER-BOTTOMLEFT"]     = { false, true,  false, false },
	["CORNER-BOTTOMRIGHT"]    = { false, false, false, true },
	["SIDE-LEFT"]             = { true,  true,  false, false },
	["SIDE-RIGHT"]            = { false, false, true,  true },
	["SIDE-TOP"]              = { true,  false, true,  false },
	["SIDE-BOTTOM"]           = { false, true,  false, true },
	["TRICORNER-TOPLEFT"]     = { true,  true,  true,  false },
	["TRICORNER-TOPRIGHT"]    = { true,  false, true,  true },
	["TRICORNER-BOTTOMLEFT"]  = { true,  true,  false, true },
	["TRICORNER-BOTTOMRIGHT"] = { false, true,  true,  true },
}
Display.minimapShapes = minimap_shapes
