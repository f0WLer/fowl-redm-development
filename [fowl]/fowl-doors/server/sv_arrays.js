function sortKeys(keys){
	if (keys != null) {
		var queryString = keys;
		queryString = queryString.replace("[","");
		queryString = queryString.replace("]","");
		var keys = queryString.split(",").map(x=>+x)
	}
	return keys
}

global.exports("sortKeys",function(keys){
	return sortKeys(keys);
})