package commons_validator_test

import std.unittest.*

import validator.routines.*
import validator.routines.checkdigit.*

func routinesIdEnsure(condition: Bool, message: String): Unit {
    if (!condition) {
        throw Exception(message)
    }
}

func routinesIdEnsureSome(expected: String, actual: ?String, message: String): Unit {
    match (actual) {
        case Some(value) => routinesIdEnsure(value == expected, "${message}: expected=${expected} actual=${value}")
        case None => throw Exception("${message}: expected Some(${expected}) actual=None")
    }
}

func routinesIdEnsureNone(actual: ?String, message: String): Unit {
    match (actual) {
        case Some(value) => throw Exception("${message}: expected=None actual=${value}")
        case None => ()
    }
}

func routinesIdExpectIllegalArgument(action: () -> Unit): Unit {
    try {
        action()
        throw Exception("Expected IllegalArgumentException")
    } catch (e: IllegalArgumentException) {
        ()
    }
}

func routinesIdRegex(validator: CodeValidator): RegexValidator {
    match (validator.getRegexValidator()) {
        case Some(value) => value
        case None => throw Exception("Expected RegexValidator")
    }
}

func routinesIdTwoDigits(value: Int64): String {
    if (value < 10) {
        return "0${value}"
    }
    "${value}"
}

let ROUTINES_VALID_VISA = "4417123456789113"
let ROUTINES_ERROR_VISA = "4417123456789112"
let ROUTINES_VALID_SHORT_VISA = "4222222222222"
let ROUTINES_ERROR_SHORT_VISA = "4222222222229"
let ROUTINES_VALID_AMEX = "378282246310005"
let ROUTINES_ERROR_AMEX = "378282246310001"
let ROUTINES_VALID_MASTERCARD = "5105105105105100"
let ROUTINES_ERROR_MASTERCARD = "5105105105105105"
let ROUTINES_VALID_DISCOVER = "6011000990139424"
let ROUTINES_ERROR_DISCOVER = "6011000990139421"
let ROUTINES_VALID_DISCOVER65 = "6534567890123458"
let ROUTINES_ERROR_DISCOVER65 = "6534567890123450"
let ROUTINES_VALID_DINERS = "30569309025904"
let ROUTINES_ERROR_DINERS = "30569309025901"
let ROUTINES_VALID_VPAY = "4370000000000061"
let ROUTINES_VALID_VPAY2 = "4370000000000012"
let ROUTINES_ERROR_VPAY = "4370000000000069"

let ROUTINES_VALID_CARDS = [
    ROUTINES_VALID_VISA,
    ROUTINES_VALID_SHORT_VISA,
    ROUTINES_VALID_AMEX,
    ROUTINES_VALID_MASTERCARD,
    ROUTINES_VALID_DISCOVER,
    ROUTINES_VALID_DISCOVER65,
    ROUTINES_VALID_DINERS,
    ROUTINES_VALID_VPAY,
    ROUTINES_VALID_VPAY2,
    "60115564485789458"
]

let ROUTINES_ERROR_CARDS = [
    ROUTINES_ERROR_VISA,
    ROUTINES_ERROR_SHORT_VISA,
    ROUTINES_ERROR_AMEX,
    ROUTINES_ERROR_MASTERCARD,
    ROUTINES_ERROR_DISCOVER,
    ROUTINES_ERROR_DISCOVER65,
    ROUTINES_ERROR_DINERS,
    ROUTINES_ERROR_VPAY,
    "",
    "12345678901",
    "12345678901234567890",
    "4417123456789112"
]

let ROUTINES_VALID_ISBN10_FORMAT = [
    "1234567890",
    "123456789X",
    "12345-1234567-123456-X",
    "12345 1234567 123456 X",
    "1-2-3-4",
    "1 2 3 4"
]

let ROUTINES_INVALID_ISBN10_FORMAT = [
    "",
    "   ",
    "1",
    "123456789",
    "12345678901",
    "12345678X0",
    "123456-1234567-123456-X",
    "12345-12345678-123456-X",
    "12345-1234567-1234567-X",
    "12345-1234567-123456-X2",
    "--1 930110 99 5",
    "1 930110 99 5--",
    "1 930110-99 5-",
    "1.2.3.4",
    "1=2=3=4",
    "1_2_3_4",
    "123456789Y",
    "dsasdsadsa",
    "I love sparrows!",
    "068-556-98-45"
]

