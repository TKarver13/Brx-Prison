local QBCore = exports['qb-core']:GetCoreObject()

local PlayerJob = nil


--save jail time  stuff

-- Save Remaining Jail Time in the Database
local function saveRemainingTime(playerId, remainingTime)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player then
        local citizenId = Player.PlayerData.citizenid
        MySQL.update('UPDATE prison_records SET remaining_time = ? WHERE citizenid = ?', {remainingTime, citizenId})
    end
end

-- Load Jail Time from the Database
local function loadRemainingTime(playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player then
        local citizenId = Player.PlayerData.citizenid
        MySQL.query('SELECT remaining_time FROM prison_records WHERE citizenid = ?', {citizenId}, function(result)
            if result[1] and result[1].remaining_time > 0 then
                Player.Functions.SetMetaData('injail', result[1].remaining_time)
                TriggerClientEvent('brx-prison:client:ReapplyJail', playerId, result[1].remaining_time)
            else
                Player.Functions.SetMetaData('injail', 0)
            end
        end)
    end
end

local function SaveJailInventory(playerId, jailTime)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if not Player then return end

    -- Make sure jailTime doesnt register nil or it throws an error.
    if jailTime == nil then
        jailTime = 0
    end
    
    -- Only save inventory if player is in jail
    if jailTime > 0 then
        local jailInventory = Inventory.GetInventory(playerId)

        -- Convert table to JSON
        local jsonData = json.encode(jailInventory)

        -- Save prisonpocket and clear the OX inventory storage
        MySQL.Async.execute('UPDATE players SET prisonpocket = ?, inventory = ? WHERE citizenid = ?', 
            {jsonData, '{}', Player.PlayerData.citizenid})
    else
        --Do Nothing
    end
end




RegisterNetEvent('brx-prison:server:SaveJailItems', function()

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then 
        print("\27[38;5;206m[ERROR:]\27[0m JailSaveLogic- Player not found for source", src)
        return 
    end
    -- Ensure `jailitems` are properly stored on initial jailing
    local existingJailItems = Player.PlayerData.metadata['jailitems']
    if not existingJailItems or type(existingJailItems) ~= "table" or next(existingJailItems) == nil then
        local items = Inventory.GetInventory(src) -- Get current inventory
        if items and next(items) then
            Player.Functions.SetMetaData('jailitems', items) -- Store items in metadata
        else
            -- Do nothing
        end
    else
        -- Skip
    end

    -- Clear player's inventory after saving jail items
    Wait(2000)
    exports.ox_inventory:ClearInventory(src)

end)


RegisterNetEvent('brx-prison:server:getprisonpocket', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenId = Player.PlayerData.citizenid

    -- Fetch prison pocket inventory from the database
    MySQL.Async.fetchScalar('SELECT prisonpocket FROM players WHERE citizenid = ?', {citizenId}, function(result)
        local jailInventory = {}

        -- Ensure result is valid JSON before decoding
        if result and result ~= "" then
            local success, decoded = pcall(json.decode, result)
            if success and type(decoded) == "table" then
                jailInventory = decoded
            end
        end

        if next(jailInventory) then
            -- Restore items to player
            for _, item in pairs(jailInventory) do
                Inventory.AddItem(src, item.name, item.count, item.metadata)
            end

            -- Clear prisonpocket in the database after restoring
            Wait(500)
            MySQL.Async.execute('UPDATE players SET prisonpocket = ? WHERE citizenid = ?', {'{}', citizenId})
        else
            -- If no items exist, give jail commissary money ONCE
            Player.Functions.AddMoney('cash', 50, 'jail money')
        end
    end)
end)





RegisterNetEvent('brx-prison:server:jailinventorysave', function()
    local playerId = source
    SaveJailInventory(playerId)
end)



RegisterNetEvent('brx-prison:server:GiveJailItems', function(escaped)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenId = Player.PlayerData.citizenid

    local function ClearPrisonPocket()
        MySQL.Async.execute('UPDATE players SET prisonpocket = ? WHERE citizenid = ?', {'{}', citizenId})
    end

    if escaped then
        Wait(100)
        Player.Functions.SetMetaData('jailitems', {})
        Wait(100)
        ClearPrisonPocket() -- Clears prisonpocket in the database
        return
    end

    local jailItems = Player.PlayerData.metadata['jailitems'] or {}

    if jailItems and next(jailItems) then
        for _, item in pairs(jailItems) do
            Inventory.AddItem(src, item.name, item.count, item.metadata)
        end
        Wait(100)
        Player.Functions.SetMetaData('jailitems', {})
        Wait(100)
        ClearPrisonPocket() -- Clears prisonpocket in the database
    else
        Wait(100)
        Player.Functions.SetMetaData('jailitems', {})
        Wait(100)
        ClearPrisonPocket() -- Clears prisonpocket in the database
    end
end)



RegisterNetEvent('brx-prison:server:CheckRecordStatus', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local CriminalRecord = Player.PlayerData.metadata['criminalrecord']
    local currentDate = os.date('*t')

    if (CriminalRecord['date'].month + 1) == 13 then
        CriminalRecord['date'].month = 0
    end

    if CriminalRecord['hasRecord'] then
        if currentDate.month == (CriminalRecord['date'].month + 1) or currentDate.day == (CriminalRecord['date'].day - 1) then
            CriminalRecord['hasRecord'] = false
            CriminalRecord['date'] = nil
        end
    end
end)


RegisterNetEvent('brx-prison:server:CheckChance', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or Player.PlayerData.metadata.injail == 0 then return end
    local chance = math.random(100)

    if chance <= 5 then
        -- Give 2 items if the roll is 15 or lower
        if not exports.ox_inventory:AddItem(src, 'hiddenstashitem', 2) then return end
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items['hiddenstashitem'], 'add')
        TriggerClientEvent('QBCore:Notify', src, Lang:t('success.found_stashitem_double'), 'success') -- Different message for 2 items
    
    elseif chance <= 35 then
        -- Give 1 item only if the roll is between 16 and 40
        if not exports.ox_inventory:AddItem(src, 'hiddenstashitem', 1) then return end
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items['hiddenstashitem'], 'add')
        TriggerClientEvent('QBCore:Notify', src, Lang:t('success.found_stashitem'), 'success')
    end
    
    
