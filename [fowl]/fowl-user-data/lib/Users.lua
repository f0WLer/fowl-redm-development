Citizen.CreateThread(function()
	User = {}


	function User.Add(player)
		exports['fowl-user-data']:user_add(player)
	end

	function User.IsSaved(player)
		return exports['fowl-user-data']:user_is_saved(player)
	end

	function User.Remove(player)
		exports['fowl-user-data']:user_remove(player)
	end

	function User.GetID(player)
		return exports['fowl-user-data']:user_get_id(player)
	end

	function User.GetName(player)
		return exports['fowl-user-data']:user_get_name(player)
	end

	function User.DoesIdExist(userid)
		return exports['fowl-user-data']:user_does_id_exist(player)
	end
end)