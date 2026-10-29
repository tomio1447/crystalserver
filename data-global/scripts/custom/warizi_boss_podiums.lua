-- ============================================================================
-- Warizi Conveyor Roulette
-- Bosses shown on podiums of vigour + filler items slide along the conveyor
-- row. Pull the lever (actionid 17777) with 1 roulette coin: entries slide
-- ~10s with deceleration; whatever stops on the winning tile is the prize.
--   - boss podium  -> rolls a RARE drop from that boss's own loot table
--   - item entries -> the item itself (tibia coin, trash - house always wins)
-- Optional prizeOverride per boss forces a manual prize list.
-- ============================================================================

local config = {
	coinId = 3533, -- black token (roulette coin)
	coinCount = 1,

	leverActionIds = { 17777, 67777 }, -- fake lever/glow + hidden lever
	podiumItemId = 38707, -- podium of vigour
	displayActionId = IMMOVABLE_ACTION_ID, -- aid 100: players can't grab entries

	row = { fromX = 1043, toX = 1055, y = 1087, z = 11 },
	winX = 1049,

	ticks = 42,
	durationMs = 10000,
	resultHoldMs = 2000,
	lockTimeoutS = 120,

	rareThreshold = 5000, -- loot chance (0-100000 scale) <= this = rare

	-- weight = how often it shows on the belt AND how likely it wins
	entries = {
		-- ===== rarest tier (megalomania-level) =====
		{ kind = "boss", name = "Phosphorus", weight = 1, rareThreshold = 3000 }, -- hardest of all
		{ kind = "boss", name = "Bakragore", weight = 1, rareThreshold = 3000 },
		{ kind = "boss", name = "Bonelord's Phylactery", weight = 2 }, -- random crypt item, see prizeOverride
		{ kind = "boss", name = "Magma Bubble", weight = 2, rareThreshold = 3000 },
		{ kind = "boss", name = "Court Warlock", weight = 2, rareThreshold = 3000 },
		{ kind = "boss", name = "Goshnar's Megalomania Purple", weight = 2, rareThreshold = 3000 },
		{ kind = "boss", name = "Ascending Ferumbras", weight = 2 }, -- hat only, see prizeOverride
		-- soul war + sanguine: lowest weights, rarer than common bosses
		{ kind = "boss", name = "Goshnar's Cruelty", weight = 1, rareThreshold = 3000 },
		{ kind = "boss", name = "Goshnar's Greed", weight = 1, rareThreshold = 3000 },
		{ kind = "boss", name = "Goshnar's Hatred", weight = 1, rareThreshold = 3000 },
		{ kind = "boss", name = "Goshnar's Malice", weight = 1, rareThreshold = 3000 },
		{ kind = "boss", name = "Goshnar's Spite", weight = 1, rareThreshold = 3000 },
		{ kind = "boss", name = "The Dread Maiden", weight = 1, rareThreshold = 3000 },
		-- sanguine (rotten blood)
		{ kind = "boss", name = "Chagorz", weight = 1, rareThreshold = 3000 },
		{ kind = "boss", name = "Vemiath", weight = 1, rareThreshold = 3000 },
		{ kind = "boss", name = "Ichgahal", weight = 1, rareThreshold = 3000 },
		{ kind = "boss", name = "Murcion", weight = 1, rareThreshold = 3000 },

		-- ===== mid tier =====
		{ kind = "boss", name = "Ratmiral Blackwhiskers", weight = 4 },
		{ kind = "boss", name = "The Brainstealer", weight = 4 },
		{ kind = "boss", name = "Arbaziloth", weight = 4 },
		{ kind = "boss", name = "The Rootkraken", weight = 4 },
		{ kind = "boss", name = "Doctor Marrow", weight = 4 },
		{ kind = "boss", name = "Timira the Many-Headed", weight = 4 },
		{ kind = "boss", name = "Leiden", weight = 4 }, -- always elven mail, see prizeOverride
		{ kind = "boss", name = "Vladrukh", weight = 4 },

		-- ===== common boss tier =====
		{ kind = "boss", name = "Grand Master Oberon", weight = 6 },
		{ kind = "boss", name = "Scarlett Etzel", weight = 6 },
		{ kind = "boss", name = "Drume", weight = 6 },
		{ kind = "boss", name = "Sugar Daddy", weight = 6 },
		{ kind = "boss", name = "Mitmah Vanguard", weight = 6 },
		{ kind = "boss", name = "Dragon Hoard", weight = 6 },
		{ kind = "boss", name = "Jaul", weight = 6 },
		{ kind = "boss", name = "Brokul", weight = 6 },
		{ kind = "boss", name = "Obujos", weight = 6 },
		{ kind = "boss", name = "Tanjis", weight = 6 },
		{ kind = "boss", name = "Duke Krule", weight = 6 },
		{ kind = "boss", name = "Lord Azaram", weight = 6 },
		{ kind = "boss", name = "Sir Baeloc", weight = 6 }, -- grave danger rare drops (nictros has no loot)
		{ kind = "boss", name = "Count Vlarkorth", weight = 6 },
		{ kind = "boss", name = "Earl Osam", weight = 6 },
		{ kind = "boss", name = "King Zelos", weight = 6 },
		{ kind = "boss", name = "The Pale Worm", weight = 6 },
		{ kind = "boss", name = "The Fear Feaster", weight = 6 },
		{ kind = "boss", name = "The Unwelcome", weight = 6 },
		{ kind = "boss", name = "Faceless Bane", weight = 6 },
		{ kind = "boss", name = "Urmahlullu the Immaculate", weight = 6 },
		{ kind = "boss", name = "The Nightmare Beast", weight = 6 },
		{ kind = "boss", name = "Maxxenius", weight = 6 },
		{ kind = "boss", name = "Plagueroot", weight = 6 },
		{ kind = "boss", name = "Alptramun", weight = 6 },
		{ kind = "boss", name = "Izkandar (Summer Blade)", weight = 3 }, -- always summerblade
		{ kind = "boss", name = "Izkandar (Winters Blade)", weight = 3 }, -- always winterblade
		{ kind = "boss", name = "The Count of the Core", weight = 6 },
		{ kind = "boss", name = "The Baron from Below", weight = 6 },
		{ kind = "boss", name = "The Duke of the Depths", weight = 6 },

		-- mid prize: tibia coin stack (use it -> transferable coins)
		{ kind = "item", id = 37317, minCount = 1, maxCount = 5, weight = 20, rare = true },

		-- trash (the house always wins)
		{ kind = "item", id = 3111, weight = 20 }, -- fishbone
		{ kind = "item", id = 3112, weight = 20 }, -- rotten meat
		{ kind = "item", id = 3113, weight = 20 }, -- broken pottery
		{ kind = "item", id = 3114, weight = 20 }, -- skull
		{ kind = "item", id = 3122, weight = 20 }, -- dirty cape
		{ kind = "item", id = 3129, weight = 20 }, -- some leaves
		{ kind = "item", id = 3106, weight = 20 }, -- old twig
	},

	-- manual prize lists per boss (override the loot-table roll)
	prizeOverride = {
		["Ascending Ferumbras"] = {
			{ id = 5903, count = 1, chance = 100 }, -- Ferumbras' hat
		},
		["Leiden"] = {
			{ id = 3399, count = 1, chance = 100 }, -- elven mail
		},
		["Izkandar (Summer Blade)"] = {
			{ id = 29421, count = 1, chance = 100 }, -- summerblade
		},
		["Izkandar (Winters Blade)"] = {
			{ id = 29422, count = 1, chance = 100 }, -- winterblade
		},
		-- soul war: always a bag you desire
		["Goshnar's Cruelty"] = { { id = 34109, count = 1, chance = 100 } },
		["Goshnar's Greed"] = { { id = 34109, count = 1, chance = 100 } },
		["Goshnar's Hatred"] = { { id = 34109, count = 1, chance = 100 } },
		["Goshnar's Malice"] = { { id = 34109, count = 1, chance = 100 } },
		["Goshnar's Spite"] = { { id = 34109, count = 1, chance = 100 } },
		["Goshnar's Megalomania Purple"] = { { id = 34109, count = 1, chance = 100 } },
		["The Dread Maiden"] = { { id = 34109, count = 1, chance = 100 } },
		-- sanguine/rotten blood: always a bag you covet
		["Chagorz"] = { { id = 43895, count = 1, chance = 100 } },
		["Vemiath"] = { { id = 43895, count = 1, chance = 100 } },
		["Ichgahal"] = { { id = 43895, count = 1, chance = 100 } },
		["Murcion"] = { { id = 43895, count = 1, chance = 100 } },
		-- bakragore: always a sanguine item (grand variants are rarer)
		["Bakragore"] = {
			{ id = 43864, count = 1, chance = 100 }, -- sanguine blade
			{ id = 43866, count = 1, chance = 100 }, -- sanguine cudgel
			{ id = 43868, count = 1, chance = 100 }, -- sanguine hatchet
			{ id = 43870, count = 1, chance = 100 }, -- sanguine razor
			{ id = 43872, count = 1, chance = 100 }, -- sanguine bludgeon
			{ id = 43874, count = 1, chance = 100 }, -- sanguine battleaxe
			{ id = 43876, count = 1, chance = 100 }, -- sanguine legs
			{ id = 43877, count = 1, chance = 100 }, -- sanguine bow
			{ id = 43879, count = 1, chance = 100 }, -- sanguine crossbow
			{ id = 43881, count = 1, chance = 100 }, -- sanguine greaves
			{ id = 43882, count = 1, chance = 100 }, -- sanguine coil
			{ id = 43884, count = 1, chance = 100 }, -- sanguine boots
			{ id = 43885, count = 1, chance = 100 }, -- sanguine rod
			{ id = 43887, count = 1, chance = 100 }, -- sanguine galoshes
			{ id = 50146, count = 1, chance = 100 }, -- sanguine trousers
			{ id = 50157, count = 1, chance = 100 }, -- sanguine claws
			{ id = 43865, count = 1, chance = 10 }, -- grand sanguine blade
			{ id = 43867, count = 1, chance = 10 }, -- grand sanguine cudgel
			{ id = 43869, count = 1, chance = 10 }, -- grand sanguine hatchet
			{ id = 43871, count = 1, chance = 10 }, -- grand sanguine razor
			{ id = 43873, count = 1, chance = 10 }, -- grand sanguine bludgeon
			{ id = 43875, count = 1, chance = 10 }, -- grand sanguine battleaxe
			{ id = 43878, count = 1, chance = 10 }, -- grand sanguine bow
			{ id = 43880, count = 1, chance = 10 }, -- grand sanguine crossbow
			{ id = 43883, count = 1, chance = 10 }, -- grand sanguine coil
			{ id = 43886, count = 1, chance = 10 }, -- grand sanguine rod
			{ id = 50158, count = 1, chance = 10 }, -- grand sanguine claws
		},
		["Phosphorus"] = {
			{ id = 54270, count = 1, chance = 100 }, -- figurine of Phosphorus
			{ id = 8090, count = 1, chance = 100 }, -- spellbook of dark mysteries
			{ id = 8092, count = 1, chance = 100 }, -- wand of starstorm
			{ id = 43865, count = 1, chance = 100 }, -- grand sanguine blade
			{ id = 43875, count = 1, chance = 100 }, -- grand sanguine battleaxe
			{ id = 43878, count = 1, chance = 100 }, -- grand sanguine bow
			{ id = 43880, count = 1, chance = 100 }, -- grand sanguine crossbow
			{ id = 43886, count = 1, chance = 100 }, -- grand sanguine rod
			{ id = 43871, count = 1, chance = 100 }, -- grand sanguine razor
			{ id = 43867, count = 1, chance = 100 }, -- grand sanguine cudgel
			{ id = 43869, count = 1, chance = 100 }, -- grand sanguine hatchet
			{ id = 43873, count = 1, chance = 100 }, -- grand sanguine bludgeon
			{ id = 43883, count = 1, chance = 100 }, -- grand sanguine coil
			{ id = 50158, count = 1, chance = 100 }, -- grand sanguine claws
		},
		["The Rootkraken"] = {
			{ id = 47368, count = 1, chance = 100 }, -- amber slayer
			{ id = 47369, count = 1, chance = 100 }, -- amber greataxe
			{ id = 47370, count = 1, chance = 100 }, -- amber bludgeon
			{ id = 47371, count = 1, chance = 100 }, -- amber bow
			{ id = 47372, count = 1, chance = 100 }, -- amber wand
			{ id = 47373, count = 1, chance = 100 }, -- amber rod
			{ id = 47374, count = 1, chance = 100 }, -- amber sabre
			{ id = 47375, count = 1, chance = 100 }, -- amber axe
			{ id = 47376, count = 1, chance = 100 }, -- amber cudgel
			{ id = 47377, count = 1, chance = 100 }, -- amber crossbow
			{ id = 50239, count = 1, chance = 100 }, -- amber kusarigama
			{ id = 50152, count = 1, chance = 100 }, -- collar of orange plasma
			{ id = 48514, count = 1, chance = 100 }, -- strange inedible fruit
		},
		["Doctor Marrow"] = {
			{ id = 40588, count = 1, chance = 100 }, -- antler-horn helmet
			{ id = 7412, count = 1, chance = 100 }, -- butcher's axe
		},
		["Vladrukh"] = { -- full norcferatu set
			{ id = 51260, count = 1, chance = 100 }, -- norcferatu skullguard
			{ id = 51261, count = 1, chance = 100 }, -- norcferatu bonehood
			{ id = 51262, count = 1, chance = 100 }, -- norcferatu tuskplate
			{ id = 51263, count = 1, chance = 100 }, -- norcferatu bloodhide
			{ id = 51264, count = 1, chance = 100 }, -- norcferatu bonecloak
			{ id = 51265, count = 1, chance = 100 }, -- norcferatu thornwraps
			{ id = 51266, count = 1, chance = 100 }, -- norcferatu bloodstrider
			{ id = 51267, count = 1, chance = 100 }, -- norcferatu fleshguards
			{ id = 51268, count = 1, chance = 100 }, -- norcferatu goretrampers
			{ id = 51269, count = 1, chance = 100 }, -- norcferatu fangstompers
		},
		["Obujos"] = {
			{ id = 13991, count = 1, chance = 100 }, -- deepling axe
			{ id = 13998, count = 1, chance = 100 }, -- depth scutum
			{ id = 13999, count = 1, chance = 100 }, -- ornate legs
			{ id = 13993, count = 1, chance = 100 }, -- ornate chestplate
			{ id = 13994, count = 1, chance = 100 }, -- depth lorica
		},
		["Tanjis"] = {
			{ id = 13996, count = 1, chance = 100 }, -- depth ocrea
			{ id = 14001, count = 1, chance = 100 }, -- ornate mace
			{ id = 14000, count = 1, chance = 100 }, -- ornate shield
			{ id = 13995, count = 1, chance = 100 }, -- depth galea
			{ id = 13993, count = 1, chance = 100 }, -- ornate chestplate
		},
		["Faceless Bane"] = {
			{ id = 28571, count = 1, chance = 100 }, -- book backpack
			{ id = 25700, count = 1, chance = 100 }, -- dream blossom staff
			{ id = 29430, count = 1, chance = 100 }, -- ectoplasmic shield
			{ id = 29431, count = 1, chance = 100 }, -- spirit guide
			{ id = 30344, count = 1, chance = 100 }, -- enchanted pendulet
		},
		["Urmahlullu the Immaculate"] = {
			{ id = 31614, count = 1, chance = 100 }, -- tagralt blade
			{ id = 31617, count = 1, chance = 100 }, -- winged boots
		},
		-- grave danger bosses share the same 4 rare drops
		["Duke Krule"] = {
			{ id = 31578, count = 1, chance = 100 }, -- bear skin
			{ id = 31577, count = 1, chance = 100 }, -- terra helmet
			{ id = 31579, count = 1, chance = 100 }, -- embrace of nature
			{ id = 31738, count = 1, chance = 100 }, -- final judgement
		},
		["Lord Azaram"] = {
			{ id = 31578, count = 1, chance = 100 }, -- bear skin
			{ id = 31577, count = 1, chance = 100 }, -- terra helmet
			{ id = 31579, count = 1, chance = 100 }, -- embrace of nature
			{ id = 31738, count = 1, chance = 100 }, -- final judgement
		},
		["Sir Baeloc"] = {
			{ id = 31578, count = 1, chance = 100 }, -- bear skin
			{ id = 31577, count = 1, chance = 100 }, -- terra helmet
			{ id = 31579, count = 1, chance = 100 }, -- embrace of nature
			{ id = 31738, count = 1, chance = 100 }, -- final judgement
		},
		["Count Vlarkorth"] = {
			{ id = 31578, count = 1, chance = 100 }, -- bear skin
			{ id = 31577, count = 1, chance = 100 }, -- terra helmet
			{ id = 31579, count = 1, chance = 100 }, -- embrace of nature
			{ id = 31738, count = 1, chance = 100 }, -- final judgement
		},
		["Earl Osam"] = {
			{ id = 31578, count = 1, chance = 100 }, -- bear skin
			{ id = 31577, count = 1, chance = 100 }, -- terra helmet
			{ id = 31579, count = 1, chance = 100 }, -- embrace of nature
			{ id = 31738, count = 1, chance = 100 }, -- final judgement
		},
		-- King Zelos keeps his own loot pool (mortal mace, galea mortis, death oyoroi...)
		["The Duke of the Depths"] = {
			{ id = 27647, count = 1, chance = 100 }, -- gnome helmet
			{ id = 27648, count = 1, chance = 100 }, -- gnome armor
			{ id = 27649, count = 1, chance = 100 }, -- gnome legs
			{ id = 27650, count = 1, chance = 100 }, -- gnome shield
			{ id = 27651, count = 1, chance = 100 }, -- gnome sword
			{ id = 50290, count = 1, chance = 100 }, -- gnomish footwraps
		},
		["Court Warlock"] = { -- full stag set
			{ id = 52348, count = 1, chance = 100 }, -- stag helmet
			{ id = 52349, count = 1, chance = 100 }, -- stag robe
			{ id = 52350, count = 1, chance = 100 }, -- stag plate
			{ id = 52351, count = 1, chance = 100 }, -- stag legs
			{ id = 52352, count = 1, chance = 100 }, -- stag shinguards
			{ id = 52353, count = 1, chance = 100 }, -- stag boots
			{ id = 52354, count = 1, chance = 100 }, -- stag footwraps
			{ id = 52355, count = 1, chance = 100 }, -- stag spellbook
			{ id = 52356, count = 1, chance = 100 }, -- stag scrolls
			{ id = 52357, count = 1, chance = 100 }, -- stag shield
		},
		["Bonelord's Phylactery"] = {
			{ id = 52332, count = 1, chance = 100 }, -- crypt spine
			{ id = 52333, count = 1, chance = 100 }, -- crypt splitter
			{ id = 52334, count = 1, chance = 100 }, -- crypt breaker
			{ id = 52335, count = 1, chance = 100 }, -- crypt strike
			{ id = 52336, count = 1, chance = 100 }, -- crypt bile
			{ id = 52337, count = 1, chance = 100 }, -- crypt jaw
			{ id = 52338, count = 1, chance = 100 }, -- crypt slicer
		},
		-- quiver bosses: quiver guaranteed in the prize list + signature drops
		["Magma Bubble"] = {
			{ id = 39150, count = 1, chance = 100 }, -- alicorn quiver
			{ id = 39147, count = 1, chance = 100 }, -- spiritthorn armor
			{ id = 39148, count = 1, chance = 100 }, -- spiritthorn helmet
			{ id = 39149, count = 1, chance = 100 }, -- alicorn headguard
			{ id = 39151, count = 1, chance = 100 }, -- arcanomancer regalia
			{ id = 39152, count = 1, chance = 100 }, -- arcanomancer folio
			{ id = 50188, count = 1, chance = 100 }, -- ethereal coned hat
			{ id = 50149, count = 1, chance = 100 }, -- charged ethereal ring
			{ id = 39183, count = 1, chance = 100 }, -- charged arcanomancer sigil
			{ id = 39186, count = 1, chance = 100 }, -- charged arboreal ring
			{ id = 39180, count = 1, chance = 100 }, -- charged alicorn ring
			{ id = 39177, count = 1, chance = 100 }, -- charged spiritthorn ring
			{ id = 39544, count = 1, chance = 100 }, -- firefighting axe
			{ id = 39545, count = 1, chance = 100 }, -- portable flame
		},
		["Ratmiral Blackwhiskers"] = {
			{ id = 35524, count = 1, chance = 100 }, -- jungle quiver
			{ id = 35518, count = 1, chance = 100 }, -- jungle bow
			{ id = 35521, count = 1, chance = 100 }, -- jungle rod
			{ id = 35522, count = 1, chance = 100 }, -- jungle wand
			{ id = 35514, count = 1, chance = 100 }, -- jungle flail
			{ id = 35516, count = 1, chance = 100 }, -- exotic legs
			{ id = 35517, count = 1, chance = 100 }, -- bast legs
			{ id = 35613, count = 1, chance = 100 }, -- ratmiral's hat
		},
		["Timira the Many-Headed"] = {
			{ id = 39160, count = 1, chance = 100 }, -- naga quiver
			{ id = 39155, count = 1, chance = 100 }, -- naga sword
			{ id = 39156, count = 1, chance = 100 }, -- naga axe
			{ id = 39157, count = 1, chance = 100 }, -- naga club
			{ id = 39162, count = 1, chance = 100 }, -- naga wand
			{ id = 39163, count = 1, chance = 100 }, -- naga rod
			{ id = 39159, count = 1, chance = 100 }, -- naga crossbow
			{ id = 50160, count = 1, chance = 100 }, -- naga katar
			{ id = 50262, count = 1, chance = 100 }, -- naga tanko
			{ id = 39165, count = 1, chance = 100 }, -- midnight tunic
			{ id = 39167, count = 1, chance = 100 }, -- midnight sarong
			{ id = 39164, count = 1, chance = 100 }, -- dawnfire sherwani
			{ id = 39166, count = 1, chance = 100 }, -- dawnfire pantaloons
			{ id = 39158, count = 1, chance = 100 }, -- frostflower boots
			{ id = 39161, count = 1, chance = 100 }, -- feverbloom boots
			{ id = 39233, count = 1, chance = 100 }, -- enchanted turtle amulet
		},
		["Dragon Hoard"] = {
			{ id = 44623, count = 1, chance = 100 }, -- arcane dragon robe
			{ id = 44621, count = 1, chance = 100 }, -- dauntless dragon scale armor
			{ id = 44753, count = 1, chance = 100 }, -- herald's insignia
			{ id = 44754, count = 1, chance = 100 }, -- herald's wings
			{ id = 50264, count = 1, chance = 100 }, -- merudri battle mail
			{ id = 44624, count = 1, chance = 100 }, -- mystical dragon robe
			{ id = 44622, count = 1, chance = 100 }, -- unerring dragon scale armor
		},
		["Mitmah Vanguard"] = {
			{ id = 44648, count = 1, chance = 100 }, -- stoic iks boots
			{ id = 44636, count = 1, chance = 100 }, -- stoic iks casque
			{ id = 44620, count = 1, chance = 100 }, -- stoic iks chestplate
			{ id = 44642, count = 1, chance = 100 }, -- stoic iks culet
			{ id = 44643, count = 1, chance = 100 }, -- stoic iks faulds
			{ id = 44637, count = 1, chance = 100 }, -- stoic iks headpiece
			{ id = 44649, count = 1, chance = 100 }, -- stoic iks sandals
			{ id = 44619, count = 1, chance = 100 }, -- stoic iks cuirass
			{ id = 50291, count = 1, chance = 100 }, -- iks footwraps
			{ id = 50255, count = 1, chance = 100 }, -- stoic iks robe
		},
		["Sugar Daddy"] = {
			{ id = 45641, count = 1, chance = 100 }, -- candy necklace
			{ id = 45644, count = 1, chance = 100 }, -- candy-coated quiver
			{ id = 45643, count = 1, chance = 100 }, -- biscuit barrier
			{ id = 45640, count = 1, chance = 100 }, -- creamy grimoire
			{ id = 45639, count = 1, chance = 100 }, -- cocoa grimoire
			{ id = 48114, count = 1, chance = 100 }, -- peppermint backpack
		},
		["The Brainstealer"] = {
			{ id = 36666, count = 1, chance = 100 }, -- eldritch quiver
			{ id = 36656, count = 1, chance = 100 }, -- eldritch shield
			{ id = 36663, count = 1, chance = 100 }, -- eldritch cuirass
			{ id = 36670, count = 1, chance = 100 }, -- eldritch cowl
			{ id = 36671, count = 1, chance = 100 }, -- eldritch hood
			{ id = 36664, count = 1, chance = 100 }, -- eldritch bow
			{ id = 36657, count = 1, chance = 100 }, -- eldritch claymore
			{ id = 36661, count = 1, chance = 100 }, -- eldritch greataxe
			{ id = 36659, count = 1, chance = 100 }, -- eldritch warmace
			{ id = 36672, count = 1, chance = 100 }, -- eldritch folio
			{ id = 36673, count = 1, chance = 100 }, -- eldritch tome
			{ id = 36674, count = 1, chance = 100 }, -- eldritch rod
			{ id = 36668, count = 1, chance = 100 }, -- eldritch wand
			{ id = 36667, count = 1, chance = 100 }, -- eldritch breeches
			{ id = 50266, count = 1, chance = 100 }, -- eldritch monk boots
			{ id = 50169, count = 1, chance = 100 }, -- eldritch crescent moon spade
		},
	},
}

