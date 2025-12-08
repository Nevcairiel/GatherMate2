--[[
	This addon designed to be as lightweight as possible.
	It will only track, Mine, Herb, Fish, Gas and some Treasure nodes.
	This mods whole purpose is to be lean, simple and feature complete.
]]
-- Mixin AceEvent
local GatherMate = LibStub("AceAddon-3.0"):NewAddon("GatherMate2","AceConsole-3.0","AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GatherMate2",false)
_G["GatherMate2"] = GatherMate

GatherMate.HBD = LibStub("HereBeDragons-2.0")
local HBDMigrate = LibStub("HereBeDragons-Migrate")

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
		worldMapIconsInteractive = true,
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
			["Treasure"]       = 15,
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

--[[
	Setup a few databases, we sub divide namespaces for resetting/importing
	:OnInitialize() is called at ADDON_LOADED so savedvariables are loaded
]]
function GatherMate:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("GatherMate2DB", defaults, "Default")
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

	self.gmdbs = {}
	self.db_types = {}
	self.db_storage_map = {}
	gmdbs = self.gmdbs
	self:RegisterDBType("Herb Gathering", "Herb")
	self:RegisterDBType("Mining", "Mine")
	self:RegisterDBType("Fishing", "Fish")
	self:RegisterDBType("Treasure", "Treasure")
	self:RegisterDBType("Extract Gas", "Gas")
	self:RegisterDBType("Archaeology", "Archaeology")
	self:RegisterDBType("Logging", "Logging")
	db = self.db.profile
	filter = db.filter
	-- depractaion scan
	if (self.db.global.data_version or 0) == 1 then
		self:RemoveDepracatedNodes()
		self.db.global.data_version = 2
	end
	if (self.db.global.data_version or 0) < 4 then
		self:RemoveGarrisonNodes()
		self.db.global.data_version = 4
	end
	if (self.db.global.data_version or 0) < 5 then
		self:MigrateData80()
		self.db.global.data_version = 5
	end
	if (self.db.global.data_version or 0) < 6 then
		self:RemoveDepracatedNodes()
		self.db.global.data_version = 6
	end

end

function GatherMate:OnEnable()
	-- moved to OnEnable so it can upgrade additional storage addons
	if (self.db.global.data_version or 0) < 8 then
		self:UpgradeNodeIDs()
		self.db.global.data_version = 8
	end
end

function GatherMate:RemoveGarrisonNodes()
	for _, database in pairs({"Herb Gathering", "Mining"}) do
		gmdbs[database][971] = {}
		gmdbs[database][976] = {}
	end
end

function GatherMate:RemoveDepracatedNodes()
	for database,storage in pairs(self.gmdbs) do
		local storeDB = storage and storage.__gm2_base_storage or storage
		for zone,data in pairs(storeDB) do
			for coord,value in pairs(data) do
				local name = self:GetNameForNode(database,value)
				if not name then
					data[coord] = nil
				end
			end
		end
	end
end

local function replaceNodeIDs(storage, idMap)
	for zone,data in pairs(storage) do
		for coord,value in pairs(data) do
			if idMap[value] then
				data[coord] = idMap[value]
			end
		end
	end
end

function GatherMate:UpgradeNodeIDs()
	for database,storage in pairs(self.gmdbs) do
		if storage.__gm2_base_storage then
			replaceNodeIDs(storage.__gm2_base_storage, self.nodeIDReplacementMap)
			for key,store in pairs(storage.__gm2_storage_map) do
				replaceNodeIDs(store, self.nodeIDReplacementMap)
			end
		end
	end
end

