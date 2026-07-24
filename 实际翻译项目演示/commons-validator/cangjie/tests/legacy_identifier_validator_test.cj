package commons_validator_test

import std.unittest.*

import validator.*

func legacyIdEnsure(condition: Bool, message: String): Unit {
    if (!condition) {
        throw Exception(message)
    }
}

private class LegacyDinersClub <: CreditCardType {
    public func matches(card: String): Bool {
        let prefix = card[0..3] + ","
        ("300,301,302,303,304,305,").contains(prefix) && card.size == 14
    }
}

@Test
class LegacyIdentifierTranslatedTest {
    @TestCase
    func legacyCreditCardValidatorBehaviors(): Unit {
        let validVisa = "4417123456789113"
        let validShortVisa = "4222222222222"
        let validAmex = "378282246310005"
        let validMastercard = "5105105105105100"
        let validDiscover = "6011000990139424"
        let validDiners = "30569309025904"

        let disabled = CreditCardValidator(CreditCardValidator.NONE)
        legacyIdEnsure(!disabled.isValid(Some(validVisa)), "legacy none visa")
        legacyIdEnsure(!disabled.isValid(Some(validAmex)), "legacy none amex")
        legacyIdEnsure(!disabled.isValid(Some(validMastercard)), "legacy none mc")
        legacyIdEnsure(!disabled.isValid(Some(validDiscover)), "legacy none discover")
        disabled.addAllowedCardType(LegacyDinersClub())
        legacyIdEnsure(disabled.isValid(Some(validDiners)), "legacy custom diners")

        var validator = CreditCardValidator()
        legacyIdEnsure(!validator.isValid(None<String>), "legacy null")
        legacyIdEnsure(!validator.isValid(Some("")), "legacy empty")
        legacyIdEnsure(!validator.isValid(Some("123456789012")), "legacy short")
        legacyIdEnsure(!validator.isValid(Some("12345678901234567890")), "legacy long")
        legacyIdEnsure(!validator.isValid(Some("4417123456789112")), "legacy invalid luhn")
        legacyIdEnsure(!validator.isValid(Some("4417q23456w89113")), "legacy invalid chars")
        legacyIdEnsure(validator.isValid(Some(validVisa)), "legacy visa")
        legacyIdEnsure(validator.isValid(Some(validShortVisa)), "legacy short visa")
        legacyIdEnsure(validator.isValid(Some(validAmex)), "legacy amex")
        legacyIdEnsure(validator.isValid(Some(validMastercard)), "legacy mc")
        legacyIdEnsure(validator.isValid(Some(validDiscover)), "legacy discover")

        validator = CreditCardValidator(CreditCardValidator.AMEX)
        legacyIdEnsure(!validator.isValid(Some(validVisa)), "legacy visa disallowed")

        legacyIdEnsure(!GenericValidator.isCreditCard(Some("1234567890")), "generic credit-card invalid path")
    }

    @TestCase
    func legacyIsbnValidatorBehaviors(): Unit {
        let validator = ISBNValidator()
        legacyIdEnsure(!validator.isValid(None<String>), "legacy isbn null")
        legacyIdEnsure(!validator.isValid(Some("")), "legacy isbn empty")
        legacyIdEnsure(!validator.isValid(Some("1")), "legacy isbn short")
        legacyIdEnsure(!validator.isValid(Some("12345678901234")), "legacy isbn long")
        legacyIdEnsure(!validator.isValid(Some("dsasdsadsads")), "legacy isbn chars")
        legacyIdEnsure(!validator.isValid(Some("535365")), "legacy isbn random digits")
        legacyIdEnsure(!validator.isValid(Some("I love sparrows!")), "legacy isbn words")
        legacyIdEnsure(!validator.isValid(Some("--1 930110 99 5")), "legacy isbn bad prefix")
        legacyIdEnsure(!validator.isValid(Some("1 930110 99 5--")), "legacy isbn bad suffix")
        legacyIdEnsure(!validator.isValid(Some("1 930110-99 5-")), "legacy isbn bad separators")

        legacyIdEnsure(validator.isValid(Some("1930110995")), "legacy isbn raw")
        legacyIdEnsure(validator.isValid(Some("1-930110-99-5")), "legacy isbn dashes")
        legacyIdEnsure(validator.isValid(Some("1 930110 99 5")), "legacy isbn spaces")
        legacyIdEnsure(validator.isValid(Some("0-201-63385-X")), "legacy isbn x")
        legacyIdEnsure(!validator.isValid(Some("068-556-98-45")), "legacy isbn invalid")
    }
}
