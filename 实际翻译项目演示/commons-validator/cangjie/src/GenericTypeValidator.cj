package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

import std.collection.*

// public class Date {
//   fields/properties:
//     public let year: Int64
//     public let month: Int64
//     public let day: Int64
//
//   constructors:
//     public init(year: Int64, month: Int64, day: Int64)
//
//   operator methods:
//     public operator func ==(other: Date): Bool
//     public operator func !=(other: Date): Bool
//
//   methods:
//     public func toString(): String
// }

// public class GenericTypeValidator {
//   static functions:
//     public static func formatByte(value: ?String): ?Int8
//     public static func formatByte(value: ?String, locale: Locale): ?Int8
//     public static func formatByte(value: ?String, locale: ?Locale): ?Int8
//     public static func formatCreditCard(value: ?String): ?Int64
//     public static func formatDate(value: ?String, locale: Locale): ?Date
//     public static func formatDate(value: ?String, locale: ?Locale): ?Date
//     public static func formatDate(value: ?String, datePattern: String, strict: Bool): ?Date
//     public static func formatDouble(value: ?String): ?Float64
//     public static func formatDouble(value: ?String, locale: Locale): ?Float64
//     public static func formatDouble(value: ?String, locale: ?Locale): ?Float64
//     public static func formatFloat(value: ?String): ?Float32
//     public static func formatFloat(value: ?String, locale: Locale): ?Float32
//     public static func formatFloat(value: ?String, locale: ?Locale): ?Float32
//     public static func formatInt(value: ?String): ?Int32
//     public static func formatInt(value: ?String, locale: Locale): ?Int32
//     public static func formatInt(value: ?String, locale: ?Locale): ?Int32
//     public static func formatLong(value: ?String): ?Int64
//     public static func formatLong(value: ?String, locale: Locale): ?Int64
//     public static func formatLong(value: ?String, locale: ?Locale): ?Int64
//     public static func formatShort(value: ?String): ?Int16
//     public static func formatShort(value: ?String, locale: Locale): ?Int16
//     public static func formatShort(value: ?String, locale: ?Locale): ?Int16
//
//   constructors:
//     public init()
// }

private func genericTypeLocaleParts(locale: ?Locale): (String, String, String) {
    let actual = match (locale) {
        case Some(value) => value
        case None => Locale.getDefault()
    }
    (actual.language, actual.country, actual.variant)
}

private func genericTypeNumericSeparators(locale: ?Locale): (Rune, Rune) {
    let (language, _, _) = genericTypeLocaleParts(locale)
    if (language == "de") {
        return (r',', r'.')
    }
    if (language == "fr") {
        return (r',', r' ')
    }
    (r'.', r',')
}

private func genericTypeTrimFloatSuffix(value: String): String {
    if (value.isEmpty()) {
        return value
    }
    let chars = value.toRuneArray()
    let last = chars[chars.size - 1]
    if (last == r'f' || last == r'F' || last == r'd' || last == r'D') {
        return value[0..value.size - 1]
    }
    value
}

private func genericTypeTrimLeadingZeros(value: String): String {
    if (value.isEmpty()) {
        return "0"
    }
    var index = 0
    let chars = value.toRuneArray()
    while (index < chars.size - 1 && chars[index] == r'0') {
        index++
    }
    value[index..]
}

private func genericTypeNormalizeInteger(value: String): String {
    if (value.isEmpty()) {
        return "0"
    }
    let negative = value.startsWith("-")
    let core = if (negative || value.startsWith("+")) { value[1..] } else { value }
    let normalized = genericTypeTrimLeadingZeros(core)
    if (negative && normalized != "0") {
        return "-" + normalized
    }
    normalized
}

private func genericTypeSplitNormalizedInteger(value: String): (Bool, String) {
    let negative = value.startsWith("-")
    let core = if (negative) { value[1..] } else { value }
    (negative, genericTypeTrimLeadingZeros(core))
}

