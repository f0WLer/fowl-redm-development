RegisterNetEvent("inventory:sv_requestCharacterInventory")
AddEventHandler("inventory:sv_requestCharacterInventory", function()
    local pSource = source
    Citizen.CreateThread(function()
        MySQL2.Async.fetchScalar(
            "SELECT `inv` FROM `inventory` WHERE `charid` = ?",{3},
            function(result)
                TriggerClientEvent("inventory:cl_receiveCharacterInventory", pSource, json.decode(result))
            end)
    end)
end)