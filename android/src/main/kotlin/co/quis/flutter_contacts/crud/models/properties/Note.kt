package co.quis.flutter_contacts.crud.models.properties

import android.content.ContentProviderOperation
import android.database.Cursor
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull
import co.quis.flutter_contacts.crud.models.JsonHelpers
import java.util.Objects
import android.provider.ContactsContract.CommonDataKinds.Note as NoteData

data class Note(
    val note: String,
    val metadata: PropertyMetadata? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): Note =
            Note(
                note = json["note"] as String,
                metadata = JsonHelpers.decodeOptionalObject(json, "metadata", PropertyMetadata::fromJson),
            )

        fun fromCursor(cursor: Cursor): Note? {
            val noteText = cursor.getStringOrNull(NoteData.NOTE)
            return if (noteText.isNullOrEmpty()) {
                null
            } else {
                Note(note = noteText, metadata = PropertyHelpers.extractMetadata(cursor))
            }
        }
    }

    fun toJson(): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>("note" to note)
        JsonHelpers.encodeOptionalObject(result, "metadata", metadata) { it.toJson() }
        return result
    }

    fun toInsertOperation(
        rawContactId: Long? = null,
        rawContactIndex: Int = 0,
        addYield: Boolean = false,
    ): ContentProviderOperation =
        PropertyHelpers.buildInsertOperation(
            rawContactId,
            rawContactIndex,
            NoteData.CONTENT_ITEM_TYPE,
            addYield,
        ) { withValue(NoteData.NOTE, note) }

    fun toUpdateOperation(): ContentProviderOperation =
        PropertyHelpers.buildUpdateOperation(
            PropertyHelpers.requireDataId(metadata, "note"),
        ) { withValue(NoteData.NOTE, note) }

    fun toDeleteOperation(): ContentProviderOperation =
        PropertyHelpers.buildDeleteOperation(
            PropertyHelpers.requireDataId(metadata, "note"),
        )

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Note) return false
        return note == other.note
    }

    override fun hashCode() = Objects.hash(note)
}
