fx_version 'adamant'
game 'gta5'
author 'Roonyx'
discord 'Pour du support -> https://discord.gg/HrW4ucmkk6'
description 'Avertir des joueurs online et offline ainsi que les gérer.'


-----------------------------------------> RageUI <-----------------------------------------

client_scripts {
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",
    "src/components/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua", 
}

-----------------------------------------> Création item <-----------------------------------------

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/*.lua'
}