let ROUTINES_VALID_ISBN13_FORMAT = [
    "9781234567890",
    "9791234567890",
    "978-12345-1234567-123456-1",
    "979-12345-1234567-123456-1",
    "978 12345 1234567 123456 1",
    "979 12345 1234567 123456 1",
    "978-1-2-3-4",
    "979-1-2-3-4",
    "978 1 2 3 4",
    "979 1 2 3 4"
]

let ROUTINES_INVALID_ISBN13_FORMAT = [
    "",
    "   ",
    "1",
    "978123456789",
    "97812345678901",
    "978-123456-1234567-123456-1",
    "978-12345-12345678-123456-1",
    "978-12345-1234567-1234567-1",
    "978-12345-1234567-123456-12",
    "--978 1 930110 99 1",
    "978 1 930110 99 1--",
    "978 1 930110-99 1-",
    "123-4-567890-12-8",
    "978.1.2.3.4",
    "978=1=2=3=4",
    "978_1_2_3_4",
    "978123456789X",
    "978-0-201-63385-X",
    "dsasdsadsadsa",
    "I love sparrows!",
    "979-1-234-567-89-6"
]

let ROUTINES_VALID_ISSN_FORMAT = [
    "ISSN 0317-8471",
    "1050-124X",
    "ISSN 1562-6865",
    "1063-7710",
    "1748-7188",
    "ISSN 0264-2875",
    "1750-0095",
    "1188-1534",
    "1911-1479",
    "ISSN 1911-1460",
    "0001-6772",
    "1365-201X",
    "0264-3596",
    "1144-875X"
]

let ROUTINES_INVALID_ISSN_FORMAT = [
    "",
    "   ",
    "ISBN 0317-8471",
    "'1050-124X",
    "ISSN1562-6865",
    "10637710",
    "1748-7188'",
    "ISSN  0264-2875",
    "1750 0095",
    "1188_1534",
    "1911-1478"
]

let ROUTINES_VALID_ISIN_FORMAT = [
    "US0378331005",
    "BMG8571G1096",
    "AU0000XVGZA3",
    "GB0002634946",
    "FR0004026250",
    "DK0009763344",
    "GB00B03MLX29",
    "US7562071065",
    "US56845T3059",
    "LU0327357389",
    "US032511BN64",
    "INE112A01023",
    "EZ0000000003",
    "EU000A0VUCF1",
    "XA2053913989",
    "XB0000000008",
    "XC0009698371",
    "XD0000000006",
    "XF0000000004",
    "QS0000000008",
    "QT0000000007",
    "QW0000000002",
    "XS0000000009",
    "EU0009652783",
    "XAC8614YAB92",
    "XC0001458477",
    "XD0209061296",
    "AN8068571086"
]

let ROUTINES_INVALID_ISIN_FORMAT = [
    "",
    "   ",
    "US037833100O",
    "BMG8571G109D",
    "AU0000XVGZAD",
    "GB000263494I",
    "FR000402625C",
    "DK000976334H",
    "3133EHHF3",
    "AU0000xvgzA3",
    "gb0002634946"
]

