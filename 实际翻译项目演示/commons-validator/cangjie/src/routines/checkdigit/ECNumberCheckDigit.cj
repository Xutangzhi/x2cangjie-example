package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class ECNumberCheckDigit <: ModulusCheckDigit {
//   static fields/constants:
//     public static let EC_REGEX = "^(?:(\\d 3)(?:\\-)(\\d 3)(?:\\-)(\\d))$"
//     public static let REGEX_VALIDATOR: CheckDigitCodeValidator = ECNumberFormatValidator()
//
//   static functions:
//     public static func getInstance(): CheckDigit
//
//   methods:
//     public override func calculate(code: String): String
//     public override func isValid(code: String): Bool
//     public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64
// }

private class ECNumberFormatValidator <: CheckDigitCodeValidator {
    public func validate(input: String): ?String {
        checkdigitNormalizeDashedDigits(input, 3, 3, 3, 1)
    }
}

public class ECNumberCheckDigit <: ModulusCheckDigit {
    public static let EC_REGEX = "^(?:(\\d{3})(?:\\-)(\\d{3})(?:\\-)(\\d))$"
    public static let REGEX_VALIDATOR: CheckDigitCodeValidator = ECNumberFormatValidator()

    private static let INSTANCE: ECNumberCheckDigit = ECNumberCheckDigit()
    private static let EC_LEN: Int64 = 7

    public static func getInstance(): CheckDigit {
        INSTANCE
    }

    private init() {
        super(ModulusCheckDigit.MODULUS_11)
    }

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
        if (leftPos >= EC_LEN) {
            return 0
        }
        charValue * leftPos
    }
}
