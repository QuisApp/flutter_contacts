package co.quis.flutter_contacts.crud.models.properties

import android.content.ContentProviderOperation
import android.database.Cursor
import android.provider.ContactsContract.Data
import co.quis.flutter_contacts.common.CursorHelpers.getLongOrNull

object PropertyHelpers {
    fun extractMetadata(cursor: Cursor): PropertyMetadata? {
        val dataId = cursor.getLongOrNull(Data._ID)?.toString()
        val rawContactId = cursor.getLongOrNull(Data.RAW_CONTACT_ID)?.toString()
        return if (dataId != null || rawContactId != null) {
            PropertyMetadata(dataId = dataId, rawContactId = rawContactId)
        } else {
            null
        }
    }

    inline fun buildInsertOperation(
        rawContactId: Long?,
        rawContactIndex: Int,
        mimeType: String,
        addYield: Boolean = false,
        block: ContentProviderOperation.Builder.() -> Unit,
    ): ContentProviderOperation {
        val builder = ContentProviderOperation.newInsert(Data.CONTENT_URI)
        if (rawContactId != null) {
            builder.withValue(Data.RAW_CONTACT_ID, rawContactId)
        } else {
            builder.withValueBackReference(Data.RAW_CONTACT_ID, rawContactIndex)
        }
        if (addYield) {
            builder.withYieldAllowed(true)
        }
        return builder.withValue(Data.MIMETYPE, mimeType).apply(block).build()
    }

    inline fun buildUpdateOperation(
        dataId: String,
        block: ContentProviderOperation.Builder.() -> Unit,
    ): ContentProviderOperation =
        ContentProviderOperation
            .newUpdate(Data.CONTENT_URI)
            .withSelection("${Data._ID} = ?", arrayOf(dataId))
            .apply(block)
            .build()

    fun buildDeleteOperation(dataId: String): ContentProviderOperation =
        ContentProviderOperation
            .newDelete(Data.CONTENT_URI)
            .withSelection("${Data._ID} = ?", arrayOf(dataId))
            .build()

    fun requireDataId(
        metadata: PropertyMetadata?,
        propertyName: String,
    ): String =
        metadata?.dataId?.toLongOrNull()?.toString()
            ?: throw IllegalStateException(
                "Cannot update $propertyName without dataId in metadata",
            )
}

fun ContentProviderOperation.Builder.withTypeAndLabel(
    typeColumn: String,
    labelColumn: String,
    typeAndLabel: Pair<Int, String>,
) {
    withValue(typeColumn, typeAndLabel.first)
    if (typeAndLabel.second.isNotEmpty()) {
        withValue(labelColumn, typeAndLabel.second)
    }
}

fun ContentProviderOperation.Builder.withPrimaryFlag(isPrimary: Boolean?) {
    withValue(Data.IS_PRIMARY, if (isPrimary == true) 1 else 0)
}
