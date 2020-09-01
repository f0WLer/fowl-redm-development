function getSurroundingDoors(x,y,z,radius) {
	var surroundingDoors = []

	Object.keys(doors).forEach(function(key){
		var door = doors[key]

		if (door.x >= (x-radius) && 
			door.x <= (x+radius) && 
			door.y >= (y-radius) &&
			door.y <= (y+radius)) {
			surroundingDoors.push(door);
		}
	});
	return surroundingDoors
};


global.exports('getSurroundingDoors', (x, y, z, radius) => {
	return getSurroundingDoors(x,y,z,radius);
});