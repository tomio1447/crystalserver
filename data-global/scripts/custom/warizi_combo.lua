-- Warizi Combo Session (leader-name based)
-- Client -> server: extended opcode 120, payload "action;arg1;arg2"
--   "sub;LeaderName"        -> register player as follower of <LeaderName>
--   "unsub"                 -> remove player from any leader list
--   "fire;atk1|atk2|atk3;T" -> sender relays the attack to his followers (leader is keyed by own name)
-- Server -> client: channel message "#combo#..." on a channel id the client never opens (invisible in console)

local COMBO_OPCODE = 120
local COMBO_CHANNEL_ID = 555

local groups = {}      -- leaderKey(lower name) -> { leaderName, followers = { [guid] = player } }
local playerGroup = {} -- follower guid -> leaderKey

local function comboTell(player, text)
	player:sendChannelMessage("Combo", "#combo#" .. text, TALKTYPE_CHANNEL_Y, COMBO_CHANNEL_ID)
end

local function split(str, sep)
	sep = sep or ";"
	local out = {}
	for part in string.gmatch((str or "") .. sep, "([^" .. sep .. "]*)" .. sep) do
		out[#out + 1] = part
	end
	return out
end

local function followerNames(group)
	local names = {}
	for guid, member in pairs(group.followers) do
		local ok, name = pcall(function() return member:getName() end)
		if ok and name then
			names[#names + 1] = name
		end
	end
	table.sort(names)
	return names
end

local function broadcastMembers(leaderKey)
	local group = groups[leaderKey]
	if not group then
		return
	end
	local payload = "members;" .. table.concat(followerNames(group), ",")
	for guid, member in pairs(group.followers) do
		pcall(comboTell, member, payload)
	end
	-- also notify the leader himself if he is online, so his member list updates
	local leader = Player(group.leaderName)
	if leader then
		pcall(comboTell, leader, payload)
	end
end

local function leaveGroup(guid)
	local key = playerGroup[guid]
	if not key then
		return
	end
	playerGroup[guid] = nil
	local group = groups[key]
	if not group then
		return
	end
	group.followers[guid] = nil
	if next(group.followers) == nil then
		groups[key] = nil
		return
	end
	broadcastMembers(key)
end

local comboSession = CreatureEvent("WariziComboSession")

function comboSession.onExtendedOpcode(player, opcode, buffer)
	if opcode ~= COMBO_OPCODE then
		return
	end
	print("[WariziCombo] " .. player:getName() .. " -> " .. tostring(buffer))

	local guid = player:getId()
	local parts = split(buffer, ";")
	local action = parts[1]

	if action == "sub" then
		local leaderName = parts[2]
		if not leaderName or leaderName == "" or #leaderName > 24 then
			comboTell(player, "error;Invalid leader name")
			return
		end
		local key = leaderName:lower()
		if key == player:getName():lower() then
			comboTell(player, "error;You are the leader")
			return
		end
		leaveGroup(guid)
		local group = groups[key]
		if not group then
			group = { leaderName = leaderName, followers = {} }
			groups[key] = group
		end
		group.followers[guid] = player
		playerGroup[guid] = key
		comboTell(player, "subbed;" .. group.leaderName)
		broadcastMembers(key)

	elseif action == "unsub" then
		leaveGroup(guid)
		comboTell(player, "unsubbed")

	elseif action == "fire" then
		local combo = parts[2]
		if combo ~= "atk1" and combo ~= "atk2" and combo ~= "atk3" then
			return
		end
		-- the sender's own character name is the group key: relay to his followers
		local group = groups[player:getName():lower()]
		if not group then
			return
		end
		local target = parts[3] or ""
		for memberGuid, member in pairs(group.followers) do
			pcall(comboTell, member, "fire;" .. combo .. ";" .. target)
		end
	end
end

comboSession:type("extendedopcode")
comboSession:register()

local comboLogout = CreatureEvent("WariziComboLogout")

function comboLogout.onLogout(player)
	if player then
		leaveGroup(player:getId())
	end
	return true
end

comboLogout:type("logout")
comboLogout:register()
