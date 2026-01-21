package co.quis.flutter_contacts.groups.utils

import android.content.ContentProviderOperation
import android.content.ContentResolver
import android.provider.ContactsContract
import android.provider.ContactsContract.CommonDataKinds.GroupMembership
import android.provider.ContactsContract.Data
import android.provider.ContactsContract.Groups
import co.quis.flutter_contacts.accounts.models.Account
import co.quis.flutter_contacts.common.BatchHelper
import co.quis.flutter_contacts.common.CursorHelpers.getString
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull
import co.quis.flutter_contacts.common.CursorHelpers.mapRows
import co.quis.flutter_contacts.common.CursorHelpers.queryAndProcess
import co.quis.flutter_contacts.crud.utils.AccountUtils
import co.quis.flutter_contacts.groups.models.Group

object GroupUtils {
    fun getGroups(
        contentResolver: ContentResolver,
        account: Account?,
        withContactCount: Boolean,
    ): List<Group> = getGroups(contentResolver, account?.let { listOf(it) }, withContactCount)

    fun getGroups(
        contentResolver: ContentResolver,
        accounts: List<Account>?,
        withContactCount: Boolean,
    ): List<Group> {
        val selectionParts = mutableListOf<String>()
        val selectionArgs = mutableListOf<String>()

        if (!accounts.isNullOrEmpty()) {
            val accountConditions =
                accounts.map { "(${Groups.ACCOUNT_TYPE} = ? AND ${Groups.ACCOUNT_NAME} = ?)" }
            selectionParts.add("(${accountConditions.joinToString(" OR ")})")
            accounts.forEach { account ->
                selectionArgs.add(account.type)
                selectionArgs.add(account.name)
            }
        }

        selectionParts.add("${Groups.AUTO_ADD} = 0")
        selectionParts.add("${Groups.FAVORITES} = 0")
        selectionParts.add("${Groups.DELETED} = 0")
        selectionParts.add("${Groups.GROUP_VISIBLE} = 1")

        val selection = selectionParts.joinToString(" AND ")
        val args = if (selectionArgs.isEmpty()) null else selectionArgs.toTypedArray()

        return contentResolver.queryAndProcess(
            Groups.CONTENT_URI,
            projection =
                arrayOf(
                    Groups._ID,
                    Groups.TITLE,
                    Groups.ACCOUNT_TYPE,
                    Groups.ACCOUNT_NAME,
                ),
            selection = selection,
            selectionArgs = args,
            sortOrder = Groups.TITLE,
        ) { cursor ->
            cursor.mapRows { cursor ->
                val groupId = cursor.getString(Groups._ID, "")
                val name = cursor.getString(Groups.TITLE, "")
                val accountType = cursor.getStringOrNull(Groups.ACCOUNT_TYPE)
                val accountName = cursor.getStringOrNull(Groups.ACCOUNT_NAME)
                val groupAccount =
                    if (accountType != null && accountName != null) {
                        Account(accountType, accountName)
                    } else {
                        null
                    }
                val contactCount =
                    if (withContactCount) {
                        getContactCount(contentResolver, groupId)
                    } else {
                        null
                    }
                Group(
                    id = groupId,
                    name = name,
                    account = groupAccount,
                    contactCount = contactCount,
                )
            }
        }
            ?: emptyList()
    }

    fun getGroup(
        contentResolver: ContentResolver,
        groupId: String,
        withContactCount: Boolean,
    ): Group? =
        contentResolver.queryAndProcess(
            Groups.CONTENT_URI,
            projection =
                arrayOf(
                    Groups._ID,
                    Groups.TITLE,
                    Groups.ACCOUNT_TYPE,
                    Groups.ACCOUNT_NAME,
                ),
            selection = "${Groups._ID} = ?",
            selectionArgs = arrayOf(groupId),
        ) { cursor ->
            if (cursor.moveToFirst()) {
                val id = cursor.getString(Groups._ID, "")
                val name = cursor.getString(Groups.TITLE, "")
                val accountType = cursor.getStringOrNull(Groups.ACCOUNT_TYPE)
                val accountName = cursor.getStringOrNull(Groups.ACCOUNT_NAME)
                val groupAccount =
                    if (accountType != null && accountName != null) {
                        Account(accountType, accountName)
                    } else {
                        null
                    }
                val contactCount =
                    if (withContactCount) {
                        getContactCount(contentResolver, id)
                    } else {
                        null
                    }
                Group(
                    id = id,
                    name = name,
                    account = groupAccount,
                    contactCount = contactCount,
                )
            } else {
                null
            }
        }

