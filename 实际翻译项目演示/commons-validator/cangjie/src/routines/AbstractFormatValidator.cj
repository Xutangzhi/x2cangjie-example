package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class Locale {
//   static fields/constants:
//     public static let US = Locale("en", "US", "", r'.', r',', r'%')
//     public static let UK = Locale("en", "GB", "", r'.', r',', r'%')
//     public static let GERMAN = Locale("de", "DE", "", r',', r'.', r'%')
//     public static let GERMANY = Locale("de", "DE", "", r',', r'.', r'%')
//     public static let FRENCH = Locale("fr", "", "", r',', r' ', r'%')
//
//   fields/properties:
//     public let language: String
//     public let country: String
//     public let variant: String
//     public let decimalSeparator: Rune
//     public let groupingSeparator: Rune
//     public let percentSymbol: Rune
//
//   static functions:
//     public static func getDefault(): Locale
//     public static func setDefault(locale: Locale): Unit
//
//   constructors:
//     public init(language: String, country: String)
//     public init(language: String, country: String, variant: String)
//
//   operator methods:
//     public operator func ==(right: Locale): Bool
//     public operator func !=(right: Locale): Bool
//
//   methods:
//     public func toString(): String
// }

// public abstract class AbstractFormatValidator {
//   constructors:
//     public init(strict: Bool)
//
//   methods:
//     public func format(value: Any): String
//     public func format(value: Any, locale: Locale): String
//     public func format(value: Any, pattern: String): String
//     public func format(value: Any, pattern: String, locale: Locale): String
//     protected func format(value: Any, formatter: ValidatorNumberFormat): String
//     public func isStrict(): Bool
//     public func isValid(value: ?String): Bool
//     public func isValid(value: ?String, locale: Locale): Bool
//     public func isValid(value: ?String, pattern: String): Bool
//     protected open func parse(value: String, formatter: ValidatorNumberFormat): ?Any
//     protected func getFormat(pattern: ?String, locale: ?Locale): ValidatorNumberFormat
//     public func isValid(value: ?String, pattern: ?String, locale: ?Locale): Bool
//     protected func processParsedValue(value: ValidatorRawNumber, formatter: ValidatorNumberFormat): ?Any
// }

public open class AbstractFormatValidator {
    private let strict: Bool

    public init(strict: Bool) {
        this.strict = strict
    }

    public func format(value: Any): String {
        format(value, None<String>, None<Locale>)
    }

    public func format(value: Any, locale: Locale): String {
        format(value, None<String>, Some(locale))
    }

    public func format(value: Any, pattern: String): String {
        format(value, Some(pattern), None<Locale>)
    }

    public func format(value: Any, pattern: String, locale: Locale): String {
        format(value, Some(pattern), Some(locale))
    }

    protected func format(value: Any, formatter: ValidatorNumberFormat): String {
        formatter.format(value)
    }

    private func format(value: Any, pattern: ?String, locale: ?Locale): String {
        format(value, getFormat(pattern, locale))
    }

    public func isStrict(): Bool {
        strict
    }

    public func isValid(value: ?String): Bool {
        isValid(value, None<String>, None<Locale>)
    }

    public func isValid(value: ?String, locale: Locale): Bool {
        isValid(value, None<String>, Some(locale))
    }

    public func isValid(value: ?String, pattern: String): Bool {
        isValid(value, Some(pattern), None<Locale>)
    }

    public open func isValid(value: ?String, pattern: ?String, locale: ?Locale): Bool {
        match (value) {
            case Some(text) =>
                match (parse(text, getFormat(pattern, locale))) {
                    case Some(_) => true
                    case None => false
                }
            case None =>
                false
        }
    }

    protected open func parse(value: String, formatter: ValidatorNumberFormat): ?Any {
        match (formatter.parse(value, strict)) {
            case Some(parsedValue) =>
                processParsedValue(parsedValue, formatter)
            case None =>
                None<Any>
        }
    }

    protected open func getFormat(pattern: ?String, locale: ?Locale): ValidatorNumberFormat {
        throw IllegalStateException("getFormat() not implemented")
    }

    protected open func processParsedValue(value: ValidatorRawNumber, formatter: ValidatorNumberFormat): ?Any {
        Some(value)
    }
}
