local config = {
	boss = {
		name = "Vemiath",
		position = Position(1095, 957, 11),
	},
	requiredLevel = 0,
	minPlayers = 1,
	playerPositions = {
		{ pos = Position(1114, 954, 11), teleport = Position(1105, 957, 11) },
		{ pos = Position(1114, 955, 11), teleport = Position(1105, 957, 11) },
		{ pos = Position(1114, 956, 11), teleport = Position(1105, 957, 11) },
		{ pos = Position(1114, 957, 11), teleport = Position(1105, 957, 11) },
		{ pos = Position(1114, 958, 11), teleport = Position(1105, 957, 11) },
	},
	monsters = {
		{ name = "Pillar of Dark Energy", pos = Position(1091, 955, 11) },
		{ name = "Pillar of Dark Energy", pos = Position(1091, 959, 11) },
	},
	specPos = {
		from = Position(1090, 952, 11),
		to = Position(1108, 962, 11),
	},
	exit = Position(1049, 983, 11),
	timeAfterKill = 3,
}

local lever = BossLever(config)
lever:aid(60007)
lever:register()
