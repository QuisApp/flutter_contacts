package co.quis.flutter_contacts.crud.utils

import android.content.ContentResolver
import android.net.Uri
import android.provider.ContactsContract.CommonDataKinds.Email
import android.provider.ContactsContract.CommonDataKinds.GroupMembership
import android.provider.ContactsContract.CommonDataKinds.Phone
import android.provider.ContactsContract.Contacts
import android.provider.ContactsContract.Data

data class FilterResult(
    val contactIds: List<String>?,
)

object ContactFilterUtils {
    fun queryContactIds(
        contentResolver: ContentResolver,
        uri: Uri,
        contactIdColumn: String,
        projection: Array<String>,
        selection: String? = null,
        selectionArgs: Array<String>? = null,
    ): List<String> =
        contentResolver
            .query(uri, projection, selection, selectionArgs, null)
            ?.use {
                val columnIndex = it.getColumnIndex(contactIdColumn)
                if (columnIndex < 0) return@use emptyList<String>()
                buildSet {
                    while (it.moveToNext()) {
                        it.getString(columnIndex)?.let { id -> add(id) }
                    }
                }
            }?.toList()
            ?: emptyList()

    fun getContactIdsByName(
        contentResolver: ContentResolver,
        nameFilter: String,
    ): List<String> {
        val uri = Uri.withAppendedPath(Contacts.CONTENT_FILTER_URI, Uri.encode(nameFilter))
        return queryContactIds(
            contentResolver,
            uri,
            Contacts._ID,
            arrayOf(Contacts._ID),
            "${Contacts.IN_VISIBLE_GROUP} = 1",
        )
    }

    fun getContactIdsByPhone(
        contentResolver: ContentResolver,
        phoneFilter: String,
    ): List<String> =
        queryContactIds(
            contentResolver,
            Phone.CONTENT_URI,
            Phone.CONTACT_ID,
            arrayOf(Phone.CONTACT_ID),
            "${Phone.NUMBER} LIKE ? OR ${Phone.NORMALIZED_NUMBER} LIKE ?",
            arrayOf("%$phoneFilter%", "%$phoneFilter%"),
        )

    fun getContactIdsByEmail(
        contentResolver: ContentResolver,
        emailFilter: String,
    ): List<String> =
        queryContactIds(
            contentResolver,
            Email.CONTENT_URI,
            Email.CONTACT_ID,
            arrayOf(Email.CONTACT_ID),
            "${Email.ADDRESS} LIKE ?",
            arrayOf("%$emailFilter%"),
        )

    fun getContactIdsFromGroups(
        contentResolver: ContentResolver,
        groupIds: List<String>,
        contactIds: List<String>? = null,
    ): List<String> {
        val groupPlaceholders = groupIds.joinToString(",") { "?" }
        val selectionParts = mutableListOf<String>()
        val selectionArgs = mutableListOf<String>()

        selectionParts.add("${GroupMembership.GROUP_ROW_ID} IN ($groupPlaceholders)")
        selectionArgs.addAll(groupIds)

        if (!contactIds.isNullOrEmpty()) {
            val contactPlaceholders = contactIds.joinToString(",") { "?" }
            selectionParts.add("${Data.CONTACT_ID} IN ($contactPlaceholders)")
            selectionArgs.addAll(contactIds)
        }

        val selection = "${selectionParts.joinToString(" AND ")} AND ${Data.MIMETYPE} = ?"
        val args = (selectionArgs + GroupMembership.CONTENT_ITEM_TYPE).toTypedArray()

        return queryContactIds(
            contentResolver,
            Data.CONTENT_URI,
            Data.CONTACT_ID,
            arrayOf(Data.CONTACT_ID),
            selection,
            args,
        )
    }

    fun parseAndApply(
        contentResolver: ContentResolver,
        filterDict: Map<String, Any?>?,
    ): FilterResult {
        if (filterDict == null) return FilterResult(contactIds = null)

        val contactIds =
            when {
                filterDict["id"] != null -> {
                    filterDict["id"] as? List<String>
                }

                filterDict["name"] != null -> {
                    getContactIdsByName(contentResolver, filterDict["name"] as String)
                }

                filterDict["phone"] != null -> {
                    getContactIdsByPhone(contentResolver, filterDict["phone"] as String)
                }

                filterDict["email"] != null -> {
                    getContactIdsByEmail(contentResolver, filterDict["email"] as String)
                }

                filterDict["group"] != null -> {
                    getContactIdsFromGroups(
                        contentResolver,
                        listOf(filterDict["group"] as String),
                        null,
                    )
                }

                else -> {
                    null
                }
            }

        return FilterResult(contactIds = contactIds)
    }
}
