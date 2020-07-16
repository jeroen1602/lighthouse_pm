package com.jeroen1602.lighthouse_pm

//import dev.flutter.plugins.e2e.E2EPlugin
import android.os.Bundle
import android.os.PersistableBundle
import com.pauldemarco.flutter_blue.FlutterBluePlugin
import io.flutter.app.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        FlutterBluePlugin.registerWith(registrarFor("com.pauldemarco.flutter_blue.FlutterBluePlugin"))
    }

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
//        E2EPlugin.registerWith(registrarFor("dev.flutter.plugins.e2e.E2EPlugin"))
    }

}
