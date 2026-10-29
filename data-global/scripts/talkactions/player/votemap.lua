local config = {
	cities = {
		[1] = "carlin",
		[2] = "venore",
	},
}

local talkAction = TalkAction("!votemap")

function talkAction.onSay(player, words, param, type)
	local manager = _G.WarMapManager
	if not manager then
		player:sendCancelMessage("Map voting system is not ready.")
		return false
	end

	if not manager.isVoteOpen() then
		player:sendCancelMessage("Voting is not open right now.")
		return false
	end

	local choice = tonumber(param)
	if not choice or not config.cities[choice] then
		player:sendCancelMessage("Use: !votemap 1 (Carlin) or !votemap 2 (Venore).")
		return false
	end

	local cityKey = config.cities[choice]
	manager.vote(player:getGuid(), cityKey)

	local cityName = cityKey:sub(1, 1):upper() .. cityKey:sub(2)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You voted for %s as the next war map.", cityName))
	manager.broadcastVoteTally()
	return false
end

talkAction:separator(" ")
talkAction:groupType("normal")
talkAction:register()
