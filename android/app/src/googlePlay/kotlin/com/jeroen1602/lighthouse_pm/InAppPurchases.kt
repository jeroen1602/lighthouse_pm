package com.jeroen1602.lighthouse_pm

import android.app.Activity
import android.util.Log
import com.android.billingclient.api.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.util.*
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine
import kotlin.reflect.KSuspendFunction3

/**
 * Native part to handle in app purchases
 */
class InAppPurchases {

    private lateinit var methodChannel: MethodChannel
    private lateinit var billingClient: BillingClient
    private lateinit var activity: Activity
    private val pendingResults: MutableList<MethodChannel.Result> =
        emptyList<MethodChannel.Result>().toMutableList()

    /**
     * Initialize the InAppPurchases Flutter method channel
     *
     * @param flutterEngine The flutter engine.
     * @param activity The activity that the init is being called from.
     */
    fun init(flutterEngine: FlutterEngine, activity: Activity) {
        this.activity = activity

        billingClient = BillingClient.newBuilder(activity)
            .enablePendingPurchases()
            .setListener { billingResult, purchases ->
                CoroutineScope(Dispatchers.IO).launch {
                    val results = handlePurchases(billingResult, purchases)
                    results.forEach {
                        withContext(Dispatchers.Main) {
                            pendingResults.takeIf { it.isNotEmpty() }?.removeAt(0)?.success(it)
                        }
                    }
                }
            }
            .enablePendingPurchases()
            .build()

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, IAP_ID)
        methodChannel.setMethodCallHandler { call, result ->
            var found = false
            for (handler in InMethods.values()) {
                if (handler.functionName == call.method) {
                    found = true
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            handler.handlerFunction(this@InAppPurchases, call, result)
                        } catch (error: Throwable) {
                            withContext(Dispatchers.Main) {
                                try {
                                    result.error(
                                        "${ErrorCodes.OTHER_ERROR.ordinal}",
                                        error.toString(),
                                        error
                                    )
                                } catch (err: IllegalStateException) {
                                    // TooBad
                                    Log.e(
                                        TAG,
                                        "There was an error that could not be reported!",
                                        error
                                    )
                                }
                            }
                        }
                    }
                    break
                }
            }
            if (!found) {
                result.notImplemented()
            }
        }
    }

    /**
     * Ensure that the billing client is connected before doing other operations.
     *
     * @return A [Pair] with a [Boolean] if the client is currently online, and a [String] for the
     * reason it is currently offline (if it is offline).
     */
    private suspend fun ensureBillingClientConnected(): Pair<Boolean, String?> {
        if (billingClient.isReady) {
            return Pair(true, null)
        }
        return withContext(Dispatchers.IO) {
            suspendCoroutine { cont ->
                billingClient.startConnection(object : BillingClientStateListener {
                    override fun onBillingSetupFinished(billingResult: BillingResult) {
                        if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                            cont.resume(Pair(true, null))
                        } else {
                            Log.e(TAG, "Could not connect because: ${billingResult.debugMessage}")
                            cont.resume(Pair(false, billingResult.debugMessage))
                        }
                    }

                    override fun onBillingServiceDisconnected() {
                        Log.w(TAG, "onBillingServiceDisconnected: No longer online!")
                    }
                })
            }
        }
    }

    /**
     * Request the current available IAP items and their prices.
     *
     * @param call the Flutter [MethodCall] this is ignored.
     * @param result the Flutter [MethodChannel.Result] that will be called for the result.
     */
    private suspend fun requestPrices(call: MethodCall, result: MethodChannel.Result) {
        val connected = ensureBillingClientConnected()
        if (!connected.first) {
            withContext(Dispatchers.Main) {
                result.error(
                    "${ErrorCodes.COULD_NOT_CONNECT.ordinal}",
                    "Could not connect to the billing client",
                    connected.second
                )
            }
            return
        }
        val skus = querySkuDetails();
        if (skus == null || skus.isEmpty()) {
            withContext(Dispatchers.Main) {
                result.success(emptyList<Unit>())
            }
            return
        }
        // Convert skus
        withContext(Dispatchers.Main) {
            result.success(skusToJson(skus))
        }
    }

    /**
     * Convert a [SkuDetails] to a [Map] with [String] keys and [Any] values for sending through
     * a Flutter [MethodChannel]
     *
     * @param sku The [SkuDetails] to convert.
     * @return A [Map] with the needed keys and values.
     * @see skusToJson
     */
    private fun skuToJson(sku: SkuDetails): Map<String, Any> {
        return mapOf(
            Pair("price", sku.price),
            Pair("id", sku.sku),
            Pair("title", sku.description),
            Pair("originalPrice", sku.originalPrice),
            // TODO: bought info?
        )
    }

    /**
     * Convert a [List] of [SkuDetails] to a [List] of [Map] for sending over a Flutter
     * [MethodChannel]
     *
     * @param skus The [List] of [SkuDetails] to convert.
     * @return A [List] of [Map]s with the needed keys and values.
     * @see skuToJson
     */
    private fun skusToJson(skus: List<SkuDetails>): List<Map<String, Any>> {
        return skus.map { skuToJson(it) }
    }

    /**
     * Query a [List] of [SkuDetails] with all the skus available to this app.
     *
     * @return A [List] of [SkuDetails] if nothing went wrong, else `null`.
     */
    private suspend fun querySkuDetails(): List<SkuDetails>? {
        val skuDetailsResult = withContext(Dispatchers.IO) {
            billingClient.querySkuDetails(SKU_DETAILS)
        }

        if (skuDetailsResult.billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
            Log.e(
                TAG,
                "Could not get SKU details because: ${skuDetailsResult.billingResult.debugMessage}"
            )
            return null;
        }
        return skuDetailsResult.skuDetailsList
    }

    /**
     * Query a single [SkuDetails] based on it's unique id.
     *
     * @param skuId The id of the sku to query.
     * @return The [SkuDetails] if found, else `null`.
     */
    private suspend fun querySingleSkuDetail(skuId: String): SkuDetails? {
        val skuDetailsResult = withContext(Dispatchers.IO) {
            billingClient.querySkuDetails(
                SkuDetailsParams.newBuilder().setType(BillingClient.SkuType.INAPP)
                    .setSkusList(listOf(skuId))
                    .build()
            )
        }
        if (skuDetailsResult.billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
            Log.e(
                TAG,
                "Could not get SKU details because: ${skuDetailsResult.billingResult.debugMessage}"
            )
            return null;
        }
        val results = skuDetailsResult.skuDetailsList;
        if (results == null || results.isEmpty()) {
            return null
        }
        return results[0]
    }

    /**
     * Start a billing flow. The [call] parameter should have "id" as an argument which is the id
     * of the item to purchase.
     *
     * @param call the Flutter [MethodCall] with an "id" argument
     * @param result the Flutter [MethodChannel.Result] that will be called for the result.
     */
    private suspend fun startBillingFlow(call: MethodCall, result: MethodChannel.Result) {
        val skuId = call.argument<String?>("id")
        if (skuId == null) {
            withContext(Dispatchers.Main) {
                result.error(
                    "${ErrorCodes.MISSING_ARGUMENT.ordinal}",
                    "Missing id argument!",
                    null
                )
            }
            return
        }
        val connected = ensureBillingClientConnected()
        if (!connected.first) {
            withContext(Dispatchers.Main) {
                result.error(
                    "${ErrorCodes.COULD_NOT_CONNECT.ordinal}",
                    "Could not connect to the billing client",
                    connected.second
                )
            }
            return
        }
        val skuDetails = querySingleSkuDetail(skuId)
        if (skuDetails == null) {
            withContext(Dispatchers.Main) {
                result.error(
                    "${ErrorCodes.COULD_NOT_GET_SKU_DETAILS.ordinal}",
                    "Could not get sku details",
                    null
                )
            }
            return
        }
        val flowParams = BillingFlowParams.newBuilder().setSkuDetails(skuDetails).build()
        val responseCode = billingClient.launchBillingFlow(activity, flowParams)
        if (responseCode.responseCode != BillingClient.BillingResponseCode.OK) {
            Log.w(TAG, "Flow unsuccessful ${responseCode.debugMessage}")
        } else {
            pendingResults.add(result)
        }
    }

    /**
     * Go through the pending purchases and consume them if they have gone through.
     *
     * @param call the Flutter [MethodCall] this is ignored.
     * @param result the Flutter [MethodChannel.Result] that will be called for the result.
     */
    private suspend fun handlePendingPurchases(call: MethodCall, result: MethodChannel.Result) {
        val connected = ensureBillingClientConnected()
        if (!connected.first) {
            withContext(Dispatchers.Main) {
                result.error(
                    "${ErrorCodes.COULD_NOT_CONNECT.ordinal}",
                    "Could not connect to the billing client",
                    connected.second
                )
            }
            return
        }
        val purchases = billingClient.queryPurchasesAsync(BillingClient.SkuType.INAPP)
        handlePurchases(purchases.billingResult, purchases.purchasesList)
        withContext(Dispatchers.Main) {
            result.success(null)
        }
    }

    /**
     * Handle pending purchases and consume them if their state is [Purchase.PurchaseState.PURCHASED]
     *
     * @param billingResult The result of the original call
     * @param purchases The [List] of [Purchase] which have not been consumed yet.
     * @return A [List] of [Int] with the state of every [Purchase]. `-1` means canceled/ error, `0`
     * for [Purchase.PurchaseState.PURCHASED] and consumed, `1` for [Purchase]s that are still
     * pending.
     */
    private suspend fun handlePurchases(
        billingResult: BillingResult,
        purchases: List<Purchase>?
    ): List<Int> {
        if (billingResult.responseCode == BillingClient.BillingResponseCode.USER_CANCELED) {
            return listOf(-1)
        } else if (billingResult.responseCode == BillingClient.BillingResponseCode.OK && purchases != null) {
            return purchases.map { purchase ->
                if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
                    val connected = ensureBillingClientConnected()
                    if (!connected.first) {
                        return@map 0
                    }
                    val result = billingClient.consumePurchase(
                        ConsumeParams.newBuilder().setPurchaseToken(purchase.purchaseToken).build()
                    )
                    result.purchaseToken
                    if (result.billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
                        Log.e(TAG, "Could not consume ${result.billingResult.debugMessage}")
                    }
                    return@map 0
                } else {
                    return@map 1
                }
            }
        } else {
            Log.w(TAG, "Error: ${billingResult.debugMessage}")
            return listOf(-1)
        }
    }


    companion object {
        private const val IAP_ID = "com.jeroen1602.lighthouse_pm/IAP"

        private val SKU_LIST = listOf(
            "com.jeroen1602.lighthouse_pm.donate2",
            "com.jeroen1602.lighthouse_pm.donate5",
            "com.jeroen1602.lighthouse_pm.donate10"
        )
        private val SKU_DETAILS =
            SkuDetailsParams.newBuilder().setType(BillingClient.SkuType.INAPP).setSkusList(SKU_LIST)
                .build()

        private val TAG = InAppPurchases::class.java.name

        enum class ErrorCodes {
            COULD_NOT_CONNECT,
            MISSING_ARGUMENT,
            COULD_NOT_GET_SKU_DETAILS,
            OTHER_ERROR
        }

        private enum class InMethods(
            val functionName: String,
            val handlerFunction: KSuspendFunction3<InAppPurchases, MethodCall, MethodChannel.Result, Unit>
        ) {
            REQUEST_PRICES("requestPrices", InAppPurchases::requestPrices),
            START_BILLING_FLOW("startBillingFlow", InAppPurchases::startBillingFlow),
            HANDLE_PENDING_PURCHASES(
                "handlePendingPurchases",
                InAppPurchases::handlePendingPurchases
            ),
        }

        val instance: InAppPurchases by lazy { InAppPurchases() }
    }

}
