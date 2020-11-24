package co.quis.flutter_contacts.properties

data class Name(
    var first: String = "",
    var last: String = "",
    var middle: String = "",
    var prefix: String = "",
    var suffix: String = "",
    var nickname: String = "",
    var firstPhonetic: String = "",
    var lastPhonetic: String = "",
    var middlePhonetic: String = ""
) {
    companion object {
        fun fromMap(m: Map<String, Any>): Name = Name(
            m["first"] as String,
            m["last"] as String,
            m["middle"] as String,
            m["prefix"] as String,
            m["suffix"] as String,
            m["nickname"] as String,
            m["firstPhonetic"] as String,
            m["lastPhonetic"] as String,
            m["middlePhonetic"] as String
        )
    }

    fun toMap(): Map<String, Any> = mapOf(
        "first" to first,
        "last" to last,
        "middle" to middle,
        "prefix" to prefix,
        "suffix" to suffix,
        "nickname" to nickname,
        "firstPhonetic" to firstPhonetic,
        "lastPhonetic" to lastPhonetic,
        "middlePhonetic" to middlePhonetic
    )
}
