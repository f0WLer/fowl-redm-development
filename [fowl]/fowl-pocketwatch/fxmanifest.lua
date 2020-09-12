fx_version 'adamant'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

client_script { 
		'@fowl-time-weather-sync/config.lua',
		'config.lua',
		'client/cl_main.lua', 
}

server_script {
		'server/sv_main.lua',
}

ui_page 'html/ui.html'

files {
		'html/*',
		'html/ui/*',
		'html/ui/textures/*',
}

dependencies {
	'fowl-user-data',
	'fowl-login',
	'fowl-time-weather-sync',
}