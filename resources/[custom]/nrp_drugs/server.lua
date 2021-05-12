ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('nrp_drugs:sellWeed')
AddEventHandler('nrp_drugs:sellWeed', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local amount = xPlayer.getInventoryItem('marijuana').count

	local price = Config.DrugDealerItems['marijuana']

	if amount > 0 then
		xPlayer.removeInventoryItem('marijuana', amount)
		xPlayer.addAccountMoney('black_money', amount * price)
		xPlayer.showNotification(_U('dealer_sold', amount, "Marijuana", ESX.Math.GroupDigits(amount*price)))
	else
		xPlayer.showNotification(_U('dealer_notenough'))
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerCoords = GetEntityCoords(PlayerPedId(), true)

        -- Weed collection point
        DrawMarker(1, 1057.55, -3197.28, -39.13 - 1.0001, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 13, 232, 255, 155, 0, 0, 2, 0, 0, 0, 0)
        if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, 1057.55, -3197.28, -39.13, true) <= 3.0 then
            -- TriggerEvent("fs_freemode:displayHelp", i18n.translate("exit_warehouse"))
            ESX.ShowHelpNotification(_U('press_to_collect_weed'))
            if IsControlPressed(0, 51) then
                Citizen.Wait(1500)
                TriggerServerEvent('esx_drugs:pickedUpCannabis')
            end
        end

        -- Weed processing point
        DrawMarker(1, 1037.62, -3205.4, -38.17 - 1.0001, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 13, 232, 255, 155, 0, 0, 2, 0, 0, 0, 0)
        if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, 1037.62, -3205.4, -38.17, true) <= 3.0 then
            -- TriggerEvent("fs_freemode:displayHelp", i18n.translate("exit_warehouse"))
            ESX.ShowHelpNotification(_U('press_to_process_weed'))
            if IsControlPressed(0, 51) then
                Citizen.Wait(500)
                TriggerServerEvent('esx_drugs:processCannabis')
            end
        end

        -- Weed sell to warehouse
        DrawMarker(1, 2415.77, 4993.31, 46.22 - 1.0001, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 13, 232, 255, 155, 0, 0, 2, 0, 0, 0, 0)
        if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, 2415.77, 4993.31, 46.22, true) <= 3.0 then
            -- TriggerEvent("fs_freemode:displayHelp", i18n.translate("exit_warehouse"))
            ESX.ShowHelpNotification(_U('press_to_sell_weed'))
            if IsControlPressed(0, 51) then
                Citizen.Wait(500)
                TriggerServerEvent('nrp_drugs:sellWeed')
            end
        end
    end
end)