package co.quis.flutter_contacts.crud.impl

import android.content.ContentProviderOperation
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
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class UpdateAllImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val contactsJson = call.argument<List<Map<String, Any>>>("contacts")!!

        val contentResolver = context.contentResolver
        val newContacts = contactsJson.map { Contact.fromJson(it) }
        val contactIds = newContacts.mapNotNull { it.id }

        if (contactIds.isEmpty()) {
            postResult(result, null)
            return
        }

        val properties = ContactValidator.validateSameProperties(newContacts)

        // Batch fetch all raw contact IDs and existing contacts at once
        val rawContactIdsMap = AccountUtils.getRawContactIdsForContacts(contentResolver, contactIds)
        val missingContactIds =
            contactIds.filter { it !in rawContactIdsMap || rawContactIdsMap[it]!!.isEmpty() }
        if (missingContactIds.isNotEmpty()) {
            postError(
                result,
                "No raw contacts found for contact(s): ${missingContactIds.joinToString(", ")}",
            )
            return
        }

        val existingContactsMap =
            ContactFetcher.getContacts(
                contentResolver,
                contactIds,
                properties,
                rawContactIdsMap,
            )
        val notFoundContactIds = contactIds.filter { it !in existingContactsMap }
        if (notFoundContactIds.isNotEmpty()) {
            postError(result, "Contact(s) not found: ${notFoundContactIds.joinToString(", ")}")
            return
        }

        // Process contacts in batches to avoid exceeding operation limits
        val maxOpsPerBatch = BatchHelper.MAX_OPERATIONS_PER_BATCH
        var ops = mutableListOf<ContentProviderOperation>()
        val photoUpdates = mutableListOf<Pair<Long, ByteArray>>()
        val photoDeletes = mutableListOf<Pair<Long, List<Long>>>()
        var didError = false

        fun flushBatch() {
            if (ops.isEmpty() || didError) return
            try {
                BatchHelper.applyInBatches(contentResolver, AUTHORITY, ops)
            } catch (e: Exception) {
                postError(result, "Failed to apply batch: ${e.message}")
                didError = true
            }
            ops = mutableListOf()
        }

        val defaultAccount = AccountUtils.getDefaultAccount(contentResolver)

        newContacts.forEach { newContact ->
            if (didError) return
            val contactId =
                newContact.id
                    ?: run {
                        postError(result, "Contact ID is required for update")
                        didError = true
                        return
                    }

            val rawContactIds = rawContactIdsMap[contactId]!!
            val existingContact = existingContactsMap[contactId]!!
            val primaryRawContactId =
                AccountUtils.getPrimaryRawContactIdForUpdate(
                    contentResolver,
                    existingContact,
                    contactId,
                    rawContactIds,
                    { defaultAccount },
                )

            val newOps =
                ContactBuilder.buildUpdateOperations(
                    contentResolver,
                    existingContact,
                    newContact,
                    properties,
                    primaryRawContactId,
                )

            if (ops.isNotEmpty() && ops.size + newOps.size > maxOpsPerBatch) {
                flushBatch()
                if (didError) return
            }

            ops.addAll(newOps)

            val photoData = newContact.photo?.fullSize ?: newContact.photo?.thumbnail
            if (photoData != null) {
                photoUpdates.add(primaryRawContactId to photoData)
            } else if (existingContact.photo?.thumbnail != null ||
                existingContact.photo?.fullSize != null
            ) {
                photoDeletes.add(contactId.toLong() to rawContactIds)
            }
        }

        flushBatch()
        if (didError) return

        photoUpdates.forEach { (rawContactId, photoData) ->
            PhotoUtils.savePhoto(contentResolver, rawContactId, photoData)
        }
        photoDeletes.forEach { (contactId, rawContactIds) ->
            PhotoUtils.deletePhotoForContact(contentResolver, contactId, rawContactIds)
        }

        postResult(result, null)
    }
}
