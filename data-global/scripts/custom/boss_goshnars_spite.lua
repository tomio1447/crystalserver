local config = {
	boss = {
		name = "Goshnar's Spite",
		position = Position(1093, 1009, 11),
	},
	requiredLevel = 0,
	minPlayers = 1,
	playerPositions = {
		{ pos = Position(1113, 1006, 11), teleport = Position(1103, 1009, 11) },
		{ pos = Position(1113, 1007, 11), teleport = Position(1103, 1009, 11) },
		{ pos = Position(1113, 1008, 11), teleport = Position(1103, 1009, 11) },
		{ pos = Position(1113, 1009, 11), teleport = Position(1103, 1009, 11) },
		{ pos = Position(1113, 1010, 11), teleport = Position(1103, 1009, 11) },
	},
	monsters = {
		{ name = "Weeping Soul", pos = Position(1091, 1007, 11) },
		{ name = "Weeping Soul", pos = Position(1091, 1011, 11) },
	},
	specPos = {
		from = Position(1089, 1004, 11),
		to = Position(1107, 1014, 11),
	},
	exit = Position(1049, 983, 11),
	timeAfterKill = 3,
}

local lever = BossLever(config)
lever:aid(60003)
lever:register()
