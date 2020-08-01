function GetButtons(t)
	local numt = {}
	local sortedtable = {}
	for i in pairs(t) do
		numt[tonumber(i)]=t[i]
	end
	for k in ipairs(numt) do
		sortedtable[numt[k][1]]=numt[k][2]
	end
	return sortedtable
end

local hud = false
local PedInfo = false
local menuButtons = GetButtons(json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/main.json")))

Citizen.CreateThread( function()
	Wait(500)
	DisableHTML()
	HideAllContainers()

	SetMinimapHideFow(true)

	while true do
		local crd = GetEntityCoords(PlayerPedId())
		SendNUIMessage({DrawHTML = true, container = "#ped-info", show = true, dst = 1, text = crd.x.." "..crd.y.." "..crd.z.." "..GetEntityHeading(PlayerPedId())})

		if PedInfo then
			if IsPlayerTargettingAnything(PlayerId()) then
				while IsPlayerTargettingAnything(PlayerId()) do
					DisplayPedInfo()
					Wait(0)
				end
				SendNUIMessage({container = "#ped-info", show = false})
			end
		end
		if IsControlJustPressed(0, 0xF3830D8E --[[J]]) then
			while not IsControlJustReleased(0, 0xF3830D8E --[[J]]) do
				Wait(0)
			end
			if hud == false then
			    OpenMenu(json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/main.json")))
			end
		end
		Wait(0)
	end
end)



function ScreenCoord(x,y,z)
	return Citizen.InvokeNative(0xCB50D7AFCC8B0EC6,x,y,z, Citizen.PointerValueFloat(), Citizen.PointerValueFloat() )
end

function DisableHTML()
	hud = false
	SendNUIMessage({DrawHTML = false})
	SetNuiFocus(false, false)
end
function DrawHTML()
	hud = true
	SendNUIMessage({DrawHTML = true})
end


function HideAllContainers()
	local containers = {
		"#prompt",
		"#ped-info",
		"#selection",
		"#ticker"
	}
	for i in pairs(containers) do
		SendNUIMessage({container = containers[i], show = false})
	end
end

local TickerVal = false
RegisterNUICallback("ticker-callback", function(data)
		TickerVal = data.value
		Wait(250)
		TickerVal = false
end)

function GetTickerVal()
	SendNUIMessage({ticker = true})
	while TickerVal == false do
		Wait(0)
	end
	return(TickerVal)
end

function DisplayPedInfo()
	local plycoords = GetEntityCoords(PlayerPedId())
	local _,ent = GetPlayerTargetEntity(PlayerId())
	local ped = GetPedIndexFromEntityIndex(ent)
	local pedcoords =GetEntityCoords(ped)
	local x,y = ScreenCoord(pedcoords.x,pedcoords.y,pedcoords.z)
	local dst = GetDistanceBetweenCoords(plycoords.x, plycoords.y, plycoords.z, pedcoords.x, pedcoords.y, pedcoords.z, true --[[useZ]])
	SendNUIMessage({container = "#ped-info", show = true, x = x, y = y, dst = dst, text=ped})
end

RegisterNUICallback("exit", function(data)
	DisableHTML()
end)

function OpenMenu(buttons)
	DrawHTML()
	SendNUIMessage({container = "#selection", show = false})
	SendNUIMessage({container = "#selection", show = true, buttons=buttons, auto=true})
	SetNuiFocus(true, true)
end

function InitializeMenu()
	for i in pairs(menuButtons) do
		RegisterNUICallback(menuButtons[i], function(data)
			id = "data/menus/"..menuButtons[i]..".json"
			OpenMenu(json.decode(LoadResourceFile(GetCurrentResourceName(),id)))
		end)
	end
end
InitializeMenu()

function MenuToEvent(buttons, event)
	DrawHTML()
	SendNUIMessage({container = "#selection", show = false})
	SendNUIMessage({container = "#selection", show = true, buttons=buttons, auto=true, event=event})
	SetNuiFocus(true, true)
end

-- Player -------------------
RegisterNUICallback("player-model", function(data)
    local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/models/submenu-male-female.json"))
    MenuToEvent(buttons, "SelectPlayerModel")
end)
RegisterNUICallback("SelectPlayerModel", function(data)
    local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),("data/menus/models/".. data.value ..".json")))
    MenuToEvent(buttons, "ChangePlayerModel")
