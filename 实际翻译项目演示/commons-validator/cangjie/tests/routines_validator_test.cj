package commons_validator_test

import std.collection.*
import std.unittest.*

import validator.routines.*

func routineEnsure(condition: Bool, message: String): Unit {
    if (!condition) {
        throw Exception(message)
    }
}

func routineEnsureSome(expected: String, actual: ?String, message: String): Unit {
    match (actual) {
        case Some(value) => routineEnsure(value == expected, "${message}: expected=${expected} actual=${value}")
        case None => throw Exception("${message}: expected Some(${expected}) actual=None")
    }
}

func routineEnsureNone(actual: ?String, message: String): Unit {
    match (actual) {
        case Some(value) => throw Exception("${message}: expected=None actual=${value}")
        case None => ()
    }
}

func routineEnsureArrayEquals(message: String, expected: ?Array<String>, actual: ?Array<String>): Unit {
    match (expected) {
        case Some(left) =>
            match (actual) {
                case Some(right) =>
                    routineEnsure(left.size == right.size, "${message}: expected-size=${left.size} actual-size=${right.size}")
                    for (i in 0..left.size) {
                        routineEnsure(left[i] == right[i], "${message}[${i}]: expected=${left[i]} actual=${right[i]}")
                    }
                case None =>
                    throw Exception("${message}: expected=${expected} actual=${actual}")
            }
        case None =>
            match (actual) {
                case Some(_) =>
                    throw Exception("${message}: expected=${expected} actual=${actual}")
                case None =>
                    ()
            }
    }
}

func routineExpectIllegalArgumentMessage(action: () -> Unit): String {
    try {
        action()
        throw Exception("Expected IllegalArgumentException")
    } catch (e: IllegalArgumentException) {
        e.message
    }
}

func routineExpectIllegalStateMessage(action: () -> Unit): String {
    try {
        action()
        throw Exception("Expected IllegalStateException")
    } catch (e: IllegalStateException) {
        e.message
    }
}

func routineExpectPatternSyntax(action: () -> Unit): Unit {
    try {
        action()
        throw Exception("Expected PatternSyntaxException")
    } catch (e: PatternSyntaxException) {
        ()
    }
}

func routineSortedLower(values: Array<String>): Bool {
    for (i in 1..values.size) {
        if (values[i - 1] > values[i] || values[i] != values[i].toAsciiLower()) {
            return false
        }
    }
    true
}

func routineUrlIncrement(testPartsIndex: Array<Int64>, testParts: Array<Array<(String, Bool)>>): Bool {
    var carry = true
    var maxIndex = true
    for (i in 0..testPartsIndex.size) {
        let reverseIndex = testPartsIndex.size - 1 - i
        var index = testPartsIndex[reverseIndex]
        let part = testParts[reverseIndex]
        if (carry) {
            if (index < part.size - 1) {
                index++
                testPartsIndex[reverseIndex] = index
                carry = false
            } else {
                testPartsIndex[reverseIndex] = 0
                carry = true
            }
        }
        maxIndex = maxIndex && index == part.size - 1
    }
    !maxIndex
}

let ROUTINE_REGEX = "^([abc]*)(?:\\-)([DEF]*)(?:\\-)([123]*)$"
let ROUTINE_COMPONENT_1 = "([abc]{3})"
let ROUTINE_COMPONENT_2 = "([DEF]{3})"
let ROUTINE_COMPONENT_3 = "([123]{3})"
let ROUTINE_SEPARATOR_1 = "(?:\\-)"
let ROUTINE_SEPARATOR_2 = "(?:\\s)"
let ROUTINE_REGEX_1 = "^" + ROUTINE_COMPONENT_1 + ROUTINE_SEPARATOR_1 + ROUTINE_COMPONENT_2 + ROUTINE_SEPARATOR_1 + ROUTINE_COMPONENT_3 + "$"
let ROUTINE_REGEX_2 = "^" + ROUTINE_COMPONENT_1 + ROUTINE_SEPARATOR_2 + ROUTINE_COMPONENT_2 + ROUTINE_SEPARATOR_2 + ROUTINE_COMPONENT_3 + "$"
let ROUTINE_REGEX_3 = "^" + ROUTINE_COMPONENT_1 + ROUTINE_COMPONENT_2 + ROUTINE_COMPONENT_3 + "$"
let ROUTINE_MULTIPLE_REGEX = [ROUTINE_REGEX_1, ROUTINE_REGEX_2, ROUTINE_REGEX_3]

let ROUTINE_URL_SCHEME: Array<(String, Bool)> = [
    ("http://", true),
    ("ftp://", true),
    ("h3t://", true),
    ("3ht://", false),
    ("http:/", false),
    ("http:", false),
    ("http/", false),
    ("://", false)
]
let ROUTINE_URL_AUTHORITY: Array<(String, Bool)> = [
    ("www.google.com", true),
    ("www.google.com.", true),
    ("go.com", true),
    ("go.au", true),
    ("0.0.0.0", true),
    ("255.255.255.255", true),
    ("256.256.256.256", false),
    ("255.com", true),
    ("1.2.3.4.5", false),
    ("1.2.3.4.", false),
    ("1.2.3", false),
    (".1.2.3.4", false),
    ("go.a", false),
    ("go.a1a", false),
    ("go.cc", true),
    ("go.1aa", false),
    ("aaa.", false),
    (".aaa", false),
    ("aaa", false),
    ("", false)
]
let ROUTINE_URL_PORT: Array<(String, Bool)> = [
    (":80", true),
    (":65535", true),
    (":65536", false),
    (":0", true),
    ("", true),
    (":-1", false),
    (":65636", false),
    (":999999999999999999", false),
    (":65a", false)
]
let ROUTINE_URL_PATH: Array<(String, Bool)> = [
    ("/test1", true),
    ("/t123", true),
    ("/$23", true),
    ("/..", false),
    ("/../", false),
    ("/test1/", true),
    ("", true),
    ("/test1/file", true),
    ("/..//file", false),
    ("/test1//file", false)
]
let ROUTINE_URL_PATH_OPTIONS: Array<(String, Bool)> = [
    ("/test1", true),
    ("/t123", true),
    ("/$23", true),
    ("/..", false),
    ("/../", false),
    ("/test1/", true),
    ("/#", false),
    ("", true),
    ("/test1/file", true),
    ("/t123/file", true),
    ("/$23/file", true),
    ("/../file", false),
    ("/..//file", false),
    ("/test1//file", true),
    ("/#/file", false)
]
let ROUTINE_URL_QUERY: Array<(String, Bool)> = [
    ("?action=view", true),
    ("?action=edit&mode=up", true),
    ("", true)
]
let ROUTINE_URL_TEST_PARTS = [ROUTINE_URL_SCHEME, ROUTINE_URL_AUTHORITY, ROUTINE_URL_PORT, ROUTINE_URL_PATH, ROUTINE_URL_QUERY]
let ROUTINE_URL_TEST_PARTS_OPTIONS = [ROUTINE_URL_SCHEME, ROUTINE_URL_AUTHORITY, ROUTINE_URL_PORT, ROUTINE_URL_PATH_OPTIONS, ROUTINE_URL_QUERY]

