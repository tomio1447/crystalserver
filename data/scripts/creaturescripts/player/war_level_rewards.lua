local config = {
	milestoneInterval = 100,
	firstMilestone = 300, -- characters start at level 220, first reward is granted at level 300
	grantBothAddons = false, -- false: grant one random missing addon piece; true: grant the full addon set
}

-- Iterates the entry lines of an XML file, skipping comments.
local function xmlEntryLines(path, tag)
	local file = io.open(path, "r")
	if not file then
		logger.error("[WarLevelRewards] could not open " .. path)
		return function() end
	end
	local lines, inComment = file:lines(), false
	return function()
		for line in lines do
			local chunk = line
			local out = {}
			repeat
				if inComment then
					local closePos = chunk:find("-->", 1, true)
					if not closePos then
						chunk = nil
					else
						chunk = chunk:sub(closePos + 3)
						inComment = false
					end
				else
					local openPos = chunk:find("<!--", 1, true)
					if openPos then
						out[#out + 1] = chunk:sub(1, openPos - 1)
						chunk = chunk:sub(openPos + 4)
						inComment = true
					else
						out[#out + 1] = chunk
						chunk = nil
					end
				end
			until not chunk
			local clean = table.concat(out)
			if clean:match("<" .. tag .. "[%s>]") then
				return clean
			end
		end
		file:close()
		return nil
	end
end

-- Mounts obtainable through milestones: every mount except store-exclusive ones.
local mountPool = {}
for line in xmlEntryLines("data/XML/mounts.xml", "mount") do
	local id = line:match('[%s]id="(%d+)"')
	if id and not line:match('type="store"') then
		mountPool[#mountPool + 1] = tonumber(id)
	end
end

-- Outfits obtainable through milestones: every outfit except store-exclusive ones, indexed by sex.
local outfitPool = { [PLAYERSEX_FEMALE] = {}, [PLAYERSEX_MALE] = {} }
for line in xmlEntryLines("data/XML/outfits.xml", "outfit") do
	if not line:match('from="store"') then
		local sex = tonumber(line:match('[%s]type="(%d+)"'))
		local looktype = tonumber(line:match('[%s]looktype="(%d+)"'))
		local name = line:match('[%s]name="([^"]*)"')
		if sex and looktype and name and outfitPool[sex] then
			outfitPool[sex][#outfitPool[sex] + 1] = { looktype = looktype, name = name }
		end
	end
end

local function grantMount(player)
	local candidates = {}
	for _, mountId in ipairs(mountPool) do
		if not player:hasMount(mountId) then
			candidates[#candidates + 1] = mountId
		end
	end
	if #candidates == 0 then
		return nil
	end
	local mountId = candidates[math.random(#candidates)]
	if not player:addMount(mountId) then
		return nil
	end
	local mount = Mount(mountId)
	return mount and mount:getName() or ("mount #" .. mountId)
end

local function grantAddon(player)
	local pool = outfitPool[player:getSex()] or {}
	local candidates = {}
	for _, outfit in ipairs(pool) do
		if not player:hasOutfit(outfit.looktype, 3) then
			candidates[#candidates + 1] = outfit
		end
	end
	if #candidates == 0 then
		return nil
	end

	local outfit = candidates[math.random(#candidates)]
	local addons = config.grantBothAddons and 3 or ({ 1, 2 })[math.random(2)]
	if not config.grantBothAddons and player:hasOutfit(outfit.looktype, addons) then
		addons = addons == 1 and 2 or 1
	end

	if not player:hasOutfit(outfit.looktype) then
		player:addOutfit(outfit.looktype)
	end
	player:addOutfitAddon(outfit.looktype, addons)

	if config.grantBothAddons or addons == 3 then
		return outfit.name .. " full addons"
	end
	return string.format("%s addon %d", outfit.name, addons)
end

local warLevelRewards = CreatureEvent("WarLevelRewards")

function warLevelRewards.onAdvance(player, skill, oldLevel, newLevel)
	if skill ~= SKILL_LEVEL or newLevel <= oldLevel then
		return true
	end

	local kv = player:kv()
	local claimed = kv:get("level_milestone") or (config.firstMilestone - config.milestoneInterval)

	local milestone = math.floor(newLevel / config.milestoneInterval) * config.milestoneInterval
	while claimed < milestone do
		claimed = claimed + config.milestoneInterval
		if claimed >= config.firstMilestone then
			local mountName = grantMount(player)
			local addonDesc = grantAddon(player)
			if mountName or addonDesc then
				local rewards = {}
				if mountName then
					rewards[#rewards + 1] = "mount: " .. mountName
				end
				if addonDesc then
					rewards[#rewards + 1] = "outfit: " .. addonDesc
				end
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Level %d milestone reward: %s!", claimed, table.concat(rewards, " | ")))
			else
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Level %d milestone reached, but you already own every mount and outfit addon!", claimed))
			end
		end
	end
	kv:set("level_milestone", claimed)
	return true
end

warLevelRewards:register()
