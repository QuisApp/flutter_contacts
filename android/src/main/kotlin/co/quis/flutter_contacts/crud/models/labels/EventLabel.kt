package co.quis.flutter_contacts.crud.models.labels

import android.database.Cursor
import android.provider.ContactsContract.CommonDataKinds.Event
import co.quis.flutter_contacts.common.CursorHelpers.getIntOrNull
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull

object EventLabel {
    private val TYPE_TO_LABEL =
        mapOf(
            Event.TYPE_BIRTHDAY to "birthday",
            Event.TYPE_ANNIVERSARY to "anniversary",
            Event.TYPE_OTHER to "other",
        )

    private val LABEL_TO_TYPE =
        mapOf(
            "birthday" to Event.TYPE_BIRTHDAY,
            "anniversary" to Event.TYPE_ANNIVERSARY,
            "other" to Event.TYPE_OTHER,
            "custom" to Event.TYPE_CUSTOM,
        )

    fun fromCursor(cursor: Cursor): Label {
        val type = cursor.getIntOrNull(Event.TYPE) ?: Event.TYPE_CUSTOM
        val customLabel = cursor.getStringOrNull(Event.LABEL)
        return LabelConverter.fromAndroidType(
            type,
            customLabel,
            TYPE_TO_LABEL,
            Event.TYPE_CUSTOM,
            "other",
        )
    }

    fun toAndroidLabel(
        label: String,
        customLabel: String?,
    ): Pair<Int, String> =
        LabelConverter.toAndroidType(
            label,
            customLabel,
            LABEL_TO_TYPE,
            Event.TYPE_CUSTOM,
        )
}
