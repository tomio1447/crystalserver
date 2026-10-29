local food = TalkAction("!food")

local config = {
	price = 10000,
	itemId = 3725, --Brown Mushroom
	quantity = 100,
	exhaustionKey = "buy_food",
	exhaustionTime = 30,
}

function food.onSay(player, words, param)
	if player:getExhaustion(config.exhaustionKey) > 0 then
		player:sendCancelMessage("You are exhausted. Please wait before using this command again.")
		return true
	end

	if player:removeMoneyBank(config.price) then
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		player:addItem(config.itemId, config.quantity)
		player:sendTextMessage(MESSAGE_LOOK, string.format("You bought %d food for %d gold!", config.quantity, config.price))
		player:setExhaustion(config.exhaustionKey, config.exhaustionTime)
	else
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendCancelMessage(string.format("You need at least %d gold coins.", config.price))
	end
end

food:setDescription("[Usage]: !food to buy 100 brown mushrooms for 10k")
food:groupType("normal")
food:register()