@Test
class IdentifierFinancialRoutinesTranslatedTest {
    @TestCase
    func creditCardValidatorsAndOptions(): Unit {
        let disabled = CreditCardValidator(CreditCardValidator.NONE)
        routinesIdEnsure(!disabled.isValid(Some(ROUTINES_VALID_VISA)), "none option visa")
        routinesIdEnsure(!disabled.isValid(Some(ROUTINES_VALID_AMEX)), "none option amex")
        routinesIdEnsure(!disabled.isValid(Some(ROUTINES_VALID_MASTERCARD)), "none option mc")
        routinesIdEnsure(!disabled.isValid(Some(ROUTINES_VALID_DISCOVER)), "none option discover")
        routinesIdEnsure(!disabled.isValid(Some(ROUTINES_VALID_DINERS)), "none option diners")

        let visaOnly = CreditCardValidator(CreditCardValidator.VISA)
        routinesIdEnsure(!visaOnly.isValid(Some(ROUTINES_ERROR_VISA)), "visa option invalid")
        routinesIdEnsure(!visaOnly.isValid(Some(ROUTINES_ERROR_SHORT_VISA)), "visa option invalid short")
        routinesIdEnsureNone(visaOnly.validate(Some(ROUTINES_ERROR_VISA)), "visa option validate invalid")
        routinesIdEnsureSome(ROUTINES_VALID_VISA, visaOnly.validate(Some(ROUTINES_VALID_VISA)), "visa option validate")
        routinesIdEnsureSome(ROUTINES_VALID_SHORT_VISA, visaOnly.validate(Some(ROUTINES_VALID_SHORT_VISA)), "visa option validate short")
        routinesIdEnsure(visaOnly.isValid(Some(ROUTINES_VALID_VISA)), "visa option valid")
        routinesIdEnsure(visaOnly.isValid(Some(ROUTINES_VALID_SHORT_VISA)), "visa option valid short")
        routinesIdEnsure(!visaOnly.isValid(Some(ROUTINES_VALID_AMEX)), "visa option rejects amex")

        let amexOnly = CreditCardValidator(CreditCardValidator.AMEX)
        routinesIdEnsure(amexOnly.isValid(Some(ROUTINES_VALID_AMEX)), "amex option valid")
        routinesIdEnsure(!amexOnly.isValid(Some(ROUTINES_VALID_VISA)), "amex option rejects visa")

        let dinersOnly = CreditCardValidator(CreditCardValidator.DINERS)
        routinesIdEnsure(dinersOnly.isValid(Some(ROUTINES_VALID_DINERS)), "diners option valid")
        routinesIdEnsure(!dinersOnly.isValid(Some(ROUTINES_VALID_AMEX)), "diners option rejects amex")

        let discoverOnly = CreditCardValidator(CreditCardValidator.DISCOVER)
        routinesIdEnsure(discoverOnly.isValid(Some(ROUTINES_VALID_DISCOVER)), "discover option valid")
        routinesIdEnsure(discoverOnly.isValid(Some(ROUTINES_VALID_DISCOVER65)), "discover option valid65")
        routinesIdEnsure(!discoverOnly.isValid(Some(ROUTINES_ERROR_DISCOVER65)), "discover option invalid65")

        let mastercardOnly = CreditCardValidator(CreditCardValidator.MASTERCARD)
        routinesIdEnsure(mastercardOnly.isValid(Some(ROUTINES_VALID_MASTERCARD)), "mastercard option valid")
        routinesIdEnsure(!mastercardOnly.isValid(Some(ROUTINES_VALID_DISCOVER)), "mastercard option rejects discover")

        let vpayOnly = CreditCardValidator(CreditCardValidator.VPAY)
        routinesIdEnsure(vpayOnly.isValid(Some(ROUTINES_VALID_VPAY)), "vpay option valid")
        routinesIdEnsure(vpayOnly.isValid(Some(ROUTINES_VALID_VPAY2)), "vpay option valid2")
        routinesIdEnsure(!vpayOnly.isValid(Some(ROUTINES_ERROR_VPAY)), "vpay option invalid")
        routinesIdEnsure(vpayOnly.isValid(Some(ROUTINES_VALID_VISA)), "vpay option accepts visa 16")
        routinesIdEnsure(vpayOnly.isValid(Some(ROUTINES_VALID_SHORT_VISA)), "vpay option accepts visa 13")

        let amexRegex = routinesIdRegex(CreditCardValidator.AMEX_VALIDATOR)
        routinesIdEnsure(!amexRegex.isValid(Some("34345678901234")), "amex regex length 14")
        routinesIdEnsure(amexRegex.isValid(Some("343456789012345")), "amex regex length 15")
        routinesIdEnsure(amexRegex.isValid(Some(ROUTINES_ERROR_AMEX)), "amex regex error card")
        routinesIdEnsure(!CreditCardValidator.AMEX_VALIDATOR.isValid(Some(ROUTINES_ERROR_AMEX)), "amex validator invalid")
        routinesIdEnsure(CreditCardValidator.AMEX_VALIDATOR.isValid(Some("371449635398431")), "amex validator sample")

        let dinersRegex = routinesIdRegex(CreditCardValidator.DINERS_VALIDATOR)
        routinesIdEnsure(dinersRegex.isValid(Some("30045678901234")), "diners regex 300")
        routinesIdEnsure(dinersRegex.isValid(Some("39345678901234")), "diners regex 39")
        routinesIdEnsure(!dinersRegex.isValid(Some("30965678901234")), "diners regex 3096")
        routinesIdEnsure(CreditCardValidator.DINERS_VALIDATOR.isValid(Some("36432685260294")), "diners validator sample")

        let discoverRegex = routinesIdRegex(CreditCardValidator.DISCOVER_VALIDATOR)
        routinesIdEnsure(discoverRegex.isValid(Some("6011567890123456")), "discover regex 6011")
        routinesIdEnsure(discoverRegex.isValid(Some("6534567890123456")), "discover regex 65")
        routinesIdEnsure(!discoverRegex.isValid(Some("6434567890123456")), "discover regex 643")
        routinesIdEnsure(CreditCardValidator.DISCOVER_VALIDATOR.isValid(Some("6011111111111117")), "discover validator sample")

        let mastercardRegex = routinesIdRegex(CreditCardValidator.MASTERCARD_VALIDATOR)
        routinesIdEnsure(mastercardRegex.isValid(Some("5134567890123456")), "mastercard regex 51")
        routinesIdEnsure(mastercardRegex.isValid(Some("2221000000000000")), "mastercard regex 2221")
        routinesIdEnsure(mastercardRegex.isValid(Some("2720990000000000")), "mastercard regex 2720")
        routinesIdEnsure(!mastercardRegex.isValid(Some("2220990000000000")), "mastercard regex below range")
        routinesIdEnsure(!mastercardRegex.isValid(Some("2721000000000000")), "mastercard regex above range")
        routinesIdEnsure(CreditCardValidator.MASTERCARD_VALIDATOR.isValid(Some("5555555555554444")), "mastercard validator sample")

        let visaRegex = routinesIdRegex(CreditCardValidator.VISA_VALIDATOR)
        routinesIdEnsure(!visaRegex.isValid(Some("423456789012")), "visa regex 12")
        routinesIdEnsure(visaRegex.isValid(Some("4234567890123")), "visa regex 13")
        routinesIdEnsure(visaRegex.isValid(Some("4234567890123456")), "visa regex 16")
        routinesIdEnsure(!visaRegex.isValid(Some("3234567890123")), "visa regex wrong prefix")
        routinesIdEnsure(CreditCardValidator.VISA_VALIDATOR.isValid(Some("4012888888881881")), "visa validator sample")
    }

