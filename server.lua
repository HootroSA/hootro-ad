-- FiveM Server-side Lua script for Business Advertisement System
local QBCore, QBox = nil, nil
local Framework = nil
local playerCooldowns = {}

-- Framework Detection
CreateThread(function()
    if Config.Framework == 'qb-core' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'qb-core'
    elseif Config.Framework == 'qbox' then
        QBox = exports.qbx_core
        Framework = 'qbox'
    else
        -- Auto detection
        if GetResourceState('qb-core') == 'started' then
            QBCore = exports['qb-core']:GetCoreObject()
            Framework = 'qb-core'
        elseif GetResourceState('qbx_core') == 'started' then
            QBox = exports.qbx_core
            Framework = 'qbox'
        end
    end
    print('^2[Business Ads]^7 Framework: ' .. (Framework or 'None'))
end)

-- Get player data
function GetPlayer(source)
    if Framework == 'qb-core' and QBCore then
        return QBCore.Functions.GetPlayer(source)
    elseif Framework == 'qbox' and QBox then
        return QBox:GetPlayer(source)
    end
    return nil
end

-- Get player job info
function GetPlayerJob(source)
    local player = GetPlayer(source)
    if not player then return nil, nil, nil, nil end
    
    if Framework == 'qb-core' then
        local job = player.PlayerData.job
        local gang = player.PlayerData.gang
        return job.name, job.grade.level, gang.name, gang.grade.level
    elseif Framework == 'qbox' then
        local job = player.PlayerData.job
        local gang = player.PlayerData.gang
        return job.name, job.grade, gang.name, gang.grade
    end
    return nil, nil, nil, nil
end

-- Check if player has money
function HasMoney(source, amount)
    if amount <= 0 then return true end
    local player = GetPlayer(source)
    if not player then return false end
    
    if Framework == 'qb-core' then
        return player.PlayerData.money.cash >= amount or player.PlayerData.money.bank >= amount
    elseif Framework == 'qbox' then
        return player.PlayerData.money.cash >= amount or player.PlayerData.money.bank >= amount
    end
    return false
end

-- Remove money from player
function RemoveMoney(source, amount)
    if amount <= 0 then return true end
    local player = GetPlayer(source)
    if not player then return false end
    
    if Framework == 'qb-core' then
        if player.PlayerData.money.cash >= amount then
            return player.Functions.RemoveMoney('cash', amount)
        else
            return player.Functions.RemoveMoney('bank', amount)
        end
    elseif Framework == 'qbox' then
        if player.PlayerData.money.cash >= amount then
            return player.Functions.RemoveMoney('cash', amount)
        else
            return player.Functions.RemoveMoney('bank', amount)
        end
    end
    return false
end

-- Check if player can send business ad
function CanSendBusinessAd(source)
    local job, jobGrade, gang, gangGrade = GetPlayerJob(source)
    local businessConfig = nil
    local isGang = false
    
    -- Check job first
    if job and Config.BusinessJobs[job] then
        if jobGrade and jobGrade >= Config.BusinessJobs[job].minGrade then
            businessConfig = Config.BusinessJobs[job]
        end
    end
    
    -- Check gang if no valid job found
    if not businessConfig and gang and Config.Gangs[gang] then
        if gangGrade and gangGrade >= Config.Gangs[gang].minGrade then
            businessConfig = Config.Gangs[gang]
            isGang = true
        end
    end
    
    if not businessConfig then
        return false, "You don't have permission to send advertisements"
    end
    
    -- Check cooldown
    local currentTime = os.time()
    if playerCooldowns[source] and (currentTime - playerCooldowns[source]) < Config.BusinessAds.cooldown then
        local remaining = Config.BusinessAds.cooldown - (currentTime - playerCooldowns[source])
        return false, "Please wait " .. remaining .. " seconds before sending another ad"
    end
    
    if not HasMoney(source, Config.BusinessAds.cost) then
        return false, "Insufficient funds. Cost: $" .. Config.BusinessAds.cost
    end
    
    return true, businessConfig, isGang
end