private func genericTypeComparePositiveIntegers(left: String, right: String): Int64 {
    let a = genericTypeTrimLeadingZeros(left)
    let b = genericTypeTrimLeadingZeros(right)
    if (a.size < b.size) {
        return -1
    }
    if (a.size > b.size) {
        return 1
    }
    if (a < b) {
        return -1
    }
    if (a > b) {
        return 1
    }
    0
}

private func genericTypeCompareSignedIntegers(left: String, right: String): Int64 {
    let (leftNegative, leftCore) = genericTypeSplitNormalizedInteger(left)
    let (rightNegative, rightCore) = genericTypeSplitNormalizedInteger(right)
    if (leftNegative && !rightNegative) {
        return -1
    }
    if (!leftNegative && rightNegative) {
        return 1
    }
    let compare = genericTypeComparePositiveIntegers(leftCore, rightCore)
    if (leftNegative) {
        return -compare
    }
    compare
}

private func genericTypeIntegerInRange(value: String, minValue: String, maxValue: String): Bool {
    genericTypeCompareSignedIntegers(value, minValue) >= 0 && genericTypeCompareSignedIntegers(value, maxValue) <= 0
}

private func genericTypeParseInt64Exact(text: String): ?Int64 {
    if (!genericTypeIntegerInRange(text, "-9223372036854775808", "9223372036854775807")) {
        return None<Int64>
    }
    let normalized = genericTypeNormalizeInteger(text)
    let negative = normalized.startsWith("-")
    let digits = if (negative) { normalized[1..] } else { normalized }
    var result: Int64 = 0
    for (ch in digits.toRuneArray()) {
        if (!ch.isAsciiNumber()) {
            return None<Int64>
        }
        let digit = ch.position() - r'0'.position()
        result = if (negative) { result * 10 - digit } else { result * 10 + digit }
    }
    Some(result)
}

private func genericTypeParsePlainInteger(value: ?String, minValue: String, maxValue: String): ?Int64 {
    match (value) {
        case Some(text) =>
            if (text.isEmpty()) {
                return None<Int64>
            }
            let chars = text.toRuneArray()
            for (i in 0..chars.size) {
                let ch = chars[i]
                if (i == 0 && (ch == r'+' || ch == r'-')) {
                    if (chars.size == 1) {
                        return None<Int64>
                    }
                    continue
                }
                if (!ch.isAsciiNumber()) {
                    return None<Int64>
                }
            }
            let normalized = genericTypeNormalizeInteger(text)
            if (!genericTypeIntegerInRange(normalized, minValue, maxValue)) {
                return None<Int64>
            }
            genericTypeParseInt64Exact(normalized)
        case None =>
            None<Int64>
    }
}

private func genericTypeParseLocalizedInteger(value: ?String, locale: ?Locale, minValue: String, maxValue: String): ?Int64 {
    match (value) {
        case Some(text) =>
            if (text.isEmpty()) {
                return None<Int64>
            }
            let (_, groupingSep) = genericTypeNumericSeparators(locale)
            var normalized = ""
            let chars = text.toRuneArray()
            for (i in 0..chars.size) {
                let ch = chars[i]
                if (i == 0 && (ch == r'+' || ch == r'-')) {
                    normalized += ch.toString()
                    continue
                }
                if (ch == groupingSep) {
                    continue
                }
                if (!ch.isAsciiNumber()) {
                    return None<Int64>
                }
                normalized += ch.toString()
            }
            if (normalized == "+" || normalized == "-") {
                return None<Int64>
            }
            normalized = genericTypeNormalizeInteger(normalized)
            if (!genericTypeIntegerInRange(normalized, minValue, maxValue)) {
                return None<Int64>
            }
            genericTypeParseInt64Exact(normalized)
        case None =>
            None<Int64>
    }
}

private func genericTypePow10(exponent: Int64): Float64 {
    var result = 1.0
    for (_ in 0..exponent) {
        result *= 10.0
    }
    result
}

