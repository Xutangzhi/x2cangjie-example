package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class ISSNValidator {
//   static functions:
//     public static func getInstance(): ISSNValidator
//
//   constructors:
//     public init()
//
//   methods:
//     public func convertToEAN13(issn: ?String, suffix: ?String): ?String
//     public func extractFromEAN13(ean13: String): ?String
//     public func isValid(code: ?String): Bool
//     public func validate(code: ?String): ?String
//     public func validateEan(code: ?String): ?String
// }

import std.regex.*
import validator.routines.checkdigit.*

public class ISSNValidator {
    private static let ISSN_REGEX = "^(?:ISSN )?(\\d{4})-(\\d{3}[0-9X])$"
    private static let ISSN_LEN: Int64 = 8
    private static let ISSN_PREFIX = "977"
    private static let EAN_ISSN_REGEX = "^(977)(?:(\\d{10}))$"
    private static let EAN_ISSN_LEN: Int64 = 13
    private static let SUFFIX_PATTERN = Regex("^\\d\\d$")
    private static let VALIDATOR = CodeValidator(ISSN_REGEX, ISSN_LEN, Some(ISSNCheckDigit.ISSN_CHECK_DIGIT))
    private static let EAN_VALIDATOR = CodeValidator(EAN_ISSN_REGEX, EAN_ISSN_LEN, Some(EAN13CheckDigit.EAN13_CHECK_DIGIT))
    private static let ISSN_VALIDATOR = ISSNValidator()

    public static func getInstance(): ISSNValidator {
        ISSN_VALIDATOR
    }

    public init() {}

    public func convertToEAN13(issn: ?String, suffix: ?String): ?String {
        var suffixText = ""
        match (suffix) {
            case Some(value) =>
                if (!SUFFIX_PATTERN.matches(value)) {
                    throw IllegalArgumentException("Suffix must be two digits: '${value}'")
                }
                suffixText = value
            case None =>
                throw IllegalArgumentException("Suffix must be two digits: 'null'")
        }
        match (validate(issn)) {
            case Some(value) =>
                var ean13 = ISSN_PREFIX + value[0..value.size - 1] + suffixText
                try {
                    ean13 += EAN13CheckDigit.EAN13_CHECK_DIGIT.calculate(ean13)
                    Some(ean13)
                } catch (e: CheckDigitException) {
                    throw IllegalArgumentException("Check digit error for '${ean13}' - ${e.message}")
                }
            case None =>
                None<String>
        }
    }

    public func extractFromEAN13(ean13: String): ?String {
        var input = ean13.trimAscii()
        if (input.size != EAN_ISSN_LEN) {
            throw IllegalArgumentException("Invalid length ${input.size} for '${input}'")
        }
        if (!input.startsWith(ISSN_PREFIX)) {
            throw IllegalArgumentException("Prefix must be ${ISSN_PREFIX} to contain an ISSN: '${ean13}'")
        }
        match (validateEan(Some(input))) {
            case Some(value) =>
                input = value
                try {
                    let issnBase = input[3..10]
                    let checkDigit = ISSNCheckDigit.ISSN_CHECK_DIGIT.calculate(issnBase)
                    Some(issnBase + checkDigit)
                } catch (e: CheckDigitException) {
                    throw IllegalArgumentException("Check digit error for '${ean13}' - ${e.message}")
                }
            case None =>
                None<String>
        }
    }

    public func isValid(code: ?String): Bool {
        VALIDATOR.isValid(code)
    }

    public func validate(code: ?String): ?String {
        VALIDATOR.validate(code)
    }

    public func validateEan(code: ?String): ?String {
        EAN_VALIDATOR.validate(code)
    }
}
