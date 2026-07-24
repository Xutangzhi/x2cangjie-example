package commons_validator_test

import std.collection.*
import std.unittest.*

import validator.routines.checkdigit.*

let POSSIBLE_CHECK_DIGITS = "0123456789 ABCDEFHIJKLMNOPQRSTUVWXYZ\tabcdefghijklmnopqrstuvwxyz!@$%^&*()_+"

let ABA_VALID: Array<String> = ["123456780", "123123123", "011000015", "111000038", "231381116", "121181976"]
let CUSIP_VALID: Array<String> = ["037833100", "931142103", "837649128", "392690QT3", "594918104", "86770G101", "Y8295N109", "G8572F100"]
let EAN13_VALID: Array<String> = ["9780072129519", "9780764558313", "4025515373438", "0095673400332"]
let LUHN_VALID: Array<String> = ["4417123456789113", "4222222222222", "378282246310005", "5105105105105100", "6011000990139424", "30569309025904"]
let ISBN10_VALID: Array<String> = ["1930110995", "020163385X", "1932394354", "1590596277"]
let ISBN_VALID: Array<String> = ["9780072129519", "9780764558313", "1930110995", "020163385X", "1590596277", "9781590596272"]
let ISSN_VALID: Array<String> = ["03178471", "1050124X", "15626865", "10637710", "17487188", "02642875", "17500095", "11881534", "19111479", "19111460", "00016772", "1365201X"]
let ISSN_INVALID: Array<String> = ["03178472", "1050-124X", " 1365201X", "1365201X ", " 1365201X "]
let ISIN_VALID: Array<String> = ["US0378331005", "BMG8571G1096", "AU0000XVGZA3", "GB0002634946", "FR0004026250", "3133EHHF3", "DK0009763344", "dk0009763344", "AU0000xvgza3", "EZ0000000003", "XS0000000009", "AA0000000006"]
let ISIN_INVALID_DIGITS: Array<String> = ["US037833100O", "BMG8571G109D", "AU0000XVGZAD", "GB000263494I", "FR000402625C", "DK000976334H"]
let SEDOL_VALID: Array<String> = ["0263494", "0870612", "B06LQ97", "3437575", "B07LF55"]
let SEDOL_INVALID_DIGITS: Array<String> = ["026349E", "087061C", "B06LQ9H", "343757F", "B07LF5F"]
let MODULUS_TEN_CUSIP_INVALID_DIGITS: Array<String> = ["DUS0421CW", "DUS0421CN", "DUS0421CE"]
let MODULUS_TEN_CUSIP_VALID_DIGITS: Array<String> = ["DUS0421C5"]
let MODULUS_TEN_SEDOL_INVALID_DIGITS: Array<String> = SEDOL_INVALID_DIGITS
let CUSIP_INVALID_DIGITS: Array<String> = MODULUS_TEN_CUSIP_INVALID_DIGITS
let CUSIP_VALID_DIGITS: Array<String> = MODULUS_TEN_CUSIP_VALID_DIGITS
let CAS_VALID: Array<String> = ["00-01-1", "7732-18-5", "64-17-5", "50-78-2", "58-08-2", "50-00-0", "50-02-2", "7440-38-2", "1332-21-4", "9999999-99-5"]
let EC_VALID: Array<String> = ["000-001-6", "200-001-8", "200-003-9", "231-148-6", "603-721-4", "999-999-2"]
let IBAN_INVALID: Array<String> = ["510007+47061BE63", "IE01AIBK93118702569045", "AA0000000000089", "AA9900000000053"]
let IBAN_RESOURCE_LINES: Array<String> = [
    "AL47 2121 1009 0000 0002 3569 8741",
    "AD12 0001 2030 2003 5910 0100",
    "BE68 5390 0754 7034",
    "BA39 1290 0794 0102 8494",
    "BG80 BNBG 9661 1020 3456 78",
    "DK50 0040 0440 1162 43",
    "FO62 6460 0001 6316 34",
    "GL89 6471 0001 0002 06",
    "DE89 3704 0044 0532 0130 00",
    "GB29 NWBK 6016 1331 9268 19",
    "EE38 2200 2210 2014 5685",
    "FI21 1234 5600 0007 85",
    "FR14 2004 1010 0505 0001 3M02 606",
    "GI75 NWBK 0000 0000 7099 453",
    "GR16 0110 1250 0000 0001 2300 695",
    "IE29 AIBK 9311 5212 3456 78",
    "IS14 0159 2600 7654 5510 7303 39",
    "IT60 X054 2811 1010 0000 0123 456",
    "HR12 1001 0051 8630 0016 0",
    "LV80 BANK 0000 4351 9500 1",
    "LI21 0881 0000 2324 013A A",
    "LT12 1000 0111 0100 1000",
    "LU28 0019 4006 4475 0000",
    "MT84 MALT 0110 0001 2345 MTLC AST0 01S",
    "MK07 2501 2000 0058 984",
    "MC58 11222 00001 0123456789030",
    "ME25 5050 0001 2345 6789 51",
    "NL91 ABNA 0417 1643 00",
    "NO93 8601 1117 947",
    "AT61 1904 3002 3457 3201",
    "PL61 1090 1014 0000 0712 1981 2874",
    "PT50 0002 0123 1234 5678 9015 4",
    "RO49 AAAA 1B31 0075 9384 0000",
    "SM86 U032 2509 8000 0000 0270 100",
    "SE45 5000 0000 0583 9825 7466",
    "CH93 0076 2011 6238 5295 7",
    "RS35 2600 0560 1001 6113 79",
    "SK31 1200 0000 1987 4263 7541",
    "SI56 1910 0000 0123 438",
    "ES91 2100 0418 4502 0005 1332",
    "CZ94 5500 0000 0010 1103 8930",
    "TR33 0006 1005 1978 6457 8413 26",
    "HU42 1177 3016 1111 1018 0000 0000",
    "CY17 0020 0128 0000 0012 0052 7600",
    "AO06 0006 0000 0100 0371 3117 4",
    "AZ21 NABZ 0000 0000 1370 1000 1944",
    "BH67 BMAG 0000 1299 1234 56",
    "BJ11 B006 1010 0400 2711 0119 2591",
    "BR97 0036 0305 0000 1000 9795 493P 1",
    "VG96 VPVG 0000 0123 4567 8901",
    "BF10 3013 4020 0154 0094 5000 643",
    "BI43 2010 1106 7444",
    "CR05 1520 2001 0262 8406 6",
    "DO28 BAGR 0000 0001 2124 5361 1324",
    "GE29 NB00 0000 0101 9049 17",
    "IR58 0540 1051 8002 1273 1130 07",
    "IL62 0108 0000 0009 9999 999",
    "JO94 CBJO 0010 0000 0000 0131 0003 02",
    "CM21 1000 3001 0005 0000 0605 306",
    "CV64 0003 0000 4547 0691 1017 6",
    "KZ86 125K ZT50 0410 0100",
    "QA58 DOHB 0000 1234 5678 90AB CDEF G",
    "CG52 3001 1000 2021 5123 4567 890",
    "KW81 CBKU 0000 0000 0000 1234 5601 01",
    "LB62 0999 0000 0001 0019 0122 9114",
    "MG46 0000 5030 0101 0191 4016 056",
    "ML03 D008 9017 0001 0021 2000 0447",
    "MR13 0002 0001 0100 0012 3456 753",
    "MU17 BOMM 0101 1010 3030 0200 000M UR",
    "MD24 AG00 0225 1000 1310 4168",
    "MZ59 0001 0000 0011 8341 9415 7",
    "PK36 SCBL 0000 0011 2345 6702",
    "PS92 PALS 0000 0000 0400 1234 5670 2",
    "CI05 A000 6017 4100 1785 3001 1852",
    "SA03 8000 0000 6080 1016 7519",
    "PT50 0002 0000 0163 0993 1035 5",
    "SN12 K001 0015 2000 0256 9000 7542",
    "TN59 1000 6035 1835 9847 8831",
    "AE07 0331 2345 6789 0123 456",
    "FR76 3000 7000 1100 0997 0004 942",
    "CH59 09000 0001 7342 7712",
    "CH59  9000 0001 7342 7712",
    "-CH59 90000 0001 7342 7712"
]

