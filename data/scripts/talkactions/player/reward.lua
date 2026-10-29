local config = {
	items = {
		{ id = 28557, charges = 3000 },
		{ id = 28552, charges = 3000 },
		{ id = 28554, charges = 3000 },
		{ id = 28556, charges = 3000 },
		{ id = 28555, charges = 3000 },
		{ id = 28553, charges = 3000 },
		{ id = 44065, charges = 3000 },
		{ id = 50293, charges = 3000 },
	},
	kvKey = "exercise_reward_day", -- player KV key, stores the last calendar day claimed
}

local function sendExerciseRewardModal(player)
	local window = ModalWindow({
		title = "Exercise Reward",
		message = "Choose one daily exercise weapon with 3000 charges.",
	})
	for _, it in pairs(config.items) do
		local iType = ItemType(it.id)
		if iType then
			window:addChoice(iType:getName(), function(player, button, choice)
				if button.name ~= "Select" then
					return true
				end
				local today = tonumber(os.date("%Y%m%d"))
				if player:kv():get(config.kvKey) == today then
					player:sendTextMessage(MESSAGE_LOOK, "You already claimed today's exercise weapon. Come back tomorrow.")
					return true
				end

				local inbox = player:getStoreInbox()
				local inboxItems = inbox:getItems()
				if inbox and #inboxItems < inbox:getMaxCapacity() then
					local item = inbox:addItem(it.id, it.charges)
					if item then
						item:setActionId(IMMOVABLE_ACTION_ID)
						item:setAttribute(ITEM_ATTRIBUTE_STORE, systemTime())
						item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, string.format("You won this exercise weapon as a reward to be a %s player. Use it in a dummy!\nHave a nice game..", configManager.getString(configKeys.SERVER_NAME)))
					else
						player:sendTextMessage(MESSAGE_LOOK, "You need to have capacity and empty slots to receive.")
						return
					end
					player:kv():set(config.kvKey, today)
					player:sendTextMessage(MESSAGE_LOOK, string.format("Congratulations, you received a %s with %i charges in your store inbox.", iType:getName(), it.charges))
				else
					player:sendTextMessage(MESSAGE_LOOK, "You need to have capacity and empty slots to receive.")
				end
			end)
		end
	end
	window:addButton("Select")
	window:addButton("Close")
	window:setDefaultEnterButton(0)
	window:setDefaultEscapeButton(1)
	window:sendToPlayer(player)
end

local exerciseRewardModal = TalkAction("!reward")
function exerciseRewardModal.onSay(player, words, param)
	if not configManager.getBoolean(configKeys.TOGGLE_RECEIVE_REWARD) then
		return true
	end
	if player:kv():get(config.kvKey) == tonumber(os.date("%Y%m%d")) then
		player:sendTextMessage(MESSAGE_LOOK, "You already claimed today's exercise weapon. Come back tomorrow.")
		return true
	end
	sendExerciseRewardModal(player)
	return true
end

exerciseRewardModal:separator(" ")
exerciseRewardModal:groupType("normal")
exerciseRewardModal:register()
