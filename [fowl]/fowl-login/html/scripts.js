// Character Creation
var newCharFields = ["firstname","lastname"]
var requiredNewCharFields = ["firstname","lastname"];
function createNewChar() {
	var canCreate = true;
	for (const [key, value] of Object.entries(requiredNewCharFields)) {
		var element = document.getElementById("newcharinput-"+value);
		if (element.value.length === 0) {
			canCreate = false;
			element.style.border = "1px solid #CF0200";
		};
	};
	if (canCreate === true) {
		var newCharData = {};
		for (const [key, value] of Object.entries(newCharFields)) {
			var element = document.getElementById("newcharinput-"+value);
			newCharData[value]=element.value;
			element.value = "";
			element.style.border = "1px solid white"
		};
		$.post("http://fowl-login/createNewChar", JSON.stringify({
			charData : newCharData
		}));
		$("#cmenu-newchar").hide();
		$("#cmenu-selection").show();
	};
};

// Spawn Selection
function confirmSpawn() {
	$.post("http://fowl-login/confirmSpawn", JSON.stringify({}))
}

function cancelSpawn() {
	$.post("http://fowl-login/cancelSpawn", JSON.stringify({}))
}

$(function () {
	//Character Data
	function populateCharWindow(charData) {
		charData = charData.filter(function (el) {
			return el != null;
		});

		function createCharElement(char) {
			var cmenuChars = document.getElementById('cmenu-chars');

    		var charWindow = document.createElement("div");
    		charWindow.classList.add("charWindow");
    		cmenuChars.appendChild(charWindow);


    		var cwindowBorder = document.createElement("img");
    		cwindowBorder.classList.add("cwindow-border");
    		cwindowBorder.src = "assets/textures/char-window-border.png";
    		charWindow.appendChild(cwindowBorder);

    		var charData = document.createElement("div");
    		charData.classList.add("char-data");
    		charWindow.appendChild(charData);

    		var charSelectButton = document.createElement("button");
    		charSelectButton.id = "char-select-button";
    		charSelectButton.textContent = "select";
    		charSelectButton.onclick = function() { selectChar(char.id); };
    		charWindow.appendChild(charSelectButton);

    		// Character Info
    		var charInfo = document.createElement("div");
    		charInfo.classList.add("char-info");
    	

    			// Name
    				//Info Tag
    		var charInfoTag = document.createElement("div");
    		charInfoTag.classList.add("char-info-tag");

    		var infoText = document.createElement("h1");
    		infoText.classList.add("info-text");
    		infoText.textContent = "name";
    		charInfoTag.appendChild(infoText);

    		charInfo.appendChild(charInfoTag);
    				//
    		var lineBreak = document.createElement("span");
    		lineBreak.classList.add("linebreak");
    		charInfo.appendChild(lineBreak);
    				//Info Value
    		var charInfoValue = document.createElement("div");
    		charInfoValue.classList.add("char-info-value");

    		var infoText = document.createElement("h1");
    		infoText.classList.add("info-text");
    		if (char.firstname && char.lastname) {
    			infoText.textContent = char.firstname + " " + char.lastname;
    		} else if (char.firstname || char.lastname) {
    			infoText.textContent = char.firstname || char.lastname;
    		};
    		charInfoValue.appendChild(infoText);

    		charInfo.appendChild(charInfoValue);
    				//
    			//

    		infoDivider = document.createElement("img");
    		infoDivider.classList.add("info-divider");
    		infoDivider.src = "assets/textures/divider_line.png";
    		charInfo.appendChild(infoDivider);

    		charData.appendChild(charInfo);
    		//
		}

		if (charData.length >= 5) {
			$("#new-char-button").hide();
			$("#new-char-button-ghost").hide();
		};

		document.getElementById("cmenu-chars").innerHTML = "";

		for(var i = 0; i < charData.length; i++) {
   			var char = charData[i];

   			createCharElement(char)
		}

		$.post("http://fowl-login/charWindowPopulated", JSON.stringify({}));
	}

	function allowLogin() {
		var mainwrap = document.getElementById('mainwrap');
		var continuePrompt = document.getElementById('mmenu-prompt');

		mainwrap.onclick = function() { mmenuContinue(); };
		continuePrompt.textContent = "click anywhere to begin";
	};

	function selectChar(id) {
		$.post("http://fowl-login/selectChar", JSON.stringify({
			charid : id
		}));
	}

	// Spawning / City Markers
	function selectSpawn(id) {
		$.post("http://fowl-login/selectSpawn", JSON.stringify({
			spawnId : id
		}))
	}

	function populateMarkers(cityData) {
		var smenu = document.getElementById("smenu");
   		var smenuMarkers = document.getElementById("smenu-markers");


   		function displayCityTitle(id) {
   			var icon = document.getElementById("icon-"+(id));
   			var cityTitle = document.getElementById("cityTitle-"+(id));

   			icon.style.opacity = 0;
   			cityTitle.style.opacity = 1;
   		};

   		function hideCityTitle(id) {
   			var icon = document.getElementById("icon-"+(id));
   			var cityTitle = document.getElementById("cityTitle-"+(id));

   			icon.style.opacity = 1;
   			cityTitle.style.opacity = 0;
   		};

		var city = cityData;
		if(city) {
			var id = city.id;

   			var marker = document.createElement("div");
   			marker.classList.add("smenu-city-marker");
   			marker.id = "marker-" + id;

   			var icon = document.createElement("img");
   			icon.classList.add("marker-icon");
   			icon.src = "assets/icons/blip_poi.png";
   			icon.style.left = (city.marker_x*100) + "%";
   			icon.style.bottom = (100 - (city.marker_y*100)) + "%";
   			icon.id = "icon-" + id;

   			var cityTitle = document.createElement("div");
   			cityTitle.classList.add("city-title");
   			cityTitle.id = "cityTitle-" + id;
   			cityTitle.style.left = (city.marker_x*100) + "%";
   			cityTitle.style.bottom = (100 - (city.marker_y*100)) + "%";
   			cityTitle.style.opacity = 0;
   			cityTitle.onclick = function() { selectSpawn(id); };

   			var cityText = document.createElement("h1");
   			cityText.classList.add("city-text");
   			cityText.textContent = city.name;
   			cityTitle.appendChild(cityText);

   			cityTitle.onmouseover = function(){displayCityTitle(id);};
   			cityTitle.onmouseout = function(){hideCityTitle(id);};


   			marker.appendChild(icon);
   			marker.appendChild(cityTitle);
   			smenuMarkers.appendChild(marker);
   		};

	};

	window.addEventListener('message', function(event) {
		var ed = event.data;

		if(ed.populateCharWindow === true) {
			if(ed.charData) {
				populateCharWindow(ed.charData);
			};
		};

		if(ed.loginReady === true) {
			allowLogin();
		};

		if(ed.loginPrompt) {
			if(ed.loginPrompt === true) {
				$("#login-prompt").show;
			} else if(ed.loginPrompt === false) {
				$("#login-prompt").hide;
			};
		};

		if(ed.loginPromptContent) {
			document.getElementById("login-prompt").textContent = ed.loginPromptContent;
		};

		if(ed.initSpawnSelect) {
			$("#cmenu").hide();
			$("#smenu").show();
			populateMarkers();
		}

		if(ed.cityData) {
			populateMarkers(ed.cityData);
		}

		if(ed.drawIcons) { $("#smenu-markers").show() }

		if(ed.hideIcons) { $("#smenu-markers").hide() }

		if(ed.drawMenu) { $("#smenu-options").show() }

		if(ed.hideMenu) { $("#smenu-options").hide() }

		if(ed.DrawHTML === true) {
			$("#mainwrap").show();
		};

		if(ed.DrawHTML === false) {
			$("#mainwrap").hide();
		};

	});
});