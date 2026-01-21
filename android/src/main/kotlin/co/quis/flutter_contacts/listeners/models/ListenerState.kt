package co.quis.flutter_contacts.listeners.models

import android.content.Context
import android.database.ContentObserver
import android.net.Uri
import android.os.Handler
import android.provider.ContactsContract
import co.quis.flutter_contacts.listeners.utils.ContactChangeTracker
import io.flutter.plugin.common.EventChannel
import org.json.JSONArray
import java.util.concurrent.ExecutorService
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.ScheduledFuture
import java.util.concurrent.TimeUnit

class ListenerState(
    private val context: Context,
    private val executor: ExecutorService,
    private val mainHandler: Handler,
    private val debounceExecutor: ScheduledExecutorService,
    private val isDetailed: Boolean,
    eventSink: EventChannel.EventSink,
) {
    companion object {
        const val DEBOUNCE_MS = 300L
    }

    var eventSink: EventChannel.EventSink? = eventSink
    var contactHashes: Map<String, Int>? = null
    var debounceTask: ScheduledFuture<*>? = null
    private var observer: ContentObserver? = null
    private val changeTracker by lazy { ContactChangeTracker(context, executor, mainHandler) }

    fun initializeContactHashes() {
        if (isDetailed && contactHashes == null) {
            executor.execute { changeTracker.initializeContactHashes { contactHashes = it } }
        }
    }

    fun registerObserver() {
        observer =
            createContentObserver().also { observer ->
                context.contentResolver.registerContentObserver(
                    ContactsContract.Contacts.CONTENT_URI,
                    true,
                    observer,
                )
            }
    }

    private fun createContentObserver() =
        object : ContentObserver(mainHandler) {
            override fun onChange(
                selfChange: Boolean,
                uri: Uri?,
            ) {
                super.onChange(selfChange, uri)
                handleContactChange()
            }
        }

    private fun handleContactChange() {
        eventSink ?: return

        cancelDebounceTask()

        debounceTask =
            debounceExecutor.schedule(
                {
                    eventSink ?: return@schedule

                    if (!isDetailed) {
                        mainHandler.post { eventSink?.success(null) }
                    } else {
                        processChanges()
                    }
                },
                DEBOUNCE_MS,
                TimeUnit.MILLISECONDS,
            )
    }

    fun processChanges() {
        if (!isDetailed) {
            mainHandler.post { eventSink?.success(null) }
        } else {
            contactHashes?.let { oldHashes ->
                executor.execute {
                    changeTracker.detectAndReportChanges(
                        oldHashes = oldHashes,
                        onChangesDetected = { diffs ->
                            val jsonDiffs =
                                JSONArray()
                                    .apply { diffs.forEach { put(it.toJson()) } }
                                    .toString()
                            mainHandler.post { eventSink?.success(jsonDiffs) }
                        },
                        onHashesUpdated = { contactHashes = it },
                    )
                }
            }
        }
    }

    fun cancelDebounceTask() {
        debounceTask?.cancel(false)
        debounceTask = null
    }

    fun reset() {
        cancelDebounceTask()
        observer?.let { context.contentResolver.unregisterContentObserver(it) }
        observer = null
        eventSink = null
        contactHashes = null
    }
}
