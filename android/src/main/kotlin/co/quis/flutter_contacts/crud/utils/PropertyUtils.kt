@file:Suppress("DEPRECATION")

package co.quis.flutter_contacts.crud.utils

import android.provider.ContactsContract.CommonDataKinds
import android.provider.ContactsContract.Contacts
import android.provider.ContactsContract.Data
import co.quis.flutter_contacts.crud.models.properties.Address
import co.quis.flutter_contacts.crud.models.properties.Email
import co.quis.flutter_contacts.crud.models.properties.Event
import co.quis.flutter_contacts.crud.models.properties.Note
import co.quis.flutter_contacts.crud.models.properties.Organization
import co.quis.flutter_contacts.crud.models.properties.Phone
import co.quis.flutter_contacts.crud.models.properties.Relation
import co.quis.flutter_contacts.crud.models.properties.SocialMedia
import co.quis.flutter_contacts.crud.models.properties.Website

object PropertyUtils {
    /**
     * All contact properties including photoThumbnail (excludes photoFullRes). Equivalent to Dart's
     * ContactProperties.all, but without photoFullRes. Used for detailed listener mode to track all
     * contact changes.
     */
    val ALL_PROPERTIES_WITH_PHOTO_THUMBNAIL =
        setOf(
            "name",
            "phone",
            "email",
            "address",
            "organization",
            "website",
            "socialMedia",
            "event",
            "relation",
            "note",
            "favorite",
            "ringtone",
            "sendToVoicemail",
            "timestamp",
            "photoThumbnail",
        )

    fun buildContactsProjection(
        properties: Set<String>,
        includePhotoThumbnail: Boolean = false,
    ): Array<String> =
        buildList {
            add(Contacts._ID)
            add(Contacts.DISPLAY_NAME_PRIMARY)
            if (properties.contains("favorite")) add(Contacts.STARRED)
            if (properties.contains("ringtone")) add(Contacts.CUSTOM_RINGTONE)
            if (properties.contains("sendToVoicemail")) add(Contacts.SEND_TO_VOICEMAIL)
            if (properties.contains("timestamp")) add(Contacts.CONTACT_LAST_UPDATED_TIMESTAMP)
            if (includePhotoThumbnail) add(Contacts.PHOTO_THUMBNAIL_URI)
        }.toTypedArray()

    fun buildDataProjection(properties: Set<String>): List<String> =
        buildList {
            add(Data.CONTACT_ID)
            add(Data.MIMETYPE)
            add(Data._ID)
            add(Data.RAW_CONTACT_ID)

            if (properties.contains("photoThumbnail")) add(CommonDataKinds.Photo.PHOTO)

            if (properties.contains("name")) {
                addAll(
                    listOf(
                        CommonDataKinds.StructuredName.PREFIX,
                        CommonDataKinds.StructuredName.GIVEN_NAME,
                        CommonDataKinds.StructuredName.MIDDLE_NAME,
                        CommonDataKinds.StructuredName.FAMILY_NAME,
                        CommonDataKinds.StructuredName.SUFFIX,
                        CommonDataKinds.StructuredName.PHONETIC_GIVEN_NAME,
                        CommonDataKinds.StructuredName.PHONETIC_FAMILY_NAME,
                        CommonDataKinds.StructuredName.PHONETIC_MIDDLE_NAME,
                        CommonDataKinds.Nickname.NAME,
                    ),
                )
            }

            if (properties.contains("phone")) {
                addAll(
                    listOf(
                        CommonDataKinds.Phone.NUMBER,
                        CommonDataKinds.Phone.NORMALIZED_NUMBER,
                        CommonDataKinds.Phone.TYPE,
                        CommonDataKinds.Phone.LABEL,
                        CommonDataKinds.Phone.IS_PRIMARY,
                    ),
                )
            }

            if (properties.contains("email")) {
                addAll(
                    listOf(
                        CommonDataKinds.Email.ADDRESS,
                        CommonDataKinds.Email.TYPE,
                        CommonDataKinds.Email.LABEL,
                        CommonDataKinds.Email.IS_PRIMARY,
                    ),
                )
            }

            if (properties.contains("address")) {
                addAll(
                    listOf(
                        CommonDataKinds.StructuredPostal.FORMATTED_ADDRESS,
                        CommonDataKinds.StructuredPostal.STREET,
                        CommonDataKinds.StructuredPostal.POBOX,
                        CommonDataKinds.StructuredPostal.NEIGHBORHOOD,
                        CommonDataKinds.StructuredPostal.CITY,
                        CommonDataKinds.StructuredPostal.REGION,
                        CommonDataKinds.StructuredPostal.POSTCODE,
                        CommonDataKinds.StructuredPostal.COUNTRY,
                        CommonDataKinds.StructuredPostal.TYPE,
                        CommonDataKinds.StructuredPostal.LABEL,
                    ),
                )
            }

            if (properties.contains("organization")) {
                addAll(
                    listOf(
                        CommonDataKinds.Organization.COMPANY,
                        CommonDataKinds.Organization.TITLE,
                        CommonDataKinds.Organization.DEPARTMENT,
                        CommonDataKinds.Organization.JOB_DESCRIPTION,
                        CommonDataKinds.Organization.SYMBOL,
                        CommonDataKinds.Organization.PHONETIC_NAME,
                        CommonDataKinds.Organization.OFFICE_LOCATION,
                    ),
                )
            }

            if (properties.contains("website")) {
                addAll(
                    listOf(
                        CommonDataKinds.Website.URL,
                        CommonDataKinds.Website.TYPE,
                        CommonDataKinds.Website.LABEL,
                    ),
                )
            }

            if (properties.contains("socialMedia")) {
                addAll(
                    listOf(
                        CommonDataKinds.Im.DATA,
                        CommonDataKinds.Im.PROTOCOL,
                        CommonDataKinds.Im.CUSTOM_PROTOCOL,
                    ),
                )
            }

            if (properties.contains("event")) {
                addAll(
                    listOf(
                        CommonDataKinds.Event.START_DATE,
                        CommonDataKinds.Event.TYPE,
                        CommonDataKinds.Event.LABEL,
                    ),
                )
            }

            if (properties.contains("relation")) {
                addAll(
                    listOf(
                        CommonDataKinds.Relation.NAME,
                        CommonDataKinds.Relation.TYPE,
                        CommonDataKinds.Relation.LABEL,
                    ),
                )
            }

            if (properties.contains("note")) {
                add(CommonDataKinds.Note.NOTE)
            }
        }

