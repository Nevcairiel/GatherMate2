--[[
	GatherMate2 node sharing between guild members and friends.

	Built on Ace3:
	  AceComm-3.0       - guild / whisper transport (message splitting + ChatThrottleLib)
	  AceSerializer-3.0 - message encoding
	  AceTimer-3.0      - debouncing and delayed responses
	  AceEvent-3.0      - game events and GatherMate2 messages

	Flow
	----
	* LIVE:    When we gather a node it is broadcast (debounced, a few seconds) to the guild and to
	           all online friends. Every receiver answers with an ACK, and the ACK updates the
	           "last sync" timestamp we keep for that receiver's account. If the receiver was missing
	           older nodes (learned since its last sync) they are sent as a catch-up right away.
	* LOGIN:   After logging in we send a REQUEST to the guild and to every online friend.
	           Only then do the others respond with all nodes we learned since the last sync
	           they sent to our account. The receiver ACKs and the sender stores the new sync time.
	* COUNTER: Players who are already online do not notice when a friend logs in. Instead, the
	           login request is the signal: once per session and account we answer it with our own
	           request (marked as "counter", which is never answered with another request), so we
	           also get the nodes that friend gathered while we were offline.
	* FORCED:  A forced request asks everybody to ignore the stored sync time and send everything
	           that has a timestamp.

	Everything is sent over AceComm (GUILD + WHISPER). Battle.net friends are reached by
	whispering their current character, which only works if that character is on our realm or
	a realm connected to it. Battle.net friends on other realms are skipped.

	Only really farmed nodes are shared:
	* A node is "farmed" if it has a timestamp. Timestamps are only created when we gather a node
	  ourselves (Collector -> AddNode) or when a farmed node arrives via sync.
	* Imported data (GatherMate2_Data / CurseForge database etc.) never has a timestamp, and an
	  import that overwrites a farmed node removes its timestamp, so it is never sent.
	* Every shared node carries the account key of the player who farmed it (origin). Origins and
	  senders can be blocked, and all nodes from a blocked origin can be deleted.
	* Live messages may only contain a handful of nodes (nobody gathers hundreds of nodes within
	  a few seconds), bigger live messages are dropped completely.
	* Optionally only our own farmed nodes are shared (no relaying of nodes farmed by others).
	Note: this protects against the normal addon sending imported data. A deliberately modified
	client can still lie - for that case use the block list.

	"Last sync" is stored per account: every client generates a random account key (stored in the
	account wide SavedVariables) and sends it with every message, so all characters of one account
	share the same sync state.
]]

