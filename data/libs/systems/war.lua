WarSystem = {
	crystalCoinId = 3043,
	ranks = {
		{ name = "Black Skull", skull = SKULL_BLACK, configKey = configKeys.WAR_BLACK_SKULL_FRAGS },
		{ name = "Red Skull", skull = SKULL_RED, configKey = configKeys.WAR_RED_SKULL_FRAGS },
		{ name = "Orange Skull", skull = SKULL_ORANGE, configKey = configKeys.WAR_ORANGE_SKULL_FRAGS },
		{ name = "Yellow Skull", skull = SKULL_YELLOW, configKey = configKeys.WAR_YELLOW_SKULL_FRAGS },
		{ name = "White Skull", skull = SKULL_WHITE, configKey = configKeys.WAR_WHITE_SKULL_FRAGS },
	},
}

function WarSystem.isEnabled()
	return configManager.getBoolean(configKeys.WAR_SYSTEM_ENABLED)
end

function WarSystem.getFrags(player)
	return player:getWarLifetimeFrags()
end

function WarSystem.getDeaths(player)
	return player:getWarDeaths()
end

function WarSystem.getRankPoints(player)
	return player:getWarRankPoints()
end

function WarSystem.getRank(frags)
	for _, rank in ipairs(WarSystem.ranks) do
		local threshold = configManager.getNumber(rank.configKey)
		if frags >= threshold then
			return rank, threshold
		end
	end
	return { name = "No Skull", skull = SKULL_NONE }, 0
end

function WarSystem.getNextRank(frags)
	for index = #WarSystem.ranks, 1, -1 do
		local rank = WarSystem.ranks[index]
		local threshold = configManager.getNumber(rank.configKey)
		if frags < threshold then
			return rank, threshold
		end
	end
	return nil, nil
end

function WarSystem.getBonuses(frags)
	local white = frags >= configManager.getNumber(configKeys.WAR_WHITE_SKULL_FRAGS)
	local yellow = frags >= configManager.getNumber(configKeys.WAR_YELLOW_SKULL_FRAGS)
	local orange = frags >= configManager.getNumber(configKeys.WAR_ORANGE_SKULL_FRAGS)
	local red = frags >= configManager.getNumber(configKeys.WAR_RED_SKULL_FRAGS)
	local black = frags >= configManager.getNumber(configKeys.WAR_BLACK_SKULL_FRAGS)
	return {
		experience = (white and 10 or 0) + (black and 2 or 0),
		experienceLoss = (yellow and 10 or 0) + (black and 2 or 0),
		skill = (orange and 10 or 0) + (black and 5 or 0),
		damageReceived = red and 5 or 0,
		damageDealt = black and 5 or 0,
		crystalCoins = red and 1 or 0,
	}
end

function WarSystem.addFrag(player)
	local frags = player:addWarLifetimeFrag()
	db.query("UPDATE `players` SET `war_lifetime_frags` = " .. frags .. " WHERE `id` = " .. player:getGuid())
	player:setSkull(SKULL_NONE)
	return frags
end

function WarSystem.addDeath(player)
	local deaths = player:addWarDeath()
	db.query("UPDATE `players` SET `war_deaths` = " .. deaths .. " WHERE `id` = " .. player:getGuid())
	player:setSkull(SKULL_NONE)
	return deaths
end

function WarSystem.rewardAttacker(attacker, victim, damage, damageRatio, experience)
	local frags = WarSystem.addFrag(attacker)
	local bonuses = WarSystem.getBonuses(attacker:getWarRankPoints())
	local fragCoins = configManager.getNumber(configKeys.WAR_PVP_FRAG_COIN_REWARD)
	local crystalCoins = configManager.getNumber(configKeys.WAR_PVP_CRYSTAL_COIN_REWARD) + bonuses.crystalCoins
	local forgeDust = configManager.getNumber(configKeys.WAR_PVP_DUST_REWARD)
	attacker:addTibiaCoins(fragCoins)
	attacker:addItem(WarSystem.crystalCoinId, crystalCoins, false)
	attacker:addForgeDusts(forgeDust)
	db.asyncQuery(string.format("INSERT INTO `war_pvp_kills` (`victim_id`, `attacker_id`, `damage`, `damage_ratio`, `experience`, `frag_coins`, `crystal_coins`, `forge_dust`, `created_at`) VALUES (%d, %d, %d, %.6f, %d, %d, %d, %d, %d)", victim:getGuid(), attacker:getGuid(), damage, damageRatio, experience, fragCoins, crystalCoins, forgeDust, os.time()))
	attacker:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("PvP reward: %d crystal coin%s, %d Frag Coin%s and %d forge dust. Lifetime frags: %d.", crystalCoins, crystalCoins == 1 and "" or "s", fragCoins, fragCoins == 1 and "" or "s", forgeDust, frags))
	return frags
end
