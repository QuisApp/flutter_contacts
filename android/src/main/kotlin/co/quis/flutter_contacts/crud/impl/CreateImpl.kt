package co.quis.flutter_contacts.crud.impl

import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.provider.ContactsContract.AUTHORITY
import android.provider.ContactsContract.RawContacts
import co.quis.flutter_contacts.accounts.models.Account
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.BatchHelper
import co.quis.flutter_contacts.common.CursorHelpers.getLongOrNull
import co.quis.flutter_contacts.common.CursorHelpers.queryAndProcess
import co.quis.flutter_contacts.common.argMap
import co.quis.flutter_contacts.crud.models.contact.Contact
import co.quis.flutter_contacts.crud.utils.AccountUtils
import co.quis.flutter_contacts.crud.utils.ContactBuilder
import co.quis.flutter_contacts.crud.utils.PhotoUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class CreateImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val contact = Contact.fromJson(call.argument<Map<String, Any>>("contact")!!)
        val account =
            Account.fromJson(call.argMap("account"))
                ?: AccountUtils.getDefaultAccount(context.contentResolver)

        val ops = ContactBuilder.buildCreateOperations(contact, account)
        val results = BatchHelper.applyInBatchesWithResults(context.contentResolver, AUTHORITY, ops)

        // Batch operation returns RawContact URI only. Need to lookup Contact ID because it's
        // required
        // for updating contact-level properties (favorite, ringtone, sendToVoicemail) and for the
        // return value.
        val rawContactId = ContentUris.parseId(results[0].uri!!)
        val contactId =
            getContactIdFromRawContact(context.contentResolver, rawContactId)
                ?: return postError(result, "Failed to get contact ID after creation")

        ContactBuilder.buildContactOptionsOperations(contactId, contact)?.let {
            BatchHelper.applyInBatches(context.contentResolver, AUTHORITY, listOf(it))
        }

        (contact.photo?.fullSize ?: contact.photo?.thumbnail)?.let {
            PhotoUtils.savePhoto(context.contentResolver, rawContactId, it)
        }

        postResult(result, contactId.toString())
    }

    private fun getContactIdFromRawContact(
        contentResolver: ContentResolver,
        rawContactId: Long,
    ): Long? =
        contentResolver.queryAndProcess(
            RawContacts.CONTENT_URI,
            projection = arrayOf(RawContacts.CONTACT_ID),
            selection = "${RawContacts._ID} = ?",
            selectionArgs = arrayOf(rawContactId.toString()),
        ) { cursor ->
            if (cursor.moveToFirst()) cursor.getLongOrNull(RawContacts.CONTACT_ID) else null
        }
}
