$(function () {
	window.addEventListener('message', function(event) {
		var ed = event.data;

		if (ed.drawIcon === true) {
			$("#door-icon").show();
		} else if (ed.drawIcon === false) {
			$("#door-icon").hide();
		}

		if (ed.doorX) {
			document.getElementById("door-icon").style.left = (ed.doorX * 100).toFixed(2) + "%";
		}
		if (ed.doorY) {
			document.getElementById("door-icon").style.top = (ed.doorY * 100).toFixed(3) + "%";
		}

		if (ed.doorLocked === true) {
			document.getElementById("door-icon").style.backgroundImage = "url(ui/icon_locked.png)";
		} else if (ed.doorLocked === false) {
			document.getElementById("door-icon").style.backgroundImage = "url(ui/icon_unlocked.png)";
		}
	});
});