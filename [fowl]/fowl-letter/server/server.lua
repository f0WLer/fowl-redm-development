RegisterNetEvent("letter:sv_OpenLetter")
AddEventHandler("letter:sv_OpenLetter", function(userid, letterid)
	sv_OpenLetter(source, userid, letterid)
end)

RegisterNetEvent("letter:sv_UpdateLetter")
AddEventHandler("letter:sv_UpdateLetter", function(letterid, body)
	sv_UpdateLetter(source, letterid, body)
end)

RegisterNetEvent("letter:sv_NewLetter")
AddEventHandler("letter:sv_NewLetter", function()
	sv_NewLetter(source)
end)

RegisterNetEvent("letter:sv_DeleteLetter")
AddEventHandler("letter:sv_DeleteLetter", function(letterid)
	sv_DeleteLetter(letterid)
end)

function GetLetterBody(letterid)
	local body = MySQL2.Sync.fetchScalar("SELECT `body` FROM `letters` WHERE `letterid` = ?",{letterid})
	return body
end

function GetLetterCreator(letterid)
	local creatorid = MySQL2.Sync.fetchScalar("SELECT `creatorid` FROM `letters` WHERE `letterid` = ?",{letterid})
	return creatorid
end

function GetLetterOwner(letterid)
	local ownerid = MySQL2.Sync.fetchScalar("SELECT `ownerid` FROM `letters` WHERE `letterid` = ?",{letterid})
	return ownerid
end

function sv_OpenLetter(player, userid, letterid)
	local body = GetLetterBody(letterid)
	local creatorid = GetLetterCreator(letterid)
	local iscreator = (tostring(userid) == tostring(creatorid))
	TriggerClientEvent("letter:cl_OpenLetter", player, letterid, iscreator, body)
end

function sv_UpdateLetter(player, letterid, body)
	local creatorid = User.GetID(player)
	local ownerid = creatorid
	MySQL2.Async.execute(
		"INSERT INTO `letters` (`letterid`, `creatorid`, `ownerid`, `body`) "..
		"VALUES (?, ?, ?, ?) "..
		"ON DUPLICATE KEY UPDATE "..
		"`ownerid` 	= VALUES(`ownerid`), "..
		"`body` 	= VALUES(`body`);",
		{letterid, creatorid, ownerid, body},
		function(affectedRows)
	end)
end

function sv_NewLetter(player)
	local letterCount = MySQL2.Sync.fetchScalar("SELECT COUNT(*) FROM `letters`",{})
	local letterid
	if letterCount ~= 0 then
		letterid = MySQL2.Sync.fetchScalar("SELECT * FROM `letters` ORDER BY `letterid` DESC LIMIT 1",{})
		letterid = math.floor(letterid + 1)
	else
		letterid = 1
	end
	TriggerClientEvent("letter:cl_OpenLetter", player, letterid, true, nil)
end

function sv_DeleteLetter(letterid)
	MySQL2.Async.execute("DELETE FROM `letters` WHERE `letterid` = ?",
	{letterid},
	function(affectedRows)
	end)
end