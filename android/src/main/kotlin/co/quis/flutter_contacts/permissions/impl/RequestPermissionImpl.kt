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
import io.flutter.plugin.common.PluginRegistry
import java.util.concurrent.ExecutorService

class RequestPermissionImpl(
    context: Context,
    executor: ExecutorService,
    private var activityBinding: ActivityPluginBinding?,
) : BaseHandler(context, executor),
    PluginRegistry.RequestPermissionsResultListener {
    private var pendingResult: MethodChannel.Result? = null

    @Suppress("ktlint:standard:property-naming")
    private val REQUEST_CODE = 1001

    init {
        activityBinding?.addRequestPermissionsResultListener(this)
    }

    fun setActivityBinding(binding: ActivityPluginBinding?) {
        activityBinding?.removeRequestPermissionsResultListener(this)
        activityBinding = binding?.also { it.addRequestPermissionsResultListener(this) }
    }

    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val type = call.argument<String>("type")!!
        if (pendingResult != null) {
            return postError(result, "Another permission request is in progress")
        }
        val permissions = getPermissionsForType(type).toTypedArray()
        if (permissions.all {
                ContextCompat.checkSelfPermission(context, it) ==
                    PackageManager.PERMISSION_GRANTED
            }
        ) {
            postResult(result, "granted")
            return
        }
        val activity =
            activityBinding?.activity ?: return postError(result, "No activity available")
        pendingResult = result
        mainHandler.post { ActivityCompat.requestPermissions(activity, permissions, REQUEST_CODE) }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != REQUEST_CODE) return false
        val result = pendingResult ?: return false
        pendingResult = null

        val permissionMap =
            permissions
                .mapIndexed { index, permission ->
                    permission to (grantResults[index] == PackageManager.PERMISSION_GRANTED)
                }.toMap()
        val allGranted = permissionMap.values.all { it }
        val status =
            if (allGranted) {
                "granted"
            } else {
                val canRequestAgain =
                    activityBinding?.activity?.let { activity ->
                        permissionMap.entries.any {
                            !it.value &&
                                ActivityCompat.shouldShowRequestPermissionRationale(
                                    activity,
                                    it.key,
                                )
                        }
                    }
                        ?: false
                if (canRequestAgain) "denied" else "permanentlyDenied"
            }
        postResult(result, status)
        return true
    }

    private fun getPermissionsForType(type: String) =
        when (type) {
            "read" -> {
                listOf(Manifest.permission.READ_CONTACTS)
            }

            "write" -> {
                listOf(Manifest.permission.WRITE_CONTACTS)
            }

            "readWrite" -> {
                listOf(
                    Manifest.permission.READ_CONTACTS,
                    Manifest.permission.WRITE_CONTACTS,
                )
            }

            else -> {
                throw IllegalArgumentException("Unknown permission type: $type")
            }
        }
}
