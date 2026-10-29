local mType = Game.createMonsterType("Chagorz")
local monster = {}

monster.description = "Chagorz"
monster.experience = 3250000
monster.outfit = {
	lookType = 1666,
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

monster.health = 350000
monster.maxHealth = 350000
monster.race = "undead"
monster.corpse = 44024
monster.speed = 100
monster.manaCost = 0

monster.changeTarget = {
	interval = 10000,
	chance = 10,
}

monster.bosstiary = {
	bossRaceId = 2366,
	bossRace = RARITY_ARCHFOE,
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
	staticAttackChance = 95,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
	pet = false,
}

monster.light = {
	level = 0,
	color = 0,
}

monster.summon = {}

monster.voices = {
	interval = 5000,
	chance = 10,
	{ text = "The ... light ... that ... drains!", yell = true },
	{ text = "Light ... that ... isn't!", yell = true },
	{ text = "WILL ... PUNISH ... YOU!", yell = true },
	{ text = "RAAAR!", yell = true },
	{ text = "Darkness ... devours!!", yell = true },
}

monster.loot = {
	{ id = 43895, chance = 360, unique = true }, ---bag you covet
	{ name = "berserk potion", chance = 22758, minCount = 24, maxCount = 31 },
	{ id = 3041, chance = 14702, minCount = 0, maxCount = 1 }, -- blue gem,
	{ name = "bullseye potion", chance = 13972, minCount = 21, maxCount = 23 },
	{ name = "crystal coin", chance = 28018, minCount = 0, maxCount = 89 },
	{ name = "darklight figurine", chance = 23164 },
	{ name = "giant topaz", chance = 55000, maxCount = 1 },
	{ name = "giant sapphire", chance = 45000, minCount = 1, maxCount = 3 },
	{ name = "gold ingot", chance = 18000, minCount = 1, maxCount = 1 },
	{ name = "green gem", chance = 9100, minCount = 1, maxCount = 1 },
	{ name = "mastermind potion", chance = 23945, minCount = 13, maxCount = 13 },
	{ name = "raw watermelon tourmaline", chance = 21876, minCount = 0, maxCount = 1 },
	{ id = 3039, chance = 22121, minCount = 1, maxCount = 29 }, -- red gem,
	{ name = "supreme health potion", chance = 22303, minCount = 24, maxCount = 164 },
	{ name = "unicorn figurine", chance = 23030 },
	{ name = "ultimate mana potion", chance = 22519, minCount = 9, maxCount = 100 },
	{ name = "ultimate spirit potion", chance = 55000, minCount = 16, maxCount = 198 },
	{ name = "violet gem", chance = 24963, minCount = 1, maxCount = 4 },
	{ name = "white gem", chance = 24927, minCount = 1, maxCount = 4 },
	{ name = "yellow gem", chance = 22940, minCount = 1, maxCount = 3 },
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
	{ name = "combat", interval = 3000, chance = 25, type = COMBAT_HEALING, minDamage = 4700, maxDamage = 6500, effect = 249, target = false },
}

monster.elements = {
	{ type = "COMBAT_PHYSICALDAMAGE", percent = 0 },
	{ type = "COMBAT_DEATHDAMAGE", percent = 0 },
	{ type = "COMBAT_HOLYDAMAGE", percent = 0 },
	{ type = "COMBAT_ICEDAMAGE", percent = 0 },
	{ type = "COMBAT_FIREDAMAGE", percent = 0 },
	{ type = "COMBAT_ENERGYDAMAGE", percent = 0 },
	{ type = "COMBAT_EARTHDAMAGE", percent = 10 },
	{ type = "COMBAT_LIFEDRAIN", percent = 0 },
	{ type = "COMBAT_MANADRAIN", percent = 0 },
	{ type = "COMBAT_DROWNDAMAGE", percent = 0 },
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
