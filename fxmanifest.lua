fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'YourName'
description 'Business Advertisement System for FiveM with QBCore/QBox and ox_lib support'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

ui_page 'index.html'

files {
    'index.html',
    'style.css',
    'script.js'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'ox_lib'
}
