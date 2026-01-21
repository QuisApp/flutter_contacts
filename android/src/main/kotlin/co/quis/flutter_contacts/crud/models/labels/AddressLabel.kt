package co.quis.flutter_contacts.crud.models.labels

import android.database.Cursor
import android.provider.ContactsContract.CommonDataKinds.StructuredPostal
import co.quis.flutter_contacts.common.CursorHelpers.getIntOrNull
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull

object AddressLabel {
    private val TYPE_TO_LABEL =
        mapOf(
            StructuredPostal.TYPE_HOME to "home",
            StructuredPostal.TYPE_WORK to "work",
            StructuredPostal.TYPE_OTHER to "other",
        )

    private val LABEL_TO_TYPE =
        mapOf(
            "home" to StructuredPostal.TYPE_HOME,
            "work" to StructuredPostal.TYPE_WORK,
            "other" to StructuredPostal.TYPE_OTHER,
            "custom" to StructuredPostal.TYPE_CUSTOM,
        )

    fun fromCursor(cursor: Cursor): Label {
        val type = cursor.getIntOrNull(StructuredPostal.TYPE) ?: StructuredPostal.TYPE_CUSTOM
        val customLabel = cursor.getStringOrNull(StructuredPostal.LABEL)
        return LabelConverter.fromAndroidType(
            type,
            customLabel,
            TYPE_TO_LABEL,
            StructuredPostal.TYPE_CUSTOM,
            "home",
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
            StructuredPostal.TYPE_CUSTOM,
        )
}