let ROUTINE_SCHEMES = ["http", "gopher", "g0-To+.", "not_valid"]
let ROUTINE_SCHEME_RESULTS: Array<(String, Bool)> = [
    ("http", true),
    ("ftp", false),
    ("httpd", false),
    ("gopher", true),
    ("g0-to+.", true),
    ("not_valid", false),
    ("HtTp", true),
    ("telnet", false)
]

@Test
class RoutinesRegexTranslatedTest {
    @TestCase
    func regexExceptions(): Unit {
        routineExpectPatternSyntax({ => RegexValidator("^([abCD12]*$") })
    }

    @TestCase
    func regexGetPatternsAndStrings(): Unit {
        let validator = RegexValidator(ROUTINE_MULTIPLE_REGEX)
        routineEnsure(validator.getPatterns().size == 3, "pattern count")
        routineEnsureArrayEquals("regex strings", Some(ROUTINE_MULTIPLE_REGEX), Some(validator.getRegexStrings()))
    }

    @TestCase
    func regexMissingInputs(): Unit {
        let emptyNullableRegexs: Array<?String> = []
        routineEnsure(routineExpectIllegalArgumentMessage({ => RegexValidator(None<String>) }) == "Regular expression[0] is missing", "single null")
        routineEnsure(routineExpectIllegalArgumentMessage({ => RegexValidator("") }) == "Regular expression[0] is missing", "single empty")
        routineEnsure(routineExpectIllegalArgumentMessage({ => RegexValidator(None<Array<String>>) }) == "Regular expressions are missing", "null array")
        routineEnsure(routineExpectIllegalArgumentMessage({ => RegexValidator(emptyNullableRegexs) }) == "Regular expressions are missing", "empty array")
        routineEnsure(routineExpectIllegalArgumentMessage({ => RegexValidator([Some("ABC"), None<String>]) }) == "Regular expression[1] is missing", "array has null")
        routineEnsure(routineExpectIllegalArgumentMessage({ => RegexValidator([Some(""), Some("ABC")]) }) == "Regular expression[0] is missing", "array has empty")
    }

    @TestCase
    func regexInsensitiveAndSensitive(): Unit {
        let insensitive = RegexValidator(ROUTINE_MULTIPLE_REGEX, false)
        let insensitiveFirst = RegexValidator(ROUTINE_REGEX_1, false)
        let insensitiveSecond = RegexValidator(ROUTINE_REGEX_2, false)
        let insensitiveThird = RegexValidator(ROUTINE_REGEX_3, false)
        let insensitiveValue = "AAC FDE 321"
        routineEnsure(insensitive.isValid(Some(insensitiveValue)), "insensitive multiple valid")
        routineEnsure(!insensitiveFirst.isValid(Some(insensitiveValue)), "insensitive first invalid")
        routineEnsure(insensitiveSecond.isValid(Some(insensitiveValue)), "insensitive second valid")
        routineEnsure(!insensitiveThird.isValid(Some(insensitiveValue)), "insensitive third invalid")
        routineEnsureSome("AACFDE321", insensitive.validate(Some(insensitiveValue)), "insensitive validate")
        routineEnsureNone(insensitiveFirst.validate(Some(insensitiveValue)), "insensitive first validate")
        routineEnsureSome("AACFDE321", insensitiveSecond.validate(Some(insensitiveValue)), "insensitive second validate")
        routineEnsureArrayEquals("insensitive match", Some(["AAC", "FDE", "321"]), insensitive.`match`(Some(insensitiveValue)))
        routineEnsureArrayEquals("insensitive second match", Some(["AAC", "FDE", "321"]), insensitiveSecond.`match`(Some(insensitiveValue)))
        routineEnsureArrayEquals("insensitive invalid match", None<Array<String>>, insensitive.`match`(Some("AAC*FDE*321")))

        let sensitive = RegexValidator(ROUTINE_MULTIPLE_REGEX)
        let sensitiveValue = "aac FDE 321"
        routineEnsure(sensitive.isValid(Some(sensitiveValue)), "sensitive multiple valid")
        routineEnsureSome("aacFDE321", sensitive.validate(Some(sensitiveValue)), "sensitive validate")
        routineEnsureArrayEquals("sensitive match", Some(["aac", "FDE", "321"]), sensitive.`match`(Some(sensitiveValue)))
        routineEnsure(!sensitive.isValid(Some("AAC*FDE*321")), "sensitive invalid")
    }

    @TestCase
    func regexSingleAndNull(): Unit {
        let sensitive = RegexValidator(ROUTINE_REGEX)
        let insensitive = RegexValidator(ROUTINE_REGEX, false)
        routineEnsure(!sensitive.isValid(None<String>), "single null valid")
        routineEnsureNone(sensitive.validate(None<String>), "single null validate")
        routineEnsureArrayEquals("single null match", None<Array<String>>, sensitive.`match`(None<String>))
        routineEnsure(sensitive.isValid(Some("ac-DE-1")), "single sensitive valid")
        routineEnsure(!sensitive.isValid(Some("AB-de-1")), "single sensitive invalid")
        routineEnsure(insensitive.isValid(Some("AB-de-1")), "single insensitive valid")
        routineEnsure(!insensitive.isValid(Some("ABd-de-1")), "single insensitive invalid")
        routineEnsureSome("acDE1", sensitive.validate(Some("ac-DE-1")), "single sensitive validate")
        routineEnsureArrayEquals("single sensitive match", Some(["ac", "DE", "1"]), sensitive.`match`(Some("ac-DE-1")))
        routineEnsureSome("ABC", RegexValidator("^([A-Z]*)$").validate(Some("ABC")), "single one-group validate")
        routineEnsureArrayEquals("single one-group match", Some(["ABC"]), RegexValidator("^([A-Z]*)$").`match`(Some("ABC")))
        routineEnsure(RegexValidator(ROUTINE_REGEX).toString() == "RegexValidator{" + ROUTINE_REGEX + "}", "regex tostring single")
        routineEnsure(RegexValidator(ROUTINE_REGEX, ROUTINE_REGEX).toString() == "RegexValidator{" + ROUTINE_REGEX + "," + ROUTINE_REGEX + "}", "regex tostring multiple")
    }
}

