local GatherMate = LibStub("AceAddon-3.0"):GetAddon("GatherMate2")
local Collector = GatherMate:NewModule("Collector", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GatherMate2",true)
local NL = LibStub("AceLocale-3.0"):GetLocale("GatherMate2Nodes")   -- for get the local name of Gas Cloud´s

-- prevSpell, curSpell are markers for what has been cast now and the lastcast
-- gatherevents if a flag for wether we are listening to events
local prevSpell, curSpell, foundTarget, ga

local GetSpellName = C_Spell.GetSpellName

--[[
Convert for 2.4 spell IDs
]]
local miningSpell = (GetSpellName(2575))
local miningSpell2 = (GetSpellName(195122))
local miningSpell3 = (GetSpellName(423341)) -- Khaz Algar
local herbSpell = (GetSpellName(2366))
local herbSkill = ((GetSpellName(170691)) or (string.gsub((GetSpellName(9134)),"%A","")))
local fishSpell = (GetSpellName(7620)) or (GetSpellName(131476))
local gasSpell = (GetSpellName(30427))
--local gasSpell = (GetSpellName(48929))  --other gasspell
local openSpell = (GetSpellName(3365))
local openNoTextSpell = (GetSpellName(22810))
local pickSpell = (GetSpellName(1804))
local archSpell = (GetSpellName(73979)) -- Searching for Artifacts spell
local sandStormSpell = (GetSpellName(93473)) -- Sandstorm spell cast by the camel
local loggingSpell = (GetSpellName(167895))

local spells =
{ -- spellname to "database name"
	[miningSpell] = "Mining",
	[miningSpell2] = "Mining",
	[miningSpell3] = "Mining",
	[herbSpell] = "Herb Gathering",
	[fishSpell] = "Fishing",
	[gasSpell] = "Extract Gas",
	[openSpell] = "Treasure",
	[openNoTextSpell] = "Treasure",
	[pickSpell] = "Treasure",
	[archSpell] = "Archaeology",
	[sandStormSpell] = "Treasure",
	[loggingSpell] = "Logging",
	[205243] = "Treasure", -- skinning ground warts
}
local tooltipLeftText1 = _G["GameTooltipTextLeft1"]
local strfind = string.find
local pii = math.pi
local sin = math.sin
local cos = math.cos
--[[
	This search string code no longer needed since we use CombatEvent to detect gas clouds harvesting
]]
-- buffsearchstring is for gas extartion detection of the aura event
-- local buffSearchString
--local sub_string = GetLocale() == "deDE" and "%%%d$s" or "%%s"
--buffSearchString = string.gsub(AURAADDEDOTHERHELPFUL, sub_string, "(.+)")

--[[
	Enable the collector
]]
function Collector:OnEnable()
	self:RegisterGatherEvents()
end

--[[
	Register the events we are interesting
]]
function Collector:RegisterGatherEvents()
	self:RegisterEvent("UNIT_SPELLCAST_SENT","SpellStarted")
	self:RegisterEvent("UNIT_SPELLCAST_STOP","SpellStopped")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED","SpellFailed")
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED","SpellFailed")
	self:RegisterEvent("CURSOR_CHANGED","CursorChange")
	self:RegisterEvent("UI_ERROR_MESSAGE","UIError")
	--self:RegisterEvent("LOOT_CLOSED","GatherCompleted")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "GasBuffDetector")
	self:RegisterEvent("CHAT_MSG_LOOT","SecondaryGasCheck") -- for Storm Clouds
end

--[[
	Unregister the events
]]
function Collector:UnregisterGatherEvents()
	self:UnregisterEvent("UNIT_SPELLCAST_SENT")
	self:UnregisterEvent("UNIT_SPELLCAST_SENT")
	self:UnregisterEvent("UNIT_SPELLCAST_STOP")
	self:UnregisterEvent("UNIT_SPELLCAST_FAILED")
	self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:UnregisterEvent("CURSOR_CHANGED")
	self:UnregisterEvent("UI_ERROR_MESSAGE")
	--self:UnregisterEvent("LOOT_CLOSED")
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

local CrystalizedWater = (C_Item.GetItemNameByID(37705)) or ""
local MoteOfAir = (C_Item.GetItemNameByID(22572)) or ""

function Collector:SecondaryGasCheck(event,msg)
	if ga ~= gasSpell then return end
	if not msg then return end
	if foundTarget then return end
	if ga == gasSpell and strfind(msg,CrystalizedWater) then
		-- check for Steam Clouds by assuming your always getting water from Steam Clouds
		foundTarget = true
		self:addItem(ga,NL["Steam Cloud"])
		ga = "No"
	end
	if ga == gasSpell and strfind(msg,MoteOfAir) then
		-- check for Steam Clouds by assuming your always getting water from Steam Clouds
		foundTarget = true
		self:addItem(ga,NL["Windy Cloud"])
		ga = "No"
	end
end