    @TestCase
    func creditCardConstructorsAndRangeBehaviors(): Unit {
        let arrayValidator = CreditCardValidator(Some([CreditCardValidator.VISA_VALIDATOR, CreditCardValidator.AMEX_VALIDATOR]))
        routinesIdEnsure(arrayValidator.isValid(Some(ROUTINES_VALID_VISA)), "array ctor visa")
        routinesIdEnsure(arrayValidator.isValid(Some(ROUTINES_VALID_SHORT_VISA)), "array ctor short visa")
        routinesIdEnsure(arrayValidator.isValid(Some(ROUTINES_VALID_AMEX)), "array ctor amex")
        routinesIdEnsure(!arrayValidator.isValid(Some(ROUTINES_VALID_MASTERCARD)), "array ctor mc reject")
        routinesIdExpectIllegalArgument({ => CreditCardValidator(None<Array<CodeValidator>>) })

        let generic = CreditCardValidator.genericCreditCardValidator()
        for (value in ROUTINES_VALID_CARDS) {
            routinesIdEnsure(generic.isValid(Some(value)), "generic valid ${value}")
        }
        for (value in ROUTINES_ERROR_CARDS) {
            routinesIdEnsure(!generic.isValid(Some(value)), "generic invalid ${value}")
        }

        var ccv = CreditCardValidator([CreditCardRange("305", Some("4"), [13, 16])])
        routinesIdEnsure(ccv.isValid(Some(ROUTINES_VALID_SHORT_VISA)), "disjoint range short visa")
        routinesIdEnsure(ccv.isValid(Some(ROUTINES_VALID_VISA)), "disjoint range visa")
        routinesIdEnsure(!ccv.isValid(Some(ROUTINES_VALID_DINERS)), "disjoint range diners reject")
        ccv = CreditCardValidator([CreditCardRange("305", Some("4"), [13, 14, 16])])
        routinesIdEnsure(ccv.isValid(Some(ROUTINES_VALID_DINERS)), "disjoint range diners accepted")

        let rangeGenerated = CreditCardValidator(
            Some([
                CreditCardValidator.AMEX_VALIDATOR,
                CreditCardValidator.VISA_VALIDATOR,
                CreditCardValidator.MASTERCARD_VALIDATOR,
                CreditCardValidator.DISCOVER_VALIDATOR
            ]),
            Some([
                CreditCardRange("300", Some("305"), 14, 14),
                CreditCardRange("3095", None<String>, 14, 14),
                CreditCardRange("36", None<String>, 14, 14),
                CreditCardRange("38", Some("39"), 14, 14)
            ])
        )
        for (value in ROUTINES_VALID_CARDS) {
            routinesIdEnsure(rangeGenerated.isValid(Some(value)), "range generated valid ${value}")
        }
        for (value in ROUTINES_ERROR_CARDS) {
            routinesIdEnsure(!rangeGenerated.isValid(Some(value)), "range generated invalid ${value}")
        }

        let noLuhn = CreditCardValidator.createRangeValidator(
            [CreditCardRange("1", None<String>, 6, 7), CreditCardRange("644", Some("65"), 8, 8)],
            None<CheckDigit>
        )
        routinesIdEnsure(noLuhn.isValid(Some("1990000")), "range no luhn 7")
        routinesIdEnsure(noLuhn.isValid(Some("199000")), "range no luhn 6")
        routinesIdEnsure(!noLuhn.isValid(Some("000000")), "range no luhn low")
        routinesIdEnsure(!noLuhn.isValid(Some("200000")), "range no luhn high")
        routinesIdEnsure(!noLuhn.isValid(Some("64399999")), "range no luhn below 644")
        routinesIdEnsure(noLuhn.isValid(Some("64400000")), "range no luhn 644")
        routinesIdEnsure(noLuhn.isValid(Some("65999999")), "range no luhn 65999999")
        routinesIdEnsure(!noLuhn.isValid(Some("66000000")), "range no luhn above 65")

        routinesIdEnsure(CreditCardValidator.validLength(14, CreditCardRange("", Some(""), 14, 14)), "validLength exact")
        routinesIdEnsure(!CreditCardValidator.validLength(15, CreditCardRange("", Some(""), 14, 14)), "validLength exact miss")
        routinesIdEnsure(CreditCardValidator.validLength(16, CreditCardRange("", Some(""), 15, 17)), "validLength range")
        routinesIdEnsure(!CreditCardValidator.validLength(18, CreditCardRange("", Some(""), 15, 17)), "validLength range miss")
        routinesIdEnsure(CreditCardValidator.validLength(15, CreditCardRange("", Some(""), [15, 17])), "validLength list 15")
        routinesIdEnsure(!CreditCardValidator.validLength(16, CreditCardRange("", Some(""), [15, 17])), "validLength list 16")

        let separatorRegex = "^(5[1-5]\\d{2})(?:[- ])?(\\d{4})(?:[- ])?(\\d{4})(?:[- ])?(\\d{4})$"
        let separatorValidator = CodeValidator(separatorRegex, Some(LuhnCheckDigit.LUHN_CHECK_DIGIT))
        let separatorMatcher = routinesIdRegex(separatorValidator)
        routinesIdEnsureSome("5134567890123456", separatorMatcher.validate(Some("5134-5678-9012-3456")), "separator validate hyphen")
        routinesIdEnsureSome("5134567890123456", separatorMatcher.validate(Some("5134 5678 9012 3456")), "separator validate space")
        routinesIdEnsure(!separatorMatcher.isValid(Some("5134.5678.9012.3456")), "separator invalid char")
        routinesIdEnsureSome("5500000000000004", separatorValidator.validate(Some("5500-0000-0000-0004")), "separator validator luhn")
    }