@Test
class RoutinesDomainTranslatedTest {
    @TestCase
    func domainCoreValidation(): Unit {
        DomainValidator.resetForTests()
        let validator = DomainValidator.getInstance()
        let noLocal = DomainValidator.getInstance(false)
        let allowLocal = DomainValidator.getInstance(true)
        routineEnsure(validator == noLocal, "default and explicit no-local validator should match")
        routineEnsure(!noLocal.isValid(Some("localhost.localdomain")), "localhost.localdomain should be invalid by default")
        routineEnsure(!noLocal.isValid(Some("localhost")), "localhost should be invalid by default")
        routineEnsure(allowLocal.isValid(Some("localhost.localdomain")), "localhost.localdomain should be valid when local allowed")
        routineEnsure(allowLocal.isValid(Some("localhost")), "localhost should be valid when local allowed")
        routineEnsure(allowLocal.isValid(Some("hostname")), "hostname should be valid when local allowed")
        routineEnsure(allowLocal.isValid(Some("apache.org")), "apache.org should validate")
        routineEnsure(!allowLocal.isValid(Some(" apache.org ")), "spaced domain should fail")
    }

    @TestCase
    func domainArraysUnicodeAndSyntax(): Unit {
        DomainValidator.resetForTests()
        let validator = DomainValidator.getInstance()
        routineEnsure(routineSortedLower(DomainValidator.getTLDEntries(ArrayType.COUNTRY_CODE_RO)), "country code tlds sorted")
        routineEnsure(routineSortedLower(DomainValidator.getTLDEntries(ArrayType.GENERIC_RO)), "generic tlds sorted")
        routineEnsure(routineSortedLower(DomainValidator.getTLDEntries(ArrayType.INFRASTRUCTURE_RO)), "infra tlds sorted")
        routineEnsure(DomainValidator.getTLDEntries(ArrayType.LOCAL_RO).size > 0, "local tlds present")
        routineEnsure(validator.isValidDomainSyntax("a"), "domain syntax a")
        routineEnsure(validator.isValidDomainSyntax("9"), "domain syntax 9")
        routineEnsure(validator.isValidDomainSyntax("c-z"), "domain syntax c-z")
        routineEnsure(!validator.isValidDomainSyntax("c-"), "domain syntax c- invalid")
        routineEnsure(!validator.isValidDomainSyntax("-c"), "domain syntax -c invalid")
        routineEnsure(validator.isValid(Some("www.xn--bcher-kva.ch")), "xn-- punycode domain")
        routineEnsure(validator.isValid(Some("www.bücher.ch")), "unicode domain")
        routineEnsure(validator.isValid(Some("президент.рф")), "unicode cctld")
        routineEnsure(!validator.isValid(Some("www.\u{FFFD}.ch")), "replacement char domain invalid")
    }

    @TestCase
    func domainInvalidValidAndAscii(): Unit {
        DomainValidator.resetForTests()
        let validator = DomainValidator.getInstance()
        for (item in [".org", " apache.org ", "apa che.org", "-testdomain.name", "testdomain-.name", "---c.com", "c--.com", "apache.rog", "http://www.apache.org", " "]) {
            routineEnsure(!validator.isValid(Some(item)), "invalid domain should fail: ${item}")
        }
        routineEnsure(!validator.isValid(None<String>), "null domain invalid")
        for (item in ["apache.org", "www.google.com", "test-domain.com", "test---domain.com", "test-d-o-m-ain.com", "as.uk", "ApAchE.Org", "z.com", "i.have.an-example.domain.name"]) {
            routineEnsure(validator.isValid(Some(item)), "valid domain should pass: ${item}")
        }
        for (item in ["a.ch", "9.ch", "az.ch", "09.ch", "9-1.ch"]) {
            routineEnsure(validator.isValid(Some(item)), "rfc2396 domain label valid: ${item}")
        }
        for (item in ["91-.ch", "-.ch"]) {
            routineEnsure(!validator.isValid(Some(item)), "rfc2396 domain label invalid: ${item}")
        }
        for (item in ["a.c", "a.cc", "a.c9", "a.c-9", "a.c-z"]) {
            routineEnsure(validator.isValidDomainSyntax(item), "rfc2396 toplabel valid: ${item}")
        }
        for (item in ["a.9c", "a.c-", "a.-", "a.-9"]) {
            routineEnsure(!validator.isValidDomainSyntax(item), "rfc2396 toplabel invalid: ${item}")
        }
        routineEnsure(validator.isValidInfrastructureTld(".arpa"), "arpa infra")
        routineEnsure(!validator.isValidInfrastructureTld(".com"), "com not infra")
        routineEnsure(validator.isValidGenericTld(".name"), "name generic")
        routineEnsure(!validator.isValidGenericTld(".us"), "us not generic")
        routineEnsure(validator.isValidCountryCodeTld(".uk"), "uk cc")
        routineEnsure(!validator.isValidCountryCodeTld(".org"), "org not cc")
        routineEnsure(validator.isValidTld(".COM"), "COM tld")
        routineEnsure(validator.isValidTld(".BiZ"), "BiZ tld")
        routineEnsure(!validator.isValid(Some(".nope")), "nope tld invalid")
        routineEnsure(DomainValidator.unicodeToASCII("") == "", "unicodeToASCII empty")
        routineEnsure(DomainValidator.unicodeToASCII(".") == ".", "unicodeToASCII dot")
        routineEnsure(DomainValidator.unicodeToASCII("a.") == "a.", "unicodeToASCII trailing dot")
        routineEnsure(DomainValidator.unicodeToASCII("b。") == "b.", "unicodeToASCII ideographic full stop")
        routineEnsure(DomainValidator.unicodeToASCII("b．") == "b.", "unicodeToASCII fullwidth full stop")
        routineEnsure(DomainValidator.unicodeToASCII("b｡") == "b.", "unicodeToASCII halfwidth ideographic full stop")
    }

