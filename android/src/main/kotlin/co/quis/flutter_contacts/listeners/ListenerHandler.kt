package co.quis.flutter_contacts.listeners

import android.content.Context
import android.os.Handler
import android.os.Looper
import co.quis.flutter_contacts.listeners.models.ListenerState
import co.quis.flutter_contacts.listeners.utils.Permissions
import io.flutter.plugin.common.EventChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService

class ListenerHandler(
    private val context: Context,
    private val executor: ExecutorService,
    private val isDetailed: Boolean,
) : EventChannel.StreamHandler {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var debounceExecutor: ScheduledExecutorService? = null
    private var state: ListenerState? = null

    override fun onListen(
        arguments: Any?,
        events: EventChannel.EventSink?,
    ) {
        events ?: return

        if (!Permissions.hasReadPermission(context)) {
            events.error("permission_denied", "Contacts permission is required", null)
            return
        }

        debounceExecutor = debounceExecutor ?: Executors.newSingleThreadScheduledExecutor()

        state =
            ListenerState(
                context = context,
                executor = executor,
                mainHandler = mainHandler,
                debounceExecutor = debounceExecutor!!,
                isDetailed = isDetailed,
                eventSink = events,
            ).apply {
                initializeContactHashes()
                registerObserver()
            }
    }

    override fun onCancel(arguments: Any?) {
        state?.reset()
        state = null
        debounceExecutor?.shutdown()
        debounceExecutor = null
    }
}
