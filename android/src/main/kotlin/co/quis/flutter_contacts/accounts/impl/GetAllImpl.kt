package co.quis.flutter_contacts.accounts.impl

import android.accounts.AccountManager
import android.content.Context
import co.quis.flutter_contacts.accounts.models.Account
import co.quis.flutter_contacts.common.BaseHandler
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
        val accounts = AccountManager.get(context).accounts.map { Account(it.type, it.name) }
        postResult(result, accounts.map { it.toJson() })
    }
}
