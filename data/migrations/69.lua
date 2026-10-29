local function columnExists(tableName, columnName)
	local resultId = db.storeQuery(string.format("SELECT 1 FROM `information_schema`.`COLUMNS` WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = '%s' AND `COLUMN_NAME` = '%s' LIMIT 1;", tableName, columnName))
	if resultId then
		Result.free(resultId)
		return true
	end
	return false
end

function onUpdateDatabase()
	logger.info("Updating database to version 69 (war KDA rank deaths)")
	if not columnExists("players", "war_deaths") then
		db.query("ALTER TABLE `players` ADD `war_deaths` INT(11) UNSIGNED NOT NULL DEFAULT 0 AFTER `war_lifetime_frags`")
	end
	db.query("UPDATE `players` SET `town_id` = 1, `posx` = 1048, `posy` = 1065, `posz` = 10, `istutorial` = 0")
end
