package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class ISBNCheckDigit <: AbstractCheckDigit {
//   static fields/constants:
//     public static let ISBN10_CHECK_DIGIT: CheckDigit = ISBN10CheckDigit.ISBN10_CHECK_DIGIT
//     public static let ISBN13_CHECK_DIGIT: CheckDigit = EAN13CheckDigit.EAN13_CHECK_DIGIT
//     public static let ISBN_CHECK_DIGIT: CheckDigit = ISBNCheckDigit()
//
//   constructors:
//     public init()
//
//   methods:
//     public override func calculate(code: String): String
//     public override func isValid(code: String): Bool
// }

public class ISBNCheckDigit <: AbstractCheckDigit {
    public static let ISBN10_CHECK_DIGIT: CheckDigit = ISBN10CheckDigit.ISBN10_CHECK_DIGIT
    public static let ISBN13_CHECK_DIGIT: CheckDigit = EAN13CheckDigit.EAN13_CHECK_DIGIT
    public static let ISBN_CHECK_DIGIT: CheckDigit = ISBNCheckDigit()

    public init() {}

    public override func calculate(code: String): String {
        if (checkdigitIsBlank(code)) {
            throw CheckDigitException("ISBN Code is missing")
        }
        if (checkdigitLength(code) == 9) {
            return ISBN10_CHECK_DIGIT.calculate(code)
        }
        if (checkdigitLength(code) == 12) {
            return ISBN13_CHECK_DIGIT.calculate(code)
        }
        throw CheckDigitException("Invalid ISBN Length = ${checkdigitLength(code)}")
    }

    public override func isValid(code: String): Bool {
        let length = checkdigitLength(code)
        if (length == 10) {
            return ISBN10_CHECK_DIGIT.isValid(code)
        }
        if (length == 13) {
            return ISBN13_CHECK_DIGIT.isValid(code)
        }
        false
    }
}
