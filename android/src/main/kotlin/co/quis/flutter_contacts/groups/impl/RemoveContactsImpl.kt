package co.quis.flutter_contacts.groups.impl

import android.content.Context
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argListRequired
import co.quis.flutter_contacts.groups.utils.GroupUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class RemoveContactsImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val groupId = call.argument<String>("groupId")!!
        val contactIds = call.argListRequired<String>("contactIds")
        GroupUtils.removeContactsFromGroup(context.contentResolver, groupId, contactIds)
        postResult(result, null)
    }
}
