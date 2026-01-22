package co.quis.flutter_contacts.crud.utils

import android.content.ContentResolver
import android.database.Cursor
import android.net.Uri
import android.provider.ContactsContract
import android.provider.ContactsContract.Contacts
import android.provider.ContactsContract.Data
import android.provider.ContactsContract.RawContacts
import co.quis.flutter_contacts.accounts.models.Account
import co.quis.flutter_contacts.crud.models.contact.RawContactInfo
import android.util.Base64
import co.quis.flutter_contacts.common.BatchHelper
import co.quis.flutter_contacts.common.CursorHelpers.forEachRow
import co.quis.flutter_contacts.common.CursorHelpers.getLongOrNull
import co.quis.flutter_contacts.common.CursorHelpers.getString
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull
import co.quis.flutter_contacts.common.CursorHelpers.queryAndProcess
import co.quis.flutter_contacts.crud.models.MutableContact
import co.quis.flutter_contacts.crud.models.contact.Contact
import co.quis.flutter_contacts.crud.models.properties.Photo
import java.util.concurrent.Callable
import java.util.concurrent.Executors
import java.util.concurrent.Future
import android.provider.ContactsContract.CommonDataKinds.Photo as PhotoData

object ContactFetcher {
    private const val MAX_PARALLEL_DATA_QUERIES = 4
    private val dataQueryExecutor = Executors.newFixedThreadPool(MAX_PARALLEL_DATA_QUERIES)

    private fun shouldLoadPhotoThumbnailViaContacts(mimeTypes: Set<String>) =
        mimeTypes.size == 1 && mimeTypes.contains(PhotoData.CONTENT_ITEM_TYPE)

    private fun applyThumbnail(
        contactData: MutableContact,
        contentResolver: ContentResolver,
        thumbnailUri: String?,
    ) {
        Photo.loadThumbnail(contentResolver, thumbnailUri)?.let { photo ->
            contactData.photo = contactData.photo?.mergeWith(photo) ?: photo
        }
    }

    private fun getOrCreateContact(
        contactsMap: MutableMap<String, MutableContact>,
        contactId: String,
    ): MutableContact? =
        contactId.takeIf { it.isNotEmpty() }?.let {
            contactsMap.getOrPut(it) { MutableContact(it, null) }
        }

    private fun fetchContactLevelFields(
        contentResolver: ContentResolver,
        contactIds: List<String>?,
        properties: Set<String>,
        loadPhotoThumbnail: Boolean = false,
    ): MutableMap<String, MutableContact> {
        val contactsMap = mutableMapOf<String, MutableContact>()
        val contactIdSelection = ContactQueryBuilder.buildContactIdSelection(contactIds)
        contentResolver.queryAndProcess(
            Contacts.CONTENT_URI,
            projection =
                PropertyUtils.buildContactsProjection(
                    properties,
                    includePhotoThumbnail = loadPhotoThumbnail,
                ),
            selection = contactIdSelection.selection,
            selectionArgs = contactIdSelection.selectionArgs,
        ) { cursor ->
            cursor.forEachRow { row ->
                val contactData =
                    getOrCreateContact(contactsMap, row.getString(Contacts._ID, "")) ?: return@forEachRow
                ContactCursorProcessor.processContactLevelFields(row, properties, contactData)
                if (loadPhotoThumbnail) {
                    applyThumbnail(
                        contactData,
                        contentResolver,
                        row.getStringOrNull(Contacts.PHOTO_THUMBNAIL_URI),
                    )
                }
            }
        }
        return contactsMap
    }

    private fun splitMimeTypes(mimeTypes: Set<String>): List<Set<String>> {
        if (mimeTypes.isEmpty()) return emptyList()
        val list = mimeTypes.toList()
        val groupCount = minOf(MAX_PARALLEL_DATA_QUERIES, list.size)
        val chunkSize = (list.size + groupCount - 1) / groupCount
        return list.chunked(chunkSize).map { it.toSet() }
    }

