package co.quis.flutter_contacts.crud.models.labels

import android.database.Cursor
import android.provider.ContactsContract.CommonDataKinds.Email
import co.quis.flutter_contacts.common.CursorHelpers.getIntOrNull
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull

object EmailLabel {
    private val TYPE_TO_LABEL =
        mapOf(
            Email.TYPE_HOME to "home",
            Email.TYPE_WORK to "work",
            Email.TYPE_MOBILE to "mobile",
            Email.TYPE_OTHER to "other",
        )

    private val LABEL_TO_TYPE =
        mapOf(
            "home" to Email.TYPE_HOME,
            "work" to Email.TYPE_WORK,
            "mobile" to Email.TYPE_MOBILE,
            "other" to Email.TYPE_OTHER,
            "custom" to Email.TYPE_CUSTOM,
        )

    fun fromCursor(cursor: Cursor): Label {
        val type = cursor.getIntOrNull(Email.TYPE) ?: Email.TYPE_CUSTOM
        val customLabel = cursor.getStringOrNull(Email.LABEL)
        return LabelConverter.fromAndroidType(
            type,
            customLabel,
            TYPE_TO_LABEL,
            Email.TYPE_CUSTOM,
            "home",
        )
    }

    fun toAndroidLabel(
        label: String,
        customLabel: String?,
    ): Pair<Int, String> = LabelConverter.toAndroidType(label, customLabel, LABEL_TO_TYPE, Email.TYPE_CUSTOM)
}
