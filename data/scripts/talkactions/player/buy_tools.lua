local items = {
	["!shovel"] = { itemId = 3457, name = "shovel" },
	["!machete"] = { itemId = 3308, name = "machete" },
	["!pick"] = { itemId = 3456, name = "pick" },
	["!rope"] = { itemId = 3003, name = "rope" },
}

local PRICE = 1000
local EXHAUSTION_TIME = 30

for words, config in pairs(items) do
	local talkAction = TalkAction(words)

	function talkAction.onSay(player, words, param)
		local exhaustKey = "buy_" .. config.name
		if player:getExhaustion(exhaustKey) > 0 then
			player:sendCancelMessage("You are exhausted. Please wait before using this command again.")
			return true
		end

		if player:removeMoneyBank(PRICE) then
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			player:addItem(config.itemId, 1)
			player:sendTextMessage(MESSAGE_LOOK, string.format("You have bought a %s for %d gold!", config.name, PRICE))
			player:setExhaustion(exhaustKey, EXHAUSTION_TIME)
		else
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			player:sendCancelMessage("You do not have enough money.")
		end

		return true
	end

	talkAction:setDescription(string.format("[Usage]: %s to buy a %s for %d gold", words, config.name, PRICE))
	talkAction:groupType("normal")
	talkAction:register()
end
