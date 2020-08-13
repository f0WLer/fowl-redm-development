fx_version 'adamant'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

client_script { 
		'client/client.lua',
		'lib/Users.lua',
}

server_script {
		'server/server.lua',
		'@fowl-mysql/lib/MySQL2.lua',
}

files {
}