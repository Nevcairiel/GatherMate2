-- GatherMate Locale
-- Please use the Localization App on WoWAce to Update this
-- http://www.wowace.com/projects/gathermate2-classic/localization/

local debug = false
--@debug@
debug = true
--@end-debug@

local L = LibStub("AceLocale-3.0"):NewLocale("GatherMate2", "enUS", true, debug)

--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, namespace="Options", table-name="L")@

local NL = LibStub("AceLocale-3.0"):NewLocale("GatherMate2Nodes", "enUS", true, debug)

--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, namespace="Nodes", table-name="NL")@

-- SoD Nightmare Incursion nodes (Emerald Nightmare phase) - not yet in the WoWAce
-- localization app, registered here directly so AceLocale doesn't warn on first use
NL["Cold Iron Ore"] = true
NL["Cold Iron Vein"] = true
NL["Fool's Gold Vein"] = true
NL["Greater Moonstone"] = true
NL["Starsilver Vein"] = true
NL["Nightmare Moss"] = true
NL["Dreamroot"] = true
NL["Moonroot"] = true
NL["Star Lotus"] = true
