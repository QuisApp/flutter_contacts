@file:Suppress("DEPRECATION")

package co.quis.flutter_contacts.crud.utils

import android.content.ContentProviderOperation
import android.content.ContentResolver
import android.content.ContentUris
import android.content.ContentValues
import android.provider.ContactsContract.CommonDataKinds
import android.provider.ContactsContract.Contacts
import android.provider.ContactsContract.Data
import android.provider.ContactsContract.RawContacts
import co.quis.flutter_contacts.accounts.models.Account
import co.quis.flutter_contacts.crud.models.contact.Contact
import co.quis.flutter_contacts.crud.models.labels.AddressLabel
import co.quis.flutter_contacts.crud.models.labels.EmailLabel
import co.quis.flutter_contacts.crud.models.labels.EventLabel
import co.quis.flutter_contacts.crud.models.labels.PhoneLabel
import co.quis.flutter_contacts.crud.models.labels.RelationLabel
import co.quis.flutter_contacts.crud.models.labels.SocialMediaLabel
import co.quis.flutter_contacts.crud.models.labels.WebsiteLabel
import co.quis.flutter_contacts.crud.models.properties.Address
import co.quis.flutter_contacts.crud.models.properties.Email
import co.quis.flutter_contacts.crud.models.properties.Event
import co.quis.flutter_contacts.crud.models.properties.Name
import co.quis.flutter_contacts.crud.models.properties.Note
import co.quis.flutter_contacts.crud.models.properties.Organization
import co.quis.flutter_contacts.crud.models.properties.Phone
import co.quis.flutter_contacts.crud.models.properties.Relation
import co.quis.flutter_contacts.crud.models.properties.SocialMedia
import co.quis.flutter_contacts.crud.models.properties.Website

object ContactBuilder {
    fun buildCreateOperations(
        contact: Contact,
        account: Account?,
        rawContactIndex: Int = 0,
        startOpIndex: Int = 0,
        shouldAddYield: ((Int) -> Boolean)? = null,
    ): List<ContentProviderOperation> {
        val ops = ArrayList<ContentProviderOperation>()
        var opIndex = startOpIndex

        fun shouldYield() = shouldAddYield?.invoke(opIndex) == true

        fun addOp(op: ContentProviderOperation) {
            ops.add(op)
            opIndex++
        }

        fun addOps(newOps: List<ContentProviderOperation>) {
            ops.addAll(newOps)
            opIndex += newOps.size
        }

        fun <T> addEach(
            items: List<T>,
            build: (T, Boolean) -> ContentProviderOperation,
        ) = items.forEach { addOp(build(it, shouldYield())) }

        addOp(
            ContentProviderOperation
                .newInsert(RawContacts.CONTENT_URI)
                .apply {
                    account?.let {
                        withValue(RawContacts.ACCOUNT_TYPE, it.type)
                        withValue(RawContacts.ACCOUNT_NAME, it.name)
                    }
                }.build(),
        )

        contact.name?.let {
            addOps(it.toInsertOperations(rawContactIndex, addYield = shouldYield()))
        }
        addEach(contact.phones) { phone, addYield ->
            phone.toInsertOperation(rawContactIndex = rawContactIndex, addYield = addYield)
        }
        addEach(contact.emails) { email, addYield ->
            email.toInsertOperation(rawContactIndex = rawContactIndex, addYield = addYield)
        }
        addEach(contact.addresses) { address, addYield ->
            address.toInsertOperation(rawContactIndex = rawContactIndex, addYield = addYield)
        }
        addEach(contact.organizations) { org, addYield ->
            org.toInsertOperation(rawContactIndex = rawContactIndex, addYield = addYield)
        }
        addEach(contact.websites) { website, addYield ->
            website.toInsertOperation(rawContactIndex = rawContactIndex, addYield = addYield)
        }
        addEach(contact.socialMedias) { social, addYield ->
            social.toInsertOperation(rawContactIndex = rawContactIndex, addYield = addYield)
        }
        addEach(contact.events) { event, addYield ->
            event.toInsertOperation(rawContactIndex = rawContactIndex, addYield = addYield)
        }
        addEach(contact.relations) { relation, addYield ->
            relation.toInsertOperation(rawContactIndex = rawContactIndex, addYield = addYield)
        }
        contact.notes.asSequence().filter { it.note.isNotEmpty() }.forEach { note ->
            addOp(note.toInsertOperation(rawContactIndex = rawContactIndex, addYield = shouldYield()))
        }

        return ops
    }

