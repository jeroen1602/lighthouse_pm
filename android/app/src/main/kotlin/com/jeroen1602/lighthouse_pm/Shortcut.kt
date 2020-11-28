package com.jeroen1602.lighthouse_pm

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * A class for handling the shortcut requests made by the platform.
 */
class Shortcut {

    private lateinit var methodChannel: MethodChannel
    private lateinit var context: Context
    private val dataQue: MutableList<QueData> = ArrayDeque()
    private var initialized = false
    private val shortcutManager: ShortcutManager? by lazy {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N_MR1) {
            context.getSystemService(ShortcutManager::class.java)
        } else {
            null
        }
    }

    /**
     * Initialize the shortcut handler. This should be called at the
     * [FlutterActivity.configureFlutterEngine] call.
     *
     * @param flutterEngine The flutter engine for registering the method channel.
     * @param context The context of the app.
     * @param intent The intent that may contain a [Shortcut.TOGGLE_EXTRA] extra.
     */
    fun init(flutterEngine: FlutterEngine, context: Context, intent: Intent) {
        this.initialized = false
        this.context = context
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHORTCUT_ID)
        methodChannel.setMethodCallHandler { call, result ->
            for (handler in InMethods.values()) {
                if (handler.functionName == call.method) {
                    handler.handlerFunction(this, call, result)
                    break
                }
            }
        }
        handleIntent(intent)
    }

    /**
     * Check if the [shortcutManager] is not null and if it is return an error to the invoker.
     *
     * @return will return `false` if the [shortcutManager] is `null` and `true` if it is not.
     */
    private fun hasManager(result: MethodChannel.Result): Boolean {
        if (shortcutManager == null) {
            result.error("${ErrorCodes.SHORTCUT_NOT_SUPPORTED.ordinal}",
                    "ShortcutManager is not available on this device",
                    NullPointerException("ShortcutManager is null"))
            return false
        }
        return true
    }

    /**
     * Check if pin shortcut is supported on the current platform. This required Android O (26) or
     * higher. Will also check [hasManager].
     * Will return an error to the invoker if this is not the case.
     *
     * @return will return `false` if the [shortcutManager] is `null` or the Android version is
     * lower than O (26) otherwise it will return `true`.
     */
    private fun isRequestPinShortcutSupported(result: MethodChannel.Result): Boolean {
        if (!hasManager(result)) {
            return false
        }
        if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.O ||
                !shortcutManager!!.isRequestPinShortcutSupported) {
            result.error("${ErrorCodes.PIN_SHORTCUT_NOT_SUPPORTED.ordinal}",
                    "Shortcut pin request is not supported on this device!",
                    null)
            return false
        }
        return true
    }

    /**
     * Handle the request shortcut native method.
     * Most check are debug only since these should never happen in production code.
     */
    @SuppressLint("NewApi")
    private fun requestShortcut(call: MethodCall, result: MethodChannel.Result) {
        if (!isRequestPinShortcutSupported(result)) {
            return
        }
        val action = call.argument<String>("action")
        if (BuildConfig.DEBUG && action == null) {
            error("Action was null!")
        }
        if (BuildConfig.DEBUG && !action!!.startsWith("mac/")) {
            error("Only mac address actions are supported for now!")
        }
        val name = call.argument<String>("name")
        if (BuildConfig.DEBUG && name.isNullOrBlank()) {
            error("Name was null or empty!")
        }

        // Create an intent to launch the main function with some extra data.
        val intent = Intent(context, MainActivity::class.java).apply {
            putExtra(TOGGLE_EXTRA, action)
            setAction(Intent.ACTION_MAIN)
        }

        // Create the shortcut info
        // TODO: add an icon.
        val pinShortcutInfo = ShortcutInfo.Builder(context, action)
                .setShortLabel(name ?: "null")
                .setLongLabel("Change ${name ?: "null"}")
                .setIntent(intent)
                .build()

        // Create the PendingIntent object only if your app needs to be notified
        // that the user allowed the shortcut to be pinned. Note that, if the
        // pinning operation fails, your app isn't notified. We assume here that the
        // app has implemented a method called createShortcutResultIntent() that
        // returns a broadcast intent.
        val pinnedShortcutCallbackIntent = shortcutManager!!.createShortcutResultIntent(pinShortcutInfo)

        // Configure the intent so that your app's broadcast receiver gets
        // the callback successfully.For details, see PendingIntent.getBroadcast().
        val successCallback = PendingIntent.getBroadcast(context, /* request code */ 0,
                pinnedShortcutCallbackIntent, /* flags */ 0)

        shortcutManager!!.requestPinShortcut(pinShortcutInfo,
                successCallback.intentSender)

        // TODO: handle the success callback
        result.success(true)
    }

    /**
     * Handler for read for data callback.
     * This will mark the shortcut method as read and invoke the methods that have been queued while
     * the Flutter app wasn't ready yet.
     */
    private fun handleReadyForData(call: MethodCall, result: MethodChannel.Result) {
        this.initialized = true
        result.success(null)
        // Fire the earlier recorded queued methods
        while (dataQue.isNotEmpty()) {
            val data = dataQue.removeFirst()
            invokeMethod(data.methodName, data.data)
        }
    }

    /**
     * Handle a (new) intent extra for this intent.
     */
    fun handleIntent(intent: Intent) {
        intent.getStringExtra(TOGGLE_EXTRA)?.run {
            if (intent.getStringExtra(TOGGLE_HANDLED) != this) {
                handleShortcut(this)
            }
        }
    }

    /**
     * Handle the shortcut launch intent.
     */
    private fun handleShortcut(action: String) {
        if (action.startsWith("mac/")) {
            handleMacShortcut(action.replace("mac/", ""))
        } else {
            if (BuildConfig.DEBUG) {
                error("Action didn't start with a supported prefix. Was (${action})")
            } else {
                Log.w(TAG, "No handler found for $action")
            }
        }
    }

    /**
     * Handle the mac address shortcut action.
     */
    private fun handleMacShortcut(mac: String) {
        invokeMethod(OutMethods.HANDLE_MAC_SHORTCUT.functionName, mac)
    }

    /**
     * Invoke a method in via the [methodChannel]. This will add the call to the [dataQue] to be
     * invoked later once the [handleReadyForData] method is called from the Flutter app.
     */
    private fun invokeMethod(methodName: String, data: Any?) {
        if (initialized) {
            methodChannel?.invokeMethod(methodName, data)
        } else {
            this.dataQue.add(QueData(methodName, data))
        }
    }

    companion object {
        private const val SHORTCUT_ID = "com.jeroen1602.lighthouse_pm/shortcut"
        private const val TOGGLE_EXTRA = "com.jeroen1602.lighthouse_pm.shortcut.toggleExtra"
        private const val TOGGLE_HANDLED = "com.jeroen1602.lighthouse_pm.shortcut.toggleHandled"
        private const val TAG = "Shortcut handler"

        enum class ErrorCodes {
            SHORTCUT_NOT_SUPPORTED,
            PIN_SHORTCUT_NOT_SUPPORTED
        }

        private enum class OutMethods(val functionName: String) {
            HANDLE_MAC_SHORTCUT("handleMacShortcut");
        }

        private enum class InMethods(val functionName: String, val handlerFunction: (Shortcut, MethodCall, MethodChannel.Result) -> Unit) {
            REQUEST_SHORTCUT("requestShortcut", Shortcut::requestShortcut),
            READY_FOR_DATA("readyForData", Shortcut::handleReadyForData)
        }

        private data class QueData(val methodName: String, val data: Any?)
    }

}