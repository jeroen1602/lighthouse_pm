package com.jeroen1602.lighthouse_pm

import android.app.Activity
import android.util.Log
import com.android.billingclient.api.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
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
        val products = queryProductDetails()
        if (products.isNullOrEmpty()) {
            withContext(Dispatchers.Main) {
                result.success(emptyList<Unit>())
            }
            return
        }
        // Convert products
        withContext(Dispatchers.Main) {
            result.success(productsToJson(products))
        }
    }

    /**
     * Convert a [ProductDetails] to a [Map] with [String] keys and [Any] values for sending through
     * a Flutter [MethodChannel]
     *
     * @param product The [ProductDetails] to convert.
     * @return A [Map] with the needed keys and values.
     * @see productsToJson
     */
    private fun productToJson(product: ProductDetails): Map<String, Any> {
        return mapOf(
            Pair("price", product.oneTimePurchaseOfferDetails?.formattedPrice ?: "unknown"),
            Pair("id", product.productId),
            Pair("title", product.description),
            Pair("priceMicros", product.oneTimePurchaseOfferDetails?.priceAmountMicros ?: 0),
        )
    }

    /**
     * Convert a [List] of [ProductDetails] to a [List] of [Map] for sending over a Flutter
     * [MethodChannel]
     *
     * @param products The [List] of [ProductDetails] to convert.
     * @return A [List] of [Map]s with the needed keys and values.
     * @see productToJson
     */
    private fun productsToJson(products: List<ProductDetails>): List<Map<String, Any>> {
        return products.map { productToJson(it) }
    }

    /**
     * Query a [List] of [ProductDetails] with all the products available to this app.
     *
     * @return A [List] of [ProductDetails] if nothing went wrong, else `null`.
     */
    private suspend fun queryProductDetails(): List<ProductDetails>? {

        val productDetailsResult = withContext(Dispatchers.IO) {
            billingClient.queryProductDetails(PRODUCT_DETAILS)
        }

        if (productDetailsResult.billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
            Log.e(
                TAG,
                "Could not get product details because: ${productDetailsResult.billingResult.debugMessage}"
            )
            return null
        }
        return productDetailsResult.productDetailsList
    }

    /**
     * Query a single [ProductDetails] based on it's unique id.
     *
     * @param productId The id of the product to query.
     * @return The [ProductDetails] if found, else `null`.
     */
    private suspend fun querySingleProductDetail(productId: String): ProductDetails? {

        val productDetailsResult = withContext(Dispatchers.IO) {
            billingClient.queryProductDetails(
                QueryProductDetailsParams.newBuilder()
                    .setProductList(
                        listOf(
                            QueryProductDetailsParams.Product.newBuilder()
                                .setProductType(BillingClient.ProductType.INAPP)
                                .setProductId(productId)
                                .build()
                        )
                    )
                    .build()
            )
        }

        if (productDetailsResult.billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
            Log.e(
                TAG,
                "Could not get product details because: ${productDetailsResult.billingResult.debugMessage}"
            )
            return null
        }

        val results = productDetailsResult.productDetailsList
        if (results.isNullOrEmpty()) {
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
        val productId = call.argument<String?>("id")
        if (productId == null) {
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
        val productDetails = querySingleProductDetail(productId)
        if (productDetails == null) {
            withContext(Dispatchers.Main) {
                result.error(
                    "${ErrorCodes.COULD_NOT_GET_PRODUCT_DETAILS.ordinal}",
                    "Could not get product details",
                    null
                )
            }
            return
        }
        val flowParams = BillingFlowParams.newBuilder().setIsOfferPersonalized(false)
            .setProductDetailsParamsList(
                listOf(
                    BillingFlowParams.ProductDetailsParams.newBuilder()
                        .setProductDetails(productDetails)
                        .build()
                )
            ).build()
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
        val purchases = billingClient.queryPurchasesAsync(
            QueryPurchasesParams.newBuilder()
                .setProductType(BillingClient.ProductType.INAPP)
                .build()
        )
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

        private val PRODUCT_LIST = listOf(
            QueryProductDetailsParams.Product.newBuilder()
                .setProductType(BillingClient.ProductType.INAPP)
                .setProductId("com.jeroen1602.lighthouse_pm.donate2")
                .build(),
            QueryProductDetailsParams.Product.newBuilder()
                .setProductType(BillingClient.ProductType.INAPP)
                .setProductId("com.jeroen1602.lighthouse_pm.donate5")
                .build(),
            QueryProductDetailsParams.Product.newBuilder()
                .setProductType(BillingClient.ProductType.INAPP)
                .setProductId("com.jeroen1602.lighthouse_pm.donate10")
                .build(),
        )

        private val PRODUCT_DETAILS =
            QueryProductDetailsParams.newBuilder().setProductList(PRODUCT_LIST).build()

        private val TAG = InAppPurchases::class.java.name

        enum class ErrorCodes {
            COULD_NOT_CONNECT,
            MISSING_ARGUMENT,
            COULD_NOT_GET_PRODUCT_DETAILS,
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
