package co.quis.flutter_contacts.crud.models.properties

import android.content.ContentProviderOperation
import android.database.Cursor
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull
import co.quis.flutter_contacts.crud.models.JsonHelpers
import co.quis.flutter_contacts.crud.models.labels.EventLabel
import co.quis.flutter_contacts.crud.models.labels.Label
import java.util.Objects
import android.provider.ContactsContract.CommonDataKinds.Event as EventData

data class Event(
    val year: Int? = null,
    val month: Int,
    val day: Int,
    val label: Label = Label(label = "other"),
    val metadata: PropertyMetadata? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): Event =
            Event(
                year = json["year"] as? Int,
                month = json["month"] as? Int ?: 1,
                day = json["day"] as? Int ?: 1,
                label = JsonHelpers.decodeRequiredObject(json, "label", Label::fromJson),
                metadata = JsonHelpers.decodeOptionalObject(json, "metadata", PropertyMetadata::fromJson),
            )

        fun fromCursor(cursor: Cursor): Event? {
            val dateString = cursor.getStringOrNull(EventData.START_DATE) ?: return null
            val label = EventLabel.fromCursor(cursor)

            @Suppress("ktlint:standard:property-naming")
            val YYYY_MM_DD = """\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|30|31)""".toRegex()

            @Suppress("ktlint:standard:property-naming")
            val MM_DD = """--(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|30|31)""".toRegex()

            val (year, month, day) =
                when {
                    YYYY_MM_DD.matches(dateString) -> {
                        Triple(
                            dateString.substring(0, 4).toIntOrNull(),
                            dateString.substring(5, 7).toIntOrNull(),
                            dateString.substring(8, 10).toIntOrNull(),
                        )
                    }

                    MM_DD.matches(dateString) -> {
                        Triple(
                            null,
                            dateString.substring(2, 4).toIntOrNull(),
                            dateString.substring(5, 7).toIntOrNull(),
                        )
                    }

                    else -> {
                        Triple(null, null, null)
                    }
                }

            return if (month != null && day != null && month in 1..12 && day in 1..31) {
                Event(
                    year = year,
                    month = month,
                    day = day,
                    label = label,
                    metadata = PropertyHelpers.extractMetadata(cursor),
                )
            } else {
                null
            }
        }
    }

    fun toJson(): Map<String, Any?> {
        val result =
            mutableMapOf<String, Any?>(
                "month" to month,
                "day" to day,
                "label" to label.toJson(),
            )
        JsonHelpers.encodeOptional(result, "year", year)
        JsonHelpers.encodeOptionalObject(result, "metadata", metadata) { it.toJson() }
        return result
    }

    private fun buildDateString(): String =
        if (year != null) {
            String.format("%04d-%02d-%02d", year, month, day)
        } else {
            String.format("--%02d-%02d", month, day)
        }

    fun toInsertOperation(
        rawContactId: Long? = null,
        rawContactIndex: Int = 0,
        addYield: Boolean = false,
    ): ContentProviderOperation {
        val labelPair = EventLabel.toAndroidLabel(label.label, label.customLabel)
        return PropertyHelpers.buildInsertOperation(
            rawContactId,
            rawContactIndex,
            EventData.CONTENT_ITEM_TYPE,
            addYield,
        ) {
            withValue(EventData.START_DATE, buildDateString())
            withTypeAndLabel(EventData.TYPE, EventData.LABEL, labelPair)
        }
    }

    fun toUpdateOperation(): ContentProviderOperation {
        val labelPair = EventLabel.toAndroidLabel(label.label, label.customLabel)
        return PropertyHelpers.buildUpdateOperation(
            PropertyHelpers.requireDataId(metadata, "event"),
        ) {
            withValue(EventData.START_DATE, buildDateString())
            withTypeAndLabel(EventData.TYPE, EventData.LABEL, labelPair)
        }
    }

    fun toDeleteOperation(): ContentProviderOperation =
        PropertyHelpers.buildDeleteOperation(
            PropertyHelpers.requireDataId(metadata, "event"),
        )

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Event) return false
        return year == other.year &&
            month == other.month &&
            day == other.day &&
            label == other.label
    }

    override fun hashCode() = Objects.hash(year, month, day, label)
}
