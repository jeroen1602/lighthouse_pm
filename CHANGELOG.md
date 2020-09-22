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
 - (iOS) Changed app icon (is the same as Android app icon now).
 - (iOS) Changed display name ("lighthouse_pm" -> "Lighthouse PM").
 - Added a dialog for changing the state when the state is unknown.
 - Added lighthouse metadata page on long press power button.
 - Added helping out dialog to the unknown power state dialog.
 - Added the ability to nickname lighthouses.
 - Added settings page.
 - Added channel to metadata page.
 - Renamed Standby to Sleep, just like the steamVR program.
 - Added identify device extension to metadata page.
 - Added standby (motors on, laser off) state extension to metadata page.

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
 - Fixed not able to change powerstate if lighthouse is stuck at 0x01 (starting).
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
