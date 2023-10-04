package co.quis.flutter_contacts

import android.Manifest
import android.app.Activity
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.ContactsContract
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.cancel

class FlutterContactsPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, ActivityAware, ActivityResultListener, RequestPermissionsResultListener {
    companion object {
        private var activity: Activity? = null
        private var context: Context? = null
        private var resolver: ContentResolver? = null
        private val permissionReadWriteCode: Int = 0
        private val permissionReadOnlyCode: Int = 1
        private var permissionResult: Result? = null
        private var viewResult: Result? = null
        private var editResult: Result? = null
        private var pickResult: Result? = null
        private var insertResult: Result? = null
    }

    private val coroutineScope = CoroutineScope(Dispatchers.IO)

    // --- FlutterPlugin implementation ---

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "github.com/QuisApp/flutter_contacts")
        val eventChannel = EventChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "github.com/QuisApp/flutter_contacts/events")
        channel.setMethodCallHandler(FlutterContactsPlugin())
        eventChannel.setStreamHandler(FlutterContactsPlugin())
        context = flutterPluginBinding.applicationContext
        resolver = context!!.contentResolver
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        coroutineScope.cancel()
    }

    // --- ActivityAware implementation ---

    override fun onDetachedFromActivity() { activity = null }

    override fun onDetachedFromActivityForConfigChanges() { activity = null }

    override fun onReattachedToActivityForConfigChanges(@NonNull binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
        binding.addActivityResultListener(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
        binding.addActivityResultListener(this)
    }

    // --- ActivityResultListener implementation ---

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        intent: Intent?
    ): Boolean {
        when (requestCode) {
            FlutterContacts.REQUEST_CODE_VIEW ->
                if (viewResult != null) {
                    viewResult!!.success(null)
                    viewResult = null
                }
            FlutterContacts.REQUEST_CODE_EDIT ->
                if (editResult != null) {
                    // Result is of the form:
                    // content://com.android.contacts/contacts/lookup/<hash>/<id>
                    val id = intent?.getData()?.getLastPathSegment()
                    editResult!!.success(id)
                    editResult = null
                }
            FlutterContacts.REQUEST_CODE_PICK ->
                if (pickResult != null) {
                    // Result is of the form:
                    // content://com.android.contacts/contacts/lookup/<hash>/<id>
                    val id = intent?.getData()?.getLastPathSegment()
                    pickResult!!.success(id)
                    pickResult = null
                }
            FlutterContacts.REQUEST_CODE_INSERT ->
                if (insertResult != null) {
                    // Result is of the form:
                    // content://com.android.contacts/raw_contacts/<raw_id>
                    // So we need to get the ID from the raw ID.
                    val rawId = intent?.getData()?.getLastPathSegment()
                    if (rawId != null) {
                        val contacts: List<Map<String, Any?>> =
                            FlutterContacts.select(
                                resolver!!,
                                rawId,
                                /*withProperties=*/false,
                                /*withThumbnail=*/false,
                                /*withPhoto=*/false,
                                /*withGroups=*/false,
                                /*withAccounts=*/false,
                                /*returnUnifiedContacts=*/true,
                                /*includeNonVisible=*/true,
                                /*idIsRawContactId=*/true
                            )
                        if (contacts.isNotEmpty()) {
                            insertResult!!.success(contacts[0]["id"])
                        } else {
                            insertResult!!.success(null)
                        }
                    } else {
                        insertResult!!.success(null)
                    }
                    insertResult = null
                }
        }
        return true
    }

    // --- RequestPermissionsResultListener implementation ---

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        when (requestCode) {
            permissionReadWriteCode -> {
                val granted = grantResults.size == 2 && grantResults[0] == PackageManager.PERMISSION_GRANTED && grantResults[1] == PackageManager.PERMISSION_GRANTED
                if (permissionResult != null) {
                    coroutineScope.launch(Dispatchers.Main) {
                        permissionResult?.success(granted)
                        permissionResult = null
                    }
                }
                return true
            }
            permissionReadOnlyCode -> {
                val granted = grantResults.size == 1 && grantResults[0] == PackageManager.PERMISSION_GRANTED
                if (permissionResult != null) {
                    coroutineScope.launch(Dispatchers.Main) {
                        permissionResult?.success(granted)
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
                coroutineScope.launch(Dispatchers.IO) {
                    if (context == null) {
                        coroutineScope.launch(Dispatchers.Main) { result.success(false); }
                    } else {
                        val readonly = call.arguments as Boolean
                        val readPermission = Manifest.permission.READ_CONTACTS
                        val writePermission = Manifest.permission.WRITE_CONTACTS
                        if (ContextCompat.checkSelfPermission(context!!, readPermission) == PackageManager.PERMISSION_GRANTED &&
                            (readonly || ContextCompat.checkSelfPermission(context!!, writePermission) == PackageManager.PERMISSION_GRANTED)
                        ) {
                            coroutineScope.launch(Dispatchers.Main) { result.success(true) }
                        } else if (activity != null) {
                            permissionResult = result
                            if (readonly) {
                                ActivityCompat.requestPermissions(activity!!, arrayOf(readPermission), permissionReadOnlyCode)
                            } else {
                                ActivityCompat.requestPermissions(activity!!, arrayOf(readPermission, writePermission), permissionReadWriteCode)
                            }
                        }
                    }
                }
            // Selects fields for request contact, or for all contacts.
            "select" ->
                coroutineScope.launch(Dispatchers.IO) { // runs in a background thread
                    val args = call.arguments as List<Any>
                    val id = args[0] as String?
                    val withProperties = args[1] as Boolean
                    val withThumbnail = args[2] as Boolean
                    val withPhoto = args[3] as Boolean
                    val withGroups = args[4] as Boolean
                    val withAccounts = args[5] as Boolean
                    val returnUnifiedContacts = args[6] as Boolean
                    val includeNonVisible = args[7] as Boolean
                    // args[8] = includeNotesOnIos13AndAbove
                    val contacts: List<Map<String, Any?>> =
                        FlutterContacts.select(
                            resolver!!,
                            id,
                            withProperties,
                            // Sometimes thumbnail is available but photo is not, so we
                            // fetch thumbnails even if only the photo was requested.
                            withThumbnail || withPhoto,
                            withPhoto,
                            withGroups,
                            withAccounts,
                            returnUnifiedContacts,
                            includeNonVisible
                        )
                    coroutineScope.launch(Dispatchers.Main) { result.success(contacts) }
                }
            // Inserts a new contact and return it.
            "insert" ->
                coroutineScope.launch(Dispatchers.IO) {
                    val args = call.arguments as List<Any>
                    val contact = args[0] as Map<String, Any>
                    val insertedContact: Map<String, Any?>? =
                        FlutterContacts.insert(resolver!!, contact)
                    coroutineScope.launch(Dispatchers.Main) {
                        if (insertedContact != null) {
                            result.success(insertedContact)
                        } else {
                            result.error("", "failed to create contact", "")
                        }
                    }
                }
            // Updates an existing contact and returns it.
            "update" ->
                coroutineScope.launch(Dispatchers.IO) {
                    val args = call.arguments as List<Any>
                    val contact = args[0] as Map<String, Any>
                    val withGroups = args[1] as Boolean
                    val updatedContact: Map<String, Any?>? =
                        FlutterContacts.update(resolver!!, contact, withGroups)
                    coroutineScope.launch(Dispatchers.Main) {
                        if (updatedContact != null) {
                            result.success(updatedContact)
                        } else {
                            result.error("", "failed to update contact", "")
                        }
                    }
                }
            // Deletes contacts with given IDs.
            "delete" ->
                coroutineScope.launch(Dispatchers.IO) {
                    FlutterContacts.delete(resolver!!, call.arguments as List<String>)
                    coroutineScope.launch(Dispatchers.Main) { result.success(null) }
                }
            // Fetches all groups.
            "getGroups" ->
                coroutineScope.launch(Dispatchers.IO) {
                    val groups: List<Map<String, Any?>> =
                        FlutterContacts.getGroups(resolver!!)
                    coroutineScope.launch(Dispatchers.Main) { result.success(groups) }
                }
            // Insert a new group and returns it.
            "insertGroup" ->
                coroutineScope.launch(Dispatchers.IO) {
                    val args = call.arguments as List<Any>
                    val group = args[0] as Map<String, Any>
                    val insertedGroup: Map<String, Any?>? =
                        FlutterContacts.insertGroup(resolver!!, group)
                    coroutineScope.launch(Dispatchers.Main) {
                        result.success(insertedGroup)
                    }
                }
            // Updates a group and returns it.
            "updateGroup" ->
                coroutineScope.launch(Dispatchers.IO) {
                    val args = call.arguments as List<Any>
                    val group = args[0] as Map<String, Any>
                    val updatedGroup: Map<String, Any?>? =
                        FlutterContacts.updateGroup(resolver!!, group)
                    coroutineScope.launch(Dispatchers.Main) {
                        result.success(updatedGroup)
                    }
                }
            // Deletes a group.
            "deleteGroup" ->
                coroutineScope.launch(Dispatchers.IO) {
                    val args = call.arguments as List<Any>
                    val group = args[0] as Map<String, Any>
                    FlutterContacts.deleteGroup(resolver!!, group)
                    coroutineScope.launch(Dispatchers.Main) {
                        result.success(null)
                    }
                }
            // Opens external contact app to view existing contact.
            "openExternalView" ->
                coroutineScope.launch(Dispatchers.IO) {
                    val args = call.arguments as List<Any>
                    val id = args[0] as String
                    FlutterContacts.openExternalViewOrEdit(activity, context, id, false)
                    viewResult = result
                }
            // Opens external contact app to edit existing contact.
            "openExternalEdit" ->
                coroutineScope.launch(Dispatchers.IO) {
                    val args = call.arguments as List<Any>
                    val id = args[0] as String
                    FlutterContacts.openExternalViewOrEdit(activity, context, id, true)
                    editResult = result
                }
            // Opens external contact app to pick an existing contact.
            "openExternalPick" ->
                coroutineScope.launch(Dispatchers.IO) {
                    FlutterContacts.openExternalPickOrInsert(activity, context, false)
                    pickResult = result
                }
            // Opens external contact app to insert a new contact.
            "openExternalInsert" ->
                coroutineScope.launch(Dispatchers.IO) {
                    var args = call.arguments as List<Any>
                    val contact = args.getOrNull(0)?.let { it as? Map<String, Any?> } ?: run {
                        null
                    }
                    FlutterContacts.openExternalPickOrInsert(activity, context, true, contact)
                    insertResult = result
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