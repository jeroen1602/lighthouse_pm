package com.jeroen1602.lighthouse_pm

import android.bluetooth.BluetoothAdapter
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME).setMethodCallHandler {
            call, result ->
            when(call.method) {
                "openBLESettings" -> {
                    openBLESettings()
                    result.success(true)
                }
                "enableBluetooth" -> {
                    val bluetooth = enableBluetooth()
                    result.success(bluetooth)
                }
                else -> result.notImplemented()
            }
        }

    }

    private fun openBLESettings() {
        val intent = Intent()
        intent.action = android.provider.Settings.ACTION_BLUETOOTH_SETTINGS
        startActivity(intent)
    }
    
    private fun enableBluetooth(): Boolean {
        val adapter = BluetoothAdapter.getDefaultAdapter()
        if (!adapter.isEnabled) {
            return adapter.enable()
        }
        return false;
    }

    companion object {
        private const val CHANNEL_NAME = "com.jeroen1602.lighthouse_pm/bluetooth"
    }

}
