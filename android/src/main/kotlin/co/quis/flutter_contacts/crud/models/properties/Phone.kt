package co.quis.flutter_contacts.crud.models.properties

import android.content.ContentProviderOperation
import android.database.Cursor
import co.quis.flutter_contacts.common.CursorHelpers.getIntOrNull
import co.quis.flutter_contacts.common.CursorHelpers.getString
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull
import co.quis.flutter_contacts.crud.models.JsonHelpers
import co.quis.flutter_contacts.crud.models.labels.Label
import co.quis.flutter_contacts.crud.models.labels.PhoneLabel
import java.util.Objects
import android.provider.ContactsContract.CommonDataKinds.Phone as PhoneData

data class Phone(
    val number: String,
    val normalizedNumber: String? = null,
    val isPrimary: Boolean? = null,
    val label: Label = Label(label = "mobile"),
    val metadata: PropertyMetadata? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): Phone =
            Phone(
                number = json["number"] as String,
                normalizedNumber = json["normalizedNumber"] as? String,
                isPrimary = json["isPrimary"] as? Boolean,
                label = JsonHelpers.decodeRequiredObject(json, "label", Label::fromJson),
                metadata = JsonHelpers.decodeOptionalObject(json, "metadata", PropertyMetadata::fromJson),
            )

        fun fromCursor(cursor: Cursor): Phone =
            Phone(
                number = cursor.getString(PhoneData.NUMBER),
                normalizedNumber = cursor.getStringOrNull(PhoneData.NORMALIZED_NUMBER),
                isPrimary =
                    if (cursor.getIntOrNull(PhoneData.IS_PRIMARY) != 0) true else null,
                label = PhoneLabel.fromCursor(cursor),
                metadata = PropertyHelpers.extractMetadata(cursor),
            )
    }

    fun toJson(): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>("number" to number, "label" to label.toJson())
        JsonHelpers.encodeOptional(result, "normalizedNumber", normalizedNumber)
        JsonHelpers.encodeOptional(result, "isPrimary", isPrimary)
        JsonHelpers.encodeOptionalObject(result, "metadata", metadata) { it.toJson() }
        return result
    }

    fun toInsertOperation(
        rawContactId: Long? = null,
        rawContactIndex: Int = 0,
        addYield: Boolean = false,
    ): ContentProviderOperation {
        val labelPair = PhoneLabel.toAndroidLabel(label.label, label.customLabel)
        return PropertyHelpers.buildInsertOperation(
            rawContactId,
            rawContactIndex,
            PhoneData.CONTENT_ITEM_TYPE,
            addYield,
        ) {
            withValue(PhoneData.NUMBER, number)
            withTypeAndLabel(PhoneData.TYPE, PhoneData.LABEL, labelPair)
            withPrimaryFlag(isPrimary)
        }
    }

    fun toUpdateOperation(): ContentProviderOperation {
        val labelPair = PhoneLabel.toAndroidLabel(label.label, label.customLabel)
        return PropertyHelpers.buildUpdateOperation(
            PropertyHelpers.requireDataId(metadata, "phone"),
        ) {
            withValue(PhoneData.NUMBER, number)
            withTypeAndLabel(PhoneData.TYPE, PhoneData.LABEL, labelPair)
            withPrimaryFlag(isPrimary)
        }
    }

    fun toDeleteOperation(): ContentProviderOperation =
        PropertyHelpers.buildDeleteOperation(
            PropertyHelpers.requireDataId(metadata, "phone"),
        )

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Phone) return false
        return number == other.number &&
            normalizedNumber == other.normalizedNumber &&
            isPrimary == other.isPrimary &&
            label == other.label
    }

    override fun hashCode() = Objects.hash(number, normalizedNumber, isPrimary, label)
}
