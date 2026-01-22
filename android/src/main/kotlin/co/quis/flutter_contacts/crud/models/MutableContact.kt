package co.quis.flutter_contacts.crud.models

import android.content.ContentResolver
import co.quis.flutter_contacts.crud.models.contact.AndroidData
import co.quis.flutter_contacts.crud.models.contact.AndroidIdentifiers
import co.quis.flutter_contacts.crud.models.contact.Contact
import co.quis.flutter_contacts.crud.models.contact.ContactMetadata
import co.quis.flutter_contacts.crud.models.contact.RawContactInfo
import co.quis.flutter_contacts.crud.models.properties.Address
import co.quis.flutter_contacts.crud.models.properties.Email
import co.quis.flutter_contacts.crud.models.properties.Event
import co.quis.flutter_contacts.crud.models.properties.Name
import co.quis.flutter_contacts.crud.models.properties.Note
import co.quis.flutter_contacts.crud.models.properties.Organization
import co.quis.flutter_contacts.crud.models.properties.Phone
import co.quis.flutter_contacts.crud.models.properties.Photo
import co.quis.flutter_contacts.crud.models.properties.Relation
import co.quis.flutter_contacts.crud.models.properties.SocialMedia
import co.quis.flutter_contacts.crud.models.properties.Website
import co.quis.flutter_contacts.crud.utils.ContactFetcher
import co.quis.flutter_contacts.crud.utils.PropertyUtils

data class MutableContact(
    val contactId: String,
    var displayName: String? = null,
    var photo: Photo? = null,
    var name: Name? = null,
    val phones: MutableList<Phone> = mutableListOf(),
    val emails: MutableList<Email> = mutableListOf(),
    val addresses: MutableList<Address> = mutableListOf(),
    val organizations: MutableList<Organization> = mutableListOf(),
    val websites: MutableList<Website> = mutableListOf(),
    val socialMedias: MutableList<SocialMedia> = mutableListOf(),
    val events: MutableList<Event> = mutableListOf(),
    val relations: MutableList<Relation> = mutableListOf(),
    val notes: MutableList<Note> = mutableListOf(),
    var isFavorite: Boolean? = null,
    var customRingtone: String? = null,
    var sendToVoicemail: Boolean? = null,
    var lastUpdatedTimestamp: Long? = null,
    var lookupKey: String? = null,
    val rawContactInfos: MutableList<RawContactInfo> = mutableListOf(),
    var accounts: List<Map<String, String>> = emptyList(),
) {
    fun mergeFrom(other: MutableContact) {
        displayName = displayName ?: other.displayName
        photo =
            when {
                photo == null -> other.photo
                other.photo == null -> photo
                else -> photo?.mergeWith(other.photo!!)
            }
        name =
            when {
                name == null -> other.name
                other.name == null -> name
                else -> name?.mergeWith(other.name!!)
            }
        phones.addAll(other.phones)
        emails.addAll(other.emails)
        addresses.addAll(other.addresses)
        organizations.addAll(other.organizations)
        websites.addAll(other.websites)
        socialMedias.addAll(other.socialMedias)
        events.addAll(other.events)
        relations.addAll(other.relations)
        notes.addAll(other.notes)
        isFavorite = isFavorite ?: other.isFavorite
        customRingtone = customRingtone ?: other.customRingtone
        sendToVoicemail = sendToVoicemail ?: other.sendToVoicemail
        lastUpdatedTimestamp = lastUpdatedTimestamp ?: other.lastUpdatedTimestamp
        if (accounts.isEmpty()) accounts = other.accounts
    }

    fun toContact(
        properties: Set<String>,
        contentResolver: ContentResolver,
    ): Contact =
        Contact(
            id = contactId,
            displayName = displayName,
            photo =
                if (properties.contains("photoFullRes")) {
                    Photo.loadFullSize(contentResolver, contactId, photo)
                } else {
                    photo
                },
            name = name,
            phones = PropertyUtils.sortPhones(phones),
            emails = PropertyUtils.sortEmails(emails),
            addresses = PropertyUtils.sortAddresses(addresses),
            organizations = PropertyUtils.sortOrganizations(organizations),
            websites = PropertyUtils.sortWebsites(websites),
            socialMedias = PropertyUtils.sortSocialMedias(socialMedias),
            events = PropertyUtils.sortEvents(events),
            relations = PropertyUtils.sortRelations(relations),
            notes = PropertyUtils.sortNotes(notes),
            android =
                run {
                    val debugData =
                        if (properties.contains("debugData")) {
                            ContactFetcher.getDebugData(contentResolver, contactId)
                        } else {
                            null
                        }
                    val identifiers = AndroidIdentifiers(lookupKey, rawContactInfos.toList()).takeIf { it.isNotEmpty() }
                    AndroidData(
                        isFavorite = isFavorite,
                        customRingtone = customRingtone,
                        sendToVoicemail = sendToVoicemail,
                        lastUpdatedTimestamp = lastUpdatedTimestamp,
                        identifiers = identifiers,
                        debugData = debugData,
                    ).takeIf { it.isNotEmpty() }
                },
            metadata = ContactMetadata.fromPropertiesSet(properties, accounts),
        )
}
