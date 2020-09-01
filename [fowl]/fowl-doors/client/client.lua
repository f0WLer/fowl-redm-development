--[[ ///// PROMPTS ///// ]]
function createPrompt(name, key, hold, group)
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

local promptGroup
local promptGroupTitle
local prompt_lock
local prompt_unlock
Citizen.CreateThread(function()
	promptGroup = 4545
	promptGroupTitle = CreateVarString(10, "LITERAL_STRING", "Door")
	prompt_lock = createPrompt("Lock", 0x0522B243 --[[F]], false, promptGroup)
	prompt_unlock = createPrompt("Unlock", 0x0522B243 --[[F]], false, promptGroup)
	PromptSetEnabled(prompt_unlock, false)
	PromptSetVisible(prompt_unlock, false)
	PromptSetEnabled(prompt_lock, false)
	PromptSetVisible(prompt_unlock, false)
end)
--[[ ////////// ]]

function DoorSystemRegisterDoor(doorHash)
	Citizen.InvokeNative(0xD99229FE93B46286,doorHash,1,1,0,0,0,0)
end


function getSurroundingDoors(x, y, z, radius)
	return exports["fowl-doors"]:getSurroundingDoors(x, y, z, radius)
end


local crd
local radius = Config.Radius
local doorActiveRange = Config.DoorActivationRange
local surroundingDoors
local nearbyDoor
local zone = {
	x = nil,
	y = nil,
	z = nil,
	xmin = nil,
	xmax = nil,
	ymin = nil,
	ymax = nil,
}

function createZone()
	crd = GetEntityCoords(PlayerPedId())
	zone.x = crd.x
	zone.y = crd.y
	zone.z = crd.z
	zone.xmin = (crd.x - radius)
	zone.xmax = (crd.x + radius)
	zone.ymin = (crd.y - radius)
	zone.ymax = (crd.y + radius)
	surroundingDoors = getSurroundingDoors(crd.x, crd.y, crd.z, radius)
	cleanHashes()
end

function cleanHashes()
	for k,v in pairs(surroundingDoors) do
		local door = surroundingDoors[k]
		local oldHash = tostring(door.hash)
		local newHash = oldHash:gsub("%.0","")
		door.hash = tonumber(newHash)
	end
end

function ensureInZone()
	if crd.x < zone.xmin or crd.x > zone.xmax or crd.y < zone.ymin or crd.y > zone.ymax then
		createZone() 
	end
end

function getNearbyDoor()
	for k,v in pairs(surroundingDoors) do
		local door = surroundingDoors[k]
		if GetDistanceBetweenCoords(crd.x, crd.y, crd.z, door.x, door.y, door.z, true) <= doorActiveRange then
			return door
		end
	end
	return nil
end

function lockDoor(doorHash)
	DoorSystemSetDoorState(doorHash, 1)
end

function unlockDoor(doorHash)
	DoorSystemSetDoorState(doorHash, 0)
end

function handlePrompts(doorState)
	if doorState == 1 or doorState == -1 then
		PromptSetVisible(prompt_unlock, true)
		PromptSetEnabled(prompt_unlock, true)

		PromptSetVisible(prompt_lock, false)
		PromptSetEnabled(prompt_lock, false)
		--[[ key conditions go here ]]
	elseif doorState == 0 then
		PromptSetVisible(prompt_lock, true)
		PromptSetEnabled(prompt_lock, true)

		PromptSetVisible(prompt_unlock, false)
		PromptSetEnabled(prompt_unlock, false)
		--[[ key conditions go here ]]
	end
end

function promptsListen(doorHash)
	if PromptHasStandardModeCompleted(prompt_unlock) then
		unlockDoor(doorHash)
	elseif PromptHasStandardModeCompleted(prompt_lock) then
		lockDoor(doorHash)
	end
end

function handleNearbyDoor()
	local door = nearbyDoor
	doorHash = door.hash
	if IsDoorRegisteredWithSystem(doorHash) == false then
		DoorSystemRegisterDoor(doorHash)
	end

	while GetDistanceBetweenCoords(crd.x, crd.y, crd.z, door.x, door.y, door.z, true) <= doorActiveRange do
		local doorState = DoorSystemGetDoorState(door.hash)
		crd = GetEntityCoords(PlayerPedId())
		handlePrompts(doorState)
		PromptSetActiveGroupThisFrame(promptGroup, promptGroupTitle)
		promptsListen(doorHash)
		Wait(0)
	end
	PromptSetEnabled(prompt_lock, false)
	PromptSetVisible(prompt_lock, false)
	PromptSetEnabled(prompt_unlock, false)
	PromptSetVisible(prompt_unlock, false)
end

Citizen.CreateThread(function()
	createZone()
	while true do
		crd = GetEntityCoords(PlayerPedId())
		ensureInZone()
		nearbyDoor = getNearbyDoor()
		if nearbyDoor ~= nil then
			handleNearbyDoor()
		end
		Wait(500)
	end
end)