end)



-- Get Food/Drink
RegisterNetEvent("brx-prison:custom:food", function(zone)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
            Player.Functions.AddItem('prisonloaf', 1) -- Give 1 
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items['prisonloaf'], "add")
    end
end)

RegisterNetEvent("brx-prison:custom:drink", function(zone)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
            Player.Functions.AddItem('prisonwater', 1) -- Give 1 
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items['prisonwater'], "add")
    end

end)




RegisterNetEvent('brx-prison:server:SetJailStatus', function(jailTime)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end


    Player.Functions.SetMetaData('injail', jailTime)
 -- This function throws errors sometimes when checking jailTime, but its a null error and can be ignored until I figure out a workaround
    if jailTime > 0 then
        saveRemainingTime(src, jailTime)

        if Player.PlayerData.job.name ~= 'unemployed' then
            Player.Functions.SetMetaData('prejailjob', Player.PlayerData.job.name)
            Player.Functions.SetMetaData('prejailgrade', Player.PlayerData.job.grade.level)
            Player.Functions.SetJob('unemployed')
            TriggerClientEvent('QBCore:Notify', src, 'You have been jailed. Your job has been temporarily removed.', 'error')
        end
    else
        --Do Nothing
    end
end)

RegisterNetEvent('brx-prison:server:RestoreJob', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local previousJob = Player.PlayerData.metadata.prejailjob or 'unemployed'
    local previousGrade = Player.PlayerData.metadata.prejailgrade or 0
    Player.Functions.SetJob(previousJob, previousGrade)
    TriggerClientEvent('QBCore:Notify', src, 'You have been released from jail. Your job has been restored.', 'success')


    Player.Functions.SetMetaData('prejailjob', nil)
    Player.Functions.SetMetaData('prejailgrade', nil)
end)






-- Save Jail Time on Logout
AddEventHandler('playerDropped', function(reason)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local jailTime = Player.PlayerData.metadata['injail'] or 0
        saveRemainingTime(src, jailTime)
        SaveJailInventory(src, jailTime)
    end
end)

-- Load Jail Time on Player Connecting
AddEventHandler('playerConnecting', function()
    local src = source
    loadRemainingTime(src)
end)

-- Decrement Jail Time Every Minute
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Every minute

        for _, playerId in ipairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(playerId)

            if Player then
                local jailTime = Player.PlayerData.metadata['injail'] or 0

                if jailTime > 0 then
                    local newJailTime = jailTime - 1
                    Player.Functions.SetMetaData('injail', newJailTime)
                    saveRemainingTime(playerId, newJailTime)

                    -- ✅ Sync the updated jail time with the client
                    TriggerClientEvent('brx-prison:client:UpdateJailTime', playerId, newJailTime)

                    end
                end
            end
        end
end)



-- Server Side Logic for Hidden Stashes
local selectedStashes = {} -- Stores selected stash locations

RegisterNetEvent("brx-prison:server:SyncStashLocations", function()
    TriggerClientEvent("brx-prison:client:SyncStashLocations", -1, selectedStashes)
end)

local function SelectRandomStashes()
    math.randomseed(os.time()) -- ✅ Ensures randomness
    selectedStashes = {}


    while #selectedStashes < 2 do
        local randomIndex = math.random(1, #Config.StashLocations)
        local selected = Config.StashLocations[randomIndex]


        local duplicate = false
        for _, stash in pairs(selectedStashes) do
            if stash.coords.x == selected.coords.x and stash.coords.y == selected.coords.y then
                duplicate = true
                break
            end
        end

        if not duplicate then
            table.insert(selectedStashes, selected)
        end
    end

    TriggerClientEvent("brx-prison:client:SyncStashLocations", -1, selectedStashes)
end


RegisterNetEvent("brx-prison:server:TakeStashItem", function(stashCoords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end


    local randomItem = Config.StashItems[math.random(1, #Config.StashItems)]
    Player.Functions.AddItem(randomItem, 1)
    TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[randomItem], "add")


    for i, stash in ipairs(selectedStashes) do
        if stash.coords.x == stashCoords.x and stash.coords.y == stashCoords.y then
            table.remove(selectedStashes, i)
            break
        end
    end


    TriggerClientEvent("brx-prison:client:SyncStashLocations", -1, selectedStashes)
end)

CreateThread(function()
    Wait(3000) 
    SelectRandomStashes()
end)



--The Stash

--storage fridge
RegisterNetEvent('brx-prison:server:TheStash', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local stashName = 'Prison Stash'
    local stashInfo = {
        weight = 100000,
        slots = 50,
    }
    if Player then
        exports['qb-inventory']:OpenInventory(src, stashName, {
            maxweight = stashInfo.weight,
            slots = stashInfo.slots,
        })
    end
end)



function TheStash()
    local storage = {
        id = 'thestash',
        label = 'Prison Stash',
        slots = 50,
        weight = 100000,
        owner = true,
    }
    exports.ox_inventory:RegisterStash(storage.id, storage.label, storage.slots, storage.weight, storage.owner, storage.jobs)
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        TheStash()
    end
end)