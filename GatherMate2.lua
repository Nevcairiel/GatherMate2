--[[
	This addon designed to be as lightweight as possible.
	It will only track, Mine, Herb, Fish, Gas and some Treasure nodes.
	This mods whole purpose is to be lean, simple and feature complete.
]]
-- Mixin AceEvent
local GatherMate = LibStub("AceAddon-3.0"):NewAddon("GatherMate2","AceConsole-3.0","AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GatherMate2",false)
_G["GatherMate2"] = GatherMate

-- locals
local db, gmdbs, filter
local reverseTables = {}
-- defaults for storage
local defaults = {
	profile = {
		scale       = 1.0,
		miniscale	= 0.75,
		alpha       = 1,
		show = {
			["Treasure"] = "always",
			["Logging"]  = "active",
			["*"] = "with_profession"
		},
		showMinimap = true,
		showWorldMap = true,
		minimapTooltips = true,
		filter = {
			["*"] = {
				["*"] = true,
			},
		},
		trackColors = {
			["Herb Gathering"] = {Red = 0, Green = 1, Blue = 0, Alpha = 1},
			["Fishing"]        = {Red = 1, Green = 1, Blue = 0, Alpha = 1},
			["Mining"]         = {Red = 1, Green = 0, Blue = 0, Alpha = 1},
			["Extract Gas"]    = {Red = 0, Green = 1, Blue = 1, Alpha = 1},
			["Treasure"]       = {Red = 1, Green = 0, Blue = 1, Alpha = 1},
			["Archaeology"]    = {Red = 1, Green = 1, Blue = 0.5, Alpha = 1},
			["Logging"]        = {Red = 0, Green = 0.8, Blue = 1, Alpha = 1},
			["*"]              = {Red = 1, Green = 0, Blue = 1, Alpha = 1},
		},
		trackDistance = 100,
		trackShow = "always",
		nodeRange = true,
		cleanupRange = {
			["Herb Gathering"] = 15,
			["Fishing"]        = 15,
			["Mining"]         = 15,
			["Extract Gas"]    = 50,
			["Treasure"]	   = 15,
			["Archaeology"]    = 10,
			["Logging"]        = 20,
		},
		dbLocks = {
			["Herb Gathering"] = false,
			["Fishing"]        = false,
			["Mining"]         = false,
			["Extract Gas"]    = false,
			["Treasure"]	   = false,
			["Archaeology"]    = false,
			["Logging"]        = false,
		},
		importers = {
			["*"] = {
				["Style"] = "Merge",
				["Databases"] = {},
				["lastImport"] = 0,
				["autoImport"] = false,
				["bcOnly"] = false,
			},
		}
	},
}
local floor = floor
local next = next

--[[
	Setup a few databases, we sub divide namespaces for resetting/importing
	:OnInitialize() is called at ADDON_LOADED so savedvariables are loaded
]]
function GatherMate:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("GatherMate2DB", defaults, "Default")
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

	-- Setup our saved vars, we dont use AceDB, cause it over kills
	-- These 4 savedvars are global and doesnt need char specific stuff in it
	GatherMate2HerbDB = GatherMate2HerbDB or {}
	GatherMate2MineDB = GatherMate2MineDB or {}
	GatherMate2GasDB = GatherMate2GasDB or {}
	GatherMate2FishDB = GatherMate2FishDB or {}
	GatherMate2TreasureDB = GatherMate2TreasureDB or {}
	GatherMate2ArchaeologyDB = GatherMate2ArchaeologyDB or {}
	GatherMate2LoggingDB = GatherMate2LoggingDB or {}
	self.gmdbs = {}
	self.db_types = {}
	gmdbs = self.gmdbs
	self:RegisterDBType("Herb Gathering", GatherMate2HerbDB)
	self:RegisterDBType("Mining", GatherMate2MineDB)
	self:RegisterDBType("Fishing", GatherMate2FishDB)
	self:RegisterDBType("Extract Gas", GatherMate2GasDB)
	self:RegisterDBType("Treasure", GatherMate2TreasureDB)
	self:RegisterDBType("Archaeology", GatherMate2ArchaeologyDB)
	self:RegisterDBType("Logging", GatherMate2LoggingDB)
	db = self.db.profile
	filter = db.filter
	-- Phasing version fix
	if not self.db.global.data_version then
		self:UpgradePhasing()
		self.db.global.data_version = 1
	end
	-- depractaion scan
	if self.db.global.data_version == 1 then
		self:RemoveDepracatedNodes()
		self.db.global.data_version = 2
	end

	self:GetMapInfo()
