package co.quis.flutter_contacts.crud.utils

import android.content.ContentProviderOperation
import android.content.ContentResolver
import android.content.ContentUris
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.provider.ContactsContract.AUTHORITY
import android.provider.ContactsContract.CommonDataKinds.Photo
import android.provider.ContactsContract.Data
import android.provider.ContactsContract.RawContacts
import co.quis.flutter_contacts.common.BatchHelper
import java.io.ByteArrayOutputStream

object PhotoUtils {
    // Intent extras cross a Binder transaction capped at ~1 MB; leave room for the rest.
    private const val MAX_INTENT_PHOTO_BYTES = 400_000
    private const val MAX_INTENT_PHOTO_DIMENSION = 1080

    /** Downscales and re-encodes a photo so it fits safely in an intent extra. */
    fun compressForIntent(photo: ByteArray): ByteArray {
        if (photo.size <= MAX_INTENT_PHOTO_BYTES) return photo
        val bitmap = BitmapFactory.decodeByteArray(photo, 0, photo.size) ?: return photo
        val scale =
            MAX_INTENT_PHOTO_DIMENSION.toFloat() / maxOf(bitmap.width, bitmap.height)
        val scaled =
            if (scale < 1f) {
                Bitmap.createScaledBitmap(
                    bitmap,
                    (bitmap.width * scale).toInt().coerceAtLeast(1),
                    (bitmap.height * scale).toInt().coerceAtLeast(1),
                    true,
                )
            } else {
                bitmap
            }
        var quality = 90
        var bytes: ByteArray
        do {
            bytes =
                ByteArrayOutputStream().use { stream ->
                    scaled.compress(Bitmap.CompressFormat.JPEG, quality, stream)
                    stream.toByteArray()
                }
            quality -= 20
        } while (bytes.size > MAX_INTENT_PHOTO_BYTES && quality > 0)
        return bytes
    }

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
