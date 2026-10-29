-- Bakragore entrance teleport (AID 60101)
-- Requires all 4 other Sanguine/Rotten Blood bosses defeated to reach the lever room.
local requiredBosses = {
	{ name = "Vemiath", key = "vemiath-killed" },
	{ name = "Chagorz", key = "chagorz-killed" },
	{ name = "Ichgahal", key = "ichgahal-killed" },
	{ name = "Murcion", key = "murcion-killed" },
}

local bakragoreLeverRoomPosition = Position(1147, 1006, 11)

local bakragoreEntrance = MoveEvent()
function bakragoreEntrance.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local kv = player:kv():scoped("sanguine-bosses")
	local missing = {}
	for _, boss in ipairs(requiredBosses) do
		if not kv:get(boss.key) then
			table.insert(missing, boss.name)
		end
	end

	if #missing > 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You still need to defeat:\n" .. table.concat(missing, "\n"))
		player:teleportTo(fromPosition, true)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		return true
	end

	player:teleportTo(bakragoreLeverRoomPosition)
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	return true
end

bakragoreEntrance:type("stepin")
bakragoreEntrance:aid(60101)
bakragoreEntrance:register()

-- Lever (AID 60011)
local config = {
	boss = {
		name = "Bakragore",
		position = Position(1127, 1011, 11),
	},
	requiredLevel = 0,
	minPlayers = 1,
	playerPositions = {
		{ pos = Position(1147, 1006, 11), teleport = Position(1137, 1011, 11) },
		{ pos = Position(1147, 1007, 11), teleport = Position(1137, 1011, 11) },
		{ pos = Position(1147, 1008, 11), teleport = Position(1137, 1011, 11) },
		{ pos = Position(1147, 1009, 11), teleport = Position(1137, 1011, 11) },
		{ pos = Position(1147, 1010, 11), teleport = Position(1137, 1011, 11) },
	},
	monsters = {
		{ name = "Elder Bloodjaw", pos = Position(1125, 1009, 11) },
		{ name = "Elder Bloodjaw", pos = Position(1125, 1013, 11) },
	},
	specPos = {
		from = Position(1123, 1006, 11),
		to = Position(1141, 1016, 11),
	},
	exit = Position(1049, 983, 11),
	timeAfterKill = 3,
}

local lever = BossLever(config)
lever:aid(60011)
lever:register()