end)
RegisterNUICallback("ChangePlayerModel", function(data)
	DisableHTML()
	model = GetHashKey(data.value)
	RequestModel(model,0)
	while not HasModelLoaded(model) do
		RequestModel(model,0)
		Wait(0)
	end
	SetPlayerModel(PlayerId(), model, true)
	SetModelAsNoLongerNeeded(model)
end)
RegisterNUICallback("player-scale", function(data)
	local ply = PlayerPedId()
	local modelscale = tofloat(GetTickerVal())
	DisableHTML()
	SetPedScale(ply, tofloat(modelscale))
end)
RegisterNUICallback("player-tp-waypoint", function(data)
	DisableHTML()
	if IsWaypointActive() then
		local ply = GetPlayerPed(PlayerId())
		local crd = GetWaypointCoords()
		SetEntityCoords(ply, crd.x, crd.y, 100.0, false, false, false, false)
		FreezeEntityPosition(ply,true)
		SetEntityVisible(ply,false)
		local ground = 0.0
		while ground == 0.0 do
			Wait(0)
			_,ground = GetGroundZAndNormalFor_3dCoord(crd.x, crd.y, 1000.0)
		end
		SetEntityCoords(ply, crd.x, crd.y, ground, false, false, false, false)
		FreezeEntityPosition(ply, false)
		SetEntityVisible(ply,true)
	end
end)

-- Peds -------------------
RegisterNUICallback("display-ped-info", function(data)
	DisableHTML()
	PedInfo = not PedInfo
end)

RegisterNUICallback("ped-scale", function(data)
	local modelscale = tofloat(GetTickerVal())
	SetNuiFocus(false, false)
	DrawHTML()
	SendNUIMessage({container = "#prompt", show = true, text = "Target a ped"})
	while not IsPlayerTargettingAnything(PlayerId()) do
		Wait(0)
	end
	SendNUIMessage({container = "#prompt", show = false})
	DisableHTML()
	local _,ent=GetPlayerTargetEntity(PlayerId())
	SetPedScale(ent, modelscale)
end)

RegisterNUICallback("peds-lasso", function(data)
	SetNuiFocus(false, false)
	DrawHTML()
	SendNUIMessage({container = "#prompt", show = true, text = "Target a ped"})
	while not IsPlayerTargettingAnything(PlayerId()) do
		Wait(0)
	end
	local _,ent = GetPlayerTargetEntity(PlayerId())
	local ped = GetPedIndexFromEntityIndex(ent)
	local ped2 = nil
	SendNUIMessage({container = "#prompt", text = "Target another ped"})
	function GetPed2()
		while not IsPlayerTargettingAnything(PlayerId()) do
			Wait(200)
		end
		local _,ent = GetPlayerTargetEntity(PlayerId())
		local ped = GetPedIndexFromEntityIndex(ent)
		return ped
	end
	while ped2 == nil or ped2 == ped do
		Wait(0)
		ped2 = GetPed2()
	end
	SendNUIMessage({container = "#prompt", text = "Ped attempting lasso!"})
	GiveWeaponToPed_2(ped, 0x7A8A724A, 1, true, true, 0x126210C3, true, 0.5, 1.0, 1, true, 0, 0)
	TaskLassoPed(ped, ped2)
	TaskStandStill(ped2, 10)
	Wait(2000)
	SendNUIMessage({container = "#prompt", show = false})
	DisableHTML()
end)

RegisterNUICallback("ped-drunk", function(data)
	SendNUIMessage({container = "#selection", show = false})
	SetNuiFocus(false, false)
	SendNUIMessage({container = "#prompt", show = true, text = "Target a ped"})
	while not IsPlayerTargettingAnything(PlayerId()) do
		Wait(0)
	end
	local ped = GetPedIndexFromEntityIndex(ent)
	SendNUIMessage({container = "#prompt", show = false})
	SetPedIsDrunk(ped, true)
end)

