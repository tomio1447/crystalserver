local TOKEN_STORAGE = (Storage and Storage.Warizi and Storage.Warizi.MapToken) or 150004

local currentStats = {
	frags = {},
	healing = {},
	damageTaken = {},
	bestDamage = {},
	bestHeal = {},
}

local function isMapActive()
	return _G.WarMapActive == true
end

local function isParticipant(guid)
	if not isMapActive() then
		return false
	end
	local manager = _G.WarMapManager
	local token = manager and manager.getMapToken and manager.getMapToken() or -1
	if token <= 0 then
		return false
	end
	local player = Player(guid)
	return player ~= nil and player:getStorageValue(TOKEN_STORAGE) == token
end

function WarMapStatsReset()
	currentStats = {
		frags = {},
		healing = {},
		damageTaken = {},
		bestDamage = {},
		bestHeal = {},
	}
end

function WarMapStatsAddFrag(attackerGuid)
	if not isParticipant(attackerGuid) then
		return
	end
	currentStats.frags[attackerGuid] = (currentStats.frags[attackerGuid] or 0) + 1
end

function WarMapStatsAddHeal(healerGuid, amount)
	if amount <= 0 or not isParticipant(healerGuid) then
		return
	end
	currentStats.healing[healerGuid] = (currentStats.healing[healerGuid] or 0) + amount
	if amount > (currentStats.bestHeal[healerGuid] or 0) then
		currentStats.bestHeal[healerGuid] = amount
	end
end

function WarMapStatsAddDamageTaken(targetGuid, amount)
	if amount <= 0 or not isParticipant(targetGuid) then
		return
	end
	currentStats.damageTaken[targetGuid] = (currentStats.damageTaken[targetGuid] or 0) + amount
end

function WarMapStatsAddDamageDealt(attackerGuid, amount)
	if amount <= 0 or not isParticipant(attackerGuid) then
		return
	end
	if amount > (currentStats.bestDamage[attackerGuid] or 0) then
		currentStats.bestDamage[attackerGuid] = amount
	end
end

function WarMapStatsGetCurrent()
	return currentStats
end

_G.WarMapStats = {
	isMapActive = isMapActive,
	isParticipant = isParticipant,
	reset = WarMapStatsReset,
	getCurrent = WarMapStatsGetCurrent,
	addFrag = WarMapStatsAddFrag,
	addHeal = WarMapStatsAddHeal,
	addDamageTaken = WarMapStatsAddDamageTaken,
	addDamageDealt = WarMapStatsAddDamageDealt,
}
