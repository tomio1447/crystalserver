local frags = TalkAction("!frags")

local function formatBonuses(bonuses)
	return string.format(
		"Experience gained: +%d%%\nExperience loss reduction: %d%%\nSkill and magic gain: +%d%%\nDamage received reduction: %d%%\nPvP damage dealt: +%d%%\nExtra crystal coins per PvP reward: %d",
		bonuses.experience,
		bonuses.experienceLoss,
		bonuses.skill,
		bonuses.damageReceived,
		bonuses.damageDealt,
		bonuses.crystalCoins
	)
end

function frags.onSay(player, words, param)
	if not WarSystem.isEnabled() then
		player:sendCancelMessage("The War progression system is disabled.")
		return true
	end

	local lifetimeFrags = WarSystem.getFrags(player)
	local deaths = WarSystem.getDeaths(player)
	local rankPoints = WarSystem.getRankPoints(player)
	local rank = WarSystem.getRank(rankPoints)
	local nextRank, nextThreshold = WarSystem.getNextRank(rankPoints)
	local progress = nextRank and string.format("%d/%d rank points to %s", rankPoints, nextThreshold, nextRank.name) or "Maximum rank reached"
	local message = string.format(
		"Lifetime frags: %d\nPvP deaths: %d\nRank points (frags - deaths): %d\nFrag Coins: %d\nCurrent rank: %s\nProgress: %s\n\nCumulative bonuses\n%s\n\nThresholds\nWhite: %d | Yellow: %d | Orange: %d | Red: %d | Black: %d",
		lifetimeFrags,
		deaths,
		rankPoints,
		player:getTibiaCoins(),
		rank.name,
		progress,
		formatBonuses(WarSystem.getBonuses(rankPoints)),
		configManager.getNumber(configKeys.WAR_WHITE_SKULL_FRAGS),
		configManager.getNumber(configKeys.WAR_YELLOW_SKULL_FRAGS),
		configManager.getNumber(configKeys.WAR_ORANGE_SKULL_FRAGS),
		configManager.getNumber(configKeys.WAR_RED_SKULL_FRAGS),
		configManager.getNumber(configKeys.WAR_BLACK_SKULL_FRAGS)
	)
	local window = ModalWindow({ title = "War Frags", message = message })
	window:addButton("Close")
	window:setDefaultEscapeButton("Close")
	window:sendToPlayer(player)
	return true
end

frags:separator(" ")
frags:groupType("normal")
frags:register()
