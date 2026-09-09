package co.quis.flutter_contacts.crud.models.properties

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class EventTest {
    // Extended format: vCard 3.0 (RFC 2426) and the AOSP Contacts app.

    @Test
    fun parsesExtendedDateWithYear() {
        assertEquals(Triple(1996, 4, 15), Event.parseDate("1996-04-15"))
    }

    @Test
    fun parsesExtendedDateWithoutYear() {
        assertEquals(Triple(null, 4, 15), Event.parseDate("--04-15"))
    }

    // Basic format: mandated by vCard 4.0 (RFC 6350), which disallows `YYYY-MM-DD`.

    @Test
    fun parsesBasicDateWithYear() {
        assertEquals(Triple(1996, 4, 15), Event.parseDate("19960415"))
    }

    @Test
    fun parsesBasicDateWithoutYear() {
        assertEquals(Triple(null, 4, 15), Event.parseDate("--0415"))
    }

    // `BDAY` may carry a time component in either spelling; it is discarded.

    @Test
    fun ignoresTimeComponentInExtendedDate() {
        assertEquals(Triple(1953, 10, 15), Event.parseDate("1953-10-15T23:10:00Z"))
    }

    @Test
    fun ignoresTimeComponentInBasicDate() {
        assertEquals(Triple(1953, 10, 15), Event.parseDate("19531015T231000Z"))
    }

    @Test
    fun ignoresSpaceSeparatedTimeComponent() {
        assertEquals(Triple(1996, 4, 15), Event.parseDate("1996-04-15 00:00:00"))
    }

    // Valid vCard 4.0 values that don't denote both a month and a day.

    @Test
    fun rejectsYearOnly() {
        assertNull(Event.parseDate("1985"))
    }

    @Test
    fun rejectsYearMonth() {
        assertNull(Event.parseDate("1985-04"))
    }

    @Test
    fun rejectsDayOnly() {
        assertNull(Event.parseDate("---15"))
    }

    @Test
    fun rejectsFreeText() {
        assertNull(Event.parseDate("circa 1800"))
    }

    @Test
    fun rejectsEmptyValue() {
        assertNull(Event.parseDate(""))
    }

    // Locale-ordered dates are ambiguous (March 10 or October 3?) and are never guessed.

    @Test
    fun rejectsPaddedLocaleOrderedDate() {
        assertNull(Event.parseDate("03/10/1978"))
        assertNull(Event.parseDate("10/03/1978"))
    }

    @Test
    fun rejectsUnpaddedLocaleOrderedDate() {
        assertNull(Event.parseDate("3/10/1978"))
    }

    // Out-of-range components are rejected.

    @Test
    fun rejectsOutOfRangeMonthAndDay() {
        assertNull(Event.parseDate("1996-13-15"))
        assertNull(Event.parseDate("1996-04-32"))
    }

    // Day-of-month is range-checked but not calendar-checked, so values that parsed before this
    // change keep parsing.

    @Test
    fun keepsAcceptingDatesThatAreRangeValidButNotCalendarValid() {
        assertEquals(Triple(1978, 2, 29), Event.parseDate("1978-02-29"))
        assertEquals(Triple(null, 2, 30), Event.parseDate("--02-30"))
    }
}
