package co.quis.flutter_contacts.groups.models

import co.quis.flutter_contacts.accounts.models.Account

data class Group(
    val id: String? = null,
    val name: String,
    val account: Account? = null,
    val contactCount: Int? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): Group {
            val accountJson = json["account"] as? Map<String, Any?>
            val account = Account.fromJson(accountJson)
            return Group(
                id = json["id"] as? String,
                name = json["name"] as String,
                account = account,
                contactCount = json["contactCount"] as? Int,
            )
        }
    }

    fun toJson(): Map<String, Any?> {
        val result =
            mutableMapOf<String, Any?>(
                "name" to name,
            )
        id?.let { result["id"] = it }
        account?.let { result["account"] = it.toJson() }
        contactCount?.let { result["contactCount"] = it }
        return result
    }
}
