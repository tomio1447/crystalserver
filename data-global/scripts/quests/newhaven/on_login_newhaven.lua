local newhavenOnLogin = CreatureEvent("NewhavenOnLogin")

function newhavenOnLogin.onLogin(player)
	if not player then
		return false
	end

	if player:getPosition().x > 30000 then
		player:teleportTo(Position(1048, 1065, 10), true)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The tutorial area is disabled on this server. You have been moved to the temple.")
	end

	if player:getStorageValue(Storage.Quest.U15_12.newhavenCitizen) == 1 then
		player:registerEvent("onDeathNewhaven")

		if player:getVocation():getId() ~= VOCATION_NONE then
			Newhaven.giveStarterItems(player)
		end
	end

	return true
end

newhavenOnLogin:register()
