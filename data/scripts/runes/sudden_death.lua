local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MORTAREA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_SUDDENDEATH)

-- war: SD escala forte acima deste level (dano bruto adicional por level)
local extraLevelStart = 500
local extraLevelScale = 0.7

function onGetFormulaValues(player, level, maglevel, basePower)
	local levelBonus = calculateBaseDamageHealing(level) * 1.25 + math.max(0, level - extraLevelStart) * extraLevelScale
	local mlvlMultiplier = math.sqrt(basePower * 0.4)
	local flatTerm = basePower / 6
	local avg = (levelBonus + maglevel * mlvlMultiplier + flatTerm) * 1.25
	return -math.floor(avg * 0.88), -math.floor(avg * 1.12)
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local rune = Spell("rune")

function rune.onCastSpell(creature, var, isHotkey)
	return combat:execute(creature, var)
end

rune:id(21)
rune:group("attack")
rune:name("sudden death rune")
rune:castSound(SOUND_EFFECT_TYPE_SPELL_OR_RUNE)
rune:impactSound(SOUND_EFFECT_TYPE_SPELL_SUDDENDEATH_RUNE)
rune:runeId(3155)
rune:allowFarUse(true)
rune:charges(3)
rune:level(45)
rune:magicLevel(15)
rune:basePower(150)
rune:cooldown(2 * 1000)
rune:groupCooldown(2 * 1000)
rune:needTarget(true)
rune:isBlocking(true) -- True = Solid / False = Creature
rune:register()