    @TestCase
    func isbnValidatorBehaviors(): Unit {
        let validator = ISBNValidator.getInstance()
        routinesIdExpectIllegalArgument({ => validator.convertToISBN13(Some("123456789 ")) })
        routinesIdExpectIllegalArgument({ => validator.convertToISBN13(Some("12345678901")) })
        routinesIdExpectIllegalArgument({ => validator.convertToISBN13(Some("")) })
        routinesIdExpectIllegalArgument({ => validator.convertToISBN13(Some("X234567890")) })

        var baseCode = "193011099"
        routinesIdEnsure(!validator.isValid(Some(baseCode + "0")), "isbn10 check 0")
        routinesIdEnsure(validator.isValid(Some(baseCode + "5")), "isbn10 check 5")
        routinesIdEnsure(!validator.isValid(Some(baseCode + "X")), "isbn10 check X")
        baseCode = "978193011099"
        routinesIdEnsure(validator.isValid(Some(baseCode + "1")), "isbn13 check 1")
        routinesIdEnsure(!validator.isValid(Some(baseCode + "0")), "isbn13 check 0")

        for (value in ROUTINES_INVALID_ISBN10_FORMAT) {
            routinesIdEnsure(!validator.isValidISBN10(Some(value)), "invalid isbn10 format ${value}")
            routinesIdEnsureNone(validator.validateISBN10(Some(value)), "invalid isbn10 validate ${value}")
        }
        for (value in ROUTINES_INVALID_ISBN13_FORMAT) {
            routinesIdEnsure(!validator.isValidISBN13(Some(value)), "invalid isbn13 format ${value}")
            routinesIdEnsureNone(validator.validateISBN13(Some(value)), "invalid isbn13 validate ${value}")
        }
        for (value in ROUTINES_VALID_ISBN10_FORMAT) {
            routinesIdEnsure(routinesIdRegex(CodeValidator(ISBNValidator.ISBN10_REGEX, None<CheckDigit>)).isValid(Some(value)), "valid isbn10 regex ${value}")
        }
        for (value in ROUTINES_VALID_ISBN13_FORMAT) {
            routinesIdEnsure(routinesIdRegex(CodeValidator(ISBNValidator.ISBN13_REGEX, None<CheckDigit>)).isValid(Some(value)), "valid isbn13 regex ${value}")
        }

        routinesIdEnsure(validator.isValidISBN10(Some("1930110995")), "isbn10 raw")
        routinesIdEnsure(validator.isValidISBN10(Some("1-930110-99-5")), "isbn10 dashes")
        routinesIdEnsure(validator.isValidISBN10(Some("0-201-63385-X")), "isbn10 x")
        routinesIdEnsure(validator.isValidISBN13(Some("9781930110991")), "isbn13 raw")
        routinesIdEnsure(validator.isValidISBN13(Some("978-1-930110-99-1")), "isbn13 dashes")
        routinesIdEnsure(validator.isValidISBN13(Some("978-0-201-63385-6")), "isbn13 alt")

        routinesIdEnsure(!validator.isValid(None<String>), "isbn null")
        routinesIdEnsure(!validator.isValidISBN10(None<String>), "isbn10 null")
        routinesIdEnsure(!validator.isValidISBN13(None<String>), "isbn13 null")
        routinesIdEnsureNone(validator.validate(None<String>), "isbn validate null")
        routinesIdEnsureNone(validator.validateISBN10(None<String>), "isbn10 validate null")
        routinesIdEnsureNone(validator.validateISBN13(None<String>), "isbn13 validate null")
        routinesIdEnsureNone(validator.convertToISBN13(None<String>), "isbn convert null")

        let noConvert = ISBNValidator.getInstance(false)
        routinesIdEnsureSome("1930110995", noConvert.validate(Some("1930110995")), "isbn validate10 raw")
        routinesIdEnsureSome("1930110995", noConvert.validate(Some("1-930110-99-5")), "isbn validate10 dashed")
        routinesIdEnsureSome("020163385X", noConvert.validate(Some("0-201-63385-X")), "isbn validate10 x")

        routinesIdEnsureSome("9781930110991", validator.validate(Some("1930110995")), "isbn convert raw")
        routinesIdEnsureSome("9781930110991", validator.validate(Some("1-930110-99-5")), "isbn convert dashed")
        routinesIdEnsureSome("9780201633856", validator.validate(Some("0-201-63385-X")), "isbn convert x")
        routinesIdEnsureSome("9781930110991", validator.validateISBN13(Some("978-1-930110-99-1")), "isbn validate13 dashed")
    }

