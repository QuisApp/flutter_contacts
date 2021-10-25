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
import io.flutter.plugin.common.*
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.nio.ByteBuffer

public class FlutterContactsPlugin : FlutterPlugin, BinaryMessenger.BinaryMessageHandler, EventChannel.StreamHandler, ActivityAware, ActivityResultListener, RequestPermissionsResultListener {
    companion object {
        private var activity: Activity? = null
        private var context: Context? = null
        private var resolver: ContentResolver? = null
        private val permissionReadWriteCode: Int = 0
        private val permissionReadOnlyCode: Int = 1
        private var permissionReply: BinaryMessenger.BinaryReply? = null
        private var viewReply: BinaryMessenger.BinaryReply? = null
        private var editReply: BinaryMessenger.BinaryReply? = null
        private var pickReply: BinaryMessenger.BinaryReply? = null
        private var insertReply: BinaryMessenger.BinaryReply? = null
    }

    // --- FlutterPlugin implementation ---

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBinding.binaryMessenger.setMessageHandler("github.com/QuisApp/flutter_contacts", FlutterContactsPlugin())
        val eventChannel = EventChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "github.com/QuisApp/flutter_contacts/events")
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
                if (viewReply != null) {
                    success(viewReply!!, null)
                    viewReply = null
                }
            FlutterContacts.REQUEST_CODE_EDIT ->
                if (editReply != null) {
                    // Result is of the form:
                    // content://com.android.contacts/contacts/lookup/<hash>/<id>
                    val id = intent?.getData()?.getLastPathSegment()
                    success(editReply!!, id)
                    editReply = null
                }
            FlutterContacts.REQUEST_CODE_PICK ->
                if (pickReply != null) {
                    // Result is of the form:
                    // content://com.android.contacts/contacts/lookup/<hash>/<id>
                    val id = intent?.getData()?.getLastPathSegment()
                    success(pickReply!!, id)
                    pickReply = null
                }
            FlutterContacts.REQUEST_CODE_INSERT ->
                if (insertReply != null) {
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
                            success(insertReply!!, contacts[0]["id"])
                        } else {
                            success(insertReply!!, null)
                        }
                    } else {
                        success(insertReply!!, null)
                    }
                    insertReply = null
                }
        }
        return true
    }

    // --- RequestPermissionsResultListener implementation ---

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>?,
        grantResults: IntArray?
    ): Boolean {
        when (requestCode) {
            permissionReadWriteCode -> {
                val granted = grantResults != null &&
                    grantResults!!.size == 2 &&
                    grantResults!![0] == PackageManager.PERMISSION_GRANTED &&
                    grantResults!![1] == PackageManager.PERMISSION_GRANTED
                if (permissionReply != null) {
                    GlobalScope.launch(Dispatchers.Main) {
                        success(permissionReply!!, granted)
                        permissionReply = null
                    }
                }
                return true
            }
            permissionReadOnlyCode -> {
                val granted = grantResults != null &&
                    grantResults!!.size == 1 &&
                    grantResults!![0] == PackageManager.PERMISSION_GRANTED
                if (permissionReply != null) {
                    GlobalScope.launch(Dispatchers.Main) {
                        success(permissionReply!!, granted)
                        permissionReply = null
                    }
                }
                return true
            }
        }
        return false // did not handle the result
    }

    // --- MethodCallHandler implementation ---

    private fun success(reply: BinaryMessenger.BinaryReply, result: Any?) {
        val codec = StandardMethodCodec.INSTANCE
        reply.reply(codec.encodeSuccessEnvelope(result))
    }

    private fun error(reply: BinaryMessenger.BinaryReply, errorCode: String, errorMessage: String, errorDetails: Any) {
        val codec = StandardMethodCodec.INSTANCE
        reply.reply(codec.encodeErrorEnvelope(errorCode, errorMessage, errorDetails))
    }

    override fun onMessage(message: ByteBuffer?, reply: BinaryMessenger.BinaryReply) {
        val codec = StandardMethodCodec.INSTANCE
        val call = codec.decodeMethodCall(message)
        when (call.method) {
            // Requests permission to read/write contacts.
            "requestPermission" ->
                GlobalScope.launch(Dispatchers.IO) {
                    if (context == null) {
                        GlobalScope.launch(Dispatchers.Main) { success(reply, false); }
                    } else {
                        val readonly = call.arguments as Boolean
                        val readPermission = Manifest.permission.READ_CONTACTS
                        val writePermission = Manifest.permission.WRITE_CONTACTS
                        if (ContextCompat.checkSelfPermission(context!!, readPermission) == PackageManager.PERMISSION_GRANTED &&
                            (readonly || ContextCompat.checkSelfPermission(context!!, writePermission) == PackageManager.PERMISSION_GRANTED)
                        ) {
                            GlobalScope.launch(Dispatchers.Main) { success(reply, true) }
                        } else if (activity != null) {
                            permissionReply = reply
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
                GlobalScope.launch(Dispatchers.IO) { // runs in a background thread
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
                    val encodedContacts = codec.encodeSuccessEnvelope(contacts)
                    GlobalScope.launch(Dispatchers.Main) { reply.reply(encodedContacts) }
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
                            success(reply, insertedContact)
                        } else {
                            error(reply, "", "failed to create contact", "")
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
                            success(reply, updatedContact)
                        } else {
                            error(reply, "", "failed to update contact", "")
                        }
                    }
                }
            // Deletes contacts with given IDs.
            "delete" ->
                GlobalScope.launch(Dispatchers.IO) {
                    FlutterContacts.delete(resolver!!, call.arguments as List<String>)
                    GlobalScope.launch(Dispatchers.Main) { success(reply, null) }
                }
            // Opens external contact app to view existing contact.
            "openExternalView" ->
                GlobalScope.launch(Dispatchers.IO) {
                    val args = call.arguments as List<Any>
                    val id = args[0] as String
                    FlutterContacts.openExternalViewOrEdit(activity, context, id, false)
                    viewReply = reply
                }
            // Opens external contact app to edit existing contact.
            "openExternalEdit" ->
                GlobalScope.launch(Dispatchers.IO) {
                    val args = call.arguments as List<Any>
                    val id = args[0] as String
                    FlutterContacts.openExternalViewOrEdit(activity, context, id, true)
                    editReply = reply
                }
            // Opens external contact app to pick an existing contact.
            "openExternalPick" ->
                GlobalScope.launch(Dispatchers.IO) {
                    FlutterContacts.openExternalPickOrInsert(activity, context, false)
                    pickReply = reply
                }
            // Opens external contact app to insert a new contact.
            "openExternalInsert" ->
                GlobalScope.launch(Dispatchers.IO) {
                    FlutterContacts.openExternalPickOrInsert(activity, context, true)
                    insertReply = reply
                }
            // notImplemented
            else -> reply.reply(null)
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