    fun buildUpdateOperations(
        contentResolver: ContentResolver,
        existingContact: Contact,
        newContact: Contact,
        properties: Set<String>,
        rawContactId: Long,
    ): List<ContentProviderOperation> {
        val ops = mutableListOf<ContentProviderOperation>()

        fun updateIf(
            property: String,
            block: () -> Unit,
        ) {
            if (property in properties) block()
        }

        updateIf("name") { newContact.name?.let { ops.addAll(it.toUpdateOperations(rawContactId)) } }
        updateIf("phone") {
            PropertyListUpdater.updatePhones(ops, existingContact.phones, newContact.phones, rawContactId)
        }
        updateIf("email") {
            PropertyListUpdater.updateEmails(ops, existingContact.emails, newContact.emails, rawContactId)
        }
        updateIf("address") {
            PropertyListUpdater.updateAddresses(ops, existingContact.addresses, newContact.addresses, rawContactId)
        }
        updateIf("organization") {
            PropertyListUpdater.updateOrganizations(
                ops,
                existingContact.organizations,
                newContact.organizations,
                rawContactId,
            )
        }
        updateIf("website") {
            PropertyListUpdater.updateWebsites(ops, existingContact.websites, newContact.websites, rawContactId)
        }
        updateIf("socialMedia") {
            PropertyListUpdater.updateSocialMedias(
                ops,
                existingContact.socialMedias,
                newContact.socialMedias,
                rawContactId,
            )
        }
        updateIf("event") {
            PropertyListUpdater.updateEvents(ops, existingContact.events, newContact.events, rawContactId)
        }
        updateIf("relation") {
            PropertyListUpdater.updateRelations(ops, existingContact.relations, newContact.relations, rawContactId)
        }
        updateIf("note") {
            PropertyListUpdater.updateNotes(ops, existingContact.notes, newContact.notes, rawContactId)
        }

        val contactId = existingContact.id!!.toLong()
        val updateOp =
            ContentProviderOperation.newUpdate(
                ContentUris.withAppendedId(Contacts.CONTENT_URI, contactId),
            )
        var needsUpdate = false

        fun updateFlag(
            property: String,
            newValue: Boolean?,
            oldValue: Boolean?,
            column: String,
        ) {
            if (property in properties && newValue != oldValue) {
                newValue?.let {
                    updateOp.withValue(column, if (it) 1 else 0)
                    needsUpdate = true
                }
            }
        }

        fun updateString(
            property: String,
            newValue: String?,
            oldValue: String?,
            column: String,
        ) {
            if (property in properties && newValue != oldValue) {
                newValue?.let {
                    updateOp.withValue(column, it)
                    needsUpdate = true
                }
            }
        }

        updateFlag("favorite", newContact.isFavorite, existingContact.isFavorite, Contacts.STARRED)
        updateString("ringtone", newContact.customRingtone, existingContact.customRingtone, Contacts.CUSTOM_RINGTONE)
        updateFlag(
            "sendToVoicemail",
            newContact.sendToVoicemail,
            existingContact.sendToVoicemail,
            Contacts.SEND_TO_VOICEMAIL,
        )
        if (needsUpdate) ops.add(updateOp.build())

        return ops
    }

    fun buildContactOptionsOperations(
        contactId: Long,
        contact: Contact,
    ): ContentProviderOperation? {
        val updateOp =
            ContentProviderOperation.newUpdate(
                ContentUris.withAppendedId(Contacts.CONTENT_URI, contactId),
            )
        var needsUpdate = false

        fun putFlag(
            value: Boolean?,
            column: String,
        ) {
            value?.let {
                updateOp.withValue(column, if (it) 1 else 0)
                needsUpdate = true
            }
        }

        fun putString(
            value: String?,
            column: String,
        ) {
            value?.let {
                updateOp.withValue(column, it)
                needsUpdate = true
            }
        }

        putFlag(contact.isFavorite, Contacts.STARRED)
        putString(contact.customRingtone, Contacts.CUSTOM_RINGTONE)
        putFlag(contact.sendToVoicemail, Contacts.SEND_TO_VOICEMAIL)

        return if (needsUpdate) updateOp.build() else null
    }

    fun buildInsertDataForIntent(contact: Contact): ArrayList<ContentValues> {
        val dataList = ArrayList<ContentValues>()
        contact.name?.let { addNameToIntent(it, dataList) }
        contact.phones.forEach { addPhoneToIntent(it, dataList) }
        contact.emails.forEach { addEmailToIntent(it, dataList) }
        contact.addresses.forEach { addAddressToIntent(it, dataList) }
        contact.organizations.forEach { addOrganizationToIntent(it, dataList) }
        contact.websites.forEach { addWebsiteToIntent(it, dataList) }
        contact.socialMedias.forEach { addSocialMediaToIntent(it, dataList) }
        contact.events.forEach { addEventToIntent(it, dataList) }
        contact.relations.forEach { addRelationToIntent(it, dataList) }
        contact.notes.filter { it.note.isNotEmpty() }.forEach { addNoteToIntent(it, dataList) }
        return dataList
    }

