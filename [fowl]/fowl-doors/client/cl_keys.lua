permkeys = {}
tempkeys = {}
masterKey = false
local charid
local keysLoaded = false

function awaitCharid()
	while charid == nil do
		charid = exports['fowl-login']:getCharid()
		Wait(500)
	end
end

--------
-- Permanent (database) keys
--------
function getPermkeys()
	TriggerServerEvent("doors:sv_getKeys", charid)
end

RegisterNetEvent("doors:cl_assignKeys")
AddEventHandler("doors:cl_assignKeys",function(keys, hasMasterKey)
	permkeys = keys
	masterKey = hasMasterKey
	keysLoaded = true
end)

function addPermkey(hash)
	if permkeys ~= nil then
		for k,v in pairs(permkeys) do
			if permkeys[k] == hash then
				return false
			end
		end
		table.insert(permkeys, hash)
	else
		permkeys = {hash}
	end
	return true
end

function removePermkey(hash)
	local removed = false
	local newKeys = {}
	if permkeys ~= nil then
		for k,v in pairs(permkeys) do
			if permkeys[k] ~= hash then
				table.insert(newKeys, permkeys[k])
			else
				removed = true
			end
		end
		if removed == true then
			permkeys = newKeys
			return true
		else
			return false
		end
	else
		return false
	end
end

function savePermkeys()
	TriggerServerEvent("doors:sv_updateKeys", charid, permkeys)
end

exports('AddPermanentKey', function(hash)
	local successful = addPermkey(hash)
	if successful == true then
		savePermkeys()
		return true
	else
		return false
	end
end)
exports('RemovePermanentKey', function(hash)
	local successful = removePermkey(hash)
	if successful == true then
		savePermkeys()
		return true
	else
		return false
	end
end)


Citizen.CreateThread(function()
	awaitCharid()
	getPermkeys()
end)


--------
-- Temporary (instance) keys
--------
function addTempkey(hash)
	for k,v in pairs(tempkeys) do
		if tempkeys[k] == hash then
			return false
		end
	end
	table.insert(tempkeys, hash)
	return true
end

function removeTempkey(hash)
	local removed = false
	local newKeys = {}
	for k,v in pairs(tempkeys) do
		if tempkeys[k] ~= hash then
			table.insert(newKeys, tempkeys[k])
		else
			removed = true
		end
	end
	if removed == true then
		tempkeys = newKeys
		return true
	else
		return false
	end
end

exports('AddTemporaryKey', function(hash)
	return addTempkey(hash)
end)
exports('RemoveTemporaryKey', function(hash)
	return removeTempkey(hash)
end)

-------
-- Master Key
-------
exports('GiveMasterKey', function()
	TriggerServerEvent("doors:sv_giveMasterKey",charid)
	masterKey = true
end)
exports('RevokeMasterKey', function()
	TriggerServerEvent("doors:sv_revokeMasterKey",charid)
	masterKey = false
end)

-------
-- Doors
-------
function playerHasKey(doorHash)
	if masterKey == true then return "master" end

	if permkeys ~= nil then
		for k,v in pairs(permkeys) do
			if permkeys[k] == doorHash then
				return true
			end
		end
	end

	if tempkeys ~= nil then
		for k,v in pairs(tempkeys) do
			if tempkeys[k] == doorHash then
				return true
			end
		end
	end

	return false
end