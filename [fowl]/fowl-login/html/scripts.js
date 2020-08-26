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
				showDiv("login-prompt");
			} else if(ed.loginPrompt === false) {
				hideDiv("login-prompt");
			};
		};

		if(ed.loginPromptContent) {
			document.getElementById("login-prompt").textContent = ed.loginPromptContent;
		};

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