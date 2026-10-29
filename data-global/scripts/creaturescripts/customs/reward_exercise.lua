local winReward = CreatureEvent("WinReward")

function winReward.onLogin(player)
	if configManager.getBoolean(configKeys.TOGGLE_RECEIVE_REWARD) and player:kv():get("exercise_reward_day") ~= tonumber(os.date("%Y%m%d")) then
		player:sendTextMessage(MESSAGE_LOGIN, "You can receive an exercise weapon using command !reward")
	end
	return true
end

if configManager.getBoolean(configKeys.TOGGLE_RECEIVE_REWARD) then
	winReward:register()
end
