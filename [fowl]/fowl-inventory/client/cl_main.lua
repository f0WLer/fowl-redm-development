local charid

function awaitCharid()
	while charid == nil do
		charid = exports['fowl-login']:getCharid()
		Wait(500)
	end
end
Citizen.CreateThread(function()
    awaitCharid()
end)

Citizen.CreateThread(function()
    SetNuiFocus(true, true)
end)