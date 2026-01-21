package co.quis.flutter_contacts.crud.impl

import android.content.Context
import android.provider.ContactsContract.RawContacts
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.BatchHelper
import co.quis.flutter_contacts.common.argListRequired
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class DeleteAllImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val ids = call.argListRequired<String>("ids")
        if (ids.isEmpty()) {
            postResult(result, null)
            return
        }

        val contentResolver = context.contentResolver
        try {
            BatchHelper.forEachSelectionArgsBatch(ids) { batch ->
                val placeholders = batch.joinToString(",") { "?" }
                val selection = "${RawContacts.CONTACT_ID} IN ($placeholders)"
                contentResolver.delete(
                    RawContacts.CONTENT_URI,
                    selection,
                    batch.toTypedArray(),
                )
            }
            postResult(result, null)
        } catch (e: Exception) {
            postError(result, "Failed to delete contacts: ${e.message}")
        }
    }
}
