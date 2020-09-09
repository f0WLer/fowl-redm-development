Citizen.CreateThread(function()
    local hour = (Config.ServerStartTime or {}).hour or 9
    local minute = (Config.ServerStartTime or {}).minute or 0

    Sync.Time.setHours(hour)
    Sync.Time.setMinutes(minute)
    Sync.Time.syncTime()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)

        if (((Sync.LastWeatherChange or 0) / 1000) >= (Config.TimeBetweenWeatherChanges * 600)) then
            Sync.Weather.randomWeatherTransitions()
        else
            Sync.LastWeatherChange = Sync.LastWeatherChange + 10000
        end

        Sync.Time.addSeconds(10)
        Sync.Time.syncTime()
        Sync.Weather.syncWeather()
    end
end)

AddEventHandler('playerLoaded', function(source)
    Sync.Time.syncTime(source)
    Sync.Weather.syncWeather(source)
end)

exports("getHours", function()
    return Sync.Time.getHours()
end)

exports("getMinutes", function()
    return Sync.Time.getMinutes()
end)

exports("getSeconds", function()
    return Sync.Time.getSeconds()
end)

exports("timeScale", function()
    return Config.TimeScale
end)