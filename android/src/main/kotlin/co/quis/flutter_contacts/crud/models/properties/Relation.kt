package co.quis.flutter_contacts.crud.models.properties

import android.content.ContentProviderOperation
import android.database.Cursor
import co.quis.flutter_contacts.common.CursorHelpers.getString
import co.quis.flutter_contacts.crud.models.JsonHelpers
import co.quis.flutter_contacts.crud.models.labels.Label
import co.quis.flutter_contacts.crud.models.labels.RelationLabel
import java.util.Objects
import android.provider.ContactsContract.CommonDataKinds.Relation as RelationData

data class Relation(
    val name: String,
    val label: Label = Label(label = "other"),
    val metadata: PropertyMetadata? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): Relation =
            Relation(
                name = json["name"] as String,
                label = JsonHelpers.decodeRequiredObject(json, "label", Label::fromJson),
                metadata = JsonHelpers.decodeOptionalObject(json, "metadata", PropertyMetadata::fromJson),
            )

        fun fromCursor(cursor: Cursor): Relation =
            Relation(
                name = cursor.getString(RelationData.NAME),
                label = RelationLabel.fromCursor(cursor),
                metadata = PropertyHelpers.extractMetadata(cursor),
            )
    }

    fun toJson(): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>("name" to name, "label" to label.toJson())
        JsonHelpers.encodeOptionalObject(result, "metadata", metadata) { it.toJson() }
        return result
    }

    fun toInsertOperation(
        rawContactId: Long? = null,
        rawContactIndex: Int = 0,
        addYield: Boolean = false,
    ): ContentProviderOperation {
        val labelPair = RelationLabel.toAndroidLabel(label.label, label.customLabel)
        return PropertyHelpers.buildInsertOperation(
            rawContactId,
            rawContactIndex,
            RelationData.CONTENT_ITEM_TYPE,
            addYield,
        ) {
            withValue(RelationData.NAME, name)
            withTypeAndLabel(RelationData.TYPE, RelationData.LABEL, labelPair)
        }
    }

    fun toUpdateOperation(): ContentProviderOperation {
        val labelPair = RelationLabel.toAndroidLabel(label.label, label.customLabel)
        return PropertyHelpers.buildUpdateOperation(
            PropertyHelpers.requireDataId(metadata, "relation"),
        ) {
            withValue(RelationData.NAME, name)
            withTypeAndLabel(RelationData.TYPE, RelationData.LABEL, labelPair)
        }
    }

    fun toDeleteOperation(): ContentProviderOperation =
        PropertyHelpers.buildDeleteOperation(
            PropertyHelpers.requireDataId(metadata, "relation"),
        )

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Relation) return false
        return name == other.name && label == other.label
    }

    override fun hashCode() = Objects.hash(name, label)
}
