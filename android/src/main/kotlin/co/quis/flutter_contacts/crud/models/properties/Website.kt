package co.quis.flutter_contacts.crud.models.properties

import android.content.ContentProviderOperation
import android.database.Cursor
import co.quis.flutter_contacts.common.CursorHelpers.getString
import co.quis.flutter_contacts.crud.models.JsonHelpers
import co.quis.flutter_contacts.crud.models.labels.Label
import co.quis.flutter_contacts.crud.models.labels.WebsiteLabel
import java.util.Objects
import android.provider.ContactsContract.CommonDataKinds.Website as WebsiteData

data class Website(
    val url: String,
    val label: Label = Label(label = "homepage"),
    val metadata: PropertyMetadata? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): Website =
            Website(
                url = json["url"] as String,
                label = JsonHelpers.decodeRequiredObject(json, "label", Label::fromJson),
                metadata = JsonHelpers.decodeOptionalObject(json, "metadata", PropertyMetadata::fromJson),
            )

        fun fromCursor(cursor: Cursor): Website =
            Website(
                url = cursor.getString(WebsiteData.URL),
                label = WebsiteLabel.fromCursor(cursor),
                metadata = PropertyHelpers.extractMetadata(cursor),
            )
    }

    fun toJson(): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>("url" to url, "label" to label.toJson())
        JsonHelpers.encodeOptionalObject(result, "metadata", metadata) { it.toJson() }
        return result
    }

    fun toInsertOperation(
        rawContactId: Long? = null,
        rawContactIndex: Int = 0,
        addYield: Boolean = false,
    ): ContentProviderOperation {
        val labelPair = WebsiteLabel.toAndroidLabel(label.label, label.customLabel)
        return PropertyHelpers.buildInsertOperation(
            rawContactId,
            rawContactIndex,
            WebsiteData.CONTENT_ITEM_TYPE,
            addYield,
        ) {
            withValue(WebsiteData.URL, url)
            withTypeAndLabel(WebsiteData.TYPE, WebsiteData.LABEL, labelPair)
        }
    }

    fun toUpdateOperation(): ContentProviderOperation {
        val labelPair = WebsiteLabel.toAndroidLabel(label.label, label.customLabel)
        return PropertyHelpers.buildUpdateOperation(
            PropertyHelpers.requireDataId(metadata, "website"),
        ) {
            withValue(WebsiteData.URL, url)
            withTypeAndLabel(WebsiteData.TYPE, WebsiteData.LABEL, labelPair)
        }
    }

    fun toDeleteOperation(): ContentProviderOperation =
        PropertyHelpers.buildDeleteOperation(
            PropertyHelpers.requireDataId(metadata, "website"),
        )

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Website) return false
        return url == other.url && label == other.label
    }

    override fun hashCode() = Objects.hash(url, label)
}
