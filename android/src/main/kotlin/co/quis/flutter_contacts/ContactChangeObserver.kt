package co.quis.flutter_contacts

import android.database.ContentObserver
import android.os.Handler
import io.flutter.plugin.common.EventChannel


class ContactChangeObserver(handler: Handler, sink: EventChannel.EventSink) :
    ContentObserver(handler) {
    val _sink: EventChannel.EventSink = sink

    override fun onChange(selfChange: Boolean) {
        _sink?.success(selfChange)
    }
}
