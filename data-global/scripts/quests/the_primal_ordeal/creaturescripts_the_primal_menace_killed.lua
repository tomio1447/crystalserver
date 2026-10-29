local thePrimalMenaceDeath = CreatureEvent("ThePrimalMenaceDeath")

function thePrimalMenaceDeath.onDeath(creature)
	local damageMap = creature:getMonster():getDamageMap()
	local hazard = Hazard.getByName("hazard.gnomprona-gardens")
	if not hazard then
		return
	end
	local _, hazardPoints = hazard:getHazardPlayerAndPoints(damageMap)
	onDeathForDamagingPlayers(creature, function(creature, player)
		if player:getStorageValue(Storage.Quest.U12_90.PrimalOrdeal.Bosses.ThePrimalMenaceKilled) < 1 then
			player:setStorageValue(Storage.Quest.U12_90.PrimalOrdeal.Bosses.ThePrimalMenaceKilled, 1)
		end

		-- Each kill counts as double: unlock up to 2 hazard levels at once.
		if hazard:getPlayerMaxLevel(player) == hazardPoints then
			local newMax = math.min(hazardPoints + 2, hazard.maxLevel)
			hazard:setPlayerMaxLevel(player, newMax)
		end
	end)
end

thePrimalMenaceDeath:register()
