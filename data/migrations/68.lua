local function columnExists(tableName, columnName)
	local resultId = db.storeQuery(string.format("SELECT 1 FROM `information_schema`.`COLUMNS` WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = '%s' AND `COLUMN_NAME` = '%s' LIMIT 1;", tableName, columnName))
	if resultId then
		Result.free(resultId)
		return true
	end
	return false
end

function onUpdateDatabase()
	logger.info("Updating database to version 68 (war PvP progression and rewards)")

	db.query("UPDATE `worlds` SET `type` = 'retro-hardcore'")

	if not columnExists("players", "war_lifetime_frags") then
		db.query("ALTER TABLE `players` ADD `war_lifetime_frags` INT(11) UNSIGNED NOT NULL DEFAULT 0 AFTER `lock_reason`")
	end

	db.query([[
		CREATE TABLE IF NOT EXISTS `war_pvp_kills` (
			`id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
			`victim_id` INT(11) NOT NULL,
			`attacker_id` INT(11) NOT NULL,
			`damage` BIGINT(20) UNSIGNED NOT NULL DEFAULT 0,
			`damage_ratio` DECIMAL(8,6) NOT NULL DEFAULT 0.000000,
			`experience` BIGINT(20) UNSIGNED NOT NULL DEFAULT 0,
			`frag_coins` INT(11) UNSIGNED NOT NULL DEFAULT 0,
			`crystal_coins` INT(11) UNSIGNED NOT NULL DEFAULT 0,
			`forge_dust` INT(11) UNSIGNED NOT NULL DEFAULT 0,
			`created_at` BIGINT(20) UNSIGNED NOT NULL,
			PRIMARY KEY (`id`),
			INDEX `war_pvp_kills_victim` (`victim_id`),
			INDEX `war_pvp_kills_attacker` (`attacker_id`),
			CONSTRAINT `war_pvp_kills_victim_fk` FOREIGN KEY (`victim_id`) REFERENCES `players` (`id`) ON DELETE CASCADE,
			CONSTRAINT `war_pvp_kills_attacker_fk` FOREIGN KEY (`attacker_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
	]])
end
