package co.quis.flutter_contacts.groups.impl

import android.content.ContentValues
import android.content.Context
import android.provider.ContactsContract.Groups
import co.quis.flutter_contacts.accounts.models.Account
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argMap
import co.quis.flutter_contacts.crud.utils.AccountUtils
import co.quis.flutter_contacts.groups.models.Group
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class CreateImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val name = call.argument<String>("name")!!
        val account =
            Account.fromJson(call.argMap("account"))
                ?: AccountUtils.getDefaultAccount(context.contentResolver)
        val group = createGroup(name, account, result)
        group?.let { postResult(result, it.toJson()) }
    }

    private fun createGroup(
        name: String,
        account: Account?,
        result: MethodChannel.Result,
    ): Group? {
        val values =
            ContentValues().apply {
                put(Groups.TITLE, name)
                put(Groups.GROUP_VISIBLE, 1)
                account?.let {
                    put(Groups.ACCOUNT_TYPE, it.type)
                    put(Groups.ACCOUNT_NAME, it.name)
                }
            }
        val uri =
            context.contentResolver.insert(Groups.CONTENT_URI, values)
                ?: return postError(result, "Failed to create group").let { null }
        val groupId =
            uri.lastPathSegment
                ?: return postError(result, "Failed to get group ID").let { null }
        return Group(id = groupId, name = name, account = account, contactCount = 0)
    }
}
