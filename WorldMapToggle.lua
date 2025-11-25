local GatherMate = LibStub("AceAddon-3.0"):GetAddon("GatherMate2")
local Display = GatherMate:GetModule("Display")
local L = LibStub("AceLocale-3.0"):GetLocale("GatherMate2")

local toggleButton = nil
local dropdownFrame = nil

-- Node types to display in menu
local nodeTypes = {
	{key = "Mining", name = L["Mining Nodes"]},
	{key = "Herb Gathering", name = L["Herb Nodes"]},
	{key = "Fishing", name = L["Fishing Nodes"]},
	{key = "Extract Gas", name = L["Gas Nodes"]},
	{key = "Treasure", name = L["Treasure Nodes"]},
	{key = "Archaeology", name = L["Archaeology Nodes"]},
	{key = "Logging", name = L["Logging Nodes"]},
}

-- Initialize worldMapNodeFilters if it doesn't exist
local function InitializeNodeFilters()
	local db = GatherMate.db.profile
	if not db.worldMapNodeFilters then
		db.worldMapNodeFilters = {}
	end
	-- Set all node types to true by default if not already set
	for _, nodeType in ipairs(nodeTypes) do
		if db.worldMapNodeFilters[nodeType.key] == nil then
			db.worldMapNodeFilters[nodeType.key] = true
		end
	end
end

-- Toggle a specific node type
local function ToggleNodeType(nodeKey)
	local db = GatherMate.db.profile
	InitializeNodeFilters()
	db.worldMapNodeFilters[nodeKey] = not db.worldMapNodeFilters[nodeKey]
	Display:UpdateWorldMap()
	UpdateButtonState()
end

-- Check if a node type is shown
local function IsNodeTypeShown(nodeKey)
	local db = GatherMate.db.profile
	InitializeNodeFilters()
	return db.worldMapNodeFilters[nodeKey]
end

-- Initialize dropdown menu
local function InitializeDropdown(self, level)
	local info = UIDropDownMenu_CreateInfo()
	
	if level == 1 then
		-- Add "Toggle All" option
		info.text = L["Toggle All"]
		info.notCheckable = true
		info.func = function()
			local db = GatherMate.db.profile
			db.showWorldMap = not db.showWorldMap
			Display:UpdateWorldMap()
			UpdateButtonState()
		end
		UIDropDownMenu_AddButton(info, level)
		
		-- Add separator
		info = UIDropDownMenu_CreateInfo()
		info.text = ""
		info.isTitle = true
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, level)
		
		-- Add checkbox for each node type
		for _, nodeType in ipairs(nodeTypes) do
			info = UIDropDownMenu_CreateInfo()
			info.text = nodeType.name
			info.checked = IsNodeTypeShown(nodeType.key)
			info.func = function()
				ToggleNodeType(nodeType.key)
			end
			info.keepShownOnClick = true
			info.isNotRadio = true
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