    @TestCase
    func domainLengthAndOverrides(): Unit {
        DomainValidator.resetForTests()
        let validator = DomainValidator.getInstance()
        let longString = "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789A"
        routineEnsure(longString.size == 63, "long label size")
        routineEnsure(validator.isValidDomainSyntax(longString + ".com"), "63-char label valid")
        routineEnsure(!validator.isValidDomainSyntax(longString + "x.com"), "64-char label invalid")
        routineEnsure(validator.isValidDomainSyntax("test." + longString), "63-char tld valid")
        routineEnsure(!validator.isValidDomainSyntax("test.x" + longString), "64-char tld invalid")
        let longDomain = longString + "." + longString + "." + longString + "." + longString[0..61]
        routineEnsure(longDomain.size == 253, "long domain size")
        routineEnsure(validator.isValidDomainSyntax(longDomain), "253-char domain valid")
        routineEnsure(!validator.isValidDomainSyntax(longDomain + "x"), "254-char domain invalid")

        DomainValidator.resetForTests()
        DomainValidator.updateTLDOverride(ArrayType.GENERIC_PLUS, "gp")
        DomainValidator.updateTLDOverride(ArrayType.GENERIC_MINUS, "com")
        DomainValidator.updateTLDOverride(ArrayType.COUNTRY_CODE_PLUS, "cp")
        DomainValidator.updateTLDOverride(ArrayType.COUNTRY_CODE_MINUS, "ch")
        let overridden = DomainValidator.getInstance(false)
        routineEnsure(overridden.isValidGenericTld("gp"), "override gp valid")
        routineEnsure(!overridden.isValidGenericTld("com"), "override com invalid")
        routineEnsure(overridden.isValidCountryCodeTld("cp"), "override cp valid")
        routineEnsure(!overridden.isValidCountryCodeTld("ch"), "override ch invalid")

        let items = ArrayList<Item>()
        items.add(Item(ArrayType.GENERIC_MINUS, ""))
        items.add(Item(ArrayType.COUNTRY_CODE_MINUS, ""))
        let instanceOverride = DomainValidator.getInstance(false, items)
        routineEnsure(instanceOverride.isValidGenericTld("com"), "instance override restores com")
        routineEnsure(instanceOverride.isValidCountryCodeTld("ch"), "instance override restores ch")
    }

    @TestCase
    func domainStartupGuards(): Unit {
        DomainValidator.resetForTests()
        DomainValidator.updateTLDOverride(ArrayType.GENERIC_PLUS, "ch")
        let dv = DomainValidator.getInstance()
        routineEnsure(dv != DomainValidator.getInstance(true), "different validators should not match")
        routineEnsure(routineExpectIllegalStateMessage({ => DomainValidator.updateTLDOverride(ArrayType.GENERIC_PLUS, "ch") }) == "Can only invoke this method before calling getInstance", "update after getInstance guard")

        DomainValidator.resetForTests()
        routineEnsure(routineExpectIllegalArgumentMessage({ => DomainValidator.updateTLDOverride(ArrayType.COUNTRY_CODE_RO, "com") }) == "Cannot update the table: COUNTRY_CODE_RO", "readonly cc table")
        routineEnsure(routineExpectIllegalArgumentMessage({ => DomainValidator.updateTLDOverride(ArrayType.GENERIC_RO, "com") }) == "Cannot update the table: GENERIC_RO", "readonly generic table")
        routineEnsure(routineExpectIllegalArgumentMessage({ => DomainValidator.updateTLDOverride(ArrayType.INFRASTRUCTURE_RO, "com") }) == "Cannot update the table: INFRASTRUCTURE_RO", "readonly infra table")
        routineEnsure(routineExpectIllegalArgumentMessage({ => DomainValidator.updateTLDOverride(ArrayType.LOCAL_RO, "com") }) == "Cannot update the table: LOCAL_RO", "readonly local table")

        DomainValidator.resetForTests()
        routineEnsure(!DomainValidator.getInstance().isValidCountryCodeTld("com"), "country-code com initially invalid")
        DomainValidator.resetForTests()
        DomainValidator.updateTLDOverride(ArrayType.COUNTRY_CODE_PLUS, "com")
        routineEnsure(DomainValidator.getInstance().isValidCountryCodeTld("com"), "country-code com overridden valid")

        DomainValidator.resetForTests()
        DomainValidator.updateTLDOverride(ArrayType.GENERIC_PLUS, "local", "pvt")
        let genericLocal = DomainValidator.getInstance()
        routineEnsure(genericLocal.isValidGenericTld("local"), "generic local valid")
        routineEnsure(genericLocal.isValid(Some("abc.local")), "abc.local generic valid")

        DomainValidator.resetForTests()
        let localDenied = DomainValidator.getInstance(true)
        routineEnsure(!localDenied.isValidLocalTld("local"), "local tld denied by default")

        DomainValidator.resetForTests()
        DomainValidator.updateTLDOverride(ArrayType.LOCAL_PLUS, "local", "pvt")
        let localAllowed = DomainValidator.getInstance(true)
        routineEnsure(localAllowed.isValidLocalTld("local"), "local tld allowed")
        routineEnsure(localAllowed.isValid(Some("abc.local")), "abc.local local valid")
    }
}

