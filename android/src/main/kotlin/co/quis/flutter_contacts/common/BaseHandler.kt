package co.quis.flutter_contacts.common

import android.content.Context
import android.os.Looper
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
                    mainHandler.post {
                        result.error(
                            "flutter_contacts_error",
                            "Failed to handle ${call.method}: ${error.message}",
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
    ) {
        mainHandler.post { result.error("flutter_contacts_error", message, null) }
    }
}
