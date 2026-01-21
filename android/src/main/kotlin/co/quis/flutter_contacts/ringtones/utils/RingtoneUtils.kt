package co.quis.flutter_contacts.ringtones.handlers

import android.content.Context
import android.database.Cursor
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.provider.MediaStore

object RingtoneUtils {
    fun parseRingtoneType(typeString: String?) =
        when (typeString?.lowercase()) {
            "ringtone" -> RingtoneManager.TYPE_RINGTONE
            "notification" -> RingtoneManager.TYPE_NOTIFICATION
            "alarm" -> RingtoneManager.TYPE_ALARM
            else -> RingtoneManager.TYPE_ALL
        }

    fun getRingtoneType(
        context: Context,
        uri: Uri,
    ): String? {
        val projection =
            arrayOf(
                MediaStore.Audio.Media.IS_RINGTONE,
                MediaStore.Audio.Media.IS_NOTIFICATION,
                MediaStore.Audio.Media.IS_ALARM,
            )
        return context.contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) {
                val isRingtoneIndex = cursor.getColumnIndex(MediaStore.Audio.Media.IS_RINGTONE)
                val isNotificationIndex = cursor.getColumnIndex(MediaStore.Audio.Media.IS_NOTIFICATION)
                val isAlarmIndex = cursor.getColumnIndex(MediaStore.Audio.Media.IS_ALARM)
                when {
                    isRingtoneIndex >= 0 && cursor.getInt(isRingtoneIndex) == 1 -> "ringtone"
                    isNotificationIndex >= 0 && cursor.getInt(isNotificationIndex) == 1 -> "notification"
                    isAlarmIndex >= 0 && cursor.getInt(isAlarmIndex) == 1 -> "alarm"
                    else -> null
                }
            } else {
                null
            }
        }
    }

    fun getMediaMetadata(
        context: Context,
        uri: Uri,
        title: String?,
        type: String?,
    ): Map<String, Any?>? {
        val projection =
            arrayOf(
                MediaStore.Audio.Media.TITLE,
                MediaStore.Audio.Media.ARTIST,
                MediaStore.Audio.Media.ALBUM,
                MediaStore.Audio.Media.DURATION,
                MediaStore.Audio.Media.DISPLAY_NAME,
                MediaStore.Audio.Media.SIZE,
                MediaStore.Audio.Media.DATE_ADDED,
                MediaStore.Audio.Media.DATE_MODIFIED,
                MediaStore.Audio.Media.MIME_TYPE,
            )
        return context.contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) {
                val metadata = mutableMapOf<String, Any?>()
                if (title != null) {
                    metadata["title"] = title
                }
                if (type != null) {
                    metadata["type"] = type
                }
                if (Build.VERSION.SDK_INT >= 33) {
                    metadata["hasHapticChannels"] = RingtoneManager.hasHapticChannels(context, uri)
                }
                listOf(
                    MediaStore.Audio.Media.TITLE to "mediaTitle",
                    MediaStore.Audio.Media.ARTIST to "artist",
                    MediaStore.Audio.Media.ALBUM to "album",
                    MediaStore.Audio.Media.DURATION to "duration",
                    MediaStore.Audio.Media.DISPLAY_NAME to "displayName",
                    MediaStore.Audio.Media.SIZE to "size",
                    MediaStore.Audio.Media.DATE_ADDED to "dateAdded",
                    MediaStore.Audio.Media.DATE_MODIFIED to "dateModified",
                    MediaStore.Audio.Media.MIME_TYPE to "mimeType",
                ).forEach { (column, key) ->
                    val index = cursor.getColumnIndex(column)
                    if (index >= 0 && !cursor.isNull(index)) {
                        metadata[key] =
                            if (key in listOf("duration", "size", "dateAdded", "dateModified")) {
                                cursor.getLong(index)
                            } else {
                                cursor.getString(index)
                            }
                    }
                }
                metadata.takeIf { it.isNotEmpty() }
            } else {
                null
            }
        }
    }

    fun buildRingtoneInfo(
        context: Context,
        uri: Uri,
        title: String?,
        type: String?,
        withMetadata: Boolean,
    ): Map<String, Any?> {
        val info =
            mutableMapOf<String, Any?>(
                "uri" to uri.toString(),
            )
        if (withMetadata) {
            val metadata = getMediaMetadata(context, uri, title, type)
            if (metadata != null) {
                // Flatten metadata into main response
                info.putAll(metadata)
            }
        }
        return info
    }
}
