package com.jeroen1602.lighthouse_pm

import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Native part to handle in app purchases, but not supported. All functions will fail.
 */
class InAppPurchases {

    private lateinit var methodChannel: MethodChannel

    fun init(flutterEngine: FlutterEngine, context: Activity) {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, IAP_ID)
        methodChannel.setMethodCallHandler { call, result ->
            result.error("99", "IAP not implemented, try switching Android flavors!", null)
        }
    }


    companion object {
        private const val IAP_ID = "com.jeroen1602.lighthouse_pm/IAP"

        val instance: InAppPurchases by lazy { InAppPurchases() }
    }

}