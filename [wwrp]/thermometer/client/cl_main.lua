--print(GetTemperatureAtCoords(GetEntityCoords(PlayerPedId())))

function getTemp()
    local temperature = GetTemperatureAtCoords(GetEntityCoords(PlayerPedId()))
    return math.ceil(((temperature * (9/5)) + 32))
end
local temp = getTemp()

function updateTemp(temperature)
    Citizen.CreateThread(function()
        Wait(2000)
        SendNUIMessage({adjustTemperature = true, temp = temperature})
    end)
end
updateTemp(temp)



local run = true    
Citizen.CreateThread(function()
    while run == true do
        Wait(2000)
        local currentTemp = getTemp()
        if currentTemp ~= temp then
            temp = currentTemp
            updateTemp(temp)
        end
    end
end)