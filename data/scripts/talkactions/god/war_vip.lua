local warVip = TalkAction("/warvip")

function warVip.onSay(player, words, param)
	local params = param:split(",")
	local action = params[1] and params[1]:trim():lower() or ""
	local targetName = params[2] and params[2]:trim() or ""
	local target = Player(targetName)
	if not target then
		player:sendCancelMessage("Usage: /warvip check|add|remove, Player Name. The player must be online.")
		return true
	end

	if action == "check" then
		player:sendTextMessage(MESSAGE_STATUS, string.format("%s is %sVIP.", target:getName(), target:isVip() and "" or "not "))
	elseif action == "add" then
		if target:getAccountType() ~= ACCOUNT_TYPE_NORMAL and target:getAccountType() ~= ACCOUNT_TYPE_VIP then
			player:sendCancelMessage("Staff account types cannot be changed by this command.")
			return true
		end
		target:setAccountType(ACCOUNT_TYPE_VIP)
		target:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
		player:sendTextMessage(MESSAGE_STATUS, target:getName() .. " is now VIP.")
	elseif action == "remove" then
		if target:getAccountType() ~= ACCOUNT_TYPE_VIP then
			player:sendCancelMessage("This player is not a War VIP.")
			return true
		end
		target:setAccountType(ACCOUNT_TYPE_NORMAL)
		target:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		player:sendTextMessage(MESSAGE_STATUS, target:getName() .. " is no longer VIP.")
	else
		player:sendCancelMessage("Usage: /warvip check|add|remove, Player Name.")
	end
	return true
end

warVip:separator(" ")
warVip:groupType("god")
warVip:register()
