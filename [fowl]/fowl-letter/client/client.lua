local userid
RegisterNetEvent("letter:cl_receiveUserId")
AddEventHandler("letter:cl_receiveUserId", function(id)
	userid = id
end)
TriggerServerEvent("letter:sv_sendClientUserId")

-- Net Events
RegisterNetEvent("letter:cl_OpenLetter")
AddEventHandler("letter:cl_OpenLetter", function(letterid, iscreator, body)
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
	TriggerServerEvent("letter:sv_OpenLetter", userid, letterid)
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