    private fun mergeContactMaps(
        target: MutableMap<String, MutableContact>,
        source: Map<String, MutableContact>,
    ) {
        source.forEach { (contactId, partial) ->
            getOrCreateContact(target, contactId)?.mergeFrom(partial)
        }
    }

    private fun queryDataToMap(
        contentResolver: ContentResolver,
        contactId: String?,
        contactIds: List<String>?,
        rawContactIds: List<Long>?,
        account: Account?,
        properties: Set<String>,
        projection: List<String>,
        mimeTypes: Set<String>,
    ): MutableMap<String, MutableContact> {
        val partialContacts = mutableMapOf<String, MutableContact>()
        val selection =
            ContactQueryBuilder.buildDataSelection(
                contactId,
                contactIds,
                rawContactIds,
                account,
                mimeTypes,
                contentResolver,
            )
        contentResolver.queryAndProcess(
            Data.CONTENT_URI,
            projection = projection.toTypedArray(),
            selection = selection.selection,
            selectionArgs = selection.selectionArgs,
        ) { cursor ->
            cursor.forEachRow { row ->
                val contactData =
                    getOrCreateContact(partialContacts, row.getString(Data.CONTACT_ID, ""))
                        ?: return@forEachRow
                ContactCursorProcessor.processCursorRow(row, properties, contactData)
            }
        }
        return partialContacts
    }

    private fun queryDataForSelection(
        contentResolver: ContentResolver,
        contactId: String?,
        contactIds: List<String>?,
        rawContactIds: List<Long>?,
        account: Account?,
        properties: Set<String>,
        projection: List<String>,
        mimeTypes: Set<String>,
        contactsMap: MutableMap<String, MutableContact>,
    ) {
        val groups = splitMimeTypes(mimeTypes)
        if (groups.isEmpty()) return
        if (groups.size == 1) {
            mergeContactMaps(
                contactsMap,
                queryDataToMap(
                    contentResolver = contentResolver,
                    contactId = contactId,
                    contactIds = contactIds,
                    rawContactIds = rawContactIds,
                    account = account,
                    properties = properties,
                    projection = projection,
                    mimeTypes = groups.first(),
                ),
            )
            return
        }

        val futures: List<Future<MutableMap<String, MutableContact>>> =
            groups.map { group ->
                dataQueryExecutor.submit(
                    Callable {
                        queryDataToMap(
                            contentResolver = contentResolver,
                            contactId = contactId,
                            contactIds = contactIds,
                            rawContactIds = rawContactIds,
                            account = account,
                            properties = properties,
                            projection = projection,
                            mimeTypes = group,
                        )
                    },
                )
            }
        futures.forEach { mergeContactMaps(contactsMap, it.get()) }
    }

    fun getContact(
        contentResolver: ContentResolver,
        id: String,
        properties: Set<String>,
        account: Account?,
        rawContactIds: List<Long>?,
        lookup: Boolean = false,
    ): Contact? {
        val contactId = if (lookup) {
            val lookupUri = Uri.withAppendedPath(
                Contacts.CONTENT_LOOKUP_URI,
                id,
            )
            Contacts.lookupContact(contentResolver, lookupUri)?.let { contactUri ->
                contactUri.lastPathSegment
            } ?: return null
        } else {
            id
        }
        val dataMimeTypes = PropertyUtils.dataMimeTypesFor(properties)
        val loadPhotoThumbnailViaContacts = shouldLoadPhotoThumbnailViaContacts(dataMimeTypes)
        val contactsMap =
            fetchContactLevelFields(
                contentResolver,
                contactIds = listOf(contactId),
                properties = properties,
                loadPhotoThumbnail = loadPhotoThumbnailViaContacts,
            )
        val contactData = contactsMap[contactId] ?: return null
        val projection = PropertyUtils.buildDataProjection(properties)

        if (dataMimeTypes.isNotEmpty() && !loadPhotoThumbnailViaContacts) {
            queryDataForSelection(
                contentResolver = contentResolver,
                contactId = contactId,
                contactIds = null,
                rawContactIds = rawContactIds,
                account = account,
                properties = properties,
                projection = projection,
                mimeTypes = dataMimeTypes,
                contactsMap = contactsMap,
            )
        }

        contactData.accounts = AccountUtils.getAccountsForContact(contentResolver, contactId)
        if (properties.contains("identifiers")) {
            fetchRawContactIdentifiers(contentResolver, listOf(contactId), contactsMap)
        }
        return contactData.toContact(properties, contentResolver)
    }

