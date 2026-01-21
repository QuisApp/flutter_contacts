package co.quis.flutter_contacts.groups.impl

import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.provider.ContactsContract.Groups
import co.quis.flutter_contacts.common.BaseHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class UpdateImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val groupId = call.argument<String>("groupId")!!
        val name = call.argument<String>("name")!!
        val groupUri = Uri.withAppendedPath(Groups.CONTENT_URI, groupId)
        val values = ContentValues().apply { put(Groups.TITLE, name) }
        val updated = context.contentResolver.update(groupUri, values, null, null)
        if (updated == 0) {
            return postError(result, "Group not found or could not be updated")
        }
        postResult(result, null)
    }
}