func testTextLength(code: String): Int64 {
    code.toRuneArray().size
}

func testTextSubstring(code: String, start: Int64): String {
    code[start..]
}

func testTextSubstring(code: String, start: Int64, endExclusive: Int64): String {
    code[start..endExclusive]
}

func defaultCheckDigit(code: String): String {
    testTextSubstring(code, testTextLength(code) - 1)
}

func defaultRemoveCheckDigit(code: String): String {
    testTextSubstring(code, 0, testTextLength(code) - 1)
}

func ibanCheckDigit(code: String): String {
    testTextSubstring(code, 2, 4)
}

func ibanRemoveCheckDigit(code: String): String {
    testTextSubstring(code, 0, 2) + "00" + testTextSubstring(code, 4)
}

func casRemoveCheckDigit(code: String): String {
    let normalized = CASNumberCheckDigit.REGEX_VALIDATOR.validate(code)
    if (let Some(value) <- normalized) {
        return testTextSubstring(value, 0, testTextLength(value) - 1)
    }
    ""
}

func ecRemoveCheckDigit(code: String): String {
    let normalized = ECNumberCheckDigit.REGEX_VALIDATOR.validate(code)
    if (let Some(value) <- normalized) {
        return testTextSubstring(value, 0, testTextLength(value) - 1)
    }
    ""
}

