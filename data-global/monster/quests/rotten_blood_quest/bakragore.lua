local mType = Game.createMonsterType("Bakragore")
local monster = {}

monster.description = "Bakragore"
monster.experience = 15000000
monster.outfit = {
	lookType = 1671,
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
	bossRaceId = 2367,
	bossRace = RARITY_NEMESIS,
}

monster.health = 660000
monster.maxHealth = 660000
monster.race = "undead"
monster.corpse = 44012
monster.speed = 100
monster.manaCost = 0

monster.changeTarget = {
	interval = 10000,
	chance = 20,
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
	{ text = "Light ... darkens!", yell = false },
	{ text = "Light .. the ... darkness!", yell = false },
	{ text = "Darkness ... is ... light!", yell = false },
	{ text = "WILL ... PUNISH ... YOU!", yell = false },
	{ text = "RAAAR!", yell = false },
}

monster.loot = {
	{ name = "crystal coin", chance = 28938, maxCount = 209 },
	{ name = "ultimate mana potion", chance = 21433, maxCount = 320 },
	{ name = "supreme health potion", chance = 50000, maxCount = 242 },
	{ name = "giant amethyst", chance = 34000, maxCount = 6 },
	{ name = "giant topaz", chance = 27570, maxCount = 6 },
	{ name = "ultimate spirit potion", chance = 48000, maxCount = 220 },
	{ name = "giant ruby", chance = 30570, maxCount = 7 },
	{ name = "giant sapphire", chance = 27570, maxCount = 6 },
	{ name = "mastermind potion", chance = 14310, maxCount = 79 },
	{ id = 3039, chance = 20570, maxCount = 30 }, -- red gem
	{ name = "Cobalt Ridge", chance = 25000, maxCount = 1 },
	{ name = "Dragon Figurine", chance = 25000, maxCount = 1 },
	{ name = "Fiery Tear", chance = 360, maxCount = 1 },
	{ name = "violet gem", chance = 20970, maxCount = 8 },
	{ name = "yellow gem", chance = 20970, maxCount = 9 },
	{ name = "figurine of bakragore", chance = 7970 },
	{ name = "bakragore's amalgamation", chance = 7100 },
	{ name = "spiritual horseshoe", chance = 360 },
	{ id = 39038, chance = 360, maxCount = 1 }, -- royal almandine
	{ id = 43946, chance = 180, maxCount = 1 }, -- scroll 1
	{ id = 43947, chance = 180, maxCount = 1 }, -- scroll 2
	{ id = 43950, chance = 180, maxCount = 1 }, -- scroll 5
	{ id = 43895, chance = 360 }, ---bag you covet
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100, minDamage = -1100, maxDamage = -3000 },
	{ name = "speed", interval = 2000, chance = 27, speedChange = -1600, radius = 7, effect = CONST_ME_SOUND_RED, target = false, duration = 10000 },
	{ name = "murcionring", interval = 2000, chance = 17, minDamage = -1200, maxDamage = -3000, target = false },
	{ name = "chagorzring", interval = 2000, chance = 17, minDamage = -1200, maxDamage = -3000, target = false },
	{ name = "combat", interval = 2000, chance = 16, type = COMBAT_DEATHDAMAGE, minDamage = -1100, maxDamage = -1250, radius = 3, effect = CONST_ME_GROUNDSHAKER, target = false },
	{ name = "combat", interval = 2000, chance = 20, type = COMBAT_EARTHDAMAGE, minDamage = -2100, maxDamage = -2650, radius = 6, effect = CONST_ME_SMALLPLANTS, target = false },
	{ name = "combat", interval = 2000, chance = 17, type = COMBAT_DEATHDAMAGE, minDamage = -2000, maxDamage = -2500, radius = 6, effect = CONST_ME_MORTAREA, target = false },
	{ name = "combat", interval = 2000, chance = 14, type = COMBAT_DEATHDAMAGE, minDamage = -2200, maxDamage = -2400, length = 8, spread = 0, effect = CONST_ME_MORTAREA, target = false },
	{ name = "combat", interval = 2000, chance = 25, type = COMBAT_LIFEDRAIN, minDamage = -1500, maxDamage = -2450, radius = 7, effect = CONST_ME_DRAWBLOOD, target = false },
	{ name = "combat", interval = 2000, chance = 18, type = COMBAT_MANADRAIN, minDamage = -2200, maxDamage = -2450, radius = 7, effect = CONST_ME_STUN, target = false },
}

monster.defenses = {
	defense = 305,
	armor = 305,
	mitigation = 8.16,
	{ name = "combat", interval = 3000, chance = 10, type = COMBAT_HEALING, minDamage = 1700, maxDamage = 4500, effect = 249, target = false },
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 20 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 5 },
	{ type = COMBAT_EARTHDAMAGE, percent = 5 },
	{ type = COMBAT_FIREDAMAGE, percent = 5 },
	{ type = COMBAT_LIFEDRAIN, percent = 0 },
	{ type = COMBAT_MANADRAIN, percent = 0 },
	{ type = COMBAT_DROWNDAMAGE, percent = 0 },
	{ type = COMBAT_ICEDAMAGE, percent = 5 },
	{ type = COMBAT_HOLYDAMAGE, percent = 10 },
	{ type = COMBAT_DEATHDAMAGE, percent = 10 },
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
