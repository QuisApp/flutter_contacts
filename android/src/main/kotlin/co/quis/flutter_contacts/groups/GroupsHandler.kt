package co.quis.flutter_contacts.groups

import android.content.Context
import co.quis.flutter_contacts.common.MappedHandler
import co.quis.flutter_contacts.groups.impl.AddContactsImpl
import co.quis.flutter_contacts.groups.impl.CreateImpl
import co.quis.flutter_contacts.groups.impl.DeleteImpl
import co.quis.flutter_contacts.groups.impl.GetAllImpl
import co.quis.flutter_contacts.groups.impl.GetForContactImpl
import co.quis.flutter_contacts.groups.impl.GetImpl
import co.quis.flutter_contacts.groups.impl.RemoveContactsImpl
import co.quis.flutter_contacts.groups.impl.UpdateImpl
import java.util.concurrent.ExecutorService

/** Domain handler for group operations. Routes method calls to specific implementation classes. */
class GroupsHandler(
    private val context: Context,
    private val executor: ExecutorService,
) : MappedHandler() {
    private val getImpl = GetImpl(context, executor)
    private val getAllImpl = GetAllImpl(context, executor)
    private val createImpl = CreateImpl(context, executor)
    private val updateImpl = UpdateImpl(context, executor)
    private val deleteImpl = DeleteImpl(context, executor)
    private val addContactsImpl = AddContactsImpl(context, executor)
    private val removeContactsImpl = RemoveContactsImpl(context, executor)
    private val getForContactImpl = GetForContactImpl(context, executor)

    override val handlers =
        mapOf(
            "get" to getImpl,
            "getAll" to getAllImpl,
            "create" to createImpl,
            "update" to updateImpl,
            "delete" to deleteImpl,
            "addContacts" to addContactsImpl,
            "removeContacts" to removeContactsImpl,
            "getOf" to getForContactImpl,
        )
}
