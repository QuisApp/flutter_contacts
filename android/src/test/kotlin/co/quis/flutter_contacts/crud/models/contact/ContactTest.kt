package co.quis.flutter_contacts.crud.models.contact

import co.quis.flutter_contacts.crud.models.labels.Label
import co.quis.flutter_contacts.crud.models.properties.Name
import co.quis.flutter_contacts.crud.models.properties.Phone
import org.junit.Assert.assertEquals
import org.junit.Test

class ContactTest {
    @Test
    fun toJsonAndFromJsonRoundTrip() {
        val contact =
            Contact(
                id = "1",
                displayName = "Ada Lovelace",
                name = Name(first = "Ada", last = "Lovelace"),
                phones = listOf(Phone(number = "555", label = Label(label = "mobile"))),
            )

        val json = contact.toJson()
        val restored = Contact.fromJson(json)

        assertEquals(contact, restored)
        assertEquals("Ada", restored.name?.first)
        assertEquals("555", restored.phones.first().number)
    }
}
