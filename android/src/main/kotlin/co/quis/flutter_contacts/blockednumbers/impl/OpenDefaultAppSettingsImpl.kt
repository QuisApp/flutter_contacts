package co.quis.flutter_contacts.blockednumbers.impl

import android.content.Context
import android.content.Intent
import android.provider.Settings
import co.quis.flutter_contacts.common.BaseHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class OpenDefaultAppSettingsImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val intent =
            Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        mainHandler.post {
            context.startActivity(intent)
            postResult(result, null)
        }
    }
}
