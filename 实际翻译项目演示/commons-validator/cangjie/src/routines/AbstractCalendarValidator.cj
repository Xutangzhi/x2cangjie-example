package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class TimeZone {
//   static fields/constants:
//     public static let GMT = TimeZone("GMT", 0)
//
//   static functions:
//     public static func getDefault(): TimeZone
//     public static func setDefault(timeZone: TimeZone): Unit
//     public static func getTimeZone(id: String): TimeZone
//
//   constructors:
//     public init(id: String, rawOffsetMillis: Int64)
//
//   operator methods:
//     public operator func ==(other: TimeZone): Bool
//     public operator func !=(other: TimeZone): Bool
//
//   methods:
//     public func getID(): String
//     public func getRawOffset(): Int64
//     public func hasSameRules(other: TimeZone): Bool
//     public func toString(): String
// }

// public class Date {
//   constructors:
//     public init(epochMillis: Int64)
//
//   operator methods:
//     public operator func ==(other: Date): Bool
//     public operator func !=(other: Date): Bool
//
//   methods:
//     public func getTime(): Int64
//     public func toString(): String
// }

// public class Calendar {
//   static fields/constants:
//     public static let YEAR: Int64 = 1
//     public static let MONTH: Int64 = 2
//     public static let WEEK_OF_YEAR: Int64 = 3
//     public static let WEEK_OF_MONTH: Int64 = 4
//     public static let DATE: Int64 = 5
//     public static let DAY_OF_YEAR: Int64 = 6
//     public static let DAY_OF_WEEK: Int64 = 7
//     public static let DAY_OF_WEEK_IN_MONTH: Int64 = 8
//     public static let HOUR: Int64 = 9
//     public static let HOUR_OF_DAY: Int64 = 10
//     public static let MINUTE: Int64 = 11
//     public static let SECOND: Int64 = 12
//     public static let MILLISECOND: Int64 = 13
//     public static let JANUARY: Int64 = 0
//     public static let FEBRUARY: Int64 = 1
//     public static let MARCH: Int64 = 2
//     public static let APRIL: Int64 = 3
//     public static let MAY: Int64 = 4
//     public static let JUNE: Int64 = 5
//     public static let JULY: Int64 = 6
//     public static let AUGUST: Int64 = 7
//     public static let SEPTEMBER: Int64 = 8
//     public static let OCTOBER: Int64 = 9
//     public static let NOVEMBER: Int64 = 10
//     public static let DECEMBER: Int64 = 11
//
//   static functions:
//     public static func getInstance(): Calendar
//     public static func getInstance(timeZone: TimeZone): Calendar
//     public static func getInstance(locale: Locale): Calendar
//
//   constructors:
//     public init(timeZone: TimeZone)
//
//   methods:
//     public func get(field: Int64): Int64
//     public func getTime(): Date
//     public func getTimeZone(): TimeZone
//     public func set(field: Int64, value: Int64): Unit
//     public func set(year: Int64, month: Int64, date: Int64): Unit
//     public func set(year: Int64, month: Int64, date: Int64, hourOfDay: Int64, minute: Int64): Unit
//     public func setTime(value: Date): Unit
//     public func setTimeZone(timeZone: TimeZone): Unit
//     public func toString(): String
// }

// public open class DateFormat {
//   static fields/constants:
//     public static let SHORT: Int64 = 3
//
//   static functions:
//     public static func getDateInstance(style: Int64): DateFormat
//     public static func getDateInstance(style: Int64, locale: Locale): DateFormat
//     public static func getTimeInstance(style: Int64): DateFormat
//     public static func getTimeInstance(style: Int64, locale: Locale): DateFormat
//     public static func getDateTimeInstance(dateStyle: Int64, timeStyle: Int64): DateFormat
//     public static func getDateTimeInstance(dateStyle: Int64, timeStyle: Int64, locale: Locale): DateFormat
//
//   constructors:
//     protected init(pattern: String, locale: Locale)
//
//   methods:
//     public func getPattern(): String
//     public func getTimeZone(): TimeZone
//     public func setTimeZone(timeZone: TimeZone): Unit
//     public func format(value: Any): String
//     public func parseCalendar(value: String): ?Calendar
// }

// public class SimpleDateFormat <: DateFormat {
//   constructors:
//     public init(pattern: String)
//     public init(pattern: String, locale: Locale)
// }

// public abstract class AbstractCalendarValidator {
//   constructors:
//     public init(strict: Bool, dateStyle: Int64, timeStyle: Int64)
//
//   methods:
//     public func compare(value: Calendar, compare: Calendar, field: Int64): Int64
//     public open func compareQuarters(value: Calendar, compare: Calendar, monthOfFirstQuarter: Int64): Int64
//     protected func compareTime(value: Calendar, compare: Calendar, field: Int64): Int64
//     public func isStrict(): Bool
//     public func getDateStyle(): Int64
//     public func getTimeStyle(): Int64
//     protected func getFormat(locale: ?Locale): DateFormat
//     protected func getFormat(pattern: ?String, locale: ?Locale): DateFormat
//     public func format(value: ?Any): ?String
//     public func format(value: Any): String
//     public func format(value: Any, locale: Locale): String
//     public func format(value: Any, timeZone: TimeZone): String
//     public func format(value: Any, locale: Locale, timeZone: TimeZone): String
//     public func format(value: Any, pattern: String): String
//     public func format(value: Any, pattern: String, locale: Locale): String
//     public func format(value: Any, pattern: String, timeZone: TimeZone): String
//     public func format(value: Any, pattern: String, locale: Locale, timeZone: TimeZone): String
//     public func isValid(value: ?String): Bool
//     public func isValid(value: ?String, locale: Locale): Bool
//     public func isValid(value: ?String, pattern: String): Bool
//     public func isValid(value: ?String, pattern: String, locale: Locale): Bool
//     public func parse(value: ?String, pattern: ?String, locale: ?Locale, timeZone: ?TimeZone): ?Any
//     protected func processParsedValue(value: Calendar, formatter: DateFormat): ?Any
// }

import std.collection.*
import std.unicode.*

private let MILLIS_PER_SECOND: Int64 = 1000
private let MILLIS_PER_MINUTE: Int64 = 60 * MILLIS_PER_SECOND
private let MILLIS_PER_HOUR: Int64 = 60 * MILLIS_PER_MINUTE
private let MILLIS_PER_DAY: Int64 = 24 * MILLIS_PER_HOUR

private class CalendarFields {
    var year: Int64
    var month: Int64
    var day: Int64
    var hour: Int64
    var minute: Int64
    var second: Int64
    var millisecond: Int64

    init(year: Int64, month: Int64, day: Int64, hour: Int64, minute: Int64, second: Int64, millisecond: Int64) {
        this.year = year
        this.month = month
        this.day = day
        this.hour = hour
        this.minute = minute
        this.second = second
        this.millisecond = millisecond
    }
}

private func dateIsLeapYear(year: Int64): Bool {
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
}

private func dateDaysInMonth(year: Int64, month: Int64): Int64 {
    match (month) {
        case 0 => 31
        case 1 => if (dateIsLeapYear(year)) { 29 } else { 28 }
        case 2 => 31
        case 3 => 30
        case 4 => 31
        case 5 => 30
        case 6 => 31
        case 7 => 31
        case 8 => 30
        case 9 => 31
        case 10 => 30
        case _ => 31
    }
}

private func dateDayOfYear(year: Int64, month: Int64, day: Int64): Int64 {
    var total = day
    for (index in 0..month) {
        total += dateDaysInMonth(year, index)
    }
    total
}

private func dateDaysFromCivil(year: Int64, month: Int64, day: Int64): Int64 {
    var adjustedYear = year
    adjustedYear -= if (month <= 1) { 1 } else { 0 }
    let era = if (adjustedYear >= 0) { adjustedYear / 400 } else { (adjustedYear - 399) / 400 }
    let yearOfEra = adjustedYear - era * 400
    let monthPrime = month + if (month > 1) { -2 } else { 10 }
    let dayOfYear = (153 * monthPrime + 2) / 5 + day - 1
    let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
    era * 146097 + dayOfEra - 719468
}

private func dateCivilFromDays(days: Int64): (Int64, Int64, Int64) {
    let adjusted = days + 719468
    let era = if (adjusted >= 0) { adjusted / 146097 } else { (adjusted - 146096) / 146097 }
    let dayOfEra = adjusted - era * 146097
    let yearOfEra = (dayOfEra - dayOfEra / 1460 + dayOfEra / 36524 - dayOfEra / 146096) / 365
    var year = yearOfEra + era * 400
    let dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
    let monthPrime = (5 * dayOfYear + 2) / 153
    let day = dayOfYear - (153 * monthPrime + 2) / 5 + 1
    let month = monthPrime + if (monthPrime < 10) { 2 } else { -10 }
    year += if (month <= 1) { 1 } else { 0 }
    (year, month, day)
}

private func dateFieldsToEpochMillis(fields: CalendarFields, timeZone: TimeZone): Int64 {
    let days = dateDaysFromCivil(fields.year, fields.month, fields.day)
    let dayMillis = fields.hour * MILLIS_PER_HOUR + fields.minute * MILLIS_PER_MINUTE + fields.second * MILLIS_PER_SECOND + fields.millisecond
    days * MILLIS_PER_DAY + dayMillis - timeZone.getRawOffset()
}

private func dateEpochMillisToFields(epochMillis: Int64, timeZone: TimeZone): CalendarFields {
    let localMillis = epochMillis + timeZone.getRawOffset()
    var days = localMillis / MILLIS_PER_DAY
    var timeOfDay = localMillis % MILLIS_PER_DAY
    if (timeOfDay < 0) {
        timeOfDay += MILLIS_PER_DAY
        days--
    }
    let (year, month, day) = dateCivilFromDays(days)
    let hour = timeOfDay / MILLIS_PER_HOUR
    timeOfDay %= MILLIS_PER_HOUR
    let minute = timeOfDay / MILLIS_PER_MINUTE
    timeOfDay %= MILLIS_PER_MINUTE
    let second = timeOfDay / MILLIS_PER_SECOND
    let millisecond = timeOfDay % MILLIS_PER_SECOND
    CalendarFields(year, month, day, hour, minute, second, millisecond)
}

private func dateLower(text: String): String {
    var out = ArrayList<Rune>()
    for (character in text.toRuneArray()) {
        out.add(character.toLowerCase())
    }
    String(out)
}

private func dateZeroPad(value: Int64, width: Int64): String {
    let text = "${value}"
    if (text.size >= width) {
        return text
    }
    var zeros = ArrayList<Rune>()
    for (_ in 0..(width - text.size)) {
        zeros.add(r'0')
    }
    String(zeros) + text
}

private func dateMonthNames(locale: Locale): Array<String> {
    if (locale.language == "de") {
        return ["Jan", "Feb", "Mar", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"]
    }
    ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
}

private func dateShortDatePattern(locale: Locale): String {
    if (locale == Locale.US) {
        return "M/d/yy"
    }
    if (locale.language == "de") {
        return "d.M.yy"
    }
    "d/M/yy"
}

private func dateShortTimePattern(locale: Locale): String {
    if (locale == Locale.US) {
        return "h:mm a"
    }
    "H:mm"
}

private func dateShortDateTimePattern(locale: Locale): String {
    dateShortDatePattern(locale) + " " + dateShortTimePattern(locale)
}

private class DateToken {
    let symbol: String
    let literal: String
    let size: Int64

    init(symbol: String, literal: String, size: Int64) {
        this.symbol = symbol
        this.literal = literal
        this.size = size
    }
}

private func dateTokenize(pattern: String): Array<DateToken> {
    let runes = pattern.toRuneArray()
    var tokens = ArrayList<DateToken>()
    var index = 0
    while (index < runes.size) {
        let character = runes[index]
        if (character.isAsciiLetter()) {
            var end = index + 1
            while (end < runes.size && runes[end] == character) {
                end++
            }
            tokens.add(DateToken("${character}", "", end - index))
            index = end
        } else {
            tokens.add(DateToken("", "${character}", 1))
            index++
        }
    }
    tokens.toArray()
}

private func dateReadNumber(text: String, index: Int64, minDigits: Int64, maxDigits: Int64): ?(Int64, Int64, Int64) {
    let runes = text.toRuneArray()
    var end = index
    var value: Int64 = 0
    while (end < runes.size && end - index < maxDigits && runes[end].isAsciiNumber()) {
        value = value * 10 + runes[end].position() - r'0'.position()
        end++
    }
    if (end - index < minDigits) {
        return None<(Int64, Int64, Int64)>
    }
    Some((value, end, end - index))
}

private func dateParsePattern(text: String, pattern: String, locale: Locale, timeZone: TimeZone): ?Calendar {
    let tokens = dateTokenize(pattern)
    var index: Int64 = 0
    var year: Int64 = 1970
    var month: Int64 = 0
    var day: Int64 = 1
    var hour: Int64 = 0
    var minute: Int64 = 0
    var second: Int64 = 0
    var hasDate = false
    var hasTime = false
    var hour12 = false
    var pm = false

    for (token in tokens) {
        if (!token.literal.isEmpty()) {
            if (index >= text.size || text[index..index + token.literal.size] != token.literal) {
                return None<Calendar>
            }
            index += token.literal.size
            continue
        }
        match (token.symbol) {
            case "y" =>
                let minDigits = if (token.size >= 4) { 4 } else { 2 }
                let maxDigits = if (token.size >= 4) { 4 } else { 4 }
                match (dateReadNumber(text, index, minDigits, maxDigits)) {
                    case Some((parsed, end, digitsRead)) =>
                        year = if (digitsRead <= 2) { 2000 + parsed } else { parsed }
                        index = end
                        hasDate = true
                    case None =>
                        return None<Calendar>
                }
            case "M" =>
                if (token.size >= 3) {
                    let names = dateMonthNames(locale)
                    var matched = false
                    for (monthIndex in 0..names.size) {
                        let name = names[monthIndex]
                        if (index + name.size <= text.size && dateLower(text[index..index + name.size]) == dateLower(name)) {
                            month = monthIndex
                            index += name.size
                            matched = true
                            hasDate = true
                            break
                        }
                    }
                    if (!matched) {
                        return None<Calendar>
                    }
                } else {
                    match (dateReadNumber(text, index, 1, 2)) {
                        case Some((parsed, end, _)) =>
                            month = parsed - 1
                            index = end
                            hasDate = true
                        case None =>
                            return None<Calendar>
                    }
                }
            case "d" =>
                match (dateReadNumber(text, index, 1, 2)) {
                    case Some((parsed, end, _)) =>
                        day = parsed
                        index = end
                        hasDate = true
                    case None =>
                        return None<Calendar>
                }
            case "H" =>
                match (dateReadNumber(text, index, 1, 2)) {
                    case Some((parsed, end, _)) =>
                        hour = parsed
                        index = end
                        hasTime = true
                    case None =>
                        return None<Calendar>
                }
            case "h" =>
                match (dateReadNumber(text, index, 1, 2)) {
                    case Some((parsed, end, _)) =>
                        hour = parsed
                        hour12 = true
                        index = end
                        hasTime = true
                    case None =>
                        return None<Calendar>
                }
            case "m" =>
                match (dateReadNumber(text, index, 1, 2)) {
                    case Some((parsed, end, _)) =>
                        minute = parsed
                        index = end
                        hasTime = true
                    case None =>
                        return None<Calendar>
                }
            case "s" =>
                match (dateReadNumber(text, index, 1, 2)) {
                    case Some((parsed, end, _)) =>
                        second = parsed
                        index = end
                        hasTime = true
                    case None =>
                        return None<Calendar>
                }
            case "a" =>
                if (index + 2 > text.size) {
                    return None<Calendar>
                }
                let marker = dateLower(text[index..index + 2])
                if (marker == "am") {
                    pm = false
                } else if (marker == "pm") {
                    pm = true
                } else {
                    return None<Calendar>
                }
                index += 2
            case "z" =>
                let zoneId = text[index..]
                let zone = TimeZone.getTimeZone(zoneId)
                let calendar = Calendar.getInstance(zone)
                let actualHour = if (hour12) { if (pm) { if (hour == 12) { 12 } else { hour + 12 } } else { if (hour == 12) { 0 } else { hour } } } else { hour }
                calendar.set(year, month, day, actualHour, minute)
                calendar.set(Calendar.SECOND, second)
                calendar.set(Calendar.MILLISECOND, 0)
                return Some(calendar)
            case _ =>
                return None<Calendar>
        }
    }
    if (index != text.size) {
        return None<Calendar>
    }

    if (month < 0 || month > 11 || day < 1 || day > dateDaysInMonth(year, month)) {
        return None<Calendar>
    }
    let actualHour = if (hour12) {
        if (hour < 1 || hour > 12) {
            return None<Calendar>
        }
        if (pm) {
            if (hour == 12) { 12 } else { hour + 12 }
        } else {
            if (hour == 12) { 0 } else { hour }
        }
    } else {
        hour
    }
    if (actualHour < 0 || actualHour > 23 || minute < 0 || minute > 59 || second < 0 || second > 59) {
        return None<Calendar>
    }

    let calendar = Calendar.getInstance(timeZone)
    calendar.set(year, month, day, actualHour, minute)
    calendar.set(Calendar.SECOND, second)
    calendar.set(Calendar.MILLISECOND, 0)
    Some(calendar)
}

private func dateFormatPattern(calendar: Calendar, pattern: String, locale: Locale, timeZone: TimeZone): String {
    let localFields = dateEpochMillisToFields(calendar.getTime().getTime(), timeZone)
    let tokens = dateTokenize(pattern)
    let months = dateMonthNames(locale)
    var out = ""
    for (token in tokens) {
        if (!token.literal.isEmpty()) {
            out += token.literal
            continue
        }
        match (token.symbol) {
            case "y" =>
                if (token.size <= 2) {
                    out += dateZeroPad(localFields.year % 100, 2)
                } else {
                    out += dateZeroPad(localFields.year, 4)
                }
            case "M" =>
                if (token.size >= 3) {
                    out += months[localFields.month]
                } else if (token.size == 2) {
                    out += dateZeroPad(localFields.month + 1, 2)
                } else {
                    out += "${localFields.month + 1}"
                }
            case "d" =>
                out += if (token.size == 2) { dateZeroPad(localFields.day, 2) } else { "${localFields.day}" }
            case "H" =>
                out += if (token.size == 2) { dateZeroPad(localFields.hour, 2) } else { "${localFields.hour}" }
            case "h" =>
                let hour12 = if (localFields.hour % 12 == 0) { 12 } else { localFields.hour % 12 }
                out += if (token.size == 2) { dateZeroPad(hour12, 2) } else { "${hour12}" }
            case "m" =>
                out += if (token.size == 2) { dateZeroPad(localFields.minute, 2) } else { "${localFields.minute}" }
            case "s" =>
                out += if (token.size == 2) { dateZeroPad(localFields.second, 2) } else { "${localFields.second}" }
            case "a" =>
                out += if (localFields.hour >= 12) { "PM" } else { "AM" }
            case "z" =>
                out += timeZone.getID()
            case _ =>
                ()
        }
    }
    out
}

public class TimeZone {
    public static let GMT = TimeZone("GMT", 0)

    private static var defaultTimeZone: TimeZone = GMT

    public static func getDefault(): TimeZone {
        defaultTimeZone
    }

    public static func setDefault(timeZone: TimeZone): Unit {
        defaultTimeZone = timeZone
    }

    public static func getTimeZone(id: String): TimeZone {
        match (id) {
            case "GMT" => GMT
            case "UTC" => TimeZone("UTC", 0)
            case "EST" => TimeZone("EST", -5 * MILLIS_PER_HOUR)
            case "EET" => TimeZone("EET", 2 * MILLIS_PER_HOUR)
            case _ => GMT
        }
    }

    private let id: String
    private let rawOffsetMillis: Int64

    public init(id: String, rawOffsetMillis: Int64) {
        this.id = id
        this.rawOffsetMillis = rawOffsetMillis
    }

    public operator func ==(other: TimeZone): Bool {
        id == other.id && rawOffsetMillis == other.rawOffsetMillis
    }

    public operator func !=(other: TimeZone): Bool {
        !(this == other)
    }

    public func getID(): String {
        id
    }

    public func getRawOffset(): Int64 {
        rawOffsetMillis
    }

    public func hasSameRules(other: TimeZone): Bool {
        rawOffsetMillis == other.rawOffsetMillis
    }

    public func toString(): String {
        id
    }
}

public class Date {
    private let epochMillis: Int64

    public init(epochMillis: Int64) {
        this.epochMillis = epochMillis
    }

    public operator func ==(other: Date): Bool {
        epochMillis == other.epochMillis
    }

    public operator func !=(other: Date): Bool {
        !(this == other)
    }

    public func getTime(): Int64 {
        epochMillis
    }

    public func toString(): String {
        "Date(${epochMillis})"
    }
}

public class Calendar {
    public static let YEAR: Int64 = 1
    public static let MONTH: Int64 = 2
    public static let WEEK_OF_YEAR: Int64 = 3
    public static let WEEK_OF_MONTH: Int64 = 4
    public static let DATE: Int64 = 5
    public static let DAY_OF_YEAR: Int64 = 6
    public static let DAY_OF_WEEK: Int64 = 7
    public static let DAY_OF_WEEK_IN_MONTH: Int64 = 8
    public static let HOUR: Int64 = 9
    public static let HOUR_OF_DAY: Int64 = 10
    public static let MINUTE: Int64 = 11
    public static let SECOND: Int64 = 12
    public static let MILLISECOND: Int64 = 13
    public static let JANUARY: Int64 = 0
    public static let FEBRUARY: Int64 = 1
    public static let MARCH: Int64 = 2
    public static let APRIL: Int64 = 3
    public static let MAY: Int64 = 4
    public static let JUNE: Int64 = 5
    public static let JULY: Int64 = 6
    public static let AUGUST: Int64 = 7
    public static let SEPTEMBER: Int64 = 8
    public static let OCTOBER: Int64 = 9
    public static let NOVEMBER: Int64 = 10
    public static let DECEMBER: Int64 = 11

    public static func getInstance(): Calendar {
        Calendar(TimeZone.getDefault())
    }

    public static func getInstance(timeZone: TimeZone): Calendar {
        Calendar(timeZone)
    }

    public static func getInstance(locale: Locale): Calendar {
        Calendar(TimeZone.getDefault())
    }

    private var epochMillis: Int64
    private var timeZone: TimeZone

    public init(timeZone: TimeZone) {
        this.timeZone = timeZone
        this.epochMillis = dateFieldsToEpochMillis(CalendarFields(1970, 0, 1, 0, 0, 0, 0), timeZone)
    }

    private func setInternalFields(fields: CalendarFields): Unit {
        epochMillis = dateFieldsToEpochMillis(fields, timeZone)
    }

    private func getFields(): CalendarFields {
        dateEpochMillisToFields(epochMillis, timeZone)
    }

    public func get(field: Int64): Int64 {
        let fields = getFields()
        if (field == YEAR) {
            return fields.year
        }
        if (field == MONTH) {
            return fields.month
        }
        if (field == DATE) {
            return fields.day
        }
        if (field == DAY_OF_YEAR) {
            return dateDayOfYear(fields.year, fields.month, fields.day)
        }
        if (field == WEEK_OF_YEAR) {
            return (dateDayOfYear(fields.year, fields.month, fields.day) - 1) / 7 + 1
        }
        if (field == WEEK_OF_MONTH || field == DAY_OF_WEEK_IN_MONTH) {
            return (fields.day - 1) / 7 + 1
        }
        if (field == HOUR) {
            return fields.hour % 12
        }
        if (field == HOUR_OF_DAY) {
            return fields.hour
        }
        if (field == MINUTE) {
            return fields.minute
        }
        if (field == SECOND) {
            return fields.second
        }
        if (field == MILLISECOND) {
            return fields.millisecond
        }
        if (field == DAY_OF_WEEK) {
            let days = dateDaysFromCivil(fields.year, fields.month, fields.day)
            return ((days + 4) % 7 + 7) % 7 + 1
        }
        0
    }

    public func getTime(): Date {
        Date(epochMillis)
    }

    public func getTimeZone(): TimeZone {
        timeZone
    }

    public func set(field: Int64, value: Int64): Unit {
        let fields = getFields()
        if (field == YEAR) {
            fields.year = value
        } else if (field == MONTH) {
            fields.month = value
        } else if (field == DATE) {
            fields.day = value
        } else if (field == HOUR || field == HOUR_OF_DAY) {
            fields.hour = value
        } else if (field == MINUTE) {
            fields.minute = value
        } else if (field == SECOND) {
            fields.second = value
        } else if (field == MILLISECOND) {
            fields.millisecond = value
        }
        setInternalFields(fields)
    }

    public func set(year: Int64, month: Int64, date: Int64): Unit {
        let fields = getFields()
        fields.year = year
        fields.month = month
        fields.day = date
        setInternalFields(fields)
    }

    public func set(year: Int64, month: Int64, date: Int64, hourOfDay: Int64, minute: Int64): Unit {
        let fields = getFields()
        fields.year = year
        fields.month = month
        fields.day = date
        fields.hour = hourOfDay
        fields.minute = minute
        setInternalFields(fields)
    }

    public func setTime(value: Date): Unit {
        epochMillis = value.getTime()
    }

    public func setTimeZone(timeZone: TimeZone): Unit {
        this.timeZone = timeZone
    }

    public func toString(): String {
        let fields = getFields()
        "Calendar(${fields.year}-${fields.month + 1}-${fields.day} ${fields.hour}:${fields.minute}:${fields.second} ${timeZone.getID()})"
    }
}

public open class DateFormat {
    public static let SHORT: Int64 = 3

    public static func getDateInstance(style: Int64): DateFormat {
        getDateInstance(style, Locale.getDefault())
    }

    public static func getDateInstance(style: Int64, locale: Locale): DateFormat {
        DateFormat(dateShortDatePattern(locale), locale)
    }

    public static func getTimeInstance(style: Int64): DateFormat {
        getTimeInstance(style, Locale.getDefault())
    }

    public static func getTimeInstance(style: Int64, locale: Locale): DateFormat {
        DateFormat(dateShortTimePattern(locale), locale)
    }

    public static func getDateTimeInstance(dateStyle: Int64, timeStyle: Int64): DateFormat {
        getDateTimeInstance(dateStyle, timeStyle, Locale.getDefault())
    }

    public static func getDateTimeInstance(dateStyle: Int64, timeStyle: Int64, locale: Locale): DateFormat {
        DateFormat(dateShortDateTimePattern(locale), locale)
    }

    private let pattern: String
    private let locale: Locale
    private var timeZone: TimeZone

    protected init(pattern: String, locale: Locale) {
        this.pattern = pattern
        this.locale = locale
        this.timeZone = TimeZone.getDefault()
    }

    public func getPattern(): String {
        pattern
    }

    public func getTimeZone(): TimeZone {
        timeZone
    }

    public func setTimeZone(timeZone: TimeZone): Unit {
        this.timeZone = timeZone
    }

    public func format(value: Any): String {
        match (value) {
            case dateValue: Date =>
                let calendar = Calendar.getInstance(timeZone)
                calendar.setTime(dateValue)
                dateFormatPattern(calendar, pattern, locale, timeZone)
            case calendarValue: Calendar =>
                dateFormatPattern(calendarValue, pattern, locale, timeZone)
            case _ =>
                ""
        }
    }

    public func parseCalendar(value: String): ?Calendar {
        dateParsePattern(value, pattern, locale, timeZone)
    }
}

public class SimpleDateFormat <: DateFormat {
    public init(pattern: String) {
        super(pattern, Locale.getDefault())
    }

    public init(pattern: String, locale: Locale) {
        super(pattern, locale)
    }
}

public open class AbstractCalendarValidator {
    private let strict: Bool
    private let dateStyle: Int64
    private let timeStyle: Int64

    public init(strict: Bool, dateStyle: Int64, timeStyle: Int64) {
        this.strict = strict
        this.dateStyle = dateStyle
        this.timeStyle = timeStyle
    }

    private func calculateCompareResult(value: Calendar, compare: Calendar, field: Int64): Int64 {
        if (value.get(field) < compare.get(field)) {
            return -1
        }
        if (value.get(field) > compare.get(field)) {
            return 1
        }
        0
    }

    private func calculateQuarter(calendar: Calendar, monthOfFirstQuarter: Int64): Int64 {
        var year = calendar.get(Calendar.YEAR)
        let month = calendar.get(Calendar.MONTH) + 1
        let relativeMonth = if (month >= monthOfFirstQuarter) { month - monthOfFirstQuarter } else { month + 12 - monthOfFirstQuarter }
        let quarter = relativeMonth / 3 + 1
        if (month < monthOfFirstQuarter) {
            year--
        }
        year * 10 + quarter
    }

    public func compare(value: Calendar, compare: Calendar, field: Int64): Int64 {
        var result = calculateCompareResult(value, compare, Calendar.YEAR)
        if (result != 0 || field == Calendar.YEAR) {
            return result
        }
        if (field == Calendar.WEEK_OF_YEAR) {
            return calculateCompareResult(value, compare, Calendar.WEEK_OF_YEAR)
        }
        if (field == Calendar.DAY_OF_YEAR) {
            return calculateCompareResult(value, compare, Calendar.DAY_OF_YEAR)
        }
        result = calculateCompareResult(value, compare, Calendar.MONTH)
        if (result != 0 || field == Calendar.MONTH) {
            return result
        }
        if (field == Calendar.WEEK_OF_MONTH) {
            return calculateCompareResult(value, compare, Calendar.WEEK_OF_MONTH)
        }
        result = calculateCompareResult(value, compare, Calendar.DATE)
        if (result != 0 || field == Calendar.DATE || field == Calendar.DAY_OF_WEEK || field == Calendar.DAY_OF_WEEK_IN_MONTH) {
            return result
        }
        compareTime(value, compare, field)
    }

    public open func compareQuarters(value: Calendar, compare: Calendar, monthOfFirstQuarter: Int64): Int64 {
        let valueQuarter = calculateQuarter(value, monthOfFirstQuarter)
        let compareQuarter = calculateQuarter(compare, monthOfFirstQuarter)
        if (valueQuarter < compareQuarter) {
            return -1
        }
        if (valueQuarter > compareQuarter) {
            return 1
        }
        0
    }

    protected func compareTime(value: Calendar, compare: Calendar, field: Int64): Int64 {
        var result = calculateCompareResult(value, compare, Calendar.HOUR_OF_DAY)
        if (result != 0 || field == Calendar.HOUR || field == Calendar.HOUR_OF_DAY) {
            return result
        }
        result = calculateCompareResult(value, compare, Calendar.MINUTE)
        if (result != 0 || field == Calendar.MINUTE) {
            return result
        }
        result = calculateCompareResult(value, compare, Calendar.SECOND)
        if (result != 0 || field == Calendar.SECOND) {
            return result
        }
        if (field == Calendar.MILLISECOND) {
            return calculateCompareResult(value, compare, Calendar.MILLISECOND)
        }
        throw IllegalArgumentException("Invalid field: ${field}")
    }

    public func isStrict(): Bool {
        strict
    }

    public func getDateStyle(): Int64 {
        dateStyle
    }

    public func getTimeStyle(): Int64 {
        timeStyle
    }

    protected func getFormat(locale: ?Locale): DateFormat {
        let actualLocale = match (locale) {
            case Some(value) => value
            case None => Locale.getDefault()
        }
        if (dateStyle >= 0 && timeStyle >= 0) {
            return DateFormat.getDateTimeInstance(dateStyle, timeStyle, actualLocale)
        }
        if (timeStyle >= 0) {
            return DateFormat.getTimeInstance(timeStyle, actualLocale)
        }
        let useDateStyle = if (dateStyle >= 0) { dateStyle } else { DateFormat.SHORT }
        DateFormat.getDateInstance(useDateStyle, actualLocale)
    }

    protected func getFormat(pattern: ?String, locale: ?Locale): DateFormat {
        match (pattern) {
            case Some(text) =>
                if (!text.trimAscii().isEmpty()) {
                    return SimpleDateFormat(text, match (locale) {
                        case Some(value) => value
                        case None => Locale.getDefault()
                    })
                }
                getFormat(locale)
            case None =>
                getFormat(locale)
        }
    }

    public func format(value: ?Any): ?String {
        match (value) {
            case Some(inner) => Some(format(inner))
            case None => None<String>
        }
    }

    public func format(value: Any): String {
        format(value, None<String>, None<Locale>, None<TimeZone>)
    }

    public func format(value: Any, locale: Locale): String {
        format(value, None<String>, Some(locale), None<TimeZone>)
    }

    public func format(value: Any, timeZone: TimeZone): String {
        format(value, None<String>, None<Locale>, Some(timeZone))
    }

    public func format(value: Any, locale: Locale, timeZone: TimeZone): String {
        format(value, None<String>, Some(locale), Some(timeZone))
    }

    public func format(value: Any, pattern: String): String {
        format(value, Some(pattern), None<Locale>, None<TimeZone>)
    }

    public func format(value: Any, pattern: String, locale: Locale): String {
        format(value, Some(pattern), Some(locale), None<TimeZone>)
    }

    public func format(value: Any, pattern: String, timeZone: TimeZone): String {
        format(value, Some(pattern), None<Locale>, Some(timeZone))
    }

    public func format(value: Any, pattern: String, locale: Locale, timeZone: TimeZone): String {
        format(value, Some(pattern), Some(locale), Some(timeZone))
    }

    private func format(value: Any, pattern: ?String, locale: ?Locale, timeZone: ?TimeZone): String {
        let formatter = getFormat(pattern, locale)
        match (timeZone) {
            case Some(zone) => formatter.setTimeZone(zone)
            case None =>
                match (value) {
                    case calendarValue: Calendar => formatter.setTimeZone(calendarValue.getTimeZone())
                    case _ => ()
                }
        }
        formatter.format(value)
    }

    public func isValid(value: ?String): Bool {
        match (parse(value, None<String>, None<Locale>, None<TimeZone>)) {
            case Some(_) => true
            case None => false
        }
    }

    public func isValid(value: ?String, locale: Locale): Bool {
        match (parse(value, None<String>, Some(locale), None<TimeZone>)) {
            case Some(_) => true
            case None => false
        }
    }

    public func isValid(value: ?String, pattern: String): Bool {
        match (parse(value, Some(pattern), None<Locale>, None<TimeZone>)) {
            case Some(_) => true
            case None => false
        }
    }

    public func isValid(value: ?String, pattern: String, locale: Locale): Bool {
        match (parse(value, Some(pattern), Some(locale), None<TimeZone>)) {
            case Some(_) => true
            case None => false
        }
    }

    public func parse(value: ?String, pattern: ?String, locale: ?Locale, timeZone: ?TimeZone): ?Any {
        match (value) {
            case Some(text) =>
                let trimmed = text.trimAscii()
                if (trimmed.isEmpty()) {
                    return None<Any>
                }
                let formatter = getFormat(pattern, locale)
                match (timeZone) {
                    case Some(zone) => formatter.setTimeZone(zone)
                    case None => ()
                }
                match (formatter.parseCalendar(trimmed)) {
                    case Some(calendar) =>
                        processParsedValue(calendar, formatter)
                    case None =>
                        None<Any>
                }
            case None =>
                None<Any>
        }
    }

    protected open func processParsedValue(value: Calendar, formatter: DateFormat): ?Any {
        Some(value)
    }
}
