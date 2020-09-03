fx_version 'adamant'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

client_script { 
		'config.lua',
		'client/sorting.js',
		'data/doors.js',
		'client/doors.lua',
		'client/keys.lua',
}

server_script {
		'data/doors.js',
		'server/server.js',
}

ui_page 'html/ui.html'

files {
		'html/*',
		'html/ui/*',
}