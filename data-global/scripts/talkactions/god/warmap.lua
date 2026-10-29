local talkAction = TalkAction("!warmap")

local function formatTime(seconds)
	local m = math.floor(seconds / 60)
	local s = seconds % 60
	return string.format("%02d:%02d", m, s)
end

function talkAction.onSay(player, words, param, type)
	if not player:getGroup():getAccess() then
		return false
	end

	local manager = _G.WarMapManager
	if not manager then
		player:sendCancelMessage("War map manager not loaded.")
		return false
	end

	local args = param:trim():lower()
	local mapKv = kv.scoped("warizi-map")

	if args == "" or args == "status" then
		local phase, phaseEnd = manager.getPhase()
		local remaining = math.max(0, phaseEnd - os.time())
		local cityKey = manager.getCurrentCity()
		local cityName = cityKey and (cityKey:sub(1, 1):upper() .. cityKey:sub(2)) or "None"
		local votes = manager.getVotes()
		local carlin = 0
		local venore = 0
		for _ in pairs(votes.carlin or {}) do carlin = carlin + 1 end
		for _ in pairs(votes.venore or {}) do venore = venore + 1 end

		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format(
			"Phase: %s | City: %s | Remaining: %s | Votes: Carlin %d / Venore %d",
			phase, cityName, formatTime(remaining), carlin, venore
		))
		return false
	end

	if args == "start carlin" or args == "start venore" then
		local cityKey = args == "start carlin" and "carlin" or "venore"
		if manager.forceStart(cityKey) then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Forced transition to " .. cityKey:sub(1, 1):upper() .. cityKey:sub(2) .. ".")
		else
			player:sendCancelMessage("Invalid war map.")
		end
		return false
	end

	if args == "end" then
		mapKv:set("phase", "active")
		mapKv:set("phase_end", os.time())
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Forced end of current map.")
		return false
	end

	if args == "cooldown" then
		mapKv:set("phase", "cooldown")
		mapKv:set("phase_end", os.time() + 10)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Forced 10s cooldown.")
		return false
	end

	if args == "reset" then
		mapKv:set("phase", "cooldown")
		mapKv:set("phase_end", os.time() + 30)
		mapKv:remove("current_city")
		mapKv:remove("next_city")
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Reset map rotation to 30s cooldown.")
		return false
	end

	player:sendCancelMessage("Usage: !warmap status / start carlin / start venore / end / cooldown / reset")
	return false
end

talkAction:separator(" ")
talkAction:groupType("god")
talkAction:register()