local GatherMate = LibStub("AceAddon-3.0"):GetAddon("GatherMate2")
local Sync = GatherMate:NewModule("Sync", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GatherMate2")

local PREFIX = "GM2Sync"      -- AceComm prefix (guild / whisper)
local PROTOCOL = 1

local LIVE_DEBOUNCE = 3       -- seconds to collect gathered nodes before broadcasting them
local LOGIN_DELAY = 10        -- seconds after login before requesting updates (friends/guild lists need to load)
local RESPONSE_DELAY_MIN = 1  -- random delay before answering a request, spreads the load in big guilds
local RESPONSE_DELAY_MAX = 6
local NODES_PER_MESSAGE = 150 -- nodes per NODES message (AceComm splits further for the wire)
local BATCH_TTL = 600         -- seconds we remember outgoing batches waiting for an ACK
local MAX_FUTURE_SKEW = 300   -- timestamps further in the future than this are clamped
local MAX_LIVE_NODES = 30     -- live messages with more nodes than this are not plausible and dropped

local GetServerTime = GetServerTime
local random = math.random
local pairs, ipairs, type, tonumber, tostring = pairs, ipairs, type, tonumber, tostring
local format, strsub, strmatch = string.format, string.sub, string.match

-- Short codes for the node databases to keep messages small
local typeToCode = {
	["Herb Gathering"] = "H",
	["Mining"]         = "M",
	["Fishing"]        = "F",
	["Treasure"]       = "T",
	["Extract Gas"]    = "G",
	["Archaeology"]    = "A",
	["Logging"]        = "L",
}
local codeToType = {}
for k, v in pairs(typeToCode) do codeToType[v] = k end
local function encodeType(nodeType) return typeToCode[nodeType] or nodeType end
local function decodeType(code) return codeToType[code] or code end

-- runtime state (not saved)
local profile, global
local myAccountKey, myName
local pendingLive = {}       -- [key] = { code, zone, coord, nodeID, collected }
local pendingLiveCount = 0
local liveTimer
local outBatches = {}        -- [batchId] = { ts, live, keys, acct, created }
local inBatches = {}         -- ["acct:batchId"] = { added, seen }
local scheduledResponses = {}-- [acct] = timer handle
local counterRequested = {}  -- [acct] = true, we already asked this account back in this session
local batchCounter = 0
local requestedThisSession = false

--[[ ---------------------------------------------------------------------------------------
	Helpers
------------------------------------------------------------------------------------------]]

local function now()
	return GetServerTime()
end

local function nodeKey(nodeType, zone, coord)
	return nodeType .. ":" .. zone .. ":" .. coord
end

local function newBatchId()
	batchCounter = batchCounter + 1
	return format("%x%x", now() % 0x100000, batchCounter)
end

local function generateAccountKey()
	local t = {}
	for i = 1, 4 do
		t[i] = format("%04x", random(0, 0xffff))
	end
	return table.concat(t) .. format("%x", time())
end

local function getPeer(acct)
	local peer = global.peers[acct]
	if not peer then
		peer = { lastSent = 0, lastReceived = 0, lastSeen = 0 }
		global.peers[acct] = peer
	end
	return peer
end

function Sync:Print(...)
	GatherMate:Print(...)
end

function Sync:IsTypeShared(nodeType)
	return profile.databases[nodeType] and true or false
end

--[[ ---------------------------------------------------------------------------------------
	Lifecycle
------------------------------------------------------------------------------------------]]

function Sync:OnInitialize()
	profile = GatherMate.db.profile.sync
	global = GatherMate.db.global.sync
	if not global.accountKey then
		global.accountKey = generateAccountKey()
	end
	myAccountKey = global.accountKey
end

function Sync:OnEnable()
	myName = UnitName("player") .. "-" .. (GetNormalizedRealmName() or "")

	self:RegisterComm(PREFIX, "OnCommReceived")

	self:RegisterMessage("GatherMate2NodeAdded", "OnNodeAdded")
	self:RegisterMessage("GatherMate2ConfigChanged", "OnConfigChanged")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")

	self:ScheduleRepeatingTimer("ExpireBatches", 60)
end

function Sync:OnConfigChanged()
	profile = GatherMate.db.profile.sync
	if not profile.enableSend then
		self:ClearOutgoing()
	end
end

function Sync:PLAYER_ENTERING_WORLD(event, isInitialLogin, isReloadingUi)
	if (isInitialLogin or isReloadingUi) and not requestedThisSession then
		requestedThisSession = true
		-- make sure guild roster and friend lists are populated before we ask
		if IsInGuild() then C_GuildInfo.GuildRoster() end
		C_FriendList.ShowFriends()
		self:ScheduleTimer("RequestUpdates", LOGIN_DELAY, false)
	end
end

function Sync:PLAYER_REGEN_ENABLED()
	-- live broadcasts are held back during combat
	if pendingLiveCount > 0 and not liveTimer then
		liveTimer = self:ScheduleTimer("FlushLive", 1)
	end
end

function Sync:ClearOutgoing()
	wipe(pendingLive)
	pendingLiveCount = 0
	if liveTimer then self:CancelTimer(liveTimer); liveTimer = nil end
	for acct, handle in pairs(scheduledResponses) do
		self:CancelTimer(handle)
		scheduledResponses[acct] = nil
	end
end

function Sync:ExpireBatches()
	local t = now()
	for id, batch in pairs(outBatches) do
		if t - batch.created > BATCH_TTL then outBatches[id] = nil end
	end
	for id, batch in pairs(inBatches) do
		if t - batch.seen > BATCH_TTL then inBatches[id] = nil end
	end
end

--[[ ---------------------------------------------------------------------------------------
	Recipients
------------------------------------------------------------------------------------------]]

-- Online character friends (not Battle.net)
local function forEachOnlineFriend(callback)
	for i = 1, C_FriendList.GetNumFriends() do
		local info = C_FriendList.GetFriendInfoByIndex(i)
		if info and info.connected and info.name then
			callback(info.name)
		end
	end
end

local function isCharacterFriend(name)
	local short = Ambiguate(name, "none")
	return C_FriendList.GetFriendInfo(name) ~= nil or C_FriendList.GetFriendInfo(short) ~= nil
end

-- Normalized names of our realm and all realms connected to it
local function normalizeRealm(realm)
	return realm and (realm:gsub("[%s%-]", "")) or nil
end

local function getConnectedRealms()
	local realms = {}
	local own = GetNormalizedRealmName()
	if own then realms[own] = true end
	local connected = GetAutoCompleteRealms and GetAutoCompleteRealms()
	if connected then
		for _, realm in ipairs(connected) do
			realms[normalizeRealm(realm)] = true
		end
	end
	return realms
end

--[[
	Online Battle.net friends whose current WoW character is on our realm or a connected realm,
	so they can be reached with a normal addon whisper.
	callback("Name-Realm")
]]
local function forEachWhisperableBNetFriend(callback)
	local realms = getConnectedRealms()
	for i = 1, BNGetNumFriends() do
		for j = 1, C_BattleNet.GetFriendNumGameAccounts(i) do
			local info = C_BattleNet.GetFriendGameAccountInfo(i, j)
			if info and info.isOnline and info.clientProgram == BNET_CLIENT_WOW
				and (not info.wowProjectID or info.wowProjectID == WOW_PROJECT_ID)
				and info.characterName and info.characterName ~= "" then
				local realm = normalizeRealm(info.realmName)
				if realm and realms[realm] then
					callback(info.characterName .. "-" .. realm)
				end
			end
		end
	end
end

local function isBNetFriendCharacter(name)
	local found = false
	local full = strmatch(name, "%-") and name or (name .. "-" .. (GetNormalizedRealmName() or ""))
	forEachWhisperableBNetFriend(function(charName)
		if charName == full then found = true end
	end)
	return found
end

local function isGuildMember(name)
	if not IsInGuild() then return false end
	if C_GuildInfo.MemberExistsByName then
		return C_GuildInfo.MemberExistsByName(name) or C_GuildInfo.MemberExistsByName(Ambiguate(name, "none"))
	end
	return false
end

--[[
	Is a sender we got a WHISPER from allowed to talk to us?
	Only guild members and friends are accepted, with respect to the options.
]]
function Sync:IsTrustedWhisper(sender)
	if profile.guild and isGuildMember(sender) then return true end
	if profile.friends and isCharacterFriend(sender) then return true end
	if profile.bnetFriends and isBNetFriendCharacter(sender) then return true end
	return false
end

--[[ ---------------------------------------------------------------------------------------
	Transport
------------------------------------------------------------------------------------------]]

-- target = { kind = "GUILD" } | { kind = "WHISPER", name = "Name-Realm" }
function Sync:SendTo(target, msg, prio)
	msg.v = PROTOCOL
	msg.a = myAccountKey
	msg.c = myName
	local payload = self:Serialize(msg)
	if target.kind == "GUILD" then
		self:SendCommMessage(PREFIX, payload, "GUILD", nil, prio)
	elseif target.kind == "WHISPER" then
		self:SendCommMessage(PREFIX, payload, "WHISPER", target.name, prio)
	end
end

-- Send to the guild and every online friend (each character only once)
function Sync:Broadcast(msg, prio)
	local sentGuild = false
	if profile.guild and IsInGuild() then
		self:SendTo({ kind = "GUILD" }, msg, prio)
		sentGuild = true
	end

	local done = {}
	local function whisper(name)
		if done[name] then return end
		done[name] = true
		-- guild members already got the guild message
		if sentGuild and isGuildMember(name) then return end
		self:SendTo({ kind = "WHISPER", name = name }, msg, prio)
	end

	if profile.friends then
		forEachOnlineFriend(function(name)
			if not strmatch(name, "%-") then name = name .. "-" .. (GetNormalizedRealmName() or "") end
			whisper(name)
		end)
	end
	if profile.bnetFriends then
		forEachWhisperableBNetFriend(whisper)
	end
end

function Sync:OnCommReceived(prefix, payload, distribution, sender)
	if prefix ~= PREFIX then return end
	if distribution == "GUILD" then
		if not profile.guild then return end
		self:HandlePayload(payload, { kind = "WHISPER", name = sender }, true)
	elseif distribution == "WHISPER" then
		if not self:IsTrustedWhisper(sender) then return end
		self:HandlePayload(payload, { kind = "WHISPER", name = sender })
	end
end

function Sync:HandlePayload(payload, replyTarget, viaGuild)
	local ok, msg = self:Deserialize(payload)
	if not ok or type(msg) ~= "table" then return end
	if type(msg.v) ~= "number" or msg.v < PROTOCOL then return end
	if type(msg.a) ~= "string" or msg.a == myAccountKey then return end -- ignore ourselves / other clients of this account

	local peer = getPeer(msg.a)
	peer.lastSeen = now()
	if type(msg.c) == "string" then peer.name = msg.c end

	if msg.k == "REQ" then
		self:OnRequest(msg, replyTarget)
	elseif msg.k == "NODES" then
		self:OnNodes(msg, replyTarget)
	elseif msg.k == "ACK" then
		self:OnAck(msg)
	end
end

--[[ ---------------------------------------------------------------------------------------
	Requests (login / forced)
------------------------------------------------------------------------------------------]]

-- Ask guild and friends for everything we are missing
function Sync:RequestUpdates(force)
	if not profile.enableReceive then
		if force then self:Print(L["Receiving is disabled, no update requested."]) end
		return
	end
	self:Broadcast({ k = "REQ", full = force and true or nil }, "ALERT")
	if force or profile.notify then
		self:Print(force and L["Forced update request sent to guild and friends."] or L["Update request sent to guild and friends."])
	end
end

function Sync:ForceUpdate()
	self:RequestUpdates(true)
end

function Sync:OnRequest(msg, replyTarget)
	local acct = msg.a

	-- the other player just came online: ask back once per session, so we also get its nodes.
	-- Counter requests are never answered with another request (no ping-pong).
	if profile.enableReceive and not msg.counter and not counterRequested[acct] then
		counterRequested[acct] = true
		self:SendTo(replyTarget, { k = "REQ", counter = true }, "ALERT")
	end

	if not profile.enableSend then return end
	-- the same request can arrive via guild and friend list, only answer once
	if scheduledResponses[acct] then return end
	local delay = RESPONSE_DELAY_MIN + random() * (RESPONSE_DELAY_MAX - RESPONSE_DELAY_MIN)
	scheduledResponses[acct] = self:ScheduleTimer(function()
		scheduledResponses[acct] = nil
		self:SendDelta(acct, replyTarget, msg.full and 0 or nil)
	end, delay)
end

--[[
	All farmed nodes we may share which were learned at or after 'since'.
	Entry format: { typeCode, zone, coord, nodeID, collected, originAccountKey }
]]
function Sync:CollectNodes(since, exclude, firstOnly)
	local list = {}
	local blocked = global.blocked
	for _, nodeType in ipairs(GatherMate.db_types) do
		if self:IsTypeShared(nodeType) then
			local code = encodeType(nodeType)
			GatherMate:ForEachNodeLearnedSince(nodeType, since, function(zone, coord, nodeID, collected, learned, source)
				if exclude and exclude[nodeKey(nodeType, zone, coord)] then return end
				if source ~= "self" and (not profile.relayOthers or blocked[source]) then return end
				if firstOnly and #list > 0 then return end
				list[#list + 1] = { code, zone, coord, nodeID, collected, source == "self" and myAccountKey or source }
			end)
		end
	end
	return list
end

--[[
	Send all shared nodes learned since the last sync to an account.
	since = nil -> use the stored last sync time of that account
	exclude = optional set of node keys which the receiver already has
]]
function Sync:SendDelta(acct, target, since, exclude)
	if not profile.enableSend then return end
	local peer = getPeer(acct)
	since = since or peer.lastSent or 0
	local snapshot = now()

	local list = self:CollectNodes(since, exclude)

	if #list == 0 then
		-- nothing new, but the receiver is up to date now
		peer.lastSent = math.max(peer.lastSent or 0, snapshot)
		return
	end

	local batchId = newBatchId()
	outBatches[batchId] = { ts = snapshot, live = false, acct = acct, created = snapshot }
	self:SendNodeList(target, batchId, list, false, "BULK")
end

function Sync:SendNodeList(target, batchId, list, live, prio)
	local total = #list
	local parts = math.max(1, math.ceil(total / NODES_PER_MESSAGE))
	for part = 1, parts do
		local chunk = {}
		for i = (part - 1) * NODES_PER_MESSAGE + 1, math.min(part * NODES_PER_MESSAGE, total) do
			chunk[#chunk + 1] = list[i]
		end
		local msg = { k = "NODES", id = batchId, n = chunk, last = (part == parts) or nil, live = live or nil }
		if target then
			self:SendTo(target, msg, prio)
		else
			self:Broadcast(msg, prio)
		end
	end
end

--[[ ---------------------------------------------------------------------------------------
	Live sharing of freshly gathered nodes
------------------------------------------------------------------------------------------]]

function Sync:OnNodeAdded(event, zone, nodeType, coord, name, shared)
	-- nodes we received from others are not broadcast again
	if shared then return end
	if not profile.enableSend or not self:IsTypeShared(nodeType) then return end
	local nodedb = GatherMate.gmdbs[nodeType]
	local nodeID = nodedb and nodedb[zone] and nodedb[zone][coord]
	if not nodeID then return end
	local collected = GatherMate:GetNodeTimestamp(zone, nodeType, coord) or now()

	local key = nodeKey(nodeType, zone, coord)
	if not pendingLive[key] then pendingLiveCount = pendingLiveCount + 1 end
	pendingLive[key] = { encodeType(nodeType), zone, coord, nodeID, collected, myAccountKey }

	if not liveTimer then
		liveTimer = self:ScheduleTimer("FlushLive", LIVE_DEBOUNCE)
	end
end

function Sync:FlushLive()
	liveTimer = nil
	if pendingLiveCount == 0 or not profile.enableSend then return end
	-- addon messages can be restricted in combat, wait until it ends (PLAYER_REGEN_ENABLED)
	if InCombatLockdown() then return end

	local list, keys = {}, {}
	for key, entry in pairs(pendingLive) do
		list[#list + 1] = entry
		keys[key] = true
	end
	wipe(pendingLive)
	pendingLiveCount = 0

	local batchId = newBatchId()
	local ts = now()
	outBatches[batchId] = { ts = ts, live = true, keys = keys, created = ts }
	self:SendNodeList(nil, batchId, list, true, "NORMAL")
end

--[[ ---------------------------------------------------------------------------------------
	Receiving nodes
------------------------------------------------------------------------------------------]]

local function validEntry(e)
	return type(e) == "table" and type(e[1]) == "string" and type(e[2]) == "number"
		and type(e[3]) == "number" and type(e[4]) == "number" and type(e[5]) == "number"
		and e[3] > 0 and e[3] < 10000000000
end

--[[
	Merge one received node. Validates it and hands it to GatherMate:AddNodeChecked,
	which does the duplicate and rare spawn handling.
	Returns true if a new node was added (replacing an imported node does not count).
]]
function Sync:MergeNode(nodeType, zone, coord, nodeID, collected, learned, source)
	if not GatherMate.gmdbs[nodeType] or not self:IsTypeShared(nodeType) then return false end
	if GatherMate.db.profile.dbLocks[nodeType] then return false end
	if (nodeType == "Mining" or nodeType == "Herb Gathering") and GatherMate.mapBlacklist[zone] then return false end
	nodeID = GatherMate.nodeIDReplacementMap[nodeID] or nodeID
	local name = GatherMate:GetNameForNode(nodeType, nodeID)
	if not name then return false end -- unknown node (version mismatch)
	local yw, yh = GatherMate.HBD:GetZoneSize(zone)
	if not yw or yw == 0 or yh == 0 then return false end

	local x, y = GatherMate:DecodeLoc(coord)
	local added, replacedSame = GatherMate:AddNodeChecked(zone, x, y, nodeType, name,
		{ collected = collected, learned = learned, source = source })
	return added and not replacedSame
end

function Sync:OnNodes(msg, replyTarget)
	if not profile.enableReceive then return end
	if type(msg.id) ~= "string" or type(msg.n) ~= "table" then return end
	local blocked = global.blocked
	if blocked[msg.a] then return end
	-- nobody gathers that many nodes within a few seconds: not a real live update
	if msg.live and #msg.n > MAX_LIVE_NODES then return end

	-- the same batch can reach us via guild and friend list
	local batchKey = msg.a .. ":" .. msg.id
	local state = inBatches[batchKey]
	if not state then
		state = { added = 0, seen = now(), parts = 0 }
		inBatches[batchKey] = state
	elseif state.done then
		return
	end
	state.parts = state.parts + 1

	local t = now()
	for _, e in ipairs(msg.n) do
		if validEntry(e) then
			-- origin = account that farmed the node (defaults to the sender)
			local origin = type(e[6]) == "string" and e[6] or msg.a
			-- live messages may only contain nodes the sender farmed itself
			if not blocked[origin] and not (msg.live and origin ~= msg.a) then
				local collected = e[5]
				if collected > t + MAX_FUTURE_SKEW then collected = t end
				local source = (origin == myAccountKey) and "self" or origin
				if self:MergeNode(decodeType(e[1]), e[2], e[3], e[4], collected, t, source) then
					state.added = state.added + 1
				end
			end
		end
	end

	if msg.last then
		state.done = true
		local peer = getPeer(msg.a)
		peer.lastReceived = t
		-- confirm, so the sender can store the last sync time for our account
		self:SendTo(replyTarget, { k = "ACK", id = msg.id }, "ALERT")
		if state.added > 0 then
			GatherMate:SendMessage("GatherMate2DataImport")
			if profile.notify then
				self:Print(format(L["Received %d new node(s) from %s."], state.added, Ambiguate(peer.name or "?", "short")))
			end
		end
	end
end

--[[ ---------------------------------------------------------------------------------------
	ACKs: store the last sync time per account
------------------------------------------------------------------------------------------]]

function Sync:OnAck(msg)
	if type(msg.id) ~= "string" then return end
	local batch = outBatches[msg.id]
	if not batch then return end
	local acct = msg.a
	local peer = getPeer(acct)

	if not batch.live then
		if batch.acct == acct then
			peer.lastSent = math.max(peer.lastSent or 0, batch.ts)
			outBatches[msg.id] = nil
		end
		return
	end

	-- Live batch: the receiver is online and got our newest nodes. If it is also missing
	-- nodes learned since its last sync (received from others, gathered while it was
	-- offline, ...) send those as catch-up, its ACK then updates the sync time.
	if not profile.enableSend then return end
	batch.acked = batch.acked or {}
	if batch.acked[acct] then return end
	batch.acked[acct] = true

	local since = peer.lastSent or 0
	local missing = #self:CollectNodes(since, batch.keys, true) > 0

	if missing then
		local target = self:TargetForPeer(acct)
		if target then
			self:SendDelta(acct, target, since, batch.keys)
			return
		end
	else
		peer.lastSent = math.max(since, batch.ts)
	end
end

-- Direct route back to an account we just heard from
function Sync:TargetForPeer(acct)
	local peer = global.peers[acct]
	if not peer or not peer.name then return nil end
	return { kind = "WHISPER", name = peer.name }
end

--[[ ---------------------------------------------------------------------------------------
	Info / maintenance (used by the options)
------------------------------------------------------------------------------------------]]

--[[
	Block list. Blocked accounts are ignored as sender and as origin of nodes.
]]
function Sync:SetBlocked(acct, blocked)
	global.blocked[acct] = blocked and true or nil
end

function Sync:IsBlocked(acct)
	return global.blocked[acct] and true or false
end

-- Delete every node that was farmed by one of the given accounts ([acct] = true)
function Sync:DeleteNodesFrom(accounts)
	local removed = 0
	for _, nodeType in ipairs(GatherMate.db_types) do
		local doomed = {}
		GatherMate:ForEachNodeLearnedSince(nodeType, 0, function(zone, coord, nodeID, collected, learned, source)
			if accounts[source] then doomed[#doomed + 1] = { zone, coord } end
		end)
		for _, d in ipairs(doomed) do
			GatherMate:RemoveNodeByID(d[1], nodeType, d[2])
			removed = removed + 1
		end
	end
	if removed > 0 then
		GatherMate:SendMessage("GatherMate2Cleanup")
	end
	self:Print(format(L["Deleted %d node(s) from blocked players."], removed))
	return removed
end

function Sync:DeleteNodesFromBlocked()
	return self:DeleteNodesFrom(global.blocked)
end

-- [acct] = display name, for the options
function Sync:GetKnownPeers()
	local t = {}
	for acct, peer in pairs(global.peers) do
		t[acct] = Ambiguate(peer.name or acct, "short")
	end
	for acct in pairs(global.blocked) do
		t[acct] = t[acct] or acct
	end
	return t
end

function Sync:ResetSyncHistory()
	wipe(global.peers)
	self:Print(L["Sync history has been reset. The next request will send all shared nodes again."])
end

function Sync:GetStatusText()
	local lines = {}
	local list = {}
	for acct, peer in pairs(global.peers) do
		list[#list + 1] = peer
	end
	table.sort(list, function(a, b) return (a.lastSeen or 0) > (b.lastSeen or 0) end)
	if #list == 0 then
		return L["No sync partners yet."]
	end
	local function fmt(t)
		if not t or t == 0 then return L["never"] end
		return date("%Y-%m-%d %H:%M", t)
	end
	for i = 1, math.min(#list, 25) do
		local p = list[i]
		lines[#lines + 1] = format(L["%s - last sent: %s, last received: %s"], Ambiguate(p.name or "?", "short"), fmt(p.lastSent), fmt(p.lastReceived))
	end
	if #list > 25 then
		lines[#lines + 1] = format(L["... and %d more"], #list - 25)
	end
	return table.concat(lines, "\n")
end
