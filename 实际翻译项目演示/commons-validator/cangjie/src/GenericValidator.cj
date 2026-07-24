package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// top-level fields/constants:
//   let chars = ArrayList<Rune>()
//   let labels = genericValidator__splitByRune(text, r'.')
//   let tld = labels[labels.size - 1]

// top-level functions:
//   public func validatorCharLength(text: String): Int64
//   public func validatorSubstring(text: String, startPos: Int64, endPos: Int64): String
//   public func validatorSubstringFrom(text: String, startPos: Int64): String
//   public func validatorTrimWhitespace(text: String): String
//   public func validatorNumericValue(ch: Rune): Int64
//   public func validatorIsDigit(ch: Rune): Bool
//   public func validatorArrayContains(values: Array<String>, target: String): Bool
//   public init()
//   public static func isBlankOrNull(value: ?String): Bool
//   public static func isBlankOrNull(value: String): Bool
//   public static func isByte(value: ?String): Bool
//   public static func isShort(value: ?String): Bool
//   public static func isInt(value: ?String): Bool
//   public static func isLong(value: ?String): Bool
//   public static func isFloat(value: ?String): Bool
//   public static func isDouble(value: ?String): Bool
//   public static func isEmail(value: ?String): Bool
//   public static func isDate(value: ?String, locale: ?Locale): Bool
//   public static func isDate(value: ?String, locale: Locale): Bool
//   public static func isDate(value: ?String, datePattern: ?String, strict: Bool): Bool
//   public static func isDate(value: ?String, datePattern: String, strict: Bool): Bool
//   public static func isInRange(value: Int8, min: Int8, max: Int8): Bool
//   public static func isInRange(value: Float64, min: Float64, max: Float64): Bool
//   public static func isInRange(value: Float32, min: Float32, max: Float32): Bool
//   public static func isInRange(value: Int32, min: Int32, max: Int32): Bool
//   public static func isInRange(value: Int64, min: Int64, max: Int64): Bool
//   public static func isInRange(value: Int16, min: Int16, max: Int16): Bool
//   public static func isUrl(value: ?String): Bool
//   public static func matchRegexp(value: ?String, regexp: ?String): Bool
//   public static func maxLength(value: String, max: Int64): Bool
//   public static func maxLength(value: String, max: Int64, lineEndLength: Int64): Bool
//   public static func minLength(value: String, min: Int64): Bool
//   public static func minLength(value: String, min: Int64, lineEndLength: Int64): Bool
//   public static func maxValue(value: Float64, max: Float64): Bool
//   public static func maxValue(value: Float32, max: Float32): Bool
//   public static func maxValue(value: Int32, max: Int32): Bool
//   public static func maxValue(value: Int64, max: Int64): Bool
//   public static func minValue(value: Float64, min: Float64): Bool
//   public static func minValue(value: Float32, min: Float32): Bool
//   public static func minValue(value: Int32, min: Int32): Bool
//   public static func minValue(value: Int64, min: Int64): Bool
//   public static func isCreditCard(value: ?String): Bool

import std.regex.*

public func validatorCharLength(text: String): Int64 {
    text.toRuneArray().size
}

public func validatorSubstring(text: String, startPos: Int64, endPos: Int64): String {
    let chars = text.toRuneArray()
    var out = ""
    for (i in startPos..endPos) {
        out += chars[i].toString()
    }
    out
}

public func validatorSubstringFrom(text: String, startPos: Int64): String {
    validatorSubstring(text, startPos, text.toRuneArray().size)
}

public func validatorTrimWhitespace(text: String): String {
    text.trimAscii()
}

public func validatorNumericValue(ch: Rune): Int64 {
    ch.position() - r'0'.position()
}

public func validatorIsDigit(ch: Rune): Bool {
    ch.isAsciiNumber()
}

public func validatorArrayContains(values: Array<String>, target: String): Bool {
    for (value in values) {
        if (value == target) {
            return true
        }
    }
    false
}

private func genericValidatorAdjustForLineEnding(value: String, lineEndLength: Int64): Int64 {
    var nCount = 0
    var rCount = 0
    for (ch in value.toRuneArray()) {
        if (ch == r'\n') {
            nCount++
        }
        if (ch == r'\r') {
            rCount++
        }
    }
    nCount * lineEndLength - (nCount + rCount)
}

public class GenericValidator {
    public static func isBlankOrNull(value: ?String): Bool {
        match (value) {
            case Some(text) => text.isEmpty() || text.trimAscii().isEmpty()
            case None => true
        }
    }