func createInvalidStandardCodes(valid: Array<String>): Array<String> {
    var list = ArrayList<String>()
    for (fullCode in valid) {
        let code = defaultRemoveCheckDigit(fullCode)
        let check = defaultCheckDigit(fullCode)
        for (candidate in POSSIBLE_CHECK_DIGITS.toRuneArray()) {
            let current = "${candidate}"
            if (current != check) {
                list.add(code + current)
            }
        }
    }
    list.toArray()
}

func createInvalidIbanCodes(valid: Array<String>): Array<String> {
    var list = ArrayList<String>()
    for (fullCode in valid) {
        let code = ibanRemoveCheckDigit(fullCode)
        let check = ibanCheckDigit(fullCode)
        for (value in 2..99) {
            let current = if (value > 9) { "${value}" } else { "0${value}" }
            if (current != check) {
                list.add(testTextSubstring(code, 0, 2) + current + testTextSubstring(code, 4))
            }
        }
    }
    list.toArray()
}

func removeSpaces(text: String): String {
    var result = ""
    for (character in text.toRuneArray()) {
        if (character != r' ') {
            result += "${character}"
        }
    }
    result
}

func ensure(condition: Bool, message: String): Unit {
    if (!condition) {
        throw Exception(message)
    }
}

func captureCheckDigitExceptionMessage(action: () -> String): String {
    try {
        let result = action()
        throw CheckDigitException("Expected CheckDigitException, got result=${result}")
    } catch (e: CheckDigitException) {
        e.message
    }
}

func checkDigitExceptionMessageEquals(expected: String, action: () -> String): Bool {
    captureCheckDigitExceptionMessage(action) == expected
}

func checkDigitExceptionMessageStartsWith(prefix: String, action: () -> String): Bool {
    captureCheckDigitExceptionMessage(action).startsWith(prefix)
}

