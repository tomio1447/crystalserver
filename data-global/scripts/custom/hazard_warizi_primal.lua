-- Extends the Gnomprona Gardens hazard zone to cover the Warizi Primal Menace room.
local event = GlobalEvent("wariziPrimalHazard")

function event.onStartup()
	local hazardZone = Zone.getByName("hazard.gnomprona-gardens")
	if hazardZone then
		hazardZone:addArea(Position(1124, 991, 11), Position(1142, 1001, 11))
		logger.info("Extended hazard.gnomprona-gardens to Warizi Primal Menace room (1124,991,11 -> 1142,1001,11)")
	else
		logger.warn("Could not find hazard.gnomprona-gardens zone to extend for Warizi Primal Menace")
	end
end

event:register()
