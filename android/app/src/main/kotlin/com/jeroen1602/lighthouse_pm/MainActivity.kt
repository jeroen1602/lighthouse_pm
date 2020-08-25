package com.jeroen1602.lighthouse_pm

import android.os.Bundle
import com.baseflow.permissionhandler.PermissionHandlerPlugin
import com.pauldemarco.flutter_blue.FlutterBluePlugin
import io.flutter.app.FlutterActivity
import io.flutter.plugins.packageinfo.PackageInfoPlugin

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        FlutterBluePlugin.registerWith(registrarFor("com.pauldemarco.flutter_blue.FlutterBluePlugin"))
        PackageInfoPlugin.registerWith(
                registrarFor("io.flutter.plugins.packageinfo.PackageInfoPlugin"))
        PermissionHandlerPlugin.registerWith(registrarFor("com.baseflow.permissionhandler.PermissionHandlerPlugin"))
    }

}