RegisterNUICallback("mount-scale", function(data)
	local modelscale = tofloat(GetTickerVal())
	SetNuiFocus(false, false)
	DrawHTML()
	SendNUIMessage({container = "#prompt", show = true, text = "Target a mounted ped"})
	function GetPedMount()
		while not IsPlayerTargettingAnything(PlayerId()) do
			Wait(0)
		end
		local _,ent = GetPlayerTargetEntity(PlayerId())
		local ped = GetPedIndexFromEntityIndex(ent)
		return GetMount(ped)
	end
	while GetPedMount() == 0 do
		print("Waiting for mount")
		Wait(300)
	end
	print("Ooops")
	SendNUIMessage({container = "#prompt", show = false})
		DisableHTML()
	local mount = GetPedMount(ped)
	SetPedScale(mount, modelscale)
end)

-- Weapons -------------------
RegisterNUICallback("give-weapon", function(data)
	local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/weapons/weapons.json"))
	OpenMenu(buttons)
end)
	RegisterNUICallback("wpnmenu-revolvers", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/weapons/revolvers.json"))
		MenuToEvent(buttons, "GiveWeapon")
	end)
	RegisterNUICallback("wpnmenu-pistols", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/weapons/pistols.json"))
		MenuToEvent(buttons, "GiveWeapon")
	end)
	RegisterNUICallback("wpnmenu-shotguns", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/weapons/shotguns.json"))
		MenuToEvent(buttons, "GiveWeapon")
	end)
	RegisterNUICallback("wpnmenu-rifles", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/weapons/rifles.json"))
		MenuToEvent(buttons, "GiveWeapon")
	end)
	RegisterNUICallback("wpnmenu-repeaters", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/weapons/repeaters.json"))
		MenuToEvent(buttons, "GiveWeapon")
	end)
	RegisterNUICallback("wpnmenu-misc", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/weapons/misc.json"))
		MenuToEvent(buttons, "GiveWeapon")
	end)
	RegisterNUICallback("wpnmenu-melee", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/weapons/melee.json"))
		MenuToEvent(buttons, "GiveWeapon")
	end)
	RegisterNUICallback("GiveWeapon", function(data)
		SendNUIMessage({container = "#selection", show = false})
		DisableHTML()
		GiveWeapon(data.value)
	end)
RegisterNUICallback("remove-weapons", function(data)
	SendNUIMessage({container = "#selection", show = false})
	DisableHTML()
	RemoveAllPedWeapons(PlayerPedId(), true, true)
end)
RegisterNUICallback("remove-current-weapon", function(data)
	SendNUIMessage({container = "#selection", show = false})
	DisableHTML()
	local ply = PlayerPedId()
	local _,currentWeapon = GetCurrentPedWeapon(ply, true, 0, true)
	RemoveWeaponFromPed(ply, currentWeapon, false, currentWeapon)
end)
RegisterNUICallback("infinite-ammo", function(data)
	local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/submenu-toggle.json"))
	MenuToEvent(buttons, "InfiniteAmmo")
end)
	RegisterNUICallback("InfiniteAmmo", function(data)
	SendNUIMessage({container = "#selection", show = false})
	DisableHTML()
	local ply = PlayerPedId()
	SetPedInfiniteAmmoClip(ply, data.value)
	end)



function GiveWeapon(weaponName)
	local ply = PlayerPedId()
	local coords = GetEntityCoords(ply, false, false)
	local weaponHash = GetHashKey(weaponName)
	local weaponType = GetWeapontypeGroup(weaponHash)
	GiveDelayedWeaponToPed(ply, weaponHash, 0, true, 12)
	SetPedAmmo(ply, weaponHash, 12)
	SetAmmoInClip(ply, weaponHash, 12)
end


