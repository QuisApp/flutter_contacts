package co.quis.flutter_contacts.ringtones.impl

import android.content.Context
import android.media.RingtoneManager
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.ringtones.handlers.RingtoneUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class GetDefaultUriImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val type = call.argument<String>("type")!!
        val uri = RingtoneManager.getDefaultUri(RingtoneUtils.parseRingtoneType(type))
        postResult(result, uri?.toString())
    }
}
