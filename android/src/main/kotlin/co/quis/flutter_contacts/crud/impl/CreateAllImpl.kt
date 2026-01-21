package co.quis.flutter_contacts.crud.impl

import android.content.ContentProviderOperation
import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.provider.ContactsContract.AUTHORITY
import android.provider.ContactsContract.RawContacts
import co.quis.flutter_contacts.accounts.models.Account
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.BatchHelper
import co.quis.flutter_contacts.common.CursorHelpers.getLongOrNull
import co.quis.flutter_contacts.common.CursorHelpers.mapRows
import co.quis.flutter_contacts.common.CursorHelpers.queryAndProcess
import co.quis.flutter_contacts.crud.models.contact.Contact
import co.quis.flutter_contacts.crud.utils.AccountUtils
import co.quis.flutter_contacts.crud.utils.ContactBuilder
import co.quis.flutter_contacts.crud.utils.PhotoUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class CreateAllImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val contactsJson = call.argument<List<Map<String, Any>>>("contacts")!!

        val contentResolver = context.contentResolver
        val contacts = contactsJson.map { Contact.fromJson(it) }
        val accountMap = call.argument<Map<*, *>>("account")
        val account =
            Account.fromJson(accountMap) ?: AccountUtils.getDefaultAccount(contentResolver)

        // Process contacts in batches to avoid exceeding operation limits
        val allContactIds = mutableListOf<String>()
        val maxOpsPerBatch = BatchHelper.MAX_OPERATIONS_PER_BATCH
        val shouldAddYield: (Int) -> Boolean = { opIndex ->
            BatchHelper.shouldYieldAtOperationIndex(opIndex)
        }

        var ops = mutableListOf<ContentProviderOperation>()
        var rawContactIndices = mutableListOf<Int>()
        var batchPhotoDataList = mutableListOf<Pair<Int, ByteArray>>()
        var batchContacts = mutableListOf<Contact>()
        var didError = false

        fun flushBatch() {
            if (ops.isEmpty() || didError) return

            val results = BatchHelper.applyInBatchesWithResults(contentResolver, AUTHORITY, ops)

            // Batch operation returns RawContact URIs only. Need to lookup Contact IDs because
            // they're required
            // for updating contact-level properties (favorite, ringtone, sendToVoicemail) and for
            // the return value.
            val batchRawContactIds =
                rawContactIndices.map { ContentUris.parseId(results[it].uri!!) }
            val contactIdsMap = getContactIdsFromRawContacts(contentResolver, batchRawContactIds)

            if (batchRawContactIds.any { it !in contactIdsMap }) {
                val missingCount = batchRawContactIds.count { it !in contactIdsMap }
                postError(result, "Failed to get contact IDs for $missingCount raw contact(s)")
                didError = true
                return
            }

            val contactUpdateOps =
                batchContacts.zip(batchRawContactIds).mapNotNull { (contact, rawContactId) ->
                    val contactId = contactIdsMap[rawContactId]!!
                    ContactBuilder.buildContactOptionsOperations(contactId, contact)
                }
            BatchHelper.applyInBatches(contentResolver, AUTHORITY, contactUpdateOps)

            // Save photos for this batch
            batchPhotoDataList.forEach { (batchIndex, photoData) ->
                val rawContactId = batchRawContactIds[batchIndex]
                PhotoUtils.savePhoto(contentResolver, rawContactId, photoData)
            }

            // Collect all contact IDs
            allContactIds.addAll(batchRawContactIds.map { contactIdsMap[it]!!.toString() })

            ops = mutableListOf()
            rawContactIndices = mutableListOf()
            batchPhotoDataList = mutableListOf()
            batchContacts = mutableListOf()
        }

        contacts.forEach { contact ->
            if (didError) return

            var rawContactIndex = ops.size
            var newOps =
                ContactBuilder.buildCreateOperations(
                    contact,
                    account,
                    rawContactIndex,
                    ops.size,
                    shouldAddYield,
                )

            if (ops.isNotEmpty() && ops.size + newOps.size > maxOpsPerBatch) {
                flushBatch()
                if (didError) return

                rawContactIndex = ops.size
                newOps =
                    ContactBuilder.buildCreateOperations(
                        contact,
                        account,
                        rawContactIndex,
                        ops.size,
                        shouldAddYield,
                    )
            }

            rawContactIndices.add(rawContactIndex)
            ops.addAll(newOps)
            batchContacts.add(contact)

            val photoData = contact.photo?.fullSize ?: contact.photo?.thumbnail
            if (photoData != null) {
                batchPhotoDataList.add((batchContacts.size - 1) to photoData)
            }
        }

        flushBatch()
        if (didError) return

        postResult(result, allContactIds)
    }

    private fun getContactIdsFromRawContacts(
        contentResolver: ContentResolver,
        rawContactIds: List<Long>,
    ): Map<Long, Long> {
        if (rawContactIds.isEmpty()) return emptyMap()
        return contentResolver.queryAndProcess(
            RawContacts.CONTENT_URI,
            projection = arrayOf(RawContacts._ID, RawContacts.CONTACT_ID),
            selection = "${RawContacts._ID} IN (${rawContactIds.joinToString(",") { "?" }})",
            selectionArgs = rawContactIds.map { it.toString() }.toTypedArray(),
        ) { cursor ->
            cursor
                .mapRows { cursor ->
                    cursor.getLongOrNull(RawContacts._ID)?.let { rawId ->
                        cursor.getLongOrNull(RawContacts.CONTACT_ID)?.let { contactId ->
                            rawId to contactId
                        }
                    }
                }.filterNotNull()
                .toMap()
        }
            ?: emptyMap()
    }
}
