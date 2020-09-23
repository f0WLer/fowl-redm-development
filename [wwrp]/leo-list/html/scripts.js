$(function () {
	
	var officerList = document.getElementById("officer-list");
	
	function addLEO(charId, firstName, lastName){
		if ( !document.getElementById("ply-"+charId) ){
			var officer = document.createElement('div');
			officer.id = "ply-"+charId;
			officer.classList.add("officer");
			officer.innerHTML = firstName + " " + lastName;
			
			officerList.appendChild(officer);
		}
	};
	function removeLEO(charId){
		var officer = document.getElementById("ply-"+charId);

		if (officer) {	
			officer.remove();
		}
	};

	function checkEmpty(){
		if ( officerList.childElementCount <= 1 ){
			$("#empty-text").show();
		} else {
			$("#empty-text").hide();
		}
	}

	checkEmpty();

	window.addEventListener('message', function(event) {
		var ed = event.data;

		if( ed.showLEO ) {
			$("#mainwrap").show();
		} else if ( ed.hideLEO ) {
			$("#mainwrap").hide();
		}

		if( ed.addLEO && ed.charId ) {
			addLEO(ed.charId, ed.firstName, ed.lastName);
		} else if ( ed.removeLEO && ed.charId ) {
			removeLEO(ed.charId);
		}

		checkEmpty();
	});
});