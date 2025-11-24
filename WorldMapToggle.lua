local GatherMate = LibStub("AceAddon-3.0"):GetAddon("GatherMate2")
local Display = GatherMate:GetModule("Display")

local toggleButton = nil

-- Function to create the toggle button
local function CreateToggleButton()
	if toggleButton then return end

	-- Create button on WorldMapFrame.BorderFrame (correct parent!)
	toggleButton = CreateFrame("Button", "GatherMate2WorldMapToggle", WorldMapFrame.BorderFrame, "UIPanelButtonTemplate")
	toggleButton:SetSize(32, 32)

	-- Position: Top-left of map, below the quest log icon
	toggleButton:SetPoint("TOPLEFT", WorldMapFrame.BorderFrame, "TOPLEFT", 10, -80)

	-- Create icon texture
	local icon = toggleButton:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints(toggleButton)
	icon:SetTexture("Interface\\AddOns\\GatherMate2\\Artwork\\Icon")
	toggleButton.icon = icon

	-- Button click handler
	toggleButton:SetScript("OnClick", function(self)
		local db = GatherMate.db.profile
		db.showWorldMap = not db.showWorldMap
		Display:UpdateWorldMap()
		UpdateButtonState()

		-- Play sound
		if db.showWorldMap then
			PlaySound(SOUNDKIT.MAP_PING)
		else
			PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
		end
	end)

	-- Tooltip
	toggleButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
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
		-- Nodes visible - button looks enabled
		toggleButton.icon:SetDesaturated(false)
		toggleButton.icon:SetAlpha(1.0)
	else
		-- Nodes hidden - button looks disabled
		toggleButton.icon:SetDesaturated(true)
		toggleButton.icon:SetAlpha(0.5)
	end
end

-- Hook WorldMapFrame OnShow to create/show button
WorldMapFrame:HookScript("OnShow", function()
	CreateToggleButton()
	if toggleButton then
		toggleButton:Show()
		UpdateButtonState()
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
	end
end)