-- Function to create the toggle button
local function CreateToggleButton()
	if toggleButton then return end

	-- Create dropdown frame
	dropdownFrame = CreateFrame("Frame", "GatherMate2NodeFilterDropdown", UIParent, "UIDropDownMenuTemplate")
	UIDropDownMenu_Initialize(dropdownFrame, InitializeDropdown, "MENU")

	-- Create button WITHOUT template for custom styling
	toggleButton = CreateFrame("Button", "GatherMate2WorldMapToggle", WorldMapFrame.BorderFrame)
	toggleButton:SetSize(28, 28)
	toggleButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	-- Position: Top-right, next to other map buttons
	if WorldMapFrame.overlayFrames and WorldMapFrame.overlayFrames[2] then
		toggleButton:SetPoint("RIGHT", WorldMapFrame.overlayFrames[2], "LEFT", -18, 0)
	else
		toggleButton:SetPoint("TOPRIGHT", WorldMapFrame.BorderFrame, "TOPRIGHT", -10, -10)
	end

	-- Create circular background
	local bgTexture = toggleButton:CreateTexture(nil, "BACKGROUND")
	bgTexture:SetAllPoints(toggleButton)
	bgTexture:SetAtlas("transmog-icon-hidden")
	toggleButton.bg = bgTexture

	-- Create icon texture
	local icon = toggleButton:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("CENTER", 0, 0)
	icon:SetSize(20, 20)
	icon:SetTexture("Interface\AddOns\GatherMate2\Artwork\Icon")
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	toggleButton.icon = icon

	-- Add highlight texture
	local highlight = toggleButton:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints(toggleButton)
	highlight:SetAtlas("charactercreate-ring-select")
	highlight:SetBlendMode("ADD")

	-- Add pushed effect
	toggleButton:SetPushedTextOffset(1, -1)

	-- Button click handler (Left = Toggle all, Right = Menu)
	toggleButton:SetScript("OnClick", function(self, button)
		if button == "LeftButton" then
			-- Left click: Toggle all nodes
			local db = GatherMate.db.profile
			db.showWorldMap = not db.showWorldMap
			Display:UpdateWorldMap()
			UpdateButtonState()

			if db.showWorldMap then
				PlaySound(SOUNDKIT.MAP_PING)
			else
				PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
			end
		elseif button == "RightButton" then
			-- Right click: Show filter menu
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			ToggleDropDownMenu(1, nil, dropdownFrame, self, 0, 0)
		end
	end)

	-- Tooltip
	toggleButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText("GatherMate2", 1, 1, 1)
		local db = GatherMate.db.profile
		if db.showWorldMap then
			GameTooltip:AddLine("|cff00ff00Nodes werden angezeigt|r", 1, 1, 1)
		else
			GameTooltip:AddLine("|cffff0000Nodes sind ausgeblendet|r", 1, 1, 1)
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("|cffFFD700" .. L["Left-click: Toggle all nodes"] .. "|r", 0.8, 0.8, 0.8)
		GameTooltip:AddLine("|cffFFD700" .. L["Right-click: Open filter menu"] .. "|r", 0.8, 0.8, 0.8)
		GameTooltip:Show()
	end)

	toggleButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	UpdateButtonState()
end

-- Update button visual state
function UpdateButtonState()
	if not toggleButton then return end

	local db = GatherMate.db.profile
	if db.showWorldMap then
		toggleButton.icon:SetDesaturated(false)
		toggleButton.icon:SetAlpha(1.0)
		toggleButton.bg:SetAlpha(0.8)
	else
		toggleButton.icon:SetDesaturated(true)
		toggleButton.icon:SetAlpha(0.4)
		toggleButton.bg:SetAlpha(0.5)
	end
end

-- Update button visibility based on config setting
function Display:UpdateToggleButtonVisibility()
	local db = GatherMate.db.profile
	if not toggleButton then return end

	if db.showWorldMapToggleButton and WorldMapFrame:IsShown() then
		toggleButton:Show()
		UpdateButtonState()
	else
		toggleButton:Hide()
	end
end

-- Hook WorldMapFrame OnShow to create/show button
WorldMapFrame:HookScript("OnShow", function()
	local db = GatherMate.db.profile
	CreateToggleButton()

	if toggleButton and db.showWorldMapToggleButton then
		toggleButton:Show()
		UpdateButtonState()
	elseif toggleButton then
		toggleButton:Hide()
	end
end)

-- Hook WorldMapFrame OnHide to hide button
WorldMapFrame:HookScript("OnHide", function()
	if toggleButton then
		toggleButton:Hide()
	end
end)

-- Hook into ConfigChanged to update button when settings change
hooksecurefunc(GatherMate, "SendMessage", function(self, message)
	if message == "GatherMate2ConfigChanged" then
		UpdateButtonState()
		if Display.UpdateToggleButtonVisibility then
			Display:UpdateToggleButtonVisibility()
		end
	end
end)
