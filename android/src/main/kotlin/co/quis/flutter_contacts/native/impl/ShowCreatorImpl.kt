package co.quis.flutter_contacts.native.impl

import android.app.Activity
import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.provider.ContactsContract
import android.provider.ContactsContract.Contacts
import android.provider.ContactsContract.Intents.Insert
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argMap
import co.quis.flutter_contacts.crud.models.JsonHelpers
import co.quis.flutter_contacts.crud.models.contact.Contact
import co.quis.flutter_contacts.crud.utils.AccountUtils
import co.quis.flutter_contacts.crud.utils.ContactBuilder
import co.quis.flutter_contacts.crud.utils.PhotoUtils
import co.quis.flutter_contacts.listeners.utils.Permissions
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
    private var pendingPhoto: ByteArray? = null
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

            // Insert.NAME is required for some Android editors (e.g. Samsung) to show the name;
            // StructuredName rows in Insert.DATA alone are often ignored for display. Use NAME
            // only (not both) to avoid duplicate/conflicting prefill. Phone/email stay in DATA
            // only for the same reason.
            it.name?.let { name ->
                fun compose(vararg parts: String?) =
                    parts
                        .filterNotNull()
                        .map(String::trim)
                        .filter(String::isNotEmpty)
                        .joinToString(" ")
                val fullName = compose(name.prefix, name.first, name.middle, name.last, name.suffix)
                if (fullName.isNotEmpty()) {
                    intent.putExtra(Insert.NAME, fullName)
                    compose(name.phoneticFirst, name.phoneticMiddle, name.phoneticLast)
                        .takeIf { phonetic -> phonetic.isNotEmpty() }
                        ?.let { phonetic -> intent.putExtra(Insert.PHONETIC_NAME, phonetic) }
                    dataList.removeAll { values ->
                        values.getAsString(ContactsContract.Data.MIMETYPE) ==
                            ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE
                    }
                }
            }

            if (dataList.isNotEmpty()) intent.putParcelableArrayListExtra(Insert.DATA, dataList)
        }
        val activity =
            activityBinding?.activity ?: return postError(result, "No activity available")
        pendingResult = result
        pendingPhoto = contact?.photo?.let { it.fullSize ?: it.thumbnail }
        mainHandler.post { activity.startActivityForResult(intent, requestCode) }
    }

    private fun handleResult(
        resultCode: Int,
        data: Intent?,
    ) {
        val result = pendingResult ?: return
        pendingResult = null
        val photo = pendingPhoto
        pendingPhoto = null
        if (resultCode == Activity.RESULT_OK && data?.data != null) {
            val contactId = ContentUris.parseId(data.data!!).toString()
            executor.execute {
                runCatching { applyPhotoIfMissing(contactId, photo) }
                postResult(result, contactId)
            }
        } else {
            postResult(result, null)
        }
    }

    /**
     * The system contact editor ignores photo rows passed via [Insert.DATA], so the prefilled
     * photo is applied to the created contact here instead. Requires WRITE_CONTACTS (skipped
     * otherwise), and never overwrites a photo the user picked in the editor.
     */
    private fun applyPhotoIfMissing(
        contactId: String,
        photo: ByteArray?,
    ) {
        if (photo == null || !Permissions.hasWritePermission(context)) return
        val contentResolver = context.contentResolver
        if (hasPhoto(contentResolver, contactId)) return
        val rawContactId =
            AccountUtils
                .getRawContactIdsForContact(contentResolver, contactId)
                .firstOrNull() ?: return
        PhotoUtils.savePhoto(contentResolver, rawContactId, photo)
    }

    private fun hasPhoto(
        contentResolver: ContentResolver,
        contactId: String,
    ): Boolean =
        contentResolver
            .query(
                ContentUris.withAppendedId(Contacts.CONTENT_URI, contactId.toLong()),
                arrayOf(Contacts.PHOTO_ID),
                null,
                null,
                null,
            )?.use { it.moveToFirst() && !it.isNull(0) }
            ?: false
}