    private fun addNameToIntent(
        name: Name,
        dataList: ArrayList<ContentValues>,
    ) {
        val values =
            ContentValues().apply {
                put(Data.MIMETYPE, CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE)
                putIfNotBlank(CommonDataKinds.StructuredName.PREFIX, name.prefix)
                putIfNotBlank(CommonDataKinds.StructuredName.GIVEN_NAME, name.first)
                putIfNotBlank(CommonDataKinds.StructuredName.MIDDLE_NAME, name.middle)
                putIfNotBlank(CommonDataKinds.StructuredName.FAMILY_NAME, name.last)
                putIfNotBlank(CommonDataKinds.StructuredName.SUFFIX, name.suffix)
                putIfNotBlank(CommonDataKinds.StructuredName.PHONETIC_GIVEN_NAME, name.phoneticFirst)
                putIfNotBlank(CommonDataKinds.StructuredName.PHONETIC_MIDDLE_NAME, name.phoneticMiddle)
                putIfNotBlank(CommonDataKinds.StructuredName.PHONETIC_FAMILY_NAME, name.phoneticLast)
            }
        if (values.size() > 1) dataList.add(values)
    }

    private fun addPhoneToIntent(
        phone: Phone,
        dataList: ArrayList<ContentValues>,
    ) {
        val (type, label) = PhoneLabel.toAndroidLabel(phone.label.label, phone.label.customLabel)
        dataList.add(
            ContentValues().apply {
                put(Data.MIMETYPE, CommonDataKinds.Phone.CONTENT_ITEM_TYPE)
                put(CommonDataKinds.Phone.NUMBER, phone.number)
                putTypeAndLabel(
                    CommonDataKinds.Phone.TYPE,
                    CommonDataKinds.Phone.LABEL,
                    type,
                    label,
                    CommonDataKinds.Phone.TYPE_CUSTOM,
                )
            },
        )
    }

    private fun addEmailToIntent(
        email: Email,
        dataList: ArrayList<ContentValues>,
    ) {
        val (type, label) = EmailLabel.toAndroidLabel(email.label.label, email.label.customLabel)
        dataList.add(
            ContentValues().apply {
                put(Data.MIMETYPE, CommonDataKinds.Email.CONTENT_ITEM_TYPE)
                put(CommonDataKinds.Email.ADDRESS, email.address)
                putTypeAndLabel(
                    CommonDataKinds.Email.TYPE,
                    CommonDataKinds.Email.LABEL,
                    type,
                    label,
                    CommonDataKinds.Email.TYPE_CUSTOM,
                )
            },
        )
    }

    private fun addAddressToIntent(
        addr: Address,
        dataList: ArrayList<ContentValues>,
    ) {
        if (hasAnyNonBlank(
                addr.formatted,
                addr.street,
                addr.poBox,
                addr.neighborhood,
                addr.city,
                addr.state,
                addr.postalCode,
                addr.country,
            )
        ) {
            val (type, label) =
                AddressLabel.toAndroidLabel(addr.label.label, addr.label.customLabel)
            dataList.add(
                ContentValues().apply {
                    put(Data.MIMETYPE, CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE)
                    putIfNotBlank(CommonDataKinds.StructuredPostal.FORMATTED_ADDRESS, addr.formatted)
                    putIfNotBlank(CommonDataKinds.StructuredPostal.STREET, addr.street)
                    putIfNotBlank(CommonDataKinds.StructuredPostal.POBOX, addr.poBox)
                    putIfNotBlank(CommonDataKinds.StructuredPostal.NEIGHBORHOOD, addr.neighborhood)
                    putIfNotBlank(CommonDataKinds.StructuredPostal.CITY, addr.city)
                    putIfNotBlank(CommonDataKinds.StructuredPostal.REGION, addr.state)
                    putIfNotBlank(CommonDataKinds.StructuredPostal.POSTCODE, addr.postalCode)
                    putIfNotBlank(CommonDataKinds.StructuredPostal.COUNTRY, addr.country)
                    putTypeAndLabel(
                        CommonDataKinds.StructuredPostal.TYPE,
                        CommonDataKinds.StructuredPostal.LABEL,
                        type,
                        label,
                    )
                },
            )
        }
    }

