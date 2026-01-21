package co.quis.flutter_contacts.permissions.impl

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import co.quis.flutter_contacts.common.BaseHandler
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class CheckPermissionImpl(
    context: Context,
    executor: ExecutorService,
    private var activityBinding: ActivityPluginBinding?,
) : BaseHandler(context, executor) {
    fun setActivityBinding(binding: ActivityPluginBinding?) {
        activityBinding = binding
    }

    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val type = call.argument<String>("type")!!
        val permissions = getPermissionsForType(type)
        val status =
            if (permissions.all { ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED }) {
                "granted"
            } else {
                val activity = activityBinding?.activity
                if (activity != null &&
                    permissions.any { ActivityCompat.shouldShowRequestPermissionRationale(activity, it) }
                ) {
                    "denied"
                } else {
                    "notDetermined"
                }
            }
        postResult(result, status)
    }

    private fun getPermissionsForType(type: String) =
        when (type) {
            "read" -> listOf(Manifest.permission.READ_CONTACTS)
            "write" -> listOf(Manifest.permission.WRITE_CONTACTS)
            "readWrite" -> listOf(Manifest.permission.READ_CONTACTS, Manifest.permission.WRITE_CONTACTS)
            else -> throw IllegalArgumentException("Unknown permission type: $type")
        }
}
