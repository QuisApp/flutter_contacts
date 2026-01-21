package co.quis.flutter_contacts.crud.utils

import android.content.ContentResolver
import android.os.Build
import android.provider.ContactsContract.RawContacts
import android.provider.ContactsContract.Settings
import co.quis.flutter_contacts.accounts.models.Account
import co.quis.flutter_contacts.common.BatchHelper
import co.quis.flutter_contacts.common.CursorHelpers.forEachRow
import co.quis.flutter_contacts.common.CursorHelpers.getLongOrNull
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull
import co.quis.flutter_contacts.common.CursorHelpers.mapRows
import co.quis.flutter_contacts.common.CursorHelpers.queryAndProcess
import co.quis.flutter_contacts.crud.models.contact.Contact
import co.quis.flutter_contacts.crud.models.properties.PropertyMetadata

object AccountUtils {
    fun getRawContactIdsForAccount(
        contentResolver: ContentResolver,
        account: Account,
        contactId: String? = null,
    ): List<Long> {
        val (selection, args) = buildAccountSelection(account, contactId)
        return contentResolver.queryAndProcess(
            RawContacts.CONTENT_URI,
            projection = arrayOf(RawContacts._ID),
            selection = selection,
            selectionArgs = args,
        ) { cursor ->
            cursor.mapRows { cursor.getLongOrNull(RawContacts._ID) }.filterNotNull()
        }
            ?: emptyList()
    }

    fun getRawContactIdsForAccountAndContacts(
        contentResolver: ContentResolver,
        account: Account,
        contactIds: List<String>,
    ): List<Long> {
        if (contactIds.isEmpty()) return emptyList()
        val resultIds = mutableListOf<Long>()
        BatchHelper.forEachSelectionArgsBatch(contactIds) { batch ->
            val selectionParts =
                mutableListOf(
                    "${RawContacts.ACCOUNT_TYPE} = ?",
                    "${RawContacts.ACCOUNT_NAME} = ?",
                    "${RawContacts.CONTACT_ID} IN (${batch.joinToString(",") { "?" }})",
                )
            val selectionArgs = mutableListOf(account.type, account.name)
            selectionArgs.addAll(batch)
            val ids =
                contentResolver.queryAndProcess(
                    RawContacts.CONTENT_URI,
                    projection = arrayOf(RawContacts._ID),
                    selection = selectionParts.joinToString(" AND "),
                    selectionArgs = selectionArgs.toTypedArray(),
                ) { cursor ->
                    cursor
                        .mapRows { cursor.getLongOrNull(RawContacts._ID) }
                        .filterNotNull()
                }
                    ?: emptyList()
            resultIds.addAll(ids)
        }
        return resultIds
    }

    fun getContactIdsForAccount(
        contentResolver: ContentResolver,
        account: Account,
        contactIds: List<String>? = null,
    ): List<String> {
        val resultIds = mutableSetOf<String>()
        if (contactIds.isNullOrEmpty()) {
            return contentResolver.queryAndProcess(
                RawContacts.CONTENT_URI,
                projection = arrayOf(RawContacts.CONTACT_ID),
                selection =
                    "${RawContacts.ACCOUNT_TYPE} = ? AND ${RawContacts.ACCOUNT_NAME} = ?",
                selectionArgs = arrayOf(account.type, account.name),
            ) { cursor ->
                cursor
                    .mapRows { cursor.getStringOrNull(RawContacts.CONTACT_ID) }
                    .filterNotNull()
                    .toSet()
                    .toList()
            }
                ?: emptyList()
        }

        BatchHelper.forEachSelectionArgsBatch(contactIds) { batch ->
            val selectionParts =
                mutableListOf(
                    "${RawContacts.ACCOUNT_TYPE} = ?",
                    "${RawContacts.ACCOUNT_NAME} = ?",
                    "${RawContacts.CONTACT_ID} IN (${batch.joinToString(",") { "?" }})",
                )
            val selectionArgs = mutableListOf(account.type, account.name)
            selectionArgs.addAll(batch)
            val ids =
                contentResolver.queryAndProcess(
                    RawContacts.CONTENT_URI,
                    projection = arrayOf(RawContacts.CONTACT_ID),
                    selection = selectionParts.joinToString(" AND "),
                    selectionArgs = selectionArgs.toTypedArray(),
                ) { cursor ->
                    cursor
                        .mapRows {
                            cursor.getStringOrNull(
                                RawContacts.CONTACT_ID,
                            )
                        }.filterNotNull()
                        .toSet()
                        .toList()
                }
                    ?: emptyList()
            resultIds.addAll(ids)
        }
        return resultIds.toList()
    }