local rouletteKv = kv.scoped("warizi-boss-roulette")

local function rowPos(x)
	return Position(x, config.row.y, config.row.z)
end

local function isRolling()
	local locked = rouletteKv:get("locked")
	return locked ~= nil and (os.time() - locked) < config.lockTimeoutS
end

local function setRolling(value)
	if value then
		rouletteKv:set("locked", os.time())
	else
		rouletteKv:remove("locked")
	end
end

local function cleanRow()
	for x = config.row.fromX, config.row.toX do
		local tile = Tile(rowPos(x))
		if tile then
			local items = tile:getItems()
			if items then
				for _, item in ipairs(items) do
					if item:getActionId() == config.displayActionId then
						item:remove()
					end
				end
			end
		end
	end
end

-- podium must be built detached so the addItem broadcast already carries
-- the podium attributes (client renders the boss on first sight)
local function spawnPodium(x, bossName)
	local mType = MonsterType(bossName)
	if not mType then
		print(("[WariziRoulette] MonsterType '%s' not found"):format(bossName))
		return nil
	end

	local podium = Game.createItem(config.podiumItemId, 1)
	if not podium then
		return nil
	end

	local outfit = mType:outfit() or {}
	podium:setCustomAttribute("PodiumMonsterRaceId", mType:raceId())
	podium:setCustomAttribute("LookType", outfit.lookType or 0)
	podium:setCustomAttribute("LookTypeEx", outfit.lookTypeEx or 0)
	podium:setCustomAttribute("LookHead", outfit.lookHead or 0)
	podium:setCustomAttribute("LookBody", outfit.lookBody or 0)
	podium:setCustomAttribute("LookLegs", outfit.lookLegs or 0)
	podium:setCustomAttribute("LookFeet", outfit.lookFeet or 0)
	podium:setCustomAttribute("LookAddons", outfit.lookAddons or 0)
	podium:setCustomAttribute("PodiumVisible", 1)
	podium:setCustomAttribute("MonsterVisible", 1)
	podium:setCustomAttribute("LookDirection", 2) -- south
	podium:setActionId(config.displayActionId)
	podium:moveTo(rowPos(x))
	return podium
