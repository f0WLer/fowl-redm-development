currentHour = nil
currentMinute = nil

Sync = {
	CurrentWeather = 'WEATHER_CLEAR',
	WeatherTypes = {
		[-1] = 'WEATHER_UNKNOWN',
		[0] = 'WEATHER_CLEAR',
		[1] = 'WEATHER_CLOUDS',
		[2] = 'WEATHER_SMOG',
		[3] = 'WEATHER_OVERCAST',
		[4] = 'WEATHER_RAINING',
		[5] = 'WEATHER_THUNDER',
		[6] = 'WEATHER_CLEARING',
		[7] = 'WEATHER_NEUTRAL',
		[8] = 'WEATHER_SNOW'
	}
}

Sync.GetWeatherType = function(index)
	index = index or -1

	if (type(index) == 'number') then
		return index, Sync.WeatherTypes[index] or Sync.WeatherTypes[-1]
	end

	local weather = string.upper(tostring(index))

	for _, _weather in pairs(Sync.WeatherTypes or {}) do
		if (_weather == weather) then
			return _, _weather
		end
	end

	return -1, Sync.WeatherTypes[-1]
end

Sync.GetCurrentWeatherType = function()
	local index, weather = Sync.GetWeatherType(Sync.CurrentWeather)

	return index
end

RegisterNetEvent('cl_updateTime')
AddEventHandler('cl_updateTime', function(hour, minute)
	hour = math.floor(hour or 0)
	minute = math.floor(minute or 0)

	SetClockTime(hour, minute, 0)
	AdvanceClockTimeTo(hour, minute, 0)
	NetworkClockTimeOverride(hour, minute, 0, 0, true)
	NetworkClockTimeOverride_2(hour, minute, 0, 0, true, true)

	currentHour = hour
	currentMinute = minute
end)

RegisterNetEvent('cl_updateWeather')
AddEventHandler('cl_updateWeather', function(weather, windSpeed)
	weather = weather or 'WEATHER_CLEAR'

	local _index, _weather = Sync.GetWeatherType(weather)

	ClearOverrideWeather()
	ClearWeatherTypePersist()

	if (Sync.CurrentWeather ~= _weather) then
		Sync.CurrentWeather = _weather
		SetWeatherTypeTransition(Sync.GetCurrentWeatherType(), _index, 0.0)
	end

	SetWindSpeed(windSpeed)
end)

exports('getHour', function()
	return currentHour
end)

exports('getMinute', function()
	return currentMinute
end)