    @TestCase
    func issnValidatorBehaviors(): Unit {
        let validator = ISSNValidator.getInstance()
        routinesIdExpectIllegalArgument({ => validator.extractFromEAN13("9780072129519") })
        routinesIdExpectIllegalArgument({ => validator.extractFromEAN13("9791090636071") })
        routinesIdExpectIllegalArgument({ => validator.extractFromEAN13("03178471") })

        for (value in ROUTINES_INVALID_ISSN_FORMAT) {
            routinesIdEnsure(!validator.isValid(Some(value)), "invalid issn ${value}")
        }
        for (value in ROUTINES_VALID_ISSN_FORMAT) {
            routinesIdEnsure(validator.isValid(Some(value)), "valid issn ${value}")
        }

        routinesIdEnsureSome("12345679", validator.extractFromEAN13("9771234567003"), "extract 12345679")
        routinesIdEnsureSome("1144875X", validator.extractFromEAN13("9771144875007"), "extract 1144875X")

        for (i in 0..ROUTINES_VALID_ISSN_FORMAT.size) {
            let suffix = routinesIdTwoDigits(i % 100)
            match (validator.convertToEAN13(Some(ROUTINES_VALID_ISSN_FORMAT[i]), Some(suffix))) {
                case Some(value) => routinesIdEnsure(EAN13CheckDigit.EAN13_CHECK_DIGIT.isValid(value), "issn to ean ${value}")
                case None => throw Exception("issn to ean none")
            }
        }
        routinesIdEnsureSome("9771144875007", validator.convertToEAN13(Some("1144-875X"), Some("00")), "issn sample 1")
        routinesIdEnsureSome("9770264359008", validator.convertToEAN13(Some("0264-3596"), Some("00")), "issn sample 2")
        routinesIdEnsureSome("9771234567003", validator.convertToEAN13(Some("1234-5679"), Some("00")), "issn sample 3")
        routinesIdEnsureNone(validator.convertToEAN13(None<String>, Some("00")), "issn convert null")

        routinesIdExpectIllegalArgument({ => validator.convertToEAN13(None<String>, None<String>) })
        routinesIdExpectIllegalArgument({ => validator.convertToEAN13(None<String>, Some("")) })
        routinesIdExpectIllegalArgument({ => validator.convertToEAN13(None<String>, Some("0")) })
        routinesIdExpectIllegalArgument({ => validator.convertToEAN13(None<String>, Some("A")) })
        routinesIdExpectIllegalArgument({ => validator.convertToEAN13(None<String>, Some("AA")) })
        routinesIdExpectIllegalArgument({ => validator.convertToEAN13(None<String>, Some("999")) })

        routinesIdEnsure(!validator.isValid(None<String>), "issn null")
        routinesIdEnsureNone(validator.extractFromEAN13("9771234567001"), "issn invalid check digit 1")
        routinesIdEnsureSome("12345679", validator.extractFromEAN13("9771234567003"), "issn valid check digit")
        routinesIdEnsureNone(validator.extractFromEAN13("9771234567009"), "issn invalid check digit 9")
    }

    @TestCase
    func isinValidatorBehaviors(): Unit {
        let validatorTrue = ISINValidator.getInstance(true)
        let validatorFalse = ISINValidator.getInstance(false)

        for (value in ROUTINES_INVALID_ISIN_FORMAT) {
            routinesIdEnsure(!validatorFalse.isValid(Some(value)), "isin false invalid ${value}")
            routinesIdEnsure(!validatorTrue.isValid(Some(value)), "isin true invalid ${value}")
            routinesIdEnsureNone(validatorTrue.validate(Some(value)), "isin true validate invalid ${value}")
        }
        routinesIdEnsure(!validatorTrue.isValid(Some("AB0000000006")), "isin invalid country")
        routinesIdEnsureNone(validatorTrue.validate(Some("AB0000000006")), "isin invalid country validate")

        for (value in ROUTINES_VALID_ISIN_FORMAT) {
            routinesIdEnsure(validatorFalse.isValid(Some(value)), "isin false valid ${value}")
            routinesIdEnsure(validatorTrue.isValid(Some(value)), "isin true valid ${value}")
            routinesIdEnsureSome(value, validatorTrue.validate(Some(value)), "isin validate ${value}")
        }
    }
}