end

function GatherMate:RemoveDepracatedNodes()
	for database,storage in pairs(self.gmdbs) do
		for zone,data in pairs(storage) do
			for coord,value in pairs(data) do
				local name = self:GetNameForNode(database,value)
				if not name then
					data[coord] = nil
				end
			end
		end
	end
end

function GatherMate:UpgradePhasing()
	for database,storage in pairs(self.gmdbs) do
		local moved_nodes = {}
		-- copy the nodes
		local count = 0
		for zone,data in pairs(storage) do
			if self.phasing[zone] then -- Hyjal Phased terrain
				moved_nodes[self.phasing[zone]] = {}
				for coord,value in pairs(data) do
					moved_nodes[self.phasing[zone]][coord] = value
					count = count + 1
				end
			end
		end
		print("Fixing nodes("..count..") phasing for "..database)
		for k,v in pairs(moved_nodes) do
			for c,v in pairs(v) do
				storage[k][c] = v
			end
		end
		for k,v in pairs(self.phasing) do
			storage[k] = nil
		end
	end
end

--[[
	Register a new node DB for usage in GatherMate
]]
function GatherMate:RegisterDBType(name, db)
	tinsert(self.db_types, name)
	self.gmdbs[name] = db
end

function GatherMate:OnProfileChanged(db,name)
	db = self.db.profile
	filter = db.filter
	GatherMate:SendMessage("GatherMate2ConfigChanged")
end
--[[
	create a reverse lookup table for input table (we use it for english names of nodes)
]]
function GatherMate:CreateReversedTable(tbl)
	if reverseTables[tbl] then
		return reverseTables[tbl]
	end
	local reverse = {}
	for k, v in pairs(tbl) do
		reverse[v] = k
	end
	reverseTables[tbl] = reverse
	return setmetatable(reverse, getmetatable(tbl))
end
--[[
	Clearing function
]]
function GatherMate:ClearDB(dbx)
	-- for our own DBs we just discard the table and be happy
	-- db lock check
	if GatherMate.db.profile.dbLocks[dbx] then
		return
	end
	if dbx == "Herb Gathering" then	GatherMate2HerbDB = {}; gmdbs[dbx] = GatherMate2HerbDB
	elseif dbx == "Fishing" then GatherMate2FishDB = {}; gmdbs[dbx] = GatherMate2FishDB
	elseif dbx == "Extract Gas" then GatherMate2GasDB = {}; gmdbs[dbx] = GatherMate2GasDB
	elseif dbx == "Mining" then GatherMate2MineDB = {}; gmdbs[dbx] = GatherMate2MineDB
	elseif dbx == "Treasure" then GatherMate2TreasureDB = {}; gmdbs[dbx] = GatherMate2TreasureDB
	elseif dbx == "Archaeology" then GatherMate2ArchaeologyDB = {}; gmdbs[dbx] = GatherMate2ArchaeologyDB
	elseif dbx == "Logging" then GatherMate2LoggingDB = {}; gmdbs[dbx] = GatherMate2LoggingDB
	else -- for custom DBs we dont know the global name, so we clear it old-fashion style
		local db = gmdbs[dbx]
		if not db then error("Trying to clear unknown database: "..dbx) end
		for k in pairs(db) do
			db[k] = nil
		end
	end
end

--[[
	Add an item to the DB
]]
function GatherMate:AddNode(zone, x, y, level, nodeType, name)
	local db = gmdbs[nodeType]
	local id = self:EncodeLoc(x,y,level)
	-- db lock check
	if GatherMate.db.profile.dbLocks[nodeType] then
		return
	end
	db[zone] = db[zone] or {}
	db[zone][id] = self.nodeIDs[nodeType][name]
	self:SendMessage("GatherMate2NodeAdded", zone, nodeType, id, name)
end

--[[
	These 2 functions are only called by the importer/sharing. These
	do NOT fire GatherMateNodeAdded or GatherMateNodeDeleted messages.
]]
function GatherMate:InjectNode(zone, coords, nodeType, nodeID)
	local db = gmdbs[nodeType]
	-- db lock check
	if GatherMate.db.profile.dbLocks[nodeType] then
		return
	end
	db[zone] = db[zone] or {}
	db[zone][coords] = nodeID
