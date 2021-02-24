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
            // Selects fields for request contact, or for all contacts.
            "select" ->
                GlobalScope.launch(Dispatchers.IO) { // runs in a background thread
                    val args = call.arguments as List<Any>
                    val id = args[0] as String?
                    val withProperties = args[1] as Boolean
                    val withThumbnail = args[2] as Boolean
                    val withPhoto = args[3] as Boolean
                    val contacts: List<Map<String, Any?>> =
                        FlutterContacts.select(
                            resolver!!,
                            id, withProperties, withThumbnail, withPhoto
                        )
                    GlobalScope.launch(Dispatchers.Main) { result.success(contacts) }
                }
            // Inserts a new contact and return it.
            "insert" ->
                GlobalScope.launch(Dispatchers.IO) {
                    val args = call.arguments as List<Any>
                    val contact = args[0] as Map<String, Any>
                    val insertedContact: Map<String, Any?>? =
                        FlutterContacts.insert(resolver!!, contact)
                    GlobalScope.launch(Dispatchers.Main) {
                        if (insertedContact != null) {
                            result.success(insertedContact)
                        } else {
                            result.error("", "failed to create contact", "")
                        }
                    }
                }
            // Updates an existing contact and returns it.
            "update" ->
                GlobalScope.launch(Dispatchers.IO) {
                    val args = call.arguments as List<Any>
                    val contact = args[0] as Map<String, Any>
                    val updatedContact: Map<String, Any?>? =
                        FlutterContacts.update(resolver!!, contact)
                    GlobalScope.launch(Dispatchers.Main) {
                        if (updatedContact != null) {
                            result.success(updatedContact)
                        } else {
                            result.error("", "failed to update contact", "")
                        }
                    }
                }
            // Deletes contacts with given IDs.
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
