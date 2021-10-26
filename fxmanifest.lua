fx_version 'cerulean'
games { 'gta5' }

client_scripts {
    'shared/config.lua',
    'client/main.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'shared/config.lua',
    'server/main.lua'
}

ui_page('ui/index.html')

files {
    'ui/index.html',
    'ui/script.js',
    'ui/style.css',
    'ui/assets/fonts/signpainter.woff2',
    '@cui_character/ui/assets/fonts/chaletlondon1960.woff2',
    'ui/assets/icons/accept.svg',
    'ui/assets/icons/cancel.svg',
    'ui/assets/icons/clear.svg',
    'ui/assets/icons/save.svg',
}

dependencies {
    'cui_character'
}