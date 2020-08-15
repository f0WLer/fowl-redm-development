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
Citizen.CreateThread(function() userid = getUserid() end)

local characters

RegisterNetEvent("login:cl_receiveCharacters")
AddEventHandler("login:cl_receiveCharacters", function(chars)
	characters = chars
	promptCharSelect()
end)

function promptCharSelect()
	DestroyAllCams(true)
	RenderScriptCams(false, false, 0, true, true)

	local camCoords = {x = -306.40, y = 790.90, z = 300.00}
	function loadStartCam()
		local startCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	    SetCamCoord(startCam, camCoords.x, camCoords.y, camCoords.z)
	    PointCamAtCoord(startCam, camCoords.x, camCoords.y, 0.0)
	    --SetCamActive(cam, true)
	    RenderScriptCams(true, false, 0, true, true)

	    print("Start cam initialized")
	    return startCam
	end
    
    function transitionCam(startCam)
    	local zoomCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    	SetCamCoord(zoomCam, camCoords.x, camCoords.y, 120.0)
    	SetCamActiveWithInterp(zoomCam, startCam, 3700, true, true)
    	RenderScriptCams(true, false, 0, true, true)
    	print("Transitioning cam")
    end

    local startCam = loadStartCam()
    Wait(2000)
    transitionCam(startCam)

end

Citizen.CreateThread(function()
	promptCharSelect()
end)