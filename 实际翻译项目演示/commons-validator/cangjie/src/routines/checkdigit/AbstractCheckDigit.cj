package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public interface CheckDigitCodeValidator {
//   methods:
//     func validate(input: String): ?String
// }

// open class AbstractCheckDigit <: CheckDigit {
//   constructors:
//     public init()
//
//   methods:
//     public open func calculate(code: String): String
//     public open func isValid(code: String): Bool
// }

public interface CheckDigitCodeValidator {
    func validate(input: String): ?String
}

private let ASCII_ZERO: Int64 = r'0'.position()
private let ASCII_A: Int64 = r'A'.position()

internal func checkdigitIsBlank(code: String): Bool {
    code.trimAscii().isEmpty()
}

internal func checkdigitLength(code: String): Int64 {
    code.toRuneArray().size
}

internal func checkdigitNumericValue(character: Rune): Int64 {
    if (character.isAsciiNumber()) {
        return character.position() - ASCII_ZERO
    }
    if (character.isAsciiLetter()) {
        return character.toAsciiUpperCase().position() - ASCII_A + 10
    }
    return -1
}

internal func checkdigitSubstring(code: String, start: Int64): String {
    code[start..]
}

internal func checkdigitSubstring(code: String, start: Int64, endExclusive: Int64): String {
    code[start..endExclusive]
}

internal func checkdigitNormalizeDashedDigits(
    input: String,
    group1Min: Int64,
    group1Max: Int64,
    group2Len: Int64,
    group3Len: Int64
): ?String {
    let groups = input.split("-")
    if (groups.size != 3) {
        return None<String>
    }
    if (checkdigitLength(groups[0]) < group1Min || checkdigitLength(groups[0]) > group1Max) {
        return None<String>
    }
    if (checkdigitLength(groups[1]) != group2Len || checkdigitLength(groups[2]) != group3Len) {
        return None<String>
    }
    for (group in groups) {
        for (character in group.toRuneArray()) {
            if (!character.isAsciiNumber()) {
                return None<String>
            }
        }
    }
    return Some(groups[0] + groups[1] + groups[2])
}

open class AbstractCheckDigit <: CheckDigit {
    public init() {}

    public open func calculate(code: String): String {
        throw CheckDigitException("calculate() not implemented")
    }

    public open func isValid(code: String): Bool {
        false
    }
}
