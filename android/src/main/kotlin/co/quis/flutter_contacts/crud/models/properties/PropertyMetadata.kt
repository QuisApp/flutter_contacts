package co.quis.flutter_contacts.crud.models.properties

data class PropertyMetadata(
    val dataId: String? = null,
    val rawContactId: String? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): PropertyMetadata =
            PropertyMetadata(
                dataId = json["dataId"] as? String,
                rawContactId = json["rawContactId"] as? String,
            )
    }

    fun toJson(): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>()
        dataId?.let { result["dataId"] = it }
        rawContactId?.let { result["rawContactId"] = it }
        return result
    }
}
