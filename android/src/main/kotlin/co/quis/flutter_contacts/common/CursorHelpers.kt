package co.quis.flutter_contacts.common

import android.content.ContentResolver
import android.database.Cursor
import android.net.Uri
import java.util.WeakHashMap

/**
 * Helper functions for common cursor operations. Shared across all APIs (CRUD, Groups, Blocked
 * Numbers, SIM, etc.).
 */
object CursorHelpers {
    private val columnIndexCache = WeakHashMap<Cursor, MutableMap<String, Int>>()

    private fun Cursor.getCachedColumnIndex(columnName: String): Int {
        val cache =
            synchronized(columnIndexCache) {
                columnIndexCache.getOrPut(this) { mutableMapOf() }
            }
        return cache.getOrPut(columnName) { getColumnIndex(columnName) }
    }

    private inline fun <T> Cursor.getOrNull(
        columnName: String,
        getter: Cursor.(Int) -> T,
    ): T? {
        val index = getCachedColumnIndex(columnName)
        if (index < 0) return null
        return runCatching { getter(index) }.getOrNull()
    }

    /** Gets a string value from a cursor column, or null if the column doesn't exist. */
    fun Cursor.getStringOrNull(columnName: String): String? = getOrNull(columnName) { getString(it) }

    /**
     * Gets a string value from a cursor column, or the default value if the column doesn't exist or
     * is null.
     */
    fun Cursor.getString(
        columnName: String,
        default: String = "",
    ): String = getStringOrNull(columnName) ?: default

    /** Gets an int value from a cursor column, or null if the column doesn't exist. */
    fun Cursor.getIntOrNull(columnName: String): Int? = getOrNull(columnName) { getInt(it) }

    /** Gets a long value from a cursor column, or null if the column doesn't exist. */
    fun Cursor.getLongOrNull(columnName: String): Long? = getOrNull(columnName) { getLong(it) }

    /** Gets a blob value from a cursor column, or null if the column doesn't exist. */
    fun Cursor.getBlobOrNull(columnName: String): ByteArray? = getOrNull(columnName) { getBlob(it) }

    /**
     * Iterates through a cursor, calling the block for each row. Collects results into a list using
     * buildList.
     */
    inline fun <T> Cursor.mapRows(block: (Cursor) -> T): List<T> {
        if (!moveToFirst()) return emptyList()
        return buildList {
            do {
                add(block(this@mapRows))
            } while (this@mapRows.moveToNext())
        }
    }

    /** Iterates through a cursor without collecting results. */
    inline fun Cursor.forEachRow(block: (Cursor) -> Unit) {
        if (!moveToFirst()) return
        do {
            block(this)
        } while (moveToNext())
    }

    /**
     * Executes a query and processes the cursor with the given block. Returns null if the query
     * returns null. The cursor is automatically closed after the block executes.
     */
    inline fun <T> ContentResolver.queryAndProcess(
        uri: Uri,
        projection: Array<String>? = null,
        selection: String? = null,
        selectionArgs: Array<String>? = null,
        sortOrder: String? = null,
        block: (Cursor) -> T,
    ): T? = query(uri, projection, selection, selectionArgs, sortOrder)?.use(block)
}