function GatherMate:MigrateData80()
	for database,storage in pairs(self.gmdbs) do
		local migrated_storage = {}
		local storeDB = storage and storage.__gm2_base_storage or storage
		for zone,data in pairs(storeDB) do
			for coord,value in pairs(data) do
				local level = coord % 100
				local newzone = HBDMigrate:GetUIMapIDFromMapAreaId(zone, level)
				if newzone then
					newzone = self.phasing[newzone] or newzone
					if not migrated_storage[newzone] then
						migrated_storage[newzone] = {}
					end
					migrated_storage[newzone][coord] = value
				end
			end
			storeDB[zone] = nil
		end
		for zone,data in pairs(migrated_storage) do
			storeDB[zone] = migrated_storage[zone]
			migrated_storage[zone] = nil
		end
	end
end

function GatherMate:GetNodeBaseStorage(db_meta, zone)
	local storagePrefix = self.db_storage_map[zone]
	if storagePrefix then
		return db_meta.__gm2_storage_map[storagePrefix]
	end

	return db_meta.__gm2_base_storage
end

function GatherMate:GetNodeStorage(db_meta, zone)
	local storage = self:GetNodeBaseStorage(db_meta, zone)
	if storage then
		return storage[zone]
	end
	return nil
end

--[[
	Register a new node DB for usage in GatherMate
]]
function GatherMate:RegisterDBType(name, db_or_prefix)
	tinsert(self.db_types, name)

	-- continue to support custom registrations with a database
	if type(db_or_prefix) == "table" then
		self.gmdbs[name] = db_or_prefix
		return
	end

	local dbName = "GatherMate2" .. db_or_prefix .. "DB"

	-- ensure the DB exists
	_G[dbName] = _G[dbName] or {}

	self.gmdbs[name] = setmetatable({__gm2_prefix = db_or_prefix, __gm2_storage_map = {}, __gm2_base_storage = _G[dbName]}, {
		__index = function(t,k) return GatherMate:GetNodeStorage(t, k) end,
		__newindex = function(t,k,v) local storage = GatherMate:GetNodeBaseStorage(t, k); storage[k] = v end
	})
end

function GatherMate:RegisterStorage(storagePrefix, zones)
	-- ensure the databases exist
	for db_type, db_meta in pairs(self.gmdbs) do
		local dbprefix = db_meta.__gm2_prefix
		if dbprefix then
			local dbStorageName = "GatherMate2" .. dbprefix .. "DB" .. storagePrefix
			_G[dbStorageName] = _G[dbStorageName] or {}

			db_meta.__gm2_storage_map[storagePrefix] = _G[dbStorageName]
		end
	end

	for _, zone in pairs(zones) do
		self.db_storage_map[zone] = storagePrefix
	end

	self:MigrateStorage(storagePrefix, zones)
end

function GatherMate:RegisterStorageAddOn(addOnName)
	local tag = C_AddOns.GetAddOnMetadata(addOnName, "X-GM2-Storage-Tag")
	local zoneList = C_AddOns.GetAddOnMetadata(addOnName, "X-GM2-Storage-Zones")

	if not (tag and zoneList) then return end

	local zoneTable = {}
	for v in string.gmatch(zoneList, "[0-9]+") do
		local zone = tonumber(v)
		if zone and zone > 0 then
			table.insert(zoneTable, zone)
		end
	end

	if tag and #zoneTable > 0 then
		self:RegisterStorage(tag, zoneTable)
	end
end

function GatherMate:MigrateStorage(storagePrefix, zones)
	for db_type, db_meta in pairs(self.gmdbs) do
		local dbprefix = db_meta.__gm2_prefix
		if dbprefix then
			local dbName = "GatherMate2" .. dbprefix .. "DB"
			local dbStorageName = "GatherMate2" .. dbprefix .. "DB" .. storagePrefix

			local dbMain, dbStorage = _G[dbName], _G[dbStorageName]
			for _, zone in pairs(zones) do
				if dbMain[zone] then
					if not dbStorage[zone] then
						dbStorage[zone] = dbMain[zone]
					else
						for k,v in pairs(dbMain[zone]) do
							dbStorage[zone][k] = v
						end
					end
					dbMain[zone] = nil
				end
			end
		end
	end
