Character = {}

Character.id = exports['fowl-login']:getCharid()

function Character.awaitId()
	Citizen.CreateThread(function()
		while Character.id == nil do
			Wait(500)
			Character.id = exports['fowl-login']:getCharid()
		end
	end)
end	

Character.awaitId()
