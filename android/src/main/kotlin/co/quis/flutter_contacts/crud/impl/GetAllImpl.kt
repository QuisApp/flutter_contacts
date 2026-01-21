package co.quis.flutter_contacts.crud.impl

import android.content.Context
import co.quis.flutter_contacts.accounts.models.Account
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argInt
import co.quis.flutter_contacts.common.argList
import co.quis.flutter_contacts.common.argMap
import co.quis.flutter_contacts.crud.utils.ContactFetcher
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class GetAllImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val properties = call.argList<String>("properties")?.toSet() ?: emptySet()

        @Suppress("UNCHECKED_CAST")
        val filterDict = call.argMap("filter") as? Map<String, Any?>
        val account = Account.fromJson(call.argMap("account"))
        val limit = call.argInt("limit")
        val contacts =
            ContactFetcher.getAllContacts(
                context.contentResolver,
                properties,
                filterDict,
                account,
                limit,
            )
        postResult(result, contacts.map { it.toJson() })
    }
}
