package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class DateValidator {
//   static functions:
//     public static func getInstance(): DateValidator
//
//   constructors:
//     protected init()
//
//   methods:
//     public func isValid(value: ?String, locale: ?Locale): Bool
//     public func isValid(value: ?String, locale: Locale): Bool
//     public func isValid(value: ?String, datePattern: ?String, strict: Bool): Bool
//     public func isValid(value: ?String, datePattern: String, strict: Bool): Bool
// }

public class DateValidator {
    private static let DATE_VALIDATOR = DateValidator()

    public static func getInstance(): DateValidator {
        DATE_VALIDATOR
    }

    protected init() {}

    public func isValid(value: ?String, locale: ?Locale): Bool {
        match (GenericTypeValidator.formatDate(value, locale)) {
            case Some(_) => true
            case None => false
        }
    }

    public func isValid(value: ?String, locale: Locale): Bool {
        isValid(value, Some(locale))
    }

    public func isValid(value: ?String, datePattern: ?String, strict: Bool): Bool {
        match (datePattern) {
            case Some(pattern) =>
                if (pattern.isEmpty()) {
                    return false
                }
                match (GenericTypeValidator.formatDate(value, pattern, strict)) {
                    case Some(_) => true
                    case None => false
                }
            case None =>
                false
        }
    }

    public func isValid(value: ?String, datePattern: String, strict: Bool): Bool {
        isValid(value, Some(datePattern), strict)
    }
}