@Test
class RoutinesEmailTranslatedTest {
    @TestCase
    func emailBasicAndOverrides(): Unit {
        DomainValidator.resetForTests()
        let validator = EmailValidator.getInstance()
        routineEnsure(validator.isValid(Some("jsmith@apache.org")), "basic email valid")
        routineEnsure(EmailValidator.getInstance(false, true).isValid(Some("test@com")), "email at tld valid")
        routineEnsure(EmailValidator.getInstance(true).isValid(Some("joe@localhost")), "allow local localhost")
        routineEnsure(!EmailValidator.getInstance(false).isValid(Some("joe@localhost")), "disallow local localhost")
        routineEnsure(!validator.isValid(Some("jsmith@apache.")), "trailing dot invalid")
        routineEnsure(!validator.isValid(Some("jsmith@apache.c")), "short tld invalid")
        routineEnsure(validator.isValid(Some("someone@yahoo.museum")), "museum tld valid")
        routineEnsure(!validator.isValid(Some("someone@yahoo.mu-seum")), "hyphenated tld invalid")

        let domainItems = ArrayList<Item>()
        routineEnsure(routineExpectIllegalArgumentMessage({ => EmailValidator(false, false, None<DomainValidator>) }) == "DomainValidator cannot be null", "null domain validator rejected")
        routineEnsure(routineExpectIllegalArgumentMessage({ => EmailValidator(false, false, Some(DomainValidator.getInstance(true, domainItems))) }) == "DomainValidator must agree with allowLocal setting", "mismatched allowLocal false")
        routineEnsure(routineExpectIllegalArgumentMessage({ => EmailValidator(true, false, Some(DomainValidator.getInstance(false, domainItems))) }) == "DomainValidator must agree with allowLocal setting", "mismatched allowLocal true")

        DomainValidator.resetForTests()
        let base = EmailValidator.getInstance()
        routineEnsure(!base.isValid(Some("user@test.local")), "test.local initially invalid")
        let items = ArrayList<Item>()
        items.add(Item(ArrayType.GENERIC_PLUS, "local"))
        let overrideValidator = EmailValidator(true, false, Some(DomainValidator.getInstance(true, items)))
        routineEnsure(overrideValidator.isValid(Some("user@test.local")), "test.local overridden valid")
    }

    @TestCase
    func emailUsernamesAndEdgeCases(): Unit {
        DomainValidator.resetForTests()
        let validator = EmailValidator.getInstance()
        for (item in ["joe1blow@apache.org", "joe$blow@apache.org", "joe-@apache.org", "joe_@apache.org", "joe+@apache.org", "joe!@apache.org", "joe*@apache.org", "joe'@apache.org", "joe%45@apache.org", "joe?@apache.org", "joe&@apache.org", "joe=@apache.org", "+joe@apache.org", "!joe@apache.org", "*joe@apache.org", "'joe@apache.org", "%joe45@apache.org", "?joe@apache.org", "&joe@apache.org", "=joe@apache.org", "+@apache.org", "!@apache.org", "*@apache.org", "'@apache.org", "%@apache.org", "?@apache.org", "&@apache.org", "=@apache.org", "joe.ok@apache.org", "\"joe.\"@apache.org", "\".joe\"@apache.org", "\"joe+\"@apache.org", "\"joe@\"@apache.org", "\"joe!\"@apache.org", "\"joe*\"@apache.org", "\"joe'\"@apache.org", "\"joe(\"@apache.org", "\"joe)\"@apache.org", "\"joe,\"@apache.org", "\"joe%45\"@apache.org", "\"joe;\"@apache.org", "\"joe?\"@apache.org", "\"joe&\"@apache.org", "\"joe=\"@apache.org", "\"..\"@apache.org", "\"john\\\"doe\"@apache.org", "john56789.john56789.john56789.john56789.john56789.john56789.john@example.com", "\\>escape\\\\special\\^characters\\<@example.com", "Abc\\@def@example.com", "space\\ monkey@example.com"]) {
            routineEnsure(validator.isValid(Some(item)), "expected valid email: ${item}")
        }
        for (item in ["joe.@apache.org", ".joe@apache.org", ".@apache.org", "joe..ok@apache.org", "..@apache.org", "joe(@apache.org", "joe)@apache.org", "joe,@apache.org", "joe;@apache.org", "Abc@def@example.com"]) {
            routineEnsure(!validator.isValid(Some(item)), "expected invalid email: ${item}")
        }
        routineEnsure(!validator.isValid(Some("john56789.john56789.john56789.john56789.john56789.john56789.john5@example.com")), "65-char local-part invalid")
    }

