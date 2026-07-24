package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public interface CreditCardType {
//   methods:
//     func matches(card: String): Bool
// }

// public class CreditCardValidator {
//   static fields/constants:
//     public static let NONE: Int64 = 0
//     public static let AMEX: Int64 = 1
//     public static let VISA: Int64 = 1 << 1
//     public static let MASTERCARD: Int64 = 1 << 2
//     public static let DISCOVER: Int64 = 1 << 3
//
//   constructors:
//     public init()
//     public init(options: Int64)
//
//   methods:
//     public func addAllowedCardType(cardType: CreditCardType): Unit
//     public func isValid(card: ?String): Bool
//     protected func luhnCheck(cardNumber: String): Bool
// }

import std.collection.*

private class LegacyAmex <: CreditCardType {
    public func matches(card: String): Bool {
        let prefix = card[0..2] + ","
        ("34,37,").contains(prefix) && card.size == 15
    }
}

private class LegacyDiscover <: CreditCardType {
    public func matches(card: String): Bool {
        card[0..4] == "6011" && card.size == 16
    }
}

private class LegacyMastercard <: CreditCardType {
    public func matches(card: String): Bool {
        let prefix = card[0..2] + ","
        ("51,52,53,54,55,").contains(prefix) && card.size == 16
    }
}

private class LegacyVisa <: CreditCardType {
    public func matches(card: String): Bool {
        card[0..1] == "4" && (card.size == 13 || card.size == 16)
    }
}

public interface CreditCardType {
    func matches(card: String): Bool
}

public class CreditCardValidator {
    public static let NONE: Int64 = 0
    public static let AMEX: Int64 = Int64(1) << 0
    public static let VISA: Int64 = Int64(1) << 1
    public static let MASTERCARD: Int64 = Int64(1) << 2
    public static let DISCOVER: Int64 = Int64(1) << 3

    private let cardTypes = ArrayList<CreditCardType>()

    public init() {
        this(AMEX + VISA + MASTERCARD + DISCOVER)
    }

    public init(options: Int64) {
        if ((options & VISA) > 0) {
            cardTypes.add(LegacyVisa())
        }
        if ((options & AMEX) > 0) {
            cardTypes.add(LegacyAmex())
        }
        if ((options & MASTERCARD) > 0) {
            cardTypes.add(LegacyMastercard())
        }
        if ((options & DISCOVER) > 0) {
            cardTypes.add(LegacyDiscover())
        }
    }

    public func addAllowedCardType(cardType: CreditCardType): Unit {
        cardTypes.add(cardType)
    }

    public func isValid(card: ?String): Bool {
        match (card) {
            case Some(value) =>
                if (value.size < 13 || value.size > 19 || !luhnCheck(value)) {
                    return false
                }
                for (cardType in cardTypes) {
                    if (cardType.matches(value)) {
                        return true
                    }
                }
                false
            case None =>
                false
        }
    }

    protected func luhnCheck(cardNumber: String): Bool {
        let digits = cardNumber.size
        let oddOrEven = digits & 1
        var sum: Int64 = 0
        for (index in 0..digits) {
            let character = cardNumber.toRuneArray()[index]
            if (!character.isAsciiNumber()) {
                return false
            }
            var digit = character.position() - r'0'.position()
            if (((index & 1) ^ oddOrEven) == 0) {
                digit *= 2
                if (digit > 9) {
                    digit -= 9
                }
            }
            sum += digit
        }
        sum != 0 && sum % 10 == 0
    }
}
