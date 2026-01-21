package co.quis.flutter_contacts.ringtones

import android.content.Context
import co.quis.flutter_contacts.common.MappedHandler
import co.quis.flutter_contacts.ringtones.impl.GetAllImpl
import co.quis.flutter_contacts.ringtones.impl.GetDefaultUriImpl
import co.quis.flutter_contacts.ringtones.impl.GetImpl
import co.quis.flutter_contacts.ringtones.impl.PickImpl
import co.quis.flutter_contacts.ringtones.impl.PlayImpl
import co.quis.flutter_contacts.ringtones.impl.SetDefaultUriImpl
import co.quis.flutter_contacts.ringtones.impl.StopImpl
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import java.util.concurrent.ExecutorService

/**
 * Domain handler for ringtone operations. Routes method calls to specific implementation classes.
 */
class RingtoneHandler(
    private val context: Context,
    private val executor: ExecutorService,
) : MappedHandler() {
    private val getImpl = GetImpl(context, executor)
    private val getAllImpl = GetAllImpl(context, executor)
    private val pickImpl = PickImpl(context, executor)
    private val getDefaultUriImpl = GetDefaultUriImpl(context, executor)
    private val setDefaultUriImpl = SetDefaultUriImpl(context, executor)
    private val playImpl = PlayImpl(context, executor)
    private val stopImpl = StopImpl(context, executor, playImpl)

    override val handlers =
        mapOf(
            "get" to getImpl,
            "getAll" to getAllImpl,
            "pick" to pickImpl,
            "getDefaultUri" to getDefaultUriImpl,
            "setDefaultUri" to setDefaultUriImpl,
            "play" to playImpl,
            "stop" to stopImpl,
        )

    fun setActivityBinding(binding: ActivityPluginBinding?) {
        pickImpl.setActivityBinding(binding)
    }
}
