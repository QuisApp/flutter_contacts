package co.quis.flutter_contacts.groups.impl

import android.content.Context
import co.quis.flutter_contacts.accounts.models.Account
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argBool
import co.quis.flutter_contacts.common.argList
import co.quis.flutter_contacts.groups.utils.GroupUtils
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
        val accounts = call.argList<Map<*, *>>("accounts")?.mapNotNull { Account.fromJson(it) }
        val withContactCount = call.argBool("withContactCount", false)
        val groups = GroupUtils.getGroups(context.contentResolver, accounts, withContactCount)
        postResult(result, groups.map { it.toJson() })
    }
}
