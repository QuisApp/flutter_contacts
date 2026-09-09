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
            val (year, month, day) = parseDate(dateString) ?: return null
            return Event(
                year = year,
                month = month,
                day = day,
                label = EventLabel.fromCursor(cursor),
                metadata = PropertyHelpers.extractMetadata(cursor),
            )
        }

        /**
         * Parses a `START_DATE` value into a (year, month, day) triple, or returns null if it
         * doesn't denote a full calendar date.
         *
         * `START_DATE` is free text and Android's vCard importer stores the `BDAY` value
         * verbatim, so both ISO 8601 spellings occur in practice:
         * - extended, used by vCard 3.0 (RFC 2426) and the AOSP Contacts app: `1996-04-15` and
         *   `--04-15`;
         * - basic, mandated by vCard 4.0 (RFC 6350, which disallows `YYYY-MM-DD`): `19960415`
         *   and `--0415`.
         *
         * A leading `--` marks the year-less form. Any time component is discarded, since `BDAY`
         * may carry one (e.g. `19531015T231000Z`).
         *
         * Values that don't denote both a month and a day are rejected rather than guessed:
         * year-only (`1985`), year-month (`1985-04`) and day-only (`---15`) are valid vCard 4.0
         * but have no representation here, and locale-ordered dates (`03/10/1978`) are ambiguous.
         */
        internal fun parseDate(dateString: String): Triple<Int?, Int, Int>? {
            val datePart = dateString.substringBefore('T').substringBefore(' ').trim()
            val digits = datePart.filter { it.isDigit() }

            val parsed: Triple<Int?, Int, Int> =
                if (datePart.startsWith("--")) {
                    if (digits.length != 4) return null
                    Triple(
                        null,
                        digits.substring(0, 2).toInt(),
                        digits.substring(2, 4).toInt(),
                    )
                } else {
                    if (digits.length != 8) return null
                    Triple(
                        digits.substring(0, 4).toInt(),
                        digits.substring(4, 6).toInt(),
                        digits.substring(6, 8).toInt(),
                    )
                }

            val (_, month, day) = parsed
            return if (month in 1..12 && day in 1..31) parsed else null
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
