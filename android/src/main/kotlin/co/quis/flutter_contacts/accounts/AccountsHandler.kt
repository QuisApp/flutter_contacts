package co.quis.flutter_contacts.accounts

import android.content.Context
import co.quis.flutter_contacts.accounts.impl.GetAllImpl
import co.quis.flutter_contacts.accounts.impl.GetDefaultImpl
import co.quis.flutter_contacts.accounts.impl.ShowDefaultPickerImpl
import co.quis.flutter_contacts.common.MappedHandler
import java.util.concurrent.ExecutorService

/**
 * Domain handler for account operations. Routes method calls to specific implementation classes.
 */
class AccountsHandler(
    private val context: Context,
    private val executor: ExecutorService,
) : MappedHandler() {
    override val handlers =
        mapOf(
            "getAll" to GetAllImpl(context, executor),
            "getDefault" to GetDefaultImpl(context, executor),
            "showDefaultPicker" to ShowDefaultPickerImpl(context, executor),
        )
}
