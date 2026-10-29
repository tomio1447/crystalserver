local config = {
	duration = 3570, -- 59.5 min de mapa ativo
	voteDuration = 60, -- último 1 min aberto para voto
	cooldown = 30, -- 30s entre mapas
	visualItemId = 25057, -- ice portal
	temple = Position(1048, 1065, 10),
	teleports = {
		Position(1056, 1060, 10),
		Position(1058, 1060, 10),
	},
	cities = {
		carlin = {
			name = "Carlin",
			destinations = {
				Position(942, 1155, 7),
				Position(924, 1125, 7),
				Position(965, 1153, 7),
			},
		},
		venore = {
			name = "Venore",
			destinations = {
				Position(771, 1173, 7),
				Position(832, 1154, 7),
			},
		},
	},
	rewards = {
		rouletteCoin = 3533,
		defensePotion = 7443,
		damagePotion = 7439,
		expPercent = 10,
	},
}

local mapKv = kv.scoped("warizi-map")
local WAR_MAP_TOKEN_STORAGE = (Storage and Storage.Warizi and Storage.Warizi.MapToken) or 150004
local votes = { carlin = {}, venore = {} }
local voteOpenAnnounced = false

local function now()
	return os.time()
end

local function setPhase(phase, endsAt)
	mapKv:set("phase", phase)
	mapKv:set("phase_end", endsAt)
	_G.WarMapActive = (phase == "active")
end

local function getPhase()
	return mapKv:get("phase") or "cooldown", mapKv:get("phase_end") or 0
end

local function setCurrentCity(cityKey)
	mapKv:set("current_city", cityKey)
end

local function getCurrentCity()
	return mapKv:get("current_city")
end

local function setNextCity(cityKey)
	mapKv:set("next_city", cityKey)
end

local function getNextCity()
	return mapKv:get("next_city")
end

local function getMapToken()
	return mapKv:get("map_token") or -1
end

local function newMapToken()
	local token = getMapToken()
	if token < 0 then
		token = 0
	end
	token = token + 1
	mapKv:set("map_token", token)
	return token
end

local function resetVotes()
	votes = { carlin = {}, venore = {} }
end

