package co.quis.flutter_contacts.ringtones.impl

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.argString
import co.quis.flutter_contacts.ringtones.handlers.RingtoneUtils
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class PickImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingResult: MethodChannel.Result? = null
    private var requestCode: Int = 0

    fun setActivityBinding(binding: ActivityPluginBinding?) {
        activityBinding = binding
        if (binding != null) {
            requestCode = System.identityHashCode(this) and 0xFFFF
            binding.addActivityResultListener { reqCode, resultCode, data ->
                if (reqCode == this.requestCode) {
                    handleResult(resultCode, data)
                    true
                } else {
                    false
                }
            }
        }
    }

    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val activity =
            activityBinding?.activity ?: return postError(result, "No activity available")
        val type = call.argument<String>("type")!!
        pendingResult = result
        mainHandler.post {
            val intent =
                Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                    putExtra(
                        RingtoneManager.EXTRA_RINGTONE_TYPE,
                        RingtoneUtils.parseRingtoneType(type),
                    )
                    putExtra(
                        RingtoneManager.EXTRA_RINGTONE_EXISTING_URI,
                        call.argString("existingUri")?.let { Uri.parse(it) },
                    )
                    putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                    putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, true)
                }
            activity.startActivityForResult(intent, requestCode)
        }
    }

    private fun handleResult(
        resultCode: Int,
        data: Intent?,
    ) {
        val result = pendingResult ?: return
        pendingResult = null
        if (resultCode == Activity.RESULT_OK && data != null) {
            val uri =
                if (Build.VERSION.SDK_INT >= 33) {
                    data.getParcelableExtra(
                        RingtoneManager.EXTRA_RINGTONE_PICKED_URI,
                        Uri::class.java,
                    )
                } else {
                    @Suppress("DEPRECATION")
                    data.getParcelableExtra<Uri>(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
                }
            postResult(result, uri?.toString())
        } else {
            postResult(result, null)
        }
    }
}
