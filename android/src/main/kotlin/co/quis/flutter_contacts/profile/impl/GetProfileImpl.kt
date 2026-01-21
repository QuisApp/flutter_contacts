package co.quis.flutter_contacts.profile.impl

import android.content.Context
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argList
import co.quis.flutter_contacts.crud.utils.ContactFetcher
import co.quis.flutter_contacts.crud.utils.PropertyUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class GetProfileImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val properties =
            call.argList<String>("properties")?.toSet()
                ?: PropertyUtils.ALL_PROPERTIES_WITH_PHOTO_THUMBNAIL
        val contact = ContactFetcher.getProfile(context.contentResolver, properties)
        postResult(result, contact?.toJson())
    }
}
