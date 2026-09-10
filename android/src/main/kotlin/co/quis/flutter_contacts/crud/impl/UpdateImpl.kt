package co.quis.flutter_contacts.crud.impl

import android.content.Context
import android.provider.ContactsContract.AUTHORITY
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.BatchHelper
import co.quis.flutter_contacts.crud.models.contact.Contact
import co.quis.flutter_contacts.crud.utils.AccountUtils
import co.quis.flutter_contacts.crud.utils.ContactBuilder
import co.quis.flutter_contacts.crud.utils.ContactFetcher
import co.quis.flutter_contacts.crud.utils.ContactValidator
import co.quis.flutter_contacts.crud.utils.PhotoUtils
import co.quis.flutter_contacts.crud.utils.ReadOnlyUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class UpdateImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val contactJson = call.argument<Map<String, Any>>("contact")!!
        val newContact = Contact.fromJson(contactJson)
        val contactId =
            newContact.id ?: return postError(result, "Contact ID is required for update")

        val properties = ContactValidator.validateHasProperties(newContact)
        val contentResolver = context.contentResolver

        val rawContactIds = AccountUtils.getRawContactIdsForContact(contentResolver, contactId)
        if (rawContactIds.isEmpty()) {
            return postError(result, "No raw contacts found for contact: $contactId")
        }

        val existingContact =
            ContactFetcher.getContact(
                contentResolver,
                contactId,
                properties,
                null,
                rawContactIds,
            )
                ?: return postError(result, "Contact not found: $contactId")

        // The provider drops updates to read-only rows without reporting it, so refuse the whole
        // update rather than returning a success that changed only part of the contact.
        val readOnlyProperties =
            ReadOnlyUtils.getReadOnlyProperties(
                contentResolver,
                listOf(existingContact to newContact),
                properties,
            )
        if (readOnlyProperties.isNotEmpty()) {
            return postError(
                result,
                "Contact $contactId has read-only properties that cannot be updated",
                ReadOnlyUtils.ERROR_CODE,
                mapOf("properties" to readOnlyProperties.sorted()),
            )
        }

        val primaryRawContactId =
            AccountUtils.getPrimaryRawContactIdForUpdate(
                contentResolver,
                existingContact,
                contactId,
                rawContactIds,
                { AccountUtils.getDefaultAccount(contentResolver) },
            )

        val ops =
            ContactBuilder.buildUpdateOperations(
                contentResolver,
                existingContact,
                newContact,
                properties,
                primaryRawContactId,
            )
        BatchHelper.applyInBatches(contentResolver, AUTHORITY, ops)

        val photoData = newContact.photo?.fullSize ?: newContact.photo?.thumbnail
        if (photoData != null) {
            PhotoUtils.savePhoto(contentResolver, primaryRawContactId, photoData)
        } else if (existingContact.photo?.thumbnail != null ||
            existingContact.photo?.fullSize != null
        ) {
            PhotoUtils.deletePhotoForContact(
                contentResolver,
                contactId.toLong(),
                rawContactIds,
            )
        }

        postResult(result, null)
    }
}
