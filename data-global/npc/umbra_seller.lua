local internalNpcName = "Umbra Seller"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 0

npcConfig.outfit = {
	lookType = 584,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.currency = 20062

npcConfig.shop = {
	{ itemName = "umbral master bow", clientId = 20084, buy = 50 },
	{ itemName = "umbral master crossbow", clientId = 20087, buy = 50 },
	{ itemName = "umbral master spellbook", clientId = 20090, buy = 50 },
	{ itemName = "umbral masterblade", clientId = 20066, buy = 50 },
	{ itemName = "umbral master slayer", clientId = 20069, buy = 50 },
	{ itemName = "umbral master axe", clientId = 20072, buy = 50 },
	{ itemName = "umbral master chopper", clientId = 20075, buy = 50 },
	{ itemName = "umbral master hammer", clientId = 20081, buy = 50 },
	{ itemName = "umbral master mace", clientId = 20078, buy = 50 },
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

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcHandler:setMessage(MESSAGE_GREET, "Welcome, |PLAYERNAME|. I sell Umbral Master equipment for 50 clusters of solace each. Ask me for {trade}.")
npcHandler:setMessage(MESSAGE_SENDTRADE, "Choose your Umbral Master equipment. Each item costs 50 clusters of solace.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Farewell, |PLAYERNAME|.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Come back when you need Umbral equipment.")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end

npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i clusters of solace.", amount, name, totalCost))
end

npcType.onCheckItem = function(npc, player, clientId, subType) end

npcType:addDialogOptions("trade", "bye")

npcType:register(npcConfig)