    @TestCase
    func emailAdditionalCases(): Unit {
        DomainValidator.resetForTests()
        let validator = EmailValidator.getInstance()
        for (item in ["andy.o'reilly@data-workshop.com", "foo+bar@i.am.not.in.us.example.com", "someone@[216.109.118.76]", "someone@yahoo.com", "joe!/blow@apache.org", "\"joeblow \"@apache.org", "\" joeblow\"@apache.org", "\" joe blow \"@apache.org", "someone@xn--d1abbgf6aiiy.xn--p1ai", "someone@президент.рф", "someone@www.bücher.ch", "abc-@abc.com", "abc_@abc.com", "abc-def@abc.com", "abc_def@abc.com", "me@att.net", "abc@school.school"]) {
            routineEnsure(validator.isValid(Some(item)), "expected valid email: ${item}")
        }
        for (item in ["andy.noble@\u{008F}data-workshop.com", "andy@o'reilly.data-workshop.com", "foo+bar@example+3.com", "test@%*.com", "test@^&#.com", "joeblow@apa,che.org", "joeblow@apache.o,rg", "joeblow@apache,org", "andy-noble@data-workshop.-com", "andy-noble@data-workshop.c-om", "andy-noble@data-workshop.co-m", "andy.noble@data-workshop.com.", "joe@ap/ache.org", "joe@apac!he.org", "joeblow @apache.org", "joeblow@ apache.org", " joeblow@apache.org", "joeblow@apache.org ", "joe blow@apache.org ", "joeblow@apa che.org ", "someone@www.\u{FFFD}.ch", "someone@-test.com", "someone@test-.com", "abc@abc_def.com", "me@at&t.net", "test@.com"]) {
            routineEnsure(!validator.isValid(Some(item)), "expected invalid email: ${item}")
        }
        for (item in ["foo\tbar@domain.com", "foo\nbar@domain.com", "foo\rbar@domain.com"]) {
            routineEnsure(!validator.isValid(Some(item)), "control-char email invalid: ${item}")
        }
        routineEnsure(!validator.isValid(Some(
            "Loremipsumdolorsitametconsecteturadipiscingelit.Nullavitaeligulamattisrhoncusnuncegestasmattisleo." +
            "Donecnonsapieninmagnatristiquedictumaacturpis.Fusceorciduifacilisisutsapieneuconsequatpharetralectus." +
            "Quisqueenimestpulvinarutquamvitaeportamattisex.Nullamquismaurisplaceratconvallisjustoquisportamauris." +
            "Innullalacusconvalliseufringillautvenenatissitametdiam.Maecenasluctusligulascelerisquepulvinarfeugiat." +
            "Sedmolestienullaaliquetorciluctusidpharetranislfinibus.Suspendissemalesuadatinciduntduisitametportaarcusollicitudinnec." +
            "Donecetmassamagna.Curabitururnadiampretiumveldignissimporttitorfringillaeuneque." +
            "Duisantetelluspharetraidtinciduntinterdummolestiesitametfelis.Utquisquamsitametantesagittisdapibusacnonodio." +
            "Namrutrummolestiediamidmattis.Cumsociisnatoquepenatibusetmagnisdisparturientmontesnasceturridiculusmus." +
            "Morbiposueresedmetusacconsectetur.Etiamquisipsumvitaejustotempusmaximus.Sedultriciesplaceratvolutpat." +
            "Integerlacuslectusmaximusacornarequissagittissitametjusto." +
            "Cumsociisnatoquepenatibusetmagnisdisparturientmontesnasceturridiculusmus.Maecenasindictumpurussedrutrumex.Nullafacilisi." +
            "Integerfinibusfinibusmietpharetranislfaucibusvel.Maecenasegetdolorlacinialobortisjustovelullamcorpersem." +
            "Vivamusaliquetpurusidvariusornaresapienrisusrutrumnisitinciduntmollissemnequeidmetus." +
            "Etiamquiseleifendpurus.Nuncfelisnuncscelerisqueiddignissimnecfinibusalibero." +
            "Nuncsemperenimnequesitamethendreritpurusfacilisisac.Maurisdapibussemperfelisdignissimgravida." +
            "Aeneanultricesblanditnequealiquamfinibusodioscelerisqueac.Aliquamnecmassaeumaurisfaucibusfringilla." +
            "Etiamconsequatligulanisisitametaliquamnibhtemporquis.Nuncinterdumdignissimnullaatsodalesarcusagittiseu." +
            "Proinpharetrametusneclacuspulvinarsedvolutpatliberoornare.Sedligulanislpulvinarnonlectuseublanditfacilisisante." +
            "Sedmollisnislalacusauctorsuscipit.Inhachabitasseplateadictumst.Phasellussitametvelittemporvenenatisfeliseuegestasrisus." +
            "Aliquameteratsitametnibhcommodofinibus.Morbiefficiturodiovelpulvinariaculis." +
            "Aeneantemporipsummassaaconsecteturturpisfaucibusultrices.Praesentsodalesmaurisquisportafermentum." +
            "Etiamnisinislvenenatisvelauctorutullamcorperinjusto.Proinvelligulaerat.Phasellusvestibulumgravidamassanonfeugiat." +
            "Maecenaspharetraeuismodmetusegetefficitur.Suspendisseamet@gmail.com"
        )), "very long local part invalid")
    }
}

@Test
class RoutinesUrlTranslatedTest {
    @TestCase
    func urlFragmentsPermutationAndSchemes(): Unit {
        let schemes = ["http", "https"]
        routineEnsure(!UrlValidator(schemes, UrlValidator.NO_FRAGMENTS).isValid(Some("http://apache.org/a/b/c#frag")), "fragment rejected")
        routineEnsure(UrlValidator(schemes).isValid(Some("http://apache.org/a/b/c#frag")), "fragment accepted")

        var indexes = [0, 0, 0, 0, 0]
        let validator = UrlValidator(None<Array<String>>, None<RegexValidator>, UrlValidator.ALLOW_ALL_SCHEMES)
        routineEnsure(validator.isValid(Some("http://www.google.com")), "simple url valid")
        routineEnsure(validator.isValid(Some("http://www.google.com/")), "simple url slash valid")
        do {
            var url = ""
            var expected = true
            for (i in 0..ROUTINE_URL_TEST_PARTS.size) {
                let part = ROUTINE_URL_TEST_PARTS[i][indexes[i]]
                url += part[0]
                expected = expected && part[1]
            }
            routineEnsure(validator.isValid(Some(url)) == expected, "url permutation mismatch: ${url}")
        } while (routineUrlIncrement(indexes, ROUTINE_URL_TEST_PARTS))

        indexes = [0, 0, 0, 0, 0]
        let validatorWithOptions = UrlValidator(None<Array<String>>, None<RegexValidator>, UrlValidator.ALLOW_2_SLASHES + UrlValidator.ALLOW_ALL_SCHEMES + UrlValidator.NO_FRAGMENTS)
        do {
            var url = ""
            var expected = true
            for (i in 0..ROUTINE_URL_TEST_PARTS_OPTIONS.size) {
                let part = ROUTINE_URL_TEST_PARTS_OPTIONS[i][indexes[i]]
                url += part[0]
                expected = expected && part[1]
            }
            routineEnsure(validatorWithOptions.isValid(Some(url)) == expected, "url option permutation mismatch: ${url}")
        } while (routineUrlIncrement(indexes, ROUTINE_URL_TEST_PARTS_OPTIONS))

        let schemeValidator = UrlValidator(ROUTINE_SCHEMES, 0)
        for (entry in ROUTINE_SCHEME_RESULTS) {
            routineEnsure(schemeValidator.isValidScheme(Some(entry[0])) == entry[1], "scheme mismatch: ${entry[0]}")
        }
    }

