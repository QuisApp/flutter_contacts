package co.quis.flutter_contacts.crud.models.properties

import android.content.ContentProviderOperation
import android.database.Cursor
import co.quis.flutter_contacts.common.CursorHelpers.getIntOrNull
import co.quis.flutter_contacts.common.CursorHelpers.getString
import co.quis.flutter_contacts.crud.models.JsonHelpers
import co.quis.flutter_contacts.crud.models.labels.EmailLabel
import co.quis.flutter_contacts.crud.models.labels.Label
import java.util.Objects
import android.provider.ContactsContract.CommonDataKinds.Email as EmailData

data class Email(
    val address: String,
    val isPrimary: Boolean? = null,
    val label: Label = Label(label = "home"),
    val metadata: PropertyMetadata? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): Email =
            Email(
                address = json["address"] as String,
                isPrimary = json["isPrimary"] as? Boolean,
                label = JsonHelpers.decodeRequiredObject(json, "label", Label::fromJson),
                metadata = JsonHelpers.decodeOptionalObject(json, "metadata", PropertyMetadata::fromJson),
            )

        fun fromCursor(cursor: Cursor): Email =
            Email(
                address = cursor.getString(EmailData.ADDRESS),
                isPrimary =
                    if (cursor.getIntOrNull(EmailData.IS_PRIMARY) != 0) true else null,
                label = EmailLabel.fromCursor(cursor),
                metadata = PropertyHelpers.extractMetadata(cursor),
            )
    }

    fun toJson(): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>("address" to address, "label" to label.toJson())
        JsonHelpers.encodeOptional(result, "isPrimary", isPrimary)
        JsonHelpers.encodeOptionalObject(result, "metadata", metadata) { it.toJson() }
        return result
    }

    fun toInsertOperation(
        rawContactId: Long? = null,
        rawContactIndex: Int = 0,
        addYield: Boolean = false,
    ): ContentProviderOperation {
        val labelPair = EmailLabel.toAndroidLabel(label.label, label.customLabel)
        return PropertyHelpers.buildInsertOperation(
            rawContactId,
            rawContactIndex,
            EmailData.CONTENT_ITEM_TYPE,
            addYield,
        ) {
            withValue(EmailData.ADDRESS, address)
            withTypeAndLabel(EmailData.TYPE, EmailData.LABEL, labelPair)
            withPrimaryFlag(isPrimary)
        }
    }

    fun toUpdateOperation(): ContentProviderOperation {
        val labelPair = EmailLabel.toAndroidLabel(label.label, label.customLabel)
        return PropertyHelpers.buildUpdateOperation(
            PropertyHelpers.requireDataId(metadata, "email"),
        ) {
            withValue(EmailData.ADDRESS, address)
            withTypeAndLabel(EmailData.TYPE, EmailData.LABEL, labelPair)
            withPrimaryFlag(isPrimary)
        }
    }

    fun toDeleteOperation(): ContentProviderOperation =
        PropertyHelpers.buildDeleteOperation(
            PropertyHelpers.requireDataId(metadata, "email"),
        )

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Email) return false
        return address == other.address && isPrimary == other.isPrimary && label == other.label
    }

    override fun hashCode() = Objects.hash(address, isPrimary, label)
}
