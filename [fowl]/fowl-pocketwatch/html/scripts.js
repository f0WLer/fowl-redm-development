function updateHands(hour, minute){
	if(hour){
		var hourDeg = hour * 30;
		var hourHand = document.getElementById("hour-hand");
		if(minute){
			var minuteDeg = minute * 6;
			var minuteHand = document.getElementById("minute-hand");
			minuteHand.style.transform = "rotate("+minuteDeg+"deg)";

			hourDeg = hourDeg + (minute/2);
		}
		hourHand.style.transform = "rotate("+hourDeg+"deg)";
	}
}

function progressSeconds(seconds){
	var secondHand = document.getElementById("second-hand");
	var sr = window.getComputedStyle(secondHand, null);
	var currentAngle = sr.getPropertyValue("transform");

	var values = currentAngle.split('(')[1],
    values = values.split(')')[0],
    values = values.split(',');
	var a = values[0];
	var b = values[1];
	var c = values[2]; 
	var d = values[3];
	var angle = Math.round(Math.atan2(b, a) * (180/Math.PI));

	var newAngle = angle + (seconds * 6);

	secondHand.style.transform = "rotate(" + newAngle + "deg)";
}

function resetSeconds(){
	var secondHand = document.getElementById("second-hand");
	secondHand.style.transform = "rotate(0deg)"
}

$(function () {

	window.addEventListener('message', function(event) {
		var ed = event.data;


		if(ed.DrawHTML === true) {
			$("#mainwrap").show();
		}

		if(ed.DrawHTML === false) {
			$("#mainwrap").hide();
		}

		if(ed.updateWatch === true) {
			var hour;
			var minute;
			if(ed.watchHour != null) {
				hour = ed.watchHour;
			}
			if(ed.watchMinute != null) {
				minute = ed.watchMinute;
			}
			updateHands(hour, minute);
		}

		if(ed.progressSeconds === true){
			if(ed.seconds != null) {
				progressSeconds(ed.seconds);
			}
		}

		if(ed.resetSeconds === true){
			resetSeconds();
		}

	});

});