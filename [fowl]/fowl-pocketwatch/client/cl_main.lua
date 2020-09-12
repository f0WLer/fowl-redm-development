local enabled = true

-------
-- HTML
-------
function drawWatch()
    SendNUIMessage({DrawHTML = true})
end

function hideWatch()
    SendNUIMessage({DrawHTML = false})
end

-------
-- Init
-------
local hour = 0
local minute = 0
local timeScale = Config.TimeScale or 8
local watchKey = Config.WatchKey or 0x80F28E95

function updateTime()
    hour = exports['fowl-time-weather-sync']:getHour()
    minute = exports['fowl-time-weather-sync']:getMinute()
end

function get12HrTime()
    if hour > 12 then
        return (hour - 12), minute
    else
        return hour, minute
    end
end

-------
-- Watch
-------
function updateWatch()
    local currentHour, currentMinute = get12HrTime()
    SendNUIMessage({updateWatch = true, watchHour = currentHour, watchMinute = currentMinute})
end

function resetSeconds()
    SendNUIMessage({resetSeconds = true})
end


function displayWatch()
    updateTime()
    updateWatch()
    resetSeconds()

    drawWatch()
    local update = 1000 / timeScale
    local second = 0
    while IsControlPressed(1, watchKey) do
        second = second + 1
        if second == 60 then
            if minute == 59 then
                hour = hour + 1
                minute = 0
            else
                minute = minute + 1
            end
            second = 0
        end
        updateWatch()
        SendNUIMessage({progressSeconds = true, seconds = 1})
        Wait(update)
    end

    hideWatch()
end


-------
-- Running Loop
-------
Citizen.CreateThread(function()
    Wait(100)
    updateTime()
    updateWatch()

    while enabled do
        if IsControlPressed(1, watchKey) then
            displayWatch()
        end
        Wait(300)
    end
end)