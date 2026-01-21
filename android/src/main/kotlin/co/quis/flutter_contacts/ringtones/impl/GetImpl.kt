package co.quis.flutter_contacts.ringtones.impl

import android.content.Context
import android.media.RingtoneManager
import android.net.Uri
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argBool
import co.quis.flutter_contacts.ringtones.handlers.RingtoneUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class GetImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val ringtoneUri = call.argument<String>("ringtoneUri")!!
        val uri = Uri.parse(ringtoneUri)
        val withMetadata = call.argBool("withMetadata", true)
        val title =
            if (withMetadata) {
                RingtoneManager.getRingtone(context, uri)?.getTitle(context)
            } else {
                null
            }
        val type = if (withMetadata) RingtoneUtils.getRingtoneType(context, uri) else null
        postResult(result, RingtoneUtils.buildRingtoneInfo(context, uri, title, type, withMetadata))
    }
}
