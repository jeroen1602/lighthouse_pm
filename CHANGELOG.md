# Version 1.0.2+4 RC

 - (Android) Close connection to open device on app close. 
 - Added a troubleshooting page.
 - Troubleshooting will also show up if no device have been found after the scan has finished.
 - (Android) Added smart troubleshooting item for location permissions.
 - (Android) Added smart troubleshooting item for bluetooth enabled.
 - Close open connection when switching to another page.
 - Close connection to discovering lighthouses on app close.
 - (Android) Hopefully fixed rare crash when closing app while scan is running.
 - Make sure no read is happening while writing.
 - BETA added support for Vive base stations.

# Version 1.0.1+3 2020-08-31

 - (Android) Fixed app crash on launch for Android < 7.0 (24). (#24)

# Version 1.0.0+2 2020-08-27

 - Fixed powerstate connection staying open on rescan.
 - Fixed powerstate connection staying open on app pause.
 - Added auto scan on app launch.
 - Added side drawer.
 - Added About page.
 - Added button to launch build-in licenses page.
 - Added privacy page.
 - Fixed not able to change powerstate if lightouse is stuck at 0x01 (starting).
 - Fixed lighthouse state button being obstructed by the scan button.
 - Added new app icon.
 - (Android) Added a dialog that shows to inform a user of the use of location permissions
 - Created Bluetooth not enabled screen.
 - (Android) added option to enable Bluetooth from the Bluetooth not enabled screen.
 - (Android) Added a workaround so the app doesn't crash if closed while scanning. Still waiting on (https://github.com/pauldemarco/flutter_blue/issues/649) for an actual fix.

# Version 0.0.1+1 2020-07-18

First release!

 - Added search lighthouses in local area.
 - Added live update of powerstate.
 - Added feature to change power-state.
 - Added page when bluetooth is disabled.
