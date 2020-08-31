$(function () {
	/*
	document.onkeyup = function(data) {
        if(data.which == 27) { //esc
            exit();
        }
    }

    function exit() {

    }
	*/

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

	function selectSpawn(id) {
		$.post("http://fowl-login/selectSpawn", JSON.stringify({
			spawnId : id
		}))
	}

	var loc_bla = {
		marker_x : 19.8647,
		marker_y : 53.9720
	}
	var loc_str = {
		marker_x : 21.4569,
		marker_y : 51.5561
	}
	var loc_val = {
		marker_x : 43.4957,
		marker_y : 48.7893
	}
	var loc_ann = {
		marker_x : 63.8637,
		marker_y : 47.9703
	}
	var loc_san = {
		marker_x : 87.0127,
		marker_y : 53.7681
	}

	var spawnCities = [loc_bla, loc_str, loc_val, loc_ann, loc_san]

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

	function showDiv(div)
	{
		$(div).show();
	}

	function hideDiv(div)
	{
		$(div).hide();
	}

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
				showDiv("#login-prompt");
			} else if(ed.loginPrompt === false) {
				hideDiv("#login-prompt");
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
			showDiv("#mainwrap");
		};

		if(ed.DrawHTML === false) {
			hideDiv("#mainwrap");
		};

		if(ed.container) {
			if(ed.show === true) {
				showDiv(ed.container)
			};
			if(ed.show === false) {
				hideDiv(ed.container)
			};
		};
	});
});