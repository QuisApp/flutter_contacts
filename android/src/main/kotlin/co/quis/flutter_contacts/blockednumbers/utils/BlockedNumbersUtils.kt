package co.quis.flutter_contacts.blockednumbers.utils

import android.content.Context
import android.telephony.PhoneNumberUtils
import android.telephony.TelephonyManager

fun normalizeToE164(
    context: Context,
    phoneNumber: String,
): String? {
    val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
    val countryIso = tm?.simCountryIso ?: tm?.networkCountryIso ?: return null
    return PhoneNumberUtils.formatNumberToE164(phoneNumber, countryIso.uppercase())
}
