local mType = Game.createMonsterType("Vemiath")
local monster = {}

monster.description = "Vemiath"
monster.experience = 3250000
monster.outfit = {
	lookType = 1668,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0,
}

monster.events = {
	"SanguineBossDeath",
}

monster.bosstiary = {
	bossRaceId = 2365,
	bossRace = RARITY_ARCHFOE,
}

monster.health = 350000
monster.maxHealth = 350000
monster.race = "undead"
monster.corpse = 44021
monster.speed = 100
monster.manaCost = 0

monster.changeTarget = {
	interval = 10000,
	chance = 10,
}

monster.strategiesTarget = {
	nearest = 100,
	health = 0,
	damage = 0,
	random = 0,
}

monster.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	pushable = false,
	rewardBoss = true,
	illusionable = false,
	canPushItems = true,
	canPushCreatures = true,
	staticAttackChance = 98,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
}

monster.light = {
	level = 0,
	color = 0,
}

monster.summon = {}

monster.voices = {
	interval = 5000,
	chance = 10,
	{ text = "The light... that... drains!", yell = false },
	{ text = "RAAAR!", yell = false },
	{ text = "WILL ... PUNISH ... YOU!", yell = false },
	{ text = "Darkness ... devours!", yell = false },
}

monster.summon = {}

monster.loot = {
	{ id = 43895, chance = 360, unique = true }, ---bag you covet
	{ name = "crystal coin", chance = 28852, maxCount = 99 },
	{ name = "ultimate mana potion", chance = 21337, maxCount = 211 },
	{ name = "giant emerald", chance = 26423, maxCount = 1 },
	{ name = "supreme health potion", chance = 44385, maxCount = 154 },
	{ name = "yellow gem", chance = 33000, maxCount = 4 },
	{ name = "berserk potion", chance = 28000, maxCount = 37 },
	{ name = "blue gem", chance = 33000, maxCount = 5 },
	{ name = "green gem", chance = 28000, maxCount = 4 },
	{ name = "bullseye potion", chance = 16530, maxCount = 22 },
	{ name = "mastermind potion", chance = 22700, maxCount = 31 },
	{ name = "ultimate spirit potion", chance = 19216, maxCount = 203 },
	{ name = "giant topaz", chance = 11191, maxCount = 1 },
	{ name = "giant amethyst", chance = 18527, maxCount = 1 },
	{ name = "gold ingot", chance = 20866, maxCount = 1 },
	{ id = 3039, chance = 18945, maxCount = 4 }, -- red gem
	{ name = "dragon figurine", chance = 19502, maxCount = 1 },
	{ name = "raw watermelon tourmaline", chance = 19302, maxCount = 1 },
	{ name = "vemiath's infused basalt", chance = 28000, maxCount = 1 },
	{ name = "violet gem", chance = 11100, maxCount = 3 },
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100, minDamage = -1300, maxDamage = -1600 },
	{ name = "chagorzring", interval = 2000, chance = 25, minDamage = -3200, maxDamage = -4000, target = false },
	{ name = "combat", interval = 2000, chance = 20, type = COMBAT_MANADRAIN, minDamage = -100, maxDamage = -500, range = 7, radius = 6, effect = 18, target = true },
	{ name = "combat", interval = 2000, chance = 20, type = COMBAT_EARTHDAMAGE, minDamage = -100, maxDamage = -500, radius = 6, effect = 18, target = false },
	{ name = "combat", interval = 2000, chance = 20, type = COMBAT_MANADRAIN, minDamage = -100, maxDamage = -500, radius = 6, effect = 32, target = false },
	{ name = "speed", interval = 2000, chance = 20, speedChange = -1600, radius = 7, effect = 20, target = false, duration = 20000 },
	{ name = "combat", interval = 2000, chance = 25, type = COMBAT_DEATHDAMAGE, minDamage = -1500, maxDamage = -2000, length = 8, spread = 0, effect = 221, target = false },
	{ name = "combat", interval = 2000, chance = 25, type = COMBAT_DEATHDAMAGE, minDamage = -500, maxDamage = -1000, length = 8, spread = 0, effect = 18, target = false },
}

monster.defenses = {
	defense = 305,
	armor = 305,
	mitigation = 7.16,
	{ name = "combat", interval = 3000, chance = 15, type = COMBAT_HEALING, minDamage = 4700, maxDamage = 6500, effect = 249, target = false },
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 15 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 15 },
	{ type = COMBAT_EARTHDAMAGE, percent = 15 },
	{ type = COMBAT_FIREDAMAGE, percent = 15 },
	{ type = COMBAT_LIFEDRAIN, percent = 0 },
	{ type = COMBAT_MANADRAIN, percent = 0 },
	{ type = COMBAT_DROWNDAMAGE, percent = 0 },
	{ type = COMBAT_ICEDAMAGE, percent = 15 },
	{ type = COMBAT_HOLYDAMAGE, percent = 15 },
	{ type = COMBAT_DEATHDAMAGE, percent = 15 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = false },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = false },
}

mType.onAppear = function(monster, creature)
	if monster:getType():isRewardBoss() then
		monster:setReward(true)
	end
end


mType:register(monster)
