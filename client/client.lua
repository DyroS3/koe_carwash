----Gets ESX-------------------------------------------------------------------------------------------------------------------------------
ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end
	PlayerLoaded = true
	ESX.PlayerData = ESX.GetPlayerData()

end)

Citizen.CreateThread(function()
	RegisterNetEvent('esx:playerLoaded')
	AddEventHandler('esx:playerLoaded', function (xPlayer)
		while ESX == nil do
			Citizen.Wait(0)
		end
		ESX.PlayerData = xPlayer
		PlayerLoaded = true
        CreateBlips()
        SpawnWashZones()
	end)
end) 

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    CreateBlips()
    SpawnWashZones()
    SpawnBossZones()
end)

AddEventHandler('onResourceStart', function(resourceName)
	if (resourceName == GetCurrentResourceName()) then
        while (ESX == nil) do Citizen.Wait(100) end        
        Citizen.Wait(5000)
        ESX.PlayerLoaded = true
        CreateBlips()
        SpawnWashZones()
	end
end)
---------------------------------------------------------------------------------------------------------------------------------------
function CreateBlips()
    for k, v in pairs(Config.CarWashes) do
        local washBlips = AddBlipForCoord(v.washcoords)

        SetBlipSprite(washBlips, v.blip.sprite)
        SetBlipDisplay(washBlips, 2)
        SetBlipScale(washBlips, 0.5)
        SetBlipColour(washBlips, v.blip.color)
        SetBlipAsShortRange(washBlips, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(v.blip.label)
        EndTextCommandSetBlipName(washBlips)
    end
end

function SpawnWashZones()
    local player = PlayerPedId()
    local wash = {}

    for k, v in pairs(Config.CarWashes) do
        table.insert(wash, v)
    end

    for number, carwash in pairs(wash) do
        local washZones = lib.points.new(carwash.washcoords, 5)

        function washZones:nearby()
            if not IsPedOnFoot(player) then
                DrawMarker(36, carwash.washcoords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 51, 153, 225, 50, false, true, 2, nil, nil, false)
                lib.showTextUI('[E] - Wash Vehicle Menu', {
                    position = "right",
                    icon = 'car',
                }) 
                if self.currentDistance < 2 and IsControlJustReleased(0, 38) then
                    location = carwash.location
                    TriggerEvent('koe_carwash:getInfo', location)
                    washZones:remove()
                end
            end
        end

        local bossMenu = lib.points.new(carwash.bosscoords, 3)

        function bossMenu:nearby()
            lib.showTextUI('[E] - Car Wash Menu', {
                position = "right",
            }) 
    
            if IsControlJustReleased(0, 38) then
                location = carwash.location
                TriggerEvent('koe_carwash:checkOwned', location)
            end
        end
        function bossMenu:onExit()
            lib.hideTextUI()
        end
    end
end

RegisterNetEvent('koe_carwash:getInfo')
AddEventHandler('koe_carwash:getInfo',function(location)
    TriggerServerEvent('koe_carwash:getInformation', location)
end)

RegisterNetEvent('koe_carwash:washMenu')
AddEventHandler('koe_carwash:washMenu',function(location , price)
    lib.registerContext({
        id = 'WashMenu',
        title = location,
        options = {
            {
                title = 'Wash Vehicle For $'..price,
                arrow = true,
                event = 'koe_carwash:checkMoney',
                icon = 'fas fa-soap',
                args = {location = location, price = price}
            },
            -- {
            --     title = 'Buy Membership',
            --     arrow = true,
            --     event = 'koe_carwash:buyMembership',
            --     icon = 'fas fa-soap',
            --     args = {location = location, price = price}
            -- },
            lib.registerContext({
                id = 'WashMenu',
                options = options
            })
        }
    })
        lib.showContext('WashMenu')
end)

RegisterNetEvent('koe_carwash:checkMoney')
AddEventHandler('koe_carwash:checkMoney',function(data)
    location = data.location
    price = data.price

    TriggerServerEvent('koe_carwash:checkMoney', location, price)
end)

RegisterNetEvent('koe_carwash:buyMembership')
AddEventHandler('koe_carwash:buyMembership',function(data)
    location = data.location
    price = data.price

    TriggerServerEvent('koe_carwash:giveMembership', location, price)
end)

RegisterNetEvent('koe_carwash:washTheCar')
AddEventHandler('koe_carwash:washTheCar',function(location, price)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local pedCoords = GetEntityCoords(ped)
    UseParticleFxAssetNextCall("core")
    particles = StartParticleFxLoopedAtCoord("ent_amb_waterfall_splash_p", pedCoords.x, pedCoords.y, pedCoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    UseParticleFxAssetNextCall("core")
    particles2 = StartParticleFxLoopedAtCoord("ent_amb_waterfall_splash_p", pedCoords.x + 2, pedCoords.y, pedCoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)

    if lib.progressBar({
        duration = 30000,
        label = 'Washing Vehicle',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
        },
    }) 
    then 
        SpawnWashZones()
        lib.notify({
            description = 'Vehicle has been cleaned',
            type = 'success',
            duration = 8000,
            position = 'top'
        })
        SetVehicleDirtLevel(vehicle, 0)
        StopParticleFxLooped(particles, 0)
        StopParticleFxLooped(particles2, 0)
    else 
        SpawnWashZones()
        StopParticleFxLooped(particles, 0)
        StopParticleFxLooped(particles2, 0)
        lib.notify({
            description = 'Wash Cancelled',
            type = 'inform',
            duration = 8000,
            position = 'top'
        })
    end

end)

RegisterNetEvent('koe_carwash:checkOwned')
AddEventHandler('koe_carwash:checkOwned', function(location)

    TriggerServerEvent('koe_carwash:checkLocation', location)
end)

RegisterNetEvent('koe_carwash:buyMenu')
AddEventHandler('koe_carwash:buyMenu',function(location)

    lib.registerContext({
        id = 'buymenu',
        title = 'Car Wash',
        options = {
            ['Purchase Unit'] = {
                description = 'Purchase this Car Wash',
                arrow = true,
                event = 'koe_carwash:buyCarWash',
                metadata = {
                    {label = 'Location', value = location},
                    {label = 'Price', value = Config.PurchasePrice},
                },
                args = {location = location}
            }
        }
    })
    lib.showContext('buymenu')

end)

RegisterNetEvent('koe_carwash:buyCarWash')
AddEventHandler('koe_carwash:buyCarWash', function(data)
    location = data.location

    TriggerServerEvent('koe_carwash:buyWashLocation', location)
end)   

RegisterNetEvent('koe_carwash:ownerMenu')
AddEventHandler('koe_carwash:ownerMenu',function(location, balance, stock, price)

    lib.registerContext({
        id = 'OwnerMenu',
        title = location,
        options = {
            {
                title = 'Supplies Stock',
                arrow = true,
                event = 'koe_carwash:checkCurrentStock',
                icon = 'fas fa-soap',
                description = 'Current Stock: %'..stock,
                args = {location = location, balance = balance, stock = stock, price = price},
            },
            {
                title = 'Finances',
                arrow = true,
                event = 'koe_carwash:Finances',
                icon = 'fas fa-sack-dollar',
                description = 'Current Balance: $'..balance,
                args = {location = location, balance = balance, stock = stock, price = price},
            },
            {
                title = 'Click to change Price per wash',
                arrow = true,
                event = 'koe_carwash:ChangePrice',
                icon = 'fas fa-credit-card',
                description = '$'..price,
                args = {location = location, balance = balance, stock = stock, price = price},
            },
            lib.registerContext({
                id = 'MainMenu',
                options = options
            })
        }
    })
        lib.showContext('OwnerMenu')

end)

RegisterNetEvent('koe_carwash:Finances')
AddEventHandler('koe_carwash:Finances', function(data)
    location = data.location
    balance = data.balance
    stock = data.stock
    price = data.price

    lib.registerContext({
        id = 'Finances',
        title = location,
        menu = 'OwnerMenu',
        options = {
            {
                title = 'Account Balance',
                icon = 'fas fa-sack-dollar',
                description = '$'..balance,
                args = {location = location, balance = balance, stock = stock, price = price},
            },
            {
                title = 'Deposit',
                arrow = true,
                event = 'koe_carwash:DepositMoney',
                args = {location = location, balance = balance, stock = stock, price = price},
            },
            {
                title = 'Withdrawal',
                arrow = true,
                event = 'koe_carwash:RemoveMoney',
                args = {location = location, balance = balance, stock = stock, price = price},
            },
            lib.registerContext({
                id = 'Finances',
                options = options
            })
        }
    })
        lib.showContext('Finances')
end) 

RegisterNetEvent('koe_carwash:DepositMoney')
AddEventHandler('koe_carwash:DepositMoney', function(data)
    location = data.location
    balance = data.balance
    stock = data.stock
    price = data.price

    local input = lib.inputDialog('How much?', {'Deposit'})

    if input then
        local amount = tonumber(input[1])
        TriggerServerEvent('koe_carwash:Deposit', location, balance, stock, price, amount)
    end


end)

RegisterNetEvent('koe_carwash:RemoveMoney')
AddEventHandler('koe_carwash:RemoveMoney', function(data)
    location = data.location
    balance = data.balance
    stock = data.stock
    price = data.price

    local input2 = lib.inputDialog('How much?', {'Withdrawal'})

    if input2 then
        local Withamount = tonumber(input2[1])
        TriggerServerEvent('koe_carwash:Remove', location, balance, stock, price, Withamount)
    end
end) 

RegisterNetEvent('koe_carwash:ChangePrice')
AddEventHandler('koe_carwash:ChangePrice', function(data)
    location = data.location
    balance = data.balance
    stock = data.stock
    price = data.price

    local input3 = lib.inputDialog('Enter new price', {'Current Price: $'..price})

    if input3 then
        local newPrice = tonumber(input3[1])
        TriggerServerEvent('koe_carwash:Price', location, balance, stock, price, newPrice)
    end
end)

RegisterNetEvent('koe_carwash:checkCurrentStock')
AddEventHandler('koe_carwash:checkCurrentStock', function(data)
    location = data.location
    balance = data.balance
    stock = data.stock
    price = data.price

    lib.registerContext({
        id = 'stockMenu',
        title = 'Stock Menu',
        options = {
            {
                title = 'Supply Stock Information',
            },
            {
                title = 'Purchase Supplies',
                arrow = true,
                event = 'koe_carwash:order',
                description = 'Click to purchase stock, hover for info.',
                metadata = {
                    {label = 'Current Stock', value = stock},
                    {label = 'Price Per Run', value = Config.CostForSupplyRun},
                },
                args = {location = location, balance = balance, stock = stock, price = price},
            },
            lib.registerContext({
                id = 'stockMenu',
                options = options
            })
        }
    })
        lib.showContext('stockMenu')
end)

RegisterNetEvent('koe_carwash:order')
AddEventHandler('koe_carwash:order', function(data)
    location = data.location
    balance = data.balance
    stock = data.stock
    price = data.price

    TriggerServerEvent('koe_carwash:getCurrentStock', location, balance, stock, price)
end)

RegisterNetEvent('koe_carwash:updateStock')
AddEventHandler('koe_carwash:updateStock', function(location, balance, stock, price)
    pickup = Config.SupplyPickups[math.random(#Config.SupplyPickups)]

    lib.notify({
        description = 'Head to the location to pickup supplies',
        type = 'inform',
        duration = 8000,
        position = 'top'
    })

    sphere = lib.zones.sphere({
        coords = pickup,
        radius = 10,
        debug = false,
        location = location,
        inside = inside,
        onEnter = onEnter,
        onExit = onExit
    })

    Blip = AddBlipForCoord(pickup)
    SetBlipRoute(Blip,true)
end)   

function inside(self)
    inZone = true
    local pedCoords = GetEntityCoords(PlayerPedId()) 
    local dst = #(sphere.coords - pedCoords)

    if dst < 3  then
        lib.showTextUI('[E] - Pickup Supplies', {
            position = "right",
            icon = 'cube',
        }) 
    end

    location = sphere.location

    DrawMarker(20, sphere.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 51, 153, 225, 50, false, true, 2, nil, nil, false)

    if IsControlJustReleased(0, 38) and inZone == true then
        RemoveBlip(Blip)

        lib.hideTextUI()
        sphere:remove()
        lib.progressBar({
            duration = 15000,
            label = 'Picking Up Supplies.',
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
                move = true,
            },
            anim = {
                dict = 'amb@prop_human_bum_bin@base',
                clip = 'base' 
            },
        })

        TriggerServerEvent('koe_carwash:Stock', location)
    end

end

function onExit(self)
    inZone = false
    lib.hideTextUI()
end