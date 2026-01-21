package co.quis.flutter_contacts.listeners.utils

import android.content.Context
import android.os.Handler
import co.quis.flutter_contacts.crud.utils.ContactFetcher
import co.quis.flutter_contacts.crud.utils.PropertyUtils
import co.quis.flutter_contacts.listeners.models.ContactChange
import co.quis.flutter_contacts.listeners.models.ContactChangeType
import java.util.concurrent.ExecutorService

class ContactChangeTracker(
    private val context: Context,
    private val executor: ExecutorService,
    private val mainHandler: Handler,
) {
    fun initializeContactHashes(onHashesInitialized: (Map<String, Int>) -> Unit) {
        onHashesInitialized(getContactHashes())
    }

    fun detectAndReportChanges(
        oldHashes: Map<String, Int>,
        onChangesDetected: (List<ContactChange>) -> Unit,
        onHashesUpdated: (Map<String, Int>) -> Unit,
    ) {
        val newHashes = getContactHashes()

        computeChanges(oldHashes, newHashes)?.let(onChangesDetected)
        onHashesUpdated(newHashes)
    }

    // Computes changes by comparing hash codes: added (in new only), updated (hash changed),
    // removed
    // (in old only)
    private fun computeChanges(
        oldHashes: Map<String, Int>,
        newHashes: Map<String, Int>,
    ): List<ContactChange>? =
        buildList {
            newHashes.forEach { (id, hash) ->
                when {
                    id !in oldHashes -> add(ContactChange(ContactChangeType.ADDED, id))
                    oldHashes[id] != hash -> add(ContactChange(ContactChangeType.UPDATED, id))
                }
            }
            oldHashes.keys.filter { it !in newHashes }.forEach {
                add(ContactChange(ContactChangeType.REMOVED, it))
            }
        }.takeIf { it.isNotEmpty() }

    private fun getContactHashes(): Map<String, Int> {
        val contacts =
            ContactFetcher.getAllContacts(
                context.contentResolver,
                PropertyUtils.ALL_PROPERTIES_WITH_PHOTO_THUMBNAIL,
                null,
                null,
                null,
            )
        return contacts.mapNotNull { it.id?.let { id -> id to it.hashCode() } }.toMap<String, Int>()
    }
}