private func genericTypeParseFloat64(text: String): ?Float64 {
    if (text.isEmpty()) {
        return None<Float64>
    }
    let chars = text.toRuneArray()
    var index = 0
    var negative = false
    if (chars[0] == r'+' || chars[0] == r'-') {
        negative = chars[0] == r'-'
        index++
        if (index >= chars.size) {
            return None<Float64>
        }
    }
    var integerPart = 0.0
    var fractionPart = 0.0
    var fractionDigits = 0
    var seenDigit = false
    var seenDecimal = false
    var exponentValue: Int64 = 0
    var exponentNegative = false
    var hasExponent = false
    while (index < chars.size) {
        let ch = chars[index]
        if (ch == r'e' || ch == r'E') {
            hasExponent = true
            index++
            if (index >= chars.size) {
                return None<Float64>
            }
            if (chars[index] == r'+' || chars[index] == r'-') {
                exponentNegative = chars[index] == r'-'
                index++
            }
            if (index >= chars.size) {
                return None<Float64>
            }
            while (index < chars.size) {
                let expCh = chars[index]
                if (!expCh.isAsciiNumber()) {
                    return None<Float64>
                }
                exponentValue = exponentValue * 10 + expCh.position() - r'0'.position()
                index++
            }
            break
        }
        if (ch == r'.') {
            if (seenDecimal) {
                return None<Float64>
            }
            seenDecimal = true
            index++
            continue
        }
        if (!ch.isAsciiNumber()) {
            return None<Float64>
        }
        seenDigit = true
        let digit = Float64(ch.position() - r'0'.position())
        if (seenDecimal) {
            fractionPart = fractionPart * 10.0 + digit
            fractionDigits++
        } else {
            integerPart = integerPart * 10.0 + digit
        }
        index++
    }
    if (!seenDigit) {
        return None<Float64>
    }
    var result = integerPart
    if (fractionDigits > 0) {
        result += fractionPart / genericTypePow10(fractionDigits)
    }
    if (hasExponent) {
        let scale = genericTypePow10(exponentValue)
        result = if (exponentNegative) { result / scale } else { result * scale }
    }
    if (negative) {
        result = -result
    }
    Some(result)
}

private func genericTypeParseLocalizedFloat(value: ?String, locale: ?Locale): ?Float64 {
    match (value) {
        case Some(text) =>
            if (text.isEmpty()) {
                return None<Float64>
            }
            let (decimalSep, groupingSep) = genericTypeNumericSeparators(locale)
            var normalized = ""
            let chars = genericTypeTrimFloatSuffix(text).toRuneArray()
            var seenDecimal = false
            for (i in 0..chars.size) {
                let ch = chars[i]
                if (i == 0 && (ch == r'+' || ch == r'-')) {
                    normalized += ch.toString()
                    continue
                }
                if (ch == groupingSep) {
                    continue
                }
                if (ch == decimalSep) {
                    if (seenDecimal) {
                        return None<Float64>
                    }
                    seenDecimal = true
                    normalized += "."
                    continue
                }
                normalized += ch.toString()
            }
            genericTypeParseFloat64(normalized)
        case None =>
            None<Float64>
    }
}

private func genericTypeDatePatterns(locale: ?Locale): Array<String> {
    let actual = match (locale) {
        case Some(value) => value
        case None => Locale.getDefault()
    }
    if (actual.language == "de" || actual.country == "DE") {
        return ["d.M.yy", "d.M.yyyy"]
    }
    if (actual.language == "fr") {
        return ["d/M/yy", "d/M/yyyy"]
    }
    if (actual.country == "US") {
        return ["M/d/yy", "M/d/yyyy"]
    }
    ["d/M/yy", "d/M/yyyy"]
}

private func genericTypeIsLeapYear(year: Int64): Bool {
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
}

private func genericTypeDaysInMonth(year: Int64, month: Int64): Int64 {
    match (month) {
        case 1 => if (genericTypeIsLeapYear(year)) { 29 } else { 28 }
        case 3 => 30
        case 5 => 30
        case 8 => 30
        case 10 => 30
        case 0 => 31
        case 2 => 31
        case 4 => 31
        case 6 => 31
        case 7 => 31
        case 9 => 31
        case 11 => 31
        case _ => 0
    }
}

