package co.quis.flutter_contacts.crud.models.labels

import android.database.Cursor
import android.provider.ContactsContract.CommonDataKinds.Relation
import co.quis.flutter_contacts.common.CursorHelpers.getIntOrNull
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull

object RelationLabel {
    private val TYPE_TO_LABEL =
        mapOf(
            Relation.TYPE_ASSISTANT to "assistant",
            Relation.TYPE_BROTHER to "brother",
            Relation.TYPE_CHILD to "child",
            Relation.TYPE_DOMESTIC_PARTNER to "domesticPartner",
            Relation.TYPE_FATHER to "father",
            Relation.TYPE_FRIEND to "friend",
            Relation.TYPE_MANAGER to "manager",
            Relation.TYPE_MOTHER to "mother",
            Relation.TYPE_PARENT to "parent",
            Relation.TYPE_PARTNER to "partner",
            Relation.TYPE_REFERRED_BY to "referredBy",
            Relation.TYPE_RELATIVE to "relative",
            Relation.TYPE_SISTER to "sister",
            Relation.TYPE_SPOUSE to "spouse",
        )

    private val LABEL_TO_TYPE =
        mapOf(
            "assistant" to Relation.TYPE_ASSISTANT,
            "brother" to Relation.TYPE_BROTHER,
            "child" to Relation.TYPE_CHILD,
            "domesticPartner" to Relation.TYPE_DOMESTIC_PARTNER,
            "father" to Relation.TYPE_FATHER,
            "friend" to Relation.TYPE_FRIEND,
            "manager" to Relation.TYPE_MANAGER,
            "mother" to Relation.TYPE_MOTHER,
            "parent" to Relation.TYPE_PARENT,
            "partner" to Relation.TYPE_PARTNER,
            "referredBy" to Relation.TYPE_REFERRED_BY,
            "relative" to Relation.TYPE_RELATIVE,
            "sister" to Relation.TYPE_SISTER,
            "spouse" to Relation.TYPE_SPOUSE,
            "other" to Relation.TYPE_CUSTOM,
            "custom" to Relation.TYPE_CUSTOM,
        )

    fun fromCursor(cursor: Cursor): Label {
        val type = cursor.getIntOrNull(Relation.TYPE) ?: Relation.TYPE_CUSTOM
        val customLabel = cursor.getStringOrNull(Relation.LABEL)
        return LabelConverter.fromAndroidType(
            type,
            customLabel,
            TYPE_TO_LABEL,
            Relation.TYPE_CUSTOM,
            "other",
        )
    }

    fun toAndroidLabel(
        label: String,
        customLabel: String?,
    ): Pair<Int, String> {
        val type = LABEL_TO_TYPE[label] ?: Relation.TYPE_CUSTOM
        return Pair(type, if (type == Relation.TYPE_CUSTOM) (customLabel ?: label) else "")
    }
}