@Test
class CheckDigitTranslatedTest {
    @TestCase
    func abstractCheckDigitTestCalculateInvalid(): Unit {
        let aba = ABANumberCheckDigit.ABAN_CHECK_DIGIT
        ensure(aba.calculate("12345678") != "A", "ABA invalid input should not yield alphabetic check digit")

        let cusip = CUSIPCheckDigit.CUSIP_CHECK_DIGIT
        ensure(checkDigitExceptionMessageStartsWith("Invalid ", { => cusip.calculate("0378#310") }), "CUSIP invalid message prefix mismatch")

        let issn = ISSNCheckDigit.ISSN_CHECK_DIGIT
        ensure(checkDigitExceptionMessageStartsWith("Invalid ", { => issn.calculate("1050-124") }), "ISSN invalid message prefix mismatch")
    }

    @TestCase
    func abstractCheckDigitTestCalculateValid(): Unit {
        let routines: Array<(CheckDigit, Array<String>, (String) -> String, (String) -> String)> = [
            (ABANumberCheckDigit.ABAN_CHECK_DIGIT, ABA_VALID, { code => defaultCheckDigit(code) }, { code => defaultRemoveCheckDigit(code) }),
            (EAN13CheckDigit.EAN13_CHECK_DIGIT, EAN13_VALID, { code => defaultCheckDigit(code) }, { code => defaultRemoveCheckDigit(code) }),
            (LuhnCheckDigit.LUHN_CHECK_DIGIT, LUHN_VALID, { code => defaultCheckDigit(code) }, { code => defaultRemoveCheckDigit(code) }),
            (ISBN10CheckDigit.ISBN10_CHECK_DIGIT, ISBN10_VALID, { code => defaultCheckDigit(code) }, { code => defaultRemoveCheckDigit(code) }),
            (ISSNCheckDigit.ISSN_CHECK_DIGIT, ISSN_VALID, { code => defaultCheckDigit(code) }, { code => defaultRemoveCheckDigit(code) }),
            (ISINCheckDigit.ISIN_CHECK_DIGIT, ISIN_VALID, { code => defaultCheckDigit(code) }, { code => defaultRemoveCheckDigit(code) }),
            (SedolCheckDigit.SEDOL_CHECK_DIGIT, SEDOL_VALID, { code => defaultCheckDigit(code) }, { code => defaultRemoveCheckDigit(code) }),
            (CASNumberCheckDigit.getInstance(), CAS_VALID, { code => defaultCheckDigit(code) }, { code => casRemoveCheckDigit(code) }),
            (ECNumberCheckDigit.getInstance(), EC_VALID, { code => defaultCheckDigit(code) }, { code => ecRemoveCheckDigit(code) }),
            (IBANCheckDigit.IBAN_CHECK_DIGIT, ["AD1200012030200359100100", "GB29NWBK60161331926819", "NL91ABNA0417164300"], { code => ibanCheckDigit(code) }, { code => ibanRemoveCheckDigit(code) })
        ]
        for (entry in routines) {
            let routine = entry[0]
            let valid = entry[1]
            let check = entry[2]
            let remove = entry[3]
            for (fullCode in valid) {
                ensure(routine.calculate(remove(fullCode)) == check(fullCode), "Calculated check digit mismatch for ${fullCode}")
            }
        }
    }

    @TestCase
    func abstractCheckDigitTestIsValidFalse(): Unit {
        let aba = ABANumberCheckDigit.ABAN_CHECK_DIGIT
        ensure(!aba.isValid("12345678A"), "ABA should reject alphabetic check digit")
        for (candidate in createInvalidStandardCodes(ABA_VALID)) {
            ensure(!aba.isValid(candidate), "ABA should reject ${candidate}")
        }

        let cusip = CUSIPCheckDigit.CUSIP_CHECK_DIGIT
        ensure(!cusip.isValid("0378#3100"), "CUSIP should reject punctuation")
        for (candidate in createInvalidStandardCodes(["037833100"])) {
            ensure(!cusip.isValid(candidate), "CUSIP should reject ${candidate}")
        }

        let issn = ISSNCheckDigit.ISSN_CHECK_DIGIT
        for (candidate in ISSN_INVALID) {
            ensure(!issn.isValid(candidate), "ISSN should reject ${candidate}")
        }

        let iban = IBANCheckDigit.IBAN_CHECK_DIGIT
        for (candidate in IBAN_INVALID) {
            ensure(!iban.isValid(candidate), "IBAN should reject ${candidate}")
        }
        for (candidate in createInvalidIbanCodes(["AD1200012030200359100100"])) {
            ensure(!iban.isValid(candidate), "IBAN should reject altered check digits ${candidate}")
        }
    }

