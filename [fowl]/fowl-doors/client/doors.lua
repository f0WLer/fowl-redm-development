--[[ ///// PROMPTS ///// ]]
function createPrompt(name, key, hold, group)
	local Prompt
    Citizen.CreateThread(function()
        local str = name
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
local prompt_switch
Citizen.CreateThread(function()
	promptGroup = 4545
	promptGroupTitle = CreateVarString(10, "LITERAL_STRING", "Door")
	prompt_lock = createPrompt("Lock", 0x0522B243 --[[F]], false, promptGroup)
	prompt_unlock = createPrompt("Unlock", 0x0522B243 --[[F]], false, promptGroup)
	prompt_switch = createPrompt("Switch Doors", 0x760A9C6F --[[G]], false, promptGroup)
	PromptSetEnabled(prompt_unlock, false)
	PromptSetVisible(prompt_unlock, false)
	PromptSetEnabled(prompt_lock, false)
	PromptSetVisible(prompt_lock, false)
	PromptSetEnabled(prompt_switch, false)
	PromptSetVisible(prompt_switch, false)
end)
--[[ ////////// ]]

function DoorSystemRegisterDoor(doorHash)
	Citizen.InvokeNative(0xD99229FE93B46286,doorHash,1,1,0,0,0,0)
end


function getSurroundingDoors(x, y, z, radius)
	return exports["fowl-doors"]:getSurroundingDoors(x, y, z, radius)
end

-------
---- Settings
-------
local radius = Config.Radius
local doorActiveRange = Config.DoorActivationRange
local secDoorRange = Config.DoorSecondaryRange
-------
----
-------

local crd
local surroundingDoors
local nearbyDoor
local secDoor
local switch = false
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
	--[[local primDoor
	local altDoor
	for k,v in pairs(surroundingDoors) do
		local door = surroundingDoors[k]
		if primDoor == nil then
			if GetDistanceBetweenCoords(crd.x, crd.y, crd.z, door.x, door.y, door.z, true) <= doorActiveRange then
				primDoor = door
			end
		else
			if GetDistanceBetweenCoords(primDoor.x, primDoor.y, primDoor.z, door.x, door.y, door.z, true) <= secDoorRange then
				altDoor = door
				break
			end
		end
	end
	if altDoor ~= nil then
		local primDist = GetDistanceBetweenCoords(crd.x, crd.y, crd.z, primDoor.x, primDoor.y, primDoor.z, true)
		local altDist = GetDistanceBetweenCoords(crd.x, crd.y, crd.z, altDoor.x, altDoor.y, altDoor.z, true)
		if primDist > altDist then
			return altDoor, primDoor
		end
	end]]
	local primDoor
	local altDoor
	local doors = {}
	local closestDist
	local secClostestDist
	for k,v in pairs(surroundingDoors) do
		local door = surroundingDoors[k]
		local dist = GetDistanceBetweenCoords(crd.x, crd.y, crd.z, door.x, door.y, door.z, true)
		if dist <= 5.0 then
			if closestDist == nil then
				closestDist = dist
			elseif dist < closestDist then
				secClostestDist = closestDist
				closestDist = dist
			elseif secClostestDist == nil or dist < secClostestDist then
				secClostestDist = dist
			end
			doors[dist] = door
		end
	end
	if closestDist == nil then
		return nil,nil
	elseif closestDist > doorActiveRange then 
		return nil,nil
	else
		primDoor = doors[closestDist]
		if secClostestDist == nil then
			return primDoor,nil
		elseif GetDistanceBetweenCoords(primDoor.x,primDoor.y,primDoor.z,doors[secClostestDist].x,doors[secClostestDist].y,doors[secClostestDist].z,true) <= secDoorRange then
			altDoor = doors[secClostestDist]
		end
		return primDoor, altDoor
	end
end

function switchDoors()
	local door1 = nearbyDoor
	local door2 = secDoor
	nearbyDoor = door2
	secDoor = door1

	switch = false
end

function lockDoor(doorHash)
	DoorSystemSetDoorState(doorHash, 1)
end

function unlockDoor(doorHash)
	DoorSystemSetDoorState(doorHash, 0)
end

function drawDoorIcon(toggle,isLocked) 
	if toggle == true then
		local door = nearbyDoor
		local onScreen,screenX,screenY = GetScreenCoordFromWorldCoord(door.x,door.y,door.z+1.5)
		SendNUIMessage({drawIcon = true, doorX = screenX, doorY = screenY})
		if isLocked == true then
			SendNUIMessage({doorLocked = true})
		else
			SendNUIMessage({doorLocked = false})
		end
	else
		SendNUIMessage({drawIcon = false})
	end
	--[[
	local door = nearbyDoor
	SetTextScale(0.3, 0.3)
	SetTextCentre(true)
	local onScreen,screenX,screenY = GetScreenCoordFromWorldCoord(door.x,door.y,door.z+1.5)
	local lockText = CreateVarString(10, "LITERAL_STRING", "Locked")
	local unlockText = CreateVarString(10, "LITERAL_STRING", "Unlocked")
	if isLocked == true then
		DisplayText(lockText, screenX, screenY)
	else
		DisplayText(unlockText, screenX, screenY)
	end
	]]
end	

function handlePrompts(doorState)
	if secDoor ~= nil then
		PromptSetVisible(prompt_switch, true)
		PromptSetEnabled(prompt_switch, true)
	end
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
	if PromptHasStandardModeCompleted(prompt_switch) and secDoor ~= nil then
		switch = true
	end

end

function handleNearbyDoor()
	local door = nearbyDoor
	doorHash = door.hash
	print(doorHash)
	if IsDoorRegisteredWithSystem(doorHash) == false then
		DoorSystemRegisterDoor(doorHash)
	end

	local inRange = true
	while inRange == true and switch == false do
		crd = GetEntityCoords(PlayerPedId())
		
		if secDoor ~= nil then
			if GetDistanceBetweenCoords(crd.x, crd.y, crd.z, door.x, door.y, door.z, true) > doorActiveRange and GetDistanceBetweenCoords(crd.x, crd.y, crd.z, secDoor.x, secDoor.y, secDoor.z, true) > doorActiveRange then
				inRange = false
			end
		elseif GetDistanceBetweenCoords(crd.x, crd.y, crd.z, door.x, door.y, door.z, true) > doorActiveRange then
			inRange = false
		end

		local doorState = DoorSystemGetDoorState(door.hash)
		if doorState == -1 or doorState == 0 then
			drawDoorIcon(true, false)
		else
			drawDoorIcon(true, true)
		end

		handlePrompts(doorState)
		PromptSetActiveGroupThisFrame(promptGroup, promptGroupTitle)
		promptsListen(doorHash)
		Wait(0)
	end
	drawDoorIcon(false)
	PromptSetEnabled(prompt_lock, false)
	PromptSetVisible(prompt_lock, false)
	PromptSetEnabled(prompt_unlock, false)
	PromptSetVisible(prompt_unlock, false)
	PromptSetEnabled(prompt_switch, false)
	PromptSetVisible(prompt_switch, false)
end

Citizen.CreateThread(function()
	createZone()
	--[[ doorMode = true
	while doorMode = true do]]
	while true do
		if switch == true then
			switchDoors()
			handleNearbyDoor()
			Wait(0)
		else
			Wait(500)
			crd = GetEntityCoords(PlayerPedId())
			ensureInZone()
			nearbyDoor,secDoor = getNearbyDoor()
			if nearbyDoor ~= nil then handleNearbyDoor() end
		end
	end
end)