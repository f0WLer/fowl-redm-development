function addCharacter(player)
	local userid = User.GetID(player)
	local characterid = nil
	local characterCount = MySQL2.Sync.fetchScalar("SELECT COUNT(characterid) FROM characters",{})
	if characterCount ~= 0 then
		local latestId = MySQL2.Sync.fetchScalar("SELECT * FROM characters ORDER BY characterid DESC LIMIT 1",{})
		characterid = math.floor(latestId + 1)
	else
		characterid = 1	
	end

	MySQL2.Async.execute("UPDATE `characters` INSERT INTO (characterid, userid) VALUES(?, ?"),
		{characterid,userid})
end

function getCharacters(player)
	local userid = User.GetID(player)
	local characters = MySQL2.Async.fetchAll("SELECT * FROM `characters` WHERE `userid` = ?",{userid},function(results) 
		return results
	end)
	return characters
end