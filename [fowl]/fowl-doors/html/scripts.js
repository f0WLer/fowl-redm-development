$(function () {

	document.onkeyup = function(data) {
        if(data.which == 27) { //esc
            //exit();
        }
    }

    function exit() {

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


		if(ed.DrawHTML === true) {
			showDiv("#mainwrap");
		}

		if(ed.DrawHTML === false) {
			hideDiv("#mainwrap");
		}

		if(ed.container) {
			if(ed.show === true) {
				showDiv(ed.container)
			}
			if(ed.show === false) {
				hideDiv(ed.container)
			}
		}
	});
});