local TELEPORT_POSITIONS = {
	Position(1056, 1060, 10),
	Position(1058, 1060, 10),
}
local WAR_MAP_TOKEN_STORAGE = (Storage and Storage.Warizi and Storage.Warizi.MapToken) or 150004

local moveEvent = MoveEvent()

function moveEvent.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local mapKv = kv.scoped("warizi-map")
	local phase = mapKv:get("phase")
	if phase ~= "active" then
		local phaseEnd = mapKv:get("phase_end") or 0
		local remaining = math.max(0, phaseEnd - os.time())
		player:sendCancelMessage(string.format("No war map is active. Next map in %d seconds.", remaining))
		return true
	end

	local manager = _G.WarMapManager
	local cityKey = mapKv:get("current_city")
	local city = manager and manager.config.cities[cityKey]
	local destinations = city and city.destinations
	if not destinations or #destinations == 0 then
		player:sendCancelMessage("The current war map is not configured.")
		return true
	end

	local destination = destinations[math.random(#destinations)]
	player:teleportTo(destination, true)
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	player:setStorageValue(WAR_MAP_TOKEN_STORAGE, mapKv:get("map_token") or -1)
	return true
end

moveEvent:type("stepin")

for _, pos in ipairs(TELEPORT_POSITIONS) do
	moveEvent:position(pos)
end

moveEvent:register()
