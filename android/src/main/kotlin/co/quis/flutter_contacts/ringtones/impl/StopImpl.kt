package co.quis.flutter_contacts.ringtones.impl

import android.content.Context
import co.quis.flutter_contacts.common.BaseHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class StopImpl(
    context: Context,
    executor: ExecutorService,
    private val playRingtoneImpl: PlayImpl,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        playRingtoneImpl.stop()
        postResult(result, null)
    }
}
