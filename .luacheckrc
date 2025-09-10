std = "lua51"
max_line_length = false
exclude_files = {
	".luacheckrc",
	"Locales/",
}

ignore = {
	"211/_.*", -- Unused local variable starting with _
	"212", -- unused argument
	"213", -- Unused loop variable
	"542", -- empty if branch
}

globals = {
	"GatherMate2",
	"GatherMate2WorldMapPinMixin",
	"GatherMate2_GenericDropDownMenu",

	"SlashCmdList",
	"SLASH_GatherMate21",

	"BINDING_HEADER_GatherMate2",
	"BINDING_NAME_TOGGLE_GATHERMATE2_MAINMAPICONS",
	"BINDING_NAME_TOGGLE_GATHERMATE2_MINIMAPICONS",
}

read_globals = {
	"max", "min", "floor", "ceil",
	"table", "tinsert", "wipe",

	-- misc custom, third party libraries
	"LibStub", "TomTom",

	-- Namespaces
	"C_AddOns",
	"C_CVar",
	"C_Item",
	"C_Map",
	"C_Minimap",
	"C_ResearchInfo",
	"C_Spell",

	-- API
	"CombatLogGetCurrentEventInfo",
	"CreateFrame",
	"GetBindingAction",
	"GetBindingKey",
	"GetBindingText",
	"GetCurrentBindingSet",
	"GetLocale",
	"GetMinimapShape",
	"GetPlayerFacing",
	"GetProfessionInfo",
	"GetProfessions",
	"IsShiftKeyDown",
	"SaveBindings",
	"SetBinding",
	"UnitName",

	-- FrameXML
	"CreateFromMixins",
	"GameTooltip",
	"MapCanvasDataProviderMixin",
	"MapCanvasPinMixin",
	"Minimap",
	"MinimapCluster",
	"Settings",
	"UIParent",
	"WorldMapFrame",

	"CloseDropDownMenus",
	"ToggleDropDownMenu",
	"UIDropDownMenu_AddButton",

	-- strings & constants
	"CLOSE",
	"GRAY_FONT_COLOR_CODE",
	"GREEN_FONT_COLOR_CODE",
	"KEY_BOUND",
	"KEY_UNBOUND_ERROR",
	"NORMAL_FONT_COLOR",
}
