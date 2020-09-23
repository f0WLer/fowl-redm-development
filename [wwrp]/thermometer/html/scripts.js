$(function () {

	function adjustTemperature(temp) {
		temp = parseInt(temp);
		var degToPerc = 100/145*.95;

		var mercury = document.getElementById("mercury");
		var perc = Math.round(temp * degToPerc) + "%";
		mercury.style.height = (perc);
	}

	window.addEventListener('message', function(event) {
		var ed = event.data;

		if ( ed.adjustTemperature === true && ed.temp) {
			adjustTemperature(ed.temp);
		}

	});
});