package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class ISBNValidator {
//   static fields/constants:
//     public static let ISBN10_REGEX = "^(?:(\\d 9 [0-9X])|(?:(\\d 1,5)(?:\\-|\\s)(\\d 1,7)(?:\\-|\\s)(\\d 1,6)(?:\\-|\\s)([0-9X])))$"
//     public static let ISBN13_REGEX = "^(978|979)(?:(\\d 10)|(?:(?:\\-|\\s)(\\d 1,5)(?:\\-|\\s)(\\d 1,7)(?:\\-|\\s)(\\d 1,6)(?:\\-|\\s)([0-9])))$"
//
//   static functions:
//     public static func getInstance(): ISBNValidator
//     public static func getInstance(convert: Bool): ISBNValidator
//
//   constructors:
//     public init()
//     public init(convert: Bool)
//
//   methods:
//     public func convertToISBN13(isbn10: ?String): ?String
//     public func isValid(code: ?String): Bool
//     public func isValidISBN10(code: ?String): Bool
//     public func isValidISBN13(code: ?String): Bool
//     public func validate(code: ?String): ?String
//     public func validateISBN10(code: ?String): ?String
//     public func validateISBN13(code: ?String): ?String
// }

import validator.routines.checkdigit.*

public class ISBNValidator {
    public static let ISBN10_REGEX =
        "^(?:(\\d{9}[0-9X])|(?:(\\d{1,5})(?:\\-|\\s)(\\d{1,7})(?:\\-|\\s)(\\d{1,6})(?:\\-|\\s)([0-9X])))$"
    public static let ISBN13_REGEX =
        "^(978|979)(?:(\\d{10})|(?:(?:\\-|\\s)(\\d{1,5})(?:\\-|\\s)(\\d{1,7})(?:\\-|\\s)(\\d{1,6})(?:\\-|\\s)([0-9])))$"

    private static let ISBN_10_LEN: Int64 = 10
    private static let ISBN_VALIDATOR = ISBNValidator()
    private static let ISBN_VALIDATOR_NO_CONVERT = ISBNValidator(false)

    private let isbn10Validator = CodeValidator(ISBN10_REGEX, 10, Some(ISBN10CheckDigit.ISBN10_CHECK_DIGIT))
    private let isbn13Validator = CodeValidator(ISBN13_REGEX, 13, Some(EAN13CheckDigit.EAN13_CHECK_DIGIT))
    private let convert: Bool

    public static func getInstance(): ISBNValidator {
        ISBN_VALIDATOR
    }

    public static func getInstance(convert: Bool): ISBNValidator {
        if (convert) {
            return ISBN_VALIDATOR
        }
        ISBN_VALIDATOR_NO_CONVERT
    }

    public init() {
        this(true)
    }

    public init(convert: Bool) {
        this.convert = convert
    }

    public func convertToISBN13(isbn10: ?String): ?String {
        match (isbn10) {
            case Some(value) =>
                let input = value.trimAscii()
                if (input.size != ISBN_10_LEN) {
                    throw IllegalArgumentException("Invalid length ${input.size} for '${input}'")
                }
                var isbn13 = "978" + input[0..ISBN_10_LEN - 1]
                try {
                    isbn13 += EAN13CheckDigit.EAN13_CHECK_DIGIT.calculate(isbn13)
                    return Some(isbn13)
                } catch (e: CheckDigitException) {
                    throw IllegalArgumentException("Check digit error for '${input}' - ${e.message}")
                }
            case None =>
                None<String>
        }
    }

    public func isValid(code: ?String): Bool {
        isValidISBN13(code) || isValidISBN10(code)
    }

    public func isValidISBN10(code: ?String): Bool {
        isbn10Validator.isValid(code)
    }

    public func isValidISBN13(code: ?String): Bool {
        isbn13Validator.isValid(code)
    }

    public func validate(code: ?String): ?String {
        match (validateISBN13(code)) {
            case Some(value) => Some(value)
            case None =>
                match (validateISBN10(code)) {
                    case Some(value) =>
                        if (convert) {
                            return convertToISBN13(Some(value))
                        }
                        Some(value)
                    case None =>
                        None<String>
                }
        }
    }

    public func validateISBN10(code: ?String): ?String {
        isbn10Validator.validate(code)
    }

    public func validateISBN13(code: ?String): ?String {
        isbn13Validator.validate(code)
    }
}
