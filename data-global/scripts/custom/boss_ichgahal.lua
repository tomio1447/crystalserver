local config = {
	boss = {
		name = "Ichgahal",
		position = Position(1094, 931, 11),
	},
	requiredLevel = 0,
	minPlayers = 1,
	playerPositions = {
		{ pos = Position(1114, 928, 11), teleport = Position(1104, 931, 11) },
		{ pos = Position(1114, 929, 11), teleport = Position(1104, 931, 11) },
		{ pos = Position(1114, 930, 11), teleport = Position(1104, 931, 11) },
		{ pos = Position(1114, 931, 11), teleport = Position(1104, 931, 11) },
		{ pos = Position(1114, 932, 11), teleport = Position(1104, 931, 11) },
	},
	monsters = {
		{ name = "Mushroom", pos = Position(1091, 929, 11) },
		{ name = "Mushroom", pos = Position(1091, 931, 11) },
		{ name = "Mushroom", pos = Position(1091, 933, 11) },
	},
	specPos = {
		from = Position(1090, 926, 11),
		to = Position(1108, 936, 11),
	},
	exit = Position(1049, 983, 11),
	timeAfterKill = 3,
}

local lever = BossLever(config)
lever:aid(60009)
lever:register()
