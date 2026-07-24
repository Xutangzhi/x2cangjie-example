package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class SedolCheckDigit <: ModulusCheckDigit {
//   static fields/constants:
//     public static let SEDOL_CHECK_DIGIT: CheckDigit = SedolCheckDigit()
//
//   constructors:
//     public init()
//
//   methods:
//     public override func calculateModulus(code: String, includesCheckDigit: Bool): Int64
//     public override func toInt(character: Rune, leftPos: Int64, rightPos: Int64): Int64
//     public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64
// }

public class SedolCheckDigit <: ModulusCheckDigit {
    public static let SEDOL_CHECK_DIGIT: CheckDigit = SedolCheckDigit()
    private static let MAX_ALPHANUMERIC_VALUE: Int64 = 35
    private static let POSITION_WEIGHT: Array<Int64> = [1, 3, 1, 7, 3, 9, 1]

    public init() {}

    public override func calculateModulus(code: String, includesCheckDigit: Bool): Int64 {
        if (checkdigitLength(code) > POSITION_WEIGHT.size) {
            throw CheckDigitException("Invalid Code Length = ${checkdigitLength(code)}")
        }
        super.calculateModulus(code, includesCheckDigit)
    }

    public override func toInt(character: Rune, leftPos: Int64, rightPos: Int64): Int64 {
        let charValue = checkdigitNumericValue(character)
        let charMax = if (rightPos == 1) { 9 } else { MAX_ALPHANUMERIC_VALUE }
        if (charValue < 0 || charValue > charMax) {
            throw CheckDigitException("Invalid Character[${leftPos},${rightPos}] = '${charValue}' out of range 0 to ${charMax}")
        }
        charValue
    }

    public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64 {
        charValue * POSITION_WEIGHT[leftPos - 1]
    }
}
