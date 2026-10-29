local experienceGain = EventCallback("WarExperienceGain")

local pvpProficiencyExpDivisor = 1000 -- PvP experience gained / this value = weapon proficiency experience

function experienceGain.playerOnGainExperience(player, target, exp, rawExp)
	if not WarSystem.isEnabled() or not target or not target:isPlayer() then
		return exp
	end

	local weapon = player:getSlotItem(CONST_SLOT_LEFT)
	if weapon then
		player:sendWeaponProficiencyExperience(weapon:getId(), math.floor(exp / pvpProficiencyExpDivisor))
	end

	local bonus = WarSystem.getBonuses(player:getWarRankPoints()).experience
	return exp + math.floor(exp * bonus / 100)
end

experienceGain:register()

local experienceLoss = EventCallback("WarExperienceLoss")

function experienceLoss.playerOnLoseExperience(player, exp)
	if not WarSystem.isEnabled() then
		return exp
	end
	local reduction = WarSystem.getBonuses(player:getWarRankPoints()).experienceLoss
	return math.floor(exp * (100 - reduction) / 100)
end

experienceLoss:register()

local skillGain = EventCallback("WarSkillGain")

function skillGain.playerOnGainSkillTries(player, skill, tries)
	if not WarSystem.isEnabled() then
		return tries
	end
	local bonus = WarSystem.getBonuses(player:getWarRankPoints()).skill
	return tries + math.floor(tries * bonus / 100)
end

skillGain:register()

local combat = EventCallback("WarCombatBonuses")

function combat.playerOnCombat(player, target, item, primaryDamage, primaryType, secondaryDamage, secondaryType)
	if not target or not target:isPlayer() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	local stats = _G.WarMapStats
	if stats and stats.isMapActive and stats.isMapActive() then
		if primaryType == COMBAT_HEALING then
			if player:getId() ~= target:getId() then
				local amount = math.abs(primaryDamage) + math.abs(secondaryDamage)
				stats.addHeal(player:getGuid(), amount)
			end
		else
			local amount = math.abs(primaryDamage) + math.abs(secondaryDamage)
			stats.addDamageTaken(target:getGuid(), amount)
			stats.addDamageDealt(player:getGuid(), amount)
		end
	end

	if not WarSystem.isEnabled() or primaryType == COMBAT_HEALING then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	local dealt = WarSystem.getBonuses(player:getWarRankPoints()).damageDealt
	local received = WarSystem.getBonuses(target:getWarRankPoints()).damageReceived
	local multiplier = (100 + dealt) * (100 - received) / 10000
	return math.floor(primaryDamage * multiplier), primaryType, math.floor(secondaryDamage * multiplier), secondaryType
end

combat:register()
