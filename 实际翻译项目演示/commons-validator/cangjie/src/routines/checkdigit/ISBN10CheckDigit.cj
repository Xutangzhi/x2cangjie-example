package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class ISBN10CheckDigit <: ModulusCheckDigit {
//   static fields/constants:
//     public static let ISBN10_CHECK_DIGIT: CheckDigit = ISBN10CheckDigit()
//
//   constructors:
//     public init()
//
//   methods:
//     public override func toCheckDigit(charValue: Int64): String
//     public override func toInt(character: Rune, leftPos: Int64, rightPos: Int64): Int64
//     public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64
// }

public class ISBN10CheckDigit <: ModulusCheckDigit {
    public static let ISBN10_CHECK_DIGIT: CheckDigit = ISBN10CheckDigit()

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
        charValue * rightPos
    }
}
