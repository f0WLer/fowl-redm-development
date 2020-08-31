function getCityScreenCoords()
	local loc_bla = {
		name = "blackwater",
		x = -930.0,
		y = -1200.0,
		id = 1,
	}
	local loc_arm = {
		name = "armadillo",
		x = -3673.0,
		y = -2617.0,
		id = 2,
	}
	local loc_val = {
		name = "valentine",
		x = -300.0,
		y = 785.0,
		id = 3,
	}
	local loc_ann = {
		name = "annesburg",
		x = 2934.0,
		y = 1341.0,
		id = 4,
	}
	local loc_san = {
		name = "saint denis",
		x = 2668.0,
		y = -1222.0,
		id = 5,
	}
	local cities = {loc_bla,loc_arm,loc_val,loc_ann,loc_san}
	for city in pairs(cities) do
		_,cities[city].marker_x,cities[city].marker_y = GetScreenCoordFromWorldCoord(cities[city].x, cities[city].y)
		SendNUIMessage({cityData = cities[city]})
	end
end

cam_bla = {
	x = -725.0,
	y = -1350.0,
	z = 75.0,
	pointx = -900.0,
	pointy = -1300.0,
	pointz = 0.0,
}

cam_arm = {
	x = -3717.80,
	y = -2618.30,
	z = -10.0,
	pointx = -3656.57,
	pointy = -2580.72,
	pointz = -12.0,
}

cam_val = {
	x = -265.0,
	y = 795.0,
	z = 120.0,
	pointx = -340.0,
	pointy = 782.5,
	pointz = 120.0,
}

cam_ann = {
	x = 3009.0,
	y = 1305.0,
	z = 90.0,
	pointx = 2934.0,
	pointy = 1341.0,
	pointz = 50.0,
}

cam_san = {
	x = 2944.0,
	y = -1411.0,
	z = 90.0,
	pointx = 2495.0,
	pointy = -1148.0,
	pointz = 50.0,
}

spawnPoints = {
	[1] = {
		x = -725.22,
		y = -1238.61,
		z = 44.73,
	},
	[2] = {
		x = -3743.56,
		y = -2607.17,
		z = -13.25,
	},
	[3] = {
		x = -164.77,
		y = 634.85,
		z = 114.03,
	},
	[4] = {
		x = 3015.75,
		y = 1345.15,
		z = 42.65,
	},
	[5] = {
		x = 2674.25,
		y = -1546.31,
		z = 46.00,
	},
}