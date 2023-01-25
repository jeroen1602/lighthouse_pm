package com.jeroen1602.lighthouse_pm

import android.util.Log
import com.polidea.rxandroidble2.exceptions.BleException
import io.flutter.app.FlutterApplication
import io.reactivex.exceptions.UndeliverableException
import io.reactivex.plugins.RxJavaPlugins

class LighthousePMApplication : FlutterApplication() {


    override fun onCreate() {
        super.onCreate()
        RxJavaPlugins.setErrorHandler { throwable ->
            if (throwable is UndeliverableException && throwable.cause is BleException) {
                Log.v("LighthousePM", "Suppressed UndeliverableException: ${throwable.toString()}");
                return@setErrorHandler // ignore BleExceptions since we do not have subscriber
            } else {
                throw java.lang.RuntimeException(
                    "Unexpected Throwable in RxJavaPlugins error handler",
                    throwable
                );
            }
        }
    }
}
