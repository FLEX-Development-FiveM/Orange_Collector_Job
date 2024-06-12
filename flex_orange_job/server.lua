ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('orangeJob:collectOrange')
AddEventHandler('orangeJob:collectOrange', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem('orange', 1)
end)

RegisterNetEvent('orangeJob:sellOranges')
AddEventHandler('orangeJob:sellOranges', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    print(json.encode(xPlayer.getInventoryItem('orange')))
    local orangeCount = xPlayer.getInventoryItem('orange').count
    local pricePerOrange = 2000
    local reward = orangeCount * pricePerOrange

    if orangeCount > 0 then
        xPlayer.removeInventoryItem('orange', orangeCount)
        xPlayer.addMoney(reward)
        TriggerClientEvent('esx:showNotification', source, 'Du hast ' .. orangeCount .. ' Orangen für $' .. reward .. ' verkauft')
    else
        TriggerClientEvent('esx:showNotification', source, 'Du hast keine Orangen zum Verkaufen')
    end
end)