    @TestCase
    func urlSpecialCases(): Unit {
        let validator = UrlValidator()
        routineEnsure(validator.isValid(Some("http://l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.l.org")), "validator202")
        routineEnsure(validator.isValid(Some("http://tech.yahoo.com/rc/desktops/102;_ylt=Ao8yevQHlZ4On0O3ZJGXLEQFLZA5")), "validator204")
        routineEnsure(UrlValidator(UrlValidator.ALLOW_2_SLASHES).isValid(Some("http://somewhere.com/pathxyz/file(1).html")), "validator218")
        routineEnsure(validator.isValid(Some("http://xn--d1abbgf6aiiy.xn--p1ai")), "validator235 punycode")
        routineEnsure(validator.isValid(Some("http://президент.рф")), "validator235 unicode")
        routineEnsure(validator.isValid(Some("http://www.bücher.ch")), "validator235 unicode umlaut")
        routineEnsure(!validator.isValid(Some("http://www.\u{FFFD}.ch")), "validator235 invalid replacement")
        routineEnsure(!validator.isValid(Some("http://finance.yahoo.com/news/Owners-54B-NY-housing-apf-2493139299.html?x=0&ap=%fr")), "validator283 invalid percent")
        routineEnsure(validator.isValid(Some("http://finance.yahoo.com/news/Owners-54B-NY-housing-apf-2493139299.html?x=0&ap=%22")), "validator283 valid percent")
        routineEnsure(validator.isValid(Some("http://xn--h1acbxfam.idn.icann.org/")), "validator290 idn icann")
        for (item in ["http://test.xn--lgbbat1ad8j", "http://test.xn--fiqs8s", "http://test.xn--fiqz9s", "http://test.xn--wgbh1c", "http://test.xn--j6w193g", "http://test.xn--h2brj9c", "http://test.xn--mgbbh1a71e", "http://test.xn--p1ai", "http://test.xn--90a3ac", "http://test.xn--3e0b707e"]) {
            routineEnsure(validator.isValid(Some(item)), "validator290 tld should validate: ${item}")
        }
        routineEnsure(validator.isValid(Some("http://sample.ondemand.com/")), "validator309 lowercase")
        routineEnsure(validator.isValid(Some("hTtP://sample.ondemand.CoM/")), "validator309 mixed case")
        routineEnsure(validator.isValid(Some("httpS://SAMPLE.ONEMAND.COM/")), "validator309 uppercase")
        routineEnsure(UrlValidator(["HTTP", "HTTPS"]).isValid(Some("http://sample.ondemand.com/")), "validator309 explicit schemes")
    }

    @TestCase
    func urlAuthorityPathAndFileCases(): Unit {
        let regex = RegexValidator("localhost", ".*\\.my-testing")
        var validator = UrlValidator(regex, 0)
        routineEnsure(validator.isValid(Some("http://localhost/test/index.html")), "validator248 localhost")
        routineEnsure(validator.isValid(Some("http://first.my-testing/test/index.html")), "validator248 custom hostname")
        routineEnsure(!validator.isValid(Some("http://broke.my-test/test/index.html")), "validator248 invalid custom hostname")
        routineEnsure(validator.isValid(Some("http://www.apache.org/test/index.html")), "validator248 standard domain still valid")

        validator = UrlValidator(UrlValidator.ALLOW_LOCAL_URLS)
        routineEnsure(validator.isValid(Some("http://localhost/test/index.html")), "validator248 allow local localhost")
        routineEnsure(validator.isValid(Some("http://machinename/test/index.html")), "validator248 allow local machinename")

        validator = UrlValidator(["http", "file"], UrlValidator.ALLOW_LOCAL_URLS)
        routineEnsure(validator.isValid(Some("file:///C:/some.file")), "validator276 file drive")
        routineEnsure(!validator.isValid(Some("file:///C:\\some.file")), "validator276 backslash file")
        routineEnsure(validator.isValid(Some("file:///etc/hosts")), "validator276 unix file")
        routineEnsure(validator.isValid(Some("file://localhost/etc/hosts")), "validator276 localhost file")
        routineEnsure(validator.isValid(Some("file://localhost/c:/some.file")), "validator276 localhost drive")
        routineEnsure(!validator.isValid(Some("file://C:/some.file")), "validator276 malformed file authority")

        let localValidator = UrlValidator(UrlValidator.ALLOW_LOCAL_URLS)
        routineEnsure(localValidator.isValid(Some("http://hostname")), "validator288 hostname valid")
        routineEnsure(localValidator.isValid(Some("http://hostname/test/index.html")), "validator288 hostname path valid")
        routineEnsure(!localValidator.isValid(Some("http://first.my-testing/test/index.html")), "validator288 custom suffix invalid")
        routineEnsure(UrlValidator(0).isValid(Some("http://www.apache.org/test/index.html")), "validator288 global domain still valid")
        routineEnsure(!UrlValidator(0).isValid(Some("http://hostname")), "validator288 hostname invalid without local")
    }

    @TestCase
    func urlMoreValidatorCases(): Unit {
        let validator = UrlValidator()
        for (item in ["http://www.cnn.com/WORLD/?hpt=sitenav", "http://www.cnn.com./WORLD/?hpt=sitenav", "http://президент.рф/WORLD/?hpt=sitenav", "http://президент.рф./WORLD/?hpt=sitenav", "http://example.rocks/", "http://example.rocks", "http://www.apache.org:80/path", "http://user:pass@www.apache.org:80/path", "http://user:@www.apache.org:80/path", "http://user@www.apache.org:80/path", "http://us%00er:-._~!$&'()*+,;=@www.apache.org:80/path", "http://hello.tokyo/", "http://www.example.org/a/b/hello..world", "http://www.example.org/hello.world", "http://www.example.org/hello..world", "http://www.example.org/.../world", "http://www.example.org/...", "http://www.example.org/.../", "http://www.example.org/.../..", "http://[FEDC:BA98:7654:3210:FEDC:BA98:7654:3210]:80/index.html", "http://[::1]:80/index.html", "ftp://username:password@example.com:8042/over/there/index.dtb?type=animal&name=narwhal#nose", "http://example.rocks:/", "http://example.rocks:0/", "http://example.rocks:65535/", "http://example.com/serach?address=Main%20Avenue", "http://example.com/serach?address=Main+Avenue", "http://[::FFFF:129.144.52.38]:80/index.html"]) {
            routineEnsure(validator.isValid(Some(item)), "expected valid url: ${item}")
        }
        for (item in ["http://www.cnn.com../", "http://www.cnn.invalid/", "http://www.cnn.invalid./", "http://президент.рф..../", "http://президент.рф.../", "http://президент.рф../", "http://:pass@www.apache.org:80/path", "http://:@www.apache.org:80/path", "http://user:pa:ss@www.apache.org/path", "http://user:pa@ss@www.apache.org/path", "http://www.example.org/../world", "http://www.example.org/..", "http://www.example.org/../", "http://www.example.org/./..", "http://www.example.org/././..", "http://FEDC:BA98:7654:3210:FEDC:BA98:7654:3210:80/index.html", "http://example.rocks:65536/", "http://example.rocks:100000/", "http://example.com/serach?address=Main Avenue"]) {
            routineEnsure(!validator.isValid(Some(item)), "expected invalid url: ${item}")
        }
        let fileOnly = UrlValidator(["file"])
        routineEnsure(fileOnly.isValid(Some("file:/C:/path/to/dir/")), "validator391 file one slash")
        routineEnsure(fileOnly.isValid(Some("file:///C:/path/to/dir/")), "validator391 file three slash")
        routineEnsure(!fileOnly.isValid(Some("file://bad ^ domain.com/label/test")), "validator464 bad file authority")
        let allowDoubleSlash = UrlValidator(UrlValidator.ALLOW_2_SLASHES)
        for (item in ["https://example.com/some_path/path/", "https://example.com//somepath/path/", "https://example.com//some_path/path/", "http://example.com//_test"]) {
            routineEnsure(allowDoubleSlash.isValid(Some(item)), "validator467 allow double slash: ${item}")
        }
    }

