MySQL2 = {
	Async = {},
	Sync = {},
}

local function safeParameters(params)
    if nil == params then
        return {[''] = ''}
    end

    assert(type(params) == "table", "A table is expected")

    if next(params) == nil then
        return {[''] = ''}
    end

    return params
end

-- Aysnc
function MySQL2.Async.execute(query, params, func)
    assert(type(query) == "string" or type(query) == "number", "The SQL Query must be a string")

    exports['fowl-mysql']:mysql2_execute(query, safeParameters(params), func)
end

function MySQL2.Async.fetchAll(query, params, func)
	assert(type(query) == "string" or type(query) == "number", "The SQL Query must be a string")

	exports['fowl-mysql']:mysql2_fetch_all(query, safeParameters(params), func)
end

function MySQL2.Async.fetchScalar(query, params, func)
    assert(type(query) == "string" or type(query) == "number", "The SQL Query must be a string")

    exports['fowl-mysql']:mysql2_fetch_scalar(query, safeParameters(params), func)
end

-- Sync
function MySQL2.Sync.execute(query, params)
    assert(type(query) == "string" or type(query) == "number", "The SQL Query must be a string")

    local res = 0
    local finishedQuery = false
    exports['fowl-mysql']:mysql2_execute(query, safeParameters(params), function (result)
        res = result
        finishedQuery = true
    end)
    repeat Citizen.Wait(0) until finishedQuery == true
    return res
end

function MySQL2.Sync.fetchAll(query, params)
    assert(type(query) == "string" or type(query) == "number", "The SQL Query must be a string")

    local res = {}
    local finishedQuery = false
    exports['fowl-mysql']:mysql2_fetch_all(query, safeParameters(params), function (result)
        res = result
        finishedQuery = true
    end)
    repeat Citizen.Wait(0) until finishedQuery == true
    return res
end

function MySQL2.Sync.fetchScalar(query, params)
    assert(type(query) == "string" or type(query) == "number", "The SQL Query must be a string")

    local res = ''
    local finishedQuery = false
    exports['fowl-mysql']:mysql2_fetch_scalar(query, safeParameters(params), function (result)
        res = result
        finishedQuery = true
    end)
    repeat Citizen.Wait(0) until finishedQuery == true
    return res
end
