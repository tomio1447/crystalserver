local internalNpcName = "Loot Seller"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = "Loot Seller"

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 1575,
	lookHead = 96,
	lookBody = 101,
	lookLegs = 120,
	lookFeet = 120,
	lookAddons = 2,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

local function findLootPouch(container)
	if not container or not container:isContainer() then
		return nil
	end
	local items = container:getItems(true)
	for _, item in ipairs(items) do
		if item:getId() == 23721 then
			local pouch = item:getContainer()
			if pouch then
				return pouch
			end
		end
	end
	return nil
end

local function getPlayerLootPouch(player)
	-- Direct inventory slots
	for slot = CONST_SLOT_FIRST, CONST_SLOT_LAST do
		local slotItem = player:getSlotItem(slot)
		if slotItem then
			if slotItem:getId() == 23721 then
				local pouch = slotItem:getContainer()
				if pouch then
					return pouch
				end
			end
			local pouch = findLootPouch(slotItem)
			if pouch then
				return pouch
			end
		end
	end
	-- Special containers
	return findLootPouch(player:getStoreInbox()) or findLootPouch(player:getInbox())
end

local function getShopSellPrice(itemId)
	for _, entry in ipairs(LootShopConfig) do
		if entry.clientId == itemId and entry.sell and entry.sell > 0 then
			return entry.sell
		end
	end
	return 0
end

local function sellAllLootPouch(npc, player)
	local pouch = getPlayerLootPouch(player)
	if not pouch then
		npcHandler:say("You don't have a Loot Pouch.", npc, player)
		return
	end

	local toSell = {}
	local items = pouch:getItems(false)
	for _, item in ipairs(items) do
		if item:getId() == 23721 then
			goto continue
		end
		if item:getTier() > 0 then
			goto continue
		end
		if item:isContainer() then
			local c = item:getContainer()
			if c and c:getSize() > 0 then
				goto continue
			end
		end
		local price = getShopSellPrice(item:getId())
		if price > 0 then
			table.insert(toSell, { item = item, price = price })
		end
		::continue::
	end

	if #toSell == 0 then
		npcHandler:say("Your Loot Pouch has no sellable items.", npc, player)
		return
	end

	local total = 0
	for _, entry in ipairs(toSell) do
		local item = entry.item
		total = total + (entry.price * item:getCount())
		item:remove()
	end

	player:addMoney(total)
	player:sendTextMessage(MESSAGE_TRADE, string.format("Sold all loot in pouch for %d gold.", total))
	npcHandler:say(string.format("I bought everything from your Loot Pouch for %d gold.", total), npc, player)
end

npcType.onSay = function(npc, creature, type, message)
	local player = Player(creature)
	if player then
		local msg = message:lower()
		if msg == "sell all" or msg == "all" or msg == "pouch" then
			sellAllLootPouch(npc, player)
			return true
		end
	end
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcConfig.shop = LootShopConfig

local function creatureSayCallback(npc, player, type, message)
	if not npcHandler:checkInteraction(npc, player) then
		return false
	end

	if MsgContains(message, "trade") or MsgContains(message, "sell") or MsgContains(message, "buy") or MsgContains(message, "loot") then
		npc:openShopWindow(player)
	else
		npcHandler:say("Greetings |PLAYERNAME|. Say {trade} to open the shop, or {sell all} to sell everything in your Loot Pouch.", npc, player)
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_GREET, "Greetings |PLAYERNAME|. I buy all kinds of loot. Say {trade} to open the shop, or {sell all} to sell everything in your Loot Pouch.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Goodbye, come back anytime.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Goodbye.")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