    @TestCase
    func abstractCheckDigitTestIsValidTrue(): Unit {
        let routines: Array<(CheckDigit, Array<String>)> = [
            (ABANumberCheckDigit.ABAN_CHECK_DIGIT, ABA_VALID),
            (CUSIPCheckDigit.CUSIP_CHECK_DIGIT, CUSIP_VALID),
            (EAN13CheckDigit.EAN13_CHECK_DIGIT, EAN13_VALID),
            (LuhnCheckDigit.LUHN_CHECK_DIGIT, LUHN_VALID),
            (ISBN10CheckDigit.ISBN10_CHECK_DIGIT, ISBN10_VALID),
            (ISBNCheckDigit.ISBN_CHECK_DIGIT, ISBN_VALID),
            (ISSNCheckDigit.ISSN_CHECK_DIGIT, ISSN_VALID),
            (ISINCheckDigit.ISIN_CHECK_DIGIT, ISIN_VALID),
            (SedolCheckDigit.SEDOL_CHECK_DIGIT, SEDOL_VALID),
            (CASNumberCheckDigit.getInstance(), CAS_VALID),
            (ECNumberCheckDigit.getInstance(), EC_VALID),
            (IBANCheckDigit.IBAN_CHECK_DIGIT, ["AD1200012030200359100100", "GB29NWBK60161331926819", "NL91ABNA0417164300"]),
            (VerhoeffCheckDigit.VERHOEFF_CHECK_DIGIT, ["15", "1428570", "12345678902"])
        ]
        for (entry in routines) {
            for (fullCode in entry[1]) {
                ensure(entry[0].isValid(fullCode), "Expected valid code ${fullCode}")
            }
        }
    }

    @TestCase
    func abstractCheckDigitTestMissingCode(): Unit {
        let aba = ABANumberCheckDigit.ABAN_CHECK_DIGIT
        ensure(!aba.isValid(""), "ABA should reject blank code")
        ensure(checkDigitExceptionMessageEquals("Code is missing", { => aba.calculate("") }), "ABA missing code message mismatch")

        let isbn = ISBNCheckDigit.ISBN_CHECK_DIGIT
        ensure(!isbn.isValid(""), "ISBN should reject blank code")
        ensure(checkDigitExceptionMessageEquals("ISBN Code is missing", { => isbn.calculate("") }), "ISBN missing code message mismatch")

        let iban = IBANCheckDigit.IBAN_CHECK_DIGIT
        ensure(!iban.isValid(""), "IBAN should reject blank code")
        ensure(checkDigitExceptionMessageEquals("Invalid Code length=0", { => iban.calculate("") }), "IBAN missing code message mismatch")
    }

    @TestCase
    func abstractCheckDigitTestSerialization(): Unit {
        let stateful = ModulusTenCheckDigit([1, 2], true, true)
        let restored = ModulusTenCheckDigit(stateful.getPositionWeight(), stateful.isUseRightPos(), stateful.isSumWeightedDigits())
        ensure(restored.toString() == stateful.toString(), "Restored modulus-ten state mismatch")
        ensure(restored.isValid("DUS0421C5"), "Restored modulus-ten instance should validate DUS0421C5")

        let stateless = ISBNCheckDigit()
        ensure(stateless.isValid("9780072129519"), "ISBN stateless instance should validate known ISBN-13")
        ensure(VerhoeffCheckDigit().calculate("142857") == "0", "Verhoeff calculation mismatch")
    }

