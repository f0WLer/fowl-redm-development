$(function () {

	document.onkeyup = function(data) {
        if(data.which == 27) { //esc
            //exit();
        }
    }

    function exit() {

	}
	

	function addInventorySlots(amount, inventory) {
		var itemGrid = document.getElementById(inventory+"-items");

		function createSlot() {
			var item = document.createElement("div");
			item.classList.add("item");
			item.id = inventory+"_item_"+i;
			item.setAttribute("data-populated", false);
			item.onmousedown = function(){dragItem(this, item.id)};
			
			var amount = document.createElement("div");
			amount.classList.add("item-amount");
			amount.id = inventory+"_item_"+i+"_amount";
			item.appendChild(amount);
			
			var name = document.createElement("div");
			name.classList.add("item-name");
			name.id = inventory+"_item_"+i+"_name";
			item.appendChild(name);

			var icon = document.createElement("img");
			icon.classList.add("item-icon");
			icon.id = inventory+"_item_"+i+"_icon";
			item.appendChild(icon)

			itemGrid.appendChild(item);
		}

		for (i = 1; i <= amount; i++) {
			createSlot(i);
		};

	}
	
	function populateInventory(array, inventory) {
		Object.keys(array).forEach(function(i) {
			if (Object.keys(array[i]).length != 0) {
				var item = inventoryItems[array[i].item];
				var amount = array[i].amount;
				var itemId = array[i].item;
				var slot = document.getElementById(inventory+"_item_"+i);
				var slotName = document.getElementById(inventory+"_item_"+i+"_name");
				var slotAmount = document.getElementById(inventory+"_item_"+i+"_amount");
				var slotIcon = document.getElementById(inventory+"_item_"+i+"_icon");
				
				slotName.innerHTML = item.name;
				if (amount > 1) {
					slotAmount.innerHTML = amount;
				}
				slot.setAttribute("data-item-id", itemId);
				slotIcon.src = "assets/item-icons/"+item.icon+"";
				
				slot.setAttribute("data-populated", true);
			}
		});
	}

	var selectedItem;
	var selectedAmount;
	function dragItem(refItem, itemId) {
		var draggedItem = document.getElementById("drag-item");
		var draggedItemName = document.getElementById("drag-item-name");
		var draggedItemAmount = document.getElementById("drag-item-amount");
		var draggedItemIcon = document.getElementById("drag-item-icon");
		selectedAmount = parseInt(document.getElementById("amount-input").value);

		
		if ( refItem.getAttribute("data-populated") === "true" ) {
			draggedItemName.innerHTML = document.getElementById(refItem.id +"_name").innerHTML;
			
			if ( document.getElementById(refItem.id + "_amount").innerHTML == "" ) {
				selectedAmount = 1;
			} else {
				if ( isNaN(selectedAmount) ) {
					selectedAmount = parseInt(document.getElementById(refItem.id + "_amount").innerHTML);
				} else if ( selectedAmount > document.getElementById(refItem.id + "_amount").innerHTML || selectedAmount == 0) {
					selectedAmount = parseInt(document.getElementById(refItem.id + "_amount").innerHTML);
				}
			}

			if (selectedAmount == 1) {
				draggedItemAmount.innerHTML = "";
			} else {
				draggedItemAmount.innerHTML = selectedAmount;
			}


			draggedItemIcon.src = document.getElementById(refItem.id + "_icon").src;
			
			selectedItem = refItem;
			dragElement(draggedItem);
		}
	}

	function getSlotIndex(el) {
		var index = el.id;
		index = index.replace("player_item_","");
		index = index.replace("target_item_","");
		return parseInt(index);
	}
	function getSlotId(el) {
		return el.getAttribute("data-item-id");
	}
	function getSlotName(el) {
		return document.getElementById(el.id + "_name").innerHTML;
	}
	function getSlotAmount(el) {
		var value = document.getElementById(el.id + "_amount").innerHTML;
		if ( value == "" ) {
			return 1;
		} else {
			return parseInt(value);
		}
	}
	function getSlotIcon(el) {
		return document.getElementById(el.id + "_icon").src;
	}
	function isSlotPopulated(el) {
		return el.getAttribute("data-populated");
	}
	function setSlotPopulated(el, bool) {
		el.setAttribute("data-populated", bool)
	}
	function isStackable(itemId) {
		return inventoryItems[itemId].stackable;
	}
	function setSlotId(el, id) {
		el.setAttribute("data-item-id", id);
	}
	function setSlotName(el, name) {
		document.getElementById(el.id + "_name").innerHTML = name;
	}
	function setSlotAmount(el, amount) {
		if (amount == 1 || amount == "1") {
			document.getElementById(el.id + "_amount").innerHTML = "";
		} else {
			document.getElementById(el.id + "_amount").innerHTML = amount;
		}
	}
	function setSlotIcon(el, icon) {
		document.getElementById(el.id + "_icon").src = icon;
	}
	function removeSlotId(el) {
		el.removeAttribute("data-item-id")
	}

	function handleDrop(id) {
		var targetSlot = document.getElementById(id);
		var itemId = getSlotId(selectedItem);
		var selectedItemAmount = getSlotAmount(selectedItem);
		if ( targetSlot != null && targetSlot != selectedItem ) {
			if ( id.includes("item_") ) {
				// Moving on top of another item
				if ( isSlotPopulated(targetSlot) === "true" ) {
					// Same Item
					if ( getSlotId(targetSlot) ===  getSlotId(selectedItem) ) {
						// Item can stack
						if ( isStackable(itemId) ) {
							if ( selectedAmount >= selectedItemAmount ) {
								combineItems(selectedItem, targetSlot);
							} else {
								mathItems(selectedItem, targetSlot);
							}
						// Item can't stack
						} else {
							swapItems(selectedItem, targetSlot);
						}
					// Different Items
					} else {
						swapItems(selectedItem, targetSlot);
					}
				// Moving on top of an empty slot
				} else {
					if (selectedAmount != selectedItemAmount && selectedItemAmount != "") {
						splitItem(selectedItem, targetSlot);
					} else {
						moveItem(selectedItem, targetSlot);
					}
				}
			}
		}
	}

	const secure = {
		player : {
			move : function(item, target) {
				fetch(`https://${GetParentResourceName()}/player_move`, {
					method: 'POST',
					headers: {
						'Content-Type': 'application/json; charset=UTF-8',
					},
					body: JSON.stringify({
						item: item,
						target: target,
					})
				}).then(resp => resp.json()).then(resp => secure.inventory.secureCallback(resp));
			},
			swap : function(item, target) {
				fetch(`https://${GetParentResourceName()}/player_swap`, {
					method: 'POST',
					headers: {
						'Content-Type': 'application/json; charset=UTF-8',
					},
					body: JSON.stringify({
						item: item,
						target: target,
					})
				}).then(resp => resp.json()).then(resp => secure.inventory.secureCallback(resp));
			},
			math : function(item, target, amount, expectedItemAmount, expectedTargetAmount) {
				fetch(`https://${GetParentResourceName()}/player_math`, {
					method: 'POST',
					headers: {
						'Content-Type': 'application/json; charset=UTF-8',
					},
					body: JSON.stringify({
						item: item,
						target: target,
						amount: amount,
						expectedItemAmount: expectedItemAmount,
						expectedTargetAmount: expectedTargetAmount,
					})
				}).then(resp => resp.json()).then(resp => secure.inventory.secureCallback(resp));
			},
			combine : function(item, target, expectedSum) {
				fetch(`https://${GetParentResourceName()}/player_combine`, {
					method: 'POST',
					headers: {
						'Content-Type': 'application/json; charset=UTF-8',
					},
					body: JSON.stringify({
						item: item,
						target: target,
						expectedSum: expectedSum,
					})
				}).then(resp => resp.json()).then(resp => secure.inventory.secureCallback(resp));
			},
			split : function(item, target, amount, expectedSum) {
				fetch(`https://${GetParentResourceName()}/player_split`, {
					method: 'POST',
					headers: {
						'Content-Type': 'application/json; charset=UTF-8',
					},
					body: JSON.stringify({
						item: item,
						target: target,
						amount: amount,
						expectedSum: expectedSum,
					})
				}).then(resp => resp.json()).then(resp => secure.inventory.secureCallback(resp));
			},
		},

		inventory : {
			secureCallback : function(wasSuccessful) {
				if ( wasSuccessful ) {
					console.log("Success!");
				} else {
					console.log("Failure :(");
				}
			},
		}
	}

	function swapItems(primItem, secItem) {
		var primName = getSlotName(primItem);
		var primAmount = getSlotAmount(primItem);
		var primIcon = getSlotIcon(primItem);
		var primId = getSlotId(primItem);
		var primIndex = getSlotIndex(primItem);

		var secIndex = getSlotIndex(secItem);
		var secId = getSlotId(secItem);
		var secAmount = getSlotAmount(secItem);

		setSlotName(primItem, getSlotName(secItem));
		setSlotAmount(primItem, getSlotAmount(secItem));
		setSlotIcon(primItem, getSlotIcon(secItem));
		setSlotId(primItem, getSlotId(secItem));

		setSlotName(secItem, primName);
		setSlotAmount(secItem, primAmount);
		setSlotIcon(secItem, primIcon);
		setSlotId(secItem, primId);

		if ( primItem.id.includes("player") && secItem.id.includes("player") ) {
			secure.player.swap(
				{"index":primIndex,"id":primId,"amount":primAmount},
				{"index":secIndex,"id":secId,"amount":secAmount},
			);
		}
	}

	function moveItem(item, slot) {
		var itemName = getSlotName(item);
		var itemAmount = getSlotAmount(item);
		var itemIcon = getSlotIcon(item);
		var itemId = getSlotId(item);
		var itemIndex = getSlotIndex(item);

		var slotIndex = getSlotIndex(slot);
		var slotId = getSlotId(slot);
		var slotAmount = getSlotAmount(slot);

		setSlotName(item, "");
		setSlotAmount(item, "");
		setSlotIcon(item, "");

		setSlotName(slot, itemName);
		setSlotAmount(slot, itemAmount);
		setSlotIcon(slot, itemIcon);

		removeSlotId(item);
		setSlotPopulated(item, false);
		setSlotId(slot, itemId);
		setSlotPopulated(slot, true);


		if ( item.id.includes("player") && slot.id.includes("player") ) {
			secure.player.move(
				{"index":itemIndex,"id":itemId,"amount":itemAmount},
				{"index":slotIndex,"id":slotId,"amount":slotAmount},
			);
		}
	}

	function mathItems(primItem, secItem){
		var primIndex = getSlotIndex(primItem);
		var primId = getSlotId(primItem);
		var primAmount = getSlotAmount(primItem);
		var secIndex = getSlotIndex(secItem);
		var secId = getSlotId(secItem);
		var secAmount = getSlotAmount(secItem);

		var primSum = primAmount - selectedAmount;
		var secSum = secAmount + selectedAmount;

		setSlotAmount(primItem, primSum);
		setSlotAmount(secItem, secSum);

		if ( primItem.id.includes("player") && secItem.id.includes("player") ) {
			secure.player.math(
				{"index":primIndex,"id":primId,"amount":primAmount},
				{"index":secIndex,"id":secId,"amount":secAmount},
				selectedAmount, primSum, secSum
			);
		}
	}

	function combineItems(primItem, secItem) {
		var primIndex = getSlotIndex(primItem);
		var primId = getSlotId(primItem);
		var primAmount = getSlotAmount(primItem);
		var secIndex = getSlotIndex(secItem);
		var secId = getSlotId(secItem);
		var secAmount = getSlotAmount(secItem);

		setSlotName(primItem, "");
		setSlotAmount(primItem, "");
		setSlotIcon(primItem, "");

		removeSlotId(primItem);
		setSlotPopulated(primItem, false);

		var secSum = primAmount + secAmount;
		setSlotAmount(secItem, secSum);

		if ( primItem.id.includes("player") && secItem.id.includes("player") ) {
			secure.player.combine(
				{"index":primIndex,"id":primId,"amount":primAmount},
				{"index":secIndex,"id":secId,"amount":secAmount},
				secSum
			);
		}
	}

	function splitItem(primItem, secItem) {
		var primId = getSlotId(primItem);
		var primIndex = getSlotIndex(primItem);
		var primAmount = getSlotAmount(primItem);
		var primName = getSlotName(primItem);
		var primIcon = getSlotIcon(primItem);

		var secId = getSlotId(secItem);
		var secIndex = getSlotIndex(secItem);
		var secAmount = getSlotAmount(secItem);

		var expectedAmount = primAmount - selectedAmount;
		setSlotAmount(primItem, expectedAmount);

		setSlotName(secItem, primName);
		setSlotAmount(secItem, selectedAmount);
		setSlotId(secItem, primId);
		setSlotIcon(secItem, primIcon)
		setSlotPopulated(secItem, true);


		if ( primItem.id.includes("player") && secItem.id.includes("player") ) {
			secure.player.split(
				{"index":primIndex,"id":primId,"amount":primAmount},
				{"index":secIndex,"amount":secAmount},
				selectedAmount, expectedAmount
			);
		}
	}


	function dragElement(dragItem) {
		var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
		var initiated = false;
		dragMouseDown(dragItem);
	  
		function dragMouseDown(e) {
			e = e || window.event;
			pos3 = e.clientX; 
			pos4 = e.clientY;
			document.onmouseup = closeDragElement;
			document.onmousemove = elementDrag;
		}
		
		function elementDrag(e) {
			if ( !initiated ) {
				dragItem.style.top = selectedItem.offsetTop - 10;
				dragItem.style.left = selectedItem.offsetLeft;
				$("#drag-item").show();

				initiated = true;
			}

			e = e || window.event;
			e.preventDefault();
			pos1 = pos3 - e.clientX;
			pos2 = pos4 - e.clientY;
			pos3 = e.clientX;
			pos4 = e.clientY;
			dragItem.style.top = (dragItem.offsetTop - pos2) + "px";
			dragItem.style.left = (dragItem.offsetLeft - pos1) + "px";
		}
		
		function closeDragElement(e) {
			if (initiated) { handleDrop(e.target.id); }
			$(dragItem).hide();
		  // stop moving when mouse button is released:
		  document.onmouseup = null;
		  document.onmousemove = null;
		}
	}

	  







	addInventorySlots(10, "player");
	addInventorySlots(10, "target");

	var testinv = {
		["1"] : {
			"item" : "pistol",
			"amount": 2,
		},
		["2"] : {},
		["3"] : {
			"item" : "pistol",
			"amount" : 1,
		},
		["4"] : {
			"item" : "hat",
			"amount" : 1,
		},
		["5"] : {
			"item" : "hat",
			"amount" : 1,
		},
		["6"] : {},
		["7"] : {},
		["8"] : {},
		["9"] : {},
		["10"] : {},
	};

	populateInventory(testinv, "player");

	window.addEventListener('message', function(event) {
		var ed = event.data;



	});
});