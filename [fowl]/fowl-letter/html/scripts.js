var currentLetter = null;
var originalBody = null;

$(function () {

	document.onkeyup = function(data) {
        if(data.which == 27) { //esc
            exit();
        }
    }

    function exit() {
    	$.post("http://fowl-letter/exit", JSON.stringify({}));
    	$.post("http://fowl-postal/refocus", JSON.stringify({}));
        document.getElementById('letter-body-text').value= "";
        currentLetter = null;
        originalBody = null;
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

		if(ed.Letter === true) {
			showDiv("#letter");
			showDiv("#letter-controls")
			if(ed.mode === "read") {
				document.getElementById('letter-body-text').readOnly = true;
				hideDiv("#confirm-button")
				/*if(ed.recipient) {
					$('#letter-recipient').html("Dear " + ed.recipient + ",");
				} else {
					$('#letter-recipient').html("To whom it may concern,")
				}
				if(ed.sender) {
					$('#letter-sender').html(ed.sender);
				}
				*/
			} else if (ed.mode === "write") {
				document.getElementById('letter-body-text').readOnly = false;
				showDiv("#confirm-button")
			}

			if(ed.body) {
				originalBody = ed.body;
				document.getElementById('letter-body-text').value = (ed.body);
				AutoGrow(document.getElementById('letter-body-text'));
			}

			if (ed.letterid) {
				currentLetter = ed.letterid
			}
		} else if (ed.Letter === false) {
			hideDiv("#letter")
			hideDiv("#letter-controls")
		}
	});
});