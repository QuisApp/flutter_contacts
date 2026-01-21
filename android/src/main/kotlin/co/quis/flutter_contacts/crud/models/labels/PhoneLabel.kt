package co.quis.flutter_contacts.crud.models.labels

import android.database.Cursor
import android.provider.ContactsContract.CommonDataKinds.Phone
import co.quis.flutter_contacts.common.CursorHelpers.getIntOrNull
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull

object PhoneLabel {
    private val TYPE_TO_LABEL =
        mapOf(
            Phone.TYPE_ASSISTANT to "assistant",
            Phone.TYPE_CALLBACK to "callback",
            Phone.TYPE_CAR to "car",
            Phone.TYPE_COMPANY_MAIN to "companyMain",
            Phone.TYPE_FAX_HOME to "homeFax",
            Phone.TYPE_FAX_WORK to "workFax",
            Phone.TYPE_HOME to "home",
            Phone.TYPE_ISDN to "isdn",
            Phone.TYPE_MAIN to "main",
            Phone.TYPE_MMS to "mms",
            Phone.TYPE_MOBILE to "mobile",
            Phone.TYPE_OTHER to "other",
            Phone.TYPE_OTHER_FAX to "otherFax",
            Phone.TYPE_PAGER to "pager",
            Phone.TYPE_RADIO to "radio",
            Phone.TYPE_TELEX to "telex",
            Phone.TYPE_TTY_TDD to "ttyTdd",
            Phone.TYPE_WORK to "work",
            Phone.TYPE_WORK_MOBILE to "workMobile",
            Phone.TYPE_WORK_PAGER to "workPager",
        )

    private val LABEL_TO_TYPE =
        mapOf(
            "assistant" to Phone.TYPE_ASSISTANT,
            "callback" to Phone.TYPE_CALLBACK,
            "car" to Phone.TYPE_CAR,
            "companyMain" to Phone.TYPE_COMPANY_MAIN,
            "homeFax" to Phone.TYPE_FAX_HOME,
            "workFax" to Phone.TYPE_FAX_WORK,
            "home" to Phone.TYPE_HOME,
            "isdn" to Phone.TYPE_ISDN,
            "main" to Phone.TYPE_MAIN,
            "mms" to Phone.TYPE_MMS,
            "mobile" to Phone.TYPE_MOBILE,
            "other" to Phone.TYPE_OTHER,
            "otherFax" to Phone.TYPE_OTHER_FAX,
            "pager" to Phone.TYPE_PAGER,
            "radio" to Phone.TYPE_RADIO,
            "telex" to Phone.TYPE_TELEX,
            "ttyTdd" to Phone.TYPE_TTY_TDD,
            "work" to Phone.TYPE_WORK,
            "workMobile" to Phone.TYPE_WORK_MOBILE,
            "workPager" to Phone.TYPE_WORK_PAGER,
            "custom" to Phone.TYPE_CUSTOM,
        )

    fun fromCursor(cursor: Cursor): Label {
        val type = cursor.getIntOrNull(Phone.TYPE) ?: Phone.TYPE_CUSTOM
        val customLabel = cursor.getStringOrNull(Phone.LABEL)
        return LabelConverter.fromAndroidType(
            type,
            customLabel,
            TYPE_TO_LABEL,
            Phone.TYPE_CUSTOM,
            "mobile",
        )
    }

    fun toAndroidLabel(
        label: String,
        customLabel: String?,
    ): Pair<Int, String> = LabelConverter.toAndroidType(label, customLabel, LABEL_TO_TYPE, Phone.TYPE_CUSTOM)
}
