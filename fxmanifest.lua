fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'HootroSA'
description 'Business Advertisement System'
version '1.0.0'

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
