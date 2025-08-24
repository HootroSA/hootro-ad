Config = {}

-- Framework Detection (supports QBCore and QBox)
Config.Framework = 'auto' -- 'qb-core', 'qbox', or 'auto' for automatic detection

-- Business Ad Settings
Config.BusinessAds = {
    cost = 500, -- Cost to send an ad
    cooldown = 300, -- Cooldown between ads (in seconds)
    maxMessageLength = 150,
    defaultDuration = 8000, -- Duration in milliseconds
}

-- Business Jobs with Grade Requirements
Config.BusinessJobs = {
    ['police'] = {
        minGrade = 2, -- Minimum grade to send ads
        label = 'Police Department',
        image = '' -- Optional custom image
    },
}

Config.Gangs = {
    ['ballas'] = {
        minGrade = 3, -- Minimum gang grade to send ads
        label = 'Ballas Gang',
        image = 'https://i.imgur.com/placeholder.png'
    },
    ['vagos'] = {
        minGrade = 2,
        label = 'Vagos Gang',
        image = 'https://i.imgur.com/placeholder.png'
    },
}

-- Status Types for Ads with Colors
Config.StatusTypes = {
    {value = 'open', label = 'Open Now', color = '#10B981'}, -- Green
    {value = 'closed', label = 'Closed', color = '#EF4444'}, -- Red
    {value = 'sale', label = 'Sale', color = '#F59E0B'}, -- Orange
    {value = 'new_stock', label = 'New Stock', color = '#3B82F6'}, -- Blue
    {value = 'grand_opening', label = 'Grand Opening', color = '#8B5CF6'}, -- Purple
    {value = '24_7', label = '24/7', color = '#06B6D4'} -- Cyan
}

-- UI Configuration
Config.UI = {
    -- Position of notifications on screen
    position = 'top-right', -- 'top-left', 'top-center', 'top-right', 'center-left', 'center-right', 'bottom-left', 'bottom-center', 'bottom-right'
    backgroundColor = 'rgba(15, 23, 42, 0.95)', 
    borderColor = 'rgba(51, 65, 85, 1)', 
    textColor = '#FFFFFF', 
    secondaryTextColor = '#CBD5E1', 
    progressBarGradient = {
        from = '#8B5CF6', 
        to = '#EC4899' 
    },
    
    -- Animation settings
    animationDuration = 500, -- milliseconds
    displayDuration = 8000, -- Default display time in milliseconds
    
    -- Shadow and effects
    boxShadow = '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
    hoverShadow = '0 25px 50px -12px rgba(139, 92, 246, 0.2)',
    borderRadius = '8px',
    
    -- Image settings
    imageSize = '64px',
    imageBorderRadius = '8px',
    imageBorder = '2px solid rgba(51, 65, 85, 1)',
    imageRing = '2px solid rgba(139, 92, 246, 0.2)'
}

-- Commands
Config.Commands = {
    businessAd = 'businessad', -- Command to open menu
    adminBroadcast = 'broadcastad', -- Simple admin command
    adminMenu = 'businessadmin' -- Admin menu command
}

-- Admin Settings
Config.Admin = {
    acePermission = 'businessads.admin', -- Required ACE permission for admin features
    allowAllBusinesses = true -- Allow admins to send ads for any business/gang
}
