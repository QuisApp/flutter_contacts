package co.quis.flutter_contacts.crud.utils

import android.content.ContentProviderOperation
import android.content.ContentResolver
import android.content.ContentUris
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.SystemClock
import android.provider.ContactsContract.AUTHORITY
import android.provider.ContactsContract.CommonDataKinds.Photo
import android.provider.ContactsContract.Data
import android.provider.ContactsContract.RawContacts
import android.util.Log
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
    ) = savePhotos(contentResolver, listOf(rawContactId to photoData))

    /**
     * Saves photos as Photo data rows inside provider transactions. The provider scales and stores
     * the display photo synchronously within the transaction, so writes are serialized (no race in
     * ContactsProvider's PhotoStore, which crashes the provider when photos are streamed through
     * DisplayPhoto in parallel) and each photo is visible as soon as this returns. Photos too large
     * for a Binder transaction fall back to streaming, one at a time.
     */
    fun savePhotos(
        contentResolver: ContentResolver,
        photos: List<Pair<Long, ByteArray>>,
    ) {
        // The provider silently drops data it can't decode; skipping it keeps any existing photo.
        val valid = photos.filter { (_, data) -> isDecodable(data) }
        val (small, large) = valid.partition { (_, data) -> data.size <= MAX_PHOTO_BATCH_BYTES }
        synchronized(this) {
            var ops = mutableListOf<ContentProviderOperation>()
            var bytes = 0
            fun flush() {
                if (ops.isEmpty()) return
                contentResolver.applyBatch(AUTHORITY, ArrayList(ops))
                ops = mutableListOf()
                bytes = 0
            }
            small.forEach { (rawContactId, data) ->
                if (bytes + data.size > MAX_PHOTO_BATCH_BYTES) flush()
                ops.add(
                    ContentProviderOperation
                        .newDelete(Data.CONTENT_URI)
                        .withSelection(
                            "${Data.RAW_CONTACT_ID} = ? AND ${Data.MIMETYPE} = ?",
                            arrayOf(rawContactId.toString(), Photo.CONTENT_ITEM_TYPE),
                        ).build(),
                )
                ops.add(
                    ContentProviderOperation
                        .newInsert(Data.CONTENT_URI)
                        .withValue(Data.RAW_CONTACT_ID, rawContactId)
                        .withValue(Data.MIMETYPE, Photo.CONTENT_ITEM_TYPE)
                        .withValue(Photo.PHOTO, data)
                        .build(),
                )
                bytes += data.size
            }
            flush()
            large.forEach { (rawContactId, data) -> streamPhoto(contentResolver, rawContactId, data) }
        }
    }

    // Binder transactions are capped at ~1 MB; leave room for the rest of the parcel.
    private const val MAX_PHOTO_BATCH_BYTES = 500_000

    private fun isDecodable(photoData: ByteArray): Boolean {
        val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeByteArray(photoData, 0, photoData.size, options)
        return options.outWidth > 0 && options.outHeight > 0
    }

    private fun streamPhoto(
        contentResolver: ContentResolver,
        rawContactId: Long,
        photoData: ByteArray,
    ) {
        val photoUri =
            Uri.withAppendedPath(
                ContentUris.withAppendedId(RawContacts.CONTENT_URI, rawContactId),
                RawContacts.DisplayPhoto.CONTENT_DIRECTORY,
            )
        val before = photoRowState(contentResolver, rawContactId)
        contentResolver.openAssetFileDescriptor(photoUri, "rw")?.use { fd ->
            fd.createOutputStream().use { it.write(photoData) }
        }
        awaitPhotoProcessed(contentResolver, rawContactId, before)
    }

    // The provider reads the stream and stores the photo on a background thread after it closes,
    // so wait for the photo data row to change before streaming the next one.
    private const val PHOTO_PROCESS_TIMEOUT_MS = 3_000L
    private const val PHOTO_PROCESS_POLL_MS = 20L

    private fun awaitPhotoProcessed(
        contentResolver: ContentResolver,
        rawContactId: Long,
        before: List<Any?>?,
    ) {
        val deadline = SystemClock.elapsedRealtime() + PHOTO_PROCESS_TIMEOUT_MS
        while (SystemClock.elapsedRealtime() < deadline) {
            val now = photoRowState(contentResolver, rawContactId)
            if (now != null && now != before) return
            Thread.sleep(PHOTO_PROCESS_POLL_MS)
        }
        Log.w("FlutterContacts", "Photo for raw contact $rawContactId not processed within ${PHOTO_PROCESS_TIMEOUT_MS}ms")
    }

    /** (data id, data version, photo file id) of the raw contact's photo row, or null if none. */
    private fun photoRowState(
        contentResolver: ContentResolver,
        rawContactId: Long,
    ): List<Any?>? =
        contentResolver
            .query(
                Data.CONTENT_URI,
                arrayOf(Data._ID, Data.DATA_VERSION, Photo.PHOTO_FILE_ID),
                "${Data.RAW_CONTACT_ID} = ? AND ${Data.MIMETYPE} = ?",
                arrayOf(rawContactId.toString(), Photo.CONTENT_ITEM_TYPE),
                null,
            )?.use { c ->
                if (!c.moveToFirst()) {
                    null
                } else {
                    listOf(c.getLong(0), c.getInt(1), if (c.isNull(2)) null else c.getLong(2))
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
