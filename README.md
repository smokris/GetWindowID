[![Build Status](https://travis-ci.org/smokris/GetWindowID.svg?branch=master)](https://travis-ci.org/smokris/GetWindowID)

GetWindowID
===========

macOS command line utility to retrieve the CGWindowID of the specified window (useful for screencapture).


## Usage

    ./GetWindowID <application-bundle-name> <window-title>

For example, to get the ID of the iOS/tvOS/watchOS Simulator:

    ./GetWindowID Simulator 'iPhone X - iOS 11.0'

…and to capture a screenshot of it:

    screencapture -l$(./GetWindowID Simulator 'iPhone X - iOS 11.0') simulator.png

To get the ID of a window without a title, pass an empty string as the title:

    ./GetWindowID GLFW ''

To list all of an app's windows, pass `--list` as the title:

    ./GetWindowID Simulator --list
