package co.quis.flutter_contacts

import android.database.ContentObserver
import android.os.Handler
import io.flutter.plugin.common.EventChannel

class ContactChangeObserver : ContentObserver {
    val _sink: EventChannel.EventSink

    constructor(handler: Handler, sink: EventChannel.EventSink) : super(handler) {
        this._sink = sink
    }

    override fun onChange(selfChange: Boolean) {
        _sink?.success(selfChange)
    }
}
