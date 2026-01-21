package co.quis.flutter_contacts.crud.utils

import android.content.ContentProviderOperation
import co.quis.flutter_contacts.crud.models.properties.Address
import co.quis.flutter_contacts.crud.models.properties.Email
import co.quis.flutter_contacts.crud.models.properties.Event
import co.quis.flutter_contacts.crud.models.properties.Note
import co.quis.flutter_contacts.crud.models.properties.Organization
import co.quis.flutter_contacts.crud.models.properties.Phone
import co.quis.flutter_contacts.crud.models.properties.Relation
import co.quis.flutter_contacts.crud.models.properties.SocialMedia
import co.quis.flutter_contacts.crud.models.properties.Website

object PropertyListUpdater {
    fun <T> updateList(
        ops: MutableList<ContentProviderOperation>,
        oldList: List<T>,
        newList: List<T>,
        rawContactId: Long,
        getDataId: (T) -> String?,
        toInsert: (T, Long) -> ContentProviderOperation,
        toUpdate: (T) -> ContentProviderOperation,
        toDelete: (T) -> ContentProviderOperation,
    ) {
        // Match by dataId: update matches, delete old items not in new, insert new items without
        // dataId
        val oldMap = oldList.associateBy { getDataId(it) }
        val newMap = newList.associateBy { getDataId(it) }

        oldMap.forEach { (dataId, oldItem) ->
            if (dataId != null) {
                newMap[dataId]?.let { ops.add(toUpdate(it)) } ?: ops.add(toDelete(oldItem))
            }
        }
        newList.filter { getDataId(it) == null }.forEach { ops.add(toInsert(it, rawContactId)) }
    }

    fun updatePhones(
        ops: MutableList<ContentProviderOperation>,
        oldList: List<Phone>,
        newList: List<Phone>,
        rawContactId: Long,
    ) = updateList(
        ops,
        oldList,
        newList,
        rawContactId,
        getDataId = { it.metadata?.dataId },
        toInsert = { phone, rawId -> phone.toInsertOperation(rawContactId = rawId) },
        toUpdate = Phone::toUpdateOperation,
        toDelete = Phone::toDeleteOperation,
    )

    fun updateEmails(
        ops: MutableList<ContentProviderOperation>,
        oldList: List<Email>,
        newList: List<Email>,
        rawContactId: Long,
    ) = updateList(
        ops,
        oldList,
        newList,
        rawContactId,
        getDataId = { it.metadata?.dataId },
        toInsert = { email, rawId -> email.toInsertOperation(rawContactId = rawId) },
        toUpdate = Email::toUpdateOperation,
        toDelete = Email::toDeleteOperation,
    )

    fun updateAddresses(
        ops: MutableList<ContentProviderOperation>,
        oldList: List<Address>,
        newList: List<Address>,
        rawContactId: Long,
    ) = updateList(
        ops,
        oldList,
        newList,
        rawContactId,
        getDataId = { it.metadata?.dataId },
        toInsert = { address, rawId -> address.toInsertOperation(rawContactId = rawId) },
        toUpdate = Address::toUpdateOperation,
        toDelete = Address::toDeleteOperation,
    )

    fun updateOrganizations(
        ops: MutableList<ContentProviderOperation>,
        oldList: List<Organization>,
        newList: List<Organization>,
        rawContactId: Long,
    ) = updateList(
        ops,
        oldList,
        newList,
        rawContactId,
        getDataId = { it.metadata?.dataId },
        toInsert = { org, rawId -> org.toInsertOperation(rawContactId = rawId) },
        toUpdate = Organization::toUpdateOperation,
        toDelete = Organization::toDeleteOperation,
    )

    fun updateWebsites(
        ops: MutableList<ContentProviderOperation>,
        oldList: List<Website>,
        newList: List<Website>,
        rawContactId: Long,
    ) = updateList(
        ops,
        oldList,
        newList,
        rawContactId,
        getDataId = { it.metadata?.dataId },
        toInsert = { website, rawId -> website.toInsertOperation(rawContactId = rawId) },
        toUpdate = Website::toUpdateOperation,
        toDelete = Website::toDeleteOperation,
    )

    fun updateSocialMedias(
        ops: MutableList<ContentProviderOperation>,
        oldList: List<SocialMedia>,
        newList: List<SocialMedia>,
        rawContactId: Long,
    ) = updateList(
        ops,
        oldList,
        newList,
        rawContactId,
        getDataId = { it.metadata?.dataId },
        toInsert = { sm, rawId -> sm.toInsertOperation(rawContactId = rawId) },
        toUpdate = SocialMedia::toUpdateOperation,
        toDelete = SocialMedia::toDeleteOperation,
    )

    fun updateEvents(
        ops: MutableList<ContentProviderOperation>,
        oldList: List<Event>,
        newList: List<Event>,
        rawContactId: Long,
    ) = updateList(
        ops,
        oldList,
        newList,
        rawContactId,
        getDataId = { it.metadata?.dataId },
        toInsert = { event, rawId -> event.toInsertOperation(rawContactId = rawId) },
        toUpdate = Event::toUpdateOperation,
        toDelete = Event::toDeleteOperation,
    )

    fun updateRelations(
        ops: MutableList<ContentProviderOperation>,
        oldList: List<Relation>,
        newList: List<Relation>,
        rawContactId: Long,
    ) = updateList(
        ops,
        oldList,
        newList,
        rawContactId,
        getDataId = { it.metadata?.dataId },
        toInsert = { relation, rawId -> relation.toInsertOperation(rawContactId = rawId) },
        toUpdate = Relation::toUpdateOperation,
        toDelete = Relation::toDeleteOperation,
    )

    fun updateNotes(
        ops: MutableList<ContentProviderOperation>,
        oldList: List<Note>,
        newList: List<Note>,
        rawContactId: Long,
    ) = updateList(
        ops,
        oldList,
        newList,
        rawContactId,
        getDataId = { it.metadata?.dataId },
        toInsert = { note, rawId -> note.toInsertOperation(rawContactId = rawId) },
        toUpdate = Note::toUpdateOperation,
        toDelete = Note::toDeleteOperation,
    )
}
