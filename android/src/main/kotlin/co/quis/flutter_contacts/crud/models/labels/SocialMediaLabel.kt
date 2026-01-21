package co.quis.flutter_contacts.crud.models.labels

import android.database.Cursor
import android.provider.ContactsContract.CommonDataKinds.Im
import co.quis.flutter_contacts.common.CursorHelpers.getIntOrNull
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull

object SocialMediaLabel {
    private val PROTOCOL_TO_LABEL =
        mapOf(
            Im.PROTOCOL_AIM to "aim",
            Im.PROTOCOL_GOOGLE_TALK to "googleTalk",
            Im.PROTOCOL_ICQ to "icq",
            Im.PROTOCOL_JABBER to "jabber",
            Im.PROTOCOL_MSN to "msn",
            Im.PROTOCOL_NETMEETING to "netmeeting",
            Im.PROTOCOL_QQ to "qq",
            Im.PROTOCOL_SKYPE to "skype",
            Im.PROTOCOL_YAHOO to "yahoo",
        )

    private val LABEL_TO_PROTOCOL =
        mapOf(
            "aim" to Im.PROTOCOL_AIM,
            "googleTalk" to Im.PROTOCOL_GOOGLE_TALK,
            "icq" to Im.PROTOCOL_ICQ,
            "jabber" to Im.PROTOCOL_JABBER,
            "msn" to Im.PROTOCOL_MSN,
            "netmeeting" to Im.PROTOCOL_NETMEETING,
            "qq" to Im.PROTOCOL_QQ,
            "skype" to Im.PROTOCOL_SKYPE,
            "yahoo" to Im.PROTOCOL_YAHOO,
            "custom" to Im.PROTOCOL_CUSTOM,
        )

    fun fromCursor(cursor: Cursor): Label {
        val protocol = cursor.getIntOrNull(Im.PROTOCOL) ?: Im.PROTOCOL_CUSTOM
        val customProtocol = cursor.getStringOrNull(Im.CUSTOM_PROTOCOL)
        return LabelConverter.fromAndroidType(
            protocol,
            customProtocol,
            PROTOCOL_TO_LABEL,
            Im.PROTOCOL_CUSTOM,
            "other",
        )
    }

    fun toAndroidLabel(
        label: String,
        customLabel: String?,
    ): Pair<Int, String> = LabelConverter.toAndroidType(label, customLabel, LABEL_TO_PROTOCOL, Im.PROTOCOL_CUSTOM)
}
