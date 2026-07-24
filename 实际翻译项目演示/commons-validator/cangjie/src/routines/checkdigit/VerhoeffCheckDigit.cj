package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class VerhoeffCheckDigit <: AbstractCheckDigit {
//   static fields/constants:
//     public static let VERHOEFF_CHECK_DIGIT: CheckDigit = VerhoeffCheckDigit()
//
//   constructors:
//     public init()
//
//   methods:
//     public override func calculate(code: String): String
//     public override func isValid(code: String): Bool
// }

public class VerhoeffCheckDigit <: AbstractCheckDigit {
    public static let VERHOEFF_CHECK_DIGIT: CheckDigit = VerhoeffCheckDigit()

    private static let D_TABLE: Array<Array<Int64>> = [
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
        [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
        [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
        [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
        [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
        [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
        [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
        [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
        [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
    ]
    private static let P_TABLE: Array<Array<Int64>> = [
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
        [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
        [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
        [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
        [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
        [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
        [7, 0, 4, 6, 9, 1, 3, 2, 5, 8]
    ]
    private static let INV_TABLE: Array<Int64> = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9]

    public init() {}

    private func calculateChecksum(code: String, includesCheckDigit: Bool): Int64 {
        var checksum = 0
        let runes = code.toRuneArray()
        for (i in 0..runes.size) {
            let idx = runes.size - (i + 1)
            let num = checkdigitNumericValue(runes[idx])
            if (num < 0 || num > 9) {
                throw CheckDigitException("Invalid Character[${i}] = '${runes[idx].position()}'")
            }
            let pos = if (includesCheckDigit) { i } else { i + 1 }
            checksum = D_TABLE[checksum][P_TABLE[pos % 8][num]]
        }
        checksum
    }

    public override func calculate(code: String): String {
        if (checkdigitIsBlank(code)) {
            throw CheckDigitException("Code is missing")
        }
        "${INV_TABLE[calculateChecksum(code, false)]}"
    }

    public override func isValid(code: String): Bool {
        if (checkdigitIsBlank(code)) {
            return false
        }
        try {
            calculateChecksum(code, true) == 0
        } catch (e: CheckDigitException) {
            false
        }
    }
}
