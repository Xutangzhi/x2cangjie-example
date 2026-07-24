package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class ISSNCheckDigit <: ModulusCheckDigit {
//   static fields/constants:
//     public static let ISSN_CHECK_DIGIT: CheckDigit = ISSNCheckDigit()
//
//   constructors:
//     public init()
//
//   methods:
//     public override func toCheckDigit(charValue: Int64): String
//     public override func toInt(character: Rune, leftPos: Int64, rightPos: Int64): Int64
//     public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64
// }

public class ISSNCheckDigit <: ModulusCheckDigit {
    public static let ISSN_CHECK_DIGIT: CheckDigit = ISSNCheckDigit()

    public init() {
        super(ModulusCheckDigit.MODULUS_11)
    }

    public override func toCheckDigit(charValue: Int64): String {
        if (charValue == 10) {
            return "X"
        }
        super.toCheckDigit(charValue)
    }

    public override func toInt(character: Rune, leftPos: Int64, rightPos: Int64): Int64 {
        if (rightPos == 1 && character == r'X') {
            return 10
        }
        super.toInt(character, leftPos, rightPos)
    }

    public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64 {
        charValue * (9 - leftPos)
    }
}
