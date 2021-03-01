package co.quis.flutter_contacts

import android.app.Activity
import android.content.ContentResolver
import android.content.Context
import android.content.pm.PackageManager
import android.Manifest
import android.provider.ContactsContract
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

public class FlutterContactsPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, ActivityAware, RequestPermissionsResultListener {
    companion object {
        private var activity: Activity? = null
        private var context: Context? = null
        private var resolver: ContentResolver? = null
        private val permissionCode: Int = 0
        private var permissionResult: Result? = null
    }

    // --- FlutterPlugin implementation ---

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "github.com/QuisApp/flutter_contacts")
        val eventChannel = EventChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "github.com/QuisApp/flutter_contacts/events")
        channel.setMethodCallHandler(FlutterContactsPlugin())
        eventChannel.setStreamHandler(FlutterContactsPlugin())
        context = flutterPluginBinding.applicationContext
        resolver = context!!.contentResolver
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {}

    // --- ActivityAware implementation ---

    override fun onDetachedFromActivity() { activity = null }

    override fun onDetachedFromActivityForConfigChanges() { activity = null }

    override fun onReattachedToActivityForConfigChanges(@NonNull binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    // --- RequestPermissionsResultListener implementation ---

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>?,
        grantResults: IntArray?
    ): Boolean {
        when (requestCode) {
            permissionCode -> {
                val granted = grantResults != null &&
                    grantResults!!.size == 2 &&
                    grantResults!![0] == PackageManager.PERMISSION_GRANTED
                grantResults!![1] == PackageManager.PERMISSION_GRANTED
                if (permissionResult != null) {
                    GlobalScope.launch(Dispatchers.Main) {
                        permissionResult!!.success(granted)
                        permissionResult = null
                    }
                }
                return true
            }
        }
        return false // did not handle the result
    }

    // --- MethodCallHandler implementation ---

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            // Requests permission to read/write contacts.
            "requestPermission" ->
                GlobalScope.launch(Dispatchers.IO) {
                    if (context == null) {
                        GlobalScope.launch(Dispatchers.Main) { result.success(false); }
                    } else {
                        val readPermission = Manifest.permission.READ_CONTACTS
                        val writePermission = Manifest.permission.WRITE_CONTACTS
                        if (ContextCompat.checkSelfPermission(context!!, readPermission) == PackageManager.PERMISSION_GRANTED &&
                            ContextCompat.checkSelfPermission(context!!, writePermission) == PackageManager.PERMISSION_GRANTED
                        ) {
                            GlobalScope.launch(Dispatchers.Main) { result.success(true) }
                        } else if (activity != null) {
                            permissionResult = result
                            ActivityCompat.requestPermissions(activity!!, arrayOf(readPermission, writePermission), permissionCode)
                        }
                    }
                }
            // Selects fields for request contact, or for all contacts.
            "select" ->
                GlobalScope.launch(Dispatchers.IO) { // runs in a background thread
                    val args = call.arguments as List<Any>
                    val id = args[0] as String?
                    val withProperties = args[1] as Boolean
                    val withThumbnail = args[2] as Boolean
                    val withPhoto = args[3] as Boolean
                    val returnUnifiedContacts = args[4] as Boolean
                    val includeNonVisible = args[5] as Boolean
                    // args[6] = includeNotesOnIos13AndAbove
                    val contacts: List<Map<String, Any?>> =
                        FlutterContacts.select(
                            resolver!!,
                            id, withProperties, withThumbnail, withPhoto,
                            returnUnifiedContacts, includeNonVisible
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