    private fun addOrganizationToIntent(
        org: Organization,
        dataList: ArrayList<ContentValues>,
    ) {
        val values =
            ContentValues().apply {
                put(Data.MIMETYPE, CommonDataKinds.Organization.CONTENT_ITEM_TYPE)
                putIfNotBlank(CommonDataKinds.Organization.COMPANY, org.name)
                putIfNotBlank(CommonDataKinds.Organization.TITLE, org.jobTitle)
                putIfNotBlank(CommonDataKinds.Organization.DEPARTMENT, org.departmentName)
                putIfNotBlank(CommonDataKinds.Organization.PHONETIC_NAME, org.phoneticName)
                putIfNotBlank(CommonDataKinds.Organization.JOB_DESCRIPTION, org.jobDescription)
                putIfNotBlank(CommonDataKinds.Organization.SYMBOL, org.symbol)
                putIfNotBlank(CommonDataKinds.Organization.OFFICE_LOCATION, org.officeLocation)
            }
        if (values.size() > 1) dataList.add(values)
    }

    private fun addWebsiteToIntent(
        website: Website,
        dataList: ArrayList<ContentValues>,
    ) {
        if (website.url.isNotEmpty()) {
            val (type, label) =
                WebsiteLabel.toAndroidLabel(website.label.label, website.label.customLabel)
            dataList.add(
                ContentValues().apply {
                    put(Data.MIMETYPE, CommonDataKinds.Website.CONTENT_ITEM_TYPE)
                    put(CommonDataKinds.Website.URL, website.url)
                    putTypeAndLabel(CommonDataKinds.Website.TYPE, CommonDataKinds.Website.LABEL, type, label)
                },
            )
        }
    }

    private fun addSocialMediaToIntent(
        social: SocialMedia,
        dataList: ArrayList<ContentValues>,
    ) {
        if (social.username.isNotEmpty()) {
            val (protocol, customProtocol) =
                SocialMediaLabel.toAndroidLabel(social.label.label, social.label.customLabel)
            dataList.add(
                ContentValues().apply {
                    put(Data.MIMETYPE, CommonDataKinds.Im.CONTENT_ITEM_TYPE)
                    put(CommonDataKinds.Im.DATA, social.username)
                    put(CommonDataKinds.Im.PROTOCOL, protocol)
                    put(CommonDataKinds.Im.CUSTOM_PROTOCOL, customProtocol)
                },
            )
        }
    }

    private fun addEventToIntent(
        event: Event,
        dataList: ArrayList<ContentValues>,
    ) {
        val dateString =
            if (event.year != null) {
                String.format("%04d-%02d-%02d", event.year, event.month, event.day)
            } else {
                String.format("--%02d-%02d", event.month, event.day)
            }
        val (eventType, customLabel) =
            EventLabel.toAndroidLabel(event.label.label, event.label.customLabel)
        dataList.add(
            ContentValues().apply {
                put(Data.MIMETYPE, CommonDataKinds.Event.CONTENT_ITEM_TYPE)
                put(CommonDataKinds.Event.START_DATE, dateString)
                put(CommonDataKinds.Event.TYPE, eventType)
                if (eventType == CommonDataKinds.Event.TYPE_CUSTOM && customLabel.isNotEmpty()) {
                    put(CommonDataKinds.Event.LABEL, customLabel)
                }
            },
        )
    }

    private fun addRelationToIntent(
        relation: Relation,
        dataList: ArrayList<ContentValues>,
    ) {
        val (relationType, customLabel) =
            RelationLabel.toAndroidLabel(relation.label.label, relation.label.customLabel)
        dataList.add(
            ContentValues().apply {
                put(Data.MIMETYPE, CommonDataKinds.Relation.CONTENT_ITEM_TYPE)
                put(CommonDataKinds.Relation.NAME, relation.name)
                putTypeAndLabel(
                    CommonDataKinds.Relation.TYPE,
                    CommonDataKinds.Relation.LABEL,
                    relationType,
                    customLabel,
                    CommonDataKinds.Relation.TYPE_CUSTOM,
                )
            },
        )
    }

    private fun addNoteToIntent(
        note: Note,
        dataList: ArrayList<ContentValues>,
    ) {
        dataList.add(
            ContentValues().apply {
                put(Data.MIMETYPE, CommonDataKinds.Note.CONTENT_ITEM_TYPE)
                put(CommonDataKinds.Note.NOTE, note.note)
            },
        )
    }

    private fun ContentValues.putIfNotBlank(
        key: String,
        value: String?,
    ) {
        value?.trim()?.takeIf { it.isNotEmpty() }?.let { put(key, it) }
    }

    private fun ContentValues.putTypeAndLabel(
        typeKey: String,
        labelKey: String,
        type: Int,
        label: String,
        customType: Int? = null,
    ) {
        put(typeKey, type)
        if (label.isNotEmpty() && (customType == null || type == customType)) {
            put(labelKey, label)
        }
    }

    private fun hasAnyNonBlank(vararg values: String?): Boolean = values.any { !it.isNullOrBlank() }
}
