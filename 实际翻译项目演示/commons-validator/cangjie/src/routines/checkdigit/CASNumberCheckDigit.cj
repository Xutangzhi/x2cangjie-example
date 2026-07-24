package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class CASNumberCheckDigit <: ModulusCheckDigit {
//   static fields/constants:
//     public static let CAS_REGEX = "^(?:(\\d 2,7)(?:\\-)(\\d 2)(?:\\-)(\\d))$"
//     public static let REGEX_VALIDATOR: CheckDigitCodeValidator = CASNumberFormatValidator()
//
//   static functions:
//     public static func getInstance(): CheckDigit
//
//   methods:
//     public override func calculate(code: String): String
//     public override func isValid(code: String): Bool
//     public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64
// }

private class CASNumberFormatValidator <: CheckDigitCodeValidator {
    public func validate(input: String): ?String {
        checkdigitNormalizeDashedDigits(input, 2, 7, 2, 1)
    }
}

public class CASNumberCheckDigit <: ModulusCheckDigit {
    public static let CAS_REGEX = "^(?:(\\d{2,7})(?:\\-)(\\d{2})(?:\\-)(\\d))$"
    public static let REGEX_VALIDATOR: CheckDigitCodeValidator = CASNumberFormatValidator()

    private static let INSTANCE: CASNumberCheckDigit = CASNumberCheckDigit()
    private static let POSITION_WEIGHT: Array<Int64> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

    public static func getInstance(): CheckDigit {
        INSTANCE
    }

    private init() {}

    public override func calculate(code: String): String {
        if (checkdigitIsBlank(code)) {
            throw CheckDigitException("Code is missing")
        }
        toCheckDigit(INSTANCE.calculateModulus(code, false))
    }

    public override func isValid(code: String): Bool {
        if (checkdigitIsBlank(code)) {
            return false
        }
        let normalized = REGEX_VALIDATOR.validate(code)
        if (let Some(value) <- normalized) {
            try {
                return INSTANCE.calculateModulus(value, true) ==
                    (checkdigitCharAt(code, checkdigitLength(code) - 1).position() - r'0'.position())
            } catch (e: CheckDigitException) {
                return false
            }
        }
        false
    }

    public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64 {
        charValue * POSITION_WEIGHT[(rightPos - 1) % ModulusCheckDigit.MODULUS_10]
    }
}
