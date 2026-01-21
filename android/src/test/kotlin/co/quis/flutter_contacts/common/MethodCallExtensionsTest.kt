package co.quis.flutter_contacts.common

import io.flutter.plugin.common.MethodCall
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class MethodCallExtensionsTest {
    @Test
    fun argBoolHandlesBooleanAndInt() {
        val call =
            MethodCall(
                "test",
                mapOf(
                    "boolTrue" to true,
                    "boolFalse" to false,
                    "intOne" to 1L, // Flutter MethodCall stores integers as Long
                    "intZero" to 0L,
                ),
            )

        assertTrue(call.argBool("boolTrue"))
        assertFalse(call.argBool("boolFalse"))
        assertTrue(call.argBool("intOne"))
        assertFalse(call.argBool("intZero"))
        assertFalse(call.argBool("missing"))
    }

    @Test
    fun argListRequiredFiltersToType() {
        val call = MethodCall("test", mapOf("items" to listOf(1, 2, "x")))
        val values = call.argListRequired<Int>("items")
        assertEquals(listOf(1, 2), values)
    }
}
