package co.quis.flutter_contacts.properties

data class Phone(
    var number: String,
    var normalizedNumber: String,
    // one of: assistant, callback, car, companyMain, faxHome, faxOther, faxWork, home,
    // iPhone, isdn, main, mms, mobile, pager, radio, school, telex, ttyTtd, work,
    // workMobile, workPager, other, custom
    var label: String = "mobile",
    var customLabel: String,
    var isPrimary: Boolean = false
) {
    companion object {
        fun fromMap(m: Map<String, Any>): Phone = Phone(
            m["number"] as String,
            m["normalizedNumber"] as String,
            m["label"] as String,
            m["customLabel"] as String,
            m["isPrimary"] as Boolean
        )
    }

    fun toMap(): Map<String, Any> = mapOf(
        "number" to number,
        "normalizedNumber" to normalizedNumber,
        "label" to label,
        "customLabel" to customLabel,
        "isPrimary" to isPrimary
    )
}
