local QBCore = exports['qb-core']:GetCoreObject()
local notify = Config.Notify 


math.randomseed(os.time())

dice = math.random(1, 100)



-- Big Bob
QBCore.Functions.CreateCallback("brx-prison:server:gettotaljailtime", function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(0) end -- Default to 0 if player is invalid

    local citizenid = Player.PlayerData.citizenid
    if not citizenid then
        return cb(0)  -- If citizenid is missing, return 0
    end

    local result = Player.PlayerData.metadata.totaljailtime or 0

    if result then
        cb(result)
    else
        cb(0) -- Default to 0 if no result found
    end

end)

RegisterNetEvent("brx-prison:server:setbigbobjob", function(source, choice)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end -- Make sure player exists

    Player.Functions.SetMetaData("currentbigbobjob", choice)
    Player.Functions.SetMetaData("bigbobjobprogress", 0)
    Player.Functions.SetMetaData("bigbobjobdone", false)

    print("^2[DEBUG] Set bigbobjob for player:", source, "Job:", choice)
end)


RegisterNetEvent("brx-prison:server:setbobtarget", function(source, targetPed)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end -- Make sure player exists
    Player.Functions.SetMetaData("bigbobjobtarget", NetworkGetNetworkIdFromEntity(targetPed))
end)



-- Pickup event (modified for targeted pickups)
RegisterNetEvent("brx-prison:server:collectPickup", function(data)
    local Player = QBCore.Functions.GetPlayerData()
    local currentJob = Player.PlayerData.metadata.currentbigbobjob

    local jobData = Config.BobJobs[currentJob]
    if not jobData then return end

    -- Increase progress
    local progress = (Player.PlayerData.metadata.bigbobjobprogress or 0) + 1
    Player.Functions.SetMetaData("bigbobjobprogress", progress)

    -- Check if job is done
    if progress >= #jobData.pickups then
        Player.Functions.SetMetaData("bigbobjobdone", true)
        QBCore.Functions.Notify("Job completed! Return to Big Bob.", "success", 5000)
        TriggerClientEvent("brx-prison:client:removepickup", Player)
    
    else
        QBCore.Functions.Notify("Pickup collected! " .. (#jobData.pickups - progress) .. " more to go.", "success", 3000)
    end
end)




RegisterNetEvent("brx-prison:server:finishbobjob", function(data)
    local Player = QBCore.Functions.GetPlayerData()
    local jobChoice = data.job
    local currentJob = Player.PlayerData.metadata.currentbigbobjob

    if jobChoice ~= currentJob then
        QBCore.Functions.Notify("You're not working on this job!", "error", 5000)
        return
    end

    if not Player.PlayerData.metadata.bigbobjobdone then
        QBCore.Functions.Notify("You haven't finished your job yet!", "error", 5000)
        return
    end

    local jobData = Config.BobJobs[jobChoice]
    if not jobData then
        QBCore.Functions.Notify("Invalid job data!", "error", 5000)
        return
    end

    -- Give money reward
    Player.Functions.AddMoney("cash", jobData.reward or 100, "Big Bob Job Payout")

    -- Reset job status
    Player.Functions.SetMetaData("currentbigbobjob", nil)
    Player.Functions.SetMetaData("bigbobjobprogress", 0)
    Player.Functions.SetMetaData("bigbobjobdone", false)

    -- Remove pickup targets & blips
    RemovePickupSpotsForJob(GetPlayerServerId(PlayerId()))

    for _, pickup in ipairs(jobData.pickups) do
        if pickup.blip then RemoveBlip(pickup.blip) end
    end

    QBCore.Functions.Notify("Job completed! You received $" .. (jobData.reward or 100), "success", 5000)
end)


-- HiddenStashUsable Item
QBCore.Functions.CreateUseableItem('hiddenstashitem', function(source)
    TriggerClientEvent('brx-prison:client:hiddenstashitem', source)
end)

RegisterNetEvent('brx-prison:hiddenstashitem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then
        print('StashOpen: Player not found!')
        return
    end

    if Player.Functions.GetItemByName('hiddenstashitem') then
        Player.Functions.RemoveItem('hiddenstashitem', 1)
        Player.Functions.AddItem('ls_plain_jane_joint', 1)

        -- Determine number of items to attempt to give
        local amountOfItems = math.random(1, 1)

        if Config and Config.HiddenStashItems then
            for i = 1, amountOfItems do
                local itemData = Config.HiddenStashItems[math.random(1, #Config.HiddenStashItems)]

                local itemName = itemData[1]
                local minAmount = itemData[2]
                local maxAmount = itemData[3]
                local itemChance = itemData[4]

                -- Roll for this specific item
                if math.random(1, 100) <= itemChance then
                    local amountToGive = math.random(minAmount, maxAmount)
                    Player.Functions.AddItem(itemName, amountToGive)
                end
            end
        else
            print("Config.hiddenstashitem is missing or empty!")
        end
    else
        print('Player does not have a hiddenstashitem!')
    end
end)





--Inventory
local invname = ''
CreateThread(function()
if GetResourceState('ps-inventory') == 'started' then
    invname = 'ps-inventory'
elseif GetResourceState('qb-inventory') == 'started' then
    invname = 'qb-inventory'
else
    invname = 'inventory'		
end
end)

local inventory = ''

CreateThread(function()
if GetResourceState('ox_inventory') == 'started' then
    inventory = 'ox'
else
    inventory = 'qb'
end
end)

------ functions

function Notifys(source, text, type)
    local src = source
    if notify == 'qb' then
        TriggerClientEvent("QBCore:Notify", src, text, type)
    elseif notify == 'ox' then
        lib.notify(src, { title = text, type = type})
    elseif notify == 'okok' then
        TriggerClientEvent('okokNotify:Alert', src, '', text, 4000, type, false)
    else
        print"^1 Look At The Config For Proper Alert Options"    
    end    
end

function GetLabels(item) 
    if inventory == 'qb' then
        return QBCore.Shared.Items[item].label
    elseif inventory == 'ox' then
        local items = exports.ox_inventory:Items() 
        return items[item].label
    end
end

function RemoveItem(source, item, amount) 
        local Player = QBCore.Functions.GetPlayer(source)
        if Player.Functions.RemoveItem(item, amount) then 
            TriggerClientEvent(invname ..":client:ItemBox", source, QBCore.Shared.Items[item], "remove", amount)  
            return true
        else 
            Notifys(source, 'You Need ' .. amount .. ' Of ' .. GetLabels(item) .. ' To Do This', 'error')
        end
end

function AddItem(source, item, amount) 
    local carry = exports.ox_inventory:CanCarryItem(source, item, amount)
if not carry then Notifys(source, 'You Cant Carry that Much Weight!', 'error') return false end
        local Player = QBCore.Functions.GetPlayer(source)
        if Player.Functions.AddItem(item, amount) then 
            TriggerClientEvent(invname ..":client:ItemBox", source, QBCore.Shared.Items[item], "add", amount) 
            return true
         else 
            print('Failed To Give Item: ' .. item .. ' Check Your qb-core/shared/items.lua')
            return false
        end
end