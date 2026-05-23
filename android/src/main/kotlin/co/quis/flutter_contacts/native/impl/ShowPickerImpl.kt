package co.quis.flutter_contacts.native.impl

import android.app.Activity
import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.ContactsContract
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argList
import co.quis.flutter_contacts.crud.models.contact.Contact
import co.quis.flutter_contacts.crud.utils.ContactFetcher
import co.quis.flutter_contacts.listeners.utils.Permissions
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class ShowPickerImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingResult: MethodChannel.Result? = null
    private var pendingProperties: Set<String> = emptySet()
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
        val activity =
            activityBinding?.activity ?: return postError(result, "No activity available")
        pendingResult = result
        pendingProperties = call.argList<String>("properties")?.toSet() ?: emptySet()
        mainHandler.post {
            val intent =
                Intent(Intent.ACTION_PICK).apply {
                    type = ContactsContract.Contacts.CONTENT_TYPE
                }
            activity.startActivityForResult(intent, requestCode)
        }
    }

    private fun handleResult(
        resultCode: Int,
        data: Intent?,
    ) {
        val result = pendingResult ?: return
        val properties = pendingProperties
        pendingResult = null
        pendingProperties = emptySet()
        if (resultCode != Activity.RESULT_OK || data?.data == null) return postResult(result, null)
        val pickedUri = data.data!!
        val contactId = ContentUris.parseId(pickedUri).toString()
        executor.execute {
            // Empty properties: read displayName via the picker's temporary URI grant; no
            // READ_CONTACTS needed. Non-empty properties: full projection requires READ_CONTACTS.
            if (properties.isEmpty()) {
                postResult(
                    result,
                    Contact(id = contactId, displayName = readDisplayName(pickedUri)).toJson(),
                )
                return@execute
            }
            if (!Permissions.hasReadPermission(context)) {
                return@execute postError(
                    result,
                    "showPicker(properties: …) requires READ_CONTACTS on Android. " +
                        "Grant the permission or call showPicker() without properties.",
                )
            }
            val contact =
                ContactFetcher.getContact(context.contentResolver, contactId, properties, null, null)
                    ?: Contact(id = contactId)
            postResult(result, contact.toJson())
        }
    }

    private fun readDisplayName(uri: Uri): String? =
        runCatching {
            context.contentResolver
                .query(uri, arrayOf(ContactsContract.Contacts.DISPLAY_NAME), null, null, null)
                ?.use { c -> if (c.moveToFirst()) c.getString(0) else null }
        }.getOrNull()
}
