package co.quis.flutter_contacts.crud.models.labels

/**
 * Generic label converter helper that uses maps for efficient lookups.
 * Handles custom labels automatically.
 */
object LabelConverter {
    /**
     * Converts from Android type to label string using a map.
     * Returns custom label if type is CUSTOM_TYPE, otherwise returns mapped label or default.
     */
    fun fromAndroidType(
        type: Int,
        customLabel: String?,
        typeToLabelMap: Map<Int, String>,
        customType: Int,
        defaultLabel: String,
    ): Label {
        if (type == customType) {
            return Label(label = "custom", customLabel = customLabel)
        }
        val label = typeToLabelMap[type] ?: defaultLabel
        return Label(label = label)
    }

    /**
     * Converts from label string to Android type using a map.
     * Returns Pair(type, customLabelString).
     * customLabelString is empty unless type is CUSTOM_TYPE.
     */
    fun toAndroidType(
        label: String,
        customLabel: String?,
        labelToTypeMap: Map<String, Int>,
        customType: Int,
    ): Pair<Int, String> {
        val type = labelToTypeMap[label] ?: customType
        val labelString = if (type == customType) (customLabel ?: label) else ""
        return Pair(type, labelString)
    }
}
