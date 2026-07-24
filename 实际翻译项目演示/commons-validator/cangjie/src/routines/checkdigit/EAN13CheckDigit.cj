package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class EAN13CheckDigit <: ModulusCheckDigit {
//   static fields/constants:
//     public static let EAN13_CHECK_DIGIT: CheckDigit = EAN13CheckDigit()
//
//   constructors:
//     public init()
//
//   methods:
//     public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64
// }

public class EAN13CheckDigit <: ModulusCheckDigit {
    public static let EAN13_CHECK_DIGIT: CheckDigit = EAN13CheckDigit()
    private static let POSITION_WEIGHT: Array<Int64> = [3, 1]

    public init() {}

    public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64 {
        charValue * POSITION_WEIGHT[rightPos % 2]
    }
}
