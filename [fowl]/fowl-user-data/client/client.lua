RegisterNetEvent("clChatOutput")
AddEventHandler("clChatOutput", function(content)
	TriggerEvent("chatMessage","[User Data]", {0,255,0}, content)
end)

TriggerServerEvent("PlayerConnect")
