package co.quis.flutter_contacts.crud.utils

import android.content.ContentProviderOperation
import android.content.ContentResolver
import android.content.ContentUris
import android.net.Uri
import android.provider.ContactsContract.AUTHORITY
import android.provider.ContactsContract.CommonDataKinds.Photo
import android.provider.ContactsContract.Data
import android.provider.ContactsContract.RawContacts
import co.quis.flutter_contacts.common.BatchHelper

object PhotoUtils {
    fun savePhoto(
        contentResolver: ContentResolver,
        rawContactId: Long,
        photoData: ByteArray,
    ) {
        val photoUri =
            Uri.withAppendedPath(
                ContentUris.withAppendedId(RawContacts.CONTENT_URI, rawContactId),
                RawContacts.DisplayPhoto.CONTENT_DIRECTORY,
            )
        contentResolver.openAssetFileDescriptor(photoUri, "rw")?.use { fd ->
            fd.createOutputStream().use { it.write(photoData) }
        }
    }

    /**
     * Deletes the contact photo for the entire aggregated contact. Android photos may exist on any
     * raw contact, so deleting by contact ID is more reliable.
     */
    fun deletePhotoForContact(
        contentResolver: ContentResolver,
        contactId: Long,
        rawContactIds: List<Long> = emptyList(),
    ) {
        BatchHelper.applyInBatches(
            contentResolver,
            AUTHORITY,
            listOf(
                ContentProviderOperation
                    .newDelete(Data.CONTENT_URI)
                    .withSelection(
                        "${RawContacts.CONTACT_ID} = ? AND ${Data.MIMETYPE} = ?",
                        arrayOf(contactId.toString(), Photo.CONTENT_ITEM_TYPE),
                    ).build(),
            ),
        )

        rawContactIds.forEach { rawContactId ->
            val uri =
                Uri.withAppendedPath(
                    ContentUris.withAppendedId(RawContacts.CONTENT_URI, rawContactId),
                    RawContacts.DisplayPhoto.CONTENT_DIRECTORY,
                )
            try {
                contentResolver.openAssetFileDescriptor(uri, "rw")?.use { fd ->
                    fd.createOutputStream().use { it.write(ByteArray(0)) }
                }
                contentResolver.delete(uri, null, null)
            } catch (e: Throwable) {
                // Ignore
            }
        }
    }
}