    @TestCase
    func urlConstructorGuards(): Unit {
        DomainValidator.resetForTests()
        routineEnsure(routineExpectIllegalArgumentMessage({ => UrlValidator([], None<RegexValidator>, 0, None<DomainValidator>) }) == "DomainValidator must not be null", "null domain validator rejected")
        let items = ArrayList<Item>()
        routineEnsure(routineExpectIllegalArgumentMessage({ => UrlValidator([], None<RegexValidator>, 0, Some(DomainValidator.getInstance(true, items))) }) == "DomainValidator disagrees with ALLOW_LOCAL_URLS setting", "mismatched local false")
        DomainValidator.resetForTests()
        let items2 = ArrayList<Item>()
        routineEnsure(routineExpectIllegalArgumentMessage({ => UrlValidator([], None<RegexValidator>, UrlValidator.ALLOW_LOCAL_URLS, Some(DomainValidator.getInstance(false, items2))) }) == "DomainValidator disagrees with ALLOW_LOCAL_URLS setting", "mismatched local true")
    }

    @TestCase
    func urlValidateUrlNoopEquivalence(): Unit {
        // UrlValidatorTest.testValidateUrl is a source no-op (assertTrue(true)); keep an explicit target case.
        routineEnsure(UrlValidator.getInstance().isValid(Some("http://www.google.com")), "routines validateUrl noop equivalence")
    }
}

@Test
class RoutinesInetAddressTranslatedTest {
    @TestCase
    func inetBrokenAndClassCases(): Unit {
        let validator = InetAddressValidator()
        for (item in ["24.25.231.12", "135.14.44.12", "213.25.224.32", "229.35.159.6", "248.85.24.92", "140.211.11.130", "72.14.253.103", "199.232.41.5", "216.35.123.87", "127.0.0.1", "255.255.255.255"]) {
            routineEnsure(validator.isValid(Some(item)), "expected valid inet address: ${item}")
        }
        for (item in ["124.14.32.abc", "124.14.32.01", "23.64.12", "26.34.23.77.234", "2.41.32.324", "154.123.441.123", "201.543.23.11", "231.54.11.987", "250.21.323.48"]) {
            routineEnsure(!validator.isValid(Some(item)), "expected invalid inet address: ${item}")
        }
        routineEnsure(!validator.isValidInet6Address(Some("")), "empty ipv6 invalid")
    }

    @TestCase
    func inetIpv6RepresentativeCases(): Unit {
        let validator = InetAddressValidator()
        for (item in ["::1", "::", "0:0:0:0:0:0:0:1", "0:0:0:0:0:0:0:0", "2001:DB8:0:0:8:800:200C:417A", "FF01::101", "fe80::217:f2ff:fe07:ed62", "2::10", "ff02::1", "fe80::", "2002::", "2001:db8::", "::ffff:0:0", "1:2:3:4:5:6:7:8", "1:2:3:4:5:6::8", "1::2:3:4:5:6:7", "::2:3:4:5:6:7:8", "::8", "1:2:3:4:5:6::", "1::", "1:2:3:4:5::7:8", "1:2:3:4:5:6:1.2.3.4", "1:2:3:4:5::1.2.3.4", "1::5:11.22.33.44", "2001:0438:FFFE:0000:0000:0000:0000:0A35", "0:0:0:0:0:0:13.1.68.3", "0:0:0:0:0:FFFF:129.144.52.38", "::13.1.68.3", "::FFFF:129.144.52.38", "2001:0000:1234:0000:0000:C1C0:ABCD:0876/123", "2001:0000:1234:0000:0000:C1C0:ABCD:0876/0", "2001:0000:1234:0000:0000:C1C0:ABCD:0876%0", "2001:0000:1234:0000:0000:C1C0:ABCD:0876%abcdefgh"]) {
            routineEnsure(validator.isValidInet6Address(Some(item)), "expected valid ipv6: ${item}")
        }
        for (item in ["", "2001:DB8:0:0:8:800:200C:417A:221", "FF01::101::2", "02001:0000:1234:0000:0000:C1C0:ABCD:0876", "2001:0000:1234:0000:00001:C1C0:ABCD:0876", "2001:0000:1234:0000:0000:C1C0:ABCD:0876 0", "2001:0000:1234: 0000:0000:C1C0:ABCD:0876", "3ffe:0b00:0000:0001:0000:0000:000a", "FF02:0000:0000:0000:0000:0000:0000:0000:0001", "3ffe:b00::1::a", "::1111:2222:3333:4444:5555:6666::", "1:2:3::4:5::7:8", "12345::6:7:8", "1::5:400.2.3.4", "::ffff:192.168.1.1:192.168.1.1", "::192.168.1.1:192.168.1.1", "2001:0000:1234:0000:0000:C1C0:ABCD:0876/129", "2001:0000:1234:0000:0000:C1C0:ABCD:0876/-0", "2001:0000:1234:0000:0000:C1C0:ABCD:0876/+0", "2001:0000:1234:0000:0000:C1C0:ABCD:0876/10O", "2001:0000:1234:0000:0000:C1C0:ABCD:0876/0%0", "2001:0000:1234:0000:0000:C1C0:ABCD:0876%abc defgh", "2001:0000:1234:0000:0000:C1C0:ABCD:0876%abc%defgh", "':10.0.0.1"]) {
            routineEnsure(!validator.isValidInet6Address(Some(item)), "expected invalid ipv6: ${item}")
        }
    }
}
