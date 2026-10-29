-- Goshnar's Megalomania entrance teleport (AID 60100)
-- Requires all 5 Soul War mini bosses defeated to reach the lever room.
local megalomaniaLeverRoomPosition = Position(1113, 967, 11)

function teleportPlayerToMegalomaniaLeverRoom(player, sourcePosition)
	if not player or not player:isPlayer() then
		return false
	end

	local soulWarQuest = player:soulWarQuestKV()
	local text = ""
	local soulWarCount = 0
	for bossName, completed in pairs(SoulWarQuest.miniBosses) do
		if soulWarQuest:get(bossName) == completed then
			soulWarCount = soulWarCount + 1
		else
			text = text .. "\n" .. bossName
		end
	end

	if soulWarCount < 5 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You still need to defeat:" .. text)
		if sourcePosition then
			player:teleportTo(sourcePosition, true)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		end
		return false
	end

	player:teleportTo(megalomaniaLeverRoomPosition)
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	return true
end

local megalomaniaEntrance = MoveEvent()
function megalomaniaEntrance.onStepIn(creature, item, position, fromPosition)
	teleportPlayerToMegalomaniaLeverRoom(creature, fromPosition)
	return true
end

megalomaniaEntrance:type("stepin")
megalomaniaEntrance:aid(60100)
megalomaniaEntrance:register()

-- Lever (AID 60006)
local config = {
	boss = {
		name = "Goshnar's Megalomania Purple",
		position = Position(1093, 970, 11),
	},
	requiredLevel = 0,
	minPlayers = 1,
	playerPositions = {
		{ pos = Position(1113, 967, 11), teleport = Position(1103, 970, 11) },
		{ pos = Position(1113, 968, 11), teleport = Position(1103, 970, 11) },
		{ pos = Position(1113, 969, 11), teleport = Position(1103, 970, 11) },
		{ pos = Position(1113, 970, 11), teleport = Position(1103, 970, 11) },
		{ pos = Position(1113, 971, 11), teleport = Position(1103, 970, 11) },
	},
	monsters = {
		{ name = "Aspect of Power", pos = Position(1093, 971, 11) },
	},
	specPos = {
		from = Position(1089, 965, 11),
		to = Position(1107, 975, 11),
	},
	exit = Position(1049, 983, 11),
	timeAfterKill = 3,
}

local lever = BossLever(config)
lever:aid(60006)
lever:register()
