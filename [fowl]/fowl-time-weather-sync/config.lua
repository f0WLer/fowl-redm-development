Config          = {}

-------
-- Time
-------

-- Set a default server time when server is started
Config.ServerStartTime = {
    hour    = 08,   -- between 0 and 23
    minute  = 00    -- between 0 and 59
}

-- Time scale (number of in-game seconds that pass every real second), default 8 (three-hour day)
Config.TimeScale = 8

-------
-- Weather
-------

-- Make weather dynamic, default `true`
Config.DynamicWeatherChanges = true

-- Time between dynamic changes, default 10 mins
Config.TimeBetweenWeatherChanges = 15

-- Max wind speed
Config.MaxWindSpeed = 10.0