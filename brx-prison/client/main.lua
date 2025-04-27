QBCore = exports['qb-core']:GetCoreObject()

local notifytype = Config.Notify 

inJail = false
jailTime = 0
currentJob = nil
CellsBlip = nil
TimeBlip = nil
CafeBlip = nil
MedicBlip = nil
local insidecanteen = false
local insidefreedom = false
local canteen_ped = 0
local freedom_ped = 0
local freedom
local canteen


-- Functions
-- Create Prison Blips for Map
CreateThread(function()
	PrisonBlip = AddBlipForCoord(Config.Locations['middle'].x, Config.Locations['middle'].y, Config.Locations['middle'].z)
    -- Set blip properties
    SetBlipSprite(PrisonBlip, 526)
    SetBlipDisplay(PrisonBlip, 6)
    SetBlipScale(PrisonBlip, 1.0) -- Default was .65
    SetBlipColour(PrisonBlip, 65)
    SetBlipAsShortRange(PrisonBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Bolingbroke Prison") -- The name displayed on the map
    EndTextCommandSetBlipName(PrisonBlip)
end)


--- @return nil
local function CreateCellsBlip()
	if CellsBlip then
		RemoveBlip(CellsBlip)
	end
	CellsBlip = AddBlipForCoord(Config.Locations['yard'].x, Config.Locations['yard'].y, Config.Locations['yard'].z)

	SetBlipSprite(CellsBlip, 238)
	SetBlipDisplay(CellsBlip, 4)
	SetBlipScale(CellsBlip, 0.8)
	SetBlipAsShortRange(CellsBlip, true)
	SetBlipColour(CellsBlip, 62)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(Lang:t('info.cells_blip'))
	EndTextCommandSetBlipName(CellsBlip)

	if CafeBlip then
		RemoveBlip(CafeBlip)
	end
	CafeBlip = AddBlipForCoord(Config.Locations['cafe'].x, Config.Locations['cafe'].y, Config.Locations['cafe'].z)

	SetBlipSprite(CafeBlip, 176)
	SetBlipDisplay(CafeBlip, 4)
	SetBlipScale(CafeBlip, 0.8)
	SetBlipAsShortRange(CafeBlip, true)
	SetBlipColour(CafeBlip, 4)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(Lang:t('info.cafe_blip'))
	EndTextCommandSetBlipName(CafeBlip)

	if MedicBlip then
		RemoveBlip(MedicBlip)
	end
	MedicBlip = AddBlipForCoord(Config.Locations['medical'].x, Config.Locations['medical'].y, Config.Locations['medical'].z)

	SetBlipSprite(MedicBlip, 153)
	SetBlipDisplay(MedicBlip, 4)
	SetBlipScale(MedicBlip, 0.8)
	SetBlipAsShortRange(MedicBlip, true)
	SetBlipColour(MedicBlip, 2)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(Lang:t('info.medical_blip'))
	EndTextCommandSetBlipName(MedicBlip)


	if TimeBlip then
		RemoveBlip(TimeBlip)
	end
	TimeBlip = AddBlipForCoord(Config.Locations['freedom'].x, Config.Locations['freedom'].y, Config.Locations['freedom'].z)

	SetBlipSprite(TimeBlip, 466)
	SetBlipDisplay(TimeBlip, 4)
	SetBlipScale(TimeBlip, 0.8)
	SetBlipAsShortRange(TimeBlip, true)
	SetBlipColour(TimeBlip, 4)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(Lang:t('info.freedom_blip'))
	EndTextCommandSetBlipName(TimeBlip)


end

-- Add clothes to prisioner

local function ApplyClothes()
	local playerPed = PlayerPedId()
	if DoesEntityExist(playerPed) then
		Citizen.CreateThread(function()
			SetPedArmour(playerPed, 0)
			ClearPedBloodDamage(playerPed)
			ResetPedVisibleDamage(playerPed)
			ClearPedLastWeaponDamage(playerPed)
			ResetPedMovementClipset(playerPed, 0)
			local gender = QBCore.Functions.GetPlayerData().charinfo.gender
			if gender == 0 then
				TriggerEvent('qb-clothing:client:loadOutfit', Config.Uniforms.male)
			else
				TriggerEvent('qb-clothing:client:loadOutfit', Config.Uniforms.female)
			end
		end)
	end
end



function Notify(text, type)
	if notifytype =='ox' then
	  lib.notify({title = text, type = type})
        elseif notifytype == 'qb' then
	  QBCore.Functions.Notify(text, type)
	elseif notifytype == 'okok' then
	  exports['okokNotify']:Alert('', text, 4000, type, false)
	else 
       	print"Notify Not Set In Config"
    	end   
  end

  function GetImage(img)
	if GetResourceState('ox_inventory') == 'started' then
		local Items = exports['ox_inventory']:Items()
		if Items[img]['client'] then 
			if Items[img]['client']['image'] then
				return Items[img]['client']['image']
			else
				return "nui://ox_inventory/web/images/".. img.. '.png'
			end
        end
    end
end

function GetLabel(label)
	if GetResourceState('ox_inventory') == 'started' then
		local Items = exports['ox_inventory']:Items()
		return Items[label]['label']
	else
		return QBCore.Shared.Items[label]['label']
	end
end


function ItemCheck(item)
local success 
if GetResourceState('ox_inventory') == 'started' then
    if exports.ox_inventory:GetItemCount(item) >= 1 then return true else Notify('You Need ' .. GetLabel(item) .. " !", 'error') end
else
    if QBCore.Shared.Items[item] == nil then print("There Is No " .. item .. " In Your QB Items.lua") return end
    if QBCore.Functions.HasItem(item) then success = item return success else Notify('You Need ' .. QBCore.Shared.Items[item].label .. " !", 'error') end
end
end

function ItemCheckMulti(item)
	local need = 0
	local has = 0
	for k,v in pairs (item) do 
		need = need + 1
		if GetResourceState('ox_inventory') == 'started' then
			if exports.ox_inventory:GetItemCount(v) >= 1 then has = has + 1 else Notify('You Need ' .. GetLabel(v) .. " !", 'error') end
		else
			if QBCore.Shared.Items[v] == nil then print("There Is No " .. item .. " In Your QB Items.lua") return end
			if QBCore.Functions.HasItem(v) then has = has + 1  else Notify('You Need ' .. QBCore.Shared.Items[v].label .. " !", 'error') end
		end
	end
	if need == has then 
		return true
	else
		return false
	end
end


  function AddSingleModel(model, data, num)
	if Config.Target == 'qb' then
		exports['qb-target']:AddTargetEntity(model, {options = {
			{icon = data.icon, label = data.label, event = data.event or nil, action = data.action or nil, data = num, canInteract = data.canInteract }
		}, distance = 4.5})
	elseif Config.Target == 'ox' then
		exports.ox_target:addLocalEntity(model, {icon = data.icon, label = data.label, event = data.event or nil, onSelect = data.action or nil, data = num, distance = 2.5, canInteract = data.canInteract })
	end
end


-- Events Going On

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.metadata['injail'] > 0 then
            jailTime = PlayerData.metadata['injail']
            inJail = true
            TriggerEvent('brx-prison:client:Enter', jailTime)
        end
    end)