end
function GatherMate:DeleteNode(zone, coords, nodeType)
	-- db lock check
	if GatherMate.db.profile.dbLocks[nodeType] then
		return
	end
	local db = gmdbs[nodeType][zone]
	if db then
		db[coords] = nil
	end
end

-- Do-end block for iterator
do
	local emptyTbl = {}
	local tablestack = setmetatable({}, {__mode = 'k'})

	local function dbCoordIterNearby(t, prestate)
		if not t then return nil end
		local data = t.data
		local state, value = next(data, prestate)
		local xLocal, yLocal, yw, yh = t.xLocal, t.yLocal, t.yw, t.yh
		local mLevel = t.mLevel
		local radiusSquared, filterTable, ignoreFilter = t.radiusSquared, t.filterTable, t.ignoreFilter
		while state do
			if filterTable[value] or ignoreFilter then
				-- inline the :getXY() here in critical minimap update loop
				local x2, y2, level2 = floor(state/1000000)/10000, floor(state % 1000000 / 100)/10000, state % 100
				local x = (x2 - xLocal) * yw
				local y = (y2 - yLocal) * yh
				if x*x + y*y <= radiusSquared and level2 == mLevel then
					return state, value
				end
			end
			state, value = next(data, state)
		end
		tablestack[t] = true
		return nil, nil
	end

	--[[
		Find all nearby nodes within the radius of the given (x,y) for a nodeType and zone
		this function returns an iterator
	]]
	function GatherMate:FindNearbyNode(zone, x, y, level, nodeType, radius, ignoreFilter)
		local tbl = next(tablestack) or {}
		tablestack[tbl] = nil
		tbl.data = gmdbs[nodeType][zone] or emptyTbl
		tbl.yw, tbl.yh =  self:GetZoneSize(zone,level)
		tbl.radiusSquared = radius * radius
		tbl.xLocal, tbl.yLocal = x, y
		tbl.mLevel = level
		tbl.filterTable = filter[nodeType]
		tbl.ignoreFilter = ignoreFilter
		return dbCoordIterNearby, tbl, nil
	end

	local function dbCoordIter(t, prestate)
		if not t then return nil end
		local data = t.data
		local state, value = next(data, prestate)
		local filterTable = t.filterTable
		while state do
			if filterTable[value] then
				return state, value
			end
			state, value = next(data, state)
		end
		tablestack[t] = true
		return nil, nil
	end

	--[[
		This function returns an iterator for the given zone and nodeType
	]]
	function GatherMate:GetNodesForZone(zone, nodeType, ignoreFilter)
		local t = gmdbs[nodeType][zone] or emptyTbl
		if ignoreFilter then
			return pairs(t)
		else
			local tbl = next(tablestack) or {}
			tablestack[tbl] = nil
			tbl.data = t
			tbl.filterTable = filter[nodeType]
			return dbCoordIter, tbl, nil
		end
	end
end
--[[
	Node id function forward and reverse
]]
function GatherMate:GetIDForNode(type, name)
	return self.nodeIDs[type][name]
end
--[[
	Get the name for a nodeID
]]
function GatherMate:GetNameForNode(type, nodeID)
	return self.reverseNodeIDs[type][nodeID]
end
--[[
	Remove an item from the DB
]]
function GatherMate:RemoveNode(zone, x, y, level, nodeType)
	local db = gmdbs[nodeType][zone]
	local coord = self:EncodeLoc(x,y,level)
	if db[coord] then
		local t = self.reverseNodeIDs[nodeType][db[coord]]
		db[coord] = nil
		self:SendMessage("GatherMate2NodeDeleted", zone, nodeType, coord, t)
	end
end
--[[
	Remove an item from the DB by node ID and type
]]
function GatherMate:RemoveNodeByID(zone, nodeType, coord)
	-- db lock check
	if GatherMate.db.profile.dbLocks[nodeType] then
		return
	end
	local db = gmdbs[nodeType][zone]
	if db[coord] then
		local t = self.reverseNodeIDs[nodeType][db[coord]]
		db[coord] = nil
		self:SendMessage("GatherMate2NodeDeleted", zone, nodeType, coord, t)
	end
