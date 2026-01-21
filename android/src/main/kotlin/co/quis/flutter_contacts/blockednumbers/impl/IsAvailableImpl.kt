package co.quis.flutter_contacts.blockednumbers.impl

import android.content.Context
import android.provider.BlockedNumberContract
import co.quis.flutter_contacts.common.BaseHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class IsAvailableImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        try {
            val canBlock = BlockedNumberContract.canCurrentUserBlockNumbers(context)
            postResult(result, canBlock)
        } catch (e: Exception) {
            // If checking availability throws, return false instead of propagating the error
            postResult(result, false)
        }
    }
}
