package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class TimeValidator <: AbstractCalendarValidator {
//   static functions:
//     public static func getInstance(): TimeValidator
//
//   constructors:
//     public init()
//     public init(strict: Bool, timeStyle: Int64)
//
//   methods:
//     public func compareHours(value: Calendar, compare: Calendar): Int64
//     public func compareMinutes(value: Calendar, compare: Calendar): Int64
//     public func compareSeconds(value: Calendar, compare: Calendar): Int64
//     public func compareTime(value: Calendar, compare: Calendar): Int64
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

public class TimeValidator <: AbstractCalendarValidator {
    private static let VALIDATOR = TimeValidator()

    public static func getInstance(): TimeValidator {
        VALIDATOR
    }

    public init() {
        this(true, DateFormat.SHORT)
    }

    public init(strict: Bool, timeStyle: Int64) {
        super(strict, -1, timeStyle)
    }

    public func compareHours(value: Calendar, compare: Calendar): Int64 {
        compareTime(value, compare, Calendar.HOUR_OF_DAY)
    }

    public func compareMinutes(value: Calendar, compare: Calendar): Int64 {
        compareTime(value, compare, Calendar.MINUTE)
    }

    public func compareSeconds(value: Calendar, compare: Calendar): Int64 {
        compareTime(value, compare, Calendar.SECOND)
    }

    public func compareTime(value: Calendar, compare: Calendar): Int64 {
        compareTime(value, compare, Calendar.MILLISECOND)
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
