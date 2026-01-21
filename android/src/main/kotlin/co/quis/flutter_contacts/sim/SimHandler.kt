package co.quis.flutter_contacts.sim

import android.content.Context
import co.quis.flutter_contacts.common.MappedHandler
import co.quis.flutter_contacts.sim.impl.GetImpl
import java.util.concurrent.ExecutorService

/** Domain handler for SIM operations. Routes method calls to specific implementation classes. */
class SimHandler(
    private val context: Context,
    private val executor: ExecutorService,
) : MappedHandler() {
    private val getImpl = GetImpl(context, executor)

    override val handlers = mapOf("get" to getImpl)
}
