package co.quis.flutter_contacts.common

import android.content.ContentProviderOperation
import android.content.ContentResolver

object BatchHelper {
    // Use smaller batch sizes (200) and more frequent yields (every 100 operations) to avoid
    // exceeding the 500 yield point limit. This results in more batches with fewer operations
    // each, but each batch processes faster and stays within system limits.
    const val MAX_OPERATIONS_PER_BATCH = 200
    const val YIELD_INTERVAL = 100

    // SQLite bind param limit is 999; keep a safe margin for IN (...) selections.
    const val MAX_SELECTION_ARGS = 900

    /** Returns true when a batch op should allow yield for responsiveness. */
    fun shouldYieldAtOperationIndex(operationIndex: Int): Boolean = (operationIndex + 1) % YIELD_INTERVAL == 0

    /** Applies ContentProvider operations in batches of MAX_OPERATIONS_PER_BATCH. */
    fun applyInBatches(
        contentResolver: ContentResolver,
        authority: String,
        operations: List<ContentProviderOperation>,
    ) {
        if (operations.isEmpty()) return
        operations.chunked(MAX_OPERATIONS_PER_BATCH).forEach { batch ->
            contentResolver.applyBatch(authority, ArrayList(batch))
        }
    }

    /** Applies operations in batches and returns flattened results. */
    fun applyInBatchesWithResults(
        contentResolver: ContentResolver,
        authority: String,
        operations: List<ContentProviderOperation>,
    ): List<android.content.ContentProviderResult> {
        if (operations.isEmpty()) return emptyList()
        return operations.chunked(MAX_OPERATIONS_PER_BATCH).flatMap { batch ->
            contentResolver.applyBatch(authority, ArrayList(batch)).toList()
        }
    }

    /** Iterates items in safe IN(...) selection batches. */
    fun <T> forEachSelectionArgsBatch(
        items: List<T>,
        action: (List<T>) -> Unit,
    ) {
        if (items.isEmpty()) return
        items.chunked(MAX_SELECTION_ARGS).forEach(action)
    }
}
