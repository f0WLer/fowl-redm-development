local characterCount
Citizen.CreateThread(function()
	characterCount = MySQL2.Sync.fetchScalar("SELECT COUNT(charid) FROM characters",{})
end)

function awaitCharacterCount()
	while characterCount == nil do
		Wait(0)
	end
end

function addCharacter(userid)
	local characterid = nil
	if characterCount ~= 0 then
		local latestId = MySQL2.Sync.fetchScalar("SELECT * FROM characters ORDER BY charid DESC LIMIT 1",{})
		characterid = math.floor(latestId + 1)
	else
		characterid = 1	
	end

	MySQL2.Async.execute("INSERT INTO `characters` (charid, userid) VALUES(?, ?)",
		{characterid,userid})
	characterCount = characterCount + 1
	return characterid
end

function getCharacters(userid)
	local characters = {}
	local finished = false
	MySQL2.Async.fetchAll("SELECT * FROM `characters` WHERE `userid` = ?",{userid},function(results) 
		for k,v in pairs(results) do
			table.insert(characters, results[k]["charid"])
		end
		finished = true
	end)
	repeat Wait(0) until finished == true
	
	for _,_ in pairs(characters) do
		return characters
	end
	return nil
end

function getCharacterData(source, chars)
	charData = {}
	for _,charid in pairs(chars) do
		local data = {
			firstname = nil,
			lastname = nil,
		}

		local queryResult = MySQL2.Sync.fetchAll("SELECT * FROM `character_data` WHERE `charid` = ?",{charid})

		data.lastname = queryResult[1].lastname
		data.firstname = queryResult[1].firstname
		data.id = charid

		charData[charid]=data
	end
	TriggerClientEvent("login:cl_receiveCharacterData", source, charData)
end

RegisterNetEvent("login:sv_requestCharacters")
AddEventHandler("login:sv_requestCharacters", function(userid)
	local player = source
	Citizen.CreateThread(function()
		awaitCharacterCount()
		local chars = getCharacters(userid)
		TriggerClientEvent("login:cl_receiveCharacters", player, chars)
	end)
end)

RegisterNetEvent("login:sv_requestCharacterData")
AddEventHandler("login:sv_requestCharacterData", function(chars)
	local source = source
	Citizen.CreateThread(function()getCharacterData(source, chars)end)
end)

RegisterNetEvent("login:sv_secureLogin")
AddEventHandler("login:sv_secureLogin", function(userid, charid)
	local player = source
	local charValid = MySQL2.Sync.fetchScalar("SELECT COUNT(*) FROM `characters` WHERE `charid` = ? AND `userid` = ?",{charid, userid})
	if charValid == 1 then
		TriggerClientEvent("login:cl_loginCharacter", player, charid)
	else
		TriggerClientEvent("login:cl_denyLogin", player)
	end
end)