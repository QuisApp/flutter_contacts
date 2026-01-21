package co.quis.flutter_contacts.crud.models.labels

import android.database.Cursor
import android.provider.ContactsContract.CommonDataKinds.Website
import co.quis.flutter_contacts.common.CursorHelpers.getIntOrNull
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull

object WebsiteLabel {
    private val TYPE_TO_LABEL =
        mapOf(
            Website.TYPE_HOMEPAGE to "homepage",
            Website.TYPE_BLOG to "blog",
            Website.TYPE_FTP to "ftp",
            Website.TYPE_HOME to "home",
            Website.TYPE_PROFILE to "profile",
            Website.TYPE_WORK to "work",
            Website.TYPE_OTHER to "other",
        )

    private val LABEL_TO_TYPE =
        mapOf(
            "homepage" to Website.TYPE_HOMEPAGE,
            "blog" to Website.TYPE_BLOG,
            "ftp" to Website.TYPE_FTP,
            "home" to Website.TYPE_HOME,
            "profile" to Website.TYPE_PROFILE,
            "work" to Website.TYPE_WORK,
            "other" to Website.TYPE_OTHER,
            "custom" to Website.TYPE_CUSTOM,
        )

    fun fromCursor(cursor: Cursor): Label {
        val type = cursor.getIntOrNull(Website.TYPE) ?: Website.TYPE_CUSTOM
        val customLabel = cursor.getStringOrNull(Website.LABEL)
        return LabelConverter.fromAndroidType(
            type,
            customLabel,
            TYPE_TO_LABEL,
            Website.TYPE_CUSTOM,
            "homepage",
        )
    }

    fun toAndroidLabel(
        label: String,
        customLabel: String?,
    ): Pair<Int, String> = LabelConverter.toAndroidType(label, customLabel, LABEL_TO_TYPE, Website.TYPE_CUSTOM)
}
