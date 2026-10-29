local function teleportToTemple(creature)
	if not creature:isPlayer() then
		return true
	end

	local templePosition = Position(1048, 1065, 10)
	creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	creature:teleportTo(templePosition)
	templePosition:sendMagicEffect(CONST_ME_TELEPORT)
end

local trainerExit = MoveEvent()
function trainerExit.onStepIn(creature, item, position, fromPosition)
	teleportToTemple(creature)
	return true
end

trainerExit:type("stepin")
trainerExit:aid(40015)
trainerExit:register()