    fun dataMimeTypesFor(properties: Set<String>): Set<String> =
        buildSet {
            if (properties.contains("photoThumbnail")) add(CommonDataKinds.Photo.CONTENT_ITEM_TYPE)
            if (properties.contains("name")) {
                add(CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE)
                add(CommonDataKinds.Nickname.CONTENT_ITEM_TYPE)
            }
            if (properties.contains("phone")) add(CommonDataKinds.Phone.CONTENT_ITEM_TYPE)
            if (properties.contains("email")) add(CommonDataKinds.Email.CONTENT_ITEM_TYPE)
            if (properties.contains("address")) add(CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE)
            if (properties.contains("organization")) add(CommonDataKinds.Organization.CONTENT_ITEM_TYPE)
            if (properties.contains("website")) add(CommonDataKinds.Website.CONTENT_ITEM_TYPE)
            if (properties.contains("socialMedia")) add(CommonDataKinds.Im.CONTENT_ITEM_TYPE)
            if (properties.contains("event")) add(CommonDataKinds.Event.CONTENT_ITEM_TYPE)
            if (properties.contains("relation")) add(CommonDataKinds.Relation.CONTENT_ITEM_TYPE)
            if (properties.contains("note")) add(CommonDataKinds.Note.CONTENT_ITEM_TYPE)
        }

    private fun <T> sortByDataId(
        items: List<T>,
        dataId: (T) -> String?,
    ) = items.sortedWith(compareBy { dataId(it).orEmpty() })

    private fun <T> sortByPrimaryThenId(
        items: List<T>,
        isPrimary: (T) -> Boolean?,
        dataId: (T) -> String?,
    ) = items.sortedWith(compareBy({ isPrimary(it) != true }, { dataId(it).orEmpty() }))

    fun sortPhones(phones: List<Phone>) = sortByPrimaryThenId(phones, isPrimary = { it.isPrimary }, dataId = { it.metadata?.dataId })

    fun sortEmails(emails: List<Email>) = sortByPrimaryThenId(emails, isPrimary = { it.isPrimary }, dataId = { it.metadata?.dataId })

    fun sortAddresses(addresses: List<Address>) = sortByDataId(addresses) { it.metadata?.dataId }

    fun sortOrganizations(organizations: List<Organization>) = sortByDataId(organizations) { it.metadata?.dataId }

    fun sortWebsites(websites: List<Website>) = sortByDataId(websites) { it.metadata?.dataId }

    fun sortSocialMedias(socialMedias: List<SocialMedia>) = sortByDataId(socialMedias) { it.metadata?.dataId }

    fun sortEvents(events: List<Event>) = sortByDataId(events) { it.metadata?.dataId }

    fun sortRelations(relations: List<Relation>) = sortByDataId(relations) { it.metadata?.dataId }

    fun sortNotes(notes: List<Note>) = sortByDataId(notes) { it.metadata?.dataId }
}
