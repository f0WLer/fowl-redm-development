--[[ Example Array
local officers = {
	[1] = {
		firstName = "Edward",
		lastName = "Phillips",
	},
	[2] = {
		firstName = "Moses",
		lastName = "Buck",
	},
	[3] = {
		firstName = "Willie",
		lastName = "Nielsen",
	},
	[4] = {
		firstName = "Floyd",
		lastName = "Riggs",
	},
}
]]

function showLEO()
	SendNUIMessage({showLEO = true})
end

function hideLEO()
	SendNUIMessage({hideLEO = true})
end


function addLEO(charId, firstName, lastName)
	SendNUIMessage({addLEO = true, charId = charId, firstName = firstName, lastName = lastName})
end

function removeLEO(charId)
	SendNUIMessage({removeLEO = true, charId = charId})
end