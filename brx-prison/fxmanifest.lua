fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Karver'
description 'Fully Immersive Prison'
version '1.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'config.lua',
    '@ox_lib/init.lua',
}
client_scripts{
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/main.lua',
    'client/jobs.lua',
    'client/peds.lua',
}

server_scripts{
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/most.lua',
    'server/server.lua',
}

dependencies { 
    'qb-target',
    'oxmysql',
}
