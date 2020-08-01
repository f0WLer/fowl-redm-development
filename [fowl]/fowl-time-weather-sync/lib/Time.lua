Time = {}

function Time.currentTime()
	local time = {
		hour = exports['fowl-time-weather-sync']:getHours(),
		minute = exports['fowl-time-weather-sync']:getMinutes(),
		second = exports['fowl-time-weather-sync']:getSeconds(),
	}
	return time
end

function Time.timeScale()
	return exports['fowl-time-weather-sync']:timeScale()
end