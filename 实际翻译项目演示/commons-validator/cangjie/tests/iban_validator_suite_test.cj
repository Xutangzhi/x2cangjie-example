package commons_validator_test

import std.unittest.*

import validator.routines.*
import validator.routines.checkdigit.*

@Test
class IBANValidatorTranslatedTest {
    @TestCase
    func fixturesAndBasicApis(): Unit {
        let validator = IBANValidator.getInstance()
        match (validator.getValidator(Some("GB"))) {
            case Some(value) =>
                ibanTestEnsure(value.getRegexValidator().getRegexStrings().size > 0, "gb patterns")
                ibanTestEnsure(value.getIbanLength() == 22, "gb length")
            case None =>
                throw Exception("Missing GB validator")
        }
        ibanTestEnsure(ibanTestOptionIsNone(validator.getValidator(Some("gb"))), "lowercase validator should be absent")
        ibanTestEnsure(validator.hasValidator(Some("GB")), "has gb")
        ibanTestEnsure(!validator.hasValidator(Some("gb")), "has lowercase gb")
        ibanTestEnsure(!validator.isValid(None<String>), "null should be invalid")

        for (iban in INVALID_IBAN_FIXTURES) {
            ibanTestEnsure(!validator.isValid(Some(iban)), "invalid fixture ${iban}")
        }
        for (iban in VALID_IBAN_FIXTURES) {
            ibanTestEnsure(validator.hasValidator(Some(iban)), "missing validator ${iban}")
            ibanTestEnsure(validator.isValid(Some(iban)), "valid fixture ${iban}")
        }

        ibanTestEnsure(validator.validate(Some("XX")) == IBANValidatorStatus.UNKNOWN_COUNTRY, "status unknown")
        ibanTestEnsure(validator.validate(Some("AD0101")) == IBANValidatorStatus.INVALID_LENGTH, "status length")
        ibanTestEnsure(validator.validate(Some("AD12XX012030200359100100")) == IBANValidatorStatus.INVALID_PATTERN, "status pattern")
        ibanTestEnsure(validator.validate(Some("AD9900012030200359100100")) == IBANValidatorStatus.INVALID_CHECKSUM, "status checksum")
        ibanTestEnsure(validator.validate(Some("AD1200012030200359100100")) == IBANValidatorStatus.VALID, "status valid")
    }

    @TestCase
    func mutableValidatorBehaviors(): Unit {
        let validator = IBANValidator()
        ibanTestEnsure(
            ibanTestExpectIllegalArgumentMessage({ => validator.setValidator("gb", 15, "GB") }) ==
                "Invalid country Code; must be exactly 2 upper-case characters",
            "lowercase country message"
        )
        ibanTestEnsure(
            ibanTestExpectIllegalArgumentMessage({ => validator.setValidator("GB", 35, "GB") }) ==
                "Invalid length parameter, must be in range 8 to 34 inclusive: 35",
            "length 35 message"
        )
        ibanTestEnsure(
            ibanTestExpectIllegalArgumentMessage({ => validator.setValidator("GB", 7, "GB") }) ==
                "Invalid length parameter, must be in range 8 to 34 inclusive: 7",
            "length 7 message"
        )
        ibanTestEnsure(ibanTestOptionIsSome(validator.setValidator("GB", -1, "")), "remove existing gb")
        ibanTestEnsure(ibanTestOptionIsNone(validator.setValidator("GB", -1, "")), "remove gb twice")
        ibanTestEnsure(ibanTestOptionIsNone(validator.setValidator(Validator("ZZ", 12, "ZZ\\d{10}"))), "custom validator add")
        ibanTestEnsure(validator.hasValidator(Some("ZZ")), "custom validator installed")
        let customBody = "00000000"
        let customCheck = IBANCheckDigit.IBAN_CHECK_DIGIT.calculate("ZZ00" + customBody)
        ibanTestEnsure(validator.isValid(Some("ZZ" + customCheck + customBody)), "custom validator valid")

        let defaultValidator = IBANValidator.getInstance()
        ibanTestEnsure(
            ibanTestExpectIllegalStateMessage({ => defaultValidator.setValidator("GB", 15, "GB") }) ==
                "The singleton validator cannot be modified",
            "singleton set message"
        )
        ibanTestEnsure(
            ibanTestExpectIllegalStateMessage({ => defaultValidator.setValidator("GB", -1, "GB") }) ==
                "The singleton validator cannot be modified",
            "singleton remove message"
        )
    }

    @TestCase
    func defaultValidatorsRemainSortedAndConfigured(): Unit {
        let validators = IBANValidator().getDefaultValidators()
        ibanTestEnsure(validators.size > 0, "default validators empty")
        for (i in 1..validators.size) {
            ibanTestEnsure(validators[i - 1].countryCode < validators[i].countryCode, "validators sorted at ${i}")
        }
    }

    @TestCase
    func providerRegistryExamplesAndPatterns(): Unit {
        let rows = ibanTestReadTsvRows()
        let countryRow = ibanTestFindRow(rows, "Name of country")
        let codeRow = ibanTestFindRow(rows, "IBAN prefix country code (ISO 3166)")
        let additionalRow = ibanTestFindRow(rows, "Country code includes other countries/territories")
        let structureRow = ibanTestFindRow(rows, "IBAN structure")
        let lengthRow = ibanTestFindRow(rows, "IBAN length")
        let exampleRow = ibanTestFindRow(rows, "IBAN electronic format example")
        let validator = IBANValidator.getInstance()

        for (i in 1..countryRow.size) {
            let example = exampleRow[i].trimAscii()
            if (!example.isEmpty() && !ibanTestArrayContains(INVALID_IBAN_FIXTURES, example)) {
                ibanTestEnsure(validator.isValid(Some(example)), "registry example ${countryRow[i]} => ${example}")
            }

            let countryCode = codeRow[i].trimAscii()
            match (validator.getValidator(Some(countryCode))) {
                case Some(formatValidator) =>
                    let expectedLength = ibanTestParseInt(lengthRow[i])
                    ibanTestEnsure(formatValidator.getIbanLength() == expectedLength, "length mismatch for ${countryCode}")
                    let additionalCodes = ibanTestAdditionalCodes(additionalRow[i])
                    let regexStrings = formatValidator.getRegexValidator().getRegexStrings()
                    ibanTestEnsure(regexStrings.size == additionalCodes.size + 1, "pattern count mismatch for ${countryCode}")
                    let expectedRegex = ibanTestFormatToRegex(structureRow[i].trimAscii()[2..], expectedLength - 2)
                    ibanTestEnsure(ibanTestArrayContains(regexStrings, countryCode + expectedRegex), "missing primary pattern for ${countryCode}")
                    for (additionalCode in additionalCodes) {
                        ibanTestEnsure(ibanTestArrayContains(regexStrings, additionalCode + expectedRegex), "missing additional pattern ${additionalCode}")
                    }
                case None =>
                    throw Exception("Missing validator for ${countryCode}")
            }
        }
    }
}
