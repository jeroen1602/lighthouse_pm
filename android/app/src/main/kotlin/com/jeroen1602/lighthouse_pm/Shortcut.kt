package com.jeroen1602.lighthouse_pm

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.*
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.Icon
import android.os.Build
import android.util.Log
import androidx.annotation.ColorInt
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest
import kotlin.math.pow
import kotlin.math.roundToInt

/**
 * A class for handling the shortcut requests made by the platform.
 */
class Shortcut {

    private lateinit var methodChannel: MethodChannel
    private lateinit var context: Context
    private val dataQue: MutableList<QueData> = ArrayDeque()
    private var initialized = false

    private val shortcutManager: ShortcutManager? by lazy {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
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
            var found = false
            for (handler in InMethods.values()) {
                if (handler.functionName == call.method) {
                    found = true
                    handler.handlerFunction(this, call, result)
                    break
                }
            }
            if (!found) {
                result.notImplemented()
            }
        }
        handleIntent(intent)
    }

    /**
     * Check if the [shortcutManager] is not null and if it is return an error to the invoker.
     *
     * @return will return `false` if the [shortcutManager] is `null` and `true` if it is not.
     */
    private fun hasManager(result: MethodChannel.Result?): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
            return false
        }
        if (shortcutManager == null) {
            result?.error(
                "${ErrorCodes.SHORTCUT_NOT_SUPPORTED.ordinal}",
                "ShortcutManager is not available on this device",
                NullPointerException("ShortcutManager is null")
            )
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
    private fun isRequestPinShortcutSupported(result: MethodChannel.Result?): Boolean {
        if (!hasManager(result)) {
            return false
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
            !shortcutManager!!.isRequestPinShortcutSupported
        ) {
            result?.error(
                "${ErrorCodes.PIN_SHORTCUT_NOT_SUPPORTED.ordinal}",
                "Shortcut pin request is not supported on this device!",
                null
            )
            return false
        }
        return true
    }

    /**
     * Use the [isRequestPinShortcutSupported] method to check if pin shortcuts are supported, but
     * instead of throwing an error just return the `true`/ `false` as a result.
     */
    private fun supportsShortcut(call: MethodCall, result: MethodChannel.Result) {
        result.success(isRequestPinShortcutSupported(null))
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

        // Create an intent to launch the main activity with some extra data.
        val intent = Intent(context, MainActivity::class.java).apply {
            putExtra(TOGGLE_EXTRA, action)
            setAction(Intent.ACTION_MAIN)
        }

        // Create the shortcut icon
        val foreground =
            context.resources.getDrawable(R.drawable.ic_launcher_foreground, context.theme)
        foreground.setTint(stringToGradientColor(action))
        val background =
            context.resources.getDrawable(R.drawable.ic_launcher_background, context.theme)
        background.setTint(Color.WHITE)
        val adaptiveIconDrawable = AdaptiveIconDrawable(background, foreground)

        val bitmap = drawableToBitmap(adaptiveIconDrawable, context)
        val icon = Icon.createWithAdaptiveBitmap(bitmap)
        // Create the shortcut info.
        val pinShortcutInfo = ShortcutInfo.Builder(context, action)
            .setShortLabel(name ?: "null")
            .setLongLabel("Change ${name ?: "null"}")
            .setIcon(icon)
            .setIntent(intent)
            .build()

        shortcutManager!!.requestPinShortcut(
            pinShortcutInfo,
            null
        )

        // TODO: handle the success callback
        result.success(true)
        bitmap.recycle()
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
            val data = dataQue.removeAt(0)
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

    /**
     * Convert a string into a color somewhere on a gradient. The gradient used is the one used for
     * the app theme.
     */
    @ColorInt
    private fun stringToGradientColor(string: String?): Int {
        // Because I didn't feel like finding a gradient implementation I decide to use the included
        // gradient implementation from Android.

        // Create a bitmap
        val bitmap = Bitmap.createBitmap(GRADIENT_RESOLUTION, 1, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint()
        val gradient = LinearGradient(
            0f, 0f, bitmap.width.toFloat(), 0f,
            intArrayOf(
                Color.rgb(0xFF, 0x5A, 0x66),
                Color.rgb(0xA5, 0x00, 0xFB),
                Color.rgb(0x0E, 0x8B, 0xFF),
                Color.rgb(0x00, 0xDF, 0xAB),
            ),
            floatArrayOf(
                0f,
                0.3315374f,
                0.6444612f,
                1f
            ),
            Shader.TileMode.CLAMP
        )
        paint.shader = gradient
        // Draw the gradient inside of the bitmap.
        canvas.drawPaint(paint)

        // Pick a color from the bitmap (that now contains the gradient) based on the hash.

        var hash: Int = if (string != null) {
            // convert the input string to an index in the gradient.
            (md5ToNumber(string) % bitmap.width).toInt()
        } else {
            // string is null so just take a random position.
            (Math.random() * (bitmap.width - 1)).toInt()
        }
        if (hash < 0) {
            hash += bitmap.width
        }
        val color = bitmap.getPixel(hash, 0)
        // Cleanup
        bitmap.recycle()

        return color
    }

    /**
     * Convert a string to a md5 digest but storing it all into a single number.
     */
    private fun md5ToNumber(string: String): Long {
        // md5 is a hashing algorithm that shouldn't be used anymore. But because I only want to
        // create a summary (hash) of a string that won't be used for security and I don't want the
        // result to be counting up (what hashcode would do) I think it is ok.
        val md = MessageDigest.getInstance("MD5")
        md.update(string.toByteArray())
        val digest = md.digest()
        // Compress the digest into a single number.
        var counter: Long = 0
        for ((index, item) in digest.withIndex()) {
            counter = ((item * 2.0.pow(index).toLong()) + counter)
        }
        return counter
    }

    /**
     * Create a bitmap from an adaptive icon drawable.
     */
    @RequiresApi(Build.VERSION_CODES.O)
    private fun drawableToBitmap(drawable: AdaptiveIconDrawable, context: Context): Bitmap {
        val screenDensity = context.resources.displayMetrics.density
        val adaptiveIconOuterSides = (ADAPTIVE_ICON_OUTER_SIDES_DP * screenDensity).roundToInt()
        val bitmap = Bitmap.createBitmap(
            adaptiveIconOuterSides,
            adaptiveIconOuterSides,
            Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(bitmap)
        drawable.background.setBounds(0, 0, adaptiveIconOuterSides, adaptiveIconOuterSides)
        drawable.background.draw(canvas)
        drawable.foreground.setBounds(0, 0, adaptiveIconOuterSides, adaptiveIconOuterSides)
        drawable.foreground.draw(canvas)
        return bitmap
    }

    companion object {
        private const val SHORTCUT_ID = "com.jeroen1602.lighthouse_pm/shortcut"
        private const val TOGGLE_EXTRA = "com.jeroen1602.lighthouse_pm.shortcut.toggleExtra"
        private const val TOGGLE_HANDLED = "com.jeroen1602.lighthouse_pm.shortcut.toggleHandled"
        private const val TAG = "Shortcut handler"

        private const val ADAPTIVE_ICON_OUTER_SIDES_DP = 108
        private const val GRADIENT_RESOLUTION = 100

        enum class ErrorCodes {
            SHORTCUT_NOT_SUPPORTED,
            PIN_SHORTCUT_NOT_SUPPORTED
        }

        private enum class OutMethods(val functionName: String) {
            HANDLE_MAC_SHORTCUT("handleMacShortcut");
        }

        private enum class InMethods(
            val functionName: String,
            val handlerFunction: (Shortcut, MethodCall, MethodChannel.Result) -> Unit
        ) {
            REQUEST_SHORTCUT("requestShortcut", Shortcut::requestShortcut),
            READY_FOR_DATA("readyForData", Shortcut::handleReadyForData),
            SUPPORTS_SHORTCUT("supportShortcut", Shortcut::supportsShortcut)
        }

        private data class QueData(val methodName: String, val data: Any?)
    }

}