end)



-- Check if the ped already exists
if DoesEntityExist(canteen_ped) or DoesEntityExist(freedom_ped) then return end

-- Load and create the ped for freedom interaction
local pedModel = `s_m_m_armoured_01`

RequestModel(pedModel)
while not HasModelLoaded(pedModel) do
    Wait(0)
end

freedom_ped = CreatePed(0, pedModel, Config.Locations['freedom'].x, Config.Locations['freedom'].y, Config.Locations['freedom'].z, Config.Locations['freedom'].w, false, true)
FreezeEntityPosition(freedom_ped, true)
SetEntityInvincible(freedom_ped, true)
SetBlockingOfNonTemporaryEvents(freedom_ped, true)
TaskStartScenarioInPlace(freedom_ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)

-- Add a target for the freedom ped if Config.UseTarget is enabled
if Config.UseTarget then
    exports['qb-target']:AddTargetEntity(freedom_ped, {
        options = {
            {
                type = 'client',
                event = 'brx-prison:client:Leave',
                icon = 'fas fa-clipboard',
                label = Lang:t('info.target_freedom_option'),
                canInteract = function()
                    return inJail
                end
            }
        },
        distance = 2.5,
    })
end



RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
	TriggerServerEvent('brx-prison:server:jailinventorysave')
    inJail = false
    currentJob = nil
    RemoveBlip(currentBlip)
end)


RegisterNetEvent('brx-prison:client:Enter', function(time)
	local invokingResource = GetInvokingResource()
	  if invokingResource and invokingResource ~= 'wasabi_police' and invokingResource ~= 'lb-tablet' and invokingResource ~= 'qb-ambulancejob' and invokingResource ~= GetCurrentResourceName() then
		-- Use QBCore.Debug here for a quick and easy way to print to the console to grab your attention with this message
		QBCore.Debug({ ('Player with source %s tried to execute brx-prison:client:Enter manually or from another resource which is not authorized to call this, invokedResource: %s'):format(GetPlayerServerId(PlayerId()), invokingResource) })
		return
	end

	QBCore.Functions.Notify(Lang:t('error.injail', { Time = time }), 'error')

	TriggerEvent('chat:addMessage', {
		color = { 3, 132, 252 },
		multiline = true,
		args = { 'SYSTEM', Lang:t('info.seized_property') }
	})
	inJail = true
	jailTime = time

	DoScreenFadeOut(500)
	while not IsScreenFadedOut() do
		Wait(10)
	end
	local RandomStartPosition = Config.Locations.spawns[math.random(1, #Config.Locations.spawns)]
	SetEntityCoords(PlayerPedId(), RandomStartPosition.coords.x, RandomStartPosition.coords.y, RandomStartPosition.coords.z - 0.9, 0, 0, 0, false)
	SetEntityHeading(PlayerPedId(), RandomStartPosition.coords.w)
	Wait(500)

	--inJail = true
	--jailTime = time
	local tempJobs = {}
	local i = 1
	for k in pairs(Config.Locations.jobs) do
		tempJobs[i] = k
		i = i + 1
	end
	
	math.randomseed(GetGameTimer())
	currentJob = tempJobs[math.random(1, #tempJobs)]
	CreateJobBlip(true)
	ApplyClothes()
	TriggerServerEvent('brx-prison:server:SetJailStatus', jailTime)
	TriggerServerEvent('brx-prison:server:SaveJailItems', jailTime)
	TriggerServerEvent('InteractSound_SV:PlayOnSource', 'jail', 0.5)
	CreateCellsBlip()
	Wait(2000)
	DoScreenFadeIn(1000)
	QBCore.Functions.Notify(Lang:t('error.do_some_work', { currentjob = Config.Jobs[currentJob] }), 'error')
	Wait(1000)
	TriggerServerEvent('brx-prison:server:getprisonpocket')
end)

RegisterNetEvent('brx-prison:client:UpdateJailTime', function(newJailTime)
    jailTime = newJailTime -- ✅ Update the client-side jail time
end)

RegisterNetEvent('brx-prison:client:Leave', function()
    if jailTime > 0 then
        QBCore.Functions.Notify(Lang:t('info.timeleft', { JAILTIME = jailTime }))
    else
        jailTime = 0
        TriggerServerEvent('brx-prison:server:SetJailStatus', 0)
        TriggerServerEvent('brx-prison:server:GiveJailItems')

        TriggerEvent('chat:addMessage', {
            color = { 3, 132, 252 },
            multiline = true,
            args = { 'SYSTEM', Lang:t('info.received_property') }
        })

        inJail = false
        RemoveBlip(currentBlip)
        RemoveBlip(CellsBlip)
        CellsBlip = nil
        RemoveBlip(TimeBlip)
        TimeBlip = nil
        RemoveBlip(CafeBlip)
        CafeBlip = nil
		RemoveBlip(MedicBlip)
		MedicBlip = nil

        QBCore.Functions.Notify(Lang:t('success.free_'))
        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do
            Wait(10)
        end

        TriggerEvent("illenium-appearance:client:reloadSkin")
        --TriggerServerEvent('qb-clothes:loadPlayerSkin')

        SetEntityCoords(PlayerPedId(), Config.Locations['outside'].x, Config.Locations['outside'].y, Config.Locations['outside'].z, false, false, false, false)
        SetEntityHeading(PlayerPedId(), Config.Locations['outside'].w)
        Wait(500)
        DoScreenFadeIn(1000)

        -- Request server to restore the job after release
        TriggerServerEvent('brx-prison:server:RestoreJob')
    end
end)



RegisterNetEvent('brx-prison:client:UnjailPerson', function()
	if jailTime > 0 then
		TriggerServerEvent('brx-prison:server:SetJailStatus', 0)
		TriggerServerEvent('brx-prison:server:GiveJailItems')
		TriggerEvent('chat:addMessage', {
			color = { 3, 132, 252 },
			multiline = true,
			args = { 'SYSTEM', Lang:t('info.received_property') }
		})
		inJail = false
		RemoveBlip(currentBlip)
		RemoveBlip(CellsBlip)
		CellsBlip = nil
		RemoveBlip(TimeBlip)
		TimeBlip = nil
		RemoveBlip(CafeBlip)
		CafeBlip = nil
		RemoveBlip(MedicBlip)
		MedicBlip = nil


		QBCore.Functions.Notify(Lang:t('success.free_'))
		DoScreenFadeOut(500)
		while not IsScreenFadedOut() do
			Wait(10)
		end
		TriggerEvent("illenium-appearance:client:reloadSkin")
		--TriggerServerEvent('qb-clothes:loadPlayerSkin')
		SetEntityCoords(PlayerPedId(), Config.Locations['outside'].x, Config.Locations['outside'].y, Config.Locations['outside'].z, false, false, false, false)
		SetEntityHeading(PlayerPedId(), Config.Locations['outside'].w)
		Wait(500)
		DoScreenFadeIn(1000)
		TriggerServerEvent('brx-prison:server:RestoreJob')
	end
end)

-- Threads


CreateThread(function()
	if not Config.UseTarget then
		freedom = BoxZone:Create(vector3(Config.Locations['freedom'].x, Config.Locations['freedom'].y, Config.Locations['freedom'].z), 2.75, 2.75, {
			name = 'freedom',
			debugPoly = false,
		})
		freedom:onPlayerInOut(function(isPointInside)
			insidefreedom = isPointInside
			if isPointInside then
				CreateThread(function()
					while insidefreedom do
						if IsControlJustReleased(0, 38) then
							exports['qb-core']:KeyPressed()
							exports['qb-core']:HideText()
							TriggerEvent('brx-prison:client:Leave')
							break
						end
						Wait(0)
					end
				end)
				exports['qb-core']:DrawText('[E] Check Time', 'left')
			else
				exports['qb-core']:HideText()
			end
		end)
	end
end)

--jail time stuff

RegisterNetEvent('brx-prison:client:ReapplyJail', function(remainingTime)
    if remainingTime > 0 then
        QBCore.Functions.Notify(Lang:t('info.timeleft', { JAILTIME = remainingTime }), 'info')
        jailTime = remainingTime
        inJail = true
    else
		jailTime = 0
        inJail = false
    end
end)

RegisterNetEvent('brx-prison:client:SaveAndTransition', function(transitionCoords)
    TriggerServerEvent('brx-prison:server:SetJailStatus', jailTime) -- Save current jail time
    inJail = false -- Temporarily mark the player as out of jail

    -- Move to transition location (e.g., medical)
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(10)
    end
    SetEntityCoords(PlayerPedId(), transitionCoords.x, transitionCoords.y, transitionCoords.z, false, false, false, true)
    DoScreenFadeIn(1000)
end)

RegisterNetEvent('brx-prison:client:ReenterFromTransition', function()
    TriggerEvent('brx-prison:client:Enter', jailTime) -- Reapply jail time
end)






-- Get Food/Drink
exports['qb-target']:AddBoxZone("food", vector3(Config.Food.x, Config.Food.y, Config.Food.z), 0.5, 0.6, {
    name = "food",
    debugPoly = false,
    minZ = Config.Food.z - 1,
    maxZ = Config.Food.z + 1
}, {
    options = {
        {
            type = "client",
            event = "brx-prison:custom:food",
            icon = "fas fa-search",
            label = "Wait for Food?"
        }
    },
    distance = 1.5 -- Interaction distance
})

exports['qb-target']:AddBoxZone("drink", vector3(Config.Drink.x, Config.Drink.y, Config.Drink.z), 0.5, 0.6, {
    name = "drink",
    debugPoly = false,
    minZ = Config.Drink.z - 1,
    maxZ = Config.Drink.z + 1
}, {
    options = {
        {
            type = "client",
            event = "brx-prison:custom:drink",
            icon = "fas fa-search",
            label = "Wait for a Drink?"
        }
    },
    distance = 1.5 -- Interaction distance
})


local function startSearchingAnimation()
    local ped = PlayerPedId() -- Get the player's ped
    if not IsPedInAnyVehicle(ped, false) then -- Ensure player is not in a vehicle
        -- Load the animation dictionary
        RequestAnimDict("random@shop_tattoo")
        while not HasAnimDictLoaded("random@shop_tattoo") do
            Wait(0)
        end

        -- Play the animation
        TaskPlayAnim(ped, "random@shop_tattoo", "_idle_a", 8.0, -8.0, -1, 1, 0, false, false, false)
    end
end

-- Function to stop the animation
local function stopSearchingAnimation()
    ClearPedTasks(PlayerPedId()) -- Stop all tasks/animations for the player
end


RegisterNetEvent("brx-prison:custom:food", function()
    startSearchingAnimation()
    QBCore.Functions.Progressbar("food", "Waitin for food...", 6000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- On success
        stopSearchingAnimation()
        TriggerServerEvent("brx-prison:custom:food", "food") -- Pass zone identifier
    end, function() -- On cancel
        stopSearchingAnimation()
        QBCore.Functions.Notify("Canceled.", "error")
    end)
end)

RegisterNetEvent("brx-prison:custom:drink", function()
    startSearchingAnimation()
    QBCore.Functions.Progressbar("drink", "Waitin for a drink...", 4000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- On success
        stopSearchingAnimation()
        TriggerServerEvent("brx-prison:custom:drink", "drink") -- Pass zone identifier
    end, function() -- On cancel
        stopSearchingAnimation()
        QBCore.Functions.Notify("Canceled.", "error")
    end)
end)


--Hidden Stash Usable Item
RegisterNetEvent('brx-prison:client:hiddenstashitem', function()
    TriggerServerEvent('brx-prison:hiddenstashitem')
end)


local activeStashes = {}

RegisterNetEvent("brx-prison:client:SyncStashLocations", function(stashes)
    activeStashes = stashes 

    -- Remove old zones before adding new ones
    for _, stash in ipairs(activeStashes) do
        exports["qb-target"]:RemoveZone("stash_" .. stash.coords.x)
    end

    for _, stash in ipairs(activeStashes) do
        exports["qb-target"]:AddBoxZone("stash_" .. stash.coords.x, vector3(stash.coords.x, stash.coords.y, stash.coords.z), 1.5, 1.5, {
            name = "stash_" .. stash.coords.x,
            heading = stash.coords.w,
            debugPoly = false,
            minZ = stash.coords.z - 1.0,
            maxZ = stash.coords.z + 1.5, 
        }, {
            options = {
                {
                    type = "client",
                    event = "brx-prison:client:TakeStash",
                    icon = "fas fa-box",
                    label = "Search Hidden Stash",
                }
            },
            distance = 2.0
        })

        print("^2[DEBUG] Stash registered at:", stash.coords.x, stash.coords.y, stash.coords.z)
    end
end)


RegisterNetEvent("brx-prison:client:TakeStash")
AddEventHandler("brx-prison:client:TakeStash", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, stash in ipairs(activeStashes) do
        local stashCoords = vector3(stash.coords.x, stash.coords.y, stash.coords.z)

        if #(playerCoords - stashCoords) < 1.5 then

            QBCore.Functions.Notify("Searching stash...", "primary")

            RequestAnimDict("mini@repair")
            while not HasAnimDictLoaded("mini@repair") do
                Wait(10)
            end
            TaskPlayAnim(playerPed, "mini@repair", "fixing_a_ped", 8.0, -8.0, -1, 1, 0, false, false, false)

            QBCore.Functions.Progressbar("stash_search", "Searching stash...", 10000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = "mini@repair",
                anim = "fixing_a_ped",
                flags = 49,
            }, {}, {}, function()
                ClearPedTasks(playerPed) 
                TriggerServerEvent("brx-prison:server:TakeStashItem", stash.coords)
            end, function()
                ClearPedTasks(playerPed)
                QBCore.Functions.Notify("You stopped searching...", "error")
            end)

            return
        end
    end

    QBCore.Functions.Notify("This was already cleaned out...", "error")
end)



-- The Stash
RegisterNetEvent("brx-prison:client:OpenStash", function()
        exports.ox_inventory:openInventory('stash', 'thestash')
end)


for k, v in pairs(Config.TheStash) do
    exports['qb-target']:AddBoxZone(v.Name, v.Location, v.Width, v.Height, {
        name = v.Name,
        heading = v.Heading,
        debugPoly = Config.DebugPoly,
        minZ = v.MinZ,
        maxZ = v.MaxZ,
    }, {
        options = {
        {
            type = "client",
            event = v.Event,
            icon = v.Icon,
            label = v.Label,
        }
        },
        distance = 1.0,
    })
end

