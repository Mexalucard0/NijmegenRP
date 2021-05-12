fx_version 'adamant'

game 'gta5'

description 'NRP Drugs'

version '0.0.1'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	-- 'locales/en.lua',
	-- 'locales/es.lua',
	-- 'locales/fr.lua',
	-- 'locales/sv.lua',
	'config.lua',
	'server.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	-- 'locales/en.lua',
	-- 'locales/es.lua',
	-- 'locales/fr.lua',
	-- 'locales/sv.lua',
	'config.lua',
	'client.lua',
}

dependencies {
	'es_extended'
}