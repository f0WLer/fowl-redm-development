fx_version 'adamant'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

client_script { 
		'client/cl_main.lua', 
}

server_script {
		'server/sv_main.lua',
		'@fowl-mysql/lib/MySQL2.lua',
		'@fowl-user-data/lib/Users.lua',
}

ui_page 'html/ui.html'

files {
		'html/*',
		'html/ui/*',
}

dependency 'fowl-user-data'