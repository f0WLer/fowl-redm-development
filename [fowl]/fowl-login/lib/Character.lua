charid = nil

function awaitCharid()
	while currentChar == nil do
		Wait(500)
	end
	charid = currentChar
end	

Citizen.CreateThread(function()
	awaitCharid()
end)