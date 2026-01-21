package co.quis.flutter_contacts.crud.impl

import android.content.Context
import android.net.Uri
import android.provider.ContactsContract.Contacts
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
        val id = call.argument<String>("id")!!
        context.contentResolver.delete(Uri.withAppendedPath(Contacts.CONTENT_URI, id), null, null)
        postResult(result, null)
    }
}
