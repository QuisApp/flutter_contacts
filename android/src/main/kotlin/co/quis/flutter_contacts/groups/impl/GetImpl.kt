package co.quis.flutter_contacts.groups.impl

import android.content.Context
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argBool
import co.quis.flutter_contacts.groups.utils.GroupUtils
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
        val groupId = call.argument<String>("groupId")!!
        val withContactCount = call.argBool("withContactCount", false)
        val group = GroupUtils.getGroup(context.contentResolver, groupId, withContactCount)
        postResult(result, group?.toJson())
    }
}