end

function GatherMate:OnProfileChanged(_db,name)
	db = self.db.profile
	filter = db.filter
	GatherMate:SendMessage("GatherMate2ConfigChanged")
end

function GatherMate:CreateNodeLookupTables(node_data)
	local nodeIdLookup, nodeReverseLookup = {}, {}
	local nodeOldIdMap = {}

	for db_type, db_data in pairs(node_data) do
		nodeIdLookup[db_type], nodeReverseLookup[db_type] = {}, {}
		for name, node in pairs(db_data) do
			if type(node) == "table" then
				nodeIdLookup[db_type][name] = node.id
				nodeReverseLookup[db_type][node.id] = name

				if node.variants then
					for _, variantName in pairs(node.variants) do
						nodeIdLookup[db_type][variantName] = node.id
					end
				end

				if node.old_ids then
					for _, old_id in pairs(node.old_ids) do
						nodeOldIdMap[old_id] = node.id
						nodeReverseLookup[db_type][old_id] = name
					end
				end
			else
				nodeIdLookup[db_type][name] = node
				nodeReverseLookup[db_type][node] = name
			end
		end
	end

	return nodeIdLookup, nodeReverseLookup, nodeOldIdMap
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
	local nodedb = gmdbs[dbx]
	if not nodedb then error("Trying to clear unknown database: "..dbx) end
	if nodedb.__gm2_prefix then
		table.wipe(nodedb.__gm2_base_storage)
		for k,v in pairs(nodedb.__gm2_storage_map) do
			table.wipe(v)
		end
	else
		table.wipe(nodedb)
	end
end

--[[
	Add an item to the DB
]]
function GatherMate:AddNode(zone, x, y, nodeType, name)
	local nodedb = gmdbs[nodeType]
	if not nodedb then return end
	local id = self:EncodeLoc(x,y)
	-- db lock check
	if GatherMate.db.profile.dbLocks[nodeType] then
		return
	end
	nodedb[zone] = nodedb[zone] or {}
	nodedb[zone][id] = self.nodeIDs[nodeType][name]
	self:SendMessage("GatherMate2NodeAdded", zone, nodeType, id, name)
end

--[[
	Add an item to the DB, performing duplicate checks and cleanup
]]
function GatherMate:AddNodeChecked(zone, x, y, nodeType, name)
	-- get the node id for what we're adding
	local nid = GatherMate:GetIDForNode(nodeType, name)
	if not nid then return end

	-- cleanup range
	local range = GatherMate.db.profile.cleanupRange[nodeType]

	-- check for existing nodes
	local skip = false
	local rares = self.rareNodes
	for coord, nodeID in GatherMate:FindNearbyNode(zone, x, y, nodeType, range, true) do
		if (nodeID == nid or rares[nodeID] and rares[nodeID][nid]) then
			GatherMate:RemoveNodeByID(zone, nodeType, coord)
		-- we're trying to add a rare node, but there is already a normal node present, skip the adding
		elseif rares[nid] and rares[nid][nodeID] then
			skip = true
		end
	end

	if not skip then
		GatherMate:AddNode(zone, x, y, nodeType, name)
	end

	return not skip
end

--[[
	These 2 functions are only called by the importer/sharing. These
	do NOT fire GatherMateNodeAdded or GatherMateNodeDeleted messages.

	Renamed to InjectNode2/DeleteNode2 to ensure data addon compatibility with 8.0 zone IDs
]]
function GatherMate:InjectNode2(zone, coords, nodeType, nodeID)
	local nodedb = gmdbs[nodeType]
	if not nodedb then return end
	-- db lock check
	if GatherMate.db.profile.dbLocks[nodeType] then
		return
	end
	if (nodeType == "Mining" or nodeType == "Herb Gathering") and GatherMate.mapBlacklist[zone] then return end
	nodedb[zone] = nodedb[zone] or {}
	nodedb[zone][coords] = self.nodeIDReplacementMap[nodeID] or nodeID
