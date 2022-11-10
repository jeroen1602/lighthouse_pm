import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_platform/shared_platform.dart';

import 'in_app_purchases/in_app_purchase_item.dart';

class InAppPurchases {
  InAppPurchases._() {
    // _channel.setMethodCallHandler((call) => {
    //
    // });
  }

  static InAppPurchases? _instance;

  static InAppPurchases get instance {
    if (!SharedPlatform.isAndroid) {
      debugPrint(
          "Creating an instance of in app purchases on a non Android platform!");
    }
    return _instance ??= InAppPurchases._();
  }

  static const _channel = MethodChannel("com.jeroen1602.lighthouse_pm/IAP");

  ///
  /// Request a [List] of [InAppPurchases] that are available.
  /// This only works on Android if the `googlePlay` flavor is used. This
  /// doesn't work if the flavor isn't correct.
  ///
  Future<List<InAppPurchaseItem>> requestPrices() async {
    if (!SharedPlatform.isAndroid) {
      if (!kReleaseMode) {
        throw UnsupportedError(
            "Can't get purchase items on a non Android platform");
      } else {
        return const [];
      }
    }
    final items = await _channel.invokeListMethod('requestPrices') ?? [];
    return items.map((final e) {
      return InAppPurchaseItem.fromMap(e as Map<dynamic, dynamic>);
    }).toList()
      ..sort(_sortInAppPurchases);
  }

  ///
  /// Sort the [InAppPurchaseItem]s.
  ///
  int _sortInAppPurchases(
      final InAppPurchaseItem a, final InAppPurchaseItem b) {
    return a.priceMicros.compareTo(b.priceMicros);
  }

  ///
  /// Start a billing flow.
  ///
  /// Returns an int with the current billing state. -1 is user Canceled, 0 is
  /// success, 1 is still pending.
  ///
  Future<int> startBillingFlow(final String id) async {
    if (!SharedPlatform.isAndroid) {
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
    if (!SharedPlatform.isAndroid) {
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
