local commonItems = {
	{ 9596, 1 },
	{ 3725, 100 },
	{ 6432, 1 },
}

local vocationItems = {
	[VOCATION.ID.MASTER_SORCERER] = {
		{ 8864, 1 }, { 11687, 1 }, { 8090, 1 }, { 3079, 1 }, { 10387, 1 }, { 25700, 1 },
		{ 23373, 1 }, { 3155, 1 }, { 3192, 1 }, { 3148, 1 }, { 3180, 1 }, { 3197, 1 },
	},
	[VOCATION.ID.ELDER_DRUID] = {
		{ 8864, 1 }, { 11687, 1 }, { 8090, 1 }, { 3079, 1 }, { 10387, 1 }, { 25700, 1 },
		{ 23373, 1 }, { 3155, 1 }, { 3192, 1 }, { 3148, 1 }, { 3180, 1 }, { 3197, 1 }, { 3165, 1 },
	},
	[VOCATION.ID.ROYAL_PALADIN] = {
		{ 11689, 1 }, { 8060, 1 }, { 8863, 1 }, { 3079, 1 }, { 8023, 1 }, { 16164, 1 }, { 35848, 1 }, { 3277, 1 },
		{ 23374, 1 }, { 238, 1 }, { 25757, 1 }, { 25758, 1 }, { 3155, 1 },
	},
	[VOCATION.ID.ELITE_KNIGHT] = {
		{ 16175, 1 }, { 16161, 1 }, { 16162, 1 }, { 10385, 1 }, { 8862, 1 }, { 10387, 1 },
		{ 4033, 1 }, { 11688, 1 }, { 238, 1 }, { 7643, 1 },
	},
	[VOCATION.ID.EXALTED_MONK] = {
		{ 50267, 1 }, { 50274, 1 }, { 50271, 1 }, { 50269, 1 }, { 50273, 1 }, { 50268, 1 },
		{ 50272, 1 }, { 50195, 1 }, { 50166, 1 }, { 50171, 1 }, { 23374, 1 }, { 238, 1 },
	},
}

local function unlockMonkPath(player)
	local quest = player:questKV("the_way_of_the_monk_quest")
	quest:set("questline", 4)
	quest:set("questlog", 4)
	quest:set("boolPointsWheel", true)
	local shrines = quest:scoped("mainShrines")
	for _, shrine in ipairs({ "guidance", "tranquility", "respect", "legacy", "empathy", "harmony", "power", "knowledge", "serenity", "eternity" }) do
		shrines:set(shrine, true)
	end
	player:setStorageValue(Storage.Quest.U15_00.TheWayOfTheMonk.Questline, 4)
	player:setStorageValue(Storage.Quest.U15_00.TheWayOfTheMonk.Questlog, 4)
end

local sendFirstItems = CreatureEvent("SendFirstItems")

function sendFirstItems.onLogin(player)
	if not WarSystem.isEnabled() or player:getLastLoginSaved() ~= 0 then
		return true
	end

	local items = vocationItems[player:getVocation():getId()]
	if not items then
		return true
	end

	local backpack = player:addItem(24395)
	if not backpack then
		return true
	end

	for _, entry in ipairs(commonItems) do
		backpack:addItem(entry[1], entry[2])
	end
	for _, entry in ipairs(items) do
		player:addItem(entry[1], entry[2], false)
	end

	if player:getVocation():getId() == VOCATION.ID.EXALTED_MONK then
		unlockMonkPath(player)
	end
	return true
end

sendFirstItems:register()
