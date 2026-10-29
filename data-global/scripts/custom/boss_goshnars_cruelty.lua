local config = {
	boss = {
		name = "Goshnar's Cruelty",
		position = Position(1061, 995, 11),
	},
	requiredLevel = 0,
	minPlayers = 1,
	playerPositions = {
		{ pos = Position(1082, 994, 11), teleport = Position(1072, 994, 11) },
		{ pos = Position(1082, 995, 11), teleport = Position(1072, 994, 11) },
		{ pos = Position(1082, 996, 11), teleport = Position(1072, 994, 11) },
		{ pos = Position(1082, 997, 11), teleport = Position(1072, 994, 11) },
		{ pos = Position(1082, 998, 11), teleport = Position(1072, 994, 11) },
	},
	monsters = {
		{ name = "A Greedy Eye", pos = Position(1061, 991, 11) },
	},
	specPos = {
		from = Position(1058, 991, 11),
		to = Position(1076, 1001, 11),
	},
	exit = Position(1049, 983, 11),
	timeAfterKill = 3,
}

local lever = BossLever(config)
lever:aid(60001)
lever:register()