-- Spawn -------------------
RegisterNUICallback("mdlmenu-animals", function(data)
	local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/models/animals.json"))
	MenuToEvent(buttons, "SpawnModel")
end)
RegisterNUICallback("mdlmenu-horses", function(data)
	local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/models/horses.json"))
	MenuToEvent(buttons, "SpawnModel")
end)
RegisterNUICallback("mdlmenu-peds-m", function(data)
	local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/models/peds-male.json"))
	MenuToEvent(buttons, "SpawnModel")
end)RegisterNUICallback("mdlmenu-peds-f", function(data)
	local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/models/peds-female.json"))
	MenuToEvent(buttons, "SpawnModel")
end)
RegisterNUICallback("SpawnModel", function(data)
	SendNUIMessage({container = "#selection", show = false})
	DisableHTML()
	SpawnModel(data.value)
end)

function SpawnModel(model)
	local ply = PlayerPedId()
	local crd = GetEntityCoords(ply, true, true)
	local heading = GetEntityHeading(ply)
	local hash = GetHashKey(model)
	RequestModel(hash,0)
    while not HasModelLoaded(hash) do
        RequestModel(hash,0)
        Wait(0)
    end

	local ped = CreatePed(model, crd.x+3, crd.y, crd.z, heading)
	local timeout = 0

	SetPedOutfitPreset(ped, true, false)
	Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
	SetEntityAsMissionEntity(ped, true, false)
	RequestCollisionAtCoord(crd.x+3, crd.y, crd.z)

	while not HasCollisionLoadedAroundEntity(ped) and timeout < 2000 do
		Citizen.Wait(0)
		timeout = timeout + 1
	end
	SetModelAsNoLongerNeeded(hash)
	TaskWanderStandard(ped,1.0,1)
end
-- World ------------------------
RegisterNUICallback("world-weather", function(data)
	local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/world/weather.json"))
	MenuToEvent(buttons, "ChangeWeather")
end)
RegisterNUICallback("ChangeWeather", function(data)
	SendNUIMessage({container = "#selection", show = false})
	DisableHTML()
	ChangeWeather(data.value)
end)
function ChangeWeather(weatherType)
	--SetWeatherType
	Citizen.InvokeNative(0x59174F1AFE095B5A, GetHashKey(weatherType), true, true, true, 10.0, false)
end

--NetworkClockTimeOverride(11,0,0,1,true)

