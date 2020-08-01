local userid
RegisterNetEvent("postal:cl_receiveUserId")
AddEventHandler("postal:cl_receiveUserId", function(id)
	userid = id
end)
TriggerServerEvent("postal:sv_sendClientUserId")

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
end)
function NuiFocus(toggle)
	SetNuiFocus(toggle, toggle)
end
RegisterNUICallback("refocus", function(data)
	if hud == true then
		NuiFocus(true)
	end
end)
RegisterNUICallback("refreshInventory", function(data)
	if hud == true then
		print("Sending refresh")
		SendNUIMessage({refresh = true})
	end
end)
RegisterNUICallback("sendLetter", function(data)
	TriggerServerEvent("postal:sv_sendLetter", userid, data.letterid, data.to_userid)
end)
RegisterNUICallback("updateAddressData", function(data)
	TriggerServerEvent("postal:sv_updateAddressData", data.letterid, data.address, data.returnAddress)
end)


local valentinePost = {
	pos = vector3(-179.02,626.65,113.10),
	name = "Valentine Station",
	clerk = "U_M_O_RigTrainStationWorker_01",
	clerkpos = {x = -178.00, y = 628.10, z = 113.50, heading = 144.53},
}
local emeraldPost = {
	pos = vector3(1521.94,439.48,89.68),
	name = "Emerald Station",
	clerk = "S_M_M_TrainStationWorker_01",
	clerkpos = {x = 1521.94, y = 441.19, z = 90.68, heading = 180.34}
}
local rhodesPost = {
	pos = vector3(1225.56,-1293.99,75.88),
	name = "Rhodes Station",
	clerk = "U_M_M_RhdTrainStationWorker_01",
	clerkpos = {x = 1226.74, y = -1295.09, z = 76.91, heading = 46.22}
}
local saintdenisPost = {
	name = "Victoria Street Station",
	pos = vector3(2747.13,-1394.99, 45.16),
	clerk = "U_M_M_RhdTrainStationWorker_01",
	clerkpos = {x = 2747.88, y = -1396.44, z = 46.183, heading = 24.14}
}
--[[local vanhornPost = {
	name = "Van Horn depot",
	pos = vector3(2985.96,568.56, 43.63),
	--clerk = "S_M_M_TrainStationWorker_01",
}]]
local annesburgPost = {
	name = "Annesburg Post OFfice",
	pos = vector3(2939.56,1288.71,43.57),
	clerk = "S_M_M_TrainStationWorker_01",
	clerkpos = {x = 2938.87, y = 1286.85, z = 44.65, heading = 340.72}
}
local riggsPost = {
	name = "Riggs Station",
	pos = vector3(-1094.22, -574.93, 81.40),
	clerk = "U_M_O_RigTrainStationWorker_01",
	clerkpos = {x = -1092.99, y = -575.88, z = 82.41, heading = 51.68}
}
local wallacePost = {
	name = "Wallace Station",
	pos = vector3(-1301.08, 398.84, 94.38),
	clerk = "U_M_O_RigTrainStationWorker_01",
	clerkpos = {x = -1300.37, y = 400.19, z = 94.50, heading = 152.12}
}
local strawberryPost = {
	name = "Strawberry Depot",
	pos = vector3(-1765.11,-384.14, 156.68),
	clerk = "U_M_M_BlWTrainStationWorker_01",
	clerkpos = {x = -1763.73, y = -385.13, z = 157.65, heading = 54.22}
}
local blackwaterPost = {
	name = "Union Freight Depot",
	pos = vector3(-875.02, -1328.75, 42.93),
	clerk = "U_M_M_BlWTrainStationWorker_01",
	clerkpos = {x = -874.98, y = -1327.08, z = 43.97, heading = 178.20}
}
local benedictpointPost = {
	name = "Benedict Point Station",
	pos = vector3(-5227.37, -3470.58, -21.57),
	clerk = "U_M_M_TUMTRAINSTATIONWORKER_01",
	clerkpos = {x = -5227.32, y = -3469.02, z = -20.57, heading = 178.40}
}
local armadilloPost = {
	name = "Amadillo Station",
	pos = vector3(-3734.00, -2597.88, -13.93),
	clerk = "U_M_M_ARMTRAINSTATIONWORKER_01",
	clerkpos = {x = -3732.29, y = -2597.95, z = -12.94, heading = 88.92}
}

local postOffices = {
	valentinePost,
	emeraldPost,
	rhodesPost,
	saintdenisPost,
	--vanhornPost,
	annesburgPost,
	riggsPost,
	wallacePost,
	strawberryPost,
	blackwaterPost,
	benedictpointPost,
	armadilloPost,
}
local currentOffice = nil
local activationDistance = 250

function searchOffice()
	local playerPos = GetEntityCoords(PlayerPedId())
	local officeFound = false
	for k,office in pairs(postOffices) do
		local distance = Vdist2(playerPos, office.pos)
		if distance < activationDistance then
			officeFound = true
			if currentOffice ~= office then
				runPostOffice(office)
			end
			break
		end
	end
	if officeFound ~= true then
		currentOffice = nil
	end
end	

Citizen.CreateThread(function()
	Wait(80)
	LockDoors()

	--DrawHTML()
	--NuiFocus(true)

	local refreshMs = 5000
	while true do
		searchOffice()
		Wait(refreshMs)
	end
end)

