package co.quis.flutter_contacts.crud.models.contact

import co.quis.flutter_contacts.crud.models.JsonHelpers
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
import java.util.Objects

data class Contact(
    val id: String? = null,
    val displayName: String? = null,
    val photo: Photo? = null,
    val name: Name? = null,
    val phones: List<Phone> = emptyList(),
    val emails: List<Email> = emptyList(),
    val addresses: List<Address> = emptyList(),
    val organizations: List<Organization> = emptyList(),
    val websites: List<Website> = emptyList(),
    val socialMedias: List<SocialMedia> = emptyList(),
    val events: List<Event> = emptyList(),
    val relations: List<Relation> = emptyList(),
    val notes: List<Note> = emptyList(),
    val isFavorite: Boolean? = null,
    val customRingtone: String? = null,
    val sendToVoicemail: Boolean? = null,
    val debugData: Map<String, Any?>? = null,
    val metadata: ContactMetadata? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): Contact =
            Contact(
                id = JsonHelpers.decodeOptional(json, "id"),
                displayName = JsonHelpers.decodeOptional(json, "displayName"),
                photo = JsonHelpers.decodeOptionalObject(json, "photo") { Photo.fromJson(it) },
                name = JsonHelpers.decodeOptionalObject(json, "name") { Name.fromJson(it) },
                phones = JsonHelpers.decodeList(json, "phones") { Phone.fromJson(it) },
                emails = JsonHelpers.decodeList(json, "emails") { Email.fromJson(it) },
                addresses = JsonHelpers.decodeList(json, "addresses") { Address.fromJson(it) },
                organizations =
                    JsonHelpers.decodeList(json, "organizations") {
                        Organization.fromJson(it)
                    },
                websites = JsonHelpers.decodeList(json, "websites") { Website.fromJson(it) },
                socialMedias =
                    JsonHelpers.decodeList(json, "socialMedias") {
                        SocialMedia.fromJson(it)
                    },
                events = JsonHelpers.decodeList(json, "events") { Event.fromJson(it) },
                relations = JsonHelpers.decodeList(json, "relations") { Relation.fromJson(it) },
                notes = JsonHelpers.decodeList(json, "notes") { Note.fromJson(it) },
                isFavorite = JsonHelpers.decodeOptional(json, "isFavorite"),
                customRingtone = JsonHelpers.decodeOptional(json, "customRingtone"),
                sendToVoicemail = JsonHelpers.decodeOptional(json, "sendToVoicemail"),
                debugData = JsonHelpers.decodeOptional(json, "debugData"),
                metadata =
                    JsonHelpers.decodeOptionalObject(json, "metadata") {
                        ContactMetadata.fromJson(it)
                    },
            )
    }

    fun toJson(): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>()
        JsonHelpers.encodeOptional(result, "id", id)
        JsonHelpers.encodeOptional(result, "displayName", displayName)
        JsonHelpers.encodeList(result, "phones", phones) { it.toJson() }
        JsonHelpers.encodeList(result, "emails", emails) { it.toJson() }
        JsonHelpers.encodeList(result, "addresses", addresses) { it.toJson() }
        JsonHelpers.encodeList(result, "organizations", organizations) { it.toJson() }
        JsonHelpers.encodeList(result, "websites", websites) { it.toJson() }
        JsonHelpers.encodeList(result, "socialMedias", socialMedias) { it.toJson() }
        JsonHelpers.encodeList(result, "events", events) { it.toJson() }
        JsonHelpers.encodeList(result, "relations", relations) { it.toJson() }
        JsonHelpers.encodeList(result, "notes", notes) { it.toJson() }
        JsonHelpers.encodeOptionalObject(result, "photo", photo) { it.toJson() }
        JsonHelpers.encodeOptionalObject(result, "name", name) { it.toJson() }
        JsonHelpers.encodeOptional(result, "isFavorite", isFavorite)
        JsonHelpers.encodeOptional(result, "customRingtone", customRingtone)
        JsonHelpers.encodeOptional(result, "sendToVoicemail", sendToVoicemail)
        JsonHelpers.encodeOptional(result, "debugData", debugData)
        JsonHelpers.encodeOptionalObject(result, "metadata", metadata) { it.toJson() }
        return result
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Contact) return false
        return id == other.id &&
            displayName == other.displayName &&
            name == other.name &&
            phones == other.phones &&
            emails == other.emails &&
            addresses == other.addresses &&
            organizations == other.organizations &&
            websites == other.websites &&
            socialMedias == other.socialMedias &&
            events == other.events &&
            relations == other.relations &&
            notes == other.notes &&
            isFavorite == other.isFavorite &&
            customRingtone == other.customRingtone &&
            sendToVoicemail == other.sendToVoicemail &&
            photo == other.photo
    }

    override fun hashCode() =
        Objects.hash(
            id,
            displayName,
            name,
            phones,
            emails,
            addresses,
            organizations,
            websites,
            socialMedias,
            events,
            relations,
            notes,
            isFavorite,
            customRingtone,
            sendToVoicemail,
            photo,
        )
}