--[[
	This is a hack for scanning mote extraction, hopefully blizz will make the mote mobs visible so we can mouse over
	or get a better event instead of cha msg parsing
	UNIT_DISSIPATES,0x0000000000000000,nil,0x80000000,0xF1307F0A00002E94,"Cinder Cloud",0xa28 now fires in cataclysm so hack not needed any more
]]
function Collector:GasBuffDetector(b)
	if foundTarget or (prevSpell and prevSpell ~= gasSpell) then return end
	local timestamp, eventType, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, spellId,spellName = CombatLogGetCurrentEventInfo()

	if eventType == "SPELL_CAST_SUCCESS" and  spellName == gasSpell then
		ga = gasSpell
	elseif eventType == "UNIT_DISSIPATES" and  ga == gasSpell then
		foundTarget = true
		self:addItem(ga,dstName)
		ga = "No"
	end
	-- Try to detect the camel figurine
	if eventType == "SPELL_CAST_SUCCESS" and spellName == sandStormSpell and srcName == NL["Mysterious Camel Figurine"] then
		foundTarget = true
		self:addItem(sandStormSpell,NL["Mysterious Camel Figurine"])
	end

end

--[[
	Any time we close a loot window stop checking for targets ala the Fishing bobber
]]
function Collector:GatherCompleted()
	prevSpell, curSpell = nil, nil
	foundTarget = false
end

--[[
	When the hand icon goes to a gear see if we can find a nde under the gear ala for the fishing bobber OR herb of mine
]]
function Collector:CursorChange()
	if foundTarget then return end
	if (MinimapCluster:IsMouseOver()) then return end
	if spells[prevSpell] then
		self:GetWorldTarget()
	end
end

--[[
	We stopped casting the spell
]]
function Collector:SpellStopped(event,unit)
	if unit ~= "player" then return end
	if spells[prevSpell] then
		self:GetWorldTarget()
	end
	-- prev spel needs set since it is used for cursor changes
	prevSpell, curSpell = curSpell, curSpell
end

--[[
	We failed to cast
]]
function Collector:SpellFailed(event,unit)
	if unit ~= "player" then return end
	prevSpell, curSpell = nil, nil
end

--[[
	UI Error from gathering when you dont have the required skill
]]
function Collector:UIError(event,token,msg)
	local what = tooltipLeftText1:GetText();
	if not what then return end
	if strfind(msg, miningSpell) or (miningSpell2 and strfind(msg, miningSpell2) or (miningSpell3 and strfind(msg, miningSpell3))) then
		self:addItem(miningSpell,what)
	elseif strfind(msg, herbSkill) then
		self:addItem(herbSpell,what)
	elseif strfind(msg, pickSpell) or strfind(msg, openSpell) then -- locked box or failed pick
		self:addItem(openSpell, what)
	elseif strfind(msg, NL["Lumber Mill"]) then -- timber requires lumber mill
		self:addItem(loggingSpell, what)
	end
end

--[[
	spell cast started
]]
function Collector:SpellStarted(event,unit,target,guid,spellcast)
	if unit ~= "player" then return end
	foundTarget = false
	ga ="No"
	local spellname = GetSpellName(spellcast)
	if spellname and (spells[spellname] or spells[spellcast]) then
		if spells[spellname] then
			curSpell = spellname
			prevSpell = spellname
		else
			curSpell = spellcast
			prevSpell = spellcast
		end
		local nodeID = GatherMate:GetIDForNode(spells[prevSpell], target)
		if nodeID then -- seem 2.4 has the node name now as the target
			self:addItem(prevSpell,target)
			foundTarget = true
		else
			self:GetWorldTarget()
		end
	else
		prevSpell, curSpell = nil, nil
	end
end

--[[
	add an item to the map (we delgate to GatherMate)
]]
local lastNode = ""
local lastNodeCoords = 0

function Collector:addItem(skill,what)
	local x, y, zone = GatherMate.HBD:GetPlayerZonePosition()
	if not x or not y then return end -- no valid data

	-- don't collect any data in the garrison, its always the same location and spams the map
	-- TODO: garrison ids
	if GatherMate.mapBlacklist[zone] then return end
	if GatherMate.phasing[zone] then zone = GatherMate.phasing[zone] end

	local node_type = spells[skill]
	if not node_type or not what then return end
	-- db lock check
	if GatherMate.db.profile.dbLocks[node_type] then return	end

	-- special case for fishing and gas extraction guage the pointing direction
	if node_type == fishSpell or node_type == gasSpell then
		local yw, yh = GatherMate.HBD:GetZoneSize(zone)
		if yw == 0 or yh == 0 then return end -- No zone size data
		x,y = self:GetFloatingNodeLocation(x, y, yw, yh)
	end
	-- avoid duplicate readds
	local foundCoord = GatherMate:EncodeLoc(x, y)
	if foundCoord == lastNodeCoords and what == lastNode then return end

	-- tell the core to add it
	local added = GatherMate:AddNodeChecked(zone, x, y, node_type, what)
	if added then
		lastNode = what
		lastNodeCoords = foundCoord
	end
	self:GatherCompleted()
end

--[[
	move the node 20 yards in the direction the player is looking at
]]
function Collector:GetFloatingNodeLocation(x,y,yardWidth,yardHeight)
	local facing = GetPlayerFacing()
	if not facing then	-- happens when minimap rotation is on
		return x,y
	else
		local rad = facing + pii
		return x + sin(rad)*15/yardWidth, y + cos(rad)*15/yardHeight
	end
end

--[[
	get the target your clicking on
]]
function Collector:GetWorldTarget()
	if foundTarget or not spells[curSpell] then return end
	if (MinimapCluster:IsMouseOver()) then return end
	local what = tooltipLeftText1:GetText()
	local nodeID = GatherMate:GetIDForNode(spells[prevSpell], what)
	if what and prevSpell and what ~= prevSpell and nodeID then
		self:addItem(prevSpell,what)
		foundTarget = true
	end
end
