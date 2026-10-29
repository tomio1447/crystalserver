-- War Bots Squad: squads of real clientless Players (server-side) that patrol the
-- active war map, hunt players together, support each other (sio/paralyze/magic wall)
-- and execute synchronized UE combos. Whole squad respawns when wiped.
_G.WarBots = _G.WarBots or {}
local WarBots = _G.WarBots

WarBots.squads = WarBots.squads or {}
WarBots.botToSquad = WarBots.botToSquad or {}
WarBots.nextSquadId = WarBots.nextSquadId or 1
WarBots.enabled = WarBots.enabled ~= nil and WarBots.enabled or true

local config = {
	squadMinSize = 5,
	squadMaxSize = 8,
	respawnDelaySec = 120,
	levelMin = 220,
	levelMax = 770,
	aggroRangeX = 9,
	aggroRangeY = 7,
	castCooldownMinSec = 2,
	castCooldownMaxSec = 3, -- casts share the action slot with weapon swings (classicAttackSpeed=false)
	comboIntervalSec = 9,
	healHpPercent = 60,
	patrolWaypointRange = 18,
	-- runes used by the bots (real items required in inventory)
	sdRune = 3155,
	mwallRune = 3180,
	paralyzeRune = 3165,
	boltItem = 35902, -- spectral bolt ammunition used by the RP crossbow/quiver
	-- base stats at level 220 (from the former Sample characters, now embedded)
	sampleStats = {
		[8] = { level = 220, health = 3365, mana = 1100, cap = 5770, maglevel = 20, skill_fist = 10, skill_club = 10, skill_sword = 10, skill_axe = 10, skill_dist = 10, skill_shielding = 110 }, -- Elite Knight
		[7] = { level = 220, health = 2305, mana = 3220, cap = 4710, maglevel = 34, skill_fist = 10, skill_club = 10, skill_sword = 10, skill_axe = 10, skill_dist = 120, skill_shielding = 100 }, -- Royal Paladin
		[5] = { level = 220, health = 1245, mana = 6400, cap = 2590, maglevel = 100, skill_fist = 10, skill_club = 10, skill_sword = 10, skill_axe = 10, skill_dist = 10, skill_shielding = 10 }, -- Master Sorcerer
		[6] = { level = 220, health = 1245, mana = 6400, cap = 2590, maglevel = 100, skill_fist = 10, skill_club = 10, skill_sword = 10, skill_axe = 10, skill_dist = 10, skill_shielding = 10 }, -- Elder Druid
	},
	-- cobra weapon sets per vocation (cobra items are level 220 in items.xml)
	-- EK picks one random cobra weapon and gets skill 110 on the matching type
	botWeapons = {
		[8] = { 30395, 30396, 30398 }, -- cobra club / cobra axe / cobra sword
		[7] = { 30393 }, -- cobra crossbow
		[6] = { 30399 }, -- cobra wand
		[5] = { 30400 }, -- cobra rod
	},
	skillByWeapon = {
		[30395] = SKILL_CLUB,
		[30396] = SKILL_AXE,
		[30398] = SKILL_SWORD,
	},
	-- 1 squad for every N real players online
	playersPerSquad = 10,
	maxSquadsPerMap = 10,
	-- random spawn points per city; one is picked per squad and bots spread around it
	citySpawnPoints = {
		venore = {
			Position(773, 1173, 6),
			Position(790, 1137, 6),
			Position(767, 1119, 6),
			Position(731, 1166, 6),
		},
		carlin = {
			Position(987, 1157, 7),
			Position(975, 1185, 7),
			Position(948, 1187, 7),
		},
	},
	spawnScatterRange = 2,
	potions = {
		greatMana = 238,
		supreme = 23375,
		ultSpirit = 23374,
		ultMana = 23373,
	},
}
WarBots.config = config

local botNames = {
	"Warbot Alpha", "Warbot Bravo", "Warbot Charlie", "Warbot Delta", "Warbot Echo",
	"Warbot Foxtrot", "Warbot Ghost", "Warbot Hunter", "Warbot Iron", "Warbot Joker",
	"Warbot Kilo", "Warbot Lima", "Warbot Mike", "Warbot Nova", "Warbot Omega",
	"Warbot Panda", "Warbot Quinn", "Warbot Rex", "Warbot Storm", "Warbot Titan",
}
local usedNames = {}

local function pickName()
	local free = {}
	for _, name in ipairs(botNames) do
		if not usedNames[name] then
			table.insert(free, name)
		end
	end
	local name = #free > 0 and free[math.random(#free)] or ("Warbot " .. math.random(1000, 9999))
	usedNames[name] = true
	return name
end

