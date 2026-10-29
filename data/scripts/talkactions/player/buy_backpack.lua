local backpack = TalkAction("!backpack", "!bp")

local itemConfig = {
	price = 1000,
	itemId = 2854,
	exhaustionKey = "buy_backpack",
	exhaustionTime = 30,
}

function backpack.onSay(player, words, param)
	if player:getExhaustion(itemConfig.exhaustionKey) > 0 then
		player:sendCancelMessage("You are exhausted. Please wait before using this command again.")
		return true
	end

	if player:removeMoneyBank(itemConfig.price) then
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		player:addItem(itemConfig.itemId, 1)
		player:sendTextMessage(MESSAGE_LOOK, string.format("You have bought a backpack for %d gold!", itemConfig.price))
		player:setExhaustion(itemConfig.exhaustionKey, itemConfig.exhaustionTime)
	else
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendCancelMessage("You do not have enough money.")
	end

	return true
end

backpack:setDescription("[Usage]: !backpack to buy a backpack for 1k")
backpack:groupType("normal")
backpack:register()
