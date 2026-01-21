package co.quis.flutter_contacts.accounts.models

data class Account(
    val type: String,
    val name: String,
) {
    fun toJson(): Map<String, String> {
        // Note: Android accounts don't have stable IDs, so we don't include "id" field.
        // Dart's Account.fromJson will default id to empty string when missing.
        return mapOf("type" to type, "name" to name)
    }

    companion object {
        fun fromJson(json: Map<*, *>?): Account? {
            val accountName = json?.get("name") as? String
            val accountType = json?.get("type") as? String
            return if (!accountName.isNullOrEmpty() && !accountType.isNullOrEmpty()) {
                Account(accountType, accountName)
            } else {
                null
            }
        }
    }
}
