RegisterNetEvent("user:onJoin")
AddEventHandler("user:onJoin", function()
	local player = source
	print("^5Player ".. GetPlayerName(source) .. " connected.^0")
	if user_is_saved(player) ~= true then
		user_add(player)
	end
	Wait(500)
	ChatOutput(player, "Welcome to ^1Fowl's RedM Server^0")
	local userid = user_get_id(player)
	TriggerClientEvent("user:setUserid", player, userid)
end)

function ChatOutput(player, content)
	TriggerClientEvent("clChatOutput", player, content)
end

function user_add(player)
	-- Get userid
	local userid = nil
	local userCount = MySQL2.Sync.fetchScalar("SELECT COUNT(userid) FROM users",{})
	if userCount ~= 0 then
		local latestId = MySQL2.Sync.fetchScalar("SELECT * FROM users ORDER BY userid DESC LIMIT 1",{})
		userid = math.floor(latestId + 1)
	else
		userid = 1	
	end
		-- Save user in db
	if user_is_saved(player) == false then
		local steamid = GetPlayerIdentifiers(player)[1]
		local name = GetPlayerName(player)
		MySQL2.Async.execute("INSERT INTO users (userid, steamid, name) VALUES(?, ?, ?)",
		{userid, steamid, name},
		function(affectedRows)
			ChatOutput(player, "You have been added as a player to the server (ID: ".. userid ..").")
			print("^3Added player ^5"..name.."^3 (userid:^5"..userid.."^3 steamid:^5"..steamid.."^3) to users.^0")
		end)
	end
end

function user_is_saved(player)
	local steamid = GetPlayerIdentifiers(player)[1]
	local userCount = MySQL2.Sync.fetchScalar("SELECT COUNT(*) FROM `users` WHERE `steamid` = ?",{steamid})
	local userExists
	if userCount ~= 0 then
		userExists = true
	else
		userExists = false
	end
	return userExists
end

function user_remove(player)
	local userid = user_get_id(player)
	local steamid = GetPlayerIdentifiers(player)[1]
	local name = GetPlayerName(player)
	MySQL2.Async.execute("DELETE FROM `users` WHERE `userid` = ? AND `steamid` = ?",
	{userid, steamid},
	function(affectedRows)
		print("^3Removed player ^5"..name.."^3 (userid:^5"..userid.."^3 steamid:^5"..steamid.."^3) from users table^0")
	end)
end

function user_get_id(player)
	local steamid = GetPlayerIdentifiers(player)[1]
	local userid = MySQL2.Sync.fetchScalar("SELECT `userid` FROM `users` WHERE `steamid` = ?",{steamid})
	return userid
end

function user_get_name(player)
	local steamid = GetPlayerIdentifiers(player)[1]
	local name = MySQL2.Sync.fetchScalar("SELECT `name` FROM `users` WHERE `steamid` = ?",{steamid})
	return name
end

function user_does_id_exist(userid)
	local userFound = MySQL2.Sync.fetchScalar("SELECT COUNT(*) FROM `users` WHERE `userid` = ?",{userid})
	local exists
	if userFound ~= 0 then
		exists = true
	else
		exists = false
	end
	return exists
end

exports("user_add", function(player)
	user_add(player)
end)

exports("user_is_saved", function(player)
	return user_is_saved(player)
end)

exports("user_remove", function(player)
	user_remove(player)
end)

exports("user_get_id", function(player)
	return user_get_id(player)
end)

exports("user_get_name", function(player)
	return user_get_name(player)
end)

exports("user_does_id_exist", function(userid)
	return user_does_id_exist(userid)
end)