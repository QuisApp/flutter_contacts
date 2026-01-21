package co.quis.flutter_contacts.permissions

import android.content.Context
import co.quis.flutter_contacts.common.MappedHandler
import co.quis.flutter_contacts.permissions.impl.CheckPermissionImpl
import co.quis.flutter_contacts.permissions.impl.OpenSettingsImpl
import co.quis.flutter_contacts.permissions.impl.RequestPermissionImpl
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import java.util.concurrent.ExecutorService

/**
 * Domain handler for permissions operations. Routes method calls to specific implementation
 * classes.
 */
class PermissionsHandler(
    private val context: Context,
    private val executor: ExecutorService,
    private var activityBinding: ActivityPluginBinding?,
) : MappedHandler() {
    private val checkPermissionImpl = CheckPermissionImpl(context, executor, activityBinding)
    private val requestPermissionImpl = RequestPermissionImpl(context, executor, activityBinding)
    private val openSettingsImpl = OpenSettingsImpl(context, executor)

    override val handlers =
        mapOf(
            "check" to checkPermissionImpl,
            "request" to requestPermissionImpl,
            "openSettings" to openSettingsImpl,
        )

    fun setActivityBinding(binding: ActivityPluginBinding?) {
        activityBinding = binding
        checkPermissionImpl.setActivityBinding(binding)
        requestPermissionImpl.setActivityBinding(binding)
    }
}
