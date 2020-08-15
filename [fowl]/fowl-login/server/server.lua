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
	return characters
end

RegisterNetEvent("login:sv_requestCharacters")
AddEventHandler("login:sv_requestCharacters", function(userid)
	Citizen.CreateThread(function()
		awaitCharacterCount()
		local chars = getCharacter(userid)
		TriggerClientEvent("login:cl_receiveCharacters")
	end)
end)