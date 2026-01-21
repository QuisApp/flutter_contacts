package co.quis.flutter_contacts.crud.models.labels

import java.util.Objects

data class Label(
    val label: String,
    val customLabel: String? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): Label =
            Label(
                label = json["label"] as String,
                customLabel = json["customLabel"] as? String,
            )
    }

    fun toJson(): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>("label" to label)
        customLabel?.let { result["customLabel"] = it }
        return result
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Label) return false
        return label == other.label && customLabel == other.customLabel
    }

    override fun hashCode(): Int = Objects.hash(label, customLabel)
}
