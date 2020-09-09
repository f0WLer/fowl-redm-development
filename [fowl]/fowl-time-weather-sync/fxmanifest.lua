fx_version 'adamant'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

client_script { 
	'config.lua',
	'client/cl_main.lua', 
}

server_script {
	'config.lua',
	'server/common.lua',
	'server/objects/time.lua',
	'server/objects/weather.lua',
	'server/sv_main.lua',
}