const {performance} = require('perf_hooks');

// SETTINGS //
/** Time in ms for slow query warning **/ const slowQuery = 150.0;
/** Print query time after every query (bool) **/ var outputQTime = true;
//*********//


function getConfigFromConnectionString() {
  const connectionString = GetConvar('mysql2_connection_string', 'mysql://root@localhost/fivem');
  let cfg = {};

  if (/(?:database|initial\scatalog)=(?:(.*?);|(.*))/gi.test(connectionString)) {
    // replace the old version with the new one
    const connectionStr = connectionString.replace(/(?:host|server|data\s?source|addr(?:ess)?)=/gi, 'host=').replace(/(?:port)=/gi, 'port=').replace(/(?:user\s?(?:id|name)?|uid)=/gi, 'user=').replace(/(?:password|pwd)=/gi, 'password=').replace(/(?:database|initial\scatalog)=/gi, 'database=');
    connectionStr.split(';').forEach(el => {
      const equal = el.indexOf('=');
      const key = equal > -1 ? el.substr(0, equal) : el;
      const value = equal > -1 ? el.substr(equal + 1) : '';
      if (key) { cfg[key] = Number.isNaN(Number(value)) ? value : Number(value); }
    });
  } else if (/mysql:\/\//gi.test(connectionString)) {
    cfg = Object(ConnectionConfig["parseUrl"])(connectionString);
  }

  return cfg;
}

const defaultCfg = {
    host: '127.0.0.1',
    user: 'root',
    password: '',
    database: 'fivem',
    supportBigNumbers: true,
    multipleStatements: true
};

const server_config = { ...defaultCfg,
  ...getConfigFromConnectionString()
};

const mysql = require('mysql2');
const connection = mysql.createPool(server_config)

if (connection) { console.log("^2[mysql2] [SUCCESS] ^0Database server connection established.") }

function convertLegacyQuery(query, parameters) {
	let sql = query;
	const params = [];
	sql = sql.replace(/@(\w+)/g, (txt, match) => {
	    let returnValue = txt;

	    if (Object.prototype.hasOwnProperty.call(parameters, txt)) {
	        params.push(parameters[txt]);
	        returnValue = '?';
	    } else if (Object.prototype.hasOwnProperty.call(parameters, match)) {
	        params.push(parameters[match]);
	        returnValue = '?';
	    }

	    return returnValue;
	});
	return {
	    sql,
	    params
	};
}

function prepareLegacyQuery(query, parameters) {
    let sql = query;
    let params = parameters;

    if (params !== null && typeof params === 'object' && !Array.isArray(params)) {
    	({
        	sql,
        	params
    	} = convertLegacyQuery(sql, params));
    }

    return [sql, params];
}

function sanitizeInput(query, parameters, callback) {
  	let sql = query;
    let params = parameters;
    let cb = callback;

    if (typeof parameters === 'function') {
        cb = parameters;
    }

    [sql, params] = prepareLegacyQuery(query, params);

    if (!Array.isArray(params)) {
        params = [];
    }

    return [sql, params, cb];
}

var MySQL2 = {}

mysql2_execute = (query, params, callback, invokingResource) => {
	[query, params, callback] = sanitizeInput(query, params, callback);
	let cb = callback;
	var promise = new Promise((resolve, reject) => {
		const queryStart = performance.now();
		connection.query(
			query,
			params,
			(err, results) => {
				const queryEnd = performance.now();
				const queryTime = Math.floor(queryEnd-queryStart);
				if (err) {
					print("^1[MySQL2]^0 "+err);
				}
				else if (results) {
					resolve([results, cb]);
					if (queryTime >= slowQuery) {
						print("^3[MySQL2] Warning: Query time of ^0"+queryTime+"ms^3: '"+query+"'.^0");
					}
				};
        if (outputQTime === true) {
          print("["+queryTime+"ms] "+query)
        }
			}
		);
	});
	return promise;
}


function safeInvoke(callback, args) {
  if (typeof callback === 'function') {
    setImmediate(() => {
      callback(args);
    });
  }
}

var utility_safeInvoke = (safeInvoke);

global.exports('mysql2_execute', (query, params, callback, resource) => {
  const invokingResource = resource || GetInvokingResource();
  mysql2_execute(query, params, callback, invokingResource).then(([result, cb]) => {
    utility_safeInvoke(cb, result ? result.affectedRows : 0);
    return true;
  }).catch(() => false);
});

global.exports('mysql2_fetch_all', (query, params, callback, resource) => {
	const invokingResource = resource || GetInvokingResource();
	mysql2_execute(query, params, callback, invokingResource).then(([result, cb]) => {
		utility_safeInvoke(callback, result);
		return true;
	}).catch(() => false);
});

global.exports('mysql2_fetch_scalar', (query, params, callback, resource) => {
	const invokingResource = resource || GetInvokingResource();
	mysql2_execute(query, params, callback, invokingResource).then(([result, cb]) => {
		utility_safeInvoke(cb, result && result[0] ? Object.values(result[0])[0] : null);
		return true;
	}).catch(() => false);
});