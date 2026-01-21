package co.quis.flutter_contacts.accounts.impl

import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.ContactsContract.Settings
import co.quis.flutter_contacts.common.BaseHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class ShowDefaultPickerImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        if (Build.VERSION.SDK_INT < 33) {
            return postError(result, "Only available on Android 13+ (API 33+)")
        }

        val intent =
            Intent(Settings.ACTION_SET_DEFAULT_ACCOUNT).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

        mainHandler.post {
            context.startActivity(intent)
            postResult(result, null)
        }
    }
}
