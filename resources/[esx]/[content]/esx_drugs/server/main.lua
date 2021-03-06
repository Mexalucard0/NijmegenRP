ESX = nil
local playersProcessingCannabis = {}
local outofbound = true
local alive = true

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('esx_drugs:sellWeed')
AddEventHandler('esx_drugs:sellWeed', function()
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

RegisterServerEvent('esx_drugs:launderMoney')
AddEventHandler('esx_drugs:launderMoney', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local dirty = xPlayer.getAccount('black_money').money
	
	xPlayer.removeAccountMoney('black_money', dirty)
	xPlayer.addMoney(dirty * 0.85)

	xPlayer.showNotification(_U('money_laundered', dirty, dirty*0.85))
end)

RegisterServerEvent('esx_drugs:sellDrug')
AddEventHandler('esx_drugs:sellDrug', function(itemName, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Config.DrugDealerItems[itemName]
	local xItem = xPlayer.getInventoryItem(itemName)

	if not price then
		print(('esx_drugs: %s attempted to sell an invalid drug!'):format(xPlayer.identifier))
		return
	end

	if xItem.count < amount then
		xPlayer.showNotification(_U('dealer_notenough'))
		return
	end

	price = ESX.Math.Round(price * amount)

	if Config.GiveBlack then
		xPlayer.addAccountMoney('black_money', price)
	else
		xPlayer.addMoney(price)
	end

	xPlayer.removeInventoryItem(xItem.name, amount)
	xPlayer.showNotification(_U('dealer_sold', amount, xItem.label, ESX.Math.GroupDigits(price)))
end)

ESX.RegisterServerCallback('esx_drugs:buyLicense', function(source, cb, licenseName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local license = Config.LicensePrices[licenseName]

	if license then
		if xPlayer.getMoney() >= license.price then
			xPlayer.removeMoney(license.price)

			TriggerEvent('esx_license:addLicense', source, licenseName, function()
				cb(true)
			end)
		else
			cb(false)
		end
	else
		print(('esx_drugs: %s attempted to buy an invalid license!'):format(xPlayer.identifier))
		cb(false)
	end
end)

RegisterServerEvent('esx_drugs:pickedUpCannabis')
AddEventHandler('esx_drugs:pickedUpCannabis', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local cime = math.random(1,3)

	if xPlayer.canCarryItem('cannabis', cime) then
		xPlayer.addInventoryItem('cannabis', cime)
	else
		xPlayer.showNotification(_U('weed_inventoryfull'))
	end
end)

ESX.RegisterServerCallback('esx_drugs:canPickUp', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(xPlayer.canCarryItem(item, 1))
end)

RegisterServerEvent('esx_drugs:outofbound')
AddEventHandler('esx_drugs:outofbound', function()
	outofbound = true
end)

RegisterServerEvent('esx_drugs:quitprocess')
AddEventHandler('esx_drugs:quitprocess', function()
	can = false
end)

ESX.RegisterServerCallback('esx_drugs:cannabis_count', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xCannabis = xPlayer.getInventoryItem('cannabis').count
	cb(xCannabis)
end)

RegisterServerEvent('esx_drugs:processCannabis')
AddEventHandler('esx_drugs:processCannabis', function()
  if not playersProcessingCannabis[source] then
		local _source = source
		local xPlayer = ESX.GetPlayerFromId(_source)
		local xCannabis = xPlayer.getInventoryItem('cannabis')
		local can = true
		outofbound = false
    if xCannabis.count >= 4 then
      while outofbound == false and can do
				if playersProcessingCannabis[_source] == nil then
					playersProcessingCannabis[_source] = ESX.SetTimeout(Config.Delays.WeedProcessing , function()
            if xCannabis.count >= 3 then
              if xPlayer.canSwapItem('cannabis', 4, 'marijuana', 1) then
                xPlayer.removeInventoryItem('cannabis', 4)
                xPlayer.addInventoryItem('marijuana', 1)
								xPlayer.showNotification(_U('weed_processed'))
							else
								can = false
								xPlayer.showNotification(_U('weed_processingfull'))
								TriggerEvent('esx_drugs:cancelProcessing')
							end
						else						
							can = false
							xPlayer.showNotification(_U('weed_processingenough'))
							TriggerEvent('esx_drugs:cancelProcessing')
						end

						playersProcessingCannabis[_source] = nil
					end)
				else
					Wait(Config.Delays.WeedProcessing)
				end	
			end
		else
			xPlayer.showNotification(_U('weed_processingenough'))
			TriggerEvent('esx_drugs:cancelProcessing')
		end	
			
	else
		print(('esx_drugs: %s attempted to exploit weed processing!'):format(GetPlayerIdentifiers(source)[1]))
	end
end)

function CancelProcessing(playerId)
	if playersProcessingCannabis[playerId] then
		ESX.ClearTimeout(playersProcessingCannabis[playerId])
		playersProcessingCannabis[playerId] = nil
	end
end

RegisterServerEvent('esx_drugs:cancelProcessing')
AddEventHandler('esx_drugs:cancelProcessing', function()
	CancelProcessing(source)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	CancelProcessing(playerId)
end)

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	CancelProcessing(source)
end)
