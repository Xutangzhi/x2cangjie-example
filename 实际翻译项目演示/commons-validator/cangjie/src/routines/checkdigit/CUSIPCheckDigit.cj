package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class CUSIPCheckDigit <: ModulusCheckDigit {
//   static fields/constants:
//     public static let CUSIP_CHECK_DIGIT: CheckDigit = CUSIPCheckDigit()
//
//   constructors:
//     public init()
//
//   methods:
//     public override func toInt(character: Rune, leftPos: Int64, rightPos: Int64): Int64
//     public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64
// }

public class CUSIPCheckDigit <: ModulusCheckDigit {
    public static let CUSIP_CHECK_DIGIT: CheckDigit = CUSIPCheckDigit()
    private static let POSITION_WEIGHT: Array<Int64> = [2, 1]

    public init() {}

    public override func toInt(character: Rune, leftPos: Int64, rightPos: Int64): Int64 {
        let charValue = checkdigitNumericValue(character)
        let charMax = if (rightPos == 1) { 9 } else { 35 }
        if (charValue < 0 || charValue > charMax) {
            throw CheckDigitException("Invalid Character[${leftPos},${rightPos}] = '${charValue}' out of range 0 to ${charMax}")
        }
        charValue
    }

    public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64 {
        ModulusCheckDigit.sumDigits(charValue * POSITION_WEIGHT[rightPos % 2])
    }
}
