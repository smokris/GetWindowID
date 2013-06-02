GetWindowID
===========

Mac OS X command line utility to retrieve the CGWindowID of the specified window (useful for screencapture).


## Usage

    ./GetWindowID <application-bundle-name> <window-title>

For example:

    ./GetWindowID "Vuo Editor" "untitled composition"

Or use it to capture a specific window:

	screencapture -l$(./GetWindowID "Vuo Editor" "untitled composition") VuoEditorWindow.png
