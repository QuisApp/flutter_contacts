package co.quis.flutter_contacts.crud.impl

import android.content.Context
import co.quis.flutter_contacts.accounts.models.Account
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argList
import co.quis.flutter_contacts.common.argMap
import co.quis.flutter_contacts.crud.utils.ContactFetcher
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class GetImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val id = call.argument<String>("id")!!
        val properties = call.argList<String>("properties")?.toSet() ?: emptySet()
        val account = Account.fromJson(call.argMap("account"))
        val rawContactIdsList = call.argList<Long>("rawContactIds")
        val contact =
            ContactFetcher.getContact(
                context.contentResolver,
                id,
                properties,
                account,
                rawContactIdsList,
            )
        if (contact != null) {
            postResult(result, contact.toJson())
        } else {
            postError(result, "Contact with ID $id not found")
        }
    }
}
