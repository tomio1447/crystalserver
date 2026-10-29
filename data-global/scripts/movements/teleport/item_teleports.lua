local itemTeleports = MoveEvent()

function itemTeleports.onAddItem(moveitem, tileitem, position)
	if tileitem.actionid == 40014 and moveitem:isPlayer() then
		teleportPlayerToAvailableTrainerRoom(moveitem, position)
		return true
	end

	if tileitem.actionid == 60100 and moveitem:isPlayer() then
		teleportPlayerToMegalomaniaLeverRoom(moveitem, position)
		return true
	end

	local setting = ItemTeleports[tileitem.actionid]
	if not setting then
		return true
	end

	moveitem:moveTo(setting.destination)
	setting.destination:sendMagicEffect(setting.effect)
	return true
end

itemTeleports:type("additem")
itemTeleports:id(1949, 1959)
itemTeleports:register()
