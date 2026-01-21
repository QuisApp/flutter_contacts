package co.quis.flutter_contacts

import android.content.Context
import co.quis.flutter_contacts.accounts.AccountsHandler
import co.quis.flutter_contacts.blockednumbers.BlockedNumbersHandler
import co.quis.flutter_contacts.common.Handler
import co.quis.flutter_contacts.crud.CrudHandler
import co.quis.flutter_contacts.groups.GroupsHandler
import co.quis.flutter_contacts.listeners.ListenerPlugin
import co.quis.flutter_contacts.native.NativeHandler
import co.quis.flutter_contacts.permissions.PermissionsHandler
import co.quis.flutter_contacts.profile.ProfileHandler
import co.quis.flutter_contacts.ringtones.RingtoneHandler
import co.quis.flutter_contacts.sim.SimHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * Main Flutter plugin that acts as a dispatcher for all contact-related operations. Uses a single
 * method channel and routes calls to domain-specific handlers.
 */
class FlutterContactsPlugin :
    FlutterPlugin,
    ActivityAware,
    MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val executor = Executors.newCachedThreadPool()

    private lateinit var crudHandler: CrudHandler
    private lateinit var accountsHandler: AccountsHandler
    private lateinit var groupsHandler: GroupsHandler
    private lateinit var permissionsHandler: PermissionsHandler
    private lateinit var nativeHandler: NativeHandler
    private lateinit var ringtoneHandler: RingtoneHandler
    private lateinit var profileHandler: ProfileHandler
    private lateinit var blockedNumbersHandler: BlockedNumbersHandler
    private lateinit var simHandler: SimHandler
    private lateinit var listenerPlugin: ListenerPlugin
    private lateinit var handlers: Map<String, Handler>

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "flutter_contacts")
        context = binding.applicationContext

        crudHandler = CrudHandler(context, executor)
        accountsHandler = AccountsHandler(context, executor)
        groupsHandler = GroupsHandler(context, executor)
        permissionsHandler = PermissionsHandler(context, executor, null)
        nativeHandler = NativeHandler(context, executor, null)
        ringtoneHandler = RingtoneHandler(context, executor)
        profileHandler = ProfileHandler(context, executor)
        blockedNumbersHandler = BlockedNumbersHandler(context, executor)
        simHandler = SimHandler(context, executor)

        channel.setMethodCallHandler(this)

        listenerPlugin = ListenerPlugin()
        listenerPlugin.onAttachedToEngine(binding)

        handlers =
            mapOf(
                "crud" to crudHandler,
                "accounts" to accountsHandler,
                "groups" to groupsHandler,
                "permissions" to permissionsHandler,
                "native" to nativeHandler,
                "ringtones" to ringtoneHandler,
                "profile" to profileHandler,
                "blockedNumbers" to blockedNumbersHandler,
                "sim" to simHandler,
            )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        listenerPlugin.onDetachedFromEngine(binding)
        executor.shutdown()
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val parts = call.method.split(".", limit = 2)
        if (parts.size != 2) return result.notImplemented()
        val (prefix, subMethod) = parts
        handlers[prefix]?.handle(MethodCall(subMethod, call.arguments), result)
            ?: result.notImplemented()
    }

    private fun setActivityBinding(binding: ActivityPluginBinding?) {
        permissionsHandler.setActivityBinding(binding)
        nativeHandler.setActivityBinding(binding)
        ringtoneHandler.setActivityBinding(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) = setActivityBinding(binding)

    override fun onDetachedFromActivityForConfigChanges() = setActivityBinding(null)

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = setActivityBinding(binding)

    override fun onDetachedFromActivity() = setActivityBinding(null)
}
