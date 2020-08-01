Sync.TimeInitialize = function()
	local self = {}

    local timeScale = Config.TimeScale
	self.currentTime = math.floor(GetGameTimer() / 1000) * timeScale

	self.getHours = function()
        return math.floor(self.currentTime / 3600)
    end

    self.getMinutes = function()
        local hours = self.getHours() * 3600
        local remainingSeconds = self.currentTime - hours

        return math.floor(remainingSeconds / 60)
    end

    self.getSeconds = function()
        local hours = self.getHours() * 3600
        local minutes = self.getMinutes() * 60

        return math.floor(self.currentTime - hours - minutes)
    end

    self.getCurrentTime = function()
        return self.getHours(), self.getMinutes(), self.getSeconds()
    end

    self.setHours = function(newHour)
        if (newHour >= 0 and newHour <= 23) then
            local hours = math.floor(newHour * 3600)
            local minutes = self.getMinutes() * 60
            local seconds = self.getSeconds()

            self.currentTime = math.floor(hours + minutes + seconds)
        end
    end

    self.setMinutes = function(newMinute)
        if (newMinute >= 0 and newMinute <= 59) then
            local hours = self.getHours() * 3600
            local minutes = math.floor(newMinute * 60)
            local seconds = self.getSeconds()

            self.currentTime = math.floor(hours + minutes + seconds)
        end
    end

    self.setSeconds = function(newSeconds)
        if (newSeconds >= 0 and newSeconds <= 59) then
            local hours = self.getHours() * 3600
            local minutes = self.getMinutes() * 60

            self.currentTime = math.floor(hours + minutes + newSeconds)
        end
    end

    self.addSeconds = function(addSeconds)
        if (addSeconds >= 0 and addSeconds <= 59) then
            self.currentTime = math.floor(self.currentTime + (addSeconds * timeScale))

            if (self.currentTime >= 86400) then
                self.currentTime = 0
            end
        end
    end

    self.syncTime = function(source)
        local hour = math.floor(self.getHours() or 0)
        local minute = math.floor(self.getMinutes() or 0)
        local seconds = math.floor(self.getSeconds() or 0)

        if (source) then
            TriggerClientEvent('cl_updateTime', source, hour, minute, seconds)
        else
            TriggerClientEvent('cl_updateTime', -1, hour, minute, seconds)
        end
    end

    return self
end

Sync.Time = Sync.TimeInitialize()