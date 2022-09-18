----Gets ESX-----
ESX = nil
local ox_inventory = exports.ox_inventory
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
----------------------------------------------------------------

RegisterNetEvent('koe_carwash:getInformation')
AddEventHandler('koe_carwash:getInformation', function(location)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)

  MySQL.Async.fetchAll('SELECT * FROM koe_carwash WHERE location = @location',
  { 
    ['@location'] = location,
  }, 
  function(result)
    for k, v in pairs(result) do
      price = v.price
      TriggerClientEvent('koe_carwash:washMenu', src, location , price)
    end
  end)
end)

RegisterNetEvent('koe_carwash:checkMoney')
AddEventHandler('koe_carwash:checkMoney', function(location, price)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  local identifier =  ESX.GetPlayerFromId(src).identifier

  MySQL.Async.fetchAll('SELECT * FROM koe_carwash WHERE location = @location',
    { 
      ['@location'] = location,
    }, 
    function(result)
        local stock = result[1].stock

        if result[1].owner == nil then
          TriggerClientEvent('koe_carwash:washTheCar', src, location, price)
        else
          if result[1].owner == identifier then
            TriggerClientEvent('koe_carwash:washTheCar', src, location, price)
          else
              if stock <= 0 then
                TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'This location has ran out of soap and supplies', duration = 8000, position = 'top'})
                TriggerClientEvent('koe_carwash:spawnZones', src)
              else
                if xPlayer.getMoney() >= price then
                  TriggerClientEvent('koe_carwash:washTheCar', src, location, price)
            
                  MySQL.Async.fetchAll('SELECT * FROM koe_carwash WHERE location = @location',
                  { 
                    ['@location'] = location,
                  }, 
                  function(result)
                        local newBalance = result[1].balance + price
      
                        MySQL.Async.fetchAll("UPDATE koe_carwash SET balance = @newBalance WHERE location = @location",{['@newBalance'] = newBalance, ['@location'] = location}, function(result)
                          xPlayer.removeMoney(price)
                        end)
                        local newStock = stock - 1
      
                        if newStock <= 0 then
                          newstock = 0
                        end
                        
                        MySQL.Async.fetchAll("UPDATE koe_carwash SET stock = @newstock WHERE location = @location",{['@newstock'] = newStock, ['@location'] = location}, function(result)
                        end)
                  end)
                else
                  TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Not enough money', duration = 8000, position = 'top'})
                  TriggerClientEvent('koe_carwash:spawnZones', src)
                end
              end
          end
        end
    end)
end)

RegisterNetEvent('koe_carwash:checkLocation')
AddEventHandler('koe_carwash:checkLocation', function(location)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier =  ESX.GetPlayerFromId(src).identifier

    MySQL.Async.fetchAll('SELECT * FROM koe_carwash WHERE location = @location',
    { 
      ['@location'] = location,
    }, 
    function(result)
        if result[1].owner == nil then
          TriggerClientEvent('koe_carwash:buyMenu', src, location)
        elseif result[1].owner == identifier then
          local balance = result[1].balance
          local stock = result[1].stock
          local price = result[1].price

          TriggerClientEvent('koe_carwash:ownerMenu', src, location, balance, stock, price)
        else
          TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'This wash is already owned', duration = 8000, position = 'top'})
        end
    end)
end)

RegisterNetEvent('koe_carwash:buyWashLocation')
AddEventHandler('koe_carwash:buyWashLocation', function(location)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier =  ESX.GetPlayerFromId(src).identifier

    MySQL.Async.fetchAll('SELECT * FROM koe_carwash WHERE location = @location',
    { 
      ['@identifier'] = identifier,
      ['@location'] = location
    },
    function(result2) 

      if xPlayer.getMoney() >= Config.PurchasePrice then
        MySQL.Async.fetchAll("UPDATE koe_carwash SET owner = @owner WHERE location = @location",{['@owner'] = identifier, ['@location'] = location}, function(result)
          xPlayer.removeMoney(Config.PurchasePrice)
        end)
      else
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Not enough money', duration = 8000, position = 'top'})
      end

    end) 
end)

