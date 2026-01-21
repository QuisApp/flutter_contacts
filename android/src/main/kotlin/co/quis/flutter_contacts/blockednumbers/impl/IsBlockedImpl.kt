package co.quis.flutter_contacts.blockednumbers.impl

import android.content.Context
import android.provider.BlockedNumberContract
import co.quis.flutter_contacts.common.BaseHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class IsBlockedImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val number = call.argument<String>("number")!!
        val isBlocked = BlockedNumberContract.isBlocked(context, number)
        postResult(result, isBlocked)
    }
}
