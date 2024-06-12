resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'


author 'FLEX SYSTEMS / by FLX53'
describtion 'Orange Collector Job Skript' 

client_scripts {
    '@es_extended/locale.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'server.lua'
}
