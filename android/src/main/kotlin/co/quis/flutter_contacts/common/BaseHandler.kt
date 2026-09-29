package co.quis.flutter_contacts.common

import android.content.Context
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

abstract class BaseHandler(
    protected val context: Context,
    protected val executor: ExecutorService,
) : Handler {
    protected val mainHandler = android.os.Handler(Looper.getMainLooper())

    override fun handle(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        executor.execute {
            runCatching { handleImpl(call, result) }
                .onFailure { error ->
                    Log.e("FlutterContacts", "Failed to handle ${call.method}", error)
                    mainHandler.post {
                        result.error(
                            // e.g. blocked numbers when the app is not the default dialer/SMS app
                            if (error is SecurityException) "security_error" else "flutter_contacts_error",
                            "Failed to handle ${call.method}: ${error.message ?: error.javaClass.simpleName}",
                            null,
                        )
                    }
                }
        }
    }

    /**
     * Implement this method to handle the actual method call logic. Results should be posted to the
     * main handler using [postResult].
     */
    protected abstract fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    )

    protected fun postResult(
        result: MethodChannel.Result,
        value: Any?,
    ) {
        mainHandler.post { result.success(value) }
    }

    protected fun postError(
        result: MethodChannel.Result,
        message: String,
        code: String = "flutter_contacts_error",
        details: Any? = null,
    ) {
        mainHandler.post { result.error(code, message, details) }
    }
}
