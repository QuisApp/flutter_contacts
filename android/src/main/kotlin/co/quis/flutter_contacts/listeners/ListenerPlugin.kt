package co.quis.flutter_contacts.listeners

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import java.util.concurrent.Executors

class ListenerPlugin : FlutterPlugin {
    private lateinit var simpleEventChannel: EventChannel
    private lateinit var detailedEventChannel: EventChannel
    private lateinit var context: Context
    private val executor = Executors.newCachedThreadPool()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        simpleEventChannel =
            EventChannel(binding.binaryMessenger, "flutter_contacts/simple_listener")
        detailedEventChannel =
            EventChannel(binding.binaryMessenger, "flutter_contacts/detailed_listener")
        simpleEventChannel.setStreamHandler(ListenerHandler(context, executor, false))
        detailedEventChannel.setStreamHandler(ListenerHandler(context, executor, true))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        simpleEventChannel.setStreamHandler(null)
        detailedEventChannel.setStreamHandler(null)
        executor.shutdownNow()
    }
}
