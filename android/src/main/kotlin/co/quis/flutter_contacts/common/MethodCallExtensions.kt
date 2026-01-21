package co.quis.flutter_contacts.common

import io.flutter.plugin.common.MethodCall

/** Extension functions for cleaner argument extraction. */
inline fun <reified T> MethodCall.argList(key: String): List<T>? = argument<List<*>>(key)?.mapNotNull { it as? T }

inline fun <reified T> MethodCall.argListRequired(key: String): List<T> = argument<List<*>>(key)!!.mapNotNull { it as? T }

fun MethodCall.argString(key: String): String? = argument<String>(key)

fun MethodCall.argInt(key: String): Int? = argument<Int>(key)

fun MethodCall.argBool(
    key: String,
    default: Boolean = false,
): Boolean {
    val args = arguments as? Map<*, *> ?: return default
    val value = args[key]
    return when (value) {
        is Boolean -> value
        is Int -> value != 0
        is Long -> value != 0L
        else -> default
    }
}

fun MethodCall.argMap(key: String): Map<*, *>? = argument<Map<*, *>>(key)
