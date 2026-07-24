package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class CalendarValidator <: AbstractCalendarValidator {
//   static functions:
//     public static func adjustToTimeZone(value: Calendar, timeZone: TimeZone): Unit
//     public static func getInstance(): CalendarValidator
//
//   constructors:
//     public init()
//     public init(strict: Bool, dateStyle: Int64)
//
//   methods:
//     public func compareDates(value: Calendar, other: Calendar): Int64
//     public func compareMonths(value: Calendar, other: Calendar): Int64
//     public func compareQuarters(value: Calendar, other: Calendar): Int64
//     public override func compareQuarters(value: Calendar, other: Calendar, monthOfFirstQuarter: Int64): Int64
//     public func compareWeeks(value: Calendar, other: Calendar): Int64
//     public func compareYears(value: Calendar, other: Calendar): Int64
//     public override func processParsedValue(value: Calendar, formatter: DateFormat): ?Any
//     public func validate(value: ?String): ?Calendar
//     public func validate(value: ?String, locale: Locale): ?Calendar
//     public func validate(value: ?String, locale: Locale, timeZone: TimeZone): ?Calendar
//     public func validate(value: ?String, pattern: String): ?Calendar
//     public func validate(value: ?String, pattern: String, locale: Locale): ?Calendar
//     public func validate(value: ?String, pattern: String, locale: Locale, timeZone: TimeZone): ?Calendar
//     public func validate(value: ?String, pattern: String, timeZone: TimeZone): ?Calendar
//     public func validate(value: ?String, timeZone: TimeZone): ?Calendar
// }

public class CalendarValidator <: AbstractCalendarValidator {
    private static let VALIDATOR = CalendarValidator()

    public static func adjustToTimeZone(value: Calendar, timeZone: TimeZone): Unit {
        if (value.getTimeZone().hasSameRules(timeZone)) {
            value.setTimeZone(timeZone)
            return
        }
        let year = value.get(Calendar.YEAR)
        let month = value.get(Calendar.MONTH)
        let date = value.get(Calendar.DATE)
        let hour = value.get(Calendar.HOUR_OF_DAY)
        let minute = value.get(Calendar.MINUTE)
        let second = value.get(Calendar.SECOND)
        let millisecond = value.get(Calendar.MILLISECOND)
        value.setTimeZone(timeZone)
        value.set(year, month, date, hour, minute)
        value.set(Calendar.SECOND, second)
        value.set(Calendar.MILLISECOND, millisecond)
    }

    public static func getInstance(): CalendarValidator {
        VALIDATOR
    }

    public init() {
        this(true, DateFormat.SHORT)
    }

    public init(strict: Bool, dateStyle: Int64) {
        super(strict, dateStyle, -1)
    }

    public func compareDates(value: Calendar, other: Calendar): Int64 {
        compare(value, other, Calendar.DATE)
    }

    public func compareMonths(value: Calendar, other: Calendar): Int64 {
        compare(value, other, Calendar.MONTH)
    }

    public func compareQuarters(value: Calendar, other: Calendar): Int64 {
        compareQuarters(value, other, 1)
    }

    public override func compareQuarters(value: Calendar, other: Calendar, monthOfFirstQuarter: Int64): Int64 {
        super.compareQuarters(value, other, monthOfFirstQuarter)
    }

    public func compareWeeks(value: Calendar, other: Calendar): Int64 {
        compare(value, other, Calendar.WEEK_OF_YEAR)
    }

    public func compareYears(value: Calendar, other: Calendar): Int64 {
        compare(value, other, Calendar.YEAR)
    }

    public override func processParsedValue(value: Calendar, formatter: DateFormat): ?Any {
        Some(value)
    }

    public func validate(value: ?String): ?Calendar {
        validate(value, None<String>, None<Locale>, None<TimeZone>)
    }

    public func validate(value: ?String, locale: Locale): ?Calendar {
        validate(value, None<String>, Some(locale), None<TimeZone>)
    }

    public func validate(value: ?String, locale: Locale, timeZone: TimeZone): ?Calendar {
        validate(value, None<String>, Some(locale), Some(timeZone))
    }

    public func validate(value: ?String, pattern: String): ?Calendar {
        validate(value, Some(pattern), None<Locale>, None<TimeZone>)
    }

    public func validate(value: ?String, pattern: String, locale: Locale): ?Calendar {
        validate(value, Some(pattern), Some(locale), None<TimeZone>)
    }

    public func validate(value: ?String, pattern: String, locale: Locale, timeZone: TimeZone): ?Calendar {
        validate(value, Some(pattern), Some(locale), Some(timeZone))
    }

    public func validate(value: ?String, pattern: String, timeZone: TimeZone): ?Calendar {
        validate(value, Some(pattern), None<Locale>, Some(timeZone))
    }

    public func validate(value: ?String, timeZone: TimeZone): ?Calendar {
        validate(value, None<String>, None<Locale>, Some(timeZone))
    }

    private func validate(value: ?String, pattern: ?String, locale: ?Locale, timeZone: ?TimeZone): ?Calendar {
        match (parse(value, pattern, locale, timeZone)) {
            case Some(parsed: Calendar) => Some(parsed)
            case _ => None<Calendar>
        }
    }
}