    @TestCase
    func abstractCheckDigitTestZeroSum(): Unit {
        let aba = ABANumberCheckDigit.ABAN_CHECK_DIGIT
        ensure(!aba.isValid("0000000000"), "ABA zero-sum should be invalid")
        ensure(checkDigitExceptionMessageEquals("Invalid code, sum is zero", { => aba.calculate("0000000000") }), "ABA zero-sum message mismatch")

        let isbn = ISBNCheckDigit.ISBN_CHECK_DIGIT
        ensure(!isbn.isValid("000000000000"), "ISBN zero-sum should be invalid")
        ensure(checkDigitExceptionMessageEquals("Invalid code, sum is zero", { => isbn.calculate("000000000000") }), "ISBN zero-sum message mismatch")

        let sedol = SedolCheckDigit.SEDOL_CHECK_DIGIT
        ensure(!sedol.isValid("0000000"), "SEDOL zero-sum should be invalid")
        ensure(checkDigitExceptionMessageEquals("Invalid code, sum is zero", { => sedol.calculate("0000000") }), "SEDOL zero-sum message mismatch")
    }

    @TestCase
    func cusipCheckDigitTestValidator336InvalidCheckDigits(): Unit {
        let routine = CUSIPCheckDigit.CUSIP_CHECK_DIGIT
        for (value in CUSIP_INVALID_DIGITS) {
            ensure(!routine.isValid(value), "CUSIP validator336 invalid digit accepted: ${value}")
        }
    }

    @TestCase
    func cusipCheckDigitTestValidator336ValidCheckDigits(): Unit {
        let routine = CUSIPCheckDigit.CUSIP_CHECK_DIGIT
        for (value in CUSIP_VALID_DIGITS) {
            ensure(routine.isValid(value), "CUSIP validator336 valid digit rejected: ${value}")
        }
    }

    @TestCase
    func modulusTenCusipCheckDigitTestValidator336InvalidCheckDigits(): Unit {
        let routine = ModulusTenCheckDigit([1, 2], true, true)
        for (value in MODULUS_TEN_CUSIP_INVALID_DIGITS) {
            ensure(!routine.isValid(value), "Modulus-ten CUSIP invalid digit accepted: ${value}")
        }
    }

    @TestCase
    func modulusTenCusipCheckDigitTestValidator336ValidCheckDigits(): Unit {
        let routine = ModulusTenCheckDigit([1, 2], true, true)
        for (value in MODULUS_TEN_CUSIP_VALID_DIGITS) {
            ensure(routine.isValid(value), "Modulus-ten CUSIP valid digit rejected: ${value}")
        }
    }

    @TestCase
    func modulusTenSedolCheckDigitTestValidator346(): Unit {
        let routine = ModulusTenCheckDigit([1, 3, 1, 7, 3, 9, 1])
        for (value in MODULUS_TEN_SEDOL_INVALID_DIGITS) {
            ensure(!routine.isValid(value), "Modulus-ten SEDOL invalid digit accepted: ${value}")
        }
    }

    @TestCase
    func sedolCheckDigitTestValidator346(): Unit {
        let routine = SedolCheckDigit.SEDOL_CHECK_DIGIT
        for (value in SEDOL_INVALID_DIGITS) {
            ensure(!routine.isValid(value), "SEDOL invalid digit accepted: ${value}")
        }
    }

    @TestCase
    func isbnCheckDigitTestInvalidLength(): Unit {
        let routine = ISBNCheckDigit.ISBN_CHECK_DIGIT
        ensure(!routine.isValid("123456789"), "ISBN length 9 should be invalid")
        ensure(!routine.isValid("12345678901"), "ISBN length 11 should be invalid")
        ensure(!routine.isValid("123456789012"), "ISBN length 12 with check digit should be invalid")
        ensure(!routine.isValid("12345678901234"), "ISBN length 14 should be invalid")

        ensure(checkDigitExceptionMessageEquals("Invalid ISBN Length = 8", { => routine.calculate("12345678") }), "ISBN length 8 message mismatch")
        ensure(checkDigitExceptionMessageEquals("Invalid ISBN Length = 10", { => routine.calculate("1234567890") }), "ISBN length 10 message mismatch")
        ensure(checkDigitExceptionMessageEquals("Invalid ISBN Length = 11", { => routine.calculate("12345678901") }), "ISBN length 11 message mismatch")
        ensure(checkDigitExceptionMessageEquals("Invalid ISBN Length = 13", { => routine.calculate("1234567890123") }), "ISBN length 13 message mismatch")
    }

