package co.quis.flutter_contacts.blockednumbers.impl

import android.content.Context
import android.database.Cursor
import android.provider.BlockedNumberContract.BlockedNumbers
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull
import co.quis.flutter_contacts.common.CursorHelpers.mapRows
import co.quis.flutter_contacts.common.CursorHelpers.queryAndProcess
import co.quis.flutter_contacts.crud.models.properties.Phone
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class GetAllImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val phones =
            context.contentResolver.queryAndProcess(
                BlockedNumbers.CONTENT_URI,
                projection =
                    arrayOf(
                        BlockedNumbers.COLUMN_ORIGINAL_NUMBER,
                        BlockedNumbers.COLUMN_E164_NUMBER,
                    ),
            ) { cursor ->
                cursor.mapRows { cursor -> parsePhone(cursor) }.filterNotNull()
            }
                ?: emptyList()
        postResult(result, phones.map { it.toJson() })
    }

    private fun parsePhone(cursor: Cursor): Phone? {
        val originalNumber = cursor.getStringOrNull(BlockedNumbers.COLUMN_ORIGINAL_NUMBER)
        val e164Number = cursor.getStringOrNull(BlockedNumbers.COLUMN_E164_NUMBER)
        return if (originalNumber != null || e164Number != null) {
            Phone(
                number = originalNumber ?: e164Number ?: "",
                normalizedNumber = e164Number,
            )
        } else {
            null
        }
    }
}
