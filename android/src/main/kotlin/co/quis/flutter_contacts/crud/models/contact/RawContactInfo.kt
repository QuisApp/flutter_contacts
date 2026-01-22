package co.quis.flutter_contacts.crud.models.contact

import co.quis.flutter_contacts.accounts.models.Account
import co.quis.flutter_contacts.crud.models.JsonHelpers

data class RawContactInfo(
    val rawContactId: String? = null,
    val sourceId: String? = null,
    val account: Account? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>?) = json?.let {
            val accountJson = it["account"] as? Map<String, Any?>
            val account = accountJson?.let { Account.fromJson(it) }
            RawContactInfo(
                rawContactId = it["rawContactId"] as? String,
                sourceId = it["sourceId"] as? String,
                account = account,
            )
        }
    }

    fun toJson() = buildMap<String, Any?> {
        rawContactId?.let { put("rawContactId", it) }
        sourceId?.let { put("sourceId", it) }
        account?.let { put("account", it.toJson()) }
    }
}
