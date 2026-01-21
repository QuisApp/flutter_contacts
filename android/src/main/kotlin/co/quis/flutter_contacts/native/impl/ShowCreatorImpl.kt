package co.quis.flutter_contacts.native.impl

import android.app.Activity
import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.provider.ContactsContract
import android.provider.ContactsContract.Intents.Insert
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argMap
import co.quis.flutter_contacts.crud.models.JsonHelpers
import co.quis.flutter_contacts.crud.models.contact.Contact
import co.quis.flutter_contacts.crud.utils.ContactBuilder
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class ShowCreatorImpl(
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
        val contact =
            call
                .argMap("contact")
                ?.let { JsonHelpers.toStringKeyMap(it) }
                ?.let(Contact::fromJson)
        val intent =
            Intent(Intent.ACTION_INSERT).apply { type = ContactsContract.Contacts.CONTENT_TYPE }
        contact?.let {
            val dataList = ContactBuilder.buildInsertDataForIntent(it)
            if (dataList.isNotEmpty()) intent.putParcelableArrayListExtra(Insert.DATA, dataList)
        }
        val activity =
            activityBinding?.activity ?: return postError(result, "No activity available")
        pendingResult = result
        mainHandler.post { activity.startActivityForResult(intent, requestCode) }
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
