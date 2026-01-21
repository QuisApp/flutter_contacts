package co.quis.flutter_contacts.native.impl

import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.provider.ContactsContract
import co.quis.flutter_contacts.common.BaseHandler
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class ShowViewerImpl(
    context: Context,
    executor: ExecutorService,
    private var activityBinding: ActivityPluginBinding?,
) : BaseHandler(context, executor) {
    fun setActivityBinding(binding: ActivityPluginBinding?) {
        activityBinding = binding
    }

    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val contactId = call.argument<String>("contactId")!!
        val uri =
            contactId.toLongOrNull()?.let { ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, it) }
                ?: return postError(result, "Invalid contactId")
        val activity = activityBinding?.activity ?: return postError(result, "No activity")
        mainHandler.post {
            activity.startActivity(Intent(Intent.ACTION_VIEW, uri))
            postResult(result, null)
        }
    }
}
