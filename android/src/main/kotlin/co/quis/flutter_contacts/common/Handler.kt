package co.quis.flutter_contacts.common

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

interface Handler {
    fun handle(
        call: MethodCall,
        result: MethodChannel.Result,
    )
}

abstract class MappedHandler : Handler {
    protected abstract val handlers: Map<String, Handler>

    override fun handle(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        handlers[call.method]?.handle(call, result) ?: result.notImplemented()
    }
}