    public static func isBlankOrNull(value: String): Bool {
        value.isEmpty() || value.trimAscii().isEmpty()
    }

    public static func isByte(value: ?String): Bool {
        match (GenericTypeValidator.formatByte(value)) {
            case Some(_) => true
            case None => false
        }
    }

    public static func isShort(value: ?String): Bool {
        match (GenericTypeValidator.formatShort(value)) {
            case Some(_) => true
            case None => false
        }
    }

    public static func isInt(value: ?String): Bool {
        match (GenericTypeValidator.formatInt(value)) {
            case Some(_) => true
            case None => false
        }
    }

    public static func isLong(value: ?String): Bool {
        match (GenericTypeValidator.formatLong(value)) {
            case Some(_) => true
            case None => false
        }
    }

    public static func isFloat(value: ?String): Bool {
        match (GenericTypeValidator.formatFloat(value)) {
            case Some(_) => true
            case None => false
        }
    }

    public static func isDouble(value: ?String): Bool {
        match (GenericTypeValidator.formatDouble(value)) {
            case Some(_) => true
            case None => false
        }
    }

    public static func isEmail(value: ?String): Bool {
        EmailValidator.getInstance().isValid(value)
    }

    public static func isDate(value: ?String, locale: ?Locale): Bool {
        DateValidator.getInstance().isValid(value, locale)
    }

    public static func isDate(value: ?String, locale: Locale): Bool {
        isDate(value, Some(locale))
    }

    public static func isDate(value: ?String, datePattern: ?String, strict: Bool): Bool {
        DateValidator.getInstance().isValid(value, datePattern, strict)
    }

    public static func isDate(value: ?String, datePattern: String, strict: Bool): Bool {
        DateValidator.getInstance().isValid(value, datePattern, strict)
    }

    public static func isInRange(value: Int8, min: Int8, max: Int8): Bool {
        value >= min && value <= max
    }

    public static func isInRange(value: Float64, min: Float64, max: Float64): Bool {
        value >= min && value <= max
    }

    public static func isInRange(value: Float32, min: Float32, max: Float32): Bool {
        value >= min && value <= max
    }

    public static func isInRange(value: Int32, min: Int32, max: Int32): Bool {
        value >= min && value <= max
    }

    public static func isInRange(value: Int64, min: Int64, max: Int64): Bool {
        value >= min && value <= max
    }

    public static func isInRange(value: Int16, min: Int16, max: Int16): Bool {
        value >= min && value <= max
    }

    public static func isUrl(value: ?String): Bool {
        UrlValidator().isValid(value)
    }

    public static func matchRegexp(value: ?String, regexp: ?String): Bool {
        match (regexp) {
            case Some(pattern) =>
                if (pattern.isEmpty()) {
                    return false
                }
                match (value) {
                    case Some(text) => Regex(pattern).matches(text)
                    case None => false
                }
            case None =>
                false
        }
    }

    public static func maxLength(value: String, max: Int64): Bool {
        validatorCharLength(value) <= max
    }

    public static func maxLength(value: String, max: Int64, lineEndLength: Int64): Bool {
        validatorCharLength(value) + genericValidatorAdjustForLineEnding(value, lineEndLength) <= max
    }

    public static func minLength(value: String, min: Int64): Bool {
        validatorCharLength(value) >= min
    }

    public static func minLength(value: String, min: Int64, lineEndLength: Int64): Bool {
        validatorCharLength(value) + genericValidatorAdjustForLineEnding(value, lineEndLength) >= min
    }

    public static func maxValue(value: Float64, max: Float64): Bool {
        value <= max
    }

    public static func maxValue(value: Float32, max: Float32): Bool {
        value <= max
    }

    public static func maxValue(value: Int32, max: Int32): Bool {
        value <= max
    }

    public static func maxValue(value: Int64, max: Int64): Bool {
        value <= max
    }

    public static func minValue(value: Float64, min: Float64): Bool {
        value >= min
    }

    public static func minValue(value: Float32, min: Float32): Bool {
        value >= min
    }

    public static func minValue(value: Int32, min: Int32): Bool {
        value >= min
    }

    public static func minValue(value: Int64, min: Int64): Bool {
        value >= min
    }

    public static func isCreditCard(value: ?String): Bool {
        match (GenericTypeValidator.formatCreditCard(value)) {
            case Some(_) => true
            case None => false
        }
    }

    public init() {}
}