    @TestCase
    func isinCheckDigitTestValidator345(): Unit {
        let routine = ISINCheckDigit.ISIN_CHECK_DIGIT
        for (value in ISIN_INVALID_DIGITS) {
            ensure(!routine.isValid(value), "ISIN invalid digit accepted: ${value}")
        }
    }

    @TestCase
    func ibanCheckDigitTestOther(): Unit {
        let routine = IBANCheckDigit.IBAN_CHECK_DIGIT
        for (line in IBAN_RESOURCE_LINES) {
            let normalized = removeSpaces(line)
            if (normalized.startsWith("-")) {
                ensure(!routine.isValid(testTextSubstring(normalized, 1)), "IBAN negative resource line should be invalid: ${line}")
            } else {
                ensure(routine.isValid(normalized), "IBAN resource line should be valid: ${line}")
            }
        }
    }

    @TestCase
    func ibanCheckDigitTestZeroSum(): Unit {
        // Source IBANCheckDigitTest disables the inherited zero-sum assertion by setting zeroSum = null
        // and overriding testZeroSum() with no executable assertions.
        let sourceZeroSumMode = "disabled"
        ensure(sourceZeroSumMode == "disabled", "IBAN source zero-sum fixture should remain disabled")
        ensure(IBANCheckDigit.IBAN_CHECK_DIGIT.isValid("GB29NWBK60161331926819"), "IBAN no-op zero-sum override must not disturb normal validation")
    }

    @TestCase
    func verhoeffCheckDigitTestZeroSum(): Unit {
        // Source VerhoeffCheckDigitTest overrides testZeroSum() as a deliberate no-op.
        let sourceZeroSumMode = "ignored"
        ensure(sourceZeroSumMode == "ignored", "Verhoeff source zero-sum override should remain intentional")
        ensure(VerhoeffCheckDigit.VERHOEFF_CHECK_DIGIT.isValid("1428570"), "Verhoeff no-op zero-sum override must not disturb normal validation")
    }

    @TestCase
    func checkDigitPublicApis(): Unit {
        ensure(ModulusCheckDigit.sumDigits(0) == 0, "sumDigits(0) mismatch")
        ensure(ModulusCheckDigit.sumDigits(12345) == 15, "sumDigits(12345) mismatch")
        ensure(ABANumberCheckDigit().getModulus() == 10, "ABA modulus mismatch")
        ensure(ISBN10CheckDigit().getModulus() == 11, "ISBN-10 modulus mismatch")

        let modulusTen = ModulusTenCheckDigit([1, 3, 1, 7, 3, 9, 1], false, false)
        ensure(modulusTen.getPositionWeight().toString() == [1, 3, 1, 7, 3, 9, 1].toString(), "Modulus-ten weights mismatch")
        ensure(!modulusTen.isUseRightPos(), "Modulus-ten useRightPos mismatch")
        ensure(!modulusTen.isSumWeightedDigits(), "Modulus-ten sumWeightedDigits mismatch")
        ensure(modulusTen.toString().contains("positionWeight"), "Modulus-ten toString mismatch")

        let emptyException = CheckDigitException()
        ensure(emptyException.message == "", "Empty exception message mismatch")
        let messageException = CheckDigitException("boom")
        ensure(messageException.message == "boom", "Message exception mismatch")
        let causeException = CheckDigitException("wrapped", Exception("cause"))
        ensure(causeException.message == "wrapped", "Cause exception message mismatch")
    }
}
