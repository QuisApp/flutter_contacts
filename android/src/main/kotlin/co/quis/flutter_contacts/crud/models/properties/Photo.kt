package co.quis.flutter_contacts.crud.models.properties

import android.content.ContentResolver
import android.content.ContentUris
import android.content.res.AssetFileDescriptor
import android.database.Cursor
import android.net.Uri
import android.provider.ContactsContract.Contacts
import android.util.Base64
import co.quis.flutter_contacts.common.CursorHelpers.getBlobOrNull
import co.quis.flutter_contacts.crud.models.JsonHelpers
import java.util.Objects
import android.provider.ContactsContract.CommonDataKinds.Photo as PhotoData

data class Photo(
    val thumbnail: ByteArray? = null,
    val fullSize: ByteArray? = null,
    val metadata: PropertyMetadata? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): Photo =
            Photo(
                thumbnail = decodeBase64(json["thumbnail"] as? String),
                fullSize = decodeBase64(json["fullSize"] as? String),
                metadata = JsonHelpers.decodeOptionalObject(json, "metadata", PropertyMetadata::fromJson),
            )

        fun fromCursor(
            cursor: Cursor,
            existingPhoto: Photo? = null,
        ): Photo =
            Photo(
                thumbnail = cursor.getBlobOrNull(PhotoData.PHOTO),
                fullSize = existingPhoto?.fullSize,
            )

        fun loadFullSize(
            contentResolver: ContentResolver,
            contactId: String,
            existingPhoto: Photo? = null,
        ): Photo? {
            val contactUri = ContentUris.withAppendedId(Contacts.CONTENT_URI, contactId.toLong())
            val displayPhotoUri = Uri.withAppendedPath(contactUri, Contacts.Photo.DISPLAY_PHOTO)

            val fullSize =
                try {
                    val fd: AssetFileDescriptor? =
                        contentResolver.openAssetFileDescriptor(displayPhotoUri, "r")
                    fd?.use { fileDescriptor ->
                        fileDescriptor.createInputStream().use { inputStream ->
                            inputStream.readBytes()
                        }
                    }
                } catch (e: java.io.FileNotFoundException) {
                    // Photo file doesn't exist
                    null
                }

            return when {
                fullSize != null && existingPhoto != null -> existingPhoto.copy(fullSize = fullSize)
                fullSize != null && existingPhoto == null -> Photo(fullSize = fullSize)
                fullSize == null && existingPhoto != null -> existingPhoto
                else -> null
            }
        }

        fun loadThumbnail(
            contentResolver: ContentResolver,
            thumbnailUri: String?,
        ): Photo? {
            val uri = thumbnailUri?.takeIf { it.isNotEmpty() } ?: return null
            val bytes =
                try {
                    contentResolver.openInputStream(Uri.parse(uri))?.use { it.readBytes() }
                } catch (e: Exception) {
                    null
                }
            return bytes?.let { Photo(thumbnail = it) }
        }

        private fun decodeBase64(value: String?): ByteArray? =
            value?.let {
                try {
                    Base64.decode(it, Base64.DEFAULT)
                } catch (_: IllegalArgumentException) {
                    null
                }
            }
    }

    fun toJson(): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>()
        thumbnail?.let { result["thumbnail"] = Base64.encodeToString(it, Base64.NO_WRAP) }
        fullSize?.let { result["fullSize"] = Base64.encodeToString(it, Base64.NO_WRAP) }
        metadata?.let { result["metadata"] = metadata.toJson() }
        return result
    }

    fun mergeWith(other: Photo): Photo =
        Photo(
            thumbnail = thumbnail ?: other.thumbnail,
            fullSize = fullSize ?: other.fullSize,
            metadata = metadata ?: other.metadata,
        )

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Photo) return false
        // Optimization: Check hash first to avoid slow byte comparison
        if (other.hashCode() != hashCode()) return false
        // Optimization: Check length
        if (thumbnail?.size != other.thumbnail?.size || fullSize?.size != other.fullSize?.size) {
            return false
        }
        // Fallback: Deep byte comparison
        return thumbnail.contentEquals(other.thumbnail) && fullSize.contentEquals(other.fullSize)
    }

    override fun hashCode(): Int {
        fun hashBytes(bytes: ByteArray?): Int {
            if (bytes == null || bytes.isEmpty()) return 0
            val mid = bytes.size / 2
            return Objects.hash(
                bytes.size,
                bytes[0].toInt(),
                bytes[bytes.size - 1].toInt(),
                bytes[mid].toInt(),
            )
        }
        return Objects.hash(hashBytes(thumbnail), hashBytes(fullSize))
    }
}
