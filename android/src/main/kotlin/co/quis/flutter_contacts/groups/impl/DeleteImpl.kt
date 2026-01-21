package co.quis.flutter_contacts.groups.impl

import android.content.ContentUris
import android.content.Context
import android.provider.ContactsContract.Groups
import co.quis.flutter_contacts.common.BaseHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class DeleteImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val groupId = call.argument<String>("groupId")!!
        val groupIdLong = groupId.toLongOrNull() ?: return postError(result, "Invalid group ID format")
        val groupUri = ContentUris.withAppendedId(Groups.CONTENT_URI, groupIdLong)
        val deleted = context.contentResolver.delete(groupUri, null, null)
        if (deleted == 0) {
            return postError(result, "Group not found or could not be deleted")
        }
        postResult(result, null)
    }
}