private func genericTypeParsePatternDate(value: String, pattern: String, strict: Bool): ?Date {
    if (pattern.isEmpty()) {
        return None<Date>
    }
    let patternChars = pattern.toRuneArray()
    let valueChars = value.toRuneArray()
    var patternIndex = 0
    var valueIndex = 0
    var month = -1
    var day = -1
    var year = -1
    while (patternIndex < patternChars.size) {
        let kind = patternChars[patternIndex]
        if (kind == r'y' || kind == r'M' || kind == r'd') {
            var count = 1
            while (patternIndex + count < patternChars.size && patternChars[patternIndex + count] == kind) {
                count++
            }
            let minDigits = if (strict || kind == r'y') { count } else { 1 }
            let maxDigits =
                if (strict) {
                    count
                } else if (kind == r'y') {
                    if (count == 2) { 4 } else { count }
                } else {
                    2
                }
            var digits = ""
            while (valueIndex < valueChars.size && digits.size < maxDigits) {
                let valueChar = valueChars[valueIndex]
                if (!valueChar.isAsciiNumber()) {
                    break
                }
                digits += valueChar.toString()
                valueIndex++
            }
            if (digits.size < minDigits) {
                return None<Date>
            }
            match (genericTypeParseInt64Exact(digits)) {
                case Some(parsed) =>
                    if (kind == r'M') {
                        month = parsed
                    } else if (kind == r'd') {
                        day = parsed
                    } else {
                        year = if (digits.size == 2) {
                            if (parsed >= 50) { 1900 + parsed } else { 2000 + parsed }
                        } else {
                            parsed
                        }
                    }
                case None =>
                    return None<Date>
            }
            patternIndex += count
            continue
        }
        if (valueIndex >= valueChars.size || valueChars[valueIndex] != kind) {
            return None<Date>
        }
        patternIndex++
        valueIndex++
    }
    if (valueIndex != valueChars.size || year < 0 || month <= 0 || day <= 0) {
        return None<Date>
    }
    let monthIndex = month - 1
    let maxDay = genericTypeDaysInMonth(year, monthIndex)
    if (maxDay == 0 || day > maxDay) {
        return None<Date>
    }
    Some(Date(year, month, day))
}

private func genericTypeLuhn(value: String): Bool {
    var sum = 0
    var doubled = false
    let chars = value.toRuneArray()
    for (index in 0..chars.size) {
        let position = chars.size - 1 - index
        let ch = chars[position]
        if (!ch.isAsciiNumber()) {
            return false
        }
        var digit = ch.position() - r'0'.position()
        if (doubled) {
            digit *= 2
            if (digit > 9) {
                digit -= 9
            }
        }
        sum += Int64(digit)
        doubled = !doubled
    }
    sum % 10 == 0
}

public class Date {
    public let year: Int64
    public let month: Int64
    public let day: Int64

    public init(year: Int64, month: Int64, day: Int64) {
        this.year = year
        this.month = month
        this.day = day
    }

    public operator func ==(other: Date): Bool {
        year == other.year && month == other.month && day == other.day
    }

    public operator func !=(other: Date): Bool {
        !(this == other)
    }

    public func toString(): String {
        let monthText = if (month < 10) { "0${month}" } else { month.toString() }
        let dayText = if (day < 10) { "0${day}" } else { day.toString() }
        "${year}-${monthText}-${dayText}"
    }
}

public class GenericTypeValidator {
    public static func formatByte(value: ?String): ?Int8 {
        match (genericTypeParsePlainInteger(value, "-128", "127")) {
            case Some(parsed) => Some(Int8(parsed))
            case None => None<Int8>
        }
    }

    public static func formatByte(value: ?String, locale: Locale): ?Int8 {
        formatByte(value, Some(locale))
    }

    public static func formatByte(value: ?String, locale: ?Locale): ?Int8 {
        match (genericTypeParseLocalizedInteger(value, locale, "-128", "127")) {
            case Some(parsed) => Some(Int8(parsed))
            case None => None<Int8>
        }
    }

