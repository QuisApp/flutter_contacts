package co.quis.flutter_contacts.ringtones.impl

import android.content.Context
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import co.quis.flutter_contacts.common.BaseHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class PlayImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    private var currentRingtone: Ringtone? = null

    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val ringtoneUri = call.argument<String>("ringtoneUri")!!
        val uri = Uri.parse(ringtoneUri)
        val ringtone = RingtoneManager.getRingtone(context, uri)
        if (ringtone != null) {
            currentRingtone?.stop()
            currentRingtone = ringtone
            ringtone.play()
            postResult(result, null)
        } else {
            postError(result, "Failed to load ringtone")
        }
    }

    fun stop() {
        currentRingtone?.stop()
        currentRingtone = null
    }
}
