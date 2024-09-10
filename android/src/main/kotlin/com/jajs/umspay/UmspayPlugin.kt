package com.jajs.umspay

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.StandardMessageCodec

import com.chinaums.pppay.unify.UnifyPayPlugin;
import com.chinaums.pppay.unify.UnifyPayRequest;
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import org.json.JSONObject

/** UmspayPlugin */
class UmspayPlugin : FlutterPlugin, MethodCallHandler, PluginRegistry.ActivityResultListener,
    ActivityAware, PluginRegistry.NewIntentListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var messageChannel: BasicMessageChannel<Any>

    private lateinit var activity: Activity

    companion object {
        const val MESSAGE_CHANNEL_NAME = "com.jajs.umspay.message"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "umspay")
        messageChannel = BasicMessageChannel<Any>(
            flutterPluginBinding.binaryMessenger,
            MESSAGE_CHANNEL_NAME,
            StandardMessageCodec.INSTANCE
        )
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        System.err.println(" === method:${call.method} === ")
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "umsPay" -> {
                try {
                    val payMode = call.argument<String>("payMode")
                    val payChannel = call.argument<String>("channel")
                    val payData = call.argument<String>("payData")
                    val wechatAppId = call.argument<String>("wechatAppId")
                    val universalLink = call.argument<String>("universalLink")
                    val request = UnifyPayRequest()
                    request.payChannel = payChannel
                    request.payData = payData;
                    UnifyPayPlugin.getInstance(activity).sendPayRequest(request)
                } catch (e: Error) {
                    Log.e("ret", e.toString())
                }

            }

            else -> {
                result.notImplemented()
            }
        }
//        if (call.method == "getPlatformVersion") {
//            result.success("Android ${android.os.Build.VERSION.RELEASE}")
//        } else {
//            result.notImplemented()
//        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (data == null) {
            return true
        }
        Log.i(" === data:", data.extras.toString())
        val payResult: HashMap<String, Any> = HashMap();
        messageChannel.send(payResult);
        return true
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        // 绑定activity
        activity = binding.activity
        binding.addActivityResultListener(this)
        binding.addOnNewIntentListener(this)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        TODO("Not yet implemented")
    }

    override fun onDetachedFromActivity() {
        TODO("Not yet implemented")
    }

    override fun onNewIntent(intent: Intent): Boolean {
        Log.e(" === data:", intent.data.toString())
        if (intent.action == Intent.ACTION_VIEW) {
            intent.data?.let { uri ->
                System.err.println(" === 处理URI参数: $uri === ");
                // 处理 URI 参数
                val errCode = uri.getQueryParameter("errCode")
                val errStr = uri.getQueryParameter("errStr")
                // 处理支付结果
                val params = mapOf(
                    "errCode" to errCode,
                    "errStr" to errStr
                )
//                messageChannel.send("{\"errCode\":\"$errCode\", \"errStr\":\"$errStr\"}");
                messageChannel.send(params)
            }
        }
        return true
    }

}