-- squad composition for a given size: more knights/mages at bigger sizes
local function pickComposition(size)
	local vocations = { EK = 8, RP = 7, MS = 5, ED = 6 }
	local comp = {}
	-- at least 1 ED (healer/paralyzer), 1 EK (blocker), rest spread
	table.insert(comp, vocations.ED)
	table.insert(comp, vocations.EK)
	local fillers = { vocations.MS, vocations.RP, vocations.MS, vocations.EK, vocations.RP, vocations.MS, vocations.ED, vocations.EK }
	for i = 3, size do
		table.insert(comp, fillers[(i - 3) % #fillers + 1])
	end
	return comp
end

local function dist(p1, p2)
	return math.max(math.abs(p1.x - p2.x), math.abs(p1.y - p2.y), math.abs(p1.z - p2.z))
end

local function dirTowards(from, to)
	local dx = to.x - from.x
	local dy = to.y - from.y
	if math.abs(dx) >= math.abs(dy) then
		return dx >= 0 and DIRECTION_EAST or DIRECTION_WEST
	end
	return dy >= 0 and DIRECTION_SOUTH or DIRECTION_NORTH
end

local function findRune(bot, itemId)
	return bot:getItemById(itemId, true)
end

-- runes inside containers have no map position; the hotkey position (0xFFFF,0,0)
-- makes the server deep-search the whole inventory for the rune id
local HOTKEY_POS = Position(0xFFFF, 0, 0)

-- screen-range + line-of-sight: bots only engage what a normal client view
-- (8x6 sqm around them) would allow, and never throw runes through walls
local function onScreen(bot, pos)
	local bp = bot:getPosition()
	return pos.z == bp.z and math.abs(pos.x - bp.x) <= 8 and math.abs(pos.y - bp.y) <= 6
end

local function hasLOS(bot, pos)
	return onScreen(bot, pos) and bot:canSee(pos)
end

local function useRuneOnTarget(bot, itemId, target)
	if not findRune(bot, itemId) or not hasLOS(bot, target:getPosition()) then
		return false
	end
	Game.playerUseWithCreature(bot, HOTKEY_POS, 0, itemId, target)
	return true
end

local function useRuneOnPos(bot, itemId, pos)
	local rune = findRune(bot, itemId)
	if not rune or not hasLOS(bot, pos) then
		return false
	end
	Game.playerUseItemEx(bot, HOTKEY_POS, 0, itemId, pos, 0, 0)
	return true
end

local function usePotionOnSelf(bot, itemId)
	if not findRune(bot, itemId) then
		return false
	end
	Game.playerUseWithCreature(bot, HOTKEY_POS, 0, itemId, bot)
	return true
end

local function hpPct(bot)
	return bot:getMaxHealth() > 0 and (bot:getHealth() * 100 / bot:getMaxHealth()) or 100
end

local function manaPct(bot)
	return bot:getMaxMana() > 0 and (bot:getMana() * 100 / bot:getMaxMana()) or 100
end

local function getSampleRow(vocationId)
	return config.sampleStats[vocationId]
end

local function setupBotStats(bot, vocationId, level)
	bot:setVocation(vocationId)
	bot:setLevel(level)

	local sample = getSampleRow(vocationId)
	local vocation = bot:getVocation()
	if sample and vocation then
		local delta = level - sample.level
		bot:setMaxHealth(math.max(150, sample.health + (vocation:getHealthGain() or 10) * delta))
		bot:addHealth(bot:getMaxHealth())
		bot:setMaxMana(math.max(55, sample.mana + (vocation:getManaGain() or 20) * delta))
		bot:addMana(bot:getMaxMana())
		bot:setCapacity(math.max(400, sample.cap + (vocation:getCapacityGain() or 10) * delta) * 100)
		bot:setSkillLevel(SKILL_FIST, sample.skill_fist)
		bot:setSkillLevel(SKILL_CLUB, sample.skill_club)
		bot:setSkillLevel(SKILL_SWORD, sample.skill_sword)
		bot:setSkillLevel(SKILL_AXE, sample.skill_axe)
		bot:setSkillLevel(SKILL_DISTANCE, sample.skill_dist)
		bot:setSkillLevel(SKILL_SHIELD, sample.skill_shielding)
		bot:setMagicLevel(math.min(100, sample.maglevel + math.max(0, math.floor(delta / 20))))
		-- war bots use fixed combat stats like a tuned pk team
		if vocationId == 8 then
			bot:setMagicLevel(11)
		elseif vocationId == 7 then
			bot:setSkillLevel(SKILL_DISTANCE, 120)
			bot:setMagicLevel(34)
		elseif vocationId == 5 or vocationId == 6 then
			bot:setMagicLevel(100)
		end
	else
		local skillValue = math.min(120, 80 + math.floor(level / 15))
		for skill = SKILL_CLUB, SKILL_FIST do
			bot:setSkillLevel(skill, skillValue)
		end
		bot:setSkillLevel(SKILL_SHIELD, skillValue)
		bot:setSkillLevel(SKILL_DISTANCE, skillValue)
		bot:setMagicLevel(math.min(90, 30 + math.floor(level / 10)))
		bot:setMaxHealth(150 + ((vocation and vocation:getHealthGain()) or 10) * math.max(0, level - 1))
		bot:addHealth(bot:getMaxHealth())
		bot:setMaxMana(55 + ((vocation and vocation:getManaGain()) or 20) * math.max(0, level - 1))
		bot:addMana(bot:getMaxMana())
		bot:setCapacity(400 * 100)
	end
end

local SPELLS_TO_LEARN = {
	[8] = { "Berserk", "Fierce Berserk", "Front Sweep", "Annihilation", "Apprentice's Strike", "Wound Cleansing", "Intense Healing", "Intense Recovery", "Charge" },
	[7] = { "Ethereal Spear", "Strong Ethereal Spear", "Divine Missile", "Salvation", "Divine Caldera", "Cure Paralysis", "Intense Healing", "Haste" },
	[5] = { "Hell's Core", "Ultimate Ice Strike", "Rage of the Skies", "Restoration", "Magic Shield", "Ultimate Healing", "Heal Friend", "Strong Haste" },
	[6] = { "Eternal Winter", "Ultimate Ice Strike", "Wrath of Nature", "Restoration", "Magic Shield", "Heal Friend", "Mass Healing", "Ultimate Healing", "Intense Healing", "Strong Haste" },
}

local function teachSpells(bot, vocationId)
	for _, spellName in ipairs(SPELLS_TO_LEARN[vocationId] or {}) do
		bot:learnSpell(spellName, false)
	end

end

local function giveCombatSupplies(bot, vocationId)
	local backpack = bot:getSlotItem(CONST_SLOT_BACKPACK)
	if not backpack or not backpack:isContainer() then
		backpack = bot:addItem(2854, 1, true, 1, CONST_SLOT_BACKPACK)
	end
	local container = backpack and backpack:isContainer() and backpack or nil
	local function add(id, count)
		if container then
			container:addItem(id, count)
		else
			bot:addItem(id, count)
		end
	end
	add(config.sdRune, 400)
	add(config.paralyzeRune, 100)
	add(config.mwallRune, 100)
	add(config.potions.greatMana, 200)
	add(config.potions.supreme, 200)
	add(config.potions.ultSpirit, 200)
	add(config.potions.ultMana, 200)

	-- RP needs ammunition for the cobra crossbow: equip a jungle quiver and fill it
	if vocationId == 7 then
		local quiver = bot:getSlotItem(CONST_SLOT_RIGHT)
		if not quiver or not quiver:isContainer() then
			if quiver then
				quiver:remove()
			end
			quiver = bot:addItem(35524, 1, true, 1, CONST_SLOT_RIGHT)
		end
		if quiver and quiver:isContainer() then
			quiver:addItem(config.boltItem, 100)
			quiver:addItem(config.boltItem, 100)
		end
	end
end

-- replaces the starter weapon with the vocation's cobra weapon and
-- raises the matching skill (EK: 110 on the chosen weapon type, RP: dist 120)
local function equipBotWeapon(bot, vocationId)
	local weapons = config.botWeapons[vocationId]
	if not weapons then
		return
	end
	local weaponId = weapons[math.random(#weapons)]
	local left = bot:getSlotItem(CONST_SLOT_LEFT)
	if left then
		left:remove()
	end
	local added = bot:addItem(weaponId, 1, true, 1, CONST_SLOT_LEFT)
	local nowL = bot:getSlotItem(CONST_SLOT_LEFT)
	logger.warn(("[WarBots DBG] equip %s -> addItem=%s leftAfter=%s"):format(
		weaponId, tostring(added ~= nil), nowL and nowL:getId() or "none"))
	local skill = config.skillByWeapon[weaponId]
	if skill then
		bot:setSkillLevel(skill, 110)
	end
end

function WarBots.makeBot(position, vocationId)
	local name = pickName()
	local bot = Game.createBot(name, position, true, false)
	if not bot then
		logger.warn("[WarBots] createBot returned nil for " .. name)
		return nil
	end

	local level = math.random(config.levelMin, config.levelMax)
	setupBotStats(bot, vocationId, level)
	bot:setGroupFlag(IsAlwaysPremium)
	bot:setGroupFlag(HasInfiniteCapacity)
	bot:setGroupFlag(IgnoreWeaponCheck)
	if Newhaven and Newhaven.giveStarterItems then
		Newhaven.giveStarterItems(bot)
	end
	equipBotWeapon(bot, vocationId)
	giveCombatSupplies(bot, vocationId)
	teachSpells(bot, vocationId)

	bot:setChaseMode(true)
	local lookTypes = { [8] = 131, [7] = 129, [5] = 130, [6] = 130 }
	bot:setOutfit({ lookType = lookTypes[vocationId] or 128, lookHead = math.random(0, 132), lookBody = math.random(0, 132), lookLegs = math.random(0, 132), lookFeet = math.random(0, 132), lookAddons = 0 })
	bot:registerEvent("WariziBotThink")
	bot:registerEvent("WariziBotDeath")
	bot:registerEvent("WariziBotPrepareDeath")
	return bot
end

local function cityDestinations(cityKey)
	local cities = _G.WarMapCities
	if cities and cities[cityKey] then
		return cities[cityKey].destinations
	end
	return nil
end

function WarBots.spawnSquad(cityKey, size, forcePos)
	size = size or math.random(config.squadMinSize, config.squadMaxSize)
	local cityDests = cityDestinations(cityKey)
	local spawnPoints = config.citySpawnPoints[cityKey]
	local spawnPos
	if forcePos then
		spawnPos = forcePos
	elseif spawnPoints and #spawnPoints > 0 then
		spawnPos = spawnPoints[math.random(#spawnPoints)]
	elseif cityDests and #cityDests > 0 then
		spawnPos = cityDests[math.random(#cityDests)]
	else
		spawnPos = Game.getTowns()[1] and Game.getTowns()[1]:getTemplePosition() or Position(1000, 1000, 7)
	end

	local squad = {
		id = WarBots.nextSquadId,
		city = cityKey,
		members = {},
		target = nil,
		wpIndex = 1,
		nextComboAt = 0,
		comboActiveUntil = 0,
		spawnPos = spawnPos,
		waypoints = {},
	}
	WarBots.nextSquadId = WarBots.nextSquadId + 1

	-- build waypoints around the city destinations
	if cityDests then
		for _, dest in ipairs(cityDests) do
			for i = 1, 3 do
				table.insert(squad.waypoints, Position(
					dest.x + math.random(-config.patrolWaypointRange, config.patrolWaypointRange),
					dest.y + math.random(-config.patrolWaypointRange, config.patrolWaypointRange),
					dest.z
				))
			end
		end
	end

	-- spawn rules: the first bot lands on the fixed spawn point; every next bot
	-- must be placed on a walkable, creature-free tile adjacent to a bot that
	-- already spawned (never inside walls/unwalkable tiles)
	local placed = {}
	local function walkableFreePos(pos)
		local tile = Tile(pos)
		return tile and tile:isWalkable(false, false, false, false, true) and tile:getCreatureCount() == 0
	end
	local function pickSpawnPos()
		if #placed == 0 then
			return walkableFreePos(spawnPos) and spawnPos or nil
		end
		for _ = 1, 12 do
			local anchor = placed[math.random(#placed)]
			local dx, dy = math.random(-1, 1), math.random(-1, 1)
			if dx ~= 0 or dy ~= 0 then
				local pos = Position(anchor.x + dx, anchor.y + dy, anchor.z)
				if walkableFreePos(pos) then
					return pos
				end
			end
		end
		return nil
	end

	local comp = pickComposition(size)
	local roles = { [8] = "ek", [7] = "rp", [5] = "ms", [6] = "ed" }
	for _, vocId in ipairs(comp) do
		local bot = nil
		for attempt = 1, 8 do
			local botPos = pickSpawnPos()
			if botPos then
				bot = WarBots.makeBot(botPos, vocId)
				if bot then
					table.insert(placed, botPos)
					break
				end
			end
		end
		if bot then
			if not squad.leaderId then
				squad.leaderId = bot:getId()
			end
			local member = {
				creature = bot,
				role = roles[vocId],
				nextCastAt = 0,
				comboDoneAt = 0,
				ringSlot = nil, -- assigned surround slot around the target
			}
			squad.members[bot:getId()] = member
			WarBots.botToSquad[bot:getId()] = squad.id
		end
	end

	WarBots.squads[squad.id] = squad
	logger.info(string.format("[WarBots] squad %d spawned in %s with %d bots at %s", squad.id, tostring(cityKey), size, spawnPos:toString()))
	return squad
end

function WarBots.removeSquad(squadId)
	local squad = WarBots.squads[squadId]
	if not squad then
		return
	end
	for botId, member in pairs(squad.members) do
		WarBots.botToSquad[botId] = nil
		local bot = member.creature
		if bot then
			usedNames[bot:getName()] = nil
			bot:remove()
		end
	end
	WarBots.squads[squadId] = nil
end

function WarBots.despawnAll()
	for squadId, _ in pairs(WarBots.squads) do
		WarBots.removeSquad(squadId)
	end
	WarBots.activeCityKey = nil
end

-- keeps the squad count proportional to real players online (1 squad per playersPerSquad)
function WarBots.syncSquads(cityKey)
	if not WarBots.enabled then
		return
	end
	WarBots.activeCityKey = cityKey
	local online = 0
	for _, p in ipairs(Game.getPlayers()) do
		if not p:isBot() then
			online = online + 1
		end
	end
	local desired = math.min(math.ceil(online / config.playersPerSquad), config.maxSquadsPerMap)
	local current = 0
	for _, squad in pairs(WarBots.squads) do
		if squad.city == cityKey then
			current = current + 1
		end
	end
	while current < desired do
		WarBots.spawnSquad(cityKey)
		current = current + 1
	end
end

function WarBots.onBotDied(bot)
	local squadId = WarBots.botToSquad[bot:getId()]
	if not squadId then
		return
	end
	local squad = WarBots.squads[squadId]
	WarBots.botToSquad[bot:getId()] = nil
	usedNames[bot:getName()] = nil
	if not squad then
		return
	end
	squad.members[bot:getId()] = nil
	if next(squad.members) == nil then
		WarBots.squads[squadId] = nil
		logger.info(string.format("[WarBots] squad %d wiped, respawning in %ds", squadId, config.respawnDelaySec))
		addEvent(function()
			if WarBots.enabled then
				WarBots.spawnSquad(squad.city)
			end
		end, config.respawnDelaySec * 1000)
	end
end

local function validTarget(bot, target)
	if not target then
		return false
	end
	if target:isRemoved() then
		return false
	end
	if target:getHealth() <= 0 then
		return false
	end
	if target:getZoneType() == ZONE_PROTECTION then
		return false
	end
	if bot and not hasLOS(bot, target:getPosition()) then
		return false
	end
	return true
end

-- enemies are: real players (not god) and bots of OTHER squads; never own squadmates
local function isEnemy(creature, bot, mySquadId)
	if not creature:isPlayer() then
		return false
	end
	if creature:getId() == bot:getId() then
		return false
	end
	if creature:isRemoved() then
		return false
	end
	if creature:getGroup() and creature:getGroup():getAccess() then
		return false
	end
	if creature:getZoneType() == ZONE_PROTECTION then
		return false
	end
	if not hasLOS(bot, creature:getPosition()) then
		return false
	end
	if creature:isBot() then
		local otherSquad = WarBots.botToSquad[creature:getId()]
		return otherSquad ~= nil and otherSquad ~= mySquadId
	end
	return true
end

local function squadMemberWithLowestHp(squad, bot)
	local best, bestPct = nil, config.healHpPercent
	for _, member in pairs(squad.members) do
		local ally = member.creature
		if ally and ally:getMaxHealth() > 0 then
			local pct = ally:getHealth() * 100 / ally:getMaxHealth()
			if pct < bestPct then
				best, bestPct = ally, pct
			end
		end
	end
	return best
end

local function findEnemyNear(bot, squad)
	local pos = bot:getPosition()
	local spectators = Game.getSpectators(pos, false, true, 0, config.aggroRangeX, 0, config.aggroRangeY)
	local best, bestScore = nil, nil
	for _, spec in ipairs(spectators) do
		if isEnemy(spec, bot, squad.id) then
			local hpPct = spec:getMaxHealth() > 0 and (spec:getHealth() * 100 / spec:getMaxHealth()) or 100
			local d = dist(pos, spec:getPosition())
			local score = hpPct + d * 2
			if not bestScore or score < bestScore then
				best, bestScore = spec, score
			end
		end
	end
	return best
end

local EK_ROTATION = { "exori gran ico", "exori gran", "exori", "exori min" }
local RP_ROTATION = { "exori gran con", "exori con", "exori san" }
local MAGE_ROTATION = { [5] = { "exevo gran mas flam", "exori max frigo" }, [6] = { "exevo gran mas frigo", "exori max frigo" } }
local MAGE_UES = { [5] = { "exevo gran mas flam", "exevo gran mas vis" }, [6] = { "exevo gran mas frigo", "exevo mas san" } }

-- surround formation: blockers take the adjacent ring, ranged/mages the outer ring
local INNER_RING = { {0,-1},{1,0},{0,1},{-1,0},{1,-1},{1,1},{-1,1},{-1,-1} }
local OUTER_RING = { {0,-2},{2,0},{0,2},{-2,0},{2,-2},{2,2},{-2,2},{-2,-2},{0,-3},{3,0},{0,3},{-3,0} }

-- everyone surrounds the target: knights claim the inner ring first, the rest
-- fills the remaining inner slots, overflow goes to the outer ring
local function assignRingSlots(squad)
	local inner, outer = 1, 1
	local function slot(m)
		if inner <= #INNER_RING then
			m.ringOffset = INNER_RING[inner]
			inner = inner + 1
		else
			m.ringOffset = OUTER_RING[((outer - 1) % #OUTER_RING) + 1]
			outer = outer + 1
		end
	end
	for _, m in pairs(squad.members) do
		if m.role == "ek" then
			slot(m)
		end
	end
	for _, m in pairs(squad.members) do
		if m.role ~= "ek" then
			slot(m)
		end
	end
end

local function dirDiagTowards(from, to)
	local dx = to.x - from.x
	local dy = to.y - from.y
	if dx > 0 and dy > 0 then return DIRECTION_SOUTHEAST end
	if dx > 0 and dy < 0 then return DIRECTION_NORTHEAST end
	if dx < 0 and dy > 0 then return DIRECTION_SOUTHWEST end
	if dx < 0 and dy < 0 then return DIRECTION_NORTHWEST end
	if dx > 0 then return DIRECTION_EAST end
	if dx < 0 then return DIRECTION_WEST end
	if dy > 0 then return DIRECTION_SOUTH end
	return DIRECTION_NORTH
end

local function cast(bot, words)
	return Game.playerSaySpell(bot, words)
end

-- temp debug: dump mage weapon/target state
local function dbgState(bot, member, target, d)
	if member.role ~= "ms" and member.role ~= "ed" then
		return
	end
	local wl = bot:getSlotItem(CONST_SLOT_LEFT)
	local wr = bot:getSlotItem(CONST_SLOT_RIGHT)
	local wandId = member.vocation == 6 and 30399 or 30400
	logger.warn(("[WarBots DBG] %s role=%s left=%s right=%s wandInBp=%s voc=%d lv=%d d=%d tgt=%s sd=%s mana=%d"):format(
		bot:getName(), member.role, wl and wl:getId() or "none", wr and wr:getId() or "none",
		bot:getItemById(wandId, true) and "y" or "n",
		member.vocation or -1, bot:getLevel(), d,
		target and target:getName() or "nil", findRune(bot, config.sdRune) and "y" or "n",
		bot:getMana()))
end

local function botCombat(bot, member, squad, target, now)
	local myPos = bot:getPosition()
	local targetPos = target:getPosition()
	local d = dist(myPos, targetPos)

	bot:setTarget(target)

	-- movement: far -> engine chase; close -> step onto the assigned ring tile to
	-- spread the surround instead of piling on the same approach tile
	-- EKs keep chasing until they are right next to the target so melee hits land
	local off = member.ringOffset or { 0, 0 }
	-- chase until the assigned ring slot is reachable: inner slots -> adjacent,
	-- outer slots -> their ring distance
	local chaseDist = math.max(math.abs(off[1]), math.abs(off[2]))
	if member.role == "ek" then
		chaseDist = math.min(chaseDist, 1)
	else
		chaseDist = math.min(chaseDist, 4)
	end
	chaseDist = math.max(chaseDist, 1)
	local ringPos = Position(targetPos.x + off[1], targetPos.y + off[2], targetPos.z)
	local dRing = dist(myPos, ringPos)
	if d > chaseDist then
		-- out of attack range: engine chase at walk speed
		if bot:getFollowCreature() ~= target then
			bot:setFollowCreature(target)
		end
	elseif dRing > 0 then
		-- in range but off the assigned ring tile: step onto it to surround the target
		if bot:getFollowCreature() then
			bot:setFollowCreature(nil)
		end
		bot:move(dirDiagTowards(myPos, ringPos))
	elseif bot:getFollowCreature() then
		bot:setFollowCreature(nil)
	end

	-- haste: recast when paralyzed (cures it) or when it wore off; runs before
	-- the cast gate so a paralyzed bot never waits to recover speed
	local hasteSpell = member.role == "ek" and "utani tempo hur" or member.role == "rp" and "utani hur" or "utani gran hur"
	if bot:hasCondition(CONDITION_PARALYZE) or not bot:hasCondition(CONDITION_HASTE) then
		cast(bot, hasteSpell)
	end

	if member.nextCastAt > now then
		return
	end

	-- self sustain: pk-style heal/potion thresholds per role
	local hp, mp = hpPct(bot), manaPct(bot)
	if member.role == "rp" then
		if hp <= 40 and usePotionOnSelf(bot, config.potions.ultSpirit) then
			member.nextCastAt = now + 1
			return
		end
		if mp <= 40 and usePotionOnSelf(bot, config.potions.greatMana) then
			member.nextCastAt = now + 1
			return
		end
		if hp <= 80 then
			cast(bot, "exura gran san")
			member.nextCastAt = now + math.random(config.castCooldownMinSec, config.castCooldownMaxSec)
			return
		end
	elseif member.role == "ek" then
		if hp <= 50 and usePotionOnSelf(bot, config.potions.supreme) then
			member.nextCastAt = now + 1
			return
		end
		if mp <= 50 and usePotionOnSelf(bot, config.potions.greatMana) then
			member.nextCastAt = now + 1
			return
		end
		if hp <= 90 then
			cast(bot, "exura ico")
			member.nextCastAt = now + math.random(config.castCooldownMinSec, config.castCooldownMaxSec)
			return
		end
	else -- ms / ed
		if mp <= 70 and usePotionOnSelf(bot, config.potions.ultMana) then
			member.nextCastAt = now + 1
			return
		end
		if hp <= 35 and (member.utamoAt or 0) <= now then
			member.utamoAt = now + 5
			cast(bot, "utamo vita")
			member.nextCastAt = now + 1
			return
		end
		if hp <= 90 then
			cast(bot, bot:getLevel() >= 300 and "exura max vita" or "exura vita")
			member.nextCastAt = now + math.random(config.castCooldownMinSec, config.castCooldownMaxSec)
			return
		end
	end

	-- support: heal lowest ally first (sio friend)
	local ally = squadMemberWithLowestHp(squad, bot)
	if ally and ally ~= bot then
		Game.playerSaySpell(bot, 'exura sio "' .. ally:getName() .. '"')
		member.nextCastAt = now + math.random(config.castCooldownMinSec, config.castCooldownMaxSec)
		return
	end

	-- target is running: druids prioritize paralyze immediately
	local targetRunning = (squad.targetRunningUntil or 0) > now
	if member.role == "ed" and targetRunning and d <= 7 then
		if useRuneOnTarget(bot, config.paralyzeRune, target) then
			member.nextCastAt = now + math.random(config.castCooldownMinSec, config.castCooldownMaxSec)
			return
		end
	end

	-- paralyze on close targets (ed/rp/mages)
	if (member.role == "ed" or member.role == "rp" or member.role == "ms") and d <= 4 and math.random() < 0.5 then
		if useRuneOnTarget(bot, config.paralyzeRune, target) then
			member.nextCastAt = now + math.random(config.castCooldownMinSec, config.castCooldownMaxSec)
			return
		end
	end

	-- magic wall: when the target runs, wall the tiles right ahead of its
	-- movement direction; otherwise wall the escape side (opposite the squad centroid)
	if (member.role == "ed" or member.role == "ms") and d <= 5 and math.random() < (targetRunning and 0.7 or 0.4) then
		local wallTiles = {}
		if targetRunning and squad.targetMoveDir and (squad.targetMoveDir.x ~= 0 or squad.targetMoveDir.y ~= 0) then
			local md = squad.targetMoveDir
			table.insert(wallTiles, Position(targetPos.x + md.x, targetPos.y + md.y, targetPos.z))
			table.insert(wallTiles, Position(targetPos.x + md.x * 2, targetPos.y + md.y * 2, targetPos.z))
		else
			local cx, cy, n = 0, 0, 0
			for _, m in pairs(squad.members) do
				if m.creature then
					local p = m.creature:getPosition()
					cx, cy, n = cx + p.x, cy + p.y, n + 1
				end
			end
			if n > 0 then
				cx, cy = cx / n, cy / n
				local ex = targetPos.x - cx
				local ey = targetPos.y - cy
				table.insert(wallTiles, Position(targetPos.x + (ex > 0.5 and 1 or ex < -0.5 and -1 or 0),
					targetPos.y + (ey > 0.5 and 1 or ey < -0.5 and -1 or 0), targetPos.z))
			end
		end
		for _, wallPos in ipairs(wallTiles) do
			local tile = Tile(wallPos)
			if tile and tile:isWalkable(false, false, false, false, true) and tile:getCreatureCount() == 0 then
				if useRuneOnPos(bot, config.mwallRune, wallPos) then
					member.nextCastAt = now + math.random(config.castCooldownMinSec, config.castCooldownMaxSec)
					return
				end
			end
		end
	end

	-- synchronized UE combo for mages (skipped when a squadmate is inside the UE radius)
	local allyInUeRange = false
	for _, m in pairs(squad.members) do
		local allyC = m.creature
		if allyC and allyC:getId() ~= bot:getId() and dist(myPos, allyC:getPosition()) <= 3 then
			allyInUeRange = true
			break
		end
	end
	if not allyInUeRange and (member.role == "ms" or member.role == "ed") and now >= squad.nextComboAt then
		squad.comboActiveUntil = now + 2
		squad.nextComboAt = now + config.comboIntervalSec
	end
	if not allyInUeRange and (member.role == "ms" or member.role == "ed") and now < squad.comboActiveUntil and member.comboDoneAt < squad.nextComboAt - config.comboIntervalSec + 10 then
		local ues = MAGE_UES[member.vocation] or MAGE_UES[5]
		cast(bot, ues[math.random(#ues)])
		member.comboDoneAt = now
		member.nextCastAt = now + math.random(config.castCooldownMinSec, config.castCooldownMaxSec)
		return
	end

	-- role attack behavior
	if member.role == "ek" then
		if d <= 1 then
			-- let the weapon swing through half the time (spells share the action slot)
			if math.random() < 0.5 then
				return
			end
			cast(bot, EK_ROTATION[math.random(#EK_ROTATION)])
		else
			return -- out of reach: keep chasing, let the weapon fire when in range
		end
	elseif member.role == "rp" then
		if d <= 5 and math.random() < 0.4 then
			if useRuneOnTarget(bot, config.sdRune, target) then
				member.nextCastAt = now + math.random(config.castCooldownMinSec, config.castCooldownMaxSec)
				return
			end
		end
		-- alternate between weapon shots and strike spells
		if math.random() < 0.5 then
			return
		end
		cast(bot, RP_ROTATION[math.random(#RP_ROTATION)])
	elseif member.role == "ms" or member.role == "ed" then
		-- strict priority with real cooldown tracking: UE (40s) -> exori max (30s) -> SD rune;
		-- wand swings fill the gaps between casts
		member.spellCd = member.spellCd or {}
		local ue = member.vocation == 6 and "exevo gran mas frigo" or "exevo gran mas flam"
		if d <= 8 and now >= (member.spellCd.ue or 0) then
			if cast(bot, ue) then
				member.spellCd.ue = now + 40
			else
				member.spellCd.ue = now + 2
			end
			member.nextCastAt = now + 1
			return
		end
		if d <= 7 and now >= (member.spellCd.strike or 0) then
			if cast(bot, "exori max frigo") then
				member.spellCd.strike = now + 30
			else
				member.spellCd.strike = now + 2
			end
			member.nextCastAt = now + 1
			return
		end
		if d <= 7 then
			useRuneOnTarget(bot, config.sdRune, target)
			member.nextCastAt = now + 1
			return
		end
		return -- out of rune range: keep chasing and let the wand fire
	end

	member.nextCastAt = now + math.random(config.castCooldownMinSec, config.castCooldownMaxSec)
end

local function botPatrol(bot, member, squad)
	local leader = squad.members[squad.leaderId] and squad.members[squad.leaderId].creature or nil

	if leader and leader:getId() ~= bot:getId() then
		-- followers trail the leader like a real team
		if bot:getFollowCreature() ~= leader then
			bot:setFollowCreature(leader)
		end
		return
	end

	-- leader walks the waypoint loop (or roams around the spawn point when
	-- no waypoints are configured so squads always patrol visibly)
	local myPos = bot:getPosition()
	local wp = squad.waypoints[squad.wpIndex]
	if wp and dist(myPos, wp) <= 2 then
		squad.wpIndex = (squad.wpIndex % #squad.waypoints) + 1
		wp = squad.waypoints[squad.wpIndex]
	end
	if not wp then
		local p = squad.spawnPos
		wp = Position(p.x + math.random(-8, 8), p.y + math.random(-8, 8), p.z)
		squad.waypoints = { wp }
		squad.wpIndex = 1
	end
	bot:move(dirDiagTowards(myPos, wp))
end

function WarBots.think(bot)
	if not WarBots.enabled then
		return true
	end
	local squadId = WarBots.botToSquad[bot:getId()]
	local squad = squadId and WarBots.squads[squadId] or nil
	if not squad then
		return true
	end
	local member = squad.members[bot:getId()]
	if not member then
		return true
	end
	local voc = bot:getVocation()
	member.vocation = voc and voc:getId() or nil

	local now = os.time()

	-- resolve squad leader (fallback: first alive member)
	local leaderId = squad.leaderId
	if not leaderId or not squad.members[leaderId] then
		for mId, _ in pairs(squad.members) do
			leaderId = mId
			break
		end
		squad.leaderId = leaderId
	end
	local isLeader = (bot:getId() == leaderId)

	-- validate shared target
	local target = squad.target
	if target and (not validTarget(bot, target) or dist(bot:getPosition(), target:getPosition()) > 30) then
		squad.target = nil
		target = nil
		bot:setTarget(nil)
		bot:setFollowCreature(nil)
	end

	-- only the leader scans and designates the squad target; followers chase it
	if not target and isLeader then
		target = findEnemyNear(bot, squad)
		if target then
			squad.target = target
			assignRingSlots(squad)
		end
	end

	-- track target movement: running = moved >=2 sqm in under 2s; used to
	-- prioritize paralyze and magic-wall the escape lane ahead of the target
	if target then
		local tp = target:getPosition()
		if squad.lastTargetPos and dist(tp, squad.lastTargetPos) >= 2 and (now - (squad.lastTargetAt or 0)) < 2 then
			squad.targetRunningUntil = now + 2
			squad.targetMoveDir = {
				x = tp.x > squad.lastTargetPos.x and 1 or tp.x < squad.lastTargetPos.x and -1 or 0,
				y = tp.y > squad.lastTargetPos.y and 1 or tp.y < squad.lastTargetPos.y and -1 or 0,
			}
		end
		squad.lastTargetPos = tp
		squad.lastTargetAt = now
	end

	if target then
		botCombat(bot, member, squad, target, now)
	else
		botPatrol(bot, member, squad)
	end
	return true
end

-- events
local thinkEvent = CreatureEvent("WariziBotThink")
function thinkEvent.onThink(creature)
	WarBots.think(creature)
	return true
end
thinkEvent:type("think")
thinkEvent:register()

local deathEvent = CreatureEvent("WariziBotDeath")
function deathEvent.onDeath(player, corpse, lastHit, mostDamage, lastHitUnjust, mostDamageUnjust)
	WarBots.onBotDied(player)
	return true
end
deathEvent:type("death")
deathEvent:register()

-- preparedeath fires on the killing blow even in zones where no corpse drops,
-- guaranteeing squad bookkeeping/respawn in every death scenario
local prepareDeathEvent = CreatureEvent("WariziBotPrepareDeath")
function prepareDeathEvent.onPrepareDeath(creature, killer)
	WarBots.onBotDied(creature)
	return true
end
prepareDeathEvent:type("preparedeath")
prepareDeathEvent:register()

-- admin talkaction: /botsquad spawn|stop|status|wipe
local botCmd = TalkAction("/botsquad")
function botCmd.onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	local args = (param or ""):split("%s+")
	local cmd = args[1] or "status"
	if cmd == "spawn" then
		local city = args[2]
		local size = tonumber(args[3])
		if not city or city == "" then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Usage: /botsquad spawn <carlin|venore> [size]")
			return true
		end
		local squad = WarBots.spawnSquad(city, size)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Squad %d spawned (%d bots) in %s.", squad.id, size or config.squadMinSize, city))
	elseif cmd == "stop" or cmd == "wipe" then
		WarBots.despawnAll()
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "All war bots removed.")
	elseif cmd == "status" then
		local total = 0
		for _, s in pairs(WarBots.squads) do
			local n = 0
			for _ in pairs(s.members) do
				n = n + 1
			end
			total = total + n
		end
		local squads = 0
		for _ in pairs(WarBots.squads) do
			squads = squads + 1
		end
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("War bots: %d squads, %d bots. Enabled: %s", squads, total, tostring(WarBots.enabled)))
	elseif cmd == "on" then
		WarBots.enabled = true
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "War bots enabled.")
	elseif cmd == "off" then
		WarBots.enabled = false
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "War bots disabled.")
	end
	return true
end
botCmd:separator(" ")
botCmd:groupType("god")
botCmd:register()

-- periodic check: squads scale with the number of real players online
local syncEvent = GlobalEvent("WarBotsSync")
function syncEvent.onThink(interval)
	if WarBots.enabled and WarBots.activeCityKey then
		WarBots.syncSquads(WarBots.activeCityKey)
	end
	return true
end
syncEvent:interval(60000)
syncEvent:register()

logger.info("[WarBots] loaded")

local dbgSpawn = GlobalEvent("WarBotsDebugSpawn")
dbgSpawn:interval(20000)
function dbgSpawn.onThink()
	local n = 0
	for _ in pairs(WarBots.squads or {}) do n = n + 1 end
	if n < 2 then
		WarBots.spawnSquad("venore", 4, Position(771, 1173, 6))
		WarBots.spawnSquad("venore", 4, Position(777, 1173, 6))
		return true
	end
	for _, squad in pairs(WarBots.squads) do
		for _, m in pairs(squad.members) do
			local c = m.creature
			if c and c:getTarget() then
				local d = dist(c:getPosition(), c:getTarget():getPosition())
				dbgState(c, m, c:getTarget(), d)
			end
		end
	end
	return true
end
dbgSpawn:register()
