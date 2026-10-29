local config = {
	boss = {
		name = "Goshnar's Greed",
		position = Position(1061, 1008, 11),
	},
	requiredLevel = 0,
	minPlayers = 1,
	playerPositions = {
		{ pos = Position(1082, 1007, 11), teleport = Position(1073, 1008, 11) },
		{ pos = Position(1082, 1008, 11), teleport = Position(1073, 1008, 11) },
		{ pos = Position(1082, 1009, 11), teleport = Position(1073, 1008, 11) },
		{ pos = Position(1082, 1010, 11), teleport = Position(1073, 1008, 11) },
		{ pos = Position(1082, 1011, 11), teleport = Position(1073, 1008, 11) },
	},
	monsters = {
		{ name = "Greedbeast", pos = Position(1059, 1008, 11) },
		{ name = "Soulsnatcher", pos = Position(1062, 1010, 11) },
		{ name = "Weak Soul", pos = Position(1065, 1008, 11) },
	},
	specPos = {
		from = Position(1057, 1004, 11),
		to = Position(1076, 1014, 11),
	},
	exit = Position(1049, 983, 11),
	timeAfterKill = 3,
}

local lever = BossLever(config)
lever:aid(60002)
lever:register()
