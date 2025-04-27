local QBCore = exports['qb-core']:GetCoreObject()

BigBob = nil


CreateThread(function()
    local currentModel = "s_m_y_prismuscl_01"
    lib.requestModel(currentModel, 10000)
    local loc = Config.BobSpawn

    local bigbob = CreatePed(4, currentModel, loc.x, loc.y, loc.z - 1, loc.w, false, true)
    BigBob = bigbob
    SetBlockingOfNonTemporaryEvents(BigBob, true)
    TaskStartScenarioInPlace(BigBob, "WORLD_HUMAN_MUSCLE_FREE_WEIGHTS", 0, true) 
    SetPedConfigFlag(BigBob, 128, true)
    FreezeEntityPosition(BigBob, true)
    SetEntityInvincible(BigBob, true)
   -- SetPedCombatAttributes(BigBob, 5, true)
    SetPedSuffersCriticalHits(BigBob, false)
    SetPedArmour(BigBob, 100)

    AddSingleModel(BigBob, {
        label = 'Billy "Big OG" Bob',
        icon = "fas fa-eye",
        event = "brx-prison:client:bigbobjobs"
    }, BigBob)
end)



----------------------------------------------------------------------
-- OG Prison Big Bob
---------------------------------------------------------------------

local activePickups = {} -- Track active job pickups per player
local activeProps = {} -- Track active props per player

-- Function to add target zones for pickups
function AddPickupSpotsForJob(playerId, choice)
    print("^[DEBUG] AddPickUpSpotsForJob called with", playerId, choice)
    local jobData = Config.BobJobs[choice]
    if not jobData or not jobData.pickups then return end

    -- Ensure this player's pickups are tracked
    activePickups[playerId] = {}
    activeProps[playerId] = {}

    for i, pickup in ipairs(jobData.pickups) do
        local zoneName = "bob_pickup_" .. playerId .. "_" .. i

        -- **SPAWN PROP HERE**
        local propHash = GetHashKey("prop_paper_bag_small") -- Change to the prop you want
        RequestModel(propHash)
        while not HasModelLoaded(propHash) do Wait(100) end

        local propObject = CreateObject(propHash, pickup.coords.x, pickup.coords.y, pickup.coords.z - 1.0, true, true, false)
        SetEntityHeading(propObject, math.random(0, 360)) -- Random rotation for realism
        FreezeEntityPosition(propObject, true) -- Ensure it doesn't move
        SetEntityAsMissionEntity(propObject, true, true)

        -- Store the prop reference
        activeProps[playerId][i] = propObject

        -- **ADD PICKUP TARGET ZONE**
        if Config.Target == 'qb' then
            exports['qb-target']:AddBoxZone(zoneName, vector3(pickup.coords.x, pickup.coords.y, pickup.coords.z), 1.0, 1.0, {
                name = zoneName,
                heading = 0,
                debugPoly = false,
                minZ = pickup.coords.z - 1.0,
                maxZ = pickup.coords.z + 1.0
            }, {
                options = {
                    {
                        icon = "fas fa-hand",
                        label = "Pick Up Item",
                        event = "brx-prison:client:collectPickup",
                        args = { pickupId = i, playerId = playerId },
                        canInteract = function()
                            return GetPlayerServerId(PlayerId()) == playerId -- Ensures only this player can interact
                        end
                    }
                },
                distance = 2.5
            })
        elseif Config.Target == 'ox' then
            exports.ox_target:addSphereZone(zoneName, vector3(pickup.coords.x, pickup.coords.y, pickup.coords.z), 1.0, {
                name = zoneName,
                options = {
                    {
                        icon = "fas fa-hand",
                        label = "Pick Up Item",
                        event = "brx-prison:client:collectPickup",
                        args = { pickupId = i, playerId = playerId },
                        canInteract = function()
                            return GetPlayerServerId(PlayerId()) == playerId
                        end
                    }
                },
                distance = 2.5
            })
        end

        -- Store pickup zones for cleanup
        table.insert(activePickups[playerId], zoneName)
    end
end


function RemovePickupSpotsForJob(playerId)
    if not activePickups[playerId] then return end

    -- Remove target zones
    for _, zone in ipairs(activePickups[playerId]) do
        if Config.Target == 'qb' then
            exports['qb-target']:RemoveZone(zone)
        elseif Config.Target == 'ox' then
            exports.ox_target:removeZone(zone)
        end
    end

    -- Remove props
    if activeProps[playerId] then
        for _, prop in pairs(activeProps[playerId]) do
            DeleteObject(prop)
        end
        activeProps[playerId] = nil
    end

    activePickups[playerId] = nil
end

function GetCurrentBigBobJob()
    local playerData = QBCore.Functions.GetPlayerData()
    return playerData.metadata and playerData.metadata.currentbigbobjob or nil
end


RegisterNetEvent("brx-prison:client:removepickup", function(Player)
    RemovePickupSpotsForJob(Player)
end)


