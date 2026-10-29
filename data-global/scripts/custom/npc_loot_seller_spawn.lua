local SPAWN_POSITION = Position(1059, 1062, 11)
local NPC_NAME = "Loot Seller"

local spawnEvent = GlobalEvent("lootSellerSpawn")

function spawnEvent.onStartup()
	local tile = Tile(SPAWN_POSITION)
	if tile and tile:getTopCreature() then
		return true
	end

	local existing = Npc(NPC_NAME)
	if existing then
		return true
	end

	local npc = Game.createNpc(NPC_NAME, SPAWN_POSITION)
	if npc then
		logger.info("Loot Seller spawned at {},{},{}", SPAWN_POSITION.x, SPAWN_POSITION.y, SPAWN_POSITION.z)
	else
		logger.warn("Failed to spawn Loot Seller at {},{},{}", SPAWN_POSITION.x, SPAWN_POSITION.y, SPAWN_POSITION.z)
	end
	return true
end

spawnEvent:register()
