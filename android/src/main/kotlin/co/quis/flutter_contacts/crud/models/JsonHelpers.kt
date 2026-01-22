package co.quis.flutter_contacts.crud.models

/**
 * Reusable JSON encoding/decoding helpers.
 */
object JsonHelpers {
    /**
     * Encodes an optional value to JSON if not null.
     */
    fun <T> encodeOptional(
        json: MutableMap<String, Any?>,
        key: String,
        value: T?,
    ) {
        value?.let { json[key] = it }
    }

    /**
     * Encodes an optional object to JSON if not null.
     */
    fun <T> encodeOptionalObject(
        json: MutableMap<String, Any?>,
        key: String,
        value: T?,
        toJson: (T) -> Map<String, Any?>,
    ) {
        value?.let { json[key] = toJson(it) }
    }

    /**
     * Encodes a list to JSON if not empty.
     */
    fun <T> encodeList(
        json: MutableMap<String, Any?>,
        key: String,
        list: List<T>,
        toJson: (T) -> Map<String, Any?>,
    ) {
        if (list.isNotEmpty()) {
            json[key] = list.map(toJson)
        }
    }

    /**
     * Decodes an optional value from JSON.
     */
    @Suppress("UNCHECKED_CAST")
    fun <T> decodeOptional(
        json: Map<String, Any?>,
        key: String,
    ): T? = json[key] as? T

    /**
     * Decodes an optional object from JSON.
     */
    fun <T> decodeOptionalObject(
        json: Map<String, Any?>,
        key: String,
        fromJson: (Map<String, Any?>) -> T,
    ): T? {
        @Suppress("UNCHECKED_CAST")
        val value = json[key] as? Map<String, Any?>
        return value?.let { fromJson(it) }
    }

    @Suppress("UNCHECKED_CAST")
    fun <T> decodeRequiredObject(
        json: Map<String, Any?>,
        key: String,
        fromJson: (Map<String, Any?>) -> T,
    ): T {
        val value =
            json[key] as? Map<String, Any?>
                ?: throw IllegalArgumentException("Missing $key")
        return fromJson(value)
    }

    fun toStringKeyMap(map: Map<*, *>): Map<String, Any?> =
        map.entries
            .mapNotNull { (key, value) ->
                (key as? String)?.let { it to value }
            }.toMap()

    /**
     * Decodes a list from JSON, returning empty list if null or missing.
     */
    @Suppress("UNCHECKED_CAST")
    fun <T> decodeList(
        json: Map<String, Any?>,
        key: String,
        fromJson: (Map<String, Any?>) -> T,
    ): List<T> {
        val value = json[key] as? List<Map<String, Any?>>
        return value?.map { fromJson(it) } ?: emptyList()
    }

    /**
     * Decodes an optional timestamp (Number) from JSON as Long.
     */
    fun decodeOptionalTimestamp(
        json: Map<String, Any?>,
        key: String,
    ): Long? = (json[key] as? Number)?.toLong()
}
