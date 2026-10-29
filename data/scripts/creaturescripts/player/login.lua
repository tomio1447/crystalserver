local function sendBoostMessage(player, category, isIncreased)
	return player:sendTextMessage(MESSAGE_BOOSTED_CREATURE, string.format("Event! %s is %screased. Happy Hunting!", category, isIncreased and "in" or "de"))
end

local function onMovementRemoveProtection(playerId, oldPos, time)
	local player = Player(playerId)
	if not player then
		return true
	end

	local playerPos = player:getPosition()
	if (playerPos.x ~= oldPos.x or playerPos.y ~= oldPos.y or playerPos.z ~= oldPos.z) or player:getTarget() then
		player:kv():remove("combat-protection")
		return true
	end

	addEvent(onMovementRemoveProtection, 1000, playerId, oldPos, time - 1)
end

local playerLoginGlobal = CreatureEvent("PlayerLoginGlobal")

function playerLoginGlobal.onLogin(player)
	-- War server: vocation-less characters trigger the client's tutorial/vocation UI. Force a vocation.
	if player:getVocation():getId() == VOCATION.ID.NONE then
		player:setVocation(Vocation(VOCATION.ID.ELITE_KNIGHT))
	end

	if configManager.getBoolean(configKeys.WAR_SYSTEM_ENABLED) then
		if player:getLastLoginSaved() == 0 then
			player:setTown(Town(1))
			player:teleportTo(Position(1048, 1065, 10), true)
			db.query("UPDATE `players` SET `istutorial` = 0, `town_id` = 1, `posx` = 1048, `posy` = 1065, `posz` = 10 WHERE `id` = " .. player:getGuid())
		end
		if player.addMissingBless then
			player:addMissingBless(true, true)
		end
	end

	-- Disables the chain system by default unless enabled in `config.lua`.
	if not configManager.getBoolean(configKeys.TOGGLE_CHAIN_SYSTEM) then
		player:setFeature(Features.ChainSystem, 0)
	end

	-- Welcome
	local loginStr
	if player:getLastLoginSaved() == 0 then
		loginStr = "Please choose your outfit."
		player:sendOutfitWindow()
		local startStreakLevel = configManager.getNumber(configKeys.START_STREAK_LEVEL)
		if startStreakLevel > 0 then
			player:setStreakLevel(startStreakLevel)
		end

		db.query("UPDATE `players` SET `istutorial` = 0 WHERE `id` = " .. player:getGuid())
	else
		loginStr = string.format("Your last visit in %s: %s.", SERVER_NAME, os.date("%d %b %Y %X", player:getLastLoginSaved()))
	end
	player:sendTextMessage(MESSAGE_LOGIN, loginStr)

	-- Grant/ensure a single loot pouch in the store inbox
	local function ensureSingleLootPouch()
		local POUCH_ID = 23721
		local pouches = {}
		local function scan(container)
			if not container then
				return
			end
			for _, item in ipairs(container:getItems(true)) do
				if item:getId() == POUCH_ID then
					table.insert(pouches, item)
				end
			end
		end

		scan(player:getStoreInbox())
		scan(player:getInbox())
		local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
		if backpack and backpack:isContainer() then
			scan(backpack)
		end

		local storeInbox = player:getStoreInbox()
		if not storeInbox then
			return
		end

		if #pouches == 0 then
			local pouch = Game.createItem(POUCH_ID, 1)
			if pouch then
				storeInbox:addItemEx(pouch)
			end
			return
		end

		local kept = pouches[1]
		for i = 2, #pouches do
			local extra = pouches[i]
			for _, item in ipairs(extra:getItems(false)) do
				kept:addItemEx(item)
			end
			extra:remove()
		end

		if kept:getParent() ~= storeInbox then
			kept:moveTo(storeInbox)
		end
	end

	ensureSingleLootPouch()
	player:kv():set("received-loot-pouch", true)

	-- War map offline protection: return players to temple if the map changed while they were offline
	local mapTokenStorage = (Storage and Storage.Warizi and Storage.Warizi.MapToken) or 150004
	local markedToken = player:getStorageValue(mapTokenStorage)
	if markedToken ~= -1 then
		local manager = _G.WarMapManager
		local phase = manager and manager.getPhase() or "cooldown"
		local currentToken = manager and manager.getMapToken() or -1
		local temple = manager and manager.config.temple or Position(1048, 1065, 10)
		if phase ~= "active" or markedToken ~= currentToken then
			player:teleportTo(temple, true)
			player:setStorageValue(mapTokenStorage, -1)
		end
	end

	-- Promotion
	local vocation = player:getVocation()
	local promotion = vocation:getPromotion()
	if player:isPremium() then
		local hasPromotion = player:kv():get("promoted")
		if not player:isPromoted() and hasPromotion then
			player:setVocation(promotion)
		end
	elseif player:isPromoted() then
		player:setVocation(vocation:getDemotion())
	end

	-- Boosted
	player:sendTextMessage(MESSAGE_BOOSTED_CREATURE, string.format("Today's boosted creature: %s.\nBoosted creatures yield more experience points, carry more loot than usual, and respawn at a faster rate.", Game.getBoostedCreature()))
	player:sendTextMessage(MESSAGE_BOOSTED_CREATURE, string.format("Today's boosted boss: %s.\nBoosted bosses contain more loot and count more kills for your Bosstiary.", Game.getBoostedBoss()))

	-- War map rotation info
	if _G.WarMapManager then
		_G.WarMapManager.sendLoginInfo(player)
	end

	-- Rewards
	local rewards = #player:getRewardList()
	if rewards > 0 then
		player:sendTextMessage(MESSAGE_LOGIN, string.format("You have %d reward%s in your reward chest.", rewards, rewards > 1 and "s" or ""))
	end

	-- Rate events:
	if SCHEDULE_EXP_RATE ~= 100 then
		sendBoostMessage(player, "Exp Rate", SCHEDULE_EXP_RATE > 100)
	end

	if SCHEDULE_SPAWN_RATE ~= 100 then
		sendBoostMessage(player, "Spawn Rate", SCHEDULE_SPAWN_RATE > 100)
	end

	if SCHEDULE_LOOT_RATE ~= 100 then
		sendBoostMessage(player, "Loot Rate", SCHEDULE_LOOT_RATE > 100)
	end

	if SCHEDULE_BOSS_LOOT_RATE ~= 100 then
		sendBoostMessage(player, "Boss Loot Rate", SCHEDULE_BOSS_LOOT_RATE > 100)
	end

	if SCHEDULE_SKILL_RATE ~= 100 then
		sendBoostMessage(player, "Skill Rate", SCHEDULE_SKILL_RATE > 100)
	end

	if SCHEDULE_FIENDISH_RATE ~= 100 then
		sendBoostMessage(player, "Fiendish Monsters", SCHEDULE_FIENDISH_RATE > 100)
	end

	if SCHEDULE_INFLUENCED_RATE ~= 100 then
		sendBoostMessage(player, "Influenced Monsters", SCHEDULE_INFLUENCED_RATE > 100)
	end

	-- Send Recruiter Outfit
	local resultId = db.storeQuery("SELECT `recruiter` FROM `accounts` WHERE `id`= " .. Game.getPlayerAccountId(getPlayerName(player)))
	if resultId then
		local recruiterStatus = Result.getNumber(resultId, "recruiter")
		Result.free(resultId)
		local sex = player:getSex()
		local outfitId = (sex == 1) and 746 or 745
		for outfitAddOn = 0, 2 do
			if recruiterStatus >= outfitAddOn * 3 + 1 then
				if not player:hasOutfit(outfitId, outfitAddOn) then
					if outfitAddOn == 0 then
						player:addOutfit(outfitId)
					else
						player:addOutfitAddon(outfitId, outfitAddOn)
					end
				end
			end
		end
	end

	-- Send Client Exp Display
	if configManager.getBoolean(configKeys.XP_DISPLAY_MODE) then
		local baseRate = player:getFinalBaseRateExperience() * 100
		if configManager.getBoolean(configKeys.VIP_SYSTEM_ENABLED) then
			local vipBonusExp = configManager.getNumber(configKeys.VIP_BONUS_EXP)
			if vipBonusExp > 0 and player:isVip() then
				vipBonusExp = (vipBonusExp > 100 and 100) or vipBonusExp
				baseRate = baseRate * (1 + (vipBonusExp / 100))
				player:sendTextMessage(MESSAGE_BOOSTED_CREATURE, "Normal base xp is: " .. baseRate .. "%, because you are VIP, bonus of " .. vipBonusExp .. "%")
			end
		end

		-- A Piece of Cake Quest - bonus xp
		if player:isPremium() and os.time() < CakeQuest.get(CakeQuest.Keys.WorldBonusUntil, 0) then
			baseRate = baseRate + (baseRate * (CakeQuest.Config.EXP_BONUS_PERCENT / 100))
		end

		player:setBaseXpGain(baseRate)
	end

	player:setStaminaXpBoost(player:getFinalBonusStamina() * 100)
	player:getFinalLowLevelBonus()

	-- Updates the player's VIP status and executes corresponding actions if applicable.
	if configManager.getBoolean(configKeys.VIP_SYSTEM_ENABLED) then
		local isCurrentlyVip = player:isVip()
		local hadVipStatus = player:kv():scoped("account"):get("vip-system") or false

		if hadVipStatus ~= isCurrentlyVip then
			if hadVipStatus then
				player:onRemoveVip()
			else
				player:onAddVip(player:getVipDays())
			end
		end

		if isCurrentlyVip then
			player:sendVipStatus()
		end
	end

	-- Set Ghost Mode
	if player:getGroup():getId() >= GROUP_TYPE_GAMEMASTER and player:getGroup():getId() < GROUP_TYPE_TESTER then
		player:setGhostMode(true)
	end

	-- Resets
	if _G.OnExerciseTraining[player:getId()] then
		stopEvent(_G.OnExerciseTraining[player:getId()].event)
		_G.OnExerciseTraining[player:getId()] = nil
		player:setTraining(false)
	end

	local playerId = player:getId()
	_G.NextUseStaminaTime[playerId] = os.time()
	_G.NextUseXpStamina[playerId] = os.time()
	_G.NextUseConcoctionTime[playerId] = os.time()
	DailyReward.init(playerId)

	local stats = player:inBossFight()
	if stats then
		stats.playerId = player:getId()
	end

	-- Remove Boss Time
	if GetDailyRewardLastServerSave() >= player:getLastLoginSaved() then
		player:setRemoveBossTime(1)
	end

	-- Remove combat protection
	local isProtected = player:kv():get("combat-protection") or 0
	if isProtected < 1 then
		player:kv():set("combat-protection", 1)
		onMovementRemoveProtection(playerId, player:getPosition(), 10)
	end

	-- fix stash
	player:setSpecialContainersAvailable(true, true, true)

	-- login log
	player:saveLoginLog()

	player:initializeLoyaltySystem()
	player:registerEvent("Castlemania")
	player:registerEvent("PartyProtection")
	player:registerEvent("PlayerDeath")
	player:registerEvent("DropLoot")
	player:registerEvent("BossParticipation")
	player:registerEvent("UpdatePlayerOnAdvancedLevel")
	player:registerEvent("RottenTaintGain")
	player:registerEvent("BakragorePlayerDeath")

	-- Vocation Adjustment: re-frame the monk's active virtue. It was restored early in IOLoginData
	-- (before the client's action bar existed), so the highlight did not stick; re-apply it here,
	-- after the spell list is loaded, so the active-stance highlight is sent at the correct time.
	local virtue = player:getVirtue()
	if virtue and virtue > 0 then
		player:setVirtue(virtue)
	end

	-- Vocation Adjustment: restore active stances from the previous session.
	local stanceKv = player:kv():scoped("stance")
	local primary = stanceKv:get("primary")
	if primary and primary > 0 then
		player:setStance(primary)
	end
	local elemental = stanceKv:get("elemental")
	if elemental and elemental > 0 then
		player:setElementalStance(elemental)
	end

	return true
end

playerLoginGlobal:register()