end

local function spawnEntry(x, entry)
	if entry.kind == "boss" then
		return spawnPodium(x, entry.name)
	end

	local count = math.random(entry.minCount or 1, math.max(entry.minCount or 1, entry.maxCount or 1))
	local item = Game.createItem(entry.id, count, rowPos(x))
	if item then
		item:setActionId(config.displayActionId)
	end
	return item
end

local function shiftWest()
	-- remove entry leaving on the left, move everything one tile west
	local first = Tile(rowPos(config.row.fromX))
	if first then
		local items = first:getItems()
		if items then
			for _, item in ipairs(items) do
				if item:getActionId() == config.displayActionId then
					item:remove()
				end
			end
		end
	end

	for x = config.row.fromX + 1, config.row.toX do
		local tile = Tile(rowPos(x))
		if tile then
			local items = tile:getItems()
			if items then
				for _, item in ipairs(items) do
					if item:getActionId() == config.displayActionId then
						item:moveTo(rowPos(x - 1))
					end
				end
			end
		end
	end
end

local function pickEntry()
	local total = 0
	for _, entry in ipairs(config.entries) do
		total = total + entry.weight
	end
	local roll = math.random() * total
	for _, entry in ipairs(config.entries) do
		roll = roll - entry.weight
		if roll <= 0 then
			return entry
		end
	end
	return config.entries[#config.entries]
end

-- geometric deceleration: ~20ms first step to ~1s last, total = durationMs
local function buildDelays()
	local ratio = 1.1
	local raw, sum = {}, 0
	for i = 1, config.ticks do
		raw[i] = ratio ^ (i - 1)
		sum = sum + raw[i]
	end
	local delays = {}
	for i = 1, config.ticks do
		delays[i] = math.max(1, math.floor(raw[i] / sum * config.durationMs))
	end
	return delays
end

local function pickPrize(pool)
	local total = 0
	for _, entry in ipairs(pool) do
		total = total + math.max(1, entry.chance or 1)
	end
	local roll = math.random() * total
	for _, entry in ipairs(pool) do
		roll = roll - math.max(1, entry.chance or 1)
		if roll <= 0 then
			return entry
		end
	end
	return pool[#pool]
end

-- gems, jewels and coins can never come out of the roulette
local bannedLootPatterns = {
	"gem", "jewel", "diamond", "pearl", "ruby", "sapphire", "emerald",
	"amethyst", "topaz", "opal", "onyx", "quartz", "amber",
	"ingot", "nugget", " coin",
	"soap", "brush", "skin",
}

-- mount-granting items (usable_mount_items, mounts, phantasmal jade,
-- singeing steed, spirit of purity, music box)
local mountItemIds = {
	[23538] = true, [23684] = true, [23685] = true, [32629] = true, [50064] = true,
	[5907] = true, [52638] = true, [12308] = true, [12260] = true, [12318] = true,
	[12547] = true, [12548] = true, [16155] = true, [12307] = true, [12546] = true,
	[12550] = true, [28791] = true, [39548] = true, [21897] = true, [19136] = true,
	[31576] = true, [30171] = true, [12305] = true, [12801] = true, [16153] = true,
	[30170] = true, [14143] = true, [16154] = true, [14142] = true, [12306] = true,
	[16251] = true, [27605] = true, [21439] = true, [12549] = true, [12509] = true,
	[20274] = true, [24960] = true, [12519] = true, [12311] = true, [12304] = true,
	[12320] = true, [21186] = true, [17858] = true, [37397] = true, [12802] = true,
	[34258] = true, [43901] = true,
	[34072] = true, [34073] = true, [34074] = true, -- phantasmal jade pieces
	[36938] = true, -- singeing steed horseshoe
	[44048] = true, -- spirit of purity horseshoe
	[16244] = true, -- music box
}

-- addon/outfit-granting items (usable_outfit_items)
local addonItemIds = {
	[16252] = true, [16253] = true, [16254] = true, -- soil guardian
	[16255] = true, [16256] = true, [16257] = true, -- crystal warlord
	[27655] = true, [27656] = true, [27657] = true, -- makeshift warrior
	[31737] = true, [31738] = true, -- hand of the inquisition
	[32630] = true, [32631] = true, -- poltergeist
	[34075] = true, [34076] = true, -- revenant
	[43899] = true, [43900] = true, -- decaying defender
	[35595] = true, [35695] = true, -- rascoohan
	[39544] = true, [39545] = true, -- fire-fighter
	[50060] = true, [50061] = true, [50067] = true, -- fiend slayer
	[51656] = true, [51657] = true, -- illuminator
	[37604] = true, [37605] = true, -- lord retro
}

-- boss bags: random set pieces (soul war / rotten blood)
local bagItemIds = {
	[34109] = true, -- bag you desire
	[43895] = true, -- bag you covet
}

-- all mount + addon item ids, used when a boss has no qualifying loot:
-- the reward is still valuable (mount/addon item) instead of trash
local specialItemIds = {}
for id in pairs(mountItemIds) do
	table.insert(specialItemIds, id)
end
for id in pairs(addonItemIds) do
	table.insert(specialItemIds, id)
end

-- rewards are limited to: mount items, addon items and class 3/4 gear.
-- Everything else (food, creature products, potions, junk) never drops.
local function isRewardable(itemId)
	if mountItemIds[itemId] or addonItemIds[itemId] or bagItemIds[itemId] then
		return true
	end

	local itemType = ItemType(itemId)
	if not itemType then
		return false
	end

	local name = (itemType:getName() or ""):lower()
	if name == "" then
		return false
	end

	for _, pattern in ipairs(bannedLootPatterns) do
		if name:find(pattern, 1, true) then
			return false
		end
	end

	-- off-hand gear is always rewardable (classification <3 would otherwise
	-- cut shields, spellbooks and quivers like eldritch shield / spirit guide)
	-- note: isSpellBook() returns 0/1 number in this binding, not a boolean
	if itemType:getWeaponType() == WEAPON_SHIELD or itemType:isSpellBook() == 1 or itemType:isQuiver() then
		return true
	end

	return (itemType:getClassification() or 0) >= 3
end

local function rollBossLoot(bossEntry)
	local override = config.prizeOverride and config.prizeOverride[bossEntry.name]
	if override and #override > 0 then
		-- uniform pick: every item in the boss' reward list has the same chance
		local picked = override[math.random(#override)]
		return { id = picked.id, count = picked.count or 1 }
	end

	local mType = MonsterType(bossEntry.name)
	if not mType then
		return nil
	end

	local threshold = bossEntry.rareThreshold or config.rareThreshold
	local loot = mType:getLoot() or {}
	local rares, candidates = {}, {}
	for _, entry in ipairs(loot) do
		if entry.itemId and entry.itemId > 0 and isRewardable(entry.itemId) then
			table.insert(candidates, entry)
			if (entry.chance or 0) <= threshold then
				table.insert(rares, entry)
			end
		end
	end

	-- only rare drops qualify; when the boss has no rare drops defined,
	-- fall back to the loot table minus banned items (never gems/jewels)
	local pool = #rares > 0 and rares or candidates
	if #pool == 0 then
		-- boss has no mount/addon/class 3-4 loot: grant a random mount/addon item
		return { id = specialItemIds[math.random(#specialItemIds)], count = 1, rare = true }
	end

	-- gear (bags, class 3-4 equipment) takes priority: mount/addon items
	-- from the loot table only drop when the boss has no gear to give
	local gear, vanity = {}, {}
	for _, entry in ipairs(pool) do
		if mountItemIds[entry.itemId] or addonItemIds[entry.itemId] then
			table.insert(vanity, entry)
		else
			table.insert(gear, entry)
		end
	end

	-- uniform pick inside the priority pool
	local target = #gear > 0 and gear or vanity
	local picked = target[math.random(#target)]
	local minC = math.max(1, picked.minCount or 1)
	local maxC = math.max(minC, picked.maxCount or 1)
	return { id = picked.itemId, count = math.random(minC, maxC), rare = #rares > 0 }
end

local function deliverReward(playerGuid, winner, reward)
	local player = Player(playerGuid)
	setRolling(false)
	if not player then
		return
	end

	local container = player:getStoreInbox() or player:getInbox()
	if not container then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Roulette error: could not deliver your reward. Contact an admin.")
		return
	end

	local item = Game.createItem(reward.id, reward.count)
	if item then
		container:addItemEx(item)
		local itemName = ItemType(reward.id):getName()
		if winner.kind == "boss" then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("%s dropped %dx %s for you! Check your store inbox.", winner.name, reward.count, itemName))
			Game.broadcastMessage(string.format("%s won %dx %s from %s in the boss roulette!", player:getName(), reward.count, itemName, winner.name), MESSAGE_EVENT_ADVANCE)
		elseif winner.rare then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You won %dx %s in the roulette! Check your store inbox.", reward.count, itemName))
			Game.broadcastMessage(string.format("%s won %dx %s in the Warizi roulette!", player:getName(), reward.count, itemName), MESSAGE_EVENT_ADVANCE)
		else
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("The house wins... you got %dx %s. Check your store inbox.", reward.count, itemName))
		end

		if winner.kind == "boss" or winner.rare then
			for x = config.row.fromX, config.row.toX do
				rowPos(x):sendMagicEffect(math.random(CONST_ME_FIREWORK_YELLOW, CONST_ME_FIREWORK_BLUE))
			end
		end
	end
end

local function spin(playerGuid)
	local winner = pickEntry()
	local delays = buildDelays()
	local rewardTick = config.ticks - (config.row.toX - config.winX) -- entry created here lands on winX at the last tick
	local tick = 0

	local function step()
		tick = tick + 1
		shiftWest()
		spawnEntry(config.row.toX, tick == rewardTick and winner or pickEntry())

		if tick < config.ticks then
			addEvent(step, delays[tick + 1] or delays[config.ticks])
		else
			local center = rowPos(config.winX)
			rowPos(config.row.fromX):sendDistanceEffect(center, CONST_ANI_FIRE)
			rowPos(config.row.toX):sendDistanceEffect(center, CONST_ANI_FIRE)
			center:sendMagicEffect(CONST_ME_HOLYAREA)
			addEvent(function()
				if winner.kind == "boss" then
					local reward = rollBossLoot(winner)
					if reward then
						deliverReward(playerGuid, winner, reward)
					else
						-- boss has no mount/addon/class 3-4 loot: the house wins, deliver trash
						local trashIds = { 3111, 3112, 3113, 3114, 3122, 3129, 3106 }
						deliverReward(playerGuid, { kind = "item", rare = false }, { id = trashIds[math.random(#trashIds)], count = 1 })
					end
				else
					local count = math.random(winner.minCount or 1, math.max(winner.minCount or 1, winner.maxCount or 1))
					deliverReward(playerGuid, winner, { id = winner.id, count = count })
				end
			end, 500)
		end
	end

	addEvent(step, delays[1])
end

-- prefill the conveyor once the map is loaded
local conveyorSetup = GlobalEvent("WariziConveyorSetup")

function conveyorSetup.onStartup()
	cleanRow()
	for x = config.row.fromX, config.row.toX do
		spawnEntry(x, pickEntry())
	end

	-- audit: log every boss' qualifying reward pool
	local function auditLog(msg)
		print(msg)
		io.stdout:flush()
	end
	for _, entry in ipairs(config.entries) do
		if entry.kind == "boss" then
			local override = config.prizeOverride and config.prizeOverride[entry.name]
			if override and #override > 0 then
				local names = {}
				for _, p in ipairs(override) do
					table.insert(names, ItemType(p.id):getName())
				end
				auditLog(("[WariziRoulette] %s -> OVERRIDE: %s"):format(entry.name, table.concat(names, ", ")))
			else
				local mType = MonsterType(entry.name)
				local threshold = entry.rareThreshold or config.rareThreshold
				local pool = {}
				if mType then
					for _, loot in ipairs(mType:getLoot() or {}) do
						if loot.itemId and loot.itemId > 0 and isRewardable(loot.itemId) and (loot.chance or 0) <= threshold then
							table.insert(pool, ItemType(loot.itemId):getName())
						end
					end
				end
				auditLog(("[WariziRoulette] %s -> %d items: %s"):format(entry.name, #pool, table.concat(pool, ", ")))
			end
		end
	end
end

conveyorSetup:type("startup")
conveyorSetup:register()

local conveyorLever = Action()

function conveyorLever.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if isRolling() then
		player:sendCancelMessage("The roulette is still spinning. Wait for it to finish.")
		return true
	end

	if player:getItemCount(config.coinId) < config.coinCount then
		player:sendCancelMessage(string.format("You need %dx %s to spin the roulette.", config.coinCount, ItemType(config.coinId):getName()))
		return true
	end

	player:removeItem(config.coinId, config.coinCount)
	setRolling(true)

	-- lever visual
	local leverId = item:getId()
	local leverPos = item:getPosition()
	local other = ({ [2772] = 2773, [2773] = 2772 })[leverId]
	if other then
		item:transform(other)
		addEvent(function()
			local tile = Tile(leverPos)
			local lever = tile and tile:getItemById(other)
			if lever then
				lever:transform(leverId)
			end
		end, config.durationMs + config.resultHoldMs)
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The roulette is spinning...")
	spin(player:getGuid())
	return true
end

conveyorLever:aid(unpack(config.leverActionIds))
conveyorLever:register()