local function pickRandomCity()
	local keys = {}
	for key, _ in pairs(config.cities) do
		table.insert(keys, key)
	end
	return keys[math.random(#keys)]
end

local function chooseNextCityFromVotes()
	local counts = {}
	for city, list in pairs(votes) do
		local count = 0
		for _ in pairs(list) do
			count = count + 1
		end
		counts[city] = count
	end

	local maxCount = -1
	for _, count in pairs(counts) do
		if count > maxCount then
			maxCount = count
		end
	end

	if maxCount <= 0 then
		return pickRandomCity()
	end

	local top = {}
	for city, count in pairs(counts) do
		if count == maxCount then
			table.insert(top, city)
		end
	end

	return top[math.random(#top)]
end

local function createVisualTeleports()
	for _, pos in ipairs(config.teleports) do
		local tile = Tile(pos)
		if tile then
			if not tile:getItemById(config.visualItemId) then
				local item = Game.createItem(config.visualItemId, 1, pos)
				if not item then
					logger.warning("[WarMap] Failed to create visual portal at " .. pos:toString())
				end
			end
		else
			logger.warning("[WarMap] No tile at portal position " .. pos:toString())
		end
	end
end

local function removeVisualTeleports()
	for _, pos in ipairs(config.teleports) do
		local tile = Tile(pos)
		if tile then
			local item = tile:getItemById(config.visualItemId)
			if item then
				item:remove()
			end
		end
	end
end

local function sendPulseEffect()
	for _, pos in ipairs(config.teleports) do
		pos:sendMagicEffect(CONST_ME_ICETORNADO)
	end
end

local function getRemainingSeconds()
	local _, phaseEnd = getPhase()
	return math.max(0, phaseEnd - now())
end

local function formatTime(seconds)
	local m = math.floor(seconds / 60)
	local s = seconds % 60
	return string.format("%02d:%02d", m, s)
end

local function notifyNearbyPlayers()
	local cityKey = getCurrentCity()
	local city = cityKey and config.cities[cityKey]
	if not city then
		return
	end
	local remaining = getRemainingSeconds()
	local msg = string.format("War map: %s | Time remaining: %s", city.name, formatTime(remaining))
	for _, player in ipairs(Game.getPlayers()) do
		local playerPos = player:getPosition()
		for _, pos in ipairs(config.teleports) do
			if playerPos.z == pos.z and math.abs(playerPos.x - pos.x) <= 8 and math.abs(playerPos.y - pos.y) <= 6 then
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, msg)
				break
			end
		end
	end
end

local function sendLoginInfo(player)
	local phase = getPhase()
	if phase ~= "active" then
		local remaining = getRemainingSeconds()
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("No war map is active. Next map in %s.", formatTime(remaining)))
		return
	end
	local cityKey = getCurrentCity()
	local city = cityKey and config.cities[cityKey]
	if city then
		local remaining = getRemainingSeconds()
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Current war map: %s | Time remaining: %s", city.name, formatTime(remaining)))
	end
end

local function teleportPlayersToTemple()
	for _, player in ipairs(Game.getPlayers()) do
		player:teleportTo(config.temple, true)
		player:setStorageValue(WAR_MAP_TOKEN_STORAGE, -1)
		player:kv():remove("warizi-last-map")
	end
end

local function expRewardForPlayer(player)
	local currentExp = player:getExperience()
	local nextLevelExp = Game.getExperienceForLevel(player:getLevel() + 1)
	local needed = nextLevelExp - currentExp
	return math.max(0, math.floor(needed * config.rewards.expPercent / 100))
end

local function giveWinnerRewards(player)
	local expAmount = expRewardForPlayer(player)
	if expAmount > 0 then
		player:addExperience(expAmount, true)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You received %d experience as a map winner reward.", expAmount))
	end

	local container = player:getStoreInbox() or player:getInbox()
	if container then
		local items = {
			{ id = config.rewards.rouletteCoin, count = 1 },
			{ id = config.rewards.defensePotion, count = 1 },
			{ id = config.rewards.damagePotion, count = 1 },
		}
		for _, itemData in ipairs(items) do
			local item = Game.createItem(itemData.id, itemData.count)
			if item then
				container:addItemEx(item)
			end
		end
	end
end

local function getPlayerNameByGuid(guid)
	local player = Player(guid)
	if player then
		return player:getName()
	end
	local resultId = db.storeQuery("SELECT `name` FROM `players` WHERE `id` = " .. guid)
	if resultId then
		local name = Result.getString(resultId, "name")
		Result.free(resultId)
		return name
	end
	return "Unknown"
end

local function broadcastWinners(winners)
	local city = config.cities[getCurrentCity()] or { name = "Unknown" }
	local lines = {
		string.format("The war in %s has ended!", city.name),
	}
	if winners.serialKiller then
		table.insert(lines, string.format("Serial Killer: %s (%d frags)", winners.serialKiller.name, winners.serialKiller.score))
	end
	if winners.healGod then
		table.insert(lines, string.format("Heal God: %s (%d HP healed)", winners.healGod.name, winners.healGod.score))
	end
	if winners.warShield then
		table.insert(lines, string.format("War Shield: %s (%d damage taken)", winners.warShield.name, winners.warShield.score))
	end
	if winners.bestDamage then
		table.insert(lines, string.format("Best damage: %d (%s)", winners.bestDamage.score, winners.bestDamage.name))
	end
	if winners.bestHeal then
		table.insert(lines, string.format("Best heal: %d (%s)", winners.bestHeal.score, winners.bestHeal.name))
	end

	local msg = table.concat(lines, "\n")
	for _, player in ipairs(Game.getPlayers()) do
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, msg)
	end
end

local function updateRanking(winners)
	local categories = {
		{ key = "serial_killer", winner = winners.serialKiller },
		{ key = "heal_god", winner = winners.healGod },
		{ key = "war_shield", winner = winners.warShield },
		{ key = "best_damage", winner = winners.bestDamage },
		{ key = "best_heal", winner = winners.bestHeal },
	}
	for _, cat in ipairs(categories) do
		if cat.winner then
			local score = cat.winner.score or 1
			db.query(string.format(
				"INSERT INTO `warizi_map_ranking` (`category`, `player_id`, `player_name`, `wins`, `total_score`, `last_win`, `updated_at`) VALUES ('%s', %d, %s, 1, %d, %d, %d) ON DUPLICATE KEY UPDATE `wins` = `wins` + 1, `total_score` = `total_score` + %d, `last_win` = %d, `updated_at` = %d",
				cat.key,
				cat.winner.id,
				db.escapeString(cat.winner.name),
				score,
				now(),
				now(),
				score,
				now(),
				now()
			))
		end
	end
end

local function getVoteCounts()
	local counts = {}
	for city, list in pairs(votes) do
		local n = 0
		for _ in pairs(list) do
			n = n + 1
		end
		counts[city] = n
	end
	return counts
end

local function isVoteOpen()
	local phase, phaseEnd = getPhase()
	if phase ~= "active" then
		return false
	end
	local remaining = phaseEnd - now()
	return remaining > 0 and remaining <= config.voteDuration
end

local function broadcastVoteTally()
	local counts = getVoteCounts()
	local parts = {}
	local keys = {}
	for key, _ in pairs(config.cities) do
		table.insert(keys, key)
	end
	table.sort(keys)
	for _, key in ipairs(keys) do
		local city = config.cities[key]
		table.insert(parts, string.format("%s: %d", city.name, counts[key] or 0))
	end
	Game.broadcastMessage(string.format("Next map voting: %s. Vote with !votemap", table.concat(parts, " | ")), MESSAGE_EVENT_ADVANCE)
end

local function sendScoreboardModal(cityKey)
	local city = config.cities[cityKey] or { name = "Unknown" }
	local stats = WarMapStats and WarMapStats.getCurrent and WarMapStats.getCurrent() or {}

	local function buildCategory(title, data, unit)
		local entries = {}
		for guid, score in pairs(data) do
			table.insert(entries, { id = guid, score = score })
		end
		table.sort(entries, function(a, b)
			return a.score > b.score
		end)
		local lines = { title }
		if #entries == 0 then
			table.insert(lines, "  - none -")
		else
			for i = 1, math.min(3, #entries) do
				local e = entries[i]
				table.insert(lines, string.format("  %d. %s - %d %s", i, getPlayerNameByGuid(e.id), e.score, unit))
			end
		end
		return table.concat(lines, "\n")
	end

	local message = table.concat({
		string.format("Map: %s", city.name),
		"",
		buildCategory("Serial Killer (frags):", stats.frags or {}, "frags"),
		"",
		buildCategory("Heal God (healing):", stats.healing or {}, "HP"),
		"",
		buildCategory("War Shield (damage taken):", stats.damageTaken or {}, "damage"),
		"",
		buildCategory("Best damage (single hit):", stats.bestDamage or {}, "damage"),
		"",
		buildCategory("Best heal (single heal):", stats.bestHeal or {}, "HP"),
	}, "\n")

	local window = ModalWindow({})
	window:setTitle("War Map Results")
	window:setMessage(message)
	window:addButton("Close", function()
		return true
	end)
	for _, player in ipairs(Game.getPlayers()) do
		window:sendToPlayer(player)
	end
end

local function resolveWinners()
	local stats = WarMapStats and WarMapStats.getCurrent and WarMapStats.getCurrent() or {}
	local function top(category)
		local data = stats[category] or {}
		local bestScore = -1
		local tied = {}
		for guid, score in pairs(data) do
			if score > bestScore then
				bestScore = score
				tied = { { id = guid, score = score } }
			elseif score == bestScore then
				table.insert(tied, { id = guid, score = score })
			end
		end
		if bestScore <= 0 then
			return nil
		end
		local chosen = tied[math.random(#tied)]
		chosen.name = getPlayerNameByGuid(chosen.id)
		return chosen
	end

	return {
		serialKiller = top("frags"),
		healGod = top("healing"),
		warShield = top("damageTaken"),
		bestDamage = top("bestDamage"),
		bestHeal = top("bestHeal"),
	}
end

local function startActive(cityKey)
	setCurrentCity(cityKey)
	mapKv:remove("next_city")
	resetVotes()
	voteOpenAnnounced = false
	if WarMapStats and WarMapStats.reset then
		WarMapStats.reset()
	end
	newMapToken()
	setPhase("active", now() + config.duration)
	createVisualTeleports()

	local city = config.cities[cityKey] or { name = tostring(cityKey) }
	logger.info("[WarMap] Map active: " .. city.name)
	Game.broadcastMessage(string.format("The war has moved to %s! Teleports are open in the temple.", city.name), MESSAGE_EVENT_ADVANCE)

	-- spawn war bot squads on the newly active map
	if _G.WarBots and _G.WarBots.enabled and _G.WarBots.syncSquads then
		_G.WarBots.despawnAll()
		_G.WarBots.syncSquads(cityKey)
	end
end

local function endActive()
	local nextCity = getNextCity() or chooseNextCityFromVotes()
	setNextCity(nextCity)
	removeVisualTeleports()
	teleportPlayersToTemple()
	if _G.WarBots and _G.WarBots.despawnAll then
		_G.WarBots.despawnAll()
	end

	local winners = resolveWinners()
	broadcastWinners(winners)
	sendScoreboardModal(getCurrentCity())

	for _, winner in pairs(winners) do
		local player = Player(winner.id)
		if player then
			giveWinnerRewards(player)
		end
	end

	updateRanking(winners)
	setPhase("cooldown", now() + config.cooldown)

	local city = config.cities[nextCity] or { name = tostring(nextCity) }
	logger.info("[WarMap] Map ended. Next: " .. city.name)
	Game.broadcastMessage(string.format("Next war map will be %s. Prepare in %d seconds!", city.name, config.cooldown), MESSAGE_EVENT_ADVANCE)
end

local function endCooldown()
	local nextCity = getNextCity() or pickRandomCity()
	startActive(nextCity)
end

local function checkTransition()
	local phase, phaseEnd = getPhase()
	if now() < phaseEnd then
		return
	end

	if phase == "active" then
		endActive()
	elseif phase == "cooldown" then
		endCooldown()
	end
end

local function init()
	local phase, phaseEnd = getPhase()
	if not phase or phase == "" then
		setPhase("cooldown", now() + config.cooldown)
		setNextCity(pickRandomCity())
		return
	end

	if phase == "active" and now() >= phaseEnd then
		endActive()
	elseif phase == "cooldown" and now() >= phaseEnd then
		endCooldown()
	elseif phase == "active" then
		if getMapToken() < 0 then
			newMapToken()
		end
		createVisualTeleports()
		voteOpenAnnounced = isVoteOpen()
		_G.WarMapActive = true
	else
		_G.WarMapActive = false
	end
end

local tickCounter = 0
local tickEvent = GlobalEvent("warMapManagerTick")

function tickEvent.onThink(interval, lastExecution)
	checkTransition()
	tickCounter = tickCounter + 1
	local phase = getPhase()
	if phase == "active" then
		if not voteOpenAnnounced and isVoteOpen() then
			voteOpenAnnounced = true
			Game.broadcastMessage(string.format("Voting for the next war map is now open! %d seconds left. Use !votemap 1 (Carlin) or !votemap 2 (Venore).", config.voteDuration), MESSAGE_EVENT_ADVANCE)
		end
		if tickCounter % 5 == 0 then
			sendPulseEffect()
		end
		if tickCounter % 10 == 0 then
			notifyNearbyPlayers()
		end
	end
	return true
end

tickEvent:interval(1000)
tickEvent:register()

local startupEvent = GlobalEvent("warMapManagerStartup")

function startupEvent.onStartup()
	init()
end

startupEvent:type("startup")
startupEvent:register()

local function forceStart(cityKey)
	if not config.cities[cityKey] then
		return false
	end
	setNextCity(cityKey)
	local phase = getPhase()
	if phase == "active" then
		mapKv:set("phase_end", now())
	else
		setPhase("cooldown", now())
	end
	return true
end

_G.WarMapCities = config.cities

_G.WarMapManager = {
	config = config,
	getCurrentCity = getCurrentCity,
	getPhase = getPhase,
	getMapToken = getMapToken,
	forceStart = forceStart,
	getVotes = function() return votes end,
	getVoteCounts = getVoteCounts,
	isVoteOpen = isVoteOpen,
	broadcastVoteTally = broadcastVoteTally,
	sendLoginInfo = sendLoginInfo,
	vote = function(playerGuid, cityKey)
		if not votes[cityKey] then
			return false
		end
		for _, list in pairs(votes) do
			list[tostring(playerGuid)] = nil
		end
		votes[cityKey][tostring(playerGuid)] = true
		return true
	end,
}