function runPostOffice(office)
	currentOffice = office
	local coords = office.pos

	-- Clerk
	local clerk
	if office.clerk then
		clerk = SpawnClerk(office.clerk, office.clerkpos)
		local tasks = {"WORLD_HUMAN_SHOPKEEPER_MALE_A","WORLD_HUMAN_SHOPKEEPER_MALE_B","WORLD_HUMAN_SHOPKEEPER_MALE_C"}
		Wait(50)
		TaskStartScenarioInPlace(clerk, GetHashKey(tasks[math.random(#tasks)]), 0, false, 0, 0, false)
	end

	local promptGroup = 28
	local promptGroupTitle = CreateVarString(10, "LITERAL_STRING", "Post Office")
	local prompt_Enter = CreatePrompt("Access", 0xC7B5340A --[[Enter]], false, promptGroup)

	while currentOffice == office do
		Wait(0)
		local playerPos = GetEntityCoords(PlayerPedId())
		local distance = Vdist2(playerPos, office.pos)
		if distance > activationDistance then
			DeletePed(clerk)
			currentOffice = nil
		end
		if distance < 2 then
			PromptSetActiveGroupThisFrame(promptGroup, promptGroupTitle)
			if PromptHasStandardModeCompleted(prompt_Enter) then
				DrawHTML()
				NuiFocus(true)
			end
		end
		-- Marker
		Citizen.InvokeNative(0x2A32FAA57B937173,-1795314153, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.35, 0.35, 0.20, 255, 0, 0, 30, false, false, 2, nil, nil, false)
	end
	PromptSetEnabled(prompt_Enter, false)
	PromptSetVisible(prompt_Enter, false)
	PromptDelete(prompt_Enter)
end

function CreatePrompt(name, key, hold, group)
	local Prompt
    Citizen.CreateThread(function()
        local str = name
        local wait = 0
    Prompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(Prompt, key)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(Prompt, str)
        PromptSetEnabled(Prompt, true)
        PromptSetVisible(Prompt, true)
        if group ~= nil then
        	PromptSetGroup(Prompt, group)
        end
        if hold == true then
       		PromptSetHoldMode(Prompt, true)
       	else
       		PromptSetStandardMode(Prompt, true)
       	end
        PromptRegisterEnd(Prompt)
    end)
    Wait(30)
   	return Prompt
end

function SpawnClerk(model, pos)
	local hash = GetHashKey(model)
	RequestModel(hash,0)
	while not HasModelLoaded(hash) do
		RequestModel(hash,0)
		Wait(0)
 	end

	local ped = CreatePed(model, pos.x, pos.y, pos.z, pos.heading, false, false)
	local timeout = 0

	SetPedOutfitPreset(ped, true, false)
	Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
	RequestCollisionAtCoord(pos.x, pos.y, pos.z)

	while not HasCollisionLoadedAroundEntity(ped) and timeout < 2000 do
		Citizen.Wait(0)
		timeout = timeout + 1
	end
	SetModelAsNoLongerNeeded(hash)

	SetEntityAsMissionEntity(ped, false, false)
	SetEntityAsNoLongerNeeded(ped)
	SetPedCanBeTargetted(ped, false)
	SetPedCanPlayAmbientAnims(ped, true)
	SetPedCanPlayAmbientBaseAnims(ped, true)
	SetPedCanRagdollFromPlayerImpact(ped, false)
	SetPedCanRagdoll(ped, false)
	SetBlockingOfNonTemporaryEvents(ped, true)
	SetPedFleeAttributes(ped, 0, 0)
	SetEntityInvincible(ped, true)
	SetEntityCanBeDamaged(ped, false)

	return ped
end

function LockDoors()
	local function DoorSystemRegisterDoor(doorHash)
		Citizen.InvokeNative(0xD99229FE93B46286,doorHash,1,1,0,0,0,0)
	end
	local doors = {
	283382142, -- Valentine
	2057841001, -- Emerald Station
	1405538538, -- Rhodes
	1915401053, -- Saint Denis
	1898720605, -- Annesburg
	1217836331, -- Riggs
	1039842904, -- Wallace
	1335840261, -- Strawberry
	1730262833, -- Blackwater
	411637818, -- Benedict Point
	238975959, -- Armadillo
	}
	for _,door in pairs(doors) do
		if IsDoorRegisteredWithSystem(door) == false then
			DoorSystemRegisterDoor(door)
		end
		DoorSystemSetDoorState(door, 1)
	end
end

RegisterNUICallback("requestLetters", function(data)
	TriggerServerEvent("postal:sv_requestLetters", userid)
end)

RegisterNUICallback("requestLetterData", function(data)
	TriggerServerEvent("postal:sv_requestLetterData", data.letterid)
end)


RegisterNetEvent("postal:cl_receiveLetters")
AddEventHandler("postal:cl_receiveLetters", function(letterinfo)
	SendNUIMessage({letters = json.encode(letterinfo)})
end)

RegisterNetEvent("postal:cl_receiveLetterData")
AddEventHandler("postal:cl_receiveLetterData", function(letterData)
	SendNUIMessage({letterData = json.encode(letterData)})
end)