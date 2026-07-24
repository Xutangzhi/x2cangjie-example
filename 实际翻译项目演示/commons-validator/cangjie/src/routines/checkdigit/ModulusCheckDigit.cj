package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public open class ModulusCheckDigit <: AbstractCheckDigit {
//   static fields/constants:
//     public static let MODULUS_10: Int64 = 10
//     public static let MODULUS_11: Int64 = 11
//
//   static functions:
//     public static func sumDigits(number: Int64): Int64
//
//   constructors:
//     public init()
//     public init(modulus: Int64)
//
//   methods:
//     public func getModulus(): Int64
//     public open override func calculate(code: String): String
//     public open func calculateModulus(code: String, includesCheckDigit: Bool): Int64
//     public open override func isValid(code: String): Bool
//     public open func toCheckDigit(charValue: Int64): String
//     public open func toInt(character: Rune, leftPos: Int64, rightPos: Int64): Int64
//     public open func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64
// }

// top-level functions:
//   public func checkdigitCharAt(text: String, index: Int64): Rune

public func checkdigitCharAt(text: String, index: Int64): Rune {
    text.toRuneArray()[index]
}

public open class ModulusCheckDigit <: AbstractCheckDigit {
    public static let MODULUS_10: Int64 = 10
    public static let MODULUS_11: Int64 = 11

    private let modulus: Int64

    public static func sumDigits(number: Int64): Int64 {
        var total = 0
        var todo = number
        while (todo > 0) {
            total += todo % 10
            todo /= 10
        }
        total
    }

    public init() {
        modulus = MODULUS_10
    }

    public init(modulus: Int64) {
        this.modulus = modulus
    }

    public func getModulus(): Int64 {
        modulus
    }

    public open override func calculate(code: String): String {
        if (checkdigitIsBlank(code)) {
            throw CheckDigitException("Code is missing")
        }
        let modulusResult = calculateModulus(code, false)
        let charValue = (modulus - modulusResult) % modulus
        toCheckDigit(charValue)
    }

    public open func calculateModulus(code: String, includesCheckDigit: Bool): Int64 {
        var total = 0
        let runes = code.toRuneArray()
        let lth = runes.size + (if (includesCheckDigit) { 0 } else { 1 })
        for (i in 0..runes.size) {
            let leftPos = i + 1
            let rightPos = lth - i
            let charValue = toInt(runes[i], leftPos, rightPos)
            total += weightedValue(charValue, leftPos, rightPos)
        }
        if (total == 0) {
            throw CheckDigitException("Invalid code, sum is zero")
        }
        total % modulus
    }

    public open override func isValid(code: String): Bool {
        if (checkdigitIsBlank(code)) {
            return false
        }
        try {
            calculateModulus(code, true) == 0
        } catch (e: CheckDigitException) {
            false
        }
    }

    public open func toCheckDigit(charValue: Int64): String {
        if (charValue >= 0 && charValue <= 9) {
            return "${charValue}"
        }
        throw CheckDigitException("Invalid Check Digit Value =${charValue}")
    }

    public open func toInt(character: Rune, leftPos: Int64, rightPos: Int64): Int64 {
        if (character.isAsciiNumber()) {
            return character.position() - r'0'.position()
        }
        throw CheckDigitException("Invalid Character[${leftPos}] = '${character}'")
    }

    public open func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64 {
        throw CheckDigitException("weightedValue() not implemented")
    }
}
