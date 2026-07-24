package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class IBANCheckDigit <: AbstractCheckDigit {
//   static fields/constants:
//     public static let IBAN_CHECK_DIGIT: CheckDigit = IBANCheckDigit()
//
//   constructors:
//     public init()
//
//   methods:
//     public override func calculate(code: String): String
//     public override func isValid(code: String): Bool
// }

public class IBANCheckDigit <: AbstractCheckDigit {
    public static let IBAN_CHECK_DIGIT: CheckDigit = IBANCheckDigit()

    private static let MIN_CODE_LEN: Int64 = 5
    private static let MAX_ALPHANUMERIC_VALUE: Int64 = 35
    private static let MAX: Int64 = 999999999
    private static let MODULUS: Int64 = 97

    public init() {}

    private func calculateModulus(code: String): Int64 {
        let reformatted = checkdigitSubstring(code, 4) + checkdigitSubstring(code, 0, 4)
        var total = 0
        let runes = reformatted.toRuneArray()
        for (i in 0..runes.size) {
            let charValue = checkdigitNumericValue(runes[i])
            if (charValue < 0 || charValue > MAX_ALPHANUMERIC_VALUE) {
                throw CheckDigitException("Invalid Character[${i}] = '${charValue}'")
            }
            total = (if (charValue > 9) { total * 100 } else { total * 10 }) + charValue
            if (total > MAX) {
                total %= MODULUS
            }
        }
        total % MODULUS
    }

    public override func calculate(code: String): String {
        if (checkdigitLength(code) < MIN_CODE_LEN) {
            throw CheckDigitException("Invalid Code length=${checkdigitLength(code)}")
        }
        let zeroed = checkdigitSubstring(code, 0, 2) + "00" + checkdigitSubstring(code, 4)
        let charValue = 98 - calculateModulus(zeroed)
        if (charValue > 9) {
            return "${charValue}"
        }
        "0${charValue}"
    }

    public override func isValid(code: String): Bool {
        if (checkdigitLength(code) < MIN_CODE_LEN) {
            return false
        }
        let check = checkdigitSubstring(code, 2, 4)
        if (check == "00" || check == "01" || check == "99") {
            return false
        }
        try {
            calculateModulus(code) == 1
        } catch (e: CheckDigitException) {
            false
        }
    }
}
