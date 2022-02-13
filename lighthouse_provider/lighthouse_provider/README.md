# Lighthouse provider

A provider that can provide lighthouses.

It will not work out of the box.

 - It needs a back end that works on the platform.
 - It needs a specific provider for the device type.

## Adding the back end

```dart
LighthouseProvider.instance.addBackEnd(backEnd);
```

## Adding the provider

```dart
LighthouseProvider.instance.addProvider(provider);
```

## Start scan

```dart
// A stream of the devices found.
LighthouseProvider.instance.lighthouseDevices;

LighthouseProvider.instance.startScan(timeout: Duration(seconds: 5));
```
