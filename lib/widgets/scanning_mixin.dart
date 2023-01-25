import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/permissions_helper/ble_permissions_helper.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class ScanningMixin {
  Future<bool> _onWillPop() async {
    return true;
  }

  Future stopScan() async {
    await LighthouseProvider.instance.stopScan();
  }

  Future startScan(final Duration scanDuration,
      {final Duration? updateInterval}) async {
    try {
      await LighthouseProvider.instance
          .startScan(timeout: scanDuration, updateInterval: updateInterval);
    } catch (e, s) {
      debugPrint(
          "Error trying to start scan! ${e.toString()}\n${s.toString()}");
    }
  }

  Future startScanWithCheck(final Duration scanDuration,
      {final Duration? updateInterval, final String failMessage = ""}) async {
    if (await BLEPermissionsHelper.hasBLEPermissions() ==
        PermissionStatus.granted) {
      await startScan(scanDuration, updateInterval: updateInterval);
    } else if (failMessage.isNotEmpty && !kReleaseMode) {
      debugPrint(failMessage);
    }
  }

  Future cleanUp() async => await LighthouseProvider.instance.cleanUp();

  Widget buildScanPopScope(
      {required final Widget child,
      final WillPopCallback? beforeWillPop,
      final WillPopCallback? afterWillPop}) {
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
