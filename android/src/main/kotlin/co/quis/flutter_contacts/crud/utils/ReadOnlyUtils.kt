package co.quis.flutter_contacts.crud.utils

import android.content.ContentResolver
import android.provider.ContactsContract.Data
import co.quis.flutter_contacts.common.BatchHelper
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull
import co.quis.flutter_contacts.common.CursorHelpers.mapRows
import co.quis.flutter_contacts.common.CursorHelpers.queryAndProcess
import co.quis.flutter_contacts.crud.models.contact.Contact

/**
 * Finds properties an update would change on rows a sync adapter marked [Data.IS_READ_ONLY].
 *
 * The provider enforces that flag by narrowing the selection of every non-sync-adapter update, so
 * such an update matches no rows and still reports success. Only in-place updates are narrowed,
 * which limits the risk to properties matched by data ID: inserts, deletes, and the
 * delete-and-reinsert used for names go through regardless.
 *
 * The column is absent from the provider's projection maps, so it throws when named in a projection
 * and works only in a selection. Providers without it report nothing, leaving updates as they were.
 */
object ReadOnlyUtils {
    const val ERROR_CODE = "read_only_contact"

    /**
     * Names of the properties [updates] would change on read-only rows, empty when there are none
     * or when the provider doesn't know the flag.
     *
     * Takes every update at once, as existing-to-new pairs, so a batch costs the same one query as
     * a single contact.
     */
    fun getReadOnlyProperties(
        contentResolver: ContentResolver,
        updates: List<Pair<Contact, Contact>>,
        properties: Set<String>,
    ): Set<String> {
        // Data IDs are unique across contacts, so the maps merge without collisions.
        val changed =
            buildMap {
                updates.forEach { (existingContact, newContact) ->
                    putAll(changedDataIds(existingContact, newContact, properties))
                }
            }
        if (changed.isEmpty()) return emptySet()
        return getReadOnlyDataIds(contentResolver, changed.keys.toList())
            .mapNotNull { changed[it] }
            .toSet()
    }

    /** Data IDs of rows this update would change in place, mapped to their property name. */
    private fun changedDataIds(
        existingContact: Contact,
        newContact: Contact,
        properties: Set<String>,
    ): Map<String, String> =
        buildMap {
            fun <T> collect(
                property: String,
                existing: List<T>,
                new: List<T>,
                dataId: (T) -> String?,
            ) {
                if (property !in properties) return
                val newByDataId = new.associateBy(dataId)
                existing.forEach { oldProperty ->
                    val id = dataId(oldProperty) ?: return@forEach
                    // A missing entry is a delete, and an equal one is an update that changes
                    // nothing. Neither needs the row to be writable. Property equality ignores
                    // metadata, so this compares values.
                    val newProperty = newByDataId[id] ?: return@forEach
                    if (newProperty != oldProperty) put(id, property)
                }
            }

            collect("phone", existingContact.phones, newContact.phones) { it.metadata?.dataId }
            collect("email", existingContact.emails, newContact.emails) { it.metadata?.dataId }
            collect("address", existingContact.addresses, newContact.addresses) { it.metadata?.dataId }
            collect("organization", existingContact.organizations, newContact.organizations) { it.metadata?.dataId }
            collect("website", existingContact.websites, newContact.websites) { it.metadata?.dataId }
            collect("socialMedia", existingContact.socialMedias, newContact.socialMedias) { it.metadata?.dataId }
            collect("event", existingContact.events, newContact.events) { it.metadata?.dataId }
            collect("relation", existingContact.relations, newContact.relations) { it.metadata?.dataId }
            collect("note", existingContact.notes, newContact.notes) { it.metadata?.dataId }
        }

    private fun getReadOnlyDataIds(
        contentResolver: ContentResolver,
        dataIds: List<String>,
    ): Set<String> {
        val readOnly = mutableSetOf<String>()
        BatchHelper.forEachSelectionArgsBatch(dataIds) { batch ->
            runCatching {
                contentResolver.queryAndProcess(
                    Data.CONTENT_URI,
                    projection = arrayOf(Data._ID),
                    selection =
                        "${Data._ID} IN (${batch.joinToString(",") { "?" }}) AND ${Data.IS_READ_ONLY} = 1",
                    selectionArgs = batch.toTypedArray(),
                ) { cursor ->
                    cursor.mapRows { it.getStringOrNull(Data._ID) }.filterNotNull()
                }
                    ?: emptyList()
            }.onSuccess { readOnly.addAll(it) }
        }
        return readOnly
    }
}
