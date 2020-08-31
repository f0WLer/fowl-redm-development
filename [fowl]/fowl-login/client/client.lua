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
function initiateSpawn(spawnCity)
	DoScreenFadeOut(500)
	Wait(500)
	DisplayHud(true)
	RenderScriptCams(false)
	local crd = spawnPoints[spawnCity]
	SetEntityCoords(PlayerPedId(),crd.x, crd.y, crd.z, false, false, false, false)
	SetEntityInvincible(PlayerPedId(), false)
	FreezeEntityPosition(PlayerPedId(), false)
	SetEveryoneIgnorePlayer(PlayerPedId(), false)
	SetEntityAlpha(PlayerPedId(), 0, false)
	local playerAlpha = 0
	SetEntityVisible(PlayerPedId(), true)
	while playerAlpha < 255 do
		Wait(25)
		playerAlpha = playerAlpha + 5
		SetEntityAlpha(PlayerPedId(), playerAlpha, false)
	end
	SetEntityAlpha(PlayerPedId(), playerAlpha, false)
	DoScreenFadeIn(3000)
end

function initiateLogin()
	DestroyAllCams(true)
	RenderScriptCams(false, false, 0, true, true)

	--local camCoords = {x = 300.0, y = -2400.0, z = 300.0}
	--local point = {x = 500.0, y = 0.0, z = 0.00}
	
	local camCoords = {x = -5027.0, y = -3094.0, z = 300.0}
	local point = {x = 3170.0, y = -56.0, z = 0.00}

	function movePlayer(x, y, z)
		SetEveryoneIgnorePlayer(PlayerPedId(), true)
		SetEntityCoords(PlayerPedId(), x, y, z, false, false, false, false)
		FreezeEntityPosition(PlayerPedId(), true)
		SetEntityVisible(PlayerPedId(), false)
		SetEntityInvincible(PlayerPedId(), true)
	end

	function loadStartCam()
		local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	    SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
		--SetCamFov(cam, 100.0)
		SetCamFov(cam, 40.0)
	    PointCamAtCoord(cam, point.x, point.y, point.z)
	    RenderScriptCams(true, false, 0, true, true)

	    return cam
	end

	function loadSpawnCam()
		local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	    SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
		--SetCamFov(cam, 100.0)
		SetCamFov(cam, 40.0)
	    PointCamAtCoord(cam, point.x, point.y, point.z)

		return cam
	end

	function loadCityCam(cityId)
		local cams = {[1] = cam_bla, [2] = cam_arm, [3] = cam_val, [4] = cam_ann, [5] = cam_san}
		local city = cams[cityId]
		movePlayer(city.x, city.y, 100.0)
		local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
		SetCamCoord(cam, city.x, city.y, city.z)
		SetCamFov(cam, 80.0)
		PointCamAtCoord(cam, city.pointx, city.pointy, city.pointz)
		return cam		
	end

	function transitionCam(fromCam, toCam, duration)
		SetCamActiveWithInterp(toCam, fromCam, duration, true, true)
		RenderScriptCams(true, false, 0, true, true)
	end

	movePlayer(camCoords.x, camCoords.y, 120.0)
	local startCam = loadStartCam()
	DisplayHud(false)
	
	while IsLoadingScreenActive() ~= false do
		Wait(100)
	end

	getCityScreenCoords()
	SendNUIMessage({initMenu = true});
	DrawHTML()
	NuiFocus(true)
	repeat Wait(100) until currentChar ~= nil
	
	SendNUIMessage({initSpawnSelect = true})
	local spawnMenuCam = loadSpawnCam()
	transitionCam(startCam, spawnMenuCam, 1000)

 	
	local selectedSpawn = nil
	local spawnConfirmed = false

	RegisterNUICallback("selectSpawn", function(data)
		selectedSpawn = data.spawnId
		SendNUIMessage({hideIcons = true})
		SendNUIMessage({drawMenu = true})
		loadCityCam(selectedSpawn)
	end)

	RegisterNUICallback("cancelSpawn", function(data)
		selectedSpawn = nil
		SendNUIMessage({drawIcons = true})
		SendNUIMessage({hideMenu = true})
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

local currentChar

Citizen.CreateThread(function()
	Wait(200)
	initiateLogin()
	
	--dRenderScriptCams(false)
	--NuiFocus(false)
	--print(GetWaypointCoords())
end) 