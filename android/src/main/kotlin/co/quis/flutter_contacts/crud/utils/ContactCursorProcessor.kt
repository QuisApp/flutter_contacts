package co.quis.flutter_contacts.crud.utils

import android.database.Cursor
import android.provider.ContactsContract.CommonDataKinds
import android.provider.ContactsContract.Contacts
import android.provider.ContactsContract.Data
import co.quis.flutter_contacts.common.CursorHelpers.getIntOrNull
import co.quis.flutter_contacts.common.CursorHelpers.getLongOrNull
import co.quis.flutter_contacts.common.CursorHelpers.getString
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull
import co.quis.flutter_contacts.crud.models.MutableContact
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

data class ContactLevelFields(
    val displayName: String?,
    val isFavorite: Boolean?,
    val customRingtone: String?,
    val sendToVoicemail: Boolean?,
    val lastUpdatedTimestamp: Long?,
    val lookupKey: String?,
)

object ContactCursorProcessor {
    fun processCursorRow(
        cursor: Cursor,
        properties: Set<String>,
        contactData: MutableContact,
    ) {
        val mimetype = cursor.getString(Data.MIMETYPE, "")

        when (mimetype) {
            CommonDataKinds.Photo.CONTENT_ITEM_TYPE -> {
                if (properties.contains("photoThumbnail")) {
                    contactData.photo = Photo.fromCursor(cursor, contactData.photo)
                }
            }

            CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE,
            CommonDataKinds.Nickname.CONTENT_ITEM_TYPE,
            -> {
                if (properties.contains("name")) {
                    contactData.name = Name.fromCursor(cursor, contactData.name)
                }
            }

            CommonDataKinds.Phone.CONTENT_ITEM_TYPE -> {
                if (properties.contains("phone")) {
                    contactData.phones.add(Phone.fromCursor(cursor))
                }
            }

            CommonDataKinds.Email.CONTENT_ITEM_TYPE -> {
                if (properties.contains("email")) {
                    contactData.emails.add(Email.fromCursor(cursor))
                }
            }

            CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE -> {
                if (properties.contains("address")) {
                    contactData.addresses.add(Address.fromCursor(cursor))
                }
            }

            CommonDataKinds.Organization.CONTENT_ITEM_TYPE -> {
                if (properties.contains("organization")) {
                    Organization.fromCursor(cursor)?.let { contactData.organizations.add(it) }
                }
            }

            CommonDataKinds.Website.CONTENT_ITEM_TYPE -> {
                if (properties.contains("website")) {
                    contactData.websites.add(Website.fromCursor(cursor))
                }
            }

            CommonDataKinds.Im.CONTENT_ITEM_TYPE -> {
                if (properties.contains("socialMedia")) {
                    contactData.socialMedias.add(SocialMedia.fromCursor(cursor))
                }
            }

            CommonDataKinds.Event.CONTENT_ITEM_TYPE -> {
                if (properties.contains("event")) {
                    Event.fromCursor(cursor)?.let { contactData.events.add(it) }
                }
            }

            CommonDataKinds.Relation.CONTENT_ITEM_TYPE -> {
                if (properties.contains("relation")) {
                    contactData.relations.add(Relation.fromCursor(cursor))
                }
            }

            CommonDataKinds.Note.CONTENT_ITEM_TYPE -> {
                if (properties.contains("note")) {
                    Note.fromCursor(cursor)?.let { contactData.notes.add(it) }
                }
            }
        }
    }

    fun processContactLevelFields(
        cursor: Cursor,
        properties: Set<String>,
        contactData: MutableContact,
    ) {
        val fields = extractContactLevelFields(cursor, properties)
        contactData.displayName = fields.displayName
        contactData.isFavorite = fields.isFavorite
        contactData.customRingtone = fields.customRingtone
        contactData.sendToVoicemail = fields.sendToVoicemail
        contactData.lastUpdatedTimestamp = fields.lastUpdatedTimestamp
        contactData.lookupKey = fields.lookupKey
    }

    private fun extractContactLevelFields(
        cursor: Cursor,
        properties: Set<String>,
    ): ContactLevelFields {
        val displayName = cursor.getStringOrNull(Contacts.DISPLAY_NAME_PRIMARY)
        val isFavorite =
            if (properties.contains("favorite")) {
                cursor.getIntOrNull(Contacts.STARRED)?.let { it == 1 }
            } else {
                null
            }
        val customRingtone =
            if (properties.contains("ringtone")) {
                cursor.getStringOrNull(Contacts.CUSTOM_RINGTONE)
            } else {
                null
            }
        val sendToVoicemail =
            if (properties.contains("sendToVoicemail")) {
                cursor.getIntOrNull(Contacts.SEND_TO_VOICEMAIL)?.let { it == 1 }
            } else {
                null
            }
        val lastUpdatedTimestamp =
            if (properties.contains("timestamp")) {
                cursor.getLongOrNull(Contacts.CONTACT_LAST_UPDATED_TIMESTAMP)
            } else {
                null
            }
        val lookupKey =
            if (properties.contains("identifiers")) {
                cursor.getStringOrNull(Contacts.LOOKUP_KEY)
            } else {
                null
            }
        return ContactLevelFields(
            displayName,
            isFavorite,
            customRingtone,
            sendToVoicemail,
            lastUpdatedTimestamp,
            lookupKey,
        )
    }
}
