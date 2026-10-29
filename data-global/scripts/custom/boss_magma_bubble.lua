local config = {
	boss = {
		name = "Magma Bubble",
		position = Position(1129, 983, 11),
	},
	requiredLevel = 0,
	minPlayers = 1,
	playerPositions = {
		{ pos = Position(1148, 980, 11), teleport = Position(1138, 983, 11) },
		{ pos = Position(1148, 981, 11), teleport = Position(1138, 983, 11) },
		{ pos = Position(1148, 982, 11), teleport = Position(1138, 983, 11) },
		{ pos = Position(1148, 983, 11), teleport = Position(1138, 983, 11) },
		{ pos = Position(1148, 984, 11), teleport = Position(1138, 983, 11) },
	},
	monsters = {
		{ name = "The End of Days", pos = Position(1126, 981, 11) },
		{ name = "The End of Days", pos = Position(1126, 985, 11) },
		{ name = "Unchained Fire", pos = Position(1132, 981, 11) },
		{ name = "Unchained Fire", pos = Position(1132, 985, 11) },
		{ name = "Magma Crystal", pos = Position(1129, 987, 11) },
	},
	specPos = {
		from = Position(1124, 978, 11),
		to = Position(1142, 988, 11),
	},
	exit = Position(1049, 983, 11),
	timeAfterKill = 3,
}

local lever = BossLever(config)
lever:aid(60013)
lever:register()
