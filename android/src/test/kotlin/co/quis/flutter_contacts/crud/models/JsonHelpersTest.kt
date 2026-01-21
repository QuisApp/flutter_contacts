package co.quis.flutter_contacts.crud.models

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class JsonHelpersTest {
    @Test
    fun encodeOptionalOnlyAddsWhenPresent() {
        val json = mutableMapOf<String, Any?>()
        JsonHelpers.encodeOptional(json, "name", "Ada")
        JsonHelpers.encodeOptional(json, "empty", null)
        assertEquals(mapOf("name" to "Ada"), json)
    }

    @Test
    fun decodeListReturnsEmptyWhenMissing() {
        val json = mapOf<String, Any?>()
        val values = JsonHelpers.decodeList(json, "items") { it["v"] as String }
        assertTrue(values.isEmpty())
    }
}
