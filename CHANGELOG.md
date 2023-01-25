# Version 1.3.0+9 R.C

- (Android + iOS) Changed back end to flutter reactive ble which still gets updates.
- Enabled Vive base stations by default.
- Removed wording for Vive base station beta.
- Updated to material 3 (not all widgets have been updated yet).
- (Linux + Android 13) Added dynamic colors.
- Updated some widgets to use different colors.
- (Web) added alt + R keyboard shortcut for rescanning devices.
- (Desktop) Added F5, ctrl + R, super/ cmd + R keyboard shortcut for rescanning devices.
- Calling disconnect if state could not be retrieved.
- (Linux) Added basic support for a linux version.
- (Web) Fixed bug where devices would show inside the group and outside the group.
- Vive base station ids are now bound to the device id instead to the device name.
  This way everyone can store whatever id without restrictions, fixing the bug for some people.
  This has the effect that all stored ids are now gone (sorry about that).
- (Web) Added more info to the Bluetooth adapter unavailable.
- (Web) Added 404 page not found.
- (Web) Added support for web.
- (Web) Added Flutter web Bluetooth back end for the web.
- (Web) Change pages based on the screen size.
- (Web) Changed wording in troubleshooting page if viewed from teh web.
- Fixed bug where devices could show up twice, mostly web and development will notice this change.
- Added pair button if the back end requires it, this change is only web for now.
- (iOS) Added Bluetooth request key.

# Version 1.2.0+8 14-04-2021

- Updated flutter, now with null safety.
- Updated dependencies.
- (Android) BETA added shortcut (Android 8.0+ (Oreo api 26)).
- Removed unused fonts (-0.6MB save).
- (Debug only )Added database test for debugging.
- Standardized dialog button order (sorry for the inconvenience).
- Added the ability to group devices.
- Added option for changing update interval.

# Version 1.1.2+7 23-02-2021

- (iOS) Fixed automatic detection of "System Theme" availability.
- Open metadata page by tapping on lighthouse instead of holding power button (holding the power
  button still works).
- Added support for F-droid.
- Updated dependencies.

# Version 1.1.1+6 02-10-2020

- Added mutex to back end so no device shows up twice.
- Fixed dialog theme not showing in light mode.
- Reverted Vive Base station report back to UNKNOWN, still needs some research before this works.
- Added help page.
- Changed drawer header image.

# Version 1.1.0+5 30-09-2020

- (Android) Fixed app including too many ABI's in the app bundle. This is a play store only release
  since nothing has changed for the APK releases. (hence the version name not increasing).

# Version 1.1.0+4 30-09-2020

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
- Added a setting to use standby instead of sleep by default.
- Added sleep state extension to metadata page.
- Added on state extension to metadata page.
- Added a standby option to the unknown state dialog.
- Added Dark Theme using OS theme (android 10+, iOS 13+)
- Added a lighthouseBackend for more lighthouse types in the future.
- BETA added support for Vive base stations.
- Added scan duration option.
- (Android) Fixed urls not opening on Android 11.
- Added an option to settings for selecting the preferred theme.

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
- (Android) Added a workaround so the app doesn't crash if closed while scanning. Still waiting
  on (https://github.com/pauldemarco/flutter_blue/issues/649) for an actual fix.

# Version 0.0.1+1 2020-07-18

First release!

- Added search lighthouses in local area.
- Added live update of powerstate.
- Added feature to change power-state.
- Added page when bluetooth is disabled.