-- Anims ------------------------
RegisterNUICallback("anim-play", function(data)
	local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/anims/anim-menu.json"))
	OpenMenu(buttons)
end)
	RegisterNUICallback("anim-animal", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/anims/animal.json"))
		MenuToEvent(buttons,"PlayScenario")
	end)
	RegisterNUICallback("anim-human", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/anims/human.json"))
		if data.value == true then
			MenuToEvent(buttons,"PlayScenarioInplace")
		else
			MenuToEvent(buttons,"PlayScenario")
		end
	end)
	RegisterNUICallback("anim-human-inplace-toggle", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/anims/inplace-toggle.json"))
		MenuToEvent(buttons,"anim-human")
	end)
	RegisterNUICallback("anim-seated", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/anims/seated-menu.json"))
		OpenMenu(buttons)
	end)
	RegisterNUICallback("anim-seated-chair", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/anims/seated-chair.json"))
		MenuToEvent(buttons,"PlaySeatedScenario")
	end)
	RegisterNUICallback("anim-seated-ground-toggle", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/anims/inplace-toggle.json"))
		MenuToEvent(buttons,"anim-seated-ground")
	end)
	RegisterNUICallback("anim-seated-ground", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/anims/seated-ground.json"))
		if data.value == true then
			MenuToEvent(buttons,"PlayScenarioInplace")
		else
			MenuToEvent(buttons,"PlayScenario")
		end
	end)
	RegisterNUICallback("anim-seated-ledge", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/anims/seated-ledge.json"))
		MenuToEvent(buttons,"PlayScenario-Ledge")
	end)
	RegisterNUICallback("anim-vehicle", function(data)
		local buttons = json.decode(LoadResourceFile(GetCurrentResourceName(),"data/menus/anims/vehicle.json"))
		MenuToEvent(buttons,"PlayScenario")
	end)
	RegisterNUICallback("PlayScenarioInplace", function(data)
		SendNUIMessage({container = "#selection", show = false})
		DisableHTML()
		PlayScenarioInplace(data.value)
	end)
	RegisterNUICallback("PlayScenario", function(data)
		SendNUIMessage({container = "#selection", show = false})
		DisableHTML()
		PlayScenario(data.value)
	end)	
	RegisterNUICallback("PlayScenario-Ledge", function(data)
		SendNUIMessage({container = "#selection", show = false})
		DisableHTML()
		PlayScenario(data.value,-2.02)
	end)
	RegisterNUICallback("PlaySeatedScenario", function(data)
		SendNUIMessage({container = "#selection", show = false})
		DisableHTML()
		PlaySeatedScenario(data.value)
	end)
	function PlayScenario(anim, offset)
		local ply = PlayerPedId()
		ClearPedTasks(ply)
		local pos,heading = PlayerSelectCoords(8)
		local timeout=0
		local zoffset = 0
		if offset ~= nil then
			zoffset = offset
		end
		print(zoffset)
		if pos ~= false then
			TaskGoStraightToCoord(ply, pos.x, pos.y, pos.z, 1.0, -1, 0.0, 0.0,0.0)
			while GetScriptTaskStatus(ply,0x7D8F4411,true) ~= 8 and timeout<300 do
				timeout=timeout+1
				Wait(0)
			end
			timeout=0
			SetPedDesiredHeading(ply, heading)
			while timeout<80 do
				timeout=timeout+1
				Wait(0)
			end
			timeout=0
			if zoffset ~= 0 then
				local coords = GetEntityCoords(ply)
				SetEntityCoords(ply, coords.x,coords.y,coords.z+zoffset)
				TaskStartScenarioInPlace(ply, GetHashKey(anim), 0, false, 0, 0, false)
			else
				TaskStartScenarioInPlace(ply, GetHashKey(anim), 0, true, 0, 0, true)
			end
		end
	end
	function PlayScenarioInplace(anim)
		local ply = PlayerPedId()
		ClearPedTasks(ply)
		TaskStartScenarioInPlace(ply, GetHashKey(anim), 0, true, 0, 0, true)
	end
	function PlaySeatedScenario(anim)
		local ply = PlayerPedId()
		local chairs = {"P_CHAIR_10X","P_CHAIR_BARREL04B","P_CHAIR_CRATE02X","P_CHAIR_CRATE15X","P_CHAIR_CS05X","P_CHAIR_PRIVATEDINING01X","P_CHAIR02X_DMG","P_CHAIR02X","P_CHAIR04X","P_CHAIR05X_SEA","P_CHAIR05X","P_CHAIR06X_DMG","P_CHAIR06X","P_CHAIR07X","P_CHAIR09X","P_CHAIR11X","P_CHAIR12BX","P_CHAIR12X","P_CHAIR13X","P_CHAIR14X","P_CHAIR15X","P_CHAIR16X","P_CHAIR17X","P_CHAIR18X","P_CHAIR19X","P_CHAIR20X","P_CHAIR21_LEG01X","P_CHAIR21X_FUSSAR","P_CHAIR21X","P_CHAIR22X","P_CHAIR23X","P_CHAIR24X","P_CHAIR25X","P_CHAIR26X","P_CHAIR27X","P_CHAIR30X","P_CHAIR31X","P_CHAIR34X","P_CHAIR37X","P_CHAIR38X","P_CHAIRBROKEN01X","P_CHAIRCOMFY01X","P_CHAIRCOMFY02","P_CHAIRCOMFY03X","P_CHAIRCOMFY04X","P_CHAIRCOMFY05X","P_CHAIRCOMFY06X","P_CHAIRCOMFY07X","P_CHAIRCOMFY08X","P_CHAIRCOMFY09X","P_CHAIRCOMFY10X","P_CHAIRCOMFY11X","P_CHAIRCOMFY12X","P_CHAIRCOMFY14X","P_CHAIRCOMFY16X","P_CHAIRCOMFY17X","P_CHAIRCOMFY18X","P_CHAIRCOMFY22X","P_CHAIRCOMFY23X","P_CHAIRCOMFYCOMBO01X","P_CHAIRCONVOROUND01X","P_CHAIRDECK01X","P_CHAIRDECKFOLDED01X","P_CHAIRDESK01X","P_CHAIRDESK02X","P_CHAIRDINING01X","P_CHAIRDINING02X","P_CHAIRDINING03X","P_CHAIRDOCTOR01X","P_CHAIRDOCTOR02X","P_CHAIREAGLE01X","P_CHAIRFOLDING02X","P_CHAIRHOB01X","P_CHAIRHOB02X","P_CHAIRIRONNBX01X","P_CHAIRMED01X","P_CHAIRMED02X","P_CHAIRNBX02X","P_CHAIROFFICE02X","P_CHAIRPOKERFANCY01X","P_CHAIRPORCH01X","P_CHAIRROCKING02X","P_CHAIRROCKING03X","P_CHAIRROCKING04X","P_CHAIRROCKING05X","P_CHAIRROCKING06X","P_CHAIRRUSTIC01X","P_CHAIRRUSTIC02X","P_CHAIRRUSTIC03X","P_CHAIRRUSTIC04X","P_CHAIRRUSTIC05X","P_CHAIRRUSTICSAV01X","P_CHAIRSALON01X","P_CHAIRTALL01X","P_CHAIRVICTORIAN01X","P_CHAIRWHITE01X","P_CHAIRWICKER01B_STATIC","P_CHAIRWICKER01X","P_CHAIRWICKER02X","P_CHAIRWICKER03X","MP005_S_POSSE_COL_CHAIR01X","MP005_S_POSSE_FOLDINGCHAIR_01X","MP005_S_POSSE_TRAD_CHAIR01X","P_AMBCHAIR01X","P_AMBCHAIR02X","P_ARMCHAIR01X","P_BISTROCHAIR01X","P_CHESTCHAIR01X","P_DININGCHAIRS01X","P_GEN_CHAIR06X","P_GEN_CHAIR07X","P_GEN_CHAIR08X","P_GEN_CHAIRPOKERFANCY01X","P_GROUP_CHAIR05X","P_OLDARMCHAIR01X","P_PIANOCHAIR01X","P_PRIVATELOUNGE_CHAIR01X","P_ROCKINGCHAIR01X","P_ROCKINGCHAIR02X","P_ROCKINGCHAIR03X","P_SIT_CHAIRWICKER01A","P_SIT_CHAIRWICKER01B","P_SIT_CHAIRWICKER01C","P_SIT_CHAIRWICKER01D","P_SIT_CHAIRWICKER01E","P_WINDSORCHAIR01X","P_WINDSORCHAIR02X","P_WINDSORCHAIR03X","P_WOODENCHAIR01X","P_WOODENDESKCHAIR01X","S_BFCHAIR04X","S_CHAIR04X","P_BENCH_LOG01X","P_BENCH_LOG02X","P_BENCH_LOG03X","P_BENCH_LOG04X","P_BENCH_LOG05X","P_BENCH_LOG06X","P_BENCH_LOG07X","P_BENCH_LOGSNOW07X","P_BENCH03X","P_BENCH06X_DMG","P_BENCH06X","P_BENCH08BX","P_BENCH09X","P_BENCH11X","P_BENCH15_MJR","P_BENCH15X","P_BENCH16X","P_BENCH17X","P_BENCH18X","P_BENCH20X","P_BENCHANNSALOON01X","P_BENCHBEAR01X","P_BENCHBROKEN02X","P_BENCHCH01X_DMG","P_BENCHCH01X","P_BENCHIRONNBX01X","P_BENCHIRONNBX02X","P_BENCHLONG05X","P_BENCHNBX01X","P_BENCHNBX02X","P_BENCHNBX03X","P_BENCHPIANO02X","P_BENCHWORK01X","P_HALLBENCH01X","P_NEW_RICH_BENCH2X","P_NEW_STONEBENCH02X","P_SEATBENCH01X","P_WINDSORBENCH01X","P_WOODBENCH02X","S_BENCH01X","P_BOXLRGSTOOL01X","P_GEN_STOOL01X","P_GEN_STOOL03X","P_GRP_W_TRA_STOOL01X","P_ROCKSTOOL02X","P_STOOL013X","P_STOOL01X","P_STOOL02X","P_STOOL03X","P_STOOL04X","P_STOOL05X","P_STOOL06X","P_STOOL07X","P_STOOL08X","P_STOOL09X","P_STOOL10X","P_STOOL11X","P_STOOL12X","P_STOOL13X","P_STOOL14X","P_STOOL15X","P_STOOL16X","P_STOOLCOMFY01X","P_STOOLCOMFY02X","P_STOOLFOLDING01BX","P_STOOLFOLDING01X","P_STOOLWINTER01X","S_STOOLFOLDINGSTATIC01X","P_AMBCLOTHSEAT01X","P_LOVESEAT01X","P_LOVESEAT02X","P_NORPASS_UP01X_SEAT01X","P_OPENSLEEPER_SEAT01X","P_OPENSLEEPER_TRE2_SEAT01X","P_RHOSALOONBOOTHSEAT01X","P_SEATBENCH01X","P_SEATSNORPASS_UPPER01X","P_SEATSNORPASS01_X","P_SEATSNORPASS01X_1_PSET_LOW","P_SEATSNORPASS01X_PSET_LOW","P_SEATSNORPASS01X_PSET_MED","P_SEATSNORPASS01X","P_SEATSNORPASS02_X","P_SEATSNORPASS02X","P_SEATSNORPASS03_X","P_SEATSNORPASS03X","S_CRATESEAT03X_LIDANIM","S_CRATESEAT03X","P_COUCH01X","P_COUCH02X","P_COUCH03X","P_COUCH05X","P_COUCH06X","P_COUCH08X","P_COUCH09X","P_COUCH10X","P_COUCH11X","P_COUCHWICKER01X"}
		local pos,heading = PlayerSelectCoords(5, chairs)
		if pos ~= false then
			local offset = -0.98
			SetEntityCoords(ply, pos.x, pos.y, pos.z+offset)
			SetEntityHeading(ply, heading)
			TaskStartScenarioInPlace(ply, GetHashKey(anim), 0, false, 0, 0, false)
		end
	end
