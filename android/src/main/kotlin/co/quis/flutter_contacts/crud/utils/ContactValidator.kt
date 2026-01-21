package co.quis.flutter_contacts.crud.utils

import co.quis.flutter_contacts.crud.models.contact.Contact

object ContactValidator {
    fun validateHasProperties(contact: Contact): Set<String> {
        val metadata =
            contact.metadata
                ?: throw IllegalStateException(
                    "Contact must have metadata. Contact must be fetched using getContact() or getAllContacts() before updating.",
                )

        val properties = metadata.properties
        if (properties.isEmpty()) {
            throw IllegalStateException(
                "Contact metadata contains no properties. Contact must be fetched with at least one property before updating.",
            )
        }

        return properties
    }

    fun validateSameProperties(contacts: List<Contact>): Set<String> {
        if (contacts.isEmpty()) return emptySet()

        val firstProperties = validateHasProperties(contacts.first())

        for (contact in contacts.drop(1)) {
            val properties = validateHasProperties(contact)
            if (properties != firstProperties) {
                throw IllegalStateException(
                    "All contacts must have the same set of properties in metadata. All contacts must be fetched with the same properties parameter.",
                )
            }
        }

        return firstProperties
    }
}
