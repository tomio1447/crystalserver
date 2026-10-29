local config = {
	boss = {
		name = "Chagorz",
		position = Position(1094, 944, 11),
	},
	requiredLevel = 0,
	minPlayers = 1,
	playerPositions = {
		{ pos = Position(1114, 941, 11), teleport = Position(1104, 944, 11) },
		{ pos = Position(1114, 942, 11), teleport = Position(1104, 944, 11) },
		{ pos = Position(1114, 943, 11), teleport = Position(1104, 944, 11) },
		{ pos = Position(1114, 944, 11), teleport = Position(1104, 944, 11) },
		{ pos = Position(1114, 945, 11), teleport = Position(1104, 944, 11) },
	},
	monsters = {
		{ name = "Pillar of Dark Energy", pos = Position(1091, 942, 11) },
		{ name = "Pillar of Dark Energy", pos = Position(1091, 946, 11) },
	},
	specPos = {
		from = Position(1090, 939, 11),
		to = Position(1108, 949, 11),
	},
	exit = Position(1049, 983, 11),
	timeAfterKill = 3,
}

local lever = BossLever(config)
lever:aid(60008)
lever:register()
