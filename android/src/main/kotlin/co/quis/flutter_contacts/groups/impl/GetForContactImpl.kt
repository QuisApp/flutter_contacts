package co.quis.flutter_contacts.groups.impl

import android.content.Context
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.groups.utils.GroupUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class GetForContactImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val contactId = call.argument<String>("contactId")!!
        val groups = GroupUtils.getGroupsForContact(context.contentResolver, contactId)
        postResult(result, groups.map { it.toJson() })
    }
}
