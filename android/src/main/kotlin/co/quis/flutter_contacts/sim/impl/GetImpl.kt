package co.quis.flutter_contacts.sim.impl

import android.content.Context
import android.net.Uri
import co.quis.flutter_contacts.common.BaseHandler
import co.quis.flutter_contacts.common.CursorHelpers.getString
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull
import co.quis.flutter_contacts.common.CursorHelpers.mapRows
import co.quis.flutter_contacts.common.CursorHelpers.queryAndProcess
import co.quis.flutter_contacts.crud.models.contact.Contact
import co.quis.flutter_contacts.crud.models.labels.Label
import co.quis.flutter_contacts.crud.models.properties.Phone
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

class GetImpl(
    context: Context,
    executor: ExecutorService,
) : BaseHandler(context, executor) {
    override fun handleImpl(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val contacts = getSimContacts()
        postResult(result, contacts.map { it.toJson() })
    }

    private fun getSimContacts(): List<Contact> {
        return context.contentResolver.queryAndProcess(
            Uri.parse("content://icc/adn"),
            projection = arrayOf("_id", "name", "number"),
        ) { cursor ->
            cursor
                .mapRows { cursor ->
                    val simId = cursor.getStringOrNull("_id") ?: return@mapRows null
                    val simName = cursor.getString("name")
                    val simNumber = cursor.getString("number")
                    if (simName.isEmpty() && simNumber.isEmpty()) return@mapRows null
                    Contact(
                        id = simId,
                        displayName = simName.ifEmpty { simNumber },
                        phones =
                            simNumber.takeIf { it.isNotEmpty() }?.let {
                                listOf(
                                    Phone(
                                        number = it,
                                        label = Label(label = "mobile"),
                                    ),
                                )
                            }
                                ?: emptyList(),
                    )
                }.filterNotNull()
        }
            ?: emptyList()
    }
}