    fun getContacts(
        contentResolver: ContentResolver,
        contactIds: List<String>,
        properties: Set<String>,
        rawContactIdsMap: Map<String, List<Long>>,
    ): Map<String, Contact> {
        if (contactIds.isEmpty()) return emptyMap()
        val resultMap = mutableMapOf<String, Contact>()
        val dataMimeTypes = PropertyUtils.dataMimeTypesFor(properties)
        val loadPhotoThumbnailViaContacts = shouldLoadPhotoThumbnailViaContacts(dataMimeTypes)
        val projection = PropertyUtils.buildDataProjection(properties)

        val contactsMap =
            fetchContactLevelFields(
                contentResolver,
                contactIds = contactIds,
                properties = properties,
                loadPhotoThumbnail = loadPhotoThumbnailViaContacts,
            )
        if (contactsMap.isEmpty()) return emptyMap()
        BatchHelper.forEachSelectionArgsBatch(contactIds) { batchIds ->
            val batchRawContactIds = batchIds.flatMap { rawContactIdsMap[it] ?: emptyList() }
            if (dataMimeTypes.isNotEmpty() && !loadPhotoThumbnailViaContacts) {
                queryDataForSelection(
                    contentResolver = contentResolver,
                    contactId = null,
                    contactIds = batchIds,
                    rawContactIds = batchRawContactIds,
                    account = null,
                    properties = properties,
                    projection = projection,
                    mimeTypes = dataMimeTypes,
                    contactsMap = contactsMap,
                )
            }
            val accountsMap = AccountUtils.getAccountsForContacts(contentResolver, batchIds)
            batchIds.forEach { contactId ->
                contactsMap[contactId]?.accounts = accountsMap[contactId] ?: emptyList()
            }
            if (properties.contains("identifiers")) {
                fetchRawContactIdentifiers(contentResolver, batchIds, contactsMap)
            }
            batchIds.forEach { contactId ->
                contactsMap[contactId]?.let {
                    resultMap[contactId] = it.toContact(properties, contentResolver)
                }
            }
        }
        return resultMap
    }

