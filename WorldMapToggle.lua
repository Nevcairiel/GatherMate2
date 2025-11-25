local GatherMate = LibStub("AceAddon-3.0"):GetAddon("GatherMate2")
local Display = GatherMate:GetModule("Display")

local toggleButton = nil

-- Function to create the toggle button
local function CreateToggleButton()
	if toggleButton then return end

	-- Create button WITHOUT template for custom styling (like right-side map buttons)
	toggleButton = CreateFrame("Button", "GatherMate2WorldMapToggle", WorldMapFrame.BorderFrame)
	toggleButton:SetSize(28, 28)

	-- Position: Top-right, next to other map buttons
	if WorldMapFrame.overlayFrames and WorldMapFrame.overlayFrames[2] then
		toggleButton:SetPoint("RIGHT", WorldMapFrame.overlayFrames[2], "LEFT", -18, 0)
	else
		toggleButton:SetPoint("TOPRIGHT", WorldMapFrame.BorderFrame, "TOPRIGHT", -10, -10)
	end

	-- Create circular background (like other map buttons)
	local bgTexture = toggleButton:CreateTexture(nil, "BACKGROUND")
	bgTexture:SetAllPoints(toggleButton)
	bgTexture:SetAtlas("transmog-icon-hidden")
	toggleButton.bg = bgTexture

	-- Create icon texture (circular)
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

	-- Button click handler
	toggleButton:SetScript("OnClick", function(self)
		local db = GatherMate.db.profile
		db.showWorldMap = not db.showWorldMap
		Display:UpdateWorldMap()
		UpdateButtonState()

		if db.showWorldMap then
			PlaySound(SOUNDKIT.MAP_PING)
		else
			PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
		end
	end)

	-- Tooltip
	toggleButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText("GatherMate2", 1, 1, 1)
		local db = GatherMate.db.profile
		if db.showWorldMap then
			GameTooltip:AddLine("|cff00ff00Nodes werden angezeigt|r", 1, 1, 1)
			GameTooltip:AddLine("Klicken zum Ausblenden", 0.5, 0.5, 0.5)
		else
			GameTooltip:AddLine("|cffff0000Nodes sind ausgeblendet|r", 1, 1, 1)
			GameTooltip:AddLine("Klicken zum Anzeigen", 0.5, 0.5, 0.5)
		end
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
