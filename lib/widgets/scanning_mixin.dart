import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/permissions_helper/ble_permissions_helper.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'multiple_callback_pop_scope.dart';

abstract class ScanningMixin {
  bool _onWillPop() {
    return true;
  }

  Future stopScan() async {
    await LighthouseProvider.instance.stopScan();
  }

  Future startScan(final Duration scanDuration,
      {final Duration? updateInterval, final bool clean = true}) async {
    try {
      await LighthouseProvider.instance.startScan(
          timeout: scanDuration, updateInterval: updateInterval, clean: clean);
    } catch (e, s) {
      debugPrint(
          "Error trying to start scan! ${e.toString()}\n${s.toString()}");
    }
  }

  Future startScanWithCheck(final Duration scanDuration,
      {final Duration? updateInterval,
      final String failMessage = "",
      final bool clean = true}) async {
    if (await BLEPermissionsHelper.hasBLEPermissions() ==
        PermissionStatus.granted) {
      await startScan(scanDuration,
          updateInterval: updateInterval, clean: clean);
    } else if (failMessage.isNotEmpty && !kReleaseMode) {
      debugPrint(failMessage);
    }
  }

  Future cleanUp() async => await LighthouseProvider.instance.cleanUp();

  Widget buildScanPopScope(
      {required final Widget child,
      final CanPop? beforeWillPop,
      final CanPop? afterWillPop}) {
    final canPopList = <CanPop>[];
    if (beforeWillPop != null) {
      canPopList.add(beforeWillPop);
    }
    canPopList.add(_onWillPop);
    if (afterWillPop != null) {
      canPopList.add(afterWillPop);
    }

    return MultipleCallbackPopScope(
      canPop: canPopList,
      child: child,
    );
  }
}
