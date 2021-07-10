import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/permissionsHelper/BLEPermissionsHelper.dart';
import 'package:lighthouse_pm/platformSpecific/shared/LocalPlatform.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class ScanningMixin {
  Future<bool> _hasConnectedDevices() async =>
      ((await LighthouseProvider.instance.lighthouseDevices.first).length > 0);

  Future<bool> _onWillPop() async {
    // A little workaround for issue https://github.com/pauldemarco/flutter_blue/issues/649
    if (LocalPlatform.isAndroid) {
      if (await LighthouseProvider.instance.isScanning.first ||
          await _hasConnectedDevices()) {
        await LighthouseProvider.instance.cleanUp();
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
    return true;
  }

  Future stopScan() async {
    await LighthouseProvider.instance.stopScan();
  }

  Future startScan(Duration scanDuration, {Duration? updateInterval}) async {
    await LighthouseProvider.instance
        .startScan(timeout: scanDuration, updateInterval: updateInterval);
  }

  Future startScanWithCheck(Duration scanDuration,
      {Duration? updateInterval, String failMessage = ""}) async {
    if (await BLEPermissionsHelper.hasBLEPermissions() ==
        PermissionStatus.granted) {
      await startScan(scanDuration, updateInterval: updateInterval);
    } else if (failMessage.isNotEmpty && !kReleaseMode) {
      debugPrint(failMessage);
    }
  }

  Future cleanUp() async => await LighthouseProvider.instance.cleanUp();

  Widget buildScanPopScope(
      {required Widget child,
      WillPopCallback? beforeWillPop,
      WillPopCallback? afterWillPop}) {
    return WillPopScope(
      onWillPop: () async {
        if (beforeWillPop != null) {
          if (!await beforeWillPop()) {
            return false;
          }
        }
        if (!await _onWillPop()) {
          return false;
        }
        if (afterWillPop != null) {
          if (!await afterWillPop()) {
            return false;
          }
        }
        return true;
      },
      child: child,
    );
  }
}
