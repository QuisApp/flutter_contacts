package co.quis.flutter_contacts.blockednumbers.impl

import android.content.Context
import android.provider.BlockedNumberContract
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argListRequired
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class UnblockNumbersImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    // Refused unless the app is the default dialer/SMS app (documented as security_error).
    override val securityErrorCode = "security_error"

    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val numbers = call.argListRequired<String>("numbers")
        numbers.forEach { BlockedNumberContract.unblock(context, it) }
        postResult(result, null)
    }
}
