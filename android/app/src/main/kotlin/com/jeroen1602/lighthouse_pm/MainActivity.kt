package com.jeroen1602.lighthouse_pm

import android.bluetooth.BluetoothAdapter
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val shortcut: Shortcut by lazy { Shortcut() }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        shortcut.handleIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            when (call.method) {
                "openBLESettings" -> {
                    openBLESettings()
                    result.success(true)
                }
                "enableBluetooth" -> {
                    val bluetooth = enableBluetooth()
                    result.success(bluetooth)
                }
                "openLocationSettings" -> {
                    openLocationSettings()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
        shortcut.init(flutterEngine, this, intent)

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

    private fun openLocationSettings() {
        val intent = Intent()
        intent.action = android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS
        startActivity(intent)
    }

    companion object {
        private const val CHANNEL_NAME = "com.jeroen1602.lighthouse_pm/bluetooth"
        private const val TAG = "lighthouseMainActivity"
    }

}
