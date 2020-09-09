function getKeys(charid)
	local keys = MySQL2.Sync.fetchScalar("SELECT JSON_QUERY(doorkeys, '$') AS 'keys' FROM `door_keys` WHERE charid = ?",{charid})
	return keys
end

function updateKeys(charid, jsonString)
	if jsonString ~= "[]" then
		MySQL2.Async.execute(
			"INSERT INTO `door_keys` (charid, doorkeys) VALUES(?, ?) "..
			"ON DUPLICATE KEY UPDATE `doorkeys` = ?",
			{charid, jsonString, jsonString}
		)
	else
		MySQL2.Async.execute(
			"DELETE FROM `door_keys` WHERE `charid` = ?",
			{charid}
		)
	end
end

function hasMasterKey(charid)
	local masterKeyHolder =  MySQL2.Sync.fetchScalar(
		"SELECT COUNT(`charid`) FROM `door_masterkeys` WHERE `charid` = ?",
		{charid})
	if masterKeyHolder == 0 or masterKeyHolder == nil then
		return false
	else
		return true
	end
end

RegisterNetEvent("doors:sv_giveMasterKey")
AddEventHandler("doors:sv_giveMasterKey", function(charid)
	MySQL2.Async.execute("INSERT IGNORE INTO `door_masterkeys` (`charid`) VALUES(?)",{charid})
end)

RegisterNetEvent("doors:sv_revokeMasterKey")
AddEventHandler("doors:sv_revokeMasterKey", function(charid)
	MySQL2.Async.execute("DELETE FROM `door_masterkeys` WHERE `charid` = ?",{charid})
end)

RegisterNetEvent("doors:sv_getKeys")
AddEventHandler("doors:sv_getKeys", function(charid)
	local player = source
	local keys
	local masterKey
	Citizen.CreateThread(function()
		keys = exports["fowl-doors"]:sortKeys(getKeys(charid))
		masterKey = hasMasterKey(charid)
		TriggerClientEvent("doors:cl_assignKeys",player,keys, masterKey)
	end)
end)

RegisterNetEvent("doors:sv_updateKeys")
AddEventHandler("doors:sv_updateKeys", function(charid, keys)
	Citizen.CreateThread(function()
		local jsonString = "["
		for k,v in pairs(keys) do
			jsonString = jsonString .. tostring(keys[k]) .. ","
		end
		if jsonString ~= "[" then
			jsonString = jsonString:sub(1, -2).."]"
		else
			jsonString = "[]"
		end

		updateKeys(charid, jsonString)
	end)
end)