    fun getRawContactIdsForContact(
        contentResolver: ContentResolver,
        contactId: String,
        account: Account? = null,
    ): List<Long> {
        val selectionParts = mutableListOf("${RawContacts.CONTACT_ID} = ?")
        val selectionArgs = mutableListOf(contactId)
        account?.let {
            selectionParts.add("${RawContacts.ACCOUNT_TYPE} = ?")
            selectionArgs.add(it.type)
            selectionParts.add("${RawContacts.ACCOUNT_NAME} = ?")
            selectionArgs.add(it.name)
        }
        return contentResolver.queryAndProcess(
            RawContacts.CONTENT_URI,
            projection = arrayOf(RawContacts._ID),
            selection = selectionParts.joinToString(" AND "),
            selectionArgs = selectionArgs.toTypedArray(),
        ) { cursor ->
            cursor.mapRows { cursor.getLongOrNull(RawContacts._ID) }.filterNotNull()
        }
            ?: emptyList()
    }

    fun getRawContactIdsForContacts(
        contentResolver: ContentResolver,
        contactIds: List<String>,
    ): Map<String, List<Long>> {
        if (contactIds.isEmpty()) return emptyMap()
        val resultMap = mutableMapOf<String, MutableList<Long>>()
        contactIds.forEach { resultMap[it] = mutableListOf() }
        BatchHelper.forEachSelectionArgsBatch(contactIds) { batch ->
            contentResolver.queryAndProcess(
                RawContacts.CONTENT_URI,
                projection = arrayOf(RawContacts.CONTACT_ID, RawContacts._ID),
                selection =
                    "${RawContacts.CONTACT_ID} IN (${batch.joinToString(",") { "?" }})",
                selectionArgs = batch.toTypedArray(),
            ) { cursor ->
                cursor.forEachRow { row ->
                    val contactId = row.getStringOrNull(RawContacts.CONTACT_ID) ?: return@forEachRow
                    row.getLongOrNull(RawContacts._ID)?.let { rawId ->
                        resultMap[contactId]?.add(rawId)
                    }
                }
            }
        }
        return resultMap
    }

    private fun buildAccountSelection(
        account: Account,
        contactId: String?,
    ): Pair<String, Array<String>> {
        val selectionParts =
            mutableListOf(
                "${RawContacts.ACCOUNT_TYPE} = ?",
                "${RawContacts.ACCOUNT_NAME} = ?",
            )
        val selectionArgs = mutableListOf(account.type, account.name)
        contactId?.let {
            selectionParts.add("${RawContacts.CONTACT_ID} = ?")
            selectionArgs.add(it)
        }
        return selectionParts.joinToString(" AND ") to selectionArgs.toTypedArray()
    }

    fun getAccountsForContact(
        contentResolver: ContentResolver,
        contactId: String,
    ): List<Map<String, String>> =
        contentResolver.queryAndProcess(
            RawContacts.CONTENT_URI,
            projection = arrayOf(RawContacts.ACCOUNT_TYPE, RawContacts.ACCOUNT_NAME),
            selection =
                "${RawContacts.CONTACT_ID} = ? AND ${RawContacts.ACCOUNT_TYPE} IS NOT NULL AND ${RawContacts.ACCOUNT_NAME} IS NOT NULL",
            selectionArgs = arrayOf(contactId),
        ) { cursor ->
            cursor
                .mapRows { cursor ->
                    val type = cursor.getStringOrNull(RawContacts.ACCOUNT_TYPE)
                    val name = cursor.getStringOrNull(RawContacts.ACCOUNT_NAME)
                    if (!name.isNullOrEmpty() && !type.isNullOrEmpty()) {
                        Account(type, name)
                    } else {
                        null
                    }
                }.filterNotNull()
                .toSet()
                .map { it.toJson() }
        }
            ?: emptyList()

