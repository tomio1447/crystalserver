-- Marks Sanguine/Rotten Blood boss kills per player (used by the Bakragore entrance)
-- and grants a Bag You Covet on the first Bakragore kill.
local sanguineBossDeath = CreatureEvent("SanguineBossDeath")

function sanguineBossDeath.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	local bossKey = creature:getName():lower() .. "-killed"
	for _, player in ipairs(creature:getKillers(true)) do
		local kv = player:kv():scoped("sanguine-bosses")
		if not kv:get(bossKey) then
			kv:set(bossKey, true)
			if bossKey == "bakragore-killed" then
				player:addItem(43895, 1)
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have defeated Bakragore for the first time and received a Bag You Covet!")
			end
		end
	end
	return true
end

sanguineBossDeath:register()
