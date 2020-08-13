function getUserid()
	local userid
	RegisterNetEvent("fowl:setUserid")
	local event = AddEventHandler("fowl:setUserid", function(id)
		userid = id
	end)
	TriggerEvent("user:getUserid", "fowl:setUserid")
	while userid == nil do
		TriggerEvent("user:getUserid", "fowl:setUserid")
		Wait(20)
	end
	RemoveEventHandler(event)
	return userid
end

local userid
Citizen.CreateThread(function() userid = getUserid() end)

-- Net Events
RegisterNetEvent("letter:cl_OpenLetter")
AddEventHandler("letter:cl_OpenLetter", function(letterid, iscreator, body)
	cacheFlush()
	cacheAdd(letterid, body, iscreator)
	if iscreator == false then
		ReadLetter(body)
	else
		WriteLetter(letterid, body)
	end
end)

RegisterNUICallback("RequestLetter", function(data)
	RequestLetter(data.letterid)
end)

RegisterNUICallback("tossLetter", function(data)
	TriggerServerEvent("letter:sv_DeleteLetter", data.letterid)
end)

RegisterNUICallback("writeLetter", function(data)
	TriggerServerEvent("letter:sv_NewLetter")
end)
--[[ /////////Caching///////////// ]]

local cache = {}

function cacheAdd(letterid, body, iscreator)
	letter = {
		letterid = letterid,
		body = body,
		iscreator = iscreator
	}
	cache[letterid] = letter
end

function cacheFlush()
	local count = 0
	for _ in pairs(cache) do count = count + 1 end
	if count >= 10 then
		cache = {}
	end
end

function cacheRead(letterid)
	for letter in pairs(cache) do
		if cache[letter].letterid == letterid then
			return cache[letter].body, cache[letter].iscreator
		end
	end
end

function isCached(letterid)
	for letter in pairs(cache) do
		if letter == letterid then
			return true
		end
	end
	return false
end
--[[ /////////////////////////////// ]]
local hud = false

function DrawHTML()
	hud = true
	SendNUIMessage({DrawHTML = true})
end
function DisableHTML()
	hud = false
	SendNUIMessage({DrawHTML = false})
end
RegisterNUICallback('exit', function()
	DisableHTML()
	NuiFocus(false)
	SendNUIMessage({Letter = false})
end)
function NuiFocus(toggle)
	SetNuiFocus(toggle, toggle)
end

function RequestLetter(letterid)
	if isCached(letterid) == false then
		TriggerServerEvent("letter:sv_OpenLetter", userid, letterid)
	else
		local body,iscreator = cacheRead(letterid)
		if iscreator == false then
			ReadLetter(body)
		else
			WriteLetter(letterid, body)
		end
	end
end

function ReadLetter(body)
	DrawHTML()
	NuiFocus(true)
	SendNUIMessage({Letter = true, body = body, mode = "read"})
end

function WriteLetter(letterid, body)
	DrawHTML()
	NuiFocus(true)
	SendNUIMessage({Letter = true, mode = "write", letterid = letterid, body = body})
end

RegisterNUICallback("update-letter", function(data)
	TriggerServerEvent("letter:sv_UpdateLetter", data.letterid, data.body)
end)

Citizen.CreateThread(function()
	Wait(30)
end)
