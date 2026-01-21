@file:Suppress("DEPRECATION")

package co.quis.flutter_contacts.crud.models.properties

import android.content.ContentProviderOperation
import android.database.Cursor
import co.quis.flutter_contacts.common.CursorHelpers.getString
import co.quis.flutter_contacts.crud.models.JsonHelpers
import co.quis.flutter_contacts.crud.models.labels.Label
import co.quis.flutter_contacts.crud.models.labels.SocialMediaLabel
import java.util.Objects
import android.provider.ContactsContract.CommonDataKinds.Im as ImData

data class SocialMedia(
    val username: String,
    val label: Label = Label(label = "other"),
    val metadata: PropertyMetadata? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): SocialMedia =
            SocialMedia(
                username = json["username"] as String,
                label = JsonHelpers.decodeRequiredObject(json, "label", Label::fromJson),
                metadata = JsonHelpers.decodeOptionalObject(json, "metadata", PropertyMetadata::fromJson),
            )

        fun fromCursor(cursor: Cursor): SocialMedia =
            SocialMedia(
                username = cursor.getString(ImData.DATA),
                label = SocialMediaLabel.fromCursor(cursor),
                metadata = PropertyHelpers.extractMetadata(cursor),
            )
    }

    fun toJson(): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>("username" to username, "label" to label.toJson())
        JsonHelpers.encodeOptionalObject(result, "metadata", metadata) { it.toJson() }
        return result
    }

    fun toInsertOperation(
        rawContactId: Long? = null,
        rawContactIndex: Int = 0,
        addYield: Boolean = false,
    ): ContentProviderOperation {
        val labelPair = SocialMediaLabel.toAndroidLabel(label.label, label.customLabel)
        return PropertyHelpers.buildInsertOperation(
            rawContactId,
            rawContactIndex,
            ImData.CONTENT_ITEM_TYPE,
            addYield,
        ) {
            withValue(ImData.DATA, username)
            withValue(ImData.PROTOCOL, labelPair.first)
            withValue(ImData.CUSTOM_PROTOCOL, labelPair.second)
        }
    }

    fun toUpdateOperation(): ContentProviderOperation {
        val labelPair = SocialMediaLabel.toAndroidLabel(label.label, label.customLabel)
        return PropertyHelpers.buildUpdateOperation(
            PropertyHelpers.requireDataId(metadata, "social media"),
        ) {
            withValue(ImData.DATA, username)
            withValue(ImData.PROTOCOL, labelPair.first)
            withValue(ImData.CUSTOM_PROTOCOL, labelPair.second)
        }
    }

    fun toDeleteOperation(): ContentProviderOperation =
        PropertyHelpers.buildDeleteOperation(
            PropertyHelpers.requireDataId(metadata, "social media"),
        )

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is SocialMedia) return false
        return username == other.username && label == other.label
    }

    override fun hashCode() = Objects.hash(username, label)
}
