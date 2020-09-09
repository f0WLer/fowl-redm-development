RegisterNetEvent("clChatOutput")
AddEventHandler("clChatOutput", function(content)
	TriggerEvent("chatMessage","[User Data]", {0,255,0}, content)
end)

TriggerServerEvent("user:onJoin")

local userid

RegisterNetEvent("user:setUserid")
AddEventHandler("user:setUserid", function(id)
	userid = id
end)

RegisterNetEvent("user:getUserid")
AddEventHandler("user:getUserid", function(returnEvent)
	TriggerEvent(returnEvent, userid)
end)
