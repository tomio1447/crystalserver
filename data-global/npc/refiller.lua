local internalNpcName = "Refiller"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 0

npcConfig.outfit = {
	lookType = 128,
	lookHead = 0,
	lookBody = 58,
	lookLegs = 95,
	lookFeet = 114,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}

local itemsTable = {
	["distance"] = {
		{ itemName = "alicorn quiver", clientId = 39150, buy = 100000 },
		{ itemName = "arrow", clientId = 3447, buy = 3 },
		{ itemName = "assassin star", clientId = 7368, buy = 100, sell = 50 },
		{ itemName = "blue quiver", clientId = 35848, buy = 400 },
		{ itemName = "bolt", clientId = 3446, buy = 4 },
		{ itemName = "bow", clientId = 3350, buy = 400, sell = 100 },
		{ itemName = "burst arrow", clientId = 3449, buy = 15 },
		{ itemName = "cobra crossbow", clientId = 30393, buy = 100000 },
		{ itemName = "crossbow", clientId = 3349, buy = 500, sell = 120 },
		{ itemName = "crystalline arrow", clientId = 15793, buy = 20 },
		{ itemName = "diamond arrow", clientId = 35901, buy = 130 },
		{ itemName = "drill bolt", clientId = 16142, buy = 12 },
		{ itemName = "earth arrow", clientId = 774, buy = 5 },
		{ itemName = "envenomed arrow", clientId = 16143, buy = 12 },
		{ itemName = "falcon bow", clientId = 28718, buy = 100000 },
		{ itemName = "flaming arrow", clientId = 763, buy = 5 },
		{ itemName = "flash arrow", clientId = 761, buy = 5 },
		{ itemName = "grand sanguine bow", clientId = 43878, buy = 100000 },
		{ itemName = "grand sanguine crossbow", clientId = 43880, buy = 100000 },
		{ itemName = "infernal bolt", clientId = 6528, buy = 13 },
		{ itemName = "lion longbow", clientId = 34150, buy = 100000 },
		{ itemName = "onyx arrow", clientId = 7365, buy = 7 },
		{ itemName = "piercing bolt", clientId = 7363, buy = 5 },
		{ itemName = "power bolt", clientId = 3450, buy = 7 },
		{ itemName = "prismatic bolt", clientId = 16141, buy = 20 },
		{ itemName = "quiver", clientId = 35562, buy = 400, sell = 100 },
		{ itemName = "red quiver", clientId = 35849, buy = 400 },
		{ itemName = "royal spear", clientId = 7378, buy = 15 },
		{ itemName = "sanguine bow", clientId = 43877, buy = 100000 },
		{ itemName = "sanguine crossbow", clientId = 43879, buy = 100000 },
		{ itemName = "shiver arrow", clientId = 762, buy = 5 },
		{ itemName = "simple arrow", clientId = 21470, buy = 2 },
		{ itemName = "small stone", clientId = 1781, buy = 100 },
		{ itemName = "sniper arrow", clientId = 7364, buy = 5 },
		{ itemName = "soulbleeder", clientId = 34088, buy = 100000 },
		{ itemName = "soulpiercer", clientId = 34089, buy = 100000 },
		{ itemName = "spear", clientId = 3277, buy = 9, sell = 3 },
		{ itemName = "spectral bolt", clientId = 35902, buy = 70 },
		{ itemName = "tarsal arrow", clientId = 14251, buy = 6 },
		{ itemName = "throwing knife", clientId = 3298, buy = 25, sell = 2 },
		{ itemName = "throwing star", clientId = 3287, buy = 42, sell = 2 },
		{ itemName = "vortex bolt", clientId = 14252, buy = 6 },
	},
	["runes"] = {
		{ itemName = "animate dead rune", clientId = 3203, buy = 375 },
		{ itemName = "avalanche rune", clientId = 3161, buy = 64 },
		{ itemName = "blank rune", clientId = 3147, buy = 10 },
		{ itemName = "chameleon rune", clientId = 3178, buy = 210 },
		{ itemName = "convince creature rune", clientId = 3177, buy = 80 },
		{ itemName = "cure poison rune", clientId = 3153, buy = 65 },
		{ itemName = "desintegrate rune", clientId = 3197, buy = 26 },
		{ itemName = "destroy field rune", clientId = 3148, buy = 15 },
		{ itemName = "energy bomb rune", clientId = 3149, buy = 203 },
		{ itemName = "energy field rune", clientId = 3164, buy = 38 },
		{ itemName = "energy wall rune", clientId = 3166, buy = 85 },
		{ itemName = "explosion rune", clientId = 3200, buy = 31 },
		{ itemName = "fire bomb rune", clientId = 3192, buy = 147 },
		{ itemName = "fire field rune", clientId = 3188, buy = 28 },
		{ itemName = "fire wall rune", clientId = 3190, buy = 61 },
		{ itemName = "fireball rune", clientId = 3189, buy = 30 },
		{ itemName = "great fireball rune", clientId = 3191, buy = 64 },
		{ itemName = "heavy magic missile rune", clientId = 3198, buy = 12 },
		{ itemName = "holy missile rune", clientId = 3182, buy = 16 },
		{ itemName = "icicle rune", clientId = 3158, buy = 30 },
		{ itemName = "intense healing rune", clientId = 3152, buy = 95 },
		{ itemName = "light magic missile rune", clientId = 3174, buy = 4 },
		{ itemName = "light stone shower rune", clientId = 21351, buy = 25 },
		{ itemName = "lightest missile rune", clientId = 21352, buy = 20 },
		{ itemName = "magic wall rune", clientId = 3180, buy = 116 },
		{ itemName = "paralyze rune", clientId = 3165, buy = 700 },
		{ itemName = "poison bomb rune", clientId = 3173, buy = 85 },
		{ itemName = "poison field rune", clientId = 3172, buy = 21 },
		{ itemName = "poison wall rune", clientId = 3176, buy = 52 },
		{ itemName = "soulfire rune", clientId = 3195, buy = 46 },
		{ itemName = "stalagmite rune", clientId = 3179, buy = 12 },
		{ itemName = "stone shower rune", clientId = 3175, buy = 41 },
		{ itemName = "sudden death rune", clientId = 3155, buy = 162 },
		{ itemName = "thunderstorm rune", clientId = 3202, buy = 52 },
		{ itemName = "ultimate healing rune", clientId = 3160, buy = 175 },
		{ itemName = "wild growth rune", clientId = 3156, buy = 160 },
	},
	["potions"] = {
		{ itemName = "great mana potion", clientId = 238, buy = 158 },
		{ itemName = "great health potion", clientId = 239, buy = 225 },
		{ itemName = "great spirit potion", clientId = 7642, buy = 254 },
		{ itemName = "health potion", clientId = 266, buy = 50 },
		{ itemName = "mana potion", clientId = 268, buy = 56 },
		{ itemName = "small health potion", clientId = 7876, buy = 20 },
		{ itemName = "strong health potion", clientId = 236, buy = 115 },
		{ itemName = "strong mana potion", clientId = 237, buy = 108 },
		{ itemName = "superior mana potion", clientId = 53162, buy = 254 },
		{ itemName = "distilled superior mana potion", clientId = 53163, buy = 381 },
		{ itemName = "distilled ultimate mana potion", clientId = 53164, buy = 732 },
		{ itemName = "supreme health potion", clientId = 23375, buy = 650 },
		{ itemName = "ultimate health potion", clientId = 7643, buy = 379 },
		{ itemName = "ultimate mana potion", clientId = 23373, buy = 488 },
		{ itemName = "ultimate spirit potion", clientId = 23374, buy = 488 },
		{ itemName = "vial of oil", clientId = 2874, buy = 20, sell = 5, count = 7 },
	},
	["foods"] = {
		{ itemName = "aubergine", clientId = 11460, buy = 8 },
		{ itemName = "banana", clientId = 3587, buy = 3 },
		{ itemName = "beetroot", clientId = 8017, buy = 2 },
		{ itemName = "blueberry", clientId = 3588, buy = 1, sell = 1 },
		{ itemName = "bread", clientId = 3600, buy = 8, sell = 1, count = 1 },
		{ itemName = "broccoli", clientId = 11461, buy = 3 },
		{ itemName = "brown bread", clientId = 3602, buy = 3 },
		{ itemName = "brown mushroom", clientId = 3725, buy = 10 },
		{ itemName = "cake", clientId = 6277, buy = 50 },
		{ itemName = "carrot", clientId = 3595, buy = 3, sell = 1, count = 1 },
		{ itemName = "cauliflower", clientId = 11462, buy = 4 },
		{ itemName = "cheese", clientId = 3607, buy = 6, sell = 2, count = 1 },
		{ itemName = "cherry", clientId = 3590, buy = 1, sell = 1, count = 1 },
		{ itemName = "coconut", clientId = 3589, buy = 8 },
		{ itemName = "cookie", clientId = 3598, buy = 2, sell = 1 },
		{ itemName = "corncob", clientId = 3597, buy = 3 },
		{ itemName = "cucumber", clientId = 8014, buy = 5 },
		{ itemName = "dragon ham", clientId = 3583, buy = 25 },
		{ itemName = "dragonfruit", clientId = 11682, buy = 5 },
		{ itemName = "egg", clientId = 3606, buy = 2, sell = 1, count = 1 },
		{ itemName = "fish", clientId = 3578, buy = 6, sell = 2 },
		{ itemName = "flour", clientId = 3603, buy = 30 },
		{ itemName = "glooth sandwich", clientId = 21143, buy = 7 },
		{ itemName = "glooth steak", clientId = 21146, buy = 10 },
		{ itemName = "grapes", clientId = 3592, buy = 3 },
		{ itemName = "ham", clientId = 3582, buy = 6, sell = 4, count = 1 },
		{ itemName = "jalapeno pepper", clientId = 8016, buy = 2 },
		{ itemName = "lemon", clientId = 8013, buy = 3 },
		{ itemName = "mango", clientId = 5096, buy = 8 },
		{ itemName = "meat", clientId = 3577, buy = 4, sell = 2, count = 1 },
		{ itemName = "melon", clientId = 3593, buy = 8 },
		{ itemName = "mushroom pie", clientId = 16103, buy = 150 },
		{ itemName = "onion", clientId = 8015, buy = 2 },
		{ itemName = "orange", clientId = 3586, buy = 6 },
		{ itemName = "pear", clientId = 3584, buy = 5 },
		{ itemName = "peas", clientId = 11683, buy = 2 },
		{ itemName = "pineapple", clientId = 11459, buy = 14 },
		{ itemName = "plum", clientId = 8011, buy = 3 },
		{ itemName = "potato", clientId = 8010, buy = 5 },
		{ itemName = "pumpkin", clientId = 3594, buy = 10 },
		{ itemName = "raspberry", clientId = 8012, buy = 1 },
		{ itemName = "red apple", clientId = 3585, buy = 3 },
		{ itemName = "red mushroom", clientId = 3724, buy = 12 },
		{ itemName = "roll", clientId = 3601, buy = 2, sell = 1 },
		{ itemName = "salmon", clientId = 3579, buy = 4, sell = 2, count = 1 },
		{ itemName = "salt", clientId = 33930, buy = 5 },
		{ itemName = "strawberry", clientId = 3591, buy = 1 },
		{ itemName = "tomato", clientId = 3596, buy = 4 },
		{ itemName = "white mushroom", clientId = 3723, buy = 6, sell = 2 },
	},
	["tools"] = {
		{ itemName = "basket", clientId = 2855, buy = 6 },
		{ itemName = "bottle", clientId = 2875, buy = 3, count = 9 },
		{ itemName = "broom", clientId = 3211, buy = 12 },
		{ itemName = "bucket", clientId = 2873, buy = 4 },
		{ itemName = "candelabrum", clientId = 2911, buy = 8 },
		{ itemName = "candlestick", clientId = 2917, buy = 2 },
		{ itemName = "closed trap", clientId = 3481, buy = 280, sell = 75 },
		{ itemName = "crowbar", clientId = 3304, buy = 260, sell = 50 },
		{ itemName = "fire bug", clientId = 5467, buy = 100 },
		{ itemName = "fishing rod", clientId = 3483, buy = 40, sell = 40, count = 1 },
		{ itemName = "hammer", clientId = 3460, buy = 80 },
		{ itemName = "hand auger", clientId = 31334, buy = 25 },
		{ itemName = "hoe", clientId = 3455, buy = 15 },
		{ itemName = "inkwell", clientId = 3509, buy = 10, sell = 8 },
		{ itemName = "lock pick", clientId = 7889, buy = 50 },
		{ itemName = "machete", clientId = 3308, buy = 6, sell = 6, count = 1 },
		{ itemName = "pick", clientId = 3456, buy = 50, sell = 15, count = 1 },
		{ itemName = "pitchfork", clientId = 3451, buy = 25 },
		{ itemName = "rake", clientId = 3452, buy = 20 },
		{ itemName = "rope", clientId = 3003, buy = 50, sell = 15, count = 1 },
		{ itemName = "saw", clientId = 3461, buy = 95 },
		{ itemName = "scythe", clientId = 3453, buy = 50, sell = 10 },
		{ itemName = "shovel", clientId = 3457, buy = 10, sell = 8, count = 1 },
		{ itemName = "torch", clientId = 2920, buy = 2, count = 1 },
		{ itemName = "very noble-looking watch", clientId = 6092, buy = 500 },
		{ itemName = "watch", clientId = 2906, buy = 20, sell = 6 },
		{ itemName = "watering can", clientId = 650, buy = 50 },
		{ itemName = "worm", clientId = 3492, buy = 1, sell = 1, count = 1 },
	},
	["rings"] = {
		{ itemName = "alicorn ring", clientId = 39182, buy = 100000 },
		{ itemName = "arboreal ring", clientId = 39188, buy = 100000 },
		{ itemName = "arcanomancer sigil", clientId = 39185, buy = 100000 },
		{ itemName = "axe ring", clientId = 3092, buy = 500, sell = 100 },
		{ itemName = "club ring", clientId = 3093, buy = 500, sell = 100 },
		{ itemName = "dwarven ring", clientId = 3097, buy = 2000, sell = 100 },
		{ itemName = "energy ring", clientId = 3051, buy = 2000, sell = 100 },
		{ itemName = "life ring", clientId = 3052, buy = 900, sell = 50 },
		{ itemName = "might ring", clientId = 3048, buy = 25000, sell = 250, count = 20 },
		{ itemName = "power ring", clientId = 3050, buy = 100, sell = 50 },
		{ itemName = "shapeshifter ring", clientId = 907, buy = 5500, subType = 15 },
		{ itemName = "spiritthorn ring", clientId = 39177, buy = 100000 },
		{ itemName = "stealth ring", clientId = 3049, buy = 5000, sell = 200 },
		{ itemName = "sweetheart ring", clientId = 21955, buy = 500 },
		{ itemName = "sword ring", clientId = 3091, buy = 500, sell = 100 },
		{ itemName = "time ring", clientId = 3053, buy = 2000, sell = 100 },
		{ itemName = "wedding ring", clientId = 3004, buy = 990, sell = 100 },
	},
	["amulets"] = {
		{ itemName = "amulet of loss", clientId = 3057, buy = 50000, sell = 45000 },
		{ itemName = "bronze amulet", clientId = 3056, buy = 100, sell = 50, count = 200 },
		{ itemName = "dragon necklace", clientId = 3085, buy = 1000, sell = 100, count = 200 },
		{ itemName = "elven amulet", clientId = 3082, buy = 500, sell = 100, count = 50 },
		{ itemName = "garlic necklace", clientId = 3083, buy = 100, sell = 50, count = 150 },
		{ itemName = "golden amulet", clientId = 3013, buy = 6600, sell = 2000 },
		{ itemName = "greater garlic necklace", clientId = 51275, buy = 100000 },
		{ itemName = "harmony amulet", clientId = 50195, buy = 1000 },
		{ itemName = "lion amulet", clientId = 34158, buy = 100000 },
		{ itemName = "protection amulet", clientId = 3084, buy = 700, sell = 100, count = 250 },
		{ itemName = "ruby necklace", clientId = 3016, buy = 3560, sell = 2000 },
		{ itemName = "scarf", clientId = 3572, buy = 15 },
		{ itemName = "silver amulet", clientId = 3054, buy = 100, sell = 50, count = 200 },
		{ itemName = "stone skin amulet", clientId = 3081, buy = 25000, sell = 500, count = 5 },
		{ itemName = "strange talisman", clientId = 3045, buy = 100, sell = 30, count = 200 },
		{ itemName = "the cobra amulet", clientId = 31631, buy = 100000 },
	},
}

