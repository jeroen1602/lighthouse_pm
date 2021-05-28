import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lighthouse_pm/platformSpecific/shared/LocalPlatform.dart';

import 'inAppPurchases/InAppPurchaseItem.dart';

class InAppPurchases {
  InAppPurchases._() {
    // _channel.setMethodCallHandler((call) => {
    //
    // });
  }

  static InAppPurchases? _instance;

  static InAppPurchases get instance {
    if (!LocalPlatform.isAndroid) {
      debugPrint(
          "Creating an instance of in app purchases on a non Android platform!");
    }
    if (_instance == null) {
      _instance = InAppPurchases._();
    }
    return _instance!;
  }

  static const _channel =
      const MethodChannel("com.jeroen1602.lighthouse_pm/IAP");

  ///
  /// Request a [List] of [InAppPurchases] that are available.
  /// This only works on Android if the `googlePlay` flavor is used. This
  /// doesn't work if the flavor isn't correct.
  ///
  Future<List<InAppPurchaseItem>> requestPrices() async {
    if (!LocalPlatform.isAndroid) {
      if (!kReleaseMode) {
        throw UnsupportedError(
            "Can't get purchase items on a non Android platform");
      } else {
        return const [];
      }
    }
    final items = await _channel.invokeListMethod('requestPrices') ?? [];
    return items.map((e) {
      return InAppPurchaseItem.fromMap(e as Map<dynamic, dynamic>);
    }).toList()
      ..sort(_sortInAppPurchases);
  }

  ///
  /// Sort the [InAppPurchaseItem]s.
  ///
  int _sortInAppPurchases(InAppPurchaseItem a, InAppPurchaseItem b) {
    final aWithoutEuro = a.originalPrice
        .replaceAll("€", "")
        .replaceAll(".", "")
        .replaceAll(",", ".")
        .trim();
    final bWithoutEuro = b.originalPrice
        .replaceAll("€", "")
        .replaceAll(".", "")
        .replaceAll(",", ".")
        .trim();
    final aAsNumber = double.tryParse(aWithoutEuro);
    final bASNumber = double.tryParse(bWithoutEuro);
    return ((aAsNumber ?? 0.0) - (bASNumber ?? 0.0)).toInt();
  }

  ///
  /// Start a billing flow.
  ///
  /// Returns an int with the current billing state. -1 is user Canceled, 0 is
  /// success, 1 is still pending.
  ///
  Future<int> startBillingFlow(String id) async {
    if (!LocalPlatform.isAndroid) {
      if (!kReleaseMode) {
        throw UnsupportedError(
            "Can't get purchase items on a non Android platform");
      } else {
        return -1;
      }
    }
    final result =
        await _channel.invokeMethod("startBillingFlow", {"id": id}) as int;
    return result;
  }

  ///
  /// Go through the list of pending purchases and handle it.
  ///
  Future<void> handlePendingPurchases() async {
    if (!LocalPlatform.isAndroid) {
      if (!kReleaseMode) {
        throw UnsupportedError(
            "Can't get purchase items on a non Android platform");
      } else {
        return;
      }
    }
    await _channel.invokeMethod("handlePendingPurchases");
  }
}