RegisterNetEvent("brx-prison:client:bigbobjobs", function()

    local currentJob = GetCurrentBigBobJob()

    if currentJob then
        print("^2[DEBUG] Player is already on a job:", currentJob)

        -- Send the player to turn in the job
        TriggerEvent("brx-prison:client:turnInJob", currentJob)
        return
    end


    QBCore.Functions.TriggerCallback("brx-prison:server:gettotaljailtime", function(totalJailTime)
        totalJailTime = totalJailTime or 0 -- Default to 0 if nil
        print('^2[DEBUG] Retrieved totalJailTime:', totalJailTime)

        local bigbobjobs = {}

        -- Iterate in order using ipairs()
        for index, job in ipairs(Config.BobJobs) do
            print("^2[DEBUG] Checking job:", job.label, "Choice:", job.name, "Required Jail Time:", job.jailtimeRequired)

            if totalJailTime >= job.jailtimeRequired then
                print("^2[DEBUG] Job Added:", job.label)
                table.insert(bigbobjobs, {
                    icon = "fa-solid fa-list",
                    title = job.label,
                    event = "brx-prison:client:selectbigbobjob",
                    args = { choice = job.name }
                })
            else
                print("^1[DEBUG] Job Skipped:", job.label, "- Needed:", job.jailtimeRequired, "You Have:", totalJailTime)
            end
        end

        -- Show the menu if there are jobs available, otherwise notify
        if #bigbobjobs > 0 then
            print("^2[DEBUG] Menu Jobs Added:", json.encode(bigbobjobs))
            lib.registerContext({ id = 'bigbobjobs', title = "Need something?", options = bigbobjobs })
            lib.showContext('bigbobjobs')
        else
            print("^1[DEBUG] No jobs available. Sending notify.")
            QBCore.Functions.Notify("You haven't served enough time, new blood. Get outta here!", "error", 5000)
        end
    end)
end)





RegisterNetEvent("brx-prison:client:selectbigbobjob", function(data)
    print("^2[DEBUG] Received job data:", json.encode(data))

    local choice = data.choice
    if not choice then
        print("^1[ERROR] No job choice received! Data is nil or missing choice.")
        return
    end

    -- Find the job in Config.BobJobs
    local jobData = nil
    for _, job in ipairs(Config.BobJobs) do
        if job.name == choice then
            jobData = job
            break
        end
    end

    if not jobData then
        print("^1[ERROR] Job not found in Config.BobJobs! Choice received:", choice)
        QBCore.Functions.Notify("Invalid job selection!", "error", 5000)
        return
    end

    print("^2[DEBUG] Job found! Starting job:", jobData.label)

  
    if choice == "yard_cleaning" then
        TriggerServerEvent("brx-prison:server:setbigbobjob", choice)

    -- Spawn pickup target zones
    AddPickupSpotsForJob(GetPlayerServerId(PlayerId()), choice)
    local theplayer = GetPlayerServerId(PlayerId())
    print("^1[DEBUGG]! Doesplayerid Get from here:", theplayer)
    end
    if choice == "contraband_delivery" then
        -- Do the thing
    end
    if choice == "collect_debt" then
        -- Do the thing
    end
    -- Job-specific logic for "kill_snitch"
    if choice == "kill_snitch" then
        local pedModel = "s_m_y_prisoner_01"
        RequestModel(pedModel)
        while not HasModelLoaded(pedModel) do
            Wait(100)
        end

        local targetPed = CreatePed(4, GetHashKey(pedModel), jobData.targetSpawn.x, jobData.targetSpawn.y, jobData.targetSpawn.z, jobData.targetSpawn.w, true, true)
        SetEntityAsMissionEntity(targetPed, true, true)
        SetPedFleeAttributes(targetPed, 0, false)
        SetPedCombatAttributes(targetPed, 46, true)
        TaskCombatPed(targetPed, PlayerPedId(), 0, 16)

        TriggerServerEvent("brx-prison:server:setbobtarget", targetPed)
        -- Store target in metadata for tracking
        

        -- Check if ped is dead
        CreateThread(function()
            while DoesEntityExist(targetPed) do
                if IsEntityDead(targetPed) then
                    TriggerServerEvent("brx-prison:server:finishbobjob", choice)
                    QBCore.Functions.Notify("Target eliminated! Return to Big Bob.", "success", 5000)
                    break
                end
                Wait(500)
            end
        end)
    end
    if choice == "buy_something" then
        -- Do the thing
    end

    QBCore.Functions.Notify("Job started: " .. jobData.label, "success", 5000)
end)


RegisterNetEvent("brx-prison:client:collectPickup", function(data)
    local playerId = data.playerId
    local pickupId = data.pickupId

    -- Debugging
    print("^2[DEBUG] Player picked up item:", playerId, "Pickup ID:", pickupId)

    -- Remove the prop
    if activeProps[playerId] and activeProps[playerId][pickupId] then
        DeleteObject(activeProps[playerId][pickupId])
        activeProps[playerId][pickupId] = nil
    end
    TriggerServerEvent("brx-prison:server:collectpickup")
    -- Notify player
    QBCore.Functions.Notify("You picked up the item!", "success", 3000)
end)






RegisterNetEvent("brx-prison:client:turnInJob", function(jobName)
    print("^2[DEBUG] Player is turning in job:", jobName)

    -- Get current job data
    local jobData = nil
    for _, job in ipairs(Config.BobJobs) do
        if job.name == jobName then
            jobData = job
            break
        end
    end

    if not jobData then
        print("^1[ERROR] Job data not found for:", jobName)
        QBCore.Functions.Notify("Error: Job data missing.", "error", 5000)
        return
    end

    -- Check if job is complete
    local playerData = QBCore.Functions.GetPlayerData()
    if not playerData.metadata.bigbobjobdone then
        print("^1[DEBUG] Job not yet complete!")
        QBCore.Functions.Notify("You haven't finished your job yet!", "error", 5000)
        return
    end

    -- Job is completed, reward player
    TriggerServerEvent("brx-prison:server:finishbobjob", jobName)

    -- Notify player
    QBCore.Functions.Notify("Job completed! You earned some extra privileges.", "success", 5000)
end)








AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if DoesEntityExist(BigBob) then
            DeleteEntity(BigBob)
        end
    end
end)
