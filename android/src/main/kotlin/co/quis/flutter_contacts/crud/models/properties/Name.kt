package co.quis.flutter_contacts.crud.models.properties

import android.content.ContentProviderOperation
import android.database.Cursor
import android.provider.ContactsContract.CommonDataKinds.Nickname
import android.provider.ContactsContract.CommonDataKinds.StructuredName
import android.provider.ContactsContract.Data
import co.quis.flutter_contacts.common.CursorHelpers.getString
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull
import co.quis.flutter_contacts.crud.models.JsonHelpers
import java.util.Objects

data class Name(
    val first: String? = null,
    val middle: String? = null,
    val last: String? = null,
    val prefix: String? = null,
    val suffix: String? = null,
    val phoneticFirst: String? = null,
    val phoneticMiddle: String? = null,
    val phoneticLast: String? = null,
    val nickname: String? = null,
    val metadata: PropertyMetadata? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): Name =
            Name(
                first = json["first"] as? String,
                middle = json["middle"] as? String,
                last = json["last"] as? String,
                prefix = json["prefix"] as? String,
                suffix = json["suffix"] as? String,
                phoneticFirst = json["phoneticFirst"] as? String,
                phoneticMiddle = json["phoneticMiddle"] as? String,
                phoneticLast = json["phoneticLast"] as? String,
                nickname = json["nickname"] as? String,
                metadata =
                    JsonHelpers.decodeOptionalObject(json, "metadata") {
                        PropertyMetadata.fromJson(it)
                    },
            )

        fun fromCursor(
            cursor: Cursor,
            existingName: Name? = null,
        ): Name {
            val mimetype = cursor.getString(Data.MIMETYPE, "")

            return when (mimetype) {
                StructuredName.CONTENT_ITEM_TYPE -> {
                    Name(
                        first = cursor.getStringOrNull(StructuredName.GIVEN_NAME),
                        middle = cursor.getStringOrNull(StructuredName.MIDDLE_NAME),
                        last = cursor.getStringOrNull(StructuredName.FAMILY_NAME),
                        prefix = cursor.getStringOrNull(StructuredName.PREFIX),
                        suffix = cursor.getStringOrNull(StructuredName.SUFFIX),
                        phoneticFirst =
                            cursor.getStringOrNull(StructuredName.PHONETIC_GIVEN_NAME),
                        phoneticMiddle =
                            cursor.getStringOrNull(StructuredName.PHONETIC_MIDDLE_NAME),
                        phoneticLast =
                            cursor.getStringOrNull(StructuredName.PHONETIC_FAMILY_NAME),
                        nickname = existingName?.nickname,
                    )
                }

                Nickname.CONTENT_ITEM_TYPE -> {
                    val nicknameValue = cursor.getStringOrNull(Nickname.NAME)
                    (existingName ?: Name()).copy(nickname = nicknameValue)
                }

                else -> {
                    existingName ?: Name()
                }
            }
        }
    }

    fun toJson(): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>()
        JsonHelpers.encodeOptional(result, "first", first)
        JsonHelpers.encodeOptional(result, "middle", middle)
        JsonHelpers.encodeOptional(result, "last", last)
        JsonHelpers.encodeOptional(result, "prefix", prefix)
        JsonHelpers.encodeOptional(result, "suffix", suffix)
        JsonHelpers.encodeOptional(result, "phoneticFirst", phoneticFirst)
        JsonHelpers.encodeOptional(result, "phoneticMiddle", phoneticMiddle)
        JsonHelpers.encodeOptional(result, "phoneticLast", phoneticLast)
        JsonHelpers.encodeOptional(result, "nickname", nickname)
        JsonHelpers.encodeOptionalObject(result, "metadata", metadata) { it.toJson() }
        return result
    }

    fun mergeWith(other: Name): Name =
        Name(
            first = first ?: other.first,
            middle = middle ?: other.middle,
            last = last ?: other.last,
            prefix = prefix ?: other.prefix,
            suffix = suffix ?: other.suffix,
            phoneticFirst = phoneticFirst ?: other.phoneticFirst,
            phoneticMiddle = phoneticMiddle ?: other.phoneticMiddle,
            phoneticLast = phoneticLast ?: other.phoneticLast,
            nickname = nickname ?: other.nickname,
            metadata = metadata ?: other.metadata,
        )

    fun toInsertOperations(
        rawContactIndex: Int = 0,
        addYield: Boolean = false,
    ): List<ContentProviderOperation> {
        val ops = mutableListOf<ContentProviderOperation>()
        ops.add(buildNameInsertOperation(null, rawContactIndex, addYield))
        nickname.trimmed()?.let { ops.add(buildNicknameInsertOperation(null, rawContactIndex, addYield)) }
        return ops
    }

    private fun buildNameInsertOperation(
        rawContactId: Long?,
        rawContactIndex: Int,
        addYield: Boolean = false,
    ): ContentProviderOperation =
        PropertyHelpers.buildInsertOperation(
            rawContactId,
            rawContactIndex,
            StructuredName.CONTENT_ITEM_TYPE,
            addYield,
        ) {
            trimmedValue(first)?.let { withValue(StructuredName.GIVEN_NAME, it) }
            trimmedValue(middle)?.let { withValue(StructuredName.MIDDLE_NAME, it) }
            trimmedValue(last)?.let { withValue(StructuredName.FAMILY_NAME, it) }
            trimmedValue(prefix)?.let { withValue(StructuredName.PREFIX, it) }
            trimmedValue(suffix)?.let { withValue(StructuredName.SUFFIX, it) }
            trimmedValue(phoneticFirst)?.let { withValue(StructuredName.PHONETIC_GIVEN_NAME, it) }
            trimmedValue(phoneticMiddle)?.let { withValue(StructuredName.PHONETIC_MIDDLE_NAME, it) }
            trimmedValue(phoneticLast)?.let { withValue(StructuredName.PHONETIC_FAMILY_NAME, it) }
        }

    private fun buildNicknameInsertOperation(
        rawContactId: Long?,
        rawContactIndex: Int,
        addYield: Boolean = false,
    ): ContentProviderOperation {
        val nicknameValue = nickname!!.trim()
        return PropertyHelpers.buildInsertOperation(
            rawContactId,
            rawContactIndex,
            Nickname.CONTENT_ITEM_TYPE,
            addYield,
        ) { withValue(Nickname.NAME, nicknameValue) }
    }

    fun toUpdateOperations(rawContactId: Long): List<ContentProviderOperation> {
        // Delete all name and nickname entries for this raw contact and re-insert. Unlike other
        // properties which are lists and matched by dataId, Name is a single value but Android can
        // have multiple name entries per raw contact.
        val ops = mutableListOf<ContentProviderOperation>()

        ops.add(
            ContentProviderOperation
                .newDelete(Data.CONTENT_URI)
                .withSelection(
                    "${Data.RAW_CONTACT_ID} = ? AND (${Data.MIMETYPE} = ? OR ${Data.MIMETYPE} = ?)",
                    arrayOf(
                        rawContactId.toString(),
                        StructuredName.CONTENT_ITEM_TYPE,
                        Nickname.CONTENT_ITEM_TYPE,
                    ),
                ).build(),
        )

        ops.addAll(toInsertOperationsWithRawContactId(rawContactId))

        return ops
    }

    private fun toInsertOperationsWithRawContactId(rawContactId: Long): List<ContentProviderOperation> {
        val ops = mutableListOf<ContentProviderOperation>()
        ops.add(buildNameInsertOperation(rawContactId, 0))
        nickname.trimmed()?.let { ops.add(buildNicknameInsertOperation(rawContactId, 0)) }
        return ops
    }

    private fun String?.trimmed(): String? = trimmedValue(this)

    private fun trimmedValue(value: String?): String? = value?.trim()?.takeIf { it.isNotEmpty() }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Name) return false
        return first == other.first &&
            middle == other.middle &&
            last == other.last &&
            prefix == other.prefix &&
            suffix == other.suffix &&
            phoneticFirst == other.phoneticFirst &&
            phoneticMiddle == other.phoneticMiddle &&
            phoneticLast == other.phoneticLast &&
            nickname == other.nickname
    }

    override fun hashCode() =
        Objects.hash(
            first,
            middle,
            last,
            prefix,
            suffix,
            phoneticFirst,
            phoneticMiddle,
            phoneticLast,
            nickname,
        )
}
