local mType = Game.createMonsterType("Izkandar (Summer Blade)")
local monster = {}

monster.description = "izkandar"
monster.experience = 0
monster.outfit = {
	lookType = 1136,
	lookHead = 114,
	lookBody = 94,
	lookLegs = 3,
	lookFeet = 121,
	lookAddons = 0,
	lookMount = 0,
}

monster.raceId = 1733

monster.health = 5700
monster.maxHealth = 5700
monster.race = "undead"
monster.corpse = 51533
monster.speed = 130
monster.manaCost = 0

monster.changeTarget = {
	interval = 4000,
	chance = 0,
}

monster.strategiesTarget = {
	nearest = 70,
	health = 10,
	damage = 10,
	random = 10,
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
	canPushCreatures = false,
	staticAttackChance = 90,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
}

monster.loot = {
	{ name = "summerblade", chance = 100 },
}

mType:register(monster)

local mTypeWinter = Game.createMonsterType("Izkandar (Winters Blade)")
local monsterWinter = {}

monsterWinter.description = "izkandar"
monsterWinter.experience = 0
monsterWinter.outfit = {
	lookType = 1136,
	lookHead = 47,
	lookBody = 7,
	lookLegs = 0,
	lookFeet = 85,
	lookAddons = 0,
	lookMount = 0,
}

monsterWinter.raceId = 1731

monsterWinter.health = 5700
monsterWinter.maxHealth = 5700
monsterWinter.race = "undead"
monsterWinter.corpse = 51533
monsterWinter.speed = 130
monsterWinter.manaCost = 0

monsterWinter.changeTarget = {
	interval = 4000,
	chance = 0,
}

monsterWinter.strategiesTarget = {
	nearest = 70,
	health = 10,
	damage = 10,
	random = 10,
}

monsterWinter.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	pushable = false,
	rewardBoss = true,
	illusionable = false,
	canPushItems = true,
	canPushCreatures = false,
	staticAttackChance = 90,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
}

monsterWinter.loot = {
	{ name = "winterblade", chance = 100 },
}

mTypeWinter:register(monsterWinter)