    fun getAllContacts(
        contentResolver: ContentResolver,
        properties: Set<String>,
        filterDict: Map<String, Any?>?,
        account: Account?,
        limit: Int?,
    ): List<Contact> {
        val filterResult = ContactFilterUtils.parseAndApply(contentResolver, filterDict)
        val contactIds = filterResult.contactIds

        val contactIdSelection = ContactQueryBuilder.buildContactIdSelection(contactIds)
        val dataMimeTypes = PropertyUtils.dataMimeTypesFor(properties)
        val loadPhotoThumbnailViaContacts = shouldLoadPhotoThumbnailViaContacts(dataMimeTypes)
        val dataProjection = PropertyUtils.buildDataProjection(properties)

        val contactIdsToFetch = mutableListOf<String>()
        val contactsMap = mutableMapOf<String, MutableContact>()

        // First, get all contact IDs
        contentResolver.queryAndProcess(
            Contacts.CONTENT_URI,
            projection =
                PropertyUtils.buildContactsProjection(
                    properties,
                    includePhotoThumbnail = loadPhotoThumbnailViaContacts,
                ),
            selection = contactIdSelection.selection,
            selectionArgs = contactIdSelection.selectionArgs,
            sortOrder = "${Contacts.DISPLAY_NAME_PRIMARY} COLLATE UNICODE ASC",
        ) { cursor ->
            cursor.forEachRow { row ->
                val contactData =
                    getOrCreateContact(contactsMap, row.getString(Contacts._ID, "")) ?: return@forEachRow
                ContactCursorProcessor.processContactLevelFields(row, properties, contactData)
                if (loadPhotoThumbnailViaContacts) {
                    applyThumbnail(
                        contactData,
                        contentResolver,
                        row.getStringOrNull(Contacts.PHOTO_THUMBNAIL_URI),
                    )
                }
                contactIdsToFetch.add(contactData.contactId)
            }
        }

        // Apply account filter if needed
        val finalContactIds =
            if (account != null) {
                val accountFilteredIds =
                    AccountUtils
                        .getContactIdsForAccount(
                            contentResolver,
                            account,
                            contactIdsToFetch,
                        ).toSet()
                // Preserve sorted order by filtering the original list
                contactIdsToFetch.filter { it in accountFilteredIds }
            } else {
                contactIdsToFetch
            }

        // Apply limit
        val limitedContactIds = limit?.let { finalContactIds.take(it) } ?: finalContactIds

        if (limitedContactIds.isEmpty()) return emptyList()

        val results = mutableListOf<Contact>()

        BatchHelper.forEachSelectionArgsBatch(limitedContactIds) { batchIds ->
            if (dataMimeTypes.isNotEmpty() && !loadPhotoThumbnailViaContacts) {
                queryDataForSelection(
                    contentResolver = contentResolver,
                    contactId = null,
                    contactIds = batchIds,
                    rawContactIds = null,
                    account = account,
                    properties = properties,
                    projection = dataProjection,
                    mimeTypes = dataMimeTypes,
                    contactsMap = contactsMap,
                )
            }

            val accountsMap = AccountUtils.getAccountsForContacts(contentResolver, batchIds)
            batchIds.forEach { contactId ->
                contactsMap[contactId]?.accounts = accountsMap[contactId] ?: emptyList()
            }

            if (properties.contains("identifiers")) {
                fetchRawContactIdentifiers(contentResolver, batchIds, contactsMap)
            }

            results.addAll(
                batchIds.mapNotNull { contactId ->
                    contactsMap[contactId]?.toContact(properties, contentResolver)
                },
            )
        }

        return results
    }

    fun getProfile(
        contentResolver: ContentResolver,
        properties: Set<String>,
    ): Contact? {
        val profileUri = ContactsContract.Profile.CONTENT_URI
        val dataMimeTypes = PropertyUtils.dataMimeTypesFor(properties)
        val loadPhotoThumbnailViaContacts = shouldLoadPhotoThumbnailViaContacts(dataMimeTypes)
        val projection = PropertyUtils.buildDataProjection(properties)

        val contactsMap = mutableMapOf<String, MutableContact>()
        var profileContactId: String? = null

        // Get profile contact ID
        contentResolver.queryAndProcess(
            profileUri,
            projection =
                PropertyUtils.buildContactsProjection(
                    properties,
                    includePhotoThumbnail = loadPhotoThumbnailViaContacts,
                ),
        ) { cursor ->
            if (cursor.moveToFirst()) {
                profileContactId = cursor.getString(Contacts._ID, "")
                val contactId = profileContactId ?: return@queryAndProcess
                val contactData = contactsMap.getOrPut(contactId) { MutableContact(contactId, null) }
                ContactCursorProcessor.processContactLevelFields(cursor, properties, contactData)
                if (loadPhotoThumbnailViaContacts) {
                    applyThumbnail(
                        contactData,
                        contentResolver,
                        cursor.getStringOrNull(Contacts.PHOTO_THUMBNAIL_URI),
                    )
                }
            }
        }

        profileContactId ?: return null

        // Fetch profile contact data
        if (dataMimeTypes.isNotEmpty() && !loadPhotoThumbnailViaContacts) {
            queryDataForSelection(
                contentResolver = contentResolver,
                contactId = profileContactId,
                contactIds = null,
                rawContactIds = null,
                account = null,
                properties = properties,
                projection = projection,
                mimeTypes = dataMimeTypes,
                contactsMap = contactsMap,
            )
        }

        val contactData = contactsMap[profileContactId!!] ?: return null
        contactData.accounts =
            AccountUtils.getAccountsForContact(contentResolver, profileContactId!!)
        if (properties.contains("identifiers")) {
            fetchRawContactIdentifiers(contentResolver, listOf(profileContactId!!), contactsMap)
        }
        return contactData.toContact(properties, contentResolver)
    }

