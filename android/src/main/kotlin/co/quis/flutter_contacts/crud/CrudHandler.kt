package co.quis.flutter_contacts.crud

import android.content.Context
import co.quis.flutter_contacts.common.MappedHandler
import co.quis.flutter_contacts.crud.impl.CreateAllImpl
import co.quis.flutter_contacts.crud.impl.CreateImpl
import co.quis.flutter_contacts.crud.impl.DeleteAllImpl
import co.quis.flutter_contacts.crud.impl.DeleteImpl
import co.quis.flutter_contacts.crud.impl.GetAllImpl
import co.quis.flutter_contacts.crud.impl.GetImpl
import co.quis.flutter_contacts.crud.impl.UpdateAllImpl
import co.quis.flutter_contacts.crud.impl.UpdateImpl
import java.util.concurrent.ExecutorService

/** Domain handler for CRUD operations. Routes method calls to specific implementation classes. */
class CrudHandler(
    private val context: Context,
    private val executor: ExecutorService,
) : MappedHandler() {
    override val handlers =
        mapOf(
            "get" to GetImpl(context, executor),
            "getAll" to GetAllImpl(context, executor),
            "create" to CreateImpl(context, executor),
            "createAll" to CreateAllImpl(context, executor),
            "update" to UpdateImpl(context, executor),
            "updateAll" to UpdateAllImpl(context, executor),
            "delete" to DeleteImpl(context, executor),
            "deleteAll" to DeleteAllImpl(context, executor),
        )
}
