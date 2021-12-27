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
                Name.fromMap(m["name"] as Map<String, Any>),
                (m["phones"] as List<Map<String, Any>>).map { Phone.fromMap(it) },
                (m["emails"] as List<Map<String, Any>>).map { Email.fromMap(it) },
                (m["addresses"] as List<Map<String, Any>>).map { Address.fromMap(it) },
                (m["organizations"] as List<Map<String, Any>>).map { Organization.fromMap(it) },
                (m["websites"] as List<Map<String, Any>>).map { Website.fromMap(it) },
                (m["socialMedias"] as List<Map<String, Any>>).map { SocialMedia.fromMap(it) },
                (m["events"] as List<Map<String, Any?>>).map { Event.fromMap(it) },
                (m["notes"] as List<Map<String, Any>>).map { Note.fromMap(it) },
                (m["accounts"] as List<Map<String, Any>>).map { Account.fromMap(it) },
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
}
