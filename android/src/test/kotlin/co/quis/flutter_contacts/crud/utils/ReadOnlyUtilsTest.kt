package co.quis.flutter_contacts.crud.utils

import android.content.ContentResolver
import android.database.MatrixCursor
import android.provider.ContactsContract.Data
import co.quis.flutter_contacts.crud.models.contact.Contact
import co.quis.flutter_contacts.crud.models.labels.Label
import co.quis.flutter_contacts.crud.models.properties.Email
import co.quis.flutter_contacts.crud.models.properties.Phone
import co.quis.flutter_contacts.crud.models.properties.PropertyMetadata
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

// Robolectric provides the real ContactsContract Uris. Pinned below the compile SDK because
// Robolectric's SDK 36 sandbox needs Java 21.
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class ReadOnlyUtilsTest {
    private fun phone(
        dataId: String?,
        number: String = "555",
    ) = Phone(number = number, label = Label(label = "mobile"), metadata = PropertyMetadata(dataId = dataId))

    private fun email(dataId: String?) =
        Email(address = "a@b.com", label = Label(label = "home"), metadata = PropertyMetadata(dataId = dataId))

    /** Reports every data ID in [readOnlyDataIds] as read-only. */
    private fun contentResolver(vararg readOnlyDataIds: String): ContentResolver {
        val contentResolver = mockk<ContentResolver>()
        val selectionArgs = slot<Array<String>>()
        every {
            contentResolver.query(any(), any(), any(), capture(selectionArgs), any())
        } answers {
            MatrixCursor(arrayOf(Data._ID)).apply {
                selectionArgs.captured.filter { it in readOnlyDataIds }.forEach { addRow(arrayOf(it)) }
            }
        }
        return contentResolver
    }

    @Test
    fun namesTheEditedPropertyThatIsReadOnly() {
        val existing = Contact(id = "1", phones = listOf(phone("10")), emails = listOf(email("11")))
        val updated = Contact(id = "1", phones = listOf(phone("10", "999")), emails = listOf(email("11")))

        val readOnly =
            ReadOnlyUtils.getReadOnlyProperties(
                contentResolver("10"),
                listOf(existing to updated),
                setOf("phone", "email"),
            )

        assertEquals(setOf("phone"), readOnly)
    }

    @Test
    fun ignoresUnchangedProperties() {
        val existing = Contact(id = "1", phones = listOf(phone("10")), emails = listOf(email("11")))
        // Editing only the email still re-issues an update for the phone row; it changes nothing,
        // so the row being read-only doesn't matter.
        val updated = Contact(id = "1", phones = listOf(phone("10")), emails = listOf(email("11")))

        assertTrue(
            ReadOnlyUtils
                .getReadOnlyProperties(contentResolver("10"), listOf(existing to updated), setOf("phone", "email"))
                .isEmpty(),
        )
    }

    @Test
    fun ignoresPropertiesTheUpdateDoesNotTouch() {
        val existing = Contact(id = "1", phones = listOf(phone("10")))
        val updated = Contact(id = "1", phones = listOf(phone("10", "999")))

        // Only the fetched properties are written, so an unfetched read-only phone is irrelevant.
        assertTrue(
            ReadOnlyUtils
                .getReadOnlyProperties(contentResolver("10"), listOf(existing to updated), setOf("email"))
                .isEmpty(),
        )
    }

    @Test
    fun ignoresRemovedAndAddedProperties() {
        val existing = Contact(id = "1", phones = listOf(phone("10")))
        // "10" is dropped and a new phone is added: a delete and an insert, neither of which the
        // provider filters on the read-only flag.
        val updated = Contact(id = "1", phones = listOf(phone(null, "999")))

        assertTrue(
            ReadOnlyUtils
                .getReadOnlyProperties(contentResolver("10"), listOf(existing to updated), setOf("phone"))
                .isEmpty(),
        )
    }

    @Test
    fun allowsEditingWritableRowsOfAPartlyReadOnlyContact() {
        val existing = Contact(id = "1", phones = listOf(phone("10"), phone("11")))
        val updated = Contact(id = "1", phones = listOf(phone("10"), phone("11", "999")))

        // Row 12 is read-only but this update doesn't touch it.
        assertTrue(
            ReadOnlyUtils
                .getReadOnlyProperties(contentResolver("12"), listOf(existing to updated), setOf("phone"))
                .isEmpty(),
        )
    }

    @Test
    fun queriesTheFlagInTheSelectionNotTheProjection() {
        val contentResolver = mockk<ContentResolver>()
        val projection = slot<Array<String>>()
        val selection = slot<String>()
        every {
            contentResolver.query(any(), capture(projection), capture(selection), any(), any())
        } returns MatrixCursor(arrayOf(Data._ID))
        val existing = Contact(id = "1", phones = listOf(phone("10")))
        val updated = Contact(id = "1", phones = listOf(phone("10", "999")))

        ReadOnlyUtils.getReadOnlyProperties(contentResolver, listOf(existing to updated), setOf("phone"))

        // The provider omits the flag from its projection maps, so selecting it throws.
        assertTrue(selection.captured.contains(Data.IS_READ_ONLY))
        assertFalse(projection.captured.contains(Data.IS_READ_ONLY))
    }

    @Test
    fun readsEveryContactInTheBatchWithOneQuery() {
        val contentResolver = contentResolver("30")
        val updates =
            (10..40).map { id ->
                Contact(id = "$id", phones = listOf(phone("$id"))) to
                    Contact(id = "$id", phones = listOf(phone("$id", "999")))
            }

        val readOnly = ReadOnlyUtils.getReadOnlyProperties(contentResolver, updates, setOf("phone"))

        assertEquals(setOf("phone"), readOnly)
        verify(exactly = 1) { contentResolver.query(any(), any(), any(), any(), any()) }
    }

    @Test
    fun leavesUpdatesAloneWhenTheProviderRejectsTheFlag() {
        val contentResolver = mockk<ContentResolver>()
        every {
            contentResolver.query(any(), any(), any(), any(), any())
        } throws IllegalArgumentException("Invalid column is_read_only")
        val existing = Contact(id = "1", phones = listOf(phone("10")))
        val updated = Contact(id = "1", phones = listOf(phone("10", "999")))

        assertTrue(
            ReadOnlyUtils
                .getReadOnlyProperties(contentResolver, listOf(existing to updated), setOf("phone"))
                .isEmpty(),
        )
    }
}