npcConfig.shop = {}
for _, categoryTable in pairs(itemsTable) do
	for _, itemTable in ipairs(categoryTable) do
		table.insert(npcConfig.shop, itemTable)
	end
end

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
	-- Shop categories respond directly in any channel/say, even if interaction focus dropped.
	local player = Player(creature)
	local categoryTable = player and itemsTable[message:lower()]
	if categoryTable then
		local remainingCategories = npc:getRemainingShopCategories(message:lower(), itemsTable)
		npcHandler:say("Of course, just browse through my wares. You can also look at " .. remainingCategories .. ".", npc, player)
		npc:openShopWindowTable(player, categoryTable)
		return
	end
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local categoryTable = itemsTable[message:lower()]
	if categoryTable then
		local remainingCategories = npc:getRemainingShopCategories(message:lower(), itemsTable)
		npcHandler:say("Of course, just browse through my wares. You can also look at " .. remainingCategories .. ".", npc, player)
		npc:openShopWindowTable(player, categoryTable)
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Welcome, |PLAYERNAME|! I sell supplies for war: {distance}, {runes}, {potions}, {foods}, {tools}, {rings} and {amulets}. Just say the category or {trade}.")
npcHandler:setMessage(MESSAGE_SENDTRADE, "Of course, just browse through my wares. Or do you want to look only at " .. GetFormattedShopCategoryNames(itemsTable) .. ".")
npcHandler:setMessage(MESSAGE_FAREWELL, "Farewell, |PLAYERNAME|. Good luck in the war.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Come back soon!")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- On buy npc shop message
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end

-- On sell npc shop message
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))
end

-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

-- Dialog options (interactive icons in the NPC conversation window)
npcType:addDialogOptions("trade", "bye")

npcType:register(npcConfig)
