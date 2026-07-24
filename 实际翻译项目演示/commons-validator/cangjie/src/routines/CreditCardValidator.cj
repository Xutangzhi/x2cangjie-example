package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class CreditCardRange {
//   fields/properties:
//     public let low: String
//     public let high: ?String
//     public let minLen: Int64
//     public let maxLen: Int64
//     public let lengths: ?Array<Int64>
//
//   constructors:
//     public init(low: String, high: ?String, minLen: Int64, maxLen: Int64)
//     public init(low: String, high: ?String, lengths: Array<Int64>)
// }

// public class CreditCardValidator {
//   static fields/constants:
//     public static let NONE: Int64 = 0
//     public static let AMEX: Int64 = 1
//     public static let VISA: Int64 = 2
//     public static let MASTERCARD: Int64 = 4
//     public static let DISCOVER: Int64 = 8
//     public static let DINERS: Int64 = 16
//     public static let VPAY: Int64 = 32
//     public static let MASTERCARD_PRE_OCT2016: Int64 = 64
//     public static let AMEX_VALIDATOR = CodeValidator("^(3[47]\\d 13)$", LUHN_VALIDATOR)
//     public static let DINERS_VALIDATOR = CodeValidator("^(30[0-5]\\d 11 |3095\\d 10 |36\\d 12 |3[8-9]\\d 12)$", LUHN_VALIDATOR)
//     public static let DISCOVER_VALIDATOR = CodeValidator(DISCOVER_REGEX, LUHN_VALIDATOR)
//     public static let MASTERCARD_VALIDATOR = CodeValidator(MASTERCARD_REGEX, LUHN_VALIDATOR)
//     public static let MASTERCARD_VALIDATOR_PRE_OCT2016 = CodeValidator("^(5[1-5]\\d 14)$", LUHN_VALIDATOR)
//     public static let VISA_VALIDATOR = CodeValidator("^(4)(\\d 12 |\\d 15)$", LUHN_VALIDATOR)
//     public static let VPAY_VALIDATOR = CodeValidator("^(4)(\\d 12,18)$", LUHN_VALIDATOR)
//
//   static functions:
//     public static func createRangeValidator(creditCardRanges: Array<CreditCardRange>, digitCheck: ?CheckDigit): CodeValidator
//     public static func genericCreditCardValidator(): CreditCardValidator
//     public static func genericCreditCardValidator(length: Int64): CreditCardValidator
//     public static func genericCreditCardValidator(minLen: Int64, maxLen: Int64): CreditCardValidator
//     public static func validLength(valueLength: Int64, range: CreditCardRange): Bool
//
//   constructors:
//     public init()
//     public init(creditCardValidators: ?Array<CodeValidator>)
//     public init(creditCardValidators: ?Array<CodeValidator>, creditCardRanges: ?Array<CreditCardRange>)
//     public init(creditCardRanges: Array<CreditCardRange>)
//     public init(options: Int64)
//
//   methods:
//     public func isValid(card: ?String): Bool
//     public func validate(card: ?String): ?String
// }

import std.collection.*
import validator.routines.checkdigit.*

private func creditCardBlankOrNull(value: ?String): Bool {
    match (value) {
        case Some(text) => text.trimAscii().isEmpty()
        case None => true
    }
}

private func creditCardIsDigits(value: String): Bool {
    if (value.isEmpty()) {
        return false
    }
    for (character in value.toRuneArray()) {
        if (!character.isAsciiNumber()) {
            return false
        }
    }
    true
}

private class RangeCodeValidator <: CodeValidator {
    private let creditCardRanges: Array<CreditCardRange>

    init(creditCardRanges: Array<CreditCardRange>, digitCheck: ?CheckDigit) {
        super("(\\d+)", digitCheck)
        this.creditCardRanges = creditCardRanges.clone()
    }

    private func matchesRange(value: String): Bool {
        let length = value.size
        for (range in creditCardRanges) {
            if (CreditCardValidator.validLength(length, range)) {
                match (range.high) {
                    case Some(highValue) =>
                        if (range.low <= value && highValue >= value[0..highValue.size]) {
                            return true
                        }
                    case None =>
                        if (value.startsWith(range.low)) {
                            return true
                        }
                }
            }
        }
        false
    }

    public override func isValid(input: ?String): Bool {
        match (validate(input)) {
            case Some(_) => true
            case None => false
        }
    }

    public override func validate(input: ?String): ?String {
        match (input) {
            case Some(raw) =>
                let value = raw.trimAscii()
                if (!creditCardIsDigits(value) || !matchesRange(value)) {
                    return None<String>
                }
                match (getCheckDigit()) {
                    case Some(validator) =>
                        if (!validator.isValid(value)) {
                            return None<String>
                        }
                    case None => ()
                }
                Some(value)
            case None =>
                None<String>
        }
    }
}

public class CreditCardRange {
    public let low: String
    public let high: ?String
    public let minLen: Int64
    public let maxLen: Int64
    public let lengths: ?Array<Int64>

    public init(low: String, high: ?String, minLen: Int64, maxLen: Int64) {
        this.low = low
        this.high = high
        this.minLen = minLen
        this.maxLen = maxLen
        this.lengths = None<Array<Int64>>
    }

    public init(low: String, high: ?String, lengths: Array<Int64>) {
        this.low = low
        this.high = high
        this.minLen = -1
        this.maxLen = -1
        this.lengths = Some(lengths.clone())
    }
}

public class CreditCardValidator {
    private static let MIN_CC_LENGTH: Int64 = 12
    private static let MAX_CC_LENGTH: Int64 = 19
    public static let NONE: Int64 = 0
    public static let AMEX: Int64 = 1
    public static let VISA: Int64 = 2
    public static let MASTERCARD: Int64 = 4
    public static let DISCOVER: Int64 = 8
    public static let DINERS: Int64 = 16
    public static let VPAY: Int64 = 32
    public static let MASTERCARD_PRE_OCT2016: Int64 = 64

    private static let LUHN_VALIDATOR: CheckDigit = LuhnCheckDigit.LUHN_CHECK_DIGIT
    public static let AMEX_VALIDATOR = CodeValidator("^(3[47]\\d{13})$", Some(LUHN_VALIDATOR))
    public static let DINERS_VALIDATOR = CodeValidator("^(30[0-5]\\d{11}|3095\\d{10}|36\\d{12}|3[8-9]\\d{12})$", Some(LUHN_VALIDATOR))
    private static let DISCOVER_REGEX = RegexValidator(Some([
        "^(6011\\d{12,13})$",
        "^(64[4-9]\\d{13})$",
        "^(65\\d{14})$",
        "^(62[2-8]\\d{13})$"
    ]))
    public static let DISCOVER_VALIDATOR = CodeValidator(DISCOVER_REGEX, Some(LUHN_VALIDATOR))
    private static let MASTERCARD_REGEX = RegexValidator(Some([
        "^(5[1-5]\\d{14})$",
        "^(2221\\d{12})$",
        "^(222[2-9]\\d{12})$",
        "^(22[3-9]\\d{13})$",
        "^(2[3-6]\\d{14})$",
        "^(27[01]\\d{13})$",
        "^(2720\\d{12})$"
    ]))
    public static let MASTERCARD_VALIDATOR = CodeValidator(MASTERCARD_REGEX, Some(LUHN_VALIDATOR))
    public static let MASTERCARD_VALIDATOR_PRE_OCT2016 = CodeValidator("^(5[1-5]\\d{14})$", Some(LUHN_VALIDATOR))
    public static let VISA_VALIDATOR = CodeValidator("^(4)(\\d{12}|\\d{15})$", Some(LUHN_VALIDATOR))
    public static let VPAY_VALIDATOR = CodeValidator("^(4)(\\d{12,18})$", Some(LUHN_VALIDATOR))

    private let cardTypes: ArrayList<CodeValidator> = ArrayList<CodeValidator>()

    public static func createRangeValidator(creditCardRanges: Array<CreditCardRange>, digitCheck: ?CheckDigit): CodeValidator {
        RangeCodeValidator(creditCardRanges, digitCheck)
    }

    public static func genericCreditCardValidator(): CreditCardValidator {
        genericCreditCardValidator(MIN_CC_LENGTH, MAX_CC_LENGTH)
    }

    public static func genericCreditCardValidator(length: Int64): CreditCardValidator {
        genericCreditCardValidator(length, length)
    }

    public static func genericCreditCardValidator(minLen: Int64, maxLen: Int64): CreditCardValidator {
        CreditCardValidator([CodeValidator("(\\d+)", minLen, maxLen, Some(LUHN_VALIDATOR))])
    }

    public static func validLength(valueLength: Int64, range: CreditCardRange): Bool {
        match (range.lengths) {
            case Some(lengths) =>
                for (length in lengths) {
                    if (valueLength == length) {
                        return true
                    }
                }
                false
            case None =>
                valueLength >= range.minLen && valueLength <= range.maxLen
        }
    }

    private static func isOn(options: Int64, flag: Int64): Bool {
        (options & flag) > 0
    }

    public init() {
        this(AMEX + VISA + MASTERCARD + DISCOVER)
    }

    public init(creditCardValidators: ?Array<CodeValidator>) {
        match (creditCardValidators) {
            case Some(validators) =>
                for (validator in validators) {
                    cardTypes.add(validator)
                }
            case None =>
                throw IllegalArgumentException("Card validators are missing")
        }
    }

    public init(creditCardValidators: ?Array<CodeValidator>, creditCardRanges: ?Array<CreditCardRange>) {
        match (creditCardValidators) {
            case Some(validators) =>
                for (validator in validators) {
                    cardTypes.add(validator)
                }
            case None =>
                throw IllegalArgumentException("Card validators are missing")
        }
        match (creditCardRanges) {
            case Some(ranges) =>
                cardTypes.add(createRangeValidator(ranges, Some(LUHN_VALIDATOR)))
            case None =>
                throw IllegalArgumentException("Card ranges are missing")
        }
    }

    public init(creditCardRanges: Array<CreditCardRange>) {
        cardTypes.add(createRangeValidator(creditCardRanges, Some(LUHN_VALIDATOR)))
    }

    public init(options: Int64) {
        if (isOn(options, VISA)) {
            cardTypes.add(VISA_VALIDATOR)
        }
        if (isOn(options, VPAY)) {
            cardTypes.add(VPAY_VALIDATOR)
        }
        if (isOn(options, AMEX)) {
            cardTypes.add(AMEX_VALIDATOR)
        }
        if (isOn(options, MASTERCARD)) {
            cardTypes.add(MASTERCARD_VALIDATOR)
        }
        if (isOn(options, MASTERCARD_PRE_OCT2016)) {
            cardTypes.add(MASTERCARD_VALIDATOR_PRE_OCT2016)
        }
        if (isOn(options, DISCOVER)) {
            cardTypes.add(DISCOVER_VALIDATOR)
        }
        if (isOn(options, DINERS)) {
            cardTypes.add(DINERS_VALIDATOR)
        }
    }

    public func isValid(card: ?String): Bool {
        if (creditCardBlankOrNull(card)) {
            return false
        }
        for (cardType in cardTypes) {
            if (cardType.isValid(card)) {
                return true
            }
        }
        false
    }

    public func validate(card: ?String): ?String {
        if (creditCardBlankOrNull(card)) {
            return None<String>
        }
        for (cardType in cardTypes) {
            match (cardType.validate(card)) {
                case Some(value) => return Some(value)
                case None => ()
            }
        }
        None<String>
    }
}
