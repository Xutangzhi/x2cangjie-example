package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class LuhnCheckDigit <: ModulusCheckDigit {
//   static fields/constants:
//     public static let LUHN_CHECK_DIGIT: CheckDigit = LuhnCheckDigit()
//
//   constructors:
//     public init()
//
//   methods:
//     public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64
// }

public class LuhnCheckDigit <: ModulusCheckDigit {
    public static let LUHN_CHECK_DIGIT: CheckDigit = LuhnCheckDigit()
    private static let POSITION_WEIGHT: Array<Int64> = [2, 1]

    public init() {}

    public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64 {
        let weighted = charValue * POSITION_WEIGHT[rightPos % 2]
        if (weighted > 9) {
            return weighted - 9
        }
        weighted
    }
}