    fun getAccountsForContacts(
        contentResolver: ContentResolver,
        contactIds: List<String>,
    ): Map<String, List<Map<String, String>>> {
        if (contactIds.isEmpty()) return emptyMap()
        val accountMap = mutableMapOf<String, MutableSet<Account>>()
        BatchHelper.forEachSelectionArgsBatch(contactIds) { batch ->
            contentResolver.queryAndProcess(
                RawContacts.CONTENT_URI,
                projection =
                    arrayOf(
                        RawContacts.CONTACT_ID,
                        RawContacts.ACCOUNT_TYPE,
                        RawContacts.ACCOUNT_NAME,
                    ),
                selection =
                    "${RawContacts.CONTACT_ID} IN (${batch.joinToString(
                        ",",
                    ) { "?" }}) AND ${RawContacts.ACCOUNT_TYPE} IS NOT NULL AND ${RawContacts.ACCOUNT_NAME} IS NOT NULL",
                selectionArgs = batch.toTypedArray(),
            ) { cursor ->
                cursor.forEachRow { row ->
                    val contactId = row.getStringOrNull(RawContacts.CONTACT_ID) ?: return@forEachRow
                    val type = row.getStringOrNull(RawContacts.ACCOUNT_TYPE)
                    val name = row.getStringOrNull(RawContacts.ACCOUNT_NAME)
                    if (!name.isNullOrEmpty() && !type.isNullOrEmpty()) {
                        accountMap.getOrPut(contactId) { mutableSetOf() }.add(Account(type, name))
                    }
                }
            }
        }
        return accountMap.mapValues { (_, accounts) -> accounts.map { it.toJson() } }
    }

    // Counts properties per rawContactId and returns the one with the most (for update
    // operations)
    fun getRawContactIdWithMostProperties(
        contentResolver: ContentResolver,
        contact: Contact,
        rawContactIds: List<Long>,
    ): Long? {
        if (rawContactIds.isEmpty()) return null

        val rawContactIdStrings = rawContactIds.map { it.toString() }.toSet()
        val propertyCounts =
            buildMap<Long, Int> {
                rawContactIds.forEach { put(it, 0) }

                fun countProperty(metadata: PropertyMetadata?) {
                    val rawContactIdStr = metadata?.rawContactId
                    if (rawContactIdStr != null &&
                        rawContactIdStr in rawContactIdStrings
                    ) {
                        val rawContactId = rawContactIdStr.toLongOrNull()
                        if (rawContactId != null &&
                            rawContactId in rawContactIds
                        ) {
                            put(
                                rawContactId,
                                getOrDefault(rawContactId, 0) + 1,
                            )
                        }
                    }
                }

                contact.name?.metadata?.let { countProperty(it) }
                contact.phones.forEach { countProperty(it.metadata) }
                contact.emails.forEach { countProperty(it.metadata) }
                contact.addresses.forEach { countProperty(it.metadata) }
                contact.organizations.forEach { countProperty(it.metadata) }
                contact.websites.forEach { countProperty(it.metadata) }
                contact.socialMedias.forEach { countProperty(it.metadata) }
                contact.events.forEach { countProperty(it.metadata) }
                contact.relations.forEach { countProperty(it.metadata) }
                contact.notes.forEach { countProperty(it.metadata) }
            }

        return propertyCounts.maxByOrNull { it.value }?.key
    }

    fun getPrimaryRawContactIdForUpdate(
        contentResolver: ContentResolver,
        contact: Contact,
        contactId: String,
        rawContactIds: List<Long>,
        getDefaultAccount: () -> Account?,
    ): Long {
        // Waterfall: (1) rawContactId with most existing properties, (2) rawContactId from
        // default
        // account, (3) first rawContactId
        return getRawContactIdWithMostProperties(contentResolver, contact, rawContactIds)
            ?: run {
                val defaultAccount = getDefaultAccount()
                if (defaultAccount != null) {
                    getRawContactIdsForAccount(
                        contentResolver,
                        defaultAccount,
                        contactId,
                    ).firstOrNull()
                        ?: rawContactIds.first()
                } else {
                    rawContactIds.first()
                }
            }
    }

    fun getDefaultAccount(contentResolver: ContentResolver): Account? {
        if (Build.VERSION.SDK_INT >= 36) {
            @Suppress("NewApi")
            val defaultAccountAndState =
                RawContacts.DefaultAccount.getDefaultAccountForNewContacts(contentResolver)

            @Suppress("NewApi")
            val account = defaultAccountAndState?.account
            if (account != null &&
                account.name.isNotEmpty() &&
                account.type.isNotEmpty()
            ) {
                return Account(account.type, account.name)
            }
        }

        @Suppress("DEPRECATION")
        val defaultAccount = Settings.getDefaultAccount(contentResolver)
        return if (defaultAccount != null &&
            defaultAccount.name.isNotEmpty() &&
            defaultAccount.type.isNotEmpty()
        ) {
            Account(defaultAccount.type, defaultAccount.name)
        } else {
            null
        }
    }
}
