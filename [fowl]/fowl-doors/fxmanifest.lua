fx_version 'adamant'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

client_script { 
	'config.lua',
	'client/sorting.js',
	'data/doors.js',
	'client/cl_keys.lua',
	'client/cl_doors.lua',
}

server_script {
	'@fowl-mysql/lib/MySQL2.lua',
	'data/doors.js',
	'server/sv_arrays.js',
	'server/sv_main.lua',
}

ui_page 'html/ui.html'

files {
	'html/*',
	'html/ui/*',
}