local config = {
	boss = {
		name = "Murcion",
		position = Position(1095, 918, 11),
	},
	requiredLevel = 0,
	minPlayers = 1,
	playerPositions = {
		{ pos = Position(1114, 915, 11), teleport = Position(1104, 918, 11) },
		{ pos = Position(1114, 916, 11), teleport = Position(1104, 918, 11) },
		{ pos = Position(1114, 917, 11), teleport = Position(1104, 918, 11) },
		{ pos = Position(1114, 918, 11), teleport = Position(1104, 918, 11) },
		{ pos = Position(1114, 919, 11), teleport = Position(1104, 918, 11) },
	},
	monsters = {
		{ name = "Mushroom", pos = Position(1092, 916, 11) },
		{ name = "Mushroom", pos = Position(1092, 918, 11) },
		{ name = "Mushroom", pos = Position(1092, 920, 11) },
	},
	specPos = {
		from = Position(1090, 913, 11),
		to = Position(1108, 923, 11),
	},
	exit = Position(1049, 983, 11),
	timeAfterKill = 3,
}

local lever = BossLever(config)
lever:aid(60010)
lever:register()
