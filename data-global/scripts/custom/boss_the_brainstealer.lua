local config = {
	boss = {
		name = "The Brainstealer",
		position = Position(1129, 970, 11),
	},
	requiredLevel = 0,
	minPlayers = 1,
	playerPositions = {
		{ pos = Position(1148, 967, 11), teleport = Position(1139, 970, 11) },
		{ pos = Position(1148, 968, 11), teleport = Position(1139, 970, 11) },
		{ pos = Position(1148, 969, 11), teleport = Position(1139, 970, 11) },
		{ pos = Position(1148, 970, 11), teleport = Position(1139, 970, 11) },
		{ pos = Position(1148, 971, 11), teleport = Position(1139, 970, 11) },
	},
	specPos = {
		from = Position(1124, 965, 11),
		to = Position(1142, 975, 11),
	},
	exit = Position(1049, 983, 11),
	timeAfterKill = 3,
}

local lever = BossLever(config)
lever:aid(60014)
lever:register()