RegisterNUICallback("anim-stop", function(data)
	SendNUIMessage({container = "#selection", show = false})
	DisableHTML()
	ClearPedTasks(PlayerPedId())
end)


function PlayerSelectCoords(distance, models)
	local function RotationToDirection(rotation)
		local adjustedRotation = 
		{ 
			x = (math.pi / 180) * rotation.x, 
			y = (math.pi / 180) * rotation.y, 
			z = (math.pi / 180) * rotation.z 
		}
		local direction = 
		{
			x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
			y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
			z = math.sin(adjustedRotation.x)
		}
		return direction
	end
	local function RayCastGamePlayCamera(distance)
		local cameraRotation = GetGameplayCamRot()
		local cameraCoord = GetGameplayCamCoord()
		local direction = RotationToDirection(cameraRotation)
		local destination = 
		{ 
			x = cameraCoord.x + direction.x * distance, 
			y = cameraCoord.y + direction.y * distance, 
			z = cameraCoord.z + direction.z * distance 
		}
		local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, -1, 1))
		return b, c, e
	end

	local Prompt_Cancel = CreatePrompt("Cancel", 0x156F7119 --[[Backspace]], true)
	local Prompt_RotLeft = CreatePrompt("Spin Left", 0xA65EBAB4 --[[Left]], false)
	local Prompt_RotRight = CreatePrompt("Spin Right", 0xDEB34313 --[[Right]], false)
	local Prompt_Confirm = CreatePrompt("Confirm", 0xC7B5340A --[[Enter]], true)
	local Prompts = {Prompt_Cancel,Prompt_RotLeft,Prompt_RotRight,Prompt_Confirm}
	local function HidePrompts()
		PromptSetVisible(Prompt_RotLeft, false)
		PromptSetEnabled(Prompt_RotLeft, false)
		PromptSetVisible(Prompt_RotRight, false)
		PromptSetEnabled(Prompt_RotRight, false)
		PromptSetVisible(Prompt_Confirm, false)
		PromptSetEnabled(Prompt_Confirm, false)
	end
	local function ShowPrompts()
		PromptSetVisible(Prompt_RotLeft, true)
		PromptSetEnabled(Prompt_RotLeft, true)
		PromptSetVisible(Prompt_RotRight, true)
		PromptSetEnabled(Prompt_RotRight, true)
		PromptSetVisible(Prompt_Confirm, true)
		PromptSetEnabled(Prompt_Confirm, true)
	end
	local function DrawEligibleMarker(coords, heading)
		Citizen.InvokeNative(0x2A32FAA57B937173,-1795314153, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.35, 0.35, 0.20, 0, 255, 0, 30, false, false, 2, nil, nil, false)
		Citizen.InvokeNative(0x2A32FAA57B937173,1857541051, coords.x+radx, coords.y+rady, coords.z, 10.0, 0.0, 0.0, 0.0, 0.0, heading, 0.05, 0.06, 0.20, 0, 255, 0, 30, false, false, 2, nil, nil, false)
		ShowPrompts()
	end
	local function DrawIneligibleMarker(coords)
		Citizen.InvokeNative(0x2A32FAA57B937173,-1795314153, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.35, 0.35, 0.20, 255, 128, 0, 30, false, false, 2, nil, nil, false)
		HidePrompts()
	end

	local heading = GetEntityHeading(PlayerPedId())-90
	local Selected = false
	while Selected == false do
		Wait(0)
		-- Exit
		if PromptHasHoldModeCompleted(Prompt_Cancel) then
			for Prompt in pairs(Prompts) do
				PromptDelete(Prompts[Prompt])
			end
			return false
		end
	-- Rotate Left/Right
		-- PromptHasStandardModeCompleted doesn't work in while loops, IsControlPressed is necessary for constant rotation
		if IsControlPressed(0, 0xA65EBAB4 --[[Left]]) then
			heading = heading + 2
		elseif IsControlPressed(0, 0xDEB34313 --[[Right]]) then
			heading = heading - 2
		end
	-- Pointer match
		radx = math.cos(heading*(math.pi/180)) * 0.2
		rady = math.sin(heading*(math.pi/180)) * 0.2
	-- Draw Marker
		local hit, coords, ent = RayCastGamePlayCamera(distance)
		if hit and (ent ~= PlayerPedId()) and coords.x ~= 0.0 then
		-- Seek model
			if models ~= nil then
			-- Check if targetted entity is a valid model
				local Chair_Found = false
				for i in pairs(models) do
					if GetEntityModel(ent) == GetHashKey(models[i]) then
						Chair_Found = true
					end
				end
				if Chair_Found then
					DrawEligibleMarker(coords, heading)
				else
					DrawIneligibleMarker(coords)
				end
			-- Confirm 
				if PromptHasHoldModeCompleted(Prompt_Confirm) then
					for Prompt in pairs(Prompts) do
						PromptDelete(Prompts[Prompt])
					end
					return coords, heading-90
				end
			else
			-- Place anywhere
				DrawEligibleMarker(coords, heading)
			-- Confirm
				if PromptHasHoldModeCompleted(Prompt_Confirm) then
					for Prompt in pairs(Prompts) do
						PromptDelete(Prompts[Prompt])
					end
					return coords, heading-90
				end
			end
		else
			HidePrompts()
		end
	end
end

function CreatePrompt(name, key, hold, group)
	local Prompt
    Citizen.CreateThread(function()
        local str = name
        local wait = 0
    Prompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(Prompt, key)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(Prompt, str)
        PromptSetEnabled(Prompt, true)
        PromptSetVisible(Prompt, true)
        if group ~= false then
        	PromptSetGroup(Prompt, group)
        end
        if hold == true then
       		PromptSetHoldMode(Prompt, true)
       	else
       		PromptSetStandardMode(Prompt, true)
       	end
        PromptRegisterEnd(Prompt)
    end)
    Wait(30)
   	return Prompt
end

--[[
PromptIsEnabled(Prompt)
PromptHasHoldModeCompleted(Prompt)
PromptHasStandardModeCompleted(Prompt, false)
PromptDelete(Prompt)
]]

function tofloat(var)
	if type(var) == "string" then
		var = tonumber(var)
	elseif math.type(var) == "integer" then
		var = tonumber(tostring(var)..".0")
	end
	return var
end