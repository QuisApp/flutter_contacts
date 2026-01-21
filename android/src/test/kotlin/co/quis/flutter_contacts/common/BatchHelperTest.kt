package co.quis.flutter_contacts.common

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class BatchHelperTest {
    @Test
    fun shouldYieldEveryInterval() {
        assertTrue(BatchHelper.shouldYieldAtOperationIndex(99))
        assertTrue(BatchHelper.shouldYieldAtOperationIndex(199))
    }

    @Test
    fun forEachSelectionArgsBatchChunksItems() {
        val items = (1..(BatchHelper.MAX_SELECTION_ARGS + 5)).toList()
        val batches = mutableListOf<Int>()
        BatchHelper.forEachSelectionArgsBatch(items) { batch -> batches.add(batch.size) }
        assertEquals(2, batches.size)
        assertEquals(BatchHelper.MAX_SELECTION_ARGS, batches.first())
        assertEquals(5, batches.last())
    }
}