end

--[[
	Function to cleanup the databases by removing nearby nodes of similar types
	As of 02/17/2013 will be converted to become a coroutine
--]]

local CleanerUpdateFrame = CreateFrame("Frame")
CleanerUpdateFrame.running = false

function CleanerUpdateFrame:OnUpdate(elapsed)
	local finished = coroutine.resume(self.cleanup)
	if finished then
		if coroutine.status(self.cleanup) == "dead" then
			self:SetScript("OnUpdate",nil)
			self.running = false
			self.cleanup = nil
			GatherMate:Print(L["Cleanup Complete."])
		end
	else
		self:SetScript("OnUpdate",nil)
		self.runing = false
		self.cleanup = nil
		GatherMate:Print(L["Cleanup Failed."])
	end
end

function GatherMate:IsCleanupRunning()
	return CleanerUpdateFrame.running
end

function GatherMate:SweepDatabase()
	local Collector = GatherMate:GetModule("Collector")
	local rares = Collector.rareNodes
	for v,zone in pairs(GatherMate:GetAllMapIDs()) do
		--self:Print(L["Processing "]..zone)
		coroutine.yield()
		for profession in pairs(gmdbs) do
			local range = db.cleanupRange[profession]
			for coord, nodeID in self:GetNodesForZone(zone, profession, true) do
				local x,y,level = self:DecodeLoc(coord)
				for _coord, _nodeID in self:FindNearbyNode(zone, x, y, level, profession, range, true) do
					if coord ~= _coord and (nodeID == _nodeID or (rares[_nodeID] and rares[_nodeID][nodeID])) then
						self:RemoveNodeByID(zone, profession, _coord)
					end
				end
			end
		end
	end
	self:RemoveDepracatedNodes()
	self:SendMessage("GatherMate2Cleanup")
end

function GatherMate:CleanupDB()
	if not CleanerUpdateFrame.running then
		CleanerUpdateFrame.cleanup = coroutine.create(GatherMate.SweepDatabase)
		CleanerUpdateFrame:SetScript("OnUpdate",CleanerUpdateFrame.OnUpdate)
		CleanerUpdateFrame.running = true
		local status = coroutine.resume(CleanerUpdateFrame.cleanup,GatherMate)
		if not status then
			CleanerUpdateFrame.running = false
			CleanerUpdateFrame:SetScript("OnUpdate",nil)
			CleanerUpdateFrame.cleanup = nil
			self:Print(L["Cleanup Failed."])
		else
			self:Print(L["Cleanup Started."])
		end
	else
		self:Print(L["Cleanup in progress."])
	end
end

--[[
	Function to delete all of a specified node from a specific zone
]]
function GatherMate:DeleteNodeFromZone(nodeType, nodeID, zone)
	local db = gmdbs[nodeType][zone]
	if db then
		for coord, node in pairs(db) do
			if node == nodeID then
				self:RemoveNodeByID(zone, nodeType, coord)
			end
		end
		self:SendMessage("GatherMate2Cleanup")
	end
end

--[[
	Encode location
]]
function GatherMate:EncodeLoc(x, y, level)
	local level = level or 0
	if x > 0.9999 then
		x = 0.9999
	end
	if y > 0.9999 then
		y = 0.9999
	end
	return floor( x * 10000 + 0.5 ) * 1000000 + floor( y * 10000  + 0.5 ) * 100 + level
end

--[[
	Decode location
]]
function GatherMate:DecodeLoc(id)
	return floor(id/1000000)/10000, floor(id % 1000000 / 100)/10000, id % 100
end

