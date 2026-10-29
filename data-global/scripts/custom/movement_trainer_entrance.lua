local config = {
	-- Area containing all trainer cabins
	fromPosition = { x = 700, y = 950, z = 11 },
	toPosition = { x = 900, y = 1200, z = 11 },
	-- Action id used by the exit teleport in every room
	roomActionId = 40015,
	-- The free player tile is immediately south of the exit teleport
	playerTileOffset = { x = 0, y = 1 },
	expectedRooms = 112,
}

local roomPositions

local function hasActionId(item, actionId)
	return item and item:getActionId() == actionId
end

local function findRoomPositions()
	local positions = {}
	for x = config.fromPosition.x, config.toPosition.x do
		for y = config.fromPosition.y, config.toPosition.y do
			local position = Position(x, y, config.fromPosition.z)
			local tile = Tile(position)
			if tile then
				local marked = hasActionId(tile:getGround(), config.roomActionId)
				if not marked then
					for _, tileItem in ipairs(tile:getItems() or {}) do
						if hasActionId(tileItem, config.roomActionId) then
							marked = true
							break
						end
					end
				end
				if marked then
					table.insert(positions, Position(position.x + config.playerTileOffset.x, position.y + config.playerTileOffset.y, position.z))
				end
			end
		end
	end

	table.sort(positions, function(left, right)
		return left.y == right.y and left.x < right.x or left.y < right.y
	end)
	roomPositions = positions
	return positions
end

local function isRoomAvailable(position, player)
	local tile = Tile(position)
	if not tile then
		return false
	end

	for _, creature in ipairs(tile:getCreatures() or {}) do
		if creature:isPlayer() then
			return false
		end
	end
	return tile:queryAdd(player) == RETURNVALUE_NOERROR
end

local function ensureTargetDummy(position)
	local tile = Tile(position)
	if tile then
		for _, creature in ipairs(tile:getCreatures() or {}) do
			if creature:isMonster() and creature:getName():lower() == "target dummy" then
				return true
			end
		end
	end
	return Game.createMonster("Target Dummy", position, true, false) ~= nil
end

local function ensureRoomDummies(playerPosition)
	ensureTargetDummy(Position(playerPosition.x - 1, playerPosition.y - 1, playerPosition.z))
	ensureTargetDummy(Position(playerPosition.x + 1, playerPosition.y - 1, playerPosition.z))
end

function teleportPlayerToAvailableTrainerRoom(player, sourcePosition)
	if not player or not player:isPlayer() then
		return false
	end

	local positions = roomPositions or findRoomPositions()
	if #positions ~= config.expectedRooms then
		logger.warn("[movement_trainer_entrance] Found {} trainer rooms with aid {}, expected {}", #positions, config.roomActionId, config.expectedRooms)
	end

	for _, roomPosition in ipairs(positions) do
		if isRoomAvailable(roomPosition, player) then
			sourcePosition:sendMagicEffect(CONST_ME_TELEPORT)
			player:teleportTo(roomPosition)
			ensureRoomDummies(roomPosition)
			roomPosition:sendMagicEffect(CONST_ME_TELEPORT)
			return true
		end
	end

	player:sendCancelMessage("All trainer rooms are currently occupied.")
	sourcePosition:sendMagicEffect(CONST_ME_POFF)
	return false
end

local trainerEntrance = MoveEvent()
function trainerEntrance.onStepIn(creature, item, position, fromPosition)
	teleportPlayerToAvailableTrainerRoom(creature, position)
	return true
end

trainerEntrance:type("stepin")
trainerEntrance:aid(40014)
trainerEntrance:register()
