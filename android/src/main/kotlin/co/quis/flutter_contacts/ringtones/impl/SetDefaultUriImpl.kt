package co.quis.flutter_contacts.ringtones.impl

import android.content.Context
import android.media.RingtoneManager
import android.net.Uri
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argString
import co.quis.flutter_contacts.ringtones.handlers.RingtoneUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class SetDefaultUriImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val type = call.argument<String>("type")!!
        RingtoneManager.setActualDefaultRingtoneUri(
            context,
            RingtoneUtils.parseRingtoneType(type),
            call.argString("ringtoneUri")?.let { Uri.parse(it) },
        )
        postResult(result, null)
    }
}