    fun getGroupsForContact(
        contentResolver: ContentResolver,
        contactId: String,
    ): List<Group> {
        val groupIds =
            contentResolver.queryAndProcess(
                Data.CONTENT_URI,
                projection = arrayOf(GroupMembership.GROUP_ROW_ID),
                selection = "${Data.CONTACT_ID} = ? AND ${Data.MIMETYPE} = ?",
                selectionArgs = arrayOf(contactId, GroupMembership.CONTENT_ITEM_TYPE),
            ) { cursor ->
                cursor.mapRows { cursor.getString(GroupMembership.GROUP_ROW_ID, "") }.filter {
                    it.isNotEmpty()
                }
            }
                ?: emptyList()

        if (groupIds.isEmpty()) return emptyList()

        val groupPlaceholders = groupIds.joinToString(",") { "?" }
        val selection =
            "${Groups._ID} IN ($groupPlaceholders) AND " +
                "${Groups.AUTO_ADD} = 0 AND " +
                "${Groups.FAVORITES} = 0 AND " +
                "${Groups.DELETED} = 0 AND " +
                "${Groups.GROUP_VISIBLE} = 1"

        return contentResolver.queryAndProcess(
            Groups.CONTENT_URI,
            projection =
                arrayOf(
                    Groups._ID,
                    Groups.TITLE,
                    Groups.ACCOUNT_TYPE,
                    Groups.ACCOUNT_NAME,
                ),
            selection = selection,
            selectionArgs = groupIds.toTypedArray(),
            sortOrder = Groups.TITLE,
        ) { cursor ->
            cursor.mapRows { cursor ->
                val groupId = cursor.getString(Groups._ID, "")
                val name = cursor.getString(Groups.TITLE, "")
                val accountType = cursor.getStringOrNull(Groups.ACCOUNT_TYPE)
                val accountName = cursor.getStringOrNull(Groups.ACCOUNT_NAME)
                val account =
                    if (accountType != null && accountName != null) {
                        Account(accountType, accountName)
                    } else {
                        null
                    }
                Group(
                    id = groupId,
                    name = name,
                    account = account,
                    contactCount = null,
                )
            }
        }
            ?: emptyList()
    }

    private fun getContactCount(
        contentResolver: ContentResolver,
        groupId: String,
    ): Int =
        contentResolver.queryAndProcess(
            Data.CONTENT_URI,
            projection = arrayOf(Data.CONTACT_ID),
            selection = "${Data.MIMETYPE} = ? AND ${GroupMembership.GROUP_ROW_ID} = ?",
            selectionArgs = arrayOf(GroupMembership.CONTENT_ITEM_TYPE, groupId),
        ) { cursor ->
            cursor
                .mapRows { cursor.getString(Data.CONTACT_ID, "") }
                .filter { it.isNotEmpty() }
                .toSet()
                .size
        }
            ?: 0

    fun addContactsToGroup(
        contentResolver: ContentResolver,
        groupId: String,
        contactIds: List<String>,
    ) {
        if (contactIds.isEmpty()) {
            return
        }

        val group =
            getGroup(contentResolver, groupId, false)
                ?: throw IllegalStateException("Group not found: $groupId")
        val groupAccount =
            group.account ?: throw IllegalStateException("Group has no account: $groupId")

        val ops = mutableListOf<ContentProviderOperation>()
        for (contactId in contactIds) {
            val rawContactIds =
                AccountUtils.getRawContactIdsForContact(
                    contentResolver,
                    contactId,
                    groupAccount,
                )
            if (rawContactIds.isEmpty()) {
                throw IllegalStateException(
                    "No raw contacts found for contact: $contactId matching group account: ${groupAccount.type}/${groupAccount.name}",
                )
            }
            for (rawContactId in rawContactIds) {
                ops.add(
                    ContentProviderOperation
                        .newInsert(Data.CONTENT_URI)
                        .withValue(Data.RAW_CONTACT_ID, rawContactId)
                        .withValue(
                            Data.MIMETYPE,
                            GroupMembership.CONTENT_ITEM_TYPE,
                        ).withValue(GroupMembership.GROUP_ROW_ID, groupId)
                        .withYieldAllowed(true)
                        .build(),
                )
            }
        }
        try {
            BatchHelper.applyInBatches(contentResolver, ContactsContract.AUTHORITY, ops)
        } catch (e: android.content.OperationApplicationException) {
            throw IllegalStateException(
                "Failed to add contacts to group: ${e.message}",
                e,
            )
        }
    }

    fun removeContactsFromGroup(
        contentResolver: ContentResolver,
        groupId: String,
        contactIds: List<String>,
    ) {
        val contactIdsPlaceholder = contactIds.joinToString(",") { "?" }
        contentResolver.delete(
            Data.CONTENT_URI,
            "${Data.MIMETYPE} = ? AND ${GroupMembership.GROUP_ROW_ID} = ? AND ${Data.CONTACT_ID} IN ($contactIdsPlaceholder)",
            arrayOf(GroupMembership.CONTENT_ITEM_TYPE, groupId) + contactIds.toTypedArray(),
        )
    }
}
