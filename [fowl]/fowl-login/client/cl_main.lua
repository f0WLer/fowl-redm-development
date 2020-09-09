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

userid = nil
Citizen.CreateThread(function()
	userid = getUserid()
	TriggerServerEvent("login:sv_requestCharacters", userid)
	while not dataLoaded do
		Wait(100)
	end
	populateCharData()
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

-- [[ /////////// LOGIN //////////]]
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
--[[ ////////// CAMS //////////]]
function movePlayer(x, y, z)
	SetEveryoneIgnorePlayer(PlayerPedId(), true)
	SetEntityCoords(PlayerPedId(), x, y, z, false, false, false, false)
	FreezeEntityPosition(PlayerPedId(), true)
	SetEntityVisible(PlayerPedId(), false)
	SetEntityInvincible(PlayerPedId(), true)
end

local camCoords = {x = -5027.0, y = -3094.0, z = 300.0}
local point = {x = 3170.0, y = -56.0, z = 0.00}

function loadStartCam()
	local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
	SetCamFov(cam, 40.0)
    PointCamAtCoord(cam, point.x, point.y, point.z)
    RenderScriptCams(true, false, 0, true, true)

    return cam
end

function loadSpawnCam()
	local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
	SetCamFov(cam, 40.0)
    PointCamAtCoord(cam, point.x, point.y, point.z)

	return cam
end

function loadCityCam(cityId)
	local cityCam = spawnCams[cityId]
	movePlayer(cityCam.x, cityCam.y, 100.0)
	local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	SetCamCoord(cam, cityCam.x, cityCam.y, cityCam.z)
	SetCamFov(cam, 80.0)
	PointCamAtCoord(cam, cityCam.pointx, cityCam.pointy, cityCam.pointz)
	return cam		
end


function initiateLogin()
	DestroyAllCams(true)
	RenderScriptCams(false, false, 0, true, true)
	DisplayHud(false)

	movePlayer(camCoords.x, camCoords.y, camCoords.z)
	local startCam = loadStartCam()
	
	while IsLoadingScreenActive() ~= false do
		Wait(100)
	end
	movePlayer(camCoords.x, camCoords.y, camCoords.z)

	DrawHTML()
	NuiFocus(true)
	SendNUIMessage({initMenu = true});

	Wait(50)

	getCityScreenCoords()

	while currentChar == nil do
		Wait(100)
	end
	
	SendNUIMessage({initSpawnSelect = true})

	local selectedSpawn = nil
	local spawnConfirmed = false

	RegisterNUICallback("selectSpawn", function(data)
		selectedSpawn = data.spawnId
		SendNUIMessage({hideIcons = true, drawMenu = true})
		loadCityCam(selectedSpawn)
	end)

	RegisterNUICallback("cancelSpawn", function(data)
		selectedSpawn = nil
		SendNUIMessage({drawIcons = true, hideMenu = true})
		loadSpawnCam()
	end)

	RegisterNUICallback("confirmSpawn", function(data)
		spawnConfirmed = true
	end)

	repeat Wait(250) until spawnConfirmed ~= false

	SendNUIMessage({hideMenu = true})
	DisableHTML()
	NuiFocus(false)
	initiateSpawn(selectedSpawn)
end

Citizen.CreateThread(function()
	Wait(200)
	initiateLogin()
end) 