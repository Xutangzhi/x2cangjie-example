package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class ISINCheckDigit <: ModulusCheckDigit {
//   static fields/constants:
//     public static let ISIN_CHECK_DIGIT: CheckDigit = ISINCheckDigit()
//
//   constructors:
//     public init()
//
//   methods:
//     public override func calculateModulus(code: String, includesCheckDigit: Bool): Int64
//     public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64
// }

public class ISINCheckDigit <: ModulusCheckDigit {
    public static let ISIN_CHECK_DIGIT: CheckDigit = ISINCheckDigit()
    private static let MAX_ALPHANUMERIC_VALUE: Int64 = 35
    private static let POSITION_WEIGHT: Array<Int64> = [2, 1]

    public init() {}

    public override func calculateModulus(code: String, includesCheckDigit: Bool): Int64 {
        var transformed = ""
        if (includesCheckDigit) {
            let checkDigit = checkdigitCharAt(code, checkdigitLength(code) - 1)
            if (!checkDigit.isAsciiNumber()) {
                throw CheckDigitException("Invalid checkdigit[${checkDigit}] in ${code}")
            }
        }
        let runes = code.toRuneArray()
        for (i in 0..runes.size) {
            let charValue = checkdigitNumericValue(runes[i])
            if (charValue < 0 || charValue > MAX_ALPHANUMERIC_VALUE) {
                throw CheckDigitException("Invalid Character[${i + 1}] = '${charValue}'")
            }
            transformed += "${charValue}"
        }
        super.calculateModulus(transformed, includesCheckDigit)
    }

    public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64 {
        ModulusCheckDigit.sumDigits(charValue * POSITION_WEIGHT[rightPos % 2])
    }
}