    public static func formatCreditCard(value: ?String): ?Int64 {
        match (value) {
            case Some(text) =>
                if (text.isEmpty() || !genericTypeLuhn(text)) {
                    return None<Int64>
                }
                genericTypeParsePlainInteger(Some(text), "0", "9223372036854775807")
            case None =>
                None<Int64>
        }
    }

    public static func formatDate(value: ?String, locale: Locale): ?Date {
        formatDate(value, Some(locale))
    }

    public static func formatDate(value: ?String, locale: ?Locale): ?Date {
        match (value) {
            case Some(text) =>
                for (pattern in genericTypeDatePatterns(locale)) {
                    match (genericTypeParsePatternDate(text, pattern, false)) {
                        case Some(date) => return Some(date)
                        case None => ()
                    }
                }
                None<Date>
            case None =>
                None<Date>
        }
    }

    public static func formatDate(value: ?String, datePattern: String, strict: Bool): ?Date {
        match (value) {
            case Some(text) => genericTypeParsePatternDate(text, datePattern, strict)
            case None => None<Date>
        }
    }

    public static func formatDouble(value: ?String): ?Float64 {
        match (value) {
            case Some(text) => genericTypeParseFloat64(genericTypeTrimFloatSuffix(text))
            case None => None<Float64>
        }
    }

    public static func formatDouble(value: ?String, locale: Locale): ?Float64 {
        formatDouble(value, Some(locale))
    }

    public static func formatDouble(value: ?String, locale: ?Locale): ?Float64 {
        genericTypeParseLocalizedFloat(value, locale)
    }

    public static func formatFloat(value: ?String): ?Float32 {
        match (formatDouble(value)) {
            case Some(parsed) => Some(Float32(parsed))
            case None => None<Float32>
        }
    }

    public static func formatFloat(value: ?String, locale: Locale): ?Float32 {
        formatFloat(value, Some(locale))
    }

    public static func formatFloat(value: ?String, locale: ?Locale): ?Float32 {
        match (genericTypeParseLocalizedFloat(value, locale)) {
            case Some(parsed) => Some(Float32(parsed))
            case None => None<Float32>
        }
    }

    public static func formatInt(value: ?String): ?Int32 {
        match (genericTypeParsePlainInteger(value, "-2147483648", "2147483647")) {
            case Some(parsed) => Some(Int32(parsed))
            case None => None<Int32>
        }
    }

    public static func formatInt(value: ?String, locale: Locale): ?Int32 {
        formatInt(value, Some(locale))
    }

    public static func formatInt(value: ?String, locale: ?Locale): ?Int32 {
        match (genericTypeParseLocalizedInteger(value, locale, "-2147483648", "2147483647")) {
            case Some(parsed) => Some(Int32(parsed))
            case None => None<Int32>
        }
    }

    public static func formatLong(value: ?String): ?Int64 {
        genericTypeParsePlainInteger(value, "-9223372036854775808", "9223372036854775807")
    }

    public static func formatLong(value: ?String, locale: Locale): ?Int64 {
        formatLong(value, Some(locale))
    }

    public static func formatLong(value: ?String, locale: ?Locale): ?Int64 {
        genericTypeParseLocalizedInteger(value, locale, "-9223372036854775808", "9223372036854775807")
    }

    public static func formatShort(value: ?String): ?Int16 {
        match (genericTypeParsePlainInteger(value, "-32768", "32767")) {
            case Some(parsed) => Some(Int16(parsed))
            case None => None<Int16>
        }
    }

    public static func formatShort(value: ?String, locale: Locale): ?Int16 {
        formatShort(value, Some(locale))
    }

    public static func formatShort(value: ?String, locale: ?Locale): ?Int16 {
        match (genericTypeParseLocalizedInteger(value, locale, "-32768", "32767")) {
            case Some(parsed) => Some(Int16(parsed))
            case None => None<Int16>
        }
    }

    public init() {}
}
