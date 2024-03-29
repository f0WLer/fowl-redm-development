# fowl-redm-development
Various resources I have created while learning to script in RedM

## fowl-login

####	[Demo](https://streamable.com/3cvc32)

####  Description
		- Greets users with a welcome screen.

		- Character selection fetches the user's registered characters from the db.
		- Character info (Name, date of birth, gender, etc.) fetched along with the character ids (max characters limited to 5).
		- Character info windows are populated dynamically. The info to be displayed can be easily chosen and added within the scripts.js file.
		- Users can create new characters from this screen, fill in basic info, and their character will be added to the db via the server script.
		- Upon choosing the desired character, the user is securely logged into that character. The server script quickly references the database to ensure the user owns that character, and communicates with the client script to select that character id.
		- The Character.lua file can be added as a client/server script on other resources. This can be used to await the defining of the variable 'charid', and after defining, continue and fetch character-specific info from the db such as clothing, owned horses, inventory, etc.

		- After selecting a character, the user selects their spawn via waypoints on the map. Spawn locations can easily be added.
		- The user has an overview of the spawn and can either confirm their spawn or go back to the spawn selection.
----------

## fowl-doors

####	[Demo](https://streamable.com/2ze1gk)

####  Description
		- Off by default, can be toggled on/off with '['.
		- On/off status indicated by a key icon on the bottom left of the screen.

		- When within a certain range of a door (this can be configured in config.lua), a prompt to lock/unlock the door will pop up.
		- When in range of the door, a locked/unlocked icon will display on the door near the handle.
		- If two doors are within a certain range of each other (range is configurable), both doors will be triggered. The user can select between these two doors with the press of a key.
		- As long as the player is in a certain range of either doors (range is configurable), the door and any neighboring doors can be locked/unlocked/switched between.

		- This can easily be accompanied by a key script, prohibiting the users without the key to a door from being able to lock/unlock it.
----------

## fowl-postal and fowl-letter

####	[Demo](https://streamable.com/bnjgai)

####	Description
		- Players can go to one of the many post offices (these can be added/removed easily) and access their P.O. box.

		- Letters can be written, edited, or tossed from the post office.
		- Letters can be mailed to other players' P.O. boxes. Mail is delivered every day at 8am.
		- Script can be easily configured to make letters sit for a certain number of days before they are received by the other player.
		- Letters can be assigned a custom address/return address on the front. This gives the option for players to choose to send mail as an individual, as a company/department of a government/or anonymously.
----------
