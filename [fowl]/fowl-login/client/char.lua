characters = nil
charData = nil
hasChars = nil
dataLoaded = nil
currentChar = nil
local newCharData = nil

RegisterNetEvent("login:cl_receiveCharacters")
AddEventHandler("login:cl_receiveCharacters", function(chars)
	characters = chars

	if chars ~= nil then
		hasChars = true
		TriggerServerEvent("login:sv_requestCharacterData", chars)
	else
		hasChars = false
	end
end)

RegisterNetEvent("login:cl_receiveCharacterData")
AddEventHandler("login:cl_receiveCharacterData", function(data)
	charData = data
	dataLoaded = true
end)

RegisterNetEvent("login:cl_receiveNewCharId")
AddEventHandler("login:cl_receiveNewCharId", function(charid)
	if newCharData ~= nil then
		local newChar = {}
		newChar["id"] = charid
		for k,v in pairs(newCharData) do
			newChar[k] = v
		end
		table.insert(charData, newChar)
		populateCharData()
	end
end)


function populateCharData()
	SendNUIMessage({populateCharWindow = true, charData = charData})
end

RegisterNUICallback("charWindowPopulated", function(data)
	SendNUIMessage({loginReady = true})
end)

RegisterNUICallback("createNewChar", function(data)
	TriggerServerEvent("login:sv_addCharacter", userid, data.charData)
	newCharData = data.charData
end)