package co.quis.flutter_contacts.blockednumbers.impl

import android.content.ContentValues
import android.content.Context
import android.provider.BlockedNumberContract.BlockedNumbers
import co.quis.flutter_contacts.blockednumbers.utils.normalizeToE164
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argListRequired
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class BlockNumbersImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val numbers = call.argListRequired<String>("numbers")
        numbers.forEach { number ->
            val e164Number = normalizeToE164(context, number)
            ContentValues()
                .apply {
                    put(BlockedNumbers.COLUMN_ORIGINAL_NUMBER, number)
                    e164Number?.let { put(BlockedNumbers.COLUMN_E164_NUMBER, it) }
                }.let { context.contentResolver.insert(BlockedNumbers.CONTENT_URI, it) }
        }
        postResult(result, null)
    }
}
