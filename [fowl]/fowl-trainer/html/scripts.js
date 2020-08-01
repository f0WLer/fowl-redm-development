$(function () {
	$("#ticker").hide(); //Hide ticker on launch
	var Buttons = []

	function SortButtons(buttons){
		var sortedbuttons = {}
		Object.keys(buttons).sort((a, b) => a - b).forEach(function(index) {
			sortedbuttons[buttons[index][0]]=buttons[index][1]
		})
		return sortedbuttons
	}

	

	function AddButtons(menubuttons){
		RemoveButtons();
		Object.keys(menubuttons).forEach(function(name) {
    		var id = menubuttons[name]
    		var buttonname = "<button id="+id+">"+name+"</button>"
    		$("#selection").append(buttonname);
    		Buttons.push("#"+id)
		});
	}

	function AddAutoButtons(menubuttons, event=false){
		RemoveButtons();
		Object.keys(menubuttons).forEach(function(name) {
    		var id = menubuttons[name]
    		var buttonname = "<button class=selection-button id="+id+">"+name+"</button>"
    		$("#selection").append(buttonname);
    		Buttons.push("#"+id)
    		$("#" + id).unbind('click').click(function(){
            	closeSelection();
            	if (event === false) {
	            	$.post(("http://fowl-trainer/"+id), JSON.stringify({
	            		value : id
	            	}));
	            }
	            else {
	            	$.post(("http://fowl-trainer/"+event), JSON.stringify({
	            		value : id
	            	}));
	            }
			})
		});
	}

	function AddPages(pages, event=false){
		function DrawPage(pagenum, event=false){
			RemoveButtons();
			console.log(pagenum)
			var page = pages[pagenum]
			var menubuttons = {}
			for (i = 0; i < 200; i+=2) {
				if (page[i] != undefined) {
					menubuttons[page[i]]=page[i+1]
				}
			}
			AddAutoButtons(menubuttons, event);
			DrawNav(pagenum)
		}
		function DrawNav(currentpage) {
			$("#selection").append("<p id=selection-pgnm>"+(currentpage+1)+"</p>")
			if (currentpage != 0) {
				$("#selection").append("<button id=selection-prevpg><</button>")
				$("#selection-prevpg").unbind('click').click(function(){
					DrawPage((currentpage-1), event);
				})
			}
			
			if (currentpage != (Object.keys(pages).length - 1)) {
				$("#selection").append("<button id=selection-nextpg>></button>")
				$("#selection-nextpg").unbind('click').click(function(){
					DrawPage((currentpage+1), event);
				})
			}
			Buttons.push("#selection-pgnm")
			Buttons.push("#selection-prevpg")
			Buttons.push("#selection-nextpg")
		}
		DrawPage(0, event)
		//for (i = 0; i < Object.keys(pages).length; i++) {
		//}
	}

	function RemoveButtons(){
		Buttons.forEach(function(item) {
			$(item).remove();
		})
	}

	document.onkeyup = function(data) {
        if(data.which == 27) { //esc
            $.post("http://fowl-trainer/exit", JSON.stringify({}));
            RemoveButtons();
        }
    }

	function openContainer()
	{
		$(".mainwrap").show();
		$(".floatwrap").css("display", "block");
	}

	function closeContainer()
	{
		$(".mainwrap").hide();

	}

	function showDiv(div)
	{
		$(div).show();

	}

	function hideDiv(div)
	{
		$(div).hide();

	}

	function updateText(container, text)
	{
		$(container).text(text);
	}

	function updatePos(container, x,y)
	{
		xRound = (x * 100)
		yRound = (y * 50)
		$(container).css("margin-left", xRound + "%");
		$(container).css("margin-top", yRound + "%");

	}

	function updateDistance(container, dst)
	{
		$(container).css("font-size", dst + 20 + "%");
	}

	function openSelection(menubuttons)
	{	
		if (Object.keys(menubuttons).length < 100) {
			AddButtons(menubuttons);
			$(".selection").show();
		}
		else {
			var pages={}
			Array(Math.ceil(menubuttons.length/100)).fill(1).map(i => {
				pages.append(menubuttons[0]);
				menubuttons.slice(0);
			})
			print(Object.keys(pages).length)

		}
	}

	function openAutoSelection(menubuttons, event)
	{	
		if(event === false) {
			AddAutoButtons(menubuttons);
			$(".selection").show();
		}


		else {
			if (Object.keys(menubuttons).length < 100) {
				AddAutoButtons(menubuttons, event);
				$(".selection").show();
			}
			else {
				console.log("generating pages")
				var pages={}
				var numpages = (Math.ceil(Object.keys(menubuttons).length / 100))
				for (i = 0; i < numpages; i+=1) {
					pages[i]=[]
					//console.log(Object.keys(menubuttons).length)
					for (v = 0; v < 100; v++) {
						pages[i].push(Object.keys(menubuttons)[v+(i*100)], menubuttons[Object.keys(menubuttons)[v+(i*100)]])
					}
				}
				AddPages(pages, event)
			}
		}
	}

	function closeSelection()
	{
		RemoveButtons();
		$(".selection").hide();
	}

	var TickerEvent = null
	$("#ticker > #ticker-submit").click(function() {
		if($( "#ticker > #ticker-input" ).val()) {
			var val = $( "#ticker > #ticker-input" ).val();
			if (val != '') {
				val = parseFloat(val).toFixed(2)
				$( "#ticker > #ticker-input" ).val(1);
    			SendTickerValue(val)
   			}
    	}
	})

	function SendTickerValue(val) {
		hideDiv("#ticker");
    	TickerEvent = null
    	var link = "http://fowl-trainer/ticker-callback"
    	$.post(link, JSON.stringify({
    		value : val
    	}));	
	}


	window.addEventListener("message", function(event){
		var ed = event.data;

		if(ed.DrawHTML === true) {
			openContainer();
			//updateContainer(ed.x,ed.y);
		}

		if(ed.DrawHTML === false) {
			closeContainer();
		}

		//Text 
		if(ed.container) {
			if(ed.show === true) {
			showDiv(ed.container)
			}
			if(ed.show === false) {
			hideDiv(ed.container)
			}

			if(ed.container === "#selection") {
				if(ed.show === true) {
					if(ed.auto === true) {
						if(ed.event) {
							openAutoSelection(SortButtons(ed.buttons), ed.event);
						}
						else {
							openAutoSelection(SortButtons(ed.buttons));
						}
					}
					else {
						openSelection(SortButtons(ed.buttons));
					}
				}
				if(ed.show === false) {
					closeSelection();
				}
			}
			if(ed.container === "#ped-info") {
				if(ed.x,ed.y) {
					updatePos(ed.container, ed.x,ed.y);
				}
				if(ed.dst) {
					updateDistance(ed.container, ed.dst);
				}
				if(ed.text) {
					updateText(ed.container, ed.text);
				}
			}
			if(ed.container === "#hover-wrap") {
				if(ed.show === true) {
					showDiv("#hover-wrap")
				}
				if(ed.show === false) {
					hideDiv("#hover-wrap")
				}

				if(ed.blips) {
					var blips = ed.blips
					for (const blip of Object.keys(blips)){
						var blipname = "<div class=hover-blip id="+blip+"></div>"
    					$("#hover-wrap").append(blipname)
						updatePos("#"+blip, blips[blip][0],blips[blip][1]);
					}		
				}
			}
		}
		if(ed.ticker === true) {
			showDiv("#ticker");
		}
	});	
});