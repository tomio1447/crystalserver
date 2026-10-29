local config = {
	boss = {
		name = "Goshnar's Hatred",
		position = Position(1093, 996, 11),
	},
	requiredLevel = 0,
	minPlayers = 1,
	playerPositions = {
		{ pos = Position(1113, 993, 11), teleport = Position(1104, 996, 11) },
		{ pos = Position(1113, 994, 11), teleport = Position(1104, 996, 11) },
		{ pos = Position(1113, 995, 11), teleport = Position(1104, 996, 11) },
		{ pos = Position(1113, 996, 11), teleport = Position(1104, 996, 11) },
		{ pos = Position(1113, 997, 11), teleport = Position(1104, 996, 11) },
	},
	monsters = {
		{ name = "Ashes of Burning Hatred", pos = Position(1092, 996, 11) },
	},
	specPos = {
		from = Position(1089, 991, 11),
		to = Position(1107, 1001, 11),
	},
	exit = Position(1049, 983, 11),
	timeAfterKill = 3,
}

local lever = BossLever(config)
lever:aid(60004)
lever:register()
