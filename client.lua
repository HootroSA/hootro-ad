-- FiveM Client-side Lua script
local isAdVisible = false

-- Function to show business ad
function ShowBusinessAd(adData)
    if not isAdVisible then
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = "showBusinessAd",
            adData = adData
        })
        isAdVisible = true
    end
end

-- Function to close business ad
function CloseBusinessAd()
    if isAdVisible then
        SendNUIMessage({
            action = "closeBusinessAd"
        })
        isAdVisible = false
    end
end

-- Register NUI callback for when ad is closed
RegisterNUICallback('adClosed', function(data, cb)
    isAdVisible = false
    cb('ok')
end)

-- Register NUI callback for getting UI config
RegisterNUICallback('getUIConfig', function(data, cb)
    cb(Config.UI)
end)

-- Register NUI callback for ad shown
RegisterNUICallback('adShown', function(data, cb)
    -- Can be used for logging/analytics
    cb('ok')
end)

-- Export functions for other resources to use
exports('ShowBusinessAd', ShowBusinessAd)
exports('CloseBusinessAd', CloseBusinessAd)

-- Network event to receive ads from server
RegisterNetEvent('businessAds:showAd')
AddEventHandler('businessAds:showAd', function(adData)
    ShowBusinessAd(adData)
end)

-- Network event to open ox_lib menu
RegisterNetEvent('businessAds:openMenu')
AddEventHandler('businessAds:openMenu', function(businessConfig, isGang)
    local options = {}
    
    -- Build status options
    for _, status in pairs(Config.StatusTypes) do
        table.insert(options, {
            value = status.label,
            label = status.label
        })
    end
    
    local entityType = isGang and 'Gang' or 'Business'
    
    -- Create the input dialog
    local input = lib.inputDialog(entityType .. ' Advertisement - ' .. businessConfig.label, {
        {
            type = 'textarea',
            label = 'Advertisement Message',
            description = 'Enter your ' .. entityType:lower() .. ' advertisement message (max ' .. Config.BusinessAds.maxMessageLength .. ' characters)',
            required = true,
            max = Config.BusinessAds.maxMessageLength
        },
        {
            type = 'select',
            label = entityType .. ' Status',
            description = 'Select the current status of your ' .. entityType:lower(),
            options = options,
            required = true
        }
    })
    
    if input then
        local message = input[1]
        local status = input[2]
        
        if message and status then
            -- Show confirmation with cost
            local alert = lib.alertDialog({
                header = 'Confirm Advertisement',
                content = entityType .. ': ' .. businessConfig.label .. '\nMessage: ' .. message .. '\nStatus: ' .. status .. '\n\nCost: $' .. Config.BusinessAds.cost,
                centered = true,
                cancel = true
            })
            
            if alert == 'confirm' then
                TriggerServerEvent('businessAds:sendAd', message, status)
            end
        end
    end
end)

-- Network event to open admin menu
RegisterNetEvent('businessAds:openAdminMenu')
AddEventHandler('businessAds:openAdminMenu', function()
    -- Build business and gang options
    local businessOptions = {}
    
    -- Add businesses
    for key, config in pairs(Config.BusinessJobs) do
        table.insert(businessOptions, {
            value = key .. '|business',
            label = '🏢 ' .. config.label .. ' (Business)'
        })
    end
    
    -- Add gangs
    for key, config in pairs(Config.Gangs) do
        table.insert(businessOptions, {
            value = key .. '|gang',
            label = '🔫 ' .. config.label .. ' (Gang)'
        })
    end
    
    -- Status options
    local statusOptions = {}
    for _, status in pairs(Config.StatusTypes) do
        table.insert(statusOptions, {
            value = status.label,
            label = status.label
        })
    end
    
    -- Create admin input dialog
    local input = lib.inputDialog('Admin Business Advertisement', {
        {
            type = 'select',
            label = 'Select Business/Gang',
            description = 'Choose which business or gang to send advertisement for',
            options = businessOptions,
            required = true
        },
        {
            type = 'textarea',
            label = 'Advertisement Message',
            description = 'Enter the advertisement message (max ' .. Config.BusinessAds.maxMessageLength .. ' characters)',
            required = true,
            max = Config.BusinessAds.maxMessageLength
        },
        {
            type = 'select',
            label = 'Status',
            description = 'Select the status for this advertisement',
            options = statusOptions,
            required = true
        }
    })
    
    if input then
        local businessSelection = input[1]
        local message = input[2]
        local status = input[3]
        
        if businessSelection and message and status then
            local parts = {}
            for part in string.gmatch(businessSelection, '([^|]+)') do
                table.insert(parts, part)
            end
            
            local businessKey = parts[1]
            local entityType = parts[2]
            local isGang = entityType == 'gang'
            
            local businessConfig = isGang and Config.Gangs[businessKey] or Config.BusinessJobs[businessKey]
            
            -- Show confirmation
            local alert = lib.alertDialog({
                header = 'Confirm Admin Advertisement',
                content = (isGang and 'Gang: ' or 'Business: ') .. businessConfig.label .. '\nMessage: ' .. message .. '\nStatus: ' .. status .. '\n\n⚠️ This will be sent to ALL players',
                centered = true,
                cancel = true
            })
            
            if alert == 'confirm' then
                TriggerServerEvent('businessAds:sendAdminAd', businessKey, message, status, isGang)
            end
        end
    end
end)

-- Example usage (remove in production)
RegisterCommand('testbusinessad', function()
    local exampleAd = {
        id = 1,
        name = "Los Santos Customs",
        message = "Professional vehicle modifications and repairs available now!",
        image = "https://example.com/business-image.jpg",
        status = "Open 24/7",
        statusType = "open",
        duration = 8000
    }
    ShowBusinessAd(exampleAd)
end, false)

