package co.quis.flutter_contacts.crud.models.properties

import android.content.ContentProviderOperation
import android.database.Cursor
import android.provider.ContactsContract.CommonDataKinds.StructuredPostal
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull
import co.quis.flutter_contacts.crud.models.JsonHelpers
import co.quis.flutter_contacts.crud.models.labels.AddressLabel
import co.quis.flutter_contacts.crud.models.labels.Label
import java.util.Objects

data class Address(
    val formatted: String? = null,
    val label: Label = Label(label = "home"),
    val street: String? = null,
    val city: String? = null,
    val state: String? = null,
    val postalCode: String? = null,
    val country: String? = null,
    val poBox: String? = null,
    val neighborhood: String? = null,
    val metadata: PropertyMetadata? = null,
) {
    companion object {
        fun isNotEmpty(value: String?) = !value.isNullOrBlank()

        fun fromJson(json: Map<String, Any?>): Address {
            val label = JsonHelpers.decodeRequiredObject(json, "label", Label::fromJson)
            return Address(
                formatted = json["formatted"] as? String,
                label = label,
                street = json["street"] as? String,
                city = json["city"] as? String,
                state = json["state"] as? String,
                postalCode = json["postalCode"] as? String,
                country = json["country"] as? String,
                poBox = json["poBox"] as? String,
                neighborhood = json["neighborhood"] as? String,
                metadata = JsonHelpers.decodeOptionalObject(json, "metadata", PropertyMetadata::fromJson),
            )
        }

        fun fromCursor(cursor: Cursor): Address =
            Address(
                formatted = cursor.getStringOrNull(StructuredPostal.FORMATTED_ADDRESS),
                label = AddressLabel.fromCursor(cursor),
                street = cursor.getStringOrNull(StructuredPostal.STREET),
                city = cursor.getStringOrNull(StructuredPostal.CITY),
                state = cursor.getStringOrNull(StructuredPostal.REGION),
                postalCode = cursor.getStringOrNull(StructuredPostal.POSTCODE),
                country = cursor.getStringOrNull(StructuredPostal.COUNTRY),
                poBox = cursor.getStringOrNull(StructuredPostal.POBOX),
                neighborhood = cursor.getStringOrNull(StructuredPostal.NEIGHBORHOOD),
                metadata = PropertyHelpers.extractMetadata(cursor),
            )
    }

    fun toJson(): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>("label" to label.toJson())
        JsonHelpers.encodeOptional(result, "formatted", formatted)
        JsonHelpers.encodeOptional(result, "street", street)
        JsonHelpers.encodeOptional(result, "city", city)
        JsonHelpers.encodeOptional(result, "state", state)
        JsonHelpers.encodeOptional(result, "postalCode", postalCode)
        JsonHelpers.encodeOptional(result, "country", country)
        JsonHelpers.encodeOptional(result, "poBox", poBox)
        JsonHelpers.encodeOptional(result, "neighborhood", neighborhood)
        JsonHelpers.encodeOptionalObject(result, "metadata", metadata) { it.toJson() }
        return result
    }

    fun toInsertOperation(
        rawContactId: Long? = null,
        rawContactIndex: Int = 0,
        addYield: Boolean = false,
    ): ContentProviderOperation {
        val labelPair = AddressLabel.toAndroidLabel(label.label, label.customLabel)
        return PropertyHelpers.buildInsertOperation(
            rawContactId,
            rawContactIndex,
            StructuredPostal.CONTENT_ITEM_TYPE,
            addYield,
        ) {
            if (isNotEmpty(formatted)) {
                withValue(StructuredPostal.FORMATTED_ADDRESS, formatted?.trim())
            }
            if (isNotEmpty(street)) withValue(StructuredPostal.STREET, street?.trim())
            if (isNotEmpty(poBox)) withValue(StructuredPostal.POBOX, poBox?.trim())
            if (isNotEmpty(neighborhood)) {
                withValue(StructuredPostal.NEIGHBORHOOD, neighborhood?.trim())
            }
            if (isNotEmpty(city)) withValue(StructuredPostal.CITY, city?.trim())
            if (isNotEmpty(state)) withValue(StructuredPostal.REGION, state?.trim())
            if (isNotEmpty(postalCode)) withValue(StructuredPostal.POSTCODE, postalCode?.trim())
            if (isNotEmpty(country)) withValue(StructuredPostal.COUNTRY, country?.trim())
            withTypeAndLabel(StructuredPostal.TYPE, StructuredPostal.LABEL, labelPair)
        }
    }

    fun toUpdateOperation(): ContentProviderOperation {
        val labelPair = AddressLabel.toAndroidLabel(label.label, label.customLabel)
        return PropertyHelpers.buildUpdateOperation(
            PropertyHelpers.requireDataId(metadata, "address"),
        ) {
            if (isNotEmpty(formatted)) {
                withValue(StructuredPostal.FORMATTED_ADDRESS, formatted?.trim())
            }
            if (isNotEmpty(street)) withValue(StructuredPostal.STREET, street?.trim())
            if (isNotEmpty(poBox)) withValue(StructuredPostal.POBOX, poBox?.trim())
            if (isNotEmpty(neighborhood)) {
                withValue(StructuredPostal.NEIGHBORHOOD, neighborhood?.trim())
            }
            if (isNotEmpty(city)) withValue(StructuredPostal.CITY, city?.trim())
            if (isNotEmpty(state)) withValue(StructuredPostal.REGION, state?.trim())
            if (isNotEmpty(postalCode)) withValue(StructuredPostal.POSTCODE, postalCode?.trim())
            if (isNotEmpty(country)) withValue(StructuredPostal.COUNTRY, country?.trim())
            withTypeAndLabel(StructuredPostal.TYPE, StructuredPostal.LABEL, labelPair)
        }
    }

    fun toDeleteOperation(): ContentProviderOperation =
        PropertyHelpers.buildDeleteOperation(
            PropertyHelpers.requireDataId(metadata, "address"),
        )

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Address) return false
        return formatted == other.formatted &&
            label == other.label &&
            street == other.street &&
            city == other.city &&
            state == other.state &&
            postalCode == other.postalCode &&
            country == other.country &&
            poBox == other.poBox &&
            neighborhood == other.neighborhood
    }

    override fun hashCode() =
        Objects.hash(
            formatted,
            label,
            street,
            city,
            state,
            postalCode,
            country,
            poBox,
            neighborhood,
        )
}
