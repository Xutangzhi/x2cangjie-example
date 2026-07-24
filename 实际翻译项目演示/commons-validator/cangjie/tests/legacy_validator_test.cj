package commons_validator_test

import std.unittest.*

import validator.*

let LEGACY_URL_SCHEME: Array<(String, Bool)> = [
    ("http://", true),
    ("ftp://", true),
    ("h3t://", true),
    ("3ht://", false),
    ("http:/", false),
    ("http:", false),
    ("http/", false),
    ("://", false),
    ("", true)
]
let LEGACY_URL_AUTHORITY: Array<(String, Bool)> = [
    ("www.google.com", true),
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
    ("go.a1a", true),
    ("go.1aa", false),
    ("aaa.", false),
    (".aaa", false),
    ("aaa", false),
    ("", false)
]
let LEGACY_URL_PORT: Array<(String, Bool)> = [
    (":80", true),
    (":65535", true),
    (":0", true),
    ("", true),
    (":-1", false),
    (":65636", true),
    (":65a", false)
]
let LEGACY_URL_PATH: Array<(String, Bool)> = [
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
let LEGACY_URL_PATH_OPTIONS: Array<(String, Bool)> = [
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
let LEGACY_URL_QUERY: Array<(String, Bool)> = [
    ("?action=view", true),
    ("?action=edit&mode=up", true),
    ("", true)
]
let LEGACY_URL_PARTS = [LEGACY_URL_SCHEME, LEGACY_URL_AUTHORITY, LEGACY_URL_PORT, LEGACY_URL_PATH, LEGACY_URL_QUERY]
let LEGACY_URL_PARTS_OPTIONS = [LEGACY_URL_SCHEME, LEGACY_URL_AUTHORITY, LEGACY_URL_PORT, LEGACY_URL_PATH_OPTIONS, LEGACY_URL_QUERY]
let LEGACY_SCHEME_RESULTS: Array<(String, Bool)> = [
    ("http", true),
    ("ftp", false),
    ("httpd", false),
    ("telnet", false)
]

@Test
class LegacyUrlTranslatedTest {
    @TestCase
    func legacyUrlIsValidPermutations(): Unit {
        var indexes = [0, 0, 0, 0, 0]
        let validator = UrlValidator(None<Array<String>>, UrlValidator.ALLOW_ALL_SCHEMES)
        routineEnsure(validator.isValid(Some("http://www.google.com")), "legacy google url")
        routineEnsure(validator.isValid(Some("http://www.google.com/")), "legacy google url slash")
        do {
            var url = ""
            var expected = true
            for (i in 0..LEGACY_URL_PARTS.size) {
                let part = LEGACY_URL_PARTS[i][indexes[i]]
                url += part[0]
                expected = expected && part[1]
            }
            routineEnsure(validator.isValid(Some(url)) == expected, "legacy permutation mismatch: ${url}")
        } while (routineUrlIncrement(indexes, LEGACY_URL_PARTS))

        indexes = [0, 0, 0, 0, 0]
        let optionValidator = UrlValidator(None<Array<String>>, UrlValidator.ALLOW_2_SLASHES + UrlValidator.ALLOW_ALL_SCHEMES + UrlValidator.NO_FRAGMENTS)
        do {
            var url = ""
            var expected = true
            for (i in 0..LEGACY_URL_PARTS_OPTIONS.size) {
                let part = LEGACY_URL_PARTS_OPTIONS[i][indexes[i]]
                url += part[0]
                expected = expected && part[1]
            }
            routineEnsure(optionValidator.isValid(Some(url)) == expected, "legacy option permutation mismatch: ${url}")
        } while (routineUrlIncrement(indexes, LEGACY_URL_PARTS_OPTIONS))
    }

    @TestCase
    func legacyUrlSchemeAndValidators(): Unit {
        let validator = UrlValidator(Some(["http", "gopher"]), 0)
        for (entry in LEGACY_SCHEME_RESULTS) {
            routineEnsure(validator.isValidScheme(Some(entry[0])) == entry[1], "legacy scheme mismatch: ${entry[0]}")
        }
        routineEnsure(validator.isValid(Some("http://www.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.logoworks.comwww.log")), "legacy validator202 long domain")
        routineEnsure(UrlValidator(Some(["http", "https"]), 0).isValid(Some("http://tech.yahoo.com/rc/desktops/102;_ylt=Ao8yevQHlZ4On0O3ZJGXLEQFLZA5")), "legacy validator204")
    }

    @TestCase
    func legacyUrlValidateUrlNoopEquivalence(): Unit {
        // UrlTest.testValidateUrl is a source no-op (assertTrue(true)); keep an explicit target case.
        routineEnsure(UrlValidator(None<Array<String>>, UrlValidator.ALLOW_ALL_SCHEMES).isValid(Some("http://www.google.com")), "legacy validateUrl noop equivalence")
    }
}

@Test
class LegacyEmailTranslatedTest {
    @TestCase
    func legacyEmailCoreCases(): Unit {
        let validator = EmailValidator.getInstance()
        for (item in ["jsmith@apache.org", "jsmith@apache.com", "jsmith@apache.net", "jsmith@apache.info", "someone@yahoo.museum", "andy.o'reilly@data-workshop.com", "foo+bar@i.am.not.in.us.example.com", "andy.noble@data-workshop.com", "someone@[216.109.118.76]", "someone@yahoo.com"]) {
            routineEnsure(validator.isValid(Some(item)), "legacy email valid: ${item}")
        }
        for (item in ["jsmith@apache.", "jsmith@apache.c", "someone@yahoo.mu-seum", "joe@localhost", "joe@localhost.localdomain", "andy.noble@\u{008F}data-workshop.com", "andy@o'reilly.data-workshop.com", "joeblow@apa,che.org", "joeblow@apache.o,rg", "joeblow@apache,org", "andy-noble@data-workshop.-com", "andy-noble@data-workshop.c-om", "andy-noble@data-workshop.co-m", "andy.noble@data-workshop.com.", "joeblow @apache.org", "joeblow@ apache.org", " joeblow@apache.org", "joeblow@apache.org ", "joe blow@apache.org ", "joeblow@apa che.org "]) {
            routineEnsure(!validator.isValid(Some(item)), "legacy email invalid: ${item}")
        }
    }

    @TestCase
    func legacyEmailControlsAndEdgeCases(): Unit {
        let validator = EmailValidator.getInstance()
        for (item in ["foo\tbar@domain.com", "foo\nbar@domain.com", "foo\rbar@domain.com"]) {
            routineEnsure(!validator.isValid(Some(item)), "legacy control-char email invalid: ${item}")
        }
        routineEnsure(!validator.isValid(Some("andy@o'reilly.data-workshop.com")), "legacy apostrophe in domain invalid")
        routineEnsure(!validator.isValid(Some("someone@-test.com")), "legacy leading hyphen invalid")
        routineEnsure(!validator.isValid(Some("someone@test-.com")), "legacy trailing hyphen invalid")
    }
}
