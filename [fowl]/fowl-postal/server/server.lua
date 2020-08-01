local mailingHour = Config.MailingHour or 8
if mailingHour <= 0 or mailingHour > 24 then
	mailingHour = 8
end

Citizen.CreateThread(function()
	local ranToday = false
	while true do
		local time = Time.currentTime()
		local hour = time.hour
		if ranToday == false then
			if hour == mailingHour then
				runMail()
				ranToday = true
			end
		else
			if hour == 0 then
				ranToday = false
			end
		end
		Wait(1000 * 30 * 1)
	end
end)

function sv_requestLetters(player, userid)
	local letters = MySQL2.Sync.fetchAll("SELECT `letterid`, `address`, `returnaddress`, `date` FROM `letters` WHERE `ownerid` = ?",{userid})
	TriggerClientEvent("postal:cl_receiveLetters", player, letters)
end

function sv_requestLetterData(player, letterid)
	local letterData = MySQL2.Sync.fetchAll("SELECT `letterid`, `address`, `returnaddress`, `date` FROM `letters` WHERE `letterid` = ?",
		{letterid})
	TriggerClientEvent("postal:cl_receiveLetterData", player, letterData)
end

function sv_updateAddressData(letterid, address, returnaddress, date)
	if address == nil then address = "‎" end
	if returnaddress == nil then returnaddress = "‎" end
	MySQL2.Async.execute(
		"UPDATE `letters` SET `address` = ?, `returnaddress` = ? WHERE `letterid` = ?;",
		{address, returnaddress, letterid},
		function(affectedRows)
	end)
end


function sv_sendLetter(letterid, to_userid, from_userid)
	-- Remove mail from user's inventory and place into circulation
	MySQL2.Async.execute(
		"UPDATE `letters` SET `ownerid` = 'Mailing' WHERE `letterid` = ?;"..
		"INSERT INTO `mail` (letterid, from_userid, to_userid) VALUES(?, ?, ?);",
		{letterid, letterid, from_userid, to_userid},
		function(affectedRows)
	end)
end

function runMail()
	local mailCount = MySQL2.Sync.fetchScalar("SELECT COUNT(`letterid`) FROM `mail`",{})
	for var=1,mailCount do
		MySQL2.Sync.execute(
			"SET @letterid = (SELECT `letterid` FROM `mail` LIMIT 1);"..
			"SET @to_userid = (SELECT `to_userid` FROM `mail` LIMIT 1);"..
			"SET @from_userid = (SELECT `from_userid` FROM `mail` LIMIT 1);"..
			"SET @usersFound = (SELECT COUNT(*) FROM `users` WHERE `userid` = @to_userid);"..
			"SET @recipient = (SELECT IF(@usersFound = 1, @to_userid, @from_userid));"..
			"SET @returned = (SELECT IF(@recipient = @from_userid, 1, 0));"..
			"UPDATE `letters` SET `ownerid` = @recipient, `returned` = @returned WHERE `letterid` = @letterid;"..
			"DELETE FROM `mail` WHERE `letterid` = @letterid;",
			{}
		)
	end
end

RegisterNetEvent("postal:sv_sendClientUserId")
AddEventHandler("postal:sv_sendClientUserId", function()
	TriggerClientEvent("postal:cl_receiveUserId", source, User.GetID(source))
end)

RegisterNetEvent("postal:sv_requestLetters")
AddEventHandler("postal:sv_requestLetters", function(userid)	
	sv_requestLetters(source, userid)
end)

RegisterNetEvent("postal:sv_requestLetterData")
AddEventHandler("postal:sv_requestLetterData", function(letterid)
	sv_requestLetterData(source, letterid)
end)

RegisterNetEvent("postal:sv_updateAddressData")
AddEventHandler("postal:sv_updateAddressData", function(letterid, address, returnaddress, date)
	sv_updateAddressData(letterid, address, returnaddress, date)
end)

RegisterNetEvent("postal:sv_sendLetter")
AddEventHandler("postal:sv_sendLetter", function(userid, letterid, to_userid)
	sv_sendLetter(letterid, to_userid, userid)
end)