package co.quis.flutter_contacts.blockednumbers

import android.content.Context
import co.quis.flutter_contacts.blockednumbers.impl.BlockNumbersImpl
import co.quis.flutter_contacts.blockednumbers.impl.GetAllImpl
import co.quis.flutter_contacts.blockednumbers.impl.IsAvailableImpl
import co.quis.flutter_contacts.blockednumbers.impl.IsBlockedImpl
import co.quis.flutter_contacts.blockednumbers.impl.OpenDefaultAppSettingsImpl
import co.quis.flutter_contacts.blockednumbers.impl.UnblockNumbersImpl
import co.quis.flutter_contacts.common.MappedHandler
import java.util.concurrent.ExecutorService

/**
 * Domain handler for blocked numbers operations. Routes method calls to specific implementation
 * classes.
 */
class BlockedNumbersHandler(
    private val context: Context,
    private val executor: ExecutorService,
) : MappedHandler() {
    private val isAvailableImpl = IsAvailableImpl(context, executor)
    private val isBlockedImpl = IsBlockedImpl(context, executor)
    private val getAllImpl = GetAllImpl(context, executor)
    private val blockNumbersImpl = BlockNumbersImpl(context, executor)
    private val unblockNumbersImpl = UnblockNumbersImpl(context, executor)
    private val openDefaultAppSettingsImpl = OpenDefaultAppSettingsImpl(context, executor)

    override val handlers =
        mapOf(
            "isAvailable" to isAvailableImpl,
            "isBlocked" to isBlockedImpl,
            "getAll" to getAllImpl,
            "blockAll" to blockNumbersImpl,
            "unblockAll" to unblockNumbersImpl,
            "openDefaultAppSettings" to openDefaultAppSettingsImpl,
        )
}