    fun getDebugData(
        contentResolver: ContentResolver,
        contactId: String,
    ): Map<String, Any?>? {
        val debugDataMap = mutableMapOf<String, MutableList<Map<String, Any?>>>()
        contentResolver
            .query(
                Data.CONTENT_URI,
                null,
                "${Data.CONTACT_ID} = ? AND ${Data.IN_VISIBLE_GROUP} = 1",
                arrayOf(contactId),
                null,
            )?.use { cursor ->
                cursor.forEachRow { row ->
                    val rowMap =
                        (0 until row.columnCount).associate { i ->
                            row.getColumnName(i) to
                                when (row.getType(i)) {
                                    Cursor.FIELD_TYPE_NULL -> {
                                        null
                                    }

                                    Cursor.FIELD_TYPE_INTEGER -> {
                                        row.getLong(i)
                                    }

                                    Cursor.FIELD_TYPE_FLOAT -> {
                                        row.getDouble(i)
                                    }

                                    Cursor.FIELD_TYPE_STRING -> {
                                        row.getString(i)
                                    }

                                    Cursor.FIELD_TYPE_BLOB -> {
                                        Base64.encodeToString(row.getBlob(i), Base64.NO_WRAP)
                                    }

                                    else -> {
                                        row.getString(i)
                                    }
                                }
                        }
                    row.getString(Data.MIMETYPE, "").takeIf { it.isNotEmpty() }?.let { mimetype ->
                        debugDataMap.getOrPut(mimetype) { mutableListOf() }.add(rowMap)
                    }
                }
            }
        return debugDataMap.takeIf { it.isNotEmpty() }
    }

    private fun fetchRawContactIdentifiers(
        contentResolver: ContentResolver,
        contactIds: List<String>,
        contactsMap: MutableMap<String, MutableContact>,
    ) {
        if (contactIds.isEmpty()) return
        contentResolver.queryAndProcess(
            RawContacts.CONTENT_URI,
            projection = arrayOf(
                RawContacts.CONTACT_ID,
                RawContacts._ID,
                RawContacts.SOURCE_ID,
                RawContacts.ACCOUNT_TYPE,
                RawContacts.ACCOUNT_NAME,
            ),
            selection = "${RawContacts.CONTACT_ID} IN (${contactIds.joinToString(",") { "?" }})",
            selectionArgs = contactIds.toTypedArray(),
        ) { cursor ->
            cursor.forEachRow { row ->
                val contactId = row.getStringOrNull(RawContacts.CONTACT_ID) ?: return@forEachRow
                val contactData = contactsMap[contactId] ?: return@forEachRow
                val rawContactId = row.getLongOrNull(RawContacts._ID)?.toString()
                val sourceId = row.getStringOrNull(RawContacts.SOURCE_ID)
                val accountType = row.getStringOrNull(RawContacts.ACCOUNT_TYPE)
                val accountName = row.getStringOrNull(RawContacts.ACCOUNT_NAME)
                val account = if (!accountType.isNullOrEmpty() && !accountName.isNullOrEmpty()) {
                    Account(accountType, accountName)
                } else null
                if (rawContactId != null || sourceId != null || account != null) {
                    contactData.rawContactInfos.add(
                        RawContactInfo(
                            rawContactId = rawContactId,
                            sourceId = sourceId,
                            account = account,
                        ),
                    )
                }
            }
        }
    }
}
