package co.quis.flutter_contacts

import android.content.ContentResolver
import android.provider.ContactsContract
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

public class FlutterContactsPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    // --- FlutterPlugin implementation ---

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "github.com/QuisApp/flutter_contacts")
        val eventChannel = EventChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "github.com/QuisApp/flutter_contacts/events")
        channel.setMethodCallHandler(FlutterContactsPlugin())
        eventChannel.setStreamHandler(FlutterContactsPlugin())
        resolver = flutterPluginBinding.applicationContext.contentResolver
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        var resolver: ContentResolver? = null

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "github.com/QuisApp/flutter_contacts")
            val eventChannel = EventChannel(registrar.messenger(), "github.com/QuisApp/flutter_contacts/events")
            channel.setMethodCallHandler(FlutterContactsPlugin())
            eventChannel.setStreamHandler(FlutterContactsPlugin())
            resolver = registrar.context().contentResolver
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {}

    // --- MethodCallHandler implementation ---

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            // Get fields for request contact, or for all contacts
            "get" ->
                GlobalScope.launch(Dispatchers.IO) { // runs in a background thread
                    val args = call.arguments as List<Any>
                    val id = args[0] as String?
                    val withDetails = args[1] as Boolean
                    val withPhotos = args[2] as Boolean
                    val useHighResolutionPhotos = args[3] as Boolean
                    val contacts: List<Map<String, Any?>> =
                        FlutterContacts.get(
                            resolver!!,
                            id, withDetails, withPhotos, useHighResolutionPhotos
                        )
                    GlobalScope.launch(Dispatchers.Main) { result.success(contacts) }
                }
            // Create a new contact and return it
            "new" ->
                GlobalScope.launch(Dispatchers.IO) {
                    val newContact: Map<String, Any?>? =
                        FlutterContacts.new(
                            resolver!!,
                            call.arguments as Map<String, Any>
                        )
                    GlobalScope.launch(Dispatchers.Main) {
                        if (newContact != null) {
                            result.success(newContact)
                        } else {
                            result.error("", "failed to create contact", "")
                        }
                    }
                }
            // Update an existing contact
            "update" ->
                GlobalScope.launch(Dispatchers.IO) {
                    val args = call.arguments as List<*>
                    val errorMessage: String? =
                        FlutterContacts.update(
                            resolver!!, args[0] as Map<String, Any>,
                            args[1] as Boolean
                        )
                    GlobalScope.launch(Dispatchers.Main) {
                        if (errorMessage == null) {
                            result.success(null)
                        } else {
                            result.error("", errorMessage, "")
                        }
                    }
                }
            // Delete contacts with given IDs
            "delete" ->
                GlobalScope.launch(Dispatchers.IO) {
                    FlutterContacts.delete(resolver!!, call.arguments as List<String>)
                    GlobalScope.launch(Dispatchers.Main) { result.success(null) }
                }
            else -> result.notImplemented()
        }
    }

    // --- StreamHandler implementation ---

    var _eventObserver: ContactChangeObserver? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events != null) {
            this._eventObserver = ContactChangeObserver(android.os.Handler(), events)
            resolver?.registerContentObserver(ContactsContract.Contacts.CONTENT_URI, true, this._eventObserver!!)
        }
    }

    override fun onCancel(arguments: Any?) {
        if (this._eventObserver != null) {
            resolver?.unregisterContentObserver(this._eventObserver!!)
        }
        this._eventObserver = null
    }
}
