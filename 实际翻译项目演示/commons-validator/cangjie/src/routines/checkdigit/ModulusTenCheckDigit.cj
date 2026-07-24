package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class ModulusTenCheckDigit <: ModulusCheckDigit {
//   constructors:
//     public init(positionWeight: Array<Int64>)
//     public init(positionWeight: Array<Int64>, useRightPos: Bool)
//     public init(positionWeight: Array<Int64>, useRightPos: Bool, sumWeightedDigits: Bool)
//
//   methods:
//     public func getPositionWeight(): Array<Int64>
//     public func isUseRightPos(): Bool
//     public func isSumWeightedDigits(): Bool
//     public override func isValid(code: String): Bool
//     public override func toInt(character: Rune, leftPos: Int64, rightPos: Int64): Int64
//     public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64
//     public func toString(): String
// }

public class ModulusTenCheckDigit <: ModulusCheckDigit {
    private let positionWeight: Array<Int64>
    private let useRightPos: Bool
    private let sumWeightedDigits: Bool

    public init(positionWeight: Array<Int64>) {
        this.positionWeight = positionWeight.clone()
        this.useRightPos = false
        this.sumWeightedDigits = false
    }

    public init(positionWeight: Array<Int64>, useRightPos: Bool) {
        this.positionWeight = positionWeight.clone()
        this.useRightPos = useRightPos
        this.sumWeightedDigits = false
    }

    public init(positionWeight: Array<Int64>, useRightPos: Bool, sumWeightedDigits: Bool) {
        this.positionWeight = positionWeight.clone()
        this.useRightPos = useRightPos
        this.sumWeightedDigits = sumWeightedDigits
    }

    public func getPositionWeight(): Array<Int64> {
        positionWeight.clone()
    }

    public func isUseRightPos(): Bool {
        useRightPos
    }

    public func isSumWeightedDigits(): Bool {
        sumWeightedDigits
    }

    public override func isValid(code: String): Bool {
        if (checkdigitIsBlank(code) || !checkdigitCharAt(code, checkdigitLength(code) - 1).isAsciiNumber()) {
            return false
        }
        super.isValid(code)
    }

    public override func toInt(character: Rune, leftPos: Int64, rightPos: Int64): Int64 {
        let num = checkdigitNumericValue(character)
        if (num < 0) {
            throw CheckDigitException("Invalid Character[${leftPos}] = '${character}'")
        }
        num
    }

    public override func weightedValue(charValue: Int64, leftPos: Int64, rightPos: Int64): Int64 {
        let pos = if (useRightPos) { rightPos } else { leftPos }
        let weight = positionWeight[(pos - 1) % positionWeight.size]
        var weighted = charValue * weight
        if (sumWeightedDigits) {
            weighted = ModulusCheckDigit.sumDigits(weighted)
        }
        weighted
    }

    public func toString(): String {
        "ModulusTenCheckDigit[positionWeight=${positionWeight}, useRightPos=${useRightPos}, sumWeightedDigits=${sumWeightedDigits}]"
    }
}
