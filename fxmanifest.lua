fx_version 'cerulean'
game 'gta5'
lua54 'yes'

client_scripts {
    'client/*.lua',
    'shared/*.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/*.lua',
    'shared/*.lua',
}


shared_script '@ox_lib/init.lua' 
shared_script '@es_extended/imports.lua'