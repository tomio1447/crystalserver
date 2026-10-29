local config = {
	boss = {
		name = "Goshnar's Malice",
		position = Position(1093, 983, 11),
	},
	requiredLevel = 0,
	minPlayers = 1,
	playerPositions = {
		{ pos = Position(1113, 980, 11), teleport = Position(1103, 983, 11) },
		{ pos = Position(1113, 981, 11), teleport = Position(1103, 983, 11) },
		{ pos = Position(1113, 982, 11), teleport = Position(1103, 983, 11) },
		{ pos = Position(1113, 983, 11), teleport = Position(1103, 983, 11) },
		{ pos = Position(1113, 984, 11), teleport = Position(1103, 983, 11) },
	},
	monsters = {
		{ name = "Soul Cage", pos = Position(1091, 981, 11) },
		{ name = "Soul Cage", pos = Position(1091, 985, 11) },
	},
	specPos = {
		from = Position(1089, 978, 11),
		to = Position(1107, 988, 11),
	},
	exit = Position(1049, 983, 11),
	timeAfterKill = 3,
}

local lever = BossLever(config)
lever:aid(60005)
lever:register()
