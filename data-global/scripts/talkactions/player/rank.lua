local CATEGORIES = {
	{ key = "serial_killer", title = "Serial Killer (frags)", unit = "frags" },
	{ key = "heal_god", title = "Heal God (healing)", unit = "HP" },
	{ key = "war_shield", title = "War Shield (damage taken)", unit = "damage" },
	{ key = "best_damage", title = "Best Damage (single hit)", unit = "damage" },
	{ key = "best_heal", title = "Best Heal (single heal)", unit = "HP" },
}

local function buildCategoryLines(cat)
	local lines = { cat.title }
	local resultId = db.storeQuery(string.format(
		"SELECT `player_name`, `wins`, `total_score` FROM `warizi_map_ranking` WHERE `category` = '%s' ORDER BY `wins` DESC, `total_score` DESC LIMIT 5",
		cat.key
	))
	if not resultId then
		table.insert(lines, "  - none -")
		return table.concat(lines, "\n")
	end

	local rank = 0
	repeat
		rank = rank + 1
		local name = Result.getString(resultId, "player_name")
		local wins = Result.getNumber(resultId, "wins")
		local score = Result.getNumber(resultId, "total_score")
		table.insert(lines, string.format("  %d. %s - %d wins (%d %s)", rank, name, wins, score, cat.unit))
	until not Result.next(resultId)
	Result.free(resultId)

	if rank == 0 then
		table.insert(lines, "  - none -")
	end
	return table.concat(lines, "\n")
end

local talkAction = TalkAction("!rank")

function talkAction.onSay(player, words, param, type)
	local sections = { "Overall war map ranking:" }
	for _, cat in ipairs(CATEGORIES) do
		table.insert(sections, "")
		table.insert(sections, buildCategoryLines(cat))
	end

	local window = ModalWindow({})
	window:setTitle("War Map Ranking")
	window:setMessage(table.concat(sections, "\n"))
	window:addButton("Close", function()
		return true
	end)
	window:sendToPlayer(player)
	return false
end

talkAction:separator(" ")
talkAction:groupType("normal")
talkAction:register()
