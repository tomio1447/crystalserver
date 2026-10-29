-- ============================================================================
-- Warizi Tibia Coin: using the item converts its stack count (1-100) into
-- transferable Tibia Coins on the player's account.
-- ============================================================================

local TIBIA_COIN_ID = 37317

local tibiaCoin = Action()

function tibiaCoin.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local count = item:getCount()
	if count < 1 or count > 100 then
		player:sendCancelMessage("Invalid coin stack.")
		return true
	end

	player:addTransferableCoins(count)
	item:remove()

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You received %d transferable Tibia Coin%s on your account.", count, count > 1 and "s" or ""))
	player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
	return true
end

tibiaCoin:id(TIBIA_COIN_ID)
tibiaCoin:register()
