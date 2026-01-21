package co.quis.flutter_contacts.profile

import android.content.Context
import co.quis.flutter_contacts.common.MappedHandler
import co.quis.flutter_contacts.profile.impl.GetProfileImpl
import java.util.concurrent.ExecutorService

/**
 * Domain handler for profile operations. Routes method calls to specific implementation classes.
 */
class ProfileHandler(
    private val context: Context,
    private val executor: ExecutorService,
) : MappedHandler() {
    private val getProfileImpl = GetProfileImpl(context, executor)

    override val handlers = mapOf("get" to getProfileImpl)
}