-- Function to broadcast ad to all players
function BroadcastBusinessAd(adData, source)
    TriggerClientEvent('businessAds:showAd', -1, adData)
    print(('Business ad broadcasted: %s - %s'):format(adData.name, adData.message))
    
    if source then
        playerCooldowns[source] = os.time()
    end
end

-- Function to broadcast ad to specific player
function ShowBusinessAdToPlayer(playerId, adData)
    TriggerClientEvent('businessAds:showAd', playerId, adData)
end

-- Export functions
exports('BroadcastBusinessAd', BroadcastBusinessAd)
exports('ShowBusinessAdToPlayer', ShowBusinessAdToPlayer)

-- Handle business ad request
RegisterNetEvent('businessAds:sendAd', function(message, status)
    local source = source
    local canSend, businessConfig, isGang = CanSendBusinessAd(source)
    
    if not canSend then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = businessConfig
        })
        return
    end
    
    if string.len(message) > Config.BusinessAds.maxMessageLength then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Message too long. Maximum ' .. Config.BusinessAds.maxMessageLength .. ' characters'
        })
        return
    end
    
    if not RemoveMoney(source, Config.BusinessAds.cost) then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Insufficient funds. Cost: $' .. Config.BusinessAds.cost
        })
        return
    end
    
    local adData = {
        id = math.random(1000, 9999),
        name = businessConfig.label,
        message = message,
        image = businessConfig.image or "https://via.placeholder.com/80x80",
        status = status,
        statusType = status:lower():gsub(" ", "_"),
        duration = Config.BusinessAds.defaultDuration
    }
    
    BroadcastBusinessAd(adData, source)
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = 'Advertisement sent successfully!'
    })
end)

-- Handle admin ad request
RegisterNetEvent('businessAds:sendAdminAd', function(businessKey, message, status, isGang)
    local source = source
    
    if not IsPlayerAceAllowed(source, Config.Admin.acePermission) then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'No permission'
        })
        return
    end
    
    local businessConfig
    if isGang then
        businessConfig = Config.Gangs[businessKey]
    else
        businessConfig = Config.BusinessJobs[businessKey]
    end
    
    if not businessConfig then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Invalid business/gang selected'
        })
        return
    end
    
    if string.len(message) > Config.BusinessAds.maxMessageLength then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Message too long. Maximum ' .. Config.BusinessAds.maxMessageLength .. ' characters'
        })
        return
    end
    
    local adData = {
        id = math.random(1000, 9999),
        name = businessConfig.label,
        message = message,
        image = businessConfig.image or "https://via.placeholder.com/80x80",
        status = status,
        statusType = status:lower():gsub(" ", "_"),
        duration = Config.BusinessAds.defaultDuration
    }
    
    BroadcastBusinessAd(adData, source)
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = 'Advertisement broadcasted successfully!'
    })
end)

-- Command to open business ad menu
RegisterCommand(Config.Commands.businessAd, function(source)
    local canSend, businessConfig, isGang = CanSendBusinessAd(source)
    
    if not canSend then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = businessConfig
        })
        return
    end
    
    TriggerClientEvent('businessAds:openMenu', source, businessConfig, isGang)
end)

-- Command to open admin menu
RegisterCommand(Config.Commands.adminMenu, function(source)
    if not IsPlayerAceAllowed(source, Config.Admin.acePermission) then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'No permission'
        })
        return
    end
    
    TriggerClientEvent('businessAds:openAdminMenu', source)
end)

-- Admin command
RegisterCommand(Config.Commands.adminBroadcast, function(source, args)
    if not IsPlayerAceAllowed(source, 'admin') then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'No permission'
        })
        return
    end
    
    if #args < 3 then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Usage: /' .. Config.Commands.adminBroadcast .. ' [business] [status] [message]'
        })
        return
    end
    
    local business = args[1]
    local status = args[2]
    local message = table.concat(args, " ", 3)
    
    local adData = {
        id = math.random(1000, 9999),
        name = business,
        message = message,
        image = "https://via.placeholder.com/80x80",
        status = status,
        statusType = status:lower():gsub(" ", "_"),
        duration = Config.BusinessAds.defaultDuration
    }
    
    BroadcastBusinessAd(adData)
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = 'Advertisement broadcasted!'
    })
end)
