local config = {
	boss = {
		name = "The Primal Menace",
		position = Position(1128, 996, 11),
	},
	requiredLevel = 0,
	minPlayers = 1,
	playerPositions = {
		{ pos = Position(1148, 993, 11), teleport = Position(1139, 996, 11) },
		{ pos = Position(1148, 994, 11), teleport = Position(1139, 996, 11) },
		{ pos = Position(1148, 995, 11), teleport = Position(1139, 996, 11) },
		{ pos = Position(1148, 996, 11), teleport = Position(1139, 996, 11) },
		{ pos = Position(1148, 997, 11), teleport = Position(1139, 996, 11) },
	},
	specPos = {
		from = Position(1124, 991, 11),
		to = Position(1142, 1001, 11),
	},
	exit = Position(1049, 983, 11),
	timeAfterKill = 3,
}

local lever = BossLever(config)
lever:aid(60012)
lever:register()
