package co.quis.flutter_contacts.accounts.impl

import android.content.Context
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.crud.utils.AccountUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class GetDefaultImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val account = AccountUtils.getDefaultAccount(context.contentResolver)
        postResult(result, account?.toJson())
    }
}