--[[
	Map Info block
]]
do
	local mapToId, idToMap = {}, {}
	local mapLocalized = {}
	local mapInstances = {}
	local mapInfo = {} --table { width, height, left, top, right, bottom }

	local function processZone(id, name)
		if not id or mapInfo[id] then return end
		SetMapByID(id)
		local mapFile = GetMapInfo()
		local numFloors = GetNumDungeonMapLevels()
		idToMap[id] = mapFile

		if not mapToId[mapFile] then mapToId[mapFile] = id end
		mapLocalized[id] = name or GetMapNameByID(id)

		local _, left, top, right, bottom = GetCurrentMapZone()
		if (left and top and right and bottom and (left ~= 0 or top ~= 0 or right ~= 0 or bottom ~= 0)) then
			mapInfo[id] = { left - right, top - bottom, left, top, right, bottom }
		elseif not mapInfo[id] then
			mapInfo[id] = { 0, 0, 0, 0, 0, 0}
		end

		mapInfo[id].instance = GetAreaMapInfo(id)

		if numFloors == 0 and GetCurrentMapDungeonLevel() == 1 then
			numFloors = 1
			mapInfo[id].fakefloor = true
		end

		if DungeonUsesTerrainMap() then
			numFloors = numFloors - 1
		end

		mapInfo[id].floors = {}
		if numFloors > 0 then
			for f = 1, numFloors do
				SetDungeonMapLevel(f)
				local _, right, bottom, left, top  = GetCurrentMapDungeonLevel()
				if left and top and right and bottom then
					mapInfo[id].floors[f] = { left - right, top - bottom, left, top, right, bottom }
					mapInfo[id].floors[f].instance = mapInfo[id].instance
				end
			end
		end
	end

	--[[
		load map data into the map info tables
	]]
	function GatherMate:GetMapInfo()
		local continents = {GetMapContinents()}
		for i = 1, #continents, 2 do
			processZone(continents[i], continents[i+1])
			local zones = {GetMapZones((i + 1) / 2)}
			for z =  1, #zones, 2 do
				processZone(zones[z], zones[z+1])
			end
		end

		local areas = GetAreaMaps()
		for idx, zoneId in pairs(areas) do
			processZone(zoneId)
		end
	end

	--[[
		Get the localized name of the map
	]]
	function GatherMate:MapLocalize(mapId)
		if mapId == WORLDMAP_COSMIC_ID then return WORLD_MAP end
		if type(mapId) == "string" then
			mapId = mapToId[mapId]
		end
		assert(mapLocalized[mapId])
		return mapLocalized[mapId]
	end

	--[[
		get the area id of the map
	]]
	function GatherMate:MapAreaId(mapFile)
		assert(mapToId[mapFile])
		return mapToId[mapFile]
	end

	--[[
		get a list of all map ids
	]]
	function GatherMate:GetAllMapIDs()
		local t = {}
		for id in pairs(mapInfo) do
			tinsert(t, id)
		end
		return t
	end

	function GatherMate:GetDataTable(mapId, level)
		if mapId == WORLDMAP_COSMIC_ID then return nil end
		if type(mapId) == "string" then
			mapId = mapToId[mapId]
		end
		local data = mapInfo[mapId]
		if not data then return nil end

		if (level == nil or level == 0) and data.fakefloor then
			level = 1
		end

		if level and level > 0 and data.floors[level] then
			return data.floors[level]
		else
			return data
		end
	end

	--[[
		get the size of the zone, in yards
	]]
	function GatherMate:GetZoneSize(mapId, level)
		if type(mapId) == "string" then
			mapId = mapToId[mapId]
		end
		local data = self:GetDataTable(mapId, level)
		if not data then return 0, 0 end

		return data[1],data[2]
	end

	--[[
		Get the distance between 2 points in a zone
	]]
	function GatherMate:Distance(zone, level, x1, y1, x2, y2)
		local width, height = self:GetZoneSize(zone, level)
		local x = (x2 - x1) * width
		local y = (y2 - y1) * height
		return (x*x + y*y)^0.5
	end

	--[[
		convert a point on the map to yard values
	]]
	function GatherMate:PointToYards(x, y, zone, level)
		local width, height = self:GetZoneSize(zone, level)
		return x * width, y * height
	end

	--[[
		convert yard values to a point on the map
	]]
	function GatherMate:YardToPoints(x, y, zone, level)
		local width, height = self:GetZoneSize(zone, level)
		if width == 0 or height == 0 then return 0, 0 end
		return x / width, y / height
	end

	--[[
		get the player position in yards
	]]
	function GatherMate:PlayerPositionYards(mapId, level)
		local data = self:GetDataTable(mapId, level)
		if not data then return 0, 0 end

		local y, x, z, instanceId = UnitPosition("player")
		if data.instance ~= instanceId then return 0, 0 end
		local left, top, right, bottom = data[3], data[4], data[5], data[6]
		x = (left - x)
		y = (top - y)
		return x, y
	end
end
