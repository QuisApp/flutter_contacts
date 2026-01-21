package co.quis.flutter_contacts.ringtones.impl

import android.content.Context
import android.media.RingtoneManager
import android.net.Uri
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argBool
import co.quis.flutter_contacts.common.argString
import co.quis.flutter_contacts.ringtones.handlers.RingtoneUtils
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
        val type = RingtoneUtils.parseRingtoneType(call.argString("type"))
        val withMetadata = call.argBool("withMetadata", false)
        val ringtoneManager = RingtoneManager(context).apply { setType(type) }
        val ringtones = mutableListOf<Map<String, Any?>>()
        ringtoneManager.cursor?.use { cursor ->
            while (cursor.moveToNext()) {
                val uri = Uri.parse(cursor.getString(RingtoneManager.URI_COLUMN_INDEX))
                val title =
                    if (withMetadata) {
                        cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
                    } else {
                        null
                    }
                val ringtoneType =
                    if (withMetadata) RingtoneUtils.getRingtoneType(context, uri) else null
                ringtones.add(
                    RingtoneUtils.buildRingtoneInfo(
                        context,
                        uri,
                        title,
                        ringtoneType,
                        withMetadata,
                    ),
                )
            }
        }
        postResult(result, ringtones)
    }
}