end
function GatherMate:DeleteNode2(zone, coords, nodeType)
	if not gmdbs[nodeType] then return end
	-- db lock check
	if GatherMate.db.profile.dbLocks[nodeType] then
		return
	end
	local nodedb = gmdbs[nodeType][zone]
	if nodedb then
		nodedb[coords] = nil
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
		local radiusSquared, filterTable, ignoreFilter = t.radiusSquared, t.filterTable, t.ignoreFilter
		while state do
			if filterTable[value] or ignoreFilter then
				-- inline the :getXY() here in critical minimap update loop
				local x2, y2 = floor(state/1000000)/10000, floor(state % 1000000 / 100)/10000
				local x = (x2 - xLocal) * yw
				local y = (y2 - yLocal) * yh
				if x*x + y*y <= radiusSquared then
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
	function GatherMate:FindNearbyNode(zone, x, y, nodeType, radius, ignoreFilter)
		local tbl = next(tablestack) or {}
		tablestack[tbl] = nil
		tbl.data = gmdbs[nodeType][zone] or emptyTbl
		tbl.yw, tbl.yh = self.HBD:GetZoneSize(zone)
		tbl.radiusSquared = radius * radius
		tbl.xLocal, tbl.yLocal = x, y
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
function GatherMate:RemoveNode(zone, x, y, nodeType)
	if not gmdbs[nodeType] then return end
	local nodedb = gmdbs[nodeType][zone]
	local coord = self:EncodeLoc(x,y)
	if nodedb[coord] then
		local t = self.reverseNodeIDs[nodeType][nodedb[coord]]
		nodedb[coord] = nil
		self:SendMessage("GatherMate2NodeDeleted", zone, nodeType, coord, t)
	end
end
--[[
	Remove an item from the DB by node ID and type
]]
function GatherMate:RemoveNodeByID(zone, nodeType, coord)
	if not gmdbs[nodeType] then return end
	-- db lock check
	if GatherMate.db.profile.dbLocks[nodeType] then
		return
	end
	local nodedb = gmdbs[nodeType][zone]
	if nodedb[coord] then
		local t = self.reverseNodeIDs[nodeType][nodedb[coord]]
		nodedb[coord] = nil
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
	self:UpgradeNodeIDs()

	local rares = self.rareNodes
	for v,zone in pairs(GatherMate.HBD:GetAllMapIDs()) do
		--self:Print(L["Processing "]..zone)
		coroutine.yield()
		for profession in pairs(gmdbs) do
			local range = db.cleanupRange[profession]
			for coord, nodeID in self:GetNodesForZone(zone, profession, true) do
				local x,y = self:DecodeLoc(coord)
				for _coord, _nodeID in self:FindNearbyNode(zone, x, y, profession, range, true) do
					if coord ~= _coord and (nodeID == _nodeID or (rares[_nodeID] and rares[_nodeID][nodeID])) then
						self:RemoveNodeByID(zone, profession, _coord)
					end
				end
			end
			coroutine.yield()
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
	if not gmdbs[nodeType] then return end
	local nodedb = gmdbs[nodeType][zone]
	if nodedb then
		for coord, node in pairs(nodedb) do
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
function GatherMate:EncodeLoc(x, y)
	if x > 0.9999 then
		x = 0.9999
	end
	if y > 0.9999 then
		y = 0.9999
	end
	return floor( x * 10000 + 0.5 ) * 1000000 + floor( y * 10000  + 0.5 ) * 100
end

--[[
	Decode location
]]
function GatherMate:DecodeLoc(id)
	return floor(id/1000000)/10000, floor(id % 1000000 / 100)/10000
end

function GatherMate:MapLocalize(map)
	return self.HBD:GetLocalizedMap(map)
end
