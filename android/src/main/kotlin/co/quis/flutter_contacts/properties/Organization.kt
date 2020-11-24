package co.quis.flutter_contacts.properties

data class Organization(
    var company: String = "",
    var title: String = "",
    var department: String = "",
    var jobDescription: String = "",
    var symbol: String = "",
    var phoneticName: String = "",
    var officeLocation: String = ""
) {
    companion object {
        fun fromMap(m: Map<String, Any>): Organization = Organization(
            m["company"] as String,
            m["title"] as String,
            m["department"] as String,
            m["jobDescription"] as String,
            m["symbol"] as String,
            m["phoneticName"] as String,
            m["officeLocation"] as String
        )
    }

    fun toMap(): Map<String, Any> = mapOf(
        "company" to company,
        "title" to title,
        "department" to department,
        "jobDescription" to jobDescription,
        "symbol" to symbol,
        "phoneticName" to phoneticName,
        "officeLocation" to officeLocation
    )
}
