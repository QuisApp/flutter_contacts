package co.quis.flutter_contacts.native

import android.content.Context
import co.quis.flutter_contacts.common.MappedHandler
import co.quis.flutter_contacts.native.impl.ShowCreatorImpl
import co.quis.flutter_contacts.native.impl.ShowEditorImpl
import co.quis.flutter_contacts.native.impl.ShowPickerImpl
import co.quis.flutter_contacts.native.impl.ShowViewerImpl
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import java.util.concurrent.ExecutorService

/** Domain handler for native operations. Routes method calls to specific implementation classes. */
class NativeHandler(
    private val context: Context,
    private val executor: ExecutorService,
    private var activityBinding: ActivityPluginBinding?,
) : MappedHandler() {
    private val showViewerImpl = ShowViewerImpl(context, executor, activityBinding)
    private val showPickerImpl = ShowPickerImpl(context, executor)
    private val showEditorImpl = ShowEditorImpl(context, executor)
    private val showCreatorImpl = ShowCreatorImpl(context, executor)

    override val handlers =
        mapOf(
            "showViewer" to showViewerImpl,
            "showPicker" to showPickerImpl,
            "showEditor" to showEditorImpl,
            "showCreator" to showCreatorImpl,
        )

    fun setActivityBinding(binding: ActivityPluginBinding?) {
        activityBinding = binding
        showViewerImpl.setActivityBinding(binding)
        showPickerImpl.setActivityBinding(binding)
        showEditorImpl.setActivityBinding(binding)
        showCreatorImpl.setActivityBinding(binding)
    }
}
