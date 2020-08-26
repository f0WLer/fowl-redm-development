function getUserid()
	local userid
	RegisterNetEvent("fowl:setUserid")
	local event = AddEventHandler("fowl:setUserid", function(id)
		userid = id
	end)
	while userid == nil do
		TriggerEvent("user:getUserid", "fowl:setUserid")
		Wait(20)
	end
	RemoveEventHandler(event)
	return userid
end

local userid
local characters
local charData

local hasChars
local dataLoaded

Citizen.CreateThread(function()
	userid = getUserid()
	TriggerServerEvent("login:sv_requestCharacters", userid)
	while not dataLoaded do
		Wait(100)
	end
	loadUI()
end)

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

--[[ ///////// HTML ////////// ]]
local hud = false
function DrawHTML()
	hud = true
	SendNUIMessage({DrawHTML = true})
end
function DisableHTML()
	hud = false
	SendNUIMessage({DrawHTML = false})
end
function NuiFocus(toggle)
	SetNuiFocus(toggle, toggle)
end
RegisterNUICallback("refocus", function(data)
	if hud == true then
		NuiFocus(true)
	end
end)
--[[ ////////// //////////]]

function loadUI()
	SendNUIMessage({populateCharWindow = true, charData = charData})
end

RegisterNUICallback("charWindowPopulated", function(data)
	SendNUIMessage({loginReady = true})
end)

-- [[ /////////// login //////////]]
local canLogin = true
local coolingDown = false
local loginAttempts = 0
function updateLoginPrompt(text)
	SendNUIMessage({loginPrompt = true, loginPromptContent = text})
end

RegisterNUICallback("selectChar", function(data)
	if canLogin == true then
		TriggerServerEvent("login:sv_secureLogin", userid, data.charid)
		updateLoginPrompt("requesting login...")
		Citizen.CreateThread(function()limitLogins()end)
	else
		updateLoginPrompt("too many login attempts. please wait to try again.")
	end
end)

RegisterNetEvent("login:cl_loginCharacter")
AddEventHandler("login:cl_loginCharacter", function(charid)
	updateLoginPrompt("logged in.")
	currentChar = charid
end)

RegisterNetEvent("login:cl_denyLogin")
AddEventHandler("login:cl_denyLogin", function(charid)
	updateLoginPrompt("login failed. verify this character is yours and try again.")
end)

function limitLogins()
	loginAttempts = loginAttempts + 1
	if loginAttempts >= 4 then
		canLogin = false
	end
	if canLogin == false and coolingDown == false then
		coolingDown = true
		Wait(3 * 1000)
		canLogin = true
		coolingDown = false
		updateLoginPrompt("  ")
	end

end
--[[ ////////// //////////]]

function initiateLogin()
	local startCam
	DrawHTML()
	NuiFocus(true)

	DestroyAllCams(true)
	RenderScriptCams(false, false, 0, true, true)

	local camCoords = {x = -306.40, y = 790.90, z = 300.00}
	function loadStartCam()
		local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	    SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
	    PointCamAtCoord(cam, camCoords.x, camCoords.y, 0.0)
	    --SetCamActive(cam, true)
	    RenderScriptCams(true, false, 0, true, true)

	    startCam = cam
	end

	function transitionCam()
		local zoomCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
		SetCamCoord(zoomCam, camCoords.x, camCoords.y, 120.0)
		SetCamActiveWithInterp(zoomCam, startCam, 3700, true, true)
		RenderScriptCams(true, false, 0, true, true)
	end

	loadStartCam()

	repeat Wait(100) until currentChar ~= nil
	
	DisableHTML()
	NuiFocus(false)
	transitionCam()
end

local currentChar

Citizen.CreateThread(function()
	initiateLogin()

end)