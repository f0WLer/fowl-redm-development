Sync.WeatherInitialize = function()
    local self = {}

    self.currentWeatherType = 'WEATHER_CLEAR'
    self.changeWeatherDynamic = Config.DynamicWeatherChanges or false
    self.timeBetweenWeatherChanges = Config.TimeBetweenWeatherChanges or 10
    self.maxWindSpeed = Config.MaxWindSpeed or 10.0

    self.getWeatherType = function(index)
        local weatherTypes = {
            [-1] = 'WEATHER_UNKNOWN',
            [0] = 'WEATHER_CLEAR',
            [1] = 'WEATHER_CLOUDS',
            [2] = 'WEATHER_SMOG',
            [3] = 'WEATHER_FOGGY',
            [4] = 'WEATHER_OVERCAST',
            [5] = 'WEATHER_RAINING',
            [6] = 'WEATHER_THUNDER',
            [7] = 'WEATHER_CLEARING',
            [8] = 'WEATHER_NEUTRAL',
            [9] = 'WEATHER_SNOW'
        }

        if (type(index) ~= 'number' or index == nil) then
            index = 0
        end

        return weatherTypes[index] or weatherTypes[-1]
    end

    self.weatherTypeExists = function(weatherType)
        for i = 0, 9 do
            if (self.getWeatherType(i) == string.upper(weatherType)) then
                return true
            end
        end

        return false
    end

    self.getWeatherTransitions = function()
        local weatherTransitions = {
            ['WEATHER_UNKNOWN'] = { 'WEATHER_CLEAR' },
            ['WEATHER_CLEAR'] = { 'WEATHER_CLOUDS', 'WEATHER_CLEARING', 'WEATHER_SMOG', 'WEATHER_OVERCAST', 'WEATHER_NEUTRAL' },
            ['WEATHER_CLOUDS'] = { 'WEATHER_CLEAR', 'WEATHER_SMOG', 'WEATHER_CLEARING', 'WEATHER_OVERCAST' },
            ['WEATHER_SMOG'] = { 'WEATHER_CLEAR', 'WEATHER_CLEARING', 'WEATHER_OVERCAST', 'WEATHER_CLOUDS' },
            ['WEATHER_FOGGY'] = { 'WEATHER_CLEAR', 'WEATHER_CLOUDS', 'WEATHER_SMOG', 'WEATHER_OVERCAST', 'WEATHER_RAINING' },
            ['WEATHER_OVERCAST'] = { 'WEATHER_CLEAR', 'WEATHER_CLOUDS', 'WEATHER_SMOG', 'WEATHER_CLEARING', 'WEATHER_THUNDER', 'WEATHER_NEUTRAL' },
            ['WEATHER_RAINING'] = { 'WEATHER_OVERCAST', 'WEATHER_CLOUDS', 'WEATHER_CLEARING', 'WEATHER_THUNDER' },
            ['WEATHER_THUNDER'] = { 'WEATHER_OVERCAST', 'WEATHER_RAINING' },
            ['WEATHER_CLEARING'] = { 'WEATHER_CLEAR', 'WEATHER_FOGGY', 'WEATHER_RAINING', 'WEATHER_NEUTRAL' },
            ['WEATHER_NEUTRAL'] = { 'WEATHER_CLEAR', 'WEATHER_CLOUDS' },
            ['WEATHER_SNOW'] = { 'WEATHER_RAINING', 'WEATHER_CLEARING', 'WEATHER_OVERCAST', 'WEATHER_SMOG' }
        }

        return weatherTransitions[self.currentWeatherType]
    end

    self.getWindSpeed = function()
        local weatherWindSpeeds = {
            ['WEATHER_UNKNOWN'] = 0.2 * self.maxWindSpeed,
            ['WEATHER_CLEAR'] = 0.3 * self.maxWindSpeed,
            ['WEATHER_CLOUDS'] = 0.1 * self.maxWindSpeed,
            ['WEATHER_SMOG'] = 0.1 * self.maxWindSpeed,
            ['WEATHER_FOGGY'] = 0.4 * self.maxWindSpeed,
            ['WEATHER_OVERCAST'] = 0.7 * self.maxWindSpeed,
            ['WEATHER_RAINING'] = 0.5 * self.maxWindSpeed,
            ['WEATHER_THUNDER'] = 1.0 * self.maxWindSpeed,
            ['WEATHER_CLEARING'] = 0.3 * self.maxWindSpeed,
            ['WEATHER_NEUTRAL'] = 0.2 * self.maxWindSpeed,
            ['WEATHER_SNOW'] = 0.6 * self.maxWindSpeed
        }

        return weatherWindSpeeds[self.currentWeatherType] or weatherWindSpeeds['WEATHER_UNKNOWN']
    end

    self.changeWeatherType = function(weatherType)
        weatherType = string.upper(weatherType or 'WEATHER_UNKNOWN')

        if (self.weatherTypeExists(weatherType)) then
            self.currentWeatherType = weatherType
        end
    end

    self.randomWeatherTransitions = function()
        local transitions = self.getWeatherTransitions()

        math.randomseed(GetGameTimer())

        self.changeWeatherType(math.random(1, #transitions))
    end

    self.syncWeather = function(source)
        if (source) then
            TriggerClientEvent('cl_updateWeather', source, self.currentWeatherType, self.getWindSpeed())
        else
            TriggerClientEvent('cl_updateWeather', -1, self.currentWeatherType, self.getWindSpeed())
        end
    end

    return self
end

Sync.Weather = Sync.WeatherInitialize()