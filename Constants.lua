--[[
	Below are constants needed for DB storage and retrieval
	The core of gathermate handles adding new node that collector finds
	data shared between Collector and Display also live in GatherMate for sharing like zone_data for sizes, and node ids with reverses for display and comparison
	Credit to Astrolabe (http://www.gathereraddon.com) for lookup tables used in GatherMate. Astrolabe is licensed LGPL
]]
local GatherMate = LibStub("AceAddon-3.0"):GetAddon("GatherMate2")
local L = LibStub("AceLocale-3.0"):GetLocale("GatherMate2")

--[[
	Node Identifiers
]]
local node_ids = {
	["Fishing"] = {
		["Floating Wreckage"] 				= 101, -- treasure.tga
		--["Patch of Elemental Water"] 		= 102, -- purewater.tga
		["Floating Debris"]					= 103, -- debris.tga
		--["Oil Spill"] 					= 104, -- oilspill.tga
		["Firefin Snapper School"] 			= 105, -- firefin.tga
		["Greater Sagefish School"] 		= 106, -- greatersagefish.tga
		["Oily Blackmouth School"] 			= 107, -- oilyblackmouth.tga
		["Sagefish School"] 				= 108, -- sagefish.tga
		["School of Deviate Fish"] 			= 109, -- firefin.tga
		["Stonescale Eel Swarm"] 			= 110, -- eel.tga
		--["Muddy Churning Water"] 			= 111, -- ZG only fishing node
		-- BC pools
		["Highland Mixed School"] 			= 112, -- fishhook.tga
		["Pure Water"] 						= 113, -- purewater.tga
		["Bluefish School"] 				= 114, -- bluefish,tga
		["Feltail School"] 					= 115, -- feltail.tga
		["Brackish Mixed School"]         	= 115, -- feltail.tga
		["Mudfish School"] 					= 116, -- mudfish.tga
		["School of Darter"] 				= 117, -- darter.tga
		["Sporefish School"] 				= 118, -- sporefish.tga
		["Steam Pump Flotsam"] 				= 119, -- steampump.tga
		["School of Tastyfish"] 			= 120, -- net.tga
		-- WotLK Pools
		["Borean Man O' War School"]        = 121,
		["Deep Sea Monsterbelly School"]	= 122,
		["Dragonfin Angelfish School"]		= 123,
		["Fangtooth Herring School"]		= 124,
		["Floating Wreckage Pool"]			= 125,
		["Glacial Salmon School"]			= 126,
		["Glassfin Minnow School"]			= 127,
		["Imperial Manta Ray School"]		= 128,
		["Moonglow Cuttlefish School"]		= 129,
		["Musselback Sculpin School"]		= 130,
		["Nettlefish School"]				= 131,
		["Strange Pool"]					= 132,
		["Schooner Wreckage"]			    = 133,
		["Waterlogged Wreckage Pool"]		= 134,
		["Bloodsail Wreckage Pool"]			= 135,
		["Mixed Ocean School"]				= 136,
		-- Begin tediuous prefix mapping
		--["Lesser Sagefish School"]		= 136, -- sagefish.tga
		--["Lesser Oily Blackmouth School"] = 137, -- oilyblackmouth.tga
		--["Sparse Oily Blackmouth School"] = 138, -- oilyblackmouth.tga
		--["Abundant Oily Blackmouth School"]	= 139, -- oilyblackmouth.tga
		--["Teeming Oily Blackmouth School"]= 140, -- oilyblackmouth.tga
		--["Lesser Firefin Snapper School"] = 141, -- firefin.tga
		--["Sparse Firefin Snapper School"] = 142, -- firefin.tga
		--["Abundant Firefin Snapper School"]= 143, -- firefin.tga
		--["Teeming Firefin Snapper School"]= 144, -- firefin.tga
		--["Lesser Floating Debris"] 		= 145, -- debris.tga
		--["Sparse Schooner Wreckage"]		= 146,
		--["Abundant Bloodsail Wreckage"]	= 147,
		--["Teeming Floating Wreckage"]		= 148,
		["Albino Cavefish School"]			= 149,
		--["Algaefin Rockfish School"]		= 150,
		["Blackbelly Mudfish School"]		= 151,
		["Fathom Eel Swarm"]				= 152,
		["Highland Guppy School"]			= 153,
		["Mountain Trout School"]			= 154,
		["Pool of Fire"]					= 155,
		["Shipwreck Debris"]				= 156,
		["Deepsea Sagefish School"]			= 157,
		-- Mists Pools
		["Emperor Salmon School"]			= 158,
		["Giant Mantis Shrimp Swarm"]		= 159,
		["Golden Carp School"]				= 160,
		["Jade Lungfish School"]			= 161,
		["Krasarang Paddlefish School"]		= 162,
		["Redbelly Mandarin School"]		= 163,
		["Reef Octopus Swarm"]				= 164,
		["Floating Shipwreck Debris"]		= 165,
		["Jewel Danio School"]				= 166,
		["Spinefish School"]				= 167,
		["Tiger Gourami School"]			= 168,
		-- WoD Pools
		["Abyssal Gulper School"]			= 169,
		["Oily Abyssal Gulper School"]		= 170,
		["Blackwater Whiptail School"]		= 171,
		["Blind Lake Sturgeon School"]		= 172,
		["Fat Sleeper School"]				= 173,
		["Fire Ammonite School"]			= 174,
		["Jawless Skulker School"]			= 175,
		["Sea Scorpion School"]				= 176,
		["Oily Sea Scorpion School"]		= 177,
		["Savage Piranha Pool"]				= 178,
		--["Lagoon Pool"]						= 179,
		--["Sparkling Pool"]					= 180,
		["Felmouth Frenzy School"]			= 181,
		-- Legion Pools
		["Black Barracuda School"]			= 182,
		["Cursed Queenfish School"]			= 183,
		["Runescale Koi School"]			= 184,
		["Fever of Stormrays"]				= 185,
		["Highmountain Salmon School"]		= 186,
		["Mossgill Perch School"]			= 187,
		-- BfA Pools
		["Frenzied Fangtooth School"]		= 188,
		["Great Sea Catfish School"]		= 189,
		["Lane Snapper School"]				= 190,
		["Rasboralus School"]				= 191,
		["Redtail Loach School"]			= 192,
		["Sand Shifter School"]				= 193,
		["Slimy Mackerel School"]			= 194,
		["Tiragarde Perch School"]			= 195,
		["U'taka School"]					= 196,
		["Mauve Stinger School"]			= 197,
		["Viper Fish School"]				= 198,
		["Ionized Minnows"]					= 199,
		["Sentry Fish School"]				= 1101,
		-- Shadowlands pools
		["Iridescent Amberjack School"]		= 1102,
		["Pocked Bonefish School"]			= 1103,
		["Silvergill Pike School"]			= 1104,
		["Elysian Thade School"]			= 1105,
		["Lost Sole School"]				= 1106,
		["Spinefin Piranha School"]			= 1107,
		["Precursor Placoderm School"]		= 1108,
		-- Dragonflight pools
		-- general
		["Islefin Dorado Pool"]				= 1109,
		["Shimmering Treasure Pool"]		= 1110,
		-- freshwater
		["Temporal Dragonhead Pool"]		= 1111,
		["Thousandbite Pirahna Swarm"]		= 1112,
		-- saltwater
		["Aileron Seamoth School"]			= 1113,
		["Cerulean Spinefish School"]		= 1114,
		-- special
		["Rimefin Tuna Pool"]				= 1115,
		["Magma Thresher Pool"]				= 1116,
		["Prismatic Leaper School"]			= 1117,
		-- TWW Pools
		["Calm Surfacing Ripple"]			= 1118,
		["River Bass Pool"]					= 1119,
		["Glimmerpool"]						= 1120,
		["Bloody Perch Swarm"]				= 1121,
		["Swarm of Slum Sharks"]			= 1122,
		["Blood in the Water"]				= 1123,
		["Festering Rotpool"]				= 1124,
		["Infused Ichor Spill"]				= 1125,
		["Stargazer Swarm"]					= 1126,
		["Anglerseeker Torrent"]			= 1127,
		["Royal Ripple"]					= 1128,
		["Shore Treasure"]					= 1129,
		["Floating Deep Treasure"]			= 1130,
		-- Midnight pools
		["Bloom Swarm"]						= 1131,
		["Blossoming Torrent"]				= 1132,
		["Bubbling Bloom"]					= 1133,
		["Hunter Surge"]					= 1134,
		["Lashing Waves"]					= 1135,
		["Obscured School"]					= 1136,
		["Salmon Pool"]						= 1137,
		["Song Swarm"]						= 1138,
		["Sunbath School"]					= 1139,
		["Sunwell Swarm"]					= 1140,
		["Surface Ripple"]					= 1141,
		["Careless Cargo"]					= 1142,
		["Lost Treasures"]					= 1143,
		["Viscous Void"]					= 1144,
	},
	["Mining"] = {
		["Copper Vein"] 					= 201,
		["Tin Vein"] 						= 202,
		["Iron Deposit"] 					= 203,
		["Silver Vein"] 					= 204,
		["Gold Vein"] 						= 205,
		["Mithril Deposit"] 				= 206,
		["Ooze Covered Mithril Deposit"]	= 207,
		["Truesilver Deposit"] 				= 208,
		["Ooze Covered Silver Vein"] 		= 209,
		["Ooze Covered Gold Vein"] 			= 210,
		["Ooze Covered Truesilver Deposit"] = 211,
		["Ooze Covered Rich Thorium Vein"] 	= 212,
		["Ooze Covered Thorium Vein"] 		= 213,
		["Small Thorium Vein"] 				= 214,
		["Rich Thorium Vein"] 				= 215,
		--["Hakkari Thorium Vein"] 			= 216, -- found on in ZG
		["Dark Iron Deposit"] 				= 217,
		["Lesser Bloodstone Deposit"] 		= 218,
		["Incendicite Mineral Vein"] 		= 219,
		["Indurium Mineral Vein"]			= 220,
-- bc nodes
		["Fel Iron Deposit"] 				= 221,
		["Adamantite Deposit"] 				= 222,
		["Rich Adamantite Deposit"] 		= 223,
		["Khorium Vein"] 					= 224,
		["Large Obsidian Chunk"] 			= 225, -- found only in AQ20/40
		["Small Obsidian Chunk"] 			= 226, -- found only in AQ20/40
		["Nethercite Deposit"] 				= 227,
-- wrath nodes
		["Cobalt Deposit"]					= 228,
		["Rich Cobalt Deposit"]				= 229,
		["Titanium Vein"]					= 230,
		["Saronite Deposit"]				= 231,
		["Rich Saronite Deposit"]			= 232,
--- Cata nodes
		["Obsidium Deposit"]				= 233,
		--["Huge Obsidian Slab"]			= 234,
		["Pure Saronite Deposit"] 			= 235,
		["Elementium Vein"]					= 236,
		["Rich Elementium Vein"]			= 237,
		["Pyrite Deposit"]					= 238,
		["Rich Obsidium Deposit"] 			= 239,
		["Rich Pyrite Deposit"] 			= 240,
-- mists nodes
		["Ghost Iron Deposit"] 				= 241,
		["Rich Ghost Iron Deposit"] 		= 242,
		--["Black Trillium Deposit"]			= 243,
		--["White Trillium Deposit"]			= 244,
		["Kyparite Deposit"]				= 245,
		["Rich Kyparite Deposit"]			= 246,
		["Trillium Vein"]					= 247,
		["Rich Trillium Vein"]				= 248,
-- wod nodes
		["True Iron Deposit"]				= 249,
		["Rich True Iron Deposit"]			= 250,
		["Blackrock Deposit"]				= 251,
		["Rich Blackrock Deposit"]			= 252,
-- legion nodes
		["Leystone Deposit"]				= 253,
		["Rich Leystone Deposit"]			= 254,
		["Leystone Seam"]					= 255,
		["Felslate Deposit"]				= 256,
		["Rich Felslate Deposit"]			= 257,
		["Felslate Seam"]					= 258,
		["Empyrium Deposit"]				= 259,
		["Rich Empyrium Deposit"]			= 260,
		["Empyrium Seam"]					= 261,
-- bfa nodes
		["Monelite Deposit"]				= 262,
		["Rich Monelite Deposit"]			= 263,
		["Monelite Seam"]					= 264,
		["Platinum Deposit"]				= 265,
		["Rich Platinum Deposit"]			= 266,
		["Storm Silver Deposit"]			= 267,
		["Rich Storm Silver Deposit"]		= 268,
		["Storm Silver Seam"]				= 269,
		["Osmenite Deposit"]				= 270,
		["Rich Osmenite Deposit"]			= 271,
		["Osmenite Seam"]					= 272,
-- shadowlands nodes
		["Laestrite Deposit"]				= 273,
		["Rich Laestrite Deposit"]			= 274,
		["Phaedrum Deposit"]				= 275,
		["Rich Phaedrum Deposit"]			= 276,
		["Oxxein Deposit"]					= 277,
		["Rich Oxxein Deposit"]				= 278,
		--["Monolithic Oxxein Deposit"]		= 279,
		["Elethium Deposit"]				= {
			id = 280,
			variants = {
				"Rich Elethium Deposit", "Elusive Elethium Deposit", "Elusive Rich Elethium Deposit"
			},
			old_ids = { 281, 291, 292 },
		},
		["Solenium Deposit"]				= 282,
		["Rich Solenium Deposit"]			= 283,
		["Sinvyr Deposit"]					= 284,
		["Rich Sinvyr Deposit"]				= 285,
		--["Menacing Sinvyr Deposit"]			= 286,
		["Progenium Deposit"]				= {
			id = 287,
			variants = {
				"Rich Progenium Deposit", "Elusive Progenium Deposit", "Elusive Rich Progenium Deposit"
			},
			old_ids = { 288, 289, 290 },
		},
-- dragonflight nodes
		["Serevite Seam"]					= 1200,
		["Serevite Deposit"]				= {
			id = 1201,
			variants = {
				"Rich Serevite Deposit", "Primal Serevite Deposit", "Molten Serevite Deposit", "Hardened Serevite Deposit", "Infurious Serevite Deposit", "Titan-Touched Serevite Deposit", "Metamorphic Serevite Deposit"
			},
			old_ids = { 1202, 1203, 1204, 1205, 1206, 1207, 1216 },
		},

		["Draconium Seam"]					= 1208,
		["Draconium Deposit"]				=
		{
			id = 1209,
			variants = {
				"Rich Draconium Deposit", "Primal Draconium Deposit", "Molten Draconium Deposit", "Hardened Draconium Deposit", "Infurious Draconium Deposit", "Titan-Touched Draconium Deposit", "Metamorphic Draconium Deposit"
			},
			old_ids = { 1210, 1211, 1212, 1213, 1214, 1215, 1217 },
		},

-- tww nodes
		["Bismuth"]							= {
			id = 1218,
			variants = {
				"Rich Bismuth", "Camouflaged Bismuth", "Crystallized Bismuth", "Weeping Bismuth", "Webbed Bismuth", "EZ-Mine Bismuth"
			},
			old_ids = { 1219, 1220, 1221, 1222, 1223, 1224 },
		},
		["Bismuth Seam"]					= 1225,

		["Aqirite"]							= {
			id = 1226,
			variants = {
				"Rich Aqirite", "Camouflaged Aqirite", "Crystallized Aqirite", "Weeping Aqirite", "Webbed Aqirite", "EZ-Mine Aqirite"
			},
			old_ids = { 1227, 1228, 1229, 1230, 1231, 1232 },
		},
		["Aqirite Seam"]					= 1233,

		["Ironclaw"]						= {
			id = 1234,
			variants = {
				"Rich Ironclaw", "Camouflaged Ironclaw", "Crystallized Ironclaw", "Weeping Ironclaw", "Webbed Ironclaw", "EZ-Mine Ironclaw"
			},
			old_ids = { 1235, 1236, 1237, 1238, 1239, 1240 },
		},
		["Ironclaw Seam"]					= 1241,

		["Webbed Ore Deposit"]				= 1242,

		["Desolate Deposit"]				= {
			id = 1243,
			variants = { "Rich Desolate Deposit" },
			old_ids = { 1244 },
		},
-- midnight nodes
		["Brilliant Silver"] = {
			id = 1245,
			variants = {
				"Rich Brilliant Silver", "Lightfused Brilliant Silver", "Primal Brilliant Silver", "Voidbound Brilliant Silver", "Wild Brilliant Silver"
			}
		},
		["Brilliant Silver Seam"] = 1246,
		["Refulgent Copper"] = {
			id = 1247,
			variants = {
				"Rich Refulgent Copper", "Lightfused Refulgent Copper", "Primal Refulgent Copper", "Voidbound Refulgent Copper", "Wild Refulgent Copper"
			}
		},
		["Refulgent Copper Seam"] = 1248,
		["Umbral Tin"] = {
			id = 1249,
			variants = {
				"Rich Umbral Tin", "Lightfused Umbral Tin", "Primal Umbral Tin", "Voidbound Umbral Tin", "Wild Umbral Tin"
			}
		},
		["Umbral Tin Seam"] = 1250,
	},
	["Extract Gas"] = {
		["Windy Cloud"] 					= 301,
		["Swamp Gas"] 						= 302,
		["Arcane Vortex"] 					= 303,
		["Felmist"] 						= 304,
		["Steam Cloud"]					    = 305,
		["Cinder Cloud"]					= 306,
		["Arctic Cloud"]					= 307,
	},
	["Herb Gathering"] = {
		["Peacebloom"] 						= 401,
		["Silverleaf"] 						= 402,
		["Earthroot"] 						= 403,
		["Mageroyal"] 						= 404,
		["Briarthorn"] 						= 405,
		--["Swiftthistle"] 					= 406, -- found it briathorn nodes
		["Stranglekelp"] 					= 407,
		["Bruiseweed"] 						= 408,
		["Wild Steelbloom"] 				= 409,
		["Grave Moss"] 						= 410,
		["Kingsblood"] 						= 411,
		["Liferoot"] 						= 412,
		["Fadeleaf"] 						= 413,
		["Goldthorn"] 						= 414,
		["Khadgar's Whisker"] 				= 415,
		["Wintersbite"] 					= 416,
		["Firebloom"] 						= 417,
		["Purple Lotus"] 					= 418,
		--["Wildvine"] 						= 419, -- found in purple lotus nodes
		["Arthas' Tears"] 					= 420,
		["Sungrass"] 						= 421,
		["Blindweed"] 						= 422,
		["Ghost Mushroom"] 					= 423,
		["Gromsblood"] 						= 424,
		["Golden Sansam"] 					= 425,
		["Dreamfoil"] 						= 426,
		["Mountain Silversage"] 			= 427,
		["Plaguebloom"] 					= 428,
		["Icecap"] 							= 429,
		--["Bloodvine"] 					= 430, -- zg bush loot
		["Black Lotus"] 					= 431,
-- bc nodes
		["Felweed"] 						= 432,
		["Dreaming Glory"] 					= 433,
		["Terocone"] 						= 434,
		["Ancient Lichen"] 					= 435, -- instance only node
		["Bloodthistle"] 					= 436,
		["Mana Thistle"] 					= 437,
		["Netherbloom"] 					= 438,
		["Nightmare Vine"] 					= 439,
		["Ragveil"] 						= 440,
		["Flame Cap"] 						= 441,
		["Netherdust Bush"] 				= 442,
-- wotlk nodes
		["Adder's Tongue"]					= 443,
		--["Constrictor Grass"]				= 444, -- drop form others
		--["Deadnettle"]					= 445, --looted from other plants
		["Goldclover"]						= 446,
		["Icethorn"]						= 447,
		["Lichbloom"]						= 448,
		["Talandra's Rose"]					= 449,
		["Tiger Lily"]						= 450,
		["Firethorn"]						= 451,
		["Frozen Herb"]						= 452,
		["Frost Lotus"]						= 453, -- found in lake wintergrasp only
-- cata nodes
		["Dragon's Teeth"]					= 454,
		["Sorrowmoss"]						= 455,
		["Azshara's Veil"]					= 456,
		["Cinderbloom"]						= 457,
		["Stormvine"]						= 458,
		["Heartblossom"]					= 459,
		["Twilight Jasmine"]				= 460,
		["Whiptail"]						= 461,
-- mist nodes
		["Golden Lotus"]					= 462,
		["Fool's Cap"]						= 463,
		["Snow Lily"]						= 464,
		["Silkweed"]						= 465,
		["Green Tea Leaf"]					= 466,
		["Rain Poppy"]						= 467,
		["Sha-Touched Herb"]				= 468,
-- wod nodes
		["Talador Orchid"]					= 469,
		["Nagrand Arrowbloom"]				= 470,
		["Starflower"]						= 471,
		["Gorgrond Flytrap"]				= 472,
		["Fireweed"]						= 473,
		["Frostweed"]						= 474,
		["Withered Herb"]					= 475,
-- legion nodes
		["Aethril"]							= 476,
		["Dreamleaf"]						= 477,
		["Felwort"]							= 478,
		["Fjarnskaggl"]						= 479,
		["Foxflower"]						= 480,
		["Starlight Rose"]					= 481,
		["Fel-Encrusted Herb"]				= 482,
		["Fel-Encrusted Herb Cluster"]		= 483,
		["Astral Glory"]					= 484,
-- bfa nodes
		["Akunda's Bite"]					= 485,
		["Anchor Weed"]						= 486,
		["Riverbud"]						= 487,
		["Sea Stalks"]						= 488,
		["Siren's Sting"]					= 489,
		["Star Moss"]						= 490,
		["Winter's Kiss"]					= 491,
		["Zin'anthid"]						= 492,
-- shadowlands nodes
		["Death Blossom"]					= 493,
		["Nightshade"] = {
			id = 494,
			variants = {
				"Lush Nightshade", "Elusive Nightshade", "Lush Elusive Nightshade"
			},
			old_ids = { 1401, 1402, 1406 },
		},
		["Marrowroot"]						= 495,
		["Vigil's Torch"]					= 496,
		["Rising Glory"]					= 497,
		["Widowbloom"]						= 498,
		["First Flower"] = {
			id = 499,
			variants = {
				"Lush First Flower", "Elusive First Flower", "Lush Elusive First Flower"
			},
			old_ids = { 1403, 1404, 1405 },
		},
-- dragonflight nodes
		["Hochenblume"] = {
			id = 1407,
			variants = {
				"Lush Hochenblume", "Frigid Hochenblume", "Decayed Hochenblume", "Windswept Hochenblume", "Infurious Hochenblume", "Titan-Touched Hochenblume", "Lambent Hochenblume"
			},
			old_ids = {	1408, 1409, 1410, 1411, 1412, 1413, 1435 },
		},

		["Bubble Poppy"] = {
			id = 1414,
			variants = {
				"Lush Bubble Poppy", "Frigid Bubble Poppy", "Decayed Bubble Poppy", "Windswept Bubble Poppy", "Infurious Bubble Poppy", "Titan-Touched Bubble Poppy", "Lambent Bubble Poppy"
			},
			old_ids = {	1415, 1416, 1417, 1418, 1419, 1420, 1436 },
		},

		["Saxifrage"] = {
			id = 1421,
			variants = {
				"Lush Saxifrage", "Frigid Saxifrage", "Decayed Saxifrage", "Windswept Saxifrage", "Infurious Saxifrage", "Titan-Touched Saxifrage", "Lambent Saxifrage"
			},
			old_ids = { 1422, 1423, 1424, 1425, 1426, 1427, 1437 },
		},

		["Writhebark"] = {
			id = 1428,
			variants = {
				"Lush Writhebark", "Frigid Writhebark", "Decayed Writhebark", "Windswept Writhebark", "Infurious Writhebark", "Titan-Touched Writhebark", "Lambent Writhebark"
			},
			old_ids = { 1429, 1430, 1431, 1432, 1433, 1434, 1438 },
		},
-- tww nodes
		["Mycobloom"]= {
			id = 1439,
			variants = {
				"Lush Mycobloom", "Irradiated Mycobloom", "Sporefused Mycobloom", "Sporelusive Mycobloom", "Crystallized Mycobloom", "Altered Mycobloom", "Camouflaged Mycobloom"
			},
			old_ids = { 1440, 1441, 1442, 1443, 1444, 1445, 1446 },
		},
		["Blessing Blossom"] = {
			id = 1447,
			variants = {
				"Lush Blessing Blossom", "Irradiated Blessing Blossom", "Sporefused Blessing Blossom", "Sporelusive Blessing Blossom", "Crystallized Blessing Blossom", "Altered Blessing Blossom", "Camouflaged Blessing Blossom"
			},
			old_ids = { 1448, 1449, 1450, 1451, 1452, 1453, 1454 },
		},
		["Luredrop"] = {
			id = 1455,
			variants = {
				"Lush Luredrop", "Irradiated Luredrop", "Sporefused Luredrop", "Sporelusive Luredrop", "Crystallized Luredrop", "Altered Luredrop", "Camouflaged Luredrop"
			},
			old_ids = { 1456, 1457, 1458, 1459, 1460, 1461, 1462 },
		},
		["Orbinid"] = {
			id = 1463,
			variants = {
				"Lush Orbinid", "Irradiated Orbinid", "Sporefused Orbinid", "Sporelusive Orbinid", "Crystallized Orbinid", "Altered Orbinid", "Camouflaged Orbinid"
			},
			old_ids = { 1464, 1465, 1466, 1467, 1468, 1469, 1470 },
		},
		["Arathor's Spear"] = {
			id = 1471,
			variants = {
				"Lush Arathor's Spear", "Irradiated Arathor's Spear", "Sporefused Arathor's Spear", "Sporelusive Arathor's Spear", "Crystallized Arathor's Spear", "Altered Arathor's Spear", "Camouflaged Arathor's Spear"
			},
			old_ids = { 1472, 1473, 1474, 1475, 1476, 1477, 1478 },
		},
		["Phantom Bloom"] = {
			id = 1479,
			variants = { "Lush Phantom Bloom" },
			old_ids = { 1480 },
		},
-- midnight nodes
		["Argentleaf"] = {
			id = 1481,
			variants = {
				"Lush Argentleaf", "Lightfused Argentleaf", "Primal Argentleaf", "Transplanted Argentleaf", "Transplanted Lush Argentleaf", "Voidbound Argentleaf", "Wild Argentleaf"
			}
		},
		["Azeroot"] = {
			id = 1482,
			variants = {
				"Lush Azeroot", "Lightfused Azeroot", "Primal Azeroot", "Transplanted Azeroot", "Transplanted Lush Azeroot", "Voidbound Azeroot", "Wild Azeroot"
			}
		},
		["Mana Lily"] = {
			id = 1483,
			variants = {
				"Lush Mana Lily", "Lightfused Mana Lily", "Primal Mana Lily", "Transplanted Mana Lily", "Transplanted Lush Mana Lily", "Voidbound Mana Lily", "Wild Mana Lily"
			}
		},
		["Sanguithorn"] = {
			id = 1484,
			variants = {
				"Lush Sanguithorn", "Lightfused Sanguithorn", "Primal Sanguithorn", "Transplanted Sanguithorn", "Transplanted Lush Sanguithorn", "Voidbound Sanguithorn", "Wild Sanguithorn"
			}
		},
		["Tranquility Bloom"] = {
			id = 1485,
			variants = {
				"Lush Tranquility Bloom", "Lightfused Tranquility Bloom", "Primal Tranquility Bloom", "Transplanted Tranquility Bloom", "Transplanted Lush Tranquility Bloom", "Voidbound Tranquility Bloom", "Wild Tranquility Bloom"
			}
		},
	},
	["Treasure"] = {
		["Giant Clam"] 						= 501,
		["Battered Chest"] 					= 502,
		["Tattered Chest"] 					= 503,
		["Solid Chest"] 					= 504,
		["Large Iron Bound Chest"] 			= 505,
		["Large Solid Chest"] 				= 506,
		["Large Battered Chest"]			= 507,
		["Buccaneer's Strongbox"] 			= 508,
		["Large Mithril Bound Chest"] 		= 509,
		["Large Darkwood Chest"] 			= 510,
		--["Un'Goro Dirt Pile"] 			= 511,
		["Bloodpetal Sprout"] 				= 512,
		--["Blood of Heroes"] 				= 513,
		["Practice Lockbox"] 				= 514,
		["Battered Footlocker"] 			= 515,
		["Waterlogged Footlocker"] 			= 516,
		["Dented Footlocker"] 				= 517,
		["Mossy Footlocker"] 				= 518,
		["Scarlet Footlocker"] 				= 519,
		["Burial Chest"] 					= 520,
		["Fel Iron Chest"] 					= 521,
		["Heavy Fel Iron Chest"] 			= 522,
		["Adamantite Bound Chest"] 			= 523,
		["Felsteel Chest"] 					= 524,
		["Glowcap"] 						= 525,
		["Wicker Chest"] 					= 526,
		["Primitive Chest"] 				= 527,
		["Solid Fel Iron Chest"] 			= 528,
		["Bound Fel Iron Chest"] 			= 529,
		["Bound Adamantite Chest"] 		    = 530, -- instance only node
		["Netherwing Egg"] 					= 531,
		["Everfrost Chip"]					= 532,
		["Brightly Colored Egg"]			= 533,
		["Silken Treasure Chest"]			= 534,
		["Sturdy Treasure Chest"]			= 535,
		["Runestone Treasure Chest"]		= 536,
		["Silverbound Treasure Chest"]		= 537,
		["Mysterious Camel Figurine"]       = 538,
		["Dark Iron Treasure Chest"]        = 539,
		["Maplewood Treasure Chest"]		= 540,
		["Takk's Nest"]						= 541,
		["Dart's Nest"]						= 542,
		["Razormaw Matriarch's Nest"]		= 543,
		["Ravasaur Matriarch's Nest"]		= 544,
		["Dark Soil"]						= 545,
		["Onyx Egg"]						= 546,
		["Trove of the Thunder King"]		= 547,
		["Highmaul Reliquary"]				= 548,
		["Suspiciously Glowing Chest"]		= 549,
		["Radiating Apexis Shard"]			= 550,
		["Gleaming Draenic Chest"]			= 551,
		-- suramar mana
		["Ancient Mana Shard"]				= 552,
		["Ancient Mana Chunk"]				= 553,
		["Ancient Mana Crystal"]			= 554,
		["Leypetal Blossom"]				= 555,
		["Leypetal Powder"]					= 556,
		["Glowing Tome"]					= 557,
		["Mana-Infused Gem"]				= 558,
		["Twice-Fortified Arcwine"]			= 559,
		-- bfa 8.2 treasures
		["Mechanized Chest"]				= 560,
		["Glimmering Chest"]				= 561,
		["Prismatic Crystal"]				= 562,
		-- 8.2.5
		["Jelly Deposit"]					= 563,
		["Large Jelly Deposit"]				= 564,
		-- Shadowlands
		["Ground Wart"]						= 565,
		-- The War Within
		["Disturbed Earth"]					= 566,
	},
	["Archaeology"] = {
		-- cata archeolgy objects
		["Night Elf Archaeology Find"]      = 601,
		["Troll Archaeology Find"]          = 602,
		["Dwarf Archaeology Find"]          = 603,
		["Fossil Archaeology Find"]         = 604,
		["Draenei Archaeology Find"]        = 605,
		["Orc Archaeology Find"]            = 606,
		["Nerubian Archaeology Find"]       = 607,
		["Vrykul Archaeology Find"]         = 608,
		["Tol'vir Archaeology Find"]        = 609,
		["Other Archaeology Find"]          = 610,
		-- pandaria
		["Pandaren Archaeology Find"]		= 611,
		["Mogu Archaeology Find"]			= 612,
		["Mantid Archaeology Find"]			= 613,
		-- draenor
		["Arakkoa Archaeology Find"]		= 614,
		["Draenor Clans Archaeology Find"]	= 615,
		["Ogre Archaeology Find"]			= 616,
		-- legion
		["Demonic Archaeology Find"]		= 617,
		["Highborne Archaeology Find"]		= 618,
		["Highmountain Tauren Archaeology Find"]	= 619,
		-- bfa
		["Drust Archaeology Find"]			= 620,
		["Zandalari Archaeology Find"]		= 621,
	},
	["Logging"] = {
		["Small Timber"]					= 701,
		["Timber"]							= 702,
		["Large Timber"]					= 703,
		-- TWW 11.2.7
		["Ironwood Lumber"]					= 704, -- itemId 245586; Classic Areas
		["Olemba Lumber"]					= 705, -- itemId 242691; BC Areas
		["Coldwind Lumber"]					= 706, -- itemId 251762; Wotlk Areas
		["Ashwood Lumber"]					= 707, -- itemId 251764; Cata Areas
		["Bamboo Lumber"]					= 708, -- itemId 251763; MoP Areas
		["Shadowmoon Lumber"]				= 709, -- itemId 251766; Draenor (By vendor for Olemba Lumber 1:1)
		["Fel-Touched Lumber"]				= 710, -- itemId 251767; Legion Areas
		["Darkpine Lumber"]					= 711, -- itemId 251768; BfA Areas
		["Arden Lumber"]					= 712, -- itemId 251772; Shadowlands Areas
		["Dragonpine Lumber"]				= 713, -- itemId 251773; Dragon Isles Areas
		["Dornic Fir Lumber"]				= 714, -- itemId 248012; Kaz Algar Areas
		-- coming soon with Midnight
		["Thalassian Lumber"]				= 715, -- itemId 256963; Midnight Areas?
	},
}
GatherMate.nodeIDs, GatherMate.reverseNodeIDs, GatherMate.nodeIDReplacementMap = GatherMate:CreateNodeLookupTables(node_ids)

-- Special fix because "Battered Chest" (502) and "Tattered Chest" (503) both translate to "Ramponierte Truhe" in deDE
if GetLocale() == "deDE" then GatherMate.reverseNodeIDs["Treasure"][502] = "Ramponierte Truhe" end

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
	[239] = {[233]=true}, -- obsidian
	[237] = {[236]=true}, -- rich elementium
	[238] = {[236]=true}, -- pyrtite
	[240] = {[236]=true}, -- rich pyrite
	[462] = {[462]=true,[463]=true,[464]=true,[465]=true,[466]=true,[467]=true,[468]=true}, -- golden lotus
	[246] = {[245]=true}, -- rich kyparite
	[242] = {[241]=true}, -- rich ghost iron
	[247] = {[242]=true,[241]=true}, -- trillium
	[248] = {[242]=true,[241]=true}, -- rich trillium
	[478] = {[476]=true,[477]=true,[479]=true,[480]=true,[481]=true}, -- felwort
	[254] = {[253]=true}, -- rich leystone deposit
	[257] = {[256]=true}, -- rich feslate deposit
	[260] = {[259]=true}, -- rich empyrium deposit
	[553] = {[552]=true}, -- ancient mana chunk
	[554] = {[552]=true,[553]=true}, -- ancient mana crystal
	[483] = {[482]=true}, -- Fel-encrusted Herb Cluster
	[263] = {[262]=true}, -- rich monelite deposit
	[266] = {[265]=true}, -- rich platinum deposit
	[268] = {[267]=true}, -- rich storm silver deposit
	[486] = {[485]=true,[487]=true,[488]=true,[491]=true,[492]=true}, -- anchor weed
	[271] = {[270]=true}, -- rich osmenite deposit
	[564] = {[563]=true}, -- large jelly deposit
	[273] = {[275]=true,[276]=true,[277]=true,[278]=true,[282]=true,[283]=true,[284]=true,[285]=true}, -- laestrite deposit
	[274] = {[273]=true,[275]=true,[276]=true,[277]=true,[278]=true,[282]=true,[283]=true,[284]=true,[285]=true}, -- rich laestrite deposit
	[276] = {[275]=true}, -- rich phaedrum deposit
	[278] = {[277]=true}, -- rich oxxein deposit
	[280] = {[273]=true,[274]=true,[275]=true,[276]=true,[277]=true,[278]=true,[282]=true,[283]=true,[284]=true,[285]=true}, -- elethium deposit
	[283] = {[282]=true}, -- rich solenium deposit
	[285] = {[284]=true}, -- rich sinvyr deposit
	[494] = {[493]=true,[495]=true,[496]=true,[497]=true,[498]=true}, -- nightshade
	[493] = {[495]=true,[496]=true,[497]=true,[498]=true}, -- death blossom shares spawn with zone-specific herbs

	[1407] = {[1414]=true,[1421]=true,[1428]=true}, -- Hochenblume is a common spawn of the other herbs
	[1439] = {[1447]=true,[1455]=true,[1463]=true,[1471]=true}, -- Mycobloom is a common shared spawn with other TWW herbs
}
GatherMate.rareNodes = rare_spawns

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
Display:SetTrackingSpell("Logging", 1256697)
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
		--[102] = icon_path.."Fish\\purewater.tga",
		[103] = icon_path.."Fish\\debris.tga",
		--[104] = icon_path.."Fish\\oilspill.tga",
		[105] = icon_path.."Fish\\firefin.tga",
		[106] = icon_path.."Fish\\greater_sagefish.tga",
		[107] = icon_path.."Fish\\oilyblackmouth.tga",
		[108] = icon_path.."Fish\\sagefish.tga",
		[109] = icon_path.."Fish\\firefin.tga",
		[110] = icon_path.."Fish\\eel.tga",
		--[111] = icon_path.."Fish\\net.tga",
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
		[136] = icon_path.."Fish\\fish_hook.tga",
		--[136] = icon_path.."Fish\\sagefish.tga",
		--[137] = icon_path.."Fish\\oilyblackmouth.tga",
		--[138] = icon_path.."Fish\\oilyblackmouth.tga",
		--[139] = icon_path.."Fish\\oilyblackmouth.tga",
		--[140] = icon_path.."Fish\\oilyblackmouth.tga",
		--[141] = icon_path.."Fish\\firefin.tga",
		--[142] = icon_path.."Fish\\firefin.tga",
		--[143] = icon_path.."Fish\\firefin.tga",
		--[144] = icon_path.."Fish\\firefin.tga",
		--[145] = icon_path.."Fish\\debris.tga",
		--[146] = icon_path.."Fish\\treasure.tga",
		--[147] = icon_path.."Fish\\treasure.tga",
		--[148] = icon_path.."Fish\\treasure.tga",
		[149] = icon_path.."Fish\\salmon.tga",
		--[150] = icon_path.."Fish\\goby.tga",
		[151] = icon_path.."Fish\\mudfish.tga",
		[152] = icon_path.."Fish\\feel.tga",
		[153] = icon_path.."Fish\\hguppy.tga",
		[154] = icon_path.."Fish\\mtrout.tga",
		[155] = icon_path.."Gas\\cinder.tga",
		[156] = icon_path.."Fish\\debris.tga",
		[157] = icon_path.."Fish\\dsagefish.tga",
		[158] = icon_path.."Fish\\emp_salmon.tga",
		[159] = icon_path.."Fish\\matis_shrimp.tga",
		[160] = icon_path.."Fish\\darter.tga",
		[161] = icon_path.."Fish\\lungfish.tga",
		[162] = icon_path.."Fish\\paddle_fish.tga",
		[163] = icon_path.."Fish\\redbelly.tga",
		[164] = icon_path.."Fish\\reef_octopus.tga",
		[165] = icon_path.."Fish\\debris.tga",
		[166] = icon_path.."Fish\\jewel.tga",
		[167] = icon_path.."Fish\\spine.tga",
		[168] = icon_path.."Fish\\tiger.tga",
		[169] = icon_path.."Fish\\abyssalgulper.tga",
		[170] = icon_path.."Fish\\abyssalgulper.tga",
		[171] = icon_path.."Fish\\whiptail.tga",
		[172] = icon_path.."Fish\\sturgeon.tga",
		[173] = icon_path.."Fish\\fatsleeper.tga",
		[174] = icon_path.."Fish\\fireammonite.tga",
		[175] = icon_path.."Fish\\jawlessskulker.tga",
		[176] = icon_path.."Fish\\seascorpion.tga",
		[177] = icon_path.."Fish\\seascorpion.tga",
		[178] = icon_path.."Fish\\piranha.tga",
		[179] = icon_path.."Fish\\fish_hook.tga",
		[180] = icon_path.."Fish\\fish_hook.tga",
		[181] = icon_path.."Fish\\suckerfish.tga",
		[182] = icon_path.."Fish\\fish_hook.tga",
		[183] = icon_path.."Fish\\fish_hook.tga",
		[184] = icon_path.."Fish\\fish_hook.tga",
		[185] = icon_path.."Fish\\fish_hook.tga",
		[186] = icon_path.."Fish\\fish_hook.tga",
		[187] = icon_path.."Fish\\fish_hook.tga",
		[188] = icon_path.."Fish\\frenzied_fangtooth.tga",
		[189] = icon_path.."Fish\\great_sea_catfish.tga",
		[190] = icon_path.."Fish\\lane_snapper.tga",
		[191] = icon_path.."Fish\\rasboralus.tga",
		[192] = icon_path.."Fish\\redtail_loach.tga",
		[193] = icon_path.."Fish\\sand_shifter.tga",
		[194] = icon_path.."Fish\\slimy_mackerel.tga",
		[195] = icon_path.."Fish\\tiragarde_perch.tga",
		[196] = icon_path.."Fish\\utaka.tga",
		[197] = icon_path.."Fish\\mauvestinger.tga",
		[198] = icon_path.."Fish\\viperfish.tga",
		[199] = icon_path.."Fish\\ionizedminnow.tga",
		[1101] = icon_path.."Fish\\sentryfish.tga",
		[1102] = icon_path.."Fish\\iridescentamberjack.tga",
		[1103] = icon_path.."Fish\\pockedbonefish.tga",
		[1104] = icon_path.."Fish\\silvergillpike.tga",
		[1105] = icon_path.."Fish\\elysianthade.tga",
		[1106] = icon_path.."Fish\\lostsole.tga",
		[1107] = icon_path.."Fish\\spinefinpiranha.tga",
		[1108] = icon_path.."Fish\\fish_hook.tga",
		[1109] = icon_path.."Fish\\fish_hook.tga",
		[1110] = icon_path.."Fish\\fish_hook.tga",
		[1111] = icon_path.."Fish\\fish_hook.tga",
		[1112] = icon_path.."Fish\\fish_hook.tga",
		[1113] = icon_path.."Fish\\fish_hook.tga",
		[1114] = icon_path.."Fish\\fish_hook.tga",
		[1115] = icon_path.."Fish\\fish_hook.tga",
		[1116] = icon_path.."Fish\\fish_hook.tga",
		[1117] = icon_path.."Fish\\fish_hook.tga",
		[1118] = icon_path.."Fish\\fish_hook.tga",
		[1119] = icon_path.."Fish\\fish_hook.tga",
		[1120] = icon_path.."Fish\\fish_hook.tga",
		[1121] = icon_path.."Fish\\fish_hook.tga",
		[1122] = icon_path.."Fish\\fish_hook.tga",
		[1123] = icon_path.."Fish\\fish_hook.tga",
		[1124] = icon_path.."Fish\\fish_hook.tga",
		[1125] = icon_path.."Fish\\fish_hook.tga",
		[1126] = icon_path.."Fish\\fish_hook.tga",
		[1127] = icon_path.."Fish\\fish_hook.tga",
		[1128] = icon_path.."Fish\\fish_hook.tga",
		[1129] = icon_path.."Fish\\debris.tga",
		[1130] = icon_path.."Fish\\debris.tga",
		[1131] = icon_path.."Fish\\fish_hook.tga",
		[1132] = icon_path.."Fish\\fish_hook.tga",
		[1133] = icon_path.."Fish\\fish_hook.tga",
		[1134] = icon_path.."Fish\\fish_hook.tga",
		[1135] = icon_path.."Fish\\fish_hook.tga",
		[1136] = icon_path.."Fish\\fish_hook.tga",
		[1137] = icon_path.."Fish\\fish_hook.tga",
		[1138] = icon_path.."Fish\\fish_hook.tga",
		[1139] = icon_path.."Fish\\fish_hook.tga",
		[1140] = icon_path.."Fish\\fish_hook.tga",
		[1141] = icon_path.."Fish\\fish_hook.tga",
		[1142] = icon_path.."Fish\\debris.tga",
		[1143] = icon_path.."Fish\\debris.tga",
		[1144] = icon_path.."Fish\\fish_hook.tga",
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
		[225] = icon_path.."Mine\\nethercite.tga",
		[226] = icon_path.."Mine\\nethercite.tga",
		[227] = icon_path.."Mine\\nethercite.tga",
		[228] = icon_path.."Mine\\cobalt.tga",
		[229] = icon_path.."Mine\\cobalt.tga",
		[230] = icon_path.."Mine\\titanium.tga",
		[231] = icon_path.."Mine\\saronite.tga",
		[232] = icon_path.."Mine\\saronite.tga",
		[233] = icon_path.."Mine\\obsidian.tga",
		--[234] = icon_path.."Mine\\store_tablet.tga",
		[235] = icon_path.."Mine\\saronite.tga",
		[236] = icon_path.."Mine\\elementium.tga",
		[237] = icon_path.."Mine\\elementium.tga",
		[238] = icon_path.."Mine\\pyrite.tga",
		[239] = icon_path.."Mine\\elementium.tga",
		[240] = icon_path.."Mine\\pyrite.tga",
		[241] = icon_path.."Mine\\ghostiron.tga",
		[242] = icon_path.."Mine\\ghostiron.tga",
		--[243] = icon_path.."Mine\\black_trillium.tga",
		--[244] = icon_path.."Mine\\white_trillium.tga",
		[245] = icon_path.."Mine\\kyparite.tga",
		[246] = icon_path.."Mine\\kyparite.tga",
		[247] = icon_path.."Mine\\white_trillium.tga",
		[248] = icon_path.."Mine\\black_trillium.tga",
		[249] = icon_path.."Mine\\trueiron.tga",
		[250] = icon_path.."Mine\\trueiron.tga",
		[251] = icon_path.."Mine\\blackrock.tga",
		[252] = icon_path.."Mine\\blackrock.tga",
		[253] = icon_path.."Mine\\leystone.tga",
		[254] = icon_path.."Mine\\leystone.tga",
		[255] = icon_path.."Mine\\leystone.tga",
		[256] = icon_path.."Mine\\felslate.tga",
		[257] = icon_path.."Mine\\felslate.tga",
		[258] = icon_path.."Mine\\felslate.tga",
		[259] = icon_path.."Mine\\empyrium.tga",
		[260] = icon_path.."Mine\\empyrium.tga",
		[261] = icon_path.."Mine\\empyrium.tga",
		[262] = icon_path.."Mine\\monelite.tga",
		[263] = icon_path.."Mine\\monelite.tga",
		[264] = icon_path.."Mine\\monelite.tga",
		[265] = icon_path.."Mine\\platinum.tga",
		[266] = icon_path.."Mine\\platinum.tga",
		[267] = icon_path.."Mine\\stormsilver.tga",
		[268] = icon_path.."Mine\\stormsilver.tga",
		[269] = icon_path.."Mine\\stormsilver.tga",
		[270] = icon_path.."Mine\\osmenite.tga",
		[271] = icon_path.."Mine\\osmenite.tga",
		[272] = icon_path.."Mine\\osmenite.tga",
		[273] = icon_path.."Mine\\laestrite.tga",
		[274] = icon_path.."Mine\\laestrite.tga",
		[275] = icon_path.."Mine\\phaedrite.tga",
		[276] = icon_path.."Mine\\phaedrite.tga",
		[277] = icon_path.."Mine\\oxxein.tga",
		[278] = icon_path.."Mine\\oxxein.tga",
		[279] = icon_path.."Mine\\oxxein.tga",
		[280] = icon_path.."Mine\\elethium.tga",
		[281] = icon_path.."Mine\\elethium.tga",
		[282] = icon_path.."Mine\\solenium.tga",
		[283] = icon_path.."Mine\\solenium.tga",
		[284] = icon_path.."Mine\\sinvyr.tga",
		[285] = icon_path.."Mine\\sinvyr.tga",
		[286] = icon_path.."Mine\\sinvyr.tga",
		[287] = icon_path.."Mine\\elethium.tga",
		[288] = icon_path.."Mine\\elethium.tga",
		[289] = icon_path.."Mine\\elethium.tga",
		[290] = icon_path.."Mine\\elethium.tga",
		[291] = icon_path.."Mine\\elethium.tga",
		[292] = icon_path.."Mine\\elethium.tga",
		[1200] = icon_path.."Mine\\serevite.tga",
		[1201] = icon_path.."Mine\\serevite.tga",
		[1208] = icon_path.."Mine\\draconium.tga",
		[1209] = icon_path.."Mine\\draconium.tga",
		[1218] = icon_path.."Mine\\bismuth.tga",
		[1225] = icon_path.."Mine\\bismuth.tga",
		[1226] = icon_path.."Mine\\aqirite.tga",
		[1233] = icon_path.."Mine\\aqirite.tga",
		[1234] = icon_path.."Mine\\ironclaw.tga",
		[1241] = icon_path.."Mine\\ironclaw.tga",
		[1242] = icon_path.."Mine\\tin.tga", -- webbed deposit
		[1243] = icon_path.."Mine\\karesh.tga",
		[1245] = icon_path.."Mine\\brilliantsilver.tga",
		[1246] = icon_path.."Mine\\brilliantsilver.tga",
		[1247] = icon_path.."Mine\\refulgentcopper.tga",
		[1248] = icon_path.."Mine\\refulgentcopper.tga",
		[1249] = icon_path.."Mine\\umbraltin.tga",
		[1250] = icon_path.."Mine\\umbraltin.tga",
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
		--[430] = icon_path.."Herb\\purple_lotus.tga",
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
		[455] = icon_path.."Herb\\plaguebloom.tga",
		[456] = icon_path.."Herb\\azsharasveil.tga",
		[457] = icon_path.."Herb\\cinderbloom.tga",
		[458] = icon_path.."Herb\\stormvine.tga",
		[459] = icon_path.."Herb\\heartblossom.tga",
		[460] = icon_path.."Herb\\twilightjasmine.tga",
		[461] = icon_path.."Herb\\whiptail.tga",
		[462] = icon_path.."Herb\\golden_lotus.tga",
		[463] = icon_path.."Herb\\fools_cap.tga",
		[464] = icon_path.."Herb\\snow_lily.tga",
		[465] = icon_path.."Herb\\silkweed.tga",
		[466] = icon_path.."Herb\\green_tea_leaf.tga",
		[467] = icon_path.."Herb\\rain_poppy.tga",
		[468] = icon_path.."Herb\\shaherb.tga",
		[469] = icon_path.."Herb\\taladororchid.tga",
		[470] = icon_path.."Herb\\arrowbloom.tga",
		[471] = icon_path.."Herb\\starflower.tga",
		[472] = icon_path.."Herb\\flytrap.tga",
		[473] = icon_path.."Herb\\fireweed.tga",
		[474] = icon_path.."Herb\\frostweed.tga",
		[475] = icon_path.."Herb\\shaherb.tga",
		[476] = icon_path.."Herb\\aethril.tga",
		[477] = icon_path.."Herb\\dreamleaf.tga",
		[478] = icon_path.."Herb\\felwort.tga",
		[479] = icon_path.."Herb\\fjarnskaggl.tga",
		[480] = icon_path.."Herb\\foxflower.tga",
		[481] = icon_path.."Herb\\starlightrose.tga",
		[482] = icon_path.."Herb\\felherb.tga",
		[483] = icon_path.."Herb\\felherb.tga",
		[484] = icon_path.."Herb\\astralglory.tga",
		[485] = icon_path.."Herb\\akundas_bite.tga",
		[486] = icon_path.."Herb\\anchor_weed.tga",
		[487] = icon_path.."Herb\\riverbud.tga",
		[488] = icon_path.."Herb\\seastalk.tga",
		[489] = icon_path.."Herb\\sirens_pollen.tga",
		[490] = icon_path.."Herb\\star_moss.tga",
		[491] = icon_path.."Herb\\winters_kiss.tga",
		[492] = icon_path.."Herb\\zinanthid.tga",
		[493] = icon_path.."Herb\\deathblossom.tga",
		[494] = icon_path.."Herb\\nightshade.tga",
		[495] = icon_path.."Herb\\marrowroot.tga",
		[496] = icon_path.."Herb\\vigilstorch.tga",
		[497] = icon_path.."Herb\\risingglory.tga",
		[498] = icon_path.."Herb\\widowbloom.tga",
		[499] = icon_path.."Herb\\nightshade.tga",
		[1407] = icon_path.."Herb\\hochenblume.tga",
		[1414] = icon_path.."Herb\\bubblepoppy.tga",
		[1421] = icon_path.."Herb\\saxifrage.tga",
		[1428] = icon_path.."Herb\\writhebark.tga",
		[1439] = icon_path.."Herb\\mycobloom.tga",
		[1447] = icon_path.."Herb\\blessing.tga",
		[1455] = icon_path.."Herb\\luredrop.tga",
		[1463] = icon_path.."Herb\\orbinid.tga",
		[1471] = icon_path.."Herb\\arathorsspear.tga",
		[1479] = icon_path.."Herb\\phantombloom.tga",
		[1481] = icon_path.."Herb\\argentleaf.tga",
		[1482] = icon_path.."Herb\\azeroot.tga",
		[1483] = icon_path.."Herb\\manalily.tga",
		[1484] = icon_path.."Herb\\sanguithorn.tga",
		[1485] = icon_path.."Herb\\tranquilitybloom.tga",
	},
	["Treasure"] = {
		[501] = icon_path.."Treasure\\clam.tga",
		[502] = icon_path.."Treasure\\chest.tga",
		[503] = icon_path.."Treasure\\chest.tga",
		[504] = icon_path.."Treasure\\chest.tga",
		[505] = icon_path.."Treasure\\chest.tga",
		[506] = icon_path.."Treasure\\chest.tga",
		[507] = icon_path.."Treasure\\chest.tga",
		[508] = icon_path.."Treasure\\chest.tga",
		[509] = icon_path.."Treasure\\chest.tga",
		[510] = icon_path.."Treasure\\chest.tga",
		--[511] = icon_path.."Treasure\\soil.tga",
		[512] = icon_path.."Treasure\\sprout.tga",
		--[513] = icon_path.."Treasure\\blood.tga",
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
		[528] = icon_path.."Treasure\\treasure.tga",
		[529] = icon_path.."Treasure\\treasure.tga",
		[530] = icon_path.."Treasure\\treasure.tga",
		[531] = icon_path.."Treasure\\egg.tga",
		[532] = icon_path.."Treasure\\everfrost.tga",
		[533] = icon_path.."Treasure\\egg.tga",
		[534] = icon_path.."Treasure\\treasure.tga",
		[535] = icon_path.."Treasure\\treasure.tga",
		[536] = icon_path.."Treasure\\treasure.tga",
		[537] = icon_path.."Treasure\\treasure.tga",
		[538] = icon_path.."Treasure\\camel.tga",
		[539] = icon_path.."Treasure\\chest.tga",
		[540] = icon_path.."Treasure\\chest.tga",
		[541] = icon_path.."Treasure\\green_raptor.tga",
		[542] = icon_path.."Treasure\\red_raptor.tga",
		[543] = icon_path.."Treasure\\red_raptor.tga",
		[544] = icon_path.."Treasure\\green_raptor.tga",
		[545] = icon_path.."Treasure\\soil.tga",
		[546] = icon_path.."Treasure\\egg.tga",
		[547] = icon_path.."Treasure\\footlocker.tga",
		[548] = icon_path.."Treasure\\treasure.tga",
		[549] = icon_path.."Treasure\\treasure.tga",
		[550] = icon_path.."Treasure\\treasure.tga",
		[551] = icon_path.."Treasure\\treasure.tga",
		[552] = icon_path.."Treasure\\ancient_mana.tga",
		[553] = icon_path.."Treasure\\ancient_mana.tga",
		[554] = icon_path.."Treasure\\ancient_mana.tga",
		[555] = icon_path.."Treasure\\ancient_mana.tga",
		[556] = icon_path.."Treasure\\ancient_mana.tga",
		[557] = icon_path.."Treasure\\ancient_mana.tga",
		[558] = icon_path.."Treasure\\ancient_mana.tga",
		[559] = icon_path.."Treasure\\ancient_mana.tga",
		[560] = icon_path.."Treasure\\treasure.tga",
		[561] = icon_path.."Treasure\\treasure.tga",
		[562] = icon_path.."Treasure\\ancient_mana.tga",
		[563] = icon_path.."Treasure\\honey.tga",
		[564] = icon_path.."Treasure\\honey.tga",
		[565] = icon_path.."Treasure\\hide.tga",
		[566] = icon_path.."Treasure\\soil.tga",
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
		[611] = icon_path.."Archaeology\\shovel.tga",
		[612] = icon_path.."Archaeology\\shovel.tga",
		[613] = icon_path.."Archaeology\\shovel.tga",
		[614] = icon_path.."Archaeology\\shovel.tga",
		[615] = icon_path.."Archaeology\\shovel.tga",
		[616] = icon_path.."Archaeology\\shovel.tga",
		[617] = icon_path.."Archaeology\\shovel.tga",
		[618] = icon_path.."Archaeology\\shovel.tga",
		[619] = icon_path.."Archaeology\\shovel.tga",
		[620] = icon_path.."Archaeology\\shovel.tga",
		[621] = icon_path.."Archaeology\\shovel.tga",
	},
	["Logging"] = {
		[701] = icon_path.."Logging\\timber.tga",
		[702] = icon_path.."Logging\\timber.tga",
		[703] = icon_path.."Logging\\timber.tga",
		[704] = icon_path.."Logging\\timber.tga",
		[705] = icon_path.."Logging\\timber.tga",
		[706] = icon_path.."Logging\\timber.tga",
		[707] = icon_path.."Logging\\timber.tga",
		[708] = icon_path.."Logging\\timber.tga",
		[709] = icon_path.."Logging\\timber.tga",
		[710] = icon_path.."Logging\\timber.tga",
		[711] = icon_path.."Logging\\timber.tga",
		[712] = icon_path.."Logging\\timber.tga",
		[713] = icon_path.."Logging\\timber.tga",
		[714] = icon_path.."Logging\\timber.tga",
		[715] = icon_path.."Logging\\timber.tga",
	},
}
GatherMate.nodeTextures = node_textures

local CLASSIC = 1
local BC      = 2
local WRATH   = 3
local CATA    = 4
local MOP     = 5
local WOD     = 6
local LEGION  = 7
local BFA     = 8
local SL      = 9
local DF      = 10
local TWW     = 11
local MN      = 12
local node_expansion = {
	["Mining"] = {
		[201] = CLASSIC,
		[202] = CLASSIC,
		[203] = CLASSIC,
		[204] = CLASSIC,
		[205] = CLASSIC,
		[206] = CLASSIC,
		[207] = CLASSIC,
		[208] = CLASSIC,
		[209] = CLASSIC,
		[210] = CLASSIC,
		[211] = CLASSIC,
		[212] = CLASSIC,
		[213] = CLASSIC,
		[214] = CLASSIC,
		[215] = CLASSIC,
		[216] = CLASSIC,
		[217] = CLASSIC,
		[218] = CLASSIC,
		[219] = CLASSIC,
		[220] = CLASSIC,
		[221] = BC,
		[222] = BC,
		[223] = BC,
		[224] = BC,
		[225] = BC,
		[226] = BC,
		[227] = BC,
		[228] = WRATH,
		[229] = WRATH,
		[230] = WRATH,
		[231] = WRATH,
		[232] = WRATH,
		[233] = WRATH,
		--[234] = CATA,
		[235] = CATA,
		[236] = CATA,
		[237] = CATA,
		[238] = CATA,
		[239] = CATA,
		[240] = CATA,
		[241] = MOP,
		[242] = MOP,
		--[243] = MOP,
		--[244] = MOP,
		[245] = MOP,
		[246] = MOP,
		[247] = MOP,
		[248] = MOP,
		[249] = WOD,
		[250] = WOD,
		[251] = WOD,
		[252] = WOD,
		[253] = LEGION,
		[254] = LEGION,
		[255] = LEGION,
		[256] = LEGION,
		[257] = LEGION,
		[258] = LEGION,
		[259] = LEGION,
		[260] = LEGION,
		[261] = LEGION,
		[262] = BFA,
		[263] = BFA,
		[264] = BFA,
		[265] = BFA,
		[266] = BFA,
		[267] = BFA,
		[268] = BFA,
		[269] = BFA,
		[270] = BFA,
		[271] = BFA,
		[272] = BFA,
		[273] = SL,
		[274] = SL,
		[275] = SL,
		[276] = SL,
		[277] = SL,
		[278] = SL,
		[279] = SL,
		[280] = SL,
		[281] = SL,
		[282] = SL,
		[283] = SL,
		[284] = SL,
		[285] = SL,
		[286] = SL,
		[287] = SL,
		[288] = SL,
		[289] = SL,
		[290] = SL,
		[291] = SL,
		[292] = SL,
		[1200] = DF,
		[1201] = DF,
		[1208] = DF,
		[1209] = DF,
		[1218] = TWW,
		[1225] = TWW,
		[1226] = TWW,
		[1233] = TWW,
		[1234] = TWW,
		[1241] = TWW,
		[1242] = TWW,
		[1243] = TWW,
		[1245] = MN,
		[1246] = MN,
		[1247] = MN,
		[1248] = MN,
		[1249] = MN,
		[1250] = MN,
	},
	["Herb Gathering"] = {
		[401] = CLASSIC,
		[402] = CLASSIC,
		[403] = CLASSIC,
		[404] = CLASSIC,
		[405] = CLASSIC,
		[406] = CLASSIC,
		[407] = CLASSIC,
		[408] = CLASSIC,
		[409] = CLASSIC,
		[410] = CLASSIC,
		[411] = CLASSIC,
		[412] = CLASSIC,
		[413] = CLASSIC,
		[414] = CLASSIC,
		[415] = CLASSIC,
		[416] = CLASSIC,
		[417] = CLASSIC,
		[418] = CLASSIC,
		[419] = CLASSIC,
		[420] = CLASSIC,
		[421] = CLASSIC,
		[422] = CLASSIC,
		[423] = CLASSIC,
		[424] = CLASSIC,
		[425] = CLASSIC,
		[426] = CLASSIC,
		[427] = CLASSIC,
		[428] = CLASSIC,
		[429] = CLASSIC,
		--[430] = CLASSIC,
		[431] = CLASSIC,
		[432] = BC,
		[433] = BC,
		[434] = BC,
		[435] = BC,
		[436] = BC,
		[437] = BC,
		[438] = BC,
		[439] = BC,
		[440] = BC,
		[441] = BC,
		[442] = BC,
		[443] = WRATH,
		[444] = WRATH,
		[445] = WRATH,
		[446] = WRATH,
		[447] = WRATH,
		[448] = WRATH,
		[449] = WRATH,
		[450] = WRATH,
		[451] = WRATH,
		[452] = WRATH,
		[453] = WRATH,
		[454] = CATA,
		[455] = CATA,
		[456] = CATA,
		[457] = CATA,
		[458] = CATA,
		[459] = CATA,
		[460] = CATA,
		[461] = CATA,
		[462] = MOP,
		[463] = MOP,
		[464] = MOP,
		[465] = MOP,
		[466] = MOP,
		[467] = MOP,
		[468] = MOP,
		[469] = WOD,
		[470] = WOD,
		[471] = WOD,
		[472] = WOD,
		[473] = WOD,
		[474] = WOD,
		[475] = WOD,
		[476] = LEGION,
		[477] = LEGION,
		[478] = LEGION,
		[479] = LEGION,
		[480] = LEGION,
		[481] = LEGION,
		[482] = LEGION,
		[483] = LEGION,
		[484] = LEGION,
		[485] = BFA,
		[486] = BFA,
		[487] = BFA,
		[488] = BFA,
		[489] = BFA,
		[490] = BFA,
		[491] = BFA,
		[492] = BFA,
		[493] = SL,
		[494] = SL,
		[495] = SL,
		[496] = SL,
		[497] = SL,
		[498] = SL,
		[499] = SL,
		[1407] = DF,
		[1414] = DF,
		[1421] = DF,
		[1428] = DF,
		[1439] = TWW,
		[1447] = TWW,
		[1455] = TWW,
		[1463] = TWW,
		[1471] = TWW,
		[1479] = TWW,
		[1481] = MN,
		[1482] = MN,
		[1483] = MN,
		[1484] = MN,
		[1485] = MN,
	},
}
GatherMate.nodeExpansion = node_expansion

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

local map_phasing = {
}

GatherMate.phasing = map_phasing

local map_blacklist = {
	[582] = true, -- Alliance Garrison
	[590] = true, -- Horde Garrison
}

GatherMate.mapBlacklist = map_blacklist
