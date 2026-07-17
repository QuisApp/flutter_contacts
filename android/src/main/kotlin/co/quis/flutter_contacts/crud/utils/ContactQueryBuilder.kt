package co.quis.flutter_contacts.crud.utils

import android.content.ContentResolver
import android.provider.ContactsContract.Contacts
import android.provider.ContactsContract.Data
import co.quis.flutter_contacts.accounts.models.Account

data class QuerySelection(
    val selection: String?,
    val selectionArgs: Array<String>?,
)

object ContactQueryBuilder {
    fun buildDataSelection(
        contactId: String?,
        contactIds: List<String>?,
        rawContactIds: List<Long>?,
        account: Account?,
        mimeTypes: Set<String>?,
        contentResolver: ContentResolver,
    ): QuerySelection {
        val selectionParts = mutableListOf<String>()
        val selectionArgs = mutableListOf<String>()

        when {
            contactId != null -> {
                selectionParts.add("${Data.CONTACT_ID} = ?")
                selectionArgs.add(contactId)
            }

            !contactIds.isNullOrEmpty() -> {
                selectionParts.add(
                    "${Data.CONTACT_ID} IN (${contactIds.joinToString(",") { "?" }})",
                )
                selectionArgs.addAll(contactIds)
            }
        }

        if (!mimeTypes.isNullOrEmpty()) {
            selectionParts.add("${Data.MIMETYPE} IN (${mimeTypes.joinToString(",") { "?" }})")
            selectionArgs.addAll(mimeTypes)
        }

        // rawContactIds priority: explicit parameter > account lookup > null
        val rawContactIdsToUse =
            when {
                rawContactIds != null -> {
                    rawContactIds
                }

                account != null -> {
                    if (!contactIds.isNullOrEmpty()) {
                        AccountUtils.getRawContactIdsForAccountAndContacts(
                            contentResolver,
                            account,
                            contactIds,
                        )
                    } else if (contactId != null) {
                        AccountUtils.getRawContactIdsForAccount(
                            contentResolver,
                            account,
                            contactId,
                        )
                    } else {
                        null
                    }
                }

                else -> {
                    null
                }
            }

        if (rawContactIdsToUse != null && rawContactIdsToUse.isNotEmpty()) {
            selectionParts.add(
                "${Data.RAW_CONTACT_ID} IN (${rawContactIdsToUse.joinToString(",") { "?" }})",
            )
            selectionArgs.addAll(rawContactIdsToUse.map { it.toString() })
        }

        return QuerySelection(
            selection = selectionParts.joinToString(" AND "),
            selectionArgs =
                if (selectionArgs.isNotEmpty()) selectionArgs.toTypedArray() else null,
        )
    }

    fun buildContactIdSelection(
        contactIds: List<String>?,
        field: String = Contacts._ID,
    ): QuerySelection =
        if (!contactIds.isNullOrEmpty()) {
            QuerySelection(
                selection = "$field IN (${contactIds.joinToString(",") { "?" }})",
                selectionArgs = contactIds.toTypedArray(),
            )
        } else {
            QuerySelection(selection = null, selectionArgs = null)
        }
}
