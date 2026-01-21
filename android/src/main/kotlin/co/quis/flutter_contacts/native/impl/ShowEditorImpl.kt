package co.quis.flutter_contacts.native.impl

import android.app.Activity
import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.provider.ContactsContract
import co.quis.flutter_contacts.common.BaseHandler
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class ShowEditorImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingResult: MethodChannel.Result? = null
    private var requestCode: Int = 0

    fun setActivityBinding(binding: ActivityPluginBinding?) {
        activityBinding = binding
        if (binding != null) {
            requestCode = System.identityHashCode(this) and 0xFFFF
            binding.addActivityResultListener { reqCode, resultCode, data ->
                if (reqCode == this.requestCode) {
                    handleResult(resultCode, data)
                    true
                } else {
                    false
                }
            }
        }
    }

    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val contactId = call.argument<String>("contactId")!!
        val uri =
            contactId.toLongOrNull()?.let {
                ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, it)
            }
                ?: return postError(result, "Invalid contactId")
        val activity =
            activityBinding?.activity ?: return postError(result, "No activity available")
        pendingResult = result
        mainHandler.post {
            activity.startActivityForResult(Intent(Intent.ACTION_EDIT, uri), requestCode)
        }
    }

    private fun handleResult(
        resultCode: Int,
        data: Intent?,
    ) {
        val result = pendingResult ?: return
        pendingResult = null
        if (resultCode == Activity.RESULT_OK && data?.data != null) {
            val contactId = ContentUris.parseId(data.data!!).toString()
            postResult(result, contactId)
        } else {
            postResult(result, null)
        }
    }
}