RegisterNetEvent('koe_carwash:getCurrentStock')
AddEventHandler('koe_carwash:getCurrentStock', function(location)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)

  MySQL.Async.fetchAll('SELECT * FROM koe_carwash WHERE location = @location',
    { 
      ['@location'] = location
    },
    function(result) 
      local accountBalance = result[1].balance
      local newAccountBalance = accountBalance - Config.CostForSupplyRun
  
      if accountBalance < Config.CostForSupplyRun then
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Not enough money in the account, the account needs to have atleast $'..Config.CostForSupplyRun, duration = 8000, position = 'top'})
      else
        local currentStock = result[1].stock

        MySQL.Async.fetchAll("UPDATE koe_carwash SET balance = @balance WHERE location = @location",{['@balance'] = newAccountBalance, ['@location'] = location}, function(result)
              if currentStock == 100 then
                TriggerClientEvent('ox_lib:notify', src, {type = 'inform', description = 'Stock is already '..currentStock, duration = 8000, position = 'top'})
              else
                TriggerClientEvent('koe_carwash:updateStock', src, location, balance, stock, price)
              end
        end)
      end

    end) 
end)

RegisterNetEvent('koe_carwash:Stock')
AddEventHandler('koe_carwash:Stock', function(location)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)

  MySQL.Async.fetchAll('SELECT * FROM koe_carwash WHERE location = @location',
    { 
      ['@location'] = location
    },
    function(result) 
      local suppliedStock = result[1].stock + Config.SupplyAmount

      if suppliedStock > 100 then
        suppliedStock = 100
      end

      MySQL.Async.fetchAll("UPDATE koe_carwash SET stock = @stock WHERE location = @location",{['@stock'] = suppliedStock, ['@location'] = location}, function(result)
        TriggerClientEvent('ox_lib:notify', src, {type = 'inform', description = 'You recieved %'..Config.SupplyAmount..' Stock Supplies.', duration = 8000, position = 'top'})
      end)

    end) 
end)

RegisterNetEvent('koe_carwash:Deposit')
AddEventHandler('koe_carwash:Deposit', function(location, balance, stock, price, amount)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  local newMoneyBalance = balance + amount

  if xPlayer.getMoney() >= amount then

    xPlayer.removeMoney(amount)

    MySQL.Async.fetchAll('SELECT * FROM koe_carwash WHERE location = @location',
    { 
      ['@location'] = location
    },
    function(result) 

      MySQL.Async.fetchAll("UPDATE koe_carwash SET balance = @balance WHERE location = @location",{['@balance'] = newMoneyBalance, ['@location'] = location}, function(result)

      end)

    end) 
  else
    TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Not enough money', duration = 8000, position = 'top'})
  end
  
end)

RegisterNetEvent('koe_carwash:Remove')
AddEventHandler('koe_carwash:Remove', function(location, balance, stock, price, Withamount)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  
  MySQL.Async.fetchAll('SELECT * FROM koe_carwash WHERE location = @location',
    { 
      ['@location'] = location
    },
    function(result) 
      local currentBalance = result[1].balance
      local withBalance = currentBalance - Withamount

      if currentBalance < Withamount then
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Not enough money in the account', duration = 8000, position = 'top'})
      else
        MySQL.Async.fetchAll("UPDATE koe_carwash SET balance = @balance WHERE location = @location",{['@balance'] = withBalance, ['@location'] = location}, function(result)
          xPlayer.addInventoryItem('money', Withamount)
        end)
      end

    end) 
end)

RegisterNetEvent('koe_carwash:Price')
AddEventHandler('koe_carwash:Price', function(location, balance, stock, price, newPrice)

  MySQL.Async.fetchAll("UPDATE koe_carwash SET price = @price WHERE location = @location",{['@price'] = newPrice, ['@location'] = location}, function(result)
    TriggerClientEvent('ox_lib:notify', src, {type = 'inform', description = 'The price has been updated', duration = 8000, position = 'top'})
  end)

end)

RegisterNetEvent('koe_carwash:giveMembership')
AddEventHandler('koe_carwash:giveMembership', function(location, balance, stock, price)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)

  ox_inventory:AddItem(src, 'washmembership', 1, '\n Type: Unlimited')

end)