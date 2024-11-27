package co.quis.flutter_contacts

import co.quis.flutter_contacts.properties.Account
import co.quis.flutter_contacts.properties.Address
import co.quis.flutter_contacts.properties.Email
import co.quis.flutter_contacts.properties.Event
import co.quis.flutter_contacts.properties.Group
import co.quis.flutter_contacts.properties.Name
import co.quis.flutter_contacts.properties.Note
import co.quis.flutter_contacts.properties.Organization
import co.quis.flutter_contacts.properties.Phone
import co.quis.flutter_contacts.properties.SocialMedia
import co.quis.flutter_contacts.properties.Website

data class Contact(
    var id: String,
    var displayName: String,
    var thumbnail: ByteArray? = null,
    var photo: ByteArray? = null,
    val isStarred: Boolean = false,
    var name: Name = Name(),
    var phones: List<Phone> = listOf(),
    var emails: List<Email> = listOf(),
    var addresses: List<Address> = listOf(),
    var organizations: List<Organization> = listOf(),
    var websites: List<Website> = listOf(),
    var socialMedias: List<SocialMedia> = listOf(),
    var events: List<Event> = listOf(),
    var notes: List<Note> = listOf(),
    var accounts: List<Account> = listOf(),
    var groups: List<Group> = listOf()
) {
    companion object {
        fun fromMap(m: Map<String, Any?>): Contact {
            return Contact(
                m["id"] as String,
                m["displayName"] as String,
                m["thumbnail"] as? ByteArray,
                m["photo"] as? ByteArray,
                m["isStarred"] as Boolean,
                @Suppress("UNCHECKED_CAST")
                Name.fromMap(m["name"] as Map<String, Any>),
                @Suppress("UNCHECKED_CAST")
                (m["phones"] as List<Map<String, Any>>).map { Phone.fromMap(it) },
                @Suppress("UNCHECKED_CAST")
                (m["emails"] as List<Map<String, Any>>).map { Email.fromMap(it) },
                @Suppress("UNCHECKED_CAST")
                (m["addresses"] as List<Map<String, Any>>).map { Address.fromMap(it) },
                @Suppress("UNCHECKED_CAST")
                (m["organizations"] as List<Map<String, Any>>).map { Organization.fromMap(it) },
                @Suppress("UNCHECKED_CAST")
                (m["websites"] as List<Map<String, Any>>).map { Website.fromMap(it) },
                @Suppress("UNCHECKED_CAST")
                (m["socialMedias"] as List<Map<String, Any>>).map { SocialMedia.fromMap(it) },
                @Suppress("UNCHECKED_CAST")
                (m["events"] as List<Map<String, Any?>>).map { Event.fromMap(it) },
                @Suppress("UNCHECKED_CAST")
                (m["notes"] as List<Map<String, Any>>).map { Note.fromMap(it) },
                @Suppress("UNCHECKED_CAST")
                (m["accounts"] as List<Map<String, Any>>).map { Account.fromMap(it) },
                @Suppress("UNCHECKED_CAST")
                (m["groups"] as List<Map<String, Any>>).map { Group.fromMap(it) }
            )
        }
    }

    fun toMap(): Map<String, Any?> = mapOf(
        "id" to id,
        "displayName" to displayName,
        "thumbnail" to thumbnail,
        "photo" to photo,
        "isStarred" to isStarred,
        "name" to name.toMap(),
        "phones" to phones.map { it.toMap() },
        "emails" to emails.map { it.toMap() },
        "addresses" to addresses.map { it.toMap() },
        "organizations" to organizations.map { it.toMap() },
        "websites" to websites.map { it.toMap() },
        "socialMedias" to socialMedias.map { it.toMap() },
        "events" to events.map { it.toMap() },
        "notes" to notes.map { it.toMap() },
        "accounts" to accounts.map { it.toMap() },
        "groups" to groups.map { it.toMap() }
    )

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as Contact

        if (id != other.id) return false
        if (displayName != other.displayName) return false
        if (thumbnail != null) {
            if (other.thumbnail == null) return false
            if (!thumbnail.contentEquals(other.thumbnail)) return false
        } else if (other.thumbnail != null) return false
        if (photo != null) {
            if (other.photo == null) return false
            if (!photo.contentEquals(other.photo)) return false
        } else if (other.photo != null) return false
        if (isStarred != other.isStarred) return false
        if (name != other.name) return false
        if (phones != other.phones) return false
        if (emails != other.emails) return false
        if (addresses != other.addresses) return false
        if (organizations != other.organizations) return false
        if (websites != other.websites) return false
        if (socialMedias != other.socialMedias) return false
        if (events != other.events) return false
        if (notes != other.notes) return false
        if (accounts != other.accounts) return false
        if (groups != other.groups) return false

        return true
    }

    override fun hashCode(): Int {
        var result = id.hashCode()
        result = 31 * result + displayName.hashCode()
        result = 31 * result + (thumbnail?.contentHashCode() ?: 0)
        result = 31 * result + (photo?.contentHashCode() ?: 0)
        result = 31 * result + isStarred.hashCode()
        result = 31 * result + name.hashCode()
        result = 31 * result + phones.hashCode()
        result = 31 * result + emails.hashCode()
        result = 31 * result + addresses.hashCode()
        result = 31 * result + organizations.hashCode()
        result = 31 * result + websites.hashCode()
        result = 31 * result + socialMedias.hashCode()
        result = 31 * result + events.hashCode()
        result = 31 * result + notes.hashCode()
        result = 31 * result + accounts.hashCode()
        result = 31 * result + groups.hashCode()
        return result
    }
}
