package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class DateValidator <: AbstractCalendarValidator {
//   static functions:
//     public static func getInstance(): DateValidator
//
//   constructors:
//     public init()
//     public init(strict: Bool, dateStyle: Int64)
//
//   methods:
//     public func compareDates(value: Date, other: Date, timeZone: TimeZone): Int64
//     public func compareMonths(value: Date, other: Date, timeZone: TimeZone): Int64
//     public func compareQuarters(value: Date, other: Date, timeZone: TimeZone): Int64
//     public func compareQuarters(value: Date, other: Date, timeZone: TimeZone, monthOfFirstQuarter: Int64): Int64
//     public func compareWeeks(value: Date, other: Date, timeZone: TimeZone): Int64
//     public func compareYears(value: Date, other: Date, timeZone: TimeZone): Int64
//     public override func processParsedValue(value: Calendar, formatter: DateFormat): ?Any
//     public func validate(value: ?String): ?Date
//     public func validate(value: ?String, locale: Locale): ?Date
//     public func validate(value: ?String, locale: Locale, timeZone: TimeZone): ?Date
//     public func validate(value: ?String, pattern: String): ?Date
//     public func validate(value: ?String, pattern: String, locale: Locale): ?Date
//     public func validate(value: ?String, pattern: String, locale: Locale, timeZone: TimeZone): ?Date
//     public func validate(value: ?String, pattern: String, timeZone: TimeZone): ?Date
//     public func validate(value: ?String, timeZone: TimeZone): ?Date
// }

public class DateValidator <: AbstractCalendarValidator {
    private static let VALIDATOR = DateValidator()

    public static func getInstance(): DateValidator {
        VALIDATOR
    }

    public init() {
        this(true, DateFormat.SHORT)
    }

    public init(strict: Bool, dateStyle: Int64) {
        super(strict, dateStyle, -1)
    }

    private func getCalendar(value: Date, timeZone: TimeZone): Calendar {
        let calendar = Calendar.getInstance(timeZone)
        calendar.setTime(value)
        calendar
    }

    public func compareDates(value: Date, other: Date, timeZone: TimeZone): Int64 {
        compare(getCalendar(value, timeZone), getCalendar(other, timeZone), Calendar.DATE)
    }

    public func compareMonths(value: Date, other: Date, timeZone: TimeZone): Int64 {
        compare(getCalendar(value, timeZone), getCalendar(other, timeZone), Calendar.MONTH)
    }

    public func compareQuarters(value: Date, other: Date, timeZone: TimeZone): Int64 {
        compareQuarters(value, other, timeZone, 1)
    }

    public func compareQuarters(value: Date, other: Date, timeZone: TimeZone, monthOfFirstQuarter: Int64): Int64 {
        super.compareQuarters(getCalendar(value, timeZone), getCalendar(other, timeZone), monthOfFirstQuarter)
    }

    public func compareWeeks(value: Date, other: Date, timeZone: TimeZone): Int64 {
        compare(getCalendar(value, timeZone), getCalendar(other, timeZone), Calendar.WEEK_OF_YEAR)
    }

    public func compareYears(value: Date, other: Date, timeZone: TimeZone): Int64 {
        compare(getCalendar(value, timeZone), getCalendar(other, timeZone), Calendar.YEAR)
    }

    public override func processParsedValue(value: Calendar, formatter: DateFormat): ?Any {
        Some(value.getTime())
    }

    public func validate(value: ?String): ?Date {
        validate(value, None<String>, None<Locale>, None<TimeZone>)
    }

    public func validate(value: ?String, locale: Locale): ?Date {
        validate(value, None<String>, Some(locale), None<TimeZone>)
    }

    public func validate(value: ?String, locale: Locale, timeZone: TimeZone): ?Date {
        validate(value, None<String>, Some(locale), Some(timeZone))
    }

    public func validate(value: ?String, pattern: String): ?Date {
        validate(value, Some(pattern), None<Locale>, None<TimeZone>)
    }

    public func validate(value: ?String, pattern: String, locale: Locale): ?Date {
        validate(value, Some(pattern), Some(locale), None<TimeZone>)
    }

    public func validate(value: ?String, pattern: String, locale: Locale, timeZone: TimeZone): ?Date {
        validate(value, Some(pattern), Some(locale), Some(timeZone))
    }

    public func validate(value: ?String, pattern: String, timeZone: TimeZone): ?Date {
        validate(value, Some(pattern), None<Locale>, Some(timeZone))
    }

    public func validate(value: ?String, timeZone: TimeZone): ?Date {
        validate(value, None<String>, None<Locale>, Some(timeZone))
    }

    private func validate(value: ?String, pattern: ?String, locale: ?Locale, timeZone: ?TimeZone): ?Date {
        match (parse(value, pattern, locale, timeZone)) {
            case Some(parsed: Date) => Some(parsed)
            case _ => None<Date>
        }
    }
}
