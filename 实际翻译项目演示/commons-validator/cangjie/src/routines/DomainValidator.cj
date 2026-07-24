package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public enum ArrayType {
//   enum cases:
//     | GENERIC_PLUS
//     | GENERIC_MINUS
//     | COUNTRY_CODE_PLUS
//     | COUNTRY_CODE_MINUS
//     | GENERIC_RO
//     | COUNTRY_CODE_RO
//     | INFRASTRUCTURE_RO
//     | LOCAL_RO
//     | LOCAL_PLUS
//     | LOCAL_MINUS
//
//   methods:
//     public func toString(): String
// }

// public class Item {
//   fields/properties:
//     public let values: Array<String>
//
//   constructors:
//     public init(`type`: ArrayType, value: String)
//     public init(`type`: ArrayType, first: String, second: String)
//     public init(`type`: ArrayType, values: Array<String>)
// }

// public class DomainValidator {
//   static functions:
//     public static func resetForTests(): Unit
//     public static func getInstance(): DomainValidator
//     public static func getInstance(allowLocal: Bool): DomainValidator
//     public static func getInstance(allowLocal: Bool, items: ArrayList<Item>): DomainValidator
//     public static func getTLDEntries(table: ArrayType): Array<String>
//     public static func updateTLDOverride(table: ArrayType, value: String): Unit
//     public static func updateTLDOverride(table: ArrayType, first: String, second: String): Unit
//     public static func updateTLDOverride(table: ArrayType, values: Array<String>): Unit
//     public static func unicodeToASCII(input: String): String
//
//   operator methods:
//     public operator func ==(right: DomainValidator): Bool
//     public operator func !=(right: DomainValidator): Bool
//
//   methods:
//     public func getOverrides(table: ArrayType): Array<String>
//     public func isAllowLocal(): Bool
//     public func isValid(domain: ?String): Bool
//     public func isValidDomainSyntax(domain: ?String): Bool
//     public func isValidCountryCodeTld(ccTld: String): Bool
//     public func isValidGenericTld(gTld: String): Bool
//     public func isValidInfrastructureTld(iTld: String): Bool
//     public func isValidLocalTld(lTld: String): Bool
//     public func isValidTld(tld: String): Bool
// }

import std.collection.*
import std.regex.*
import std.sort.*
import std.unicode.*

private let DOMAIN_MAX_LENGTH: Int64 = 253
private let DOMAIN_LABEL_REGEX = "[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?"
private let TOP_LABEL_REGEX = "[A-Za-z](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?"
private let DOMAIN_NAME_REGEX = "^(?:" + DOMAIN_LABEL_REGEX + "\\.)+(" + TOP_LABEL_REGEX + ")\\.?$"
private let UNEXPECTED_ENUM_VALUE = "Unexpected enum value: "

private func domainArrayContains(values: Array<String>, target: String): Bool {
    for (value in values) {
        if (value == target) {
            return true
        }
    }
    false
}

private func domainCopy(values: Array<String>): Array<String> {
    values.clone()
}

private func domainLower(text: String): String {
    var runes = ArrayList<Rune>()
    for (character in text.toRuneArray()) {
        runes.add(character.toLowerCase())
    }
    String(runes)
}

private func domainNormalizeOverrides(values: Array<String>): Array<String> {
    var copy = ArrayList<String>()
    for (value in values) {
        copy.add(domainLower(value))
    }
    var result = copy.toArray()
    sort<String>(result)
    result
}

private func domainNormalizeOverrides(values: ArrayList<String>): Array<String> {
    domainNormalizeOverrides(values.toArray())
}

private func domainHasOnlyAscii(input: String): Bool {
    for (character in input.toRuneArray()) {
        if (character.position() > 0x7f) {
            return false
        }
    }
    true
}

private func domainNormalizeSeparators(input: String): String {
    var runes = ArrayList<Rune>()
    for (character in input.toRuneArray()) {
        let position = character.position()
        if (position == 0x3002 || position == 0xFF0E || position == 0xFF61) {
            runes.add(r'.')
        } else {
            runes.add(character)
        }
    }
    String(runes)
}

private func domainContainsInvalidReplacement(label: String): Bool {
    for (character in label.toRuneArray()) {
        if (character.position() == 0xFFFD) {
            return true
        }
    }
    false
}

private func domainEncodeDigit(digit: Int64): String {
    if (digit < 26) {
        return "${r'a'.next(digit)}"
    }
    "${r'0'.next(digit - 26)}"
}

private func domainAdapt(deltaValue: Int64, numPoints: Int64, firstTime: Bool): Int64 {
    let base: Int64 = 36
    let tMin: Int64 = 1
    let tMax: Int64 = 26
    let skew: Int64 = 38
    let damp: Int64 = 700

    var delta = if (firstTime) { deltaValue / damp } else { deltaValue / 2 }
    delta += delta / numPoints
    var k: Int64 = 0
    while (delta > ((base - tMin) * tMax) / 2) {
        delta /= (base - tMin)
        k += base
    }
    k + (((base - tMin + 1) * delta) / (delta + skew))
}

private func domainPunycodeEncode(label: String): String {
    let base: Int64 = 36
    let tMin: Int64 = 1
    let tMax: Int64 = 26
    let initialBias: Int64 = 72
    let initialN: Int64 = 128
    let delimiter = "-"

    let runes = domainLower(label).toRuneArray()
    var output = ""
    var basicCount: Int64 = 0
    for (character in runes) {
        if (character.position() < 0x80) {
            output += "${character.toAsciiLowerCase()}"
            basicCount++
        }
    }

    var handled = basicCount
    if (basicCount > 0 && basicCount < runes.size) {
        output += delimiter
    }

    var n = initialN
    var delta: Int64 = 0
    var bias = initialBias
    while (handled < runes.size) {
        var nextCodePoint: Int64 = 0x7fffffffffffffff
        for (character in runes) {
            let codePoint = character.position()
            if (codePoint >= n && codePoint < nextCodePoint) {
                nextCodePoint = codePoint
            }
        }

        delta += (nextCodePoint - n) * (handled + 1)
        n = nextCodePoint
        for (character in runes) {
            let codePoint = character.position()
            if (codePoint < n) {
                delta++
            } else if (codePoint == n) {
                var q = delta
                var k = base
                while (true) {
                    let threshold = if (k <= bias) {
                        tMin
                    } else if (k >= bias + tMax) {
                        tMax
                    } else {
                        k - bias
                    }
                    if (q < threshold) {
                        break
                    }
                    output += domainEncodeDigit(threshold + ((q - threshold) % (base - threshold)))
                    q = (q - threshold) / (base - threshold)
                    k += base
                }
                output += domainEncodeDigit(q)
                bias = domainAdapt(delta, handled + 1, handled == basicCount)
                delta = 0
                handled++
            }
        }
        delta++
        n++
    }

    "xn--" + output
}

private func domainLabelToAscii(label: String): String {
    if (label.isEmpty()) {
        return label
    }
    if (domainHasOnlyAscii(label)) {
        return label
    }
    if (domainContainsInvalidReplacement(label)) {
        return label
    }
    domainPunycodeEncode(label)
}

public enum ArrayType <: ToString & Equatable<ArrayType> {
    | GENERIC_PLUS
    | GENERIC_MINUS
    | COUNTRY_CODE_PLUS
    | COUNTRY_CODE_MINUS
    | GENERIC_RO
    | COUNTRY_CODE_RO
    | INFRASTRUCTURE_RO
    | LOCAL_RO
    | LOCAL_PLUS
    | LOCAL_MINUS

    public func toString(): String {
        match (this) {
            case GENERIC_PLUS => "GENERIC_PLUS"
            case GENERIC_MINUS => "GENERIC_MINUS"
            case COUNTRY_CODE_PLUS => "COUNTRY_CODE_PLUS"
            case COUNTRY_CODE_MINUS => "COUNTRY_CODE_MINUS"
            case GENERIC_RO => "GENERIC_RO"
            case COUNTRY_CODE_RO => "COUNTRY_CODE_RO"
            case INFRASTRUCTURE_RO => "INFRASTRUCTURE_RO"
            case LOCAL_RO => "LOCAL_RO"
            case LOCAL_PLUS => "LOCAL_PLUS"
            case LOCAL_MINUS => "LOCAL_MINUS"
        }
    }

    public operator func ==(right: ArrayType): Bool {
        this.toString() == right.toString()
    }

    public operator func !=(right: ArrayType): Bool {
        !(this == right)
    }
}

public class Item {
    internal let typeValue: ArrayType
    public let values: Array<String>

    public init(`type`: ArrayType, value: String) {
        this.typeValue = `type`
        this.values = [value]
    }

    public init(`type`: ArrayType, first: String, second: String) {
        this.typeValue = `type`
        this.values = [first, second]
    }

    public init(`type`: ArrayType, values: Array<String>) {
        this.typeValue = `type`
        this.values = values.clone()
    }
}

public class DomainValidator {
    private static let INFRASTRUCTURE_TLDS = INFRASTRUCTURE_TLDS_DATA
    private static let GENERIC_TLDS = GENERIC_TLDS_DATA
    private static let COUNTRY_CODE_TLDS = COUNTRY_CODE_TLDS_DATA
    private static let LOCAL_TLDS = LOCAL_TLDS_DATA
    private static let EMPTY_STRING_ARRAY: Array<String> = []

    private static var inUse = false
    private static var countryCodeTLDsPlus: Array<String> = EMPTY_STRING_ARRAY
    private static var genericTLDsPlus: Array<String> = EMPTY_STRING_ARRAY
    private static var countryCodeTLDsMinus: Array<String> = EMPTY_STRING_ARRAY
    private static var genericTLDsMinus: Array<String> = EMPTY_STRING_ARRAY
    private static var localTLDsPlus: Array<String> = EMPTY_STRING_ARRAY
    private static var localTLDsMinus: Array<String> = EMPTY_STRING_ARRAY
    private static var singletonNoLocal: ?DomainValidator = None
    private static var singletonWithLocal: ?DomainValidator = None

    private let allowLocalValue: Bool
    private let domainRegex = RegexValidator(DOMAIN_NAME_REGEX)
    private let hostnameRegex = RegexValidator("^" + DOMAIN_LABEL_REGEX + "$")
    private let myCountryCodeTLDsMinus: Array<String>
    private let myCountryCodeTLDsPlus: Array<String>
    private let myGenericTLDsPlus: Array<String>
    private let myGenericTLDsMinus: Array<String>
    private let myLocalTLDsPlus: Array<String>
    private let myLocalTLDsMinus: Array<String>

    public static func resetForTests(): Unit {
        inUse = false
        countryCodeTLDsPlus = EMPTY_STRING_ARRAY
        genericTLDsPlus = EMPTY_STRING_ARRAY
        countryCodeTLDsMinus = EMPTY_STRING_ARRAY
        genericTLDsMinus = EMPTY_STRING_ARRAY
        localTLDsPlus = EMPTY_STRING_ARRAY
        localTLDsMinus = EMPTY_STRING_ARRAY
        singletonNoLocal = None
        singletonWithLocal = None
    }

    public static func getInstance(): DomainValidator {
        inUse = true
        if (let Some(instance) <- singletonNoLocal) {
            return instance
        }
        let created = DomainValidator(false)
        singletonNoLocal = Some(created)
        created
    }

    public static func getInstance(allowLocal: Bool): DomainValidator {
        inUse = true
        if (allowLocal) {
            if (let Some(instance) <- singletonWithLocal) {
                return instance
            }
            let created = DomainValidator(true)
            singletonWithLocal = Some(created)
            return created
        }
        getInstance()
    }

    public static func getInstance(allowLocal: Bool, items: ArrayList<Item>): DomainValidator {
        inUse = true
        DomainValidator(allowLocal, items)
    }

    public static func getTLDEntries(table: ArrayType): Array<String> {
        let array = match (table) {
            case ArrayType.COUNTRY_CODE_MINUS => countryCodeTLDsMinus
            case ArrayType.COUNTRY_CODE_PLUS => countryCodeTLDsPlus
            case ArrayType.GENERIC_MINUS => genericTLDsMinus
            case ArrayType.GENERIC_PLUS => genericTLDsPlus
            case ArrayType.LOCAL_MINUS => localTLDsMinus
            case ArrayType.LOCAL_PLUS => localTLDsPlus
            case ArrayType.GENERIC_RO => GENERIC_TLDS
            case ArrayType.COUNTRY_CODE_RO => COUNTRY_CODE_TLDS
            case ArrayType.INFRASTRUCTURE_RO => INFRASTRUCTURE_TLDS
            case ArrayType.LOCAL_RO => LOCAL_TLDS
        }
        domainCopy(array)
    }

    public static func updateTLDOverride(table: ArrayType, value: String): Unit {
        updateTLDOverride(table, [value])
    }

    public static func updateTLDOverride(table: ArrayType, first: String, second: String): Unit {
        updateTLDOverride(table, [first, second])
    }

    public static func updateTLDOverride(table: ArrayType, values: Array<String>): Unit {
        if (inUse) {
            throw IllegalStateException("Can only invoke this method before calling getInstance")
        }
        let copy = domainNormalizeOverrides(values)
        match (table) {
            case ArrayType.COUNTRY_CODE_MINUS => countryCodeTLDsMinus = copy
            case ArrayType.COUNTRY_CODE_PLUS => countryCodeTLDsPlus = copy
            case ArrayType.GENERIC_MINUS => genericTLDsMinus = copy
            case ArrayType.GENERIC_PLUS => genericTLDsPlus = copy
            case ArrayType.LOCAL_MINUS => localTLDsMinus = copy
            case ArrayType.LOCAL_PLUS => localTLDsPlus = copy
            case ArrayType.COUNTRY_CODE_RO => throw IllegalArgumentException("Cannot update the table: ${table}")
            case ArrayType.GENERIC_RO => throw IllegalArgumentException("Cannot update the table: ${table}")
            case ArrayType.INFRASTRUCTURE_RO => throw IllegalArgumentException("Cannot update the table: ${table}")
            case ArrayType.LOCAL_RO => throw IllegalArgumentException("Cannot update the table: ${table}")
        }
    }

    public static func unicodeToASCII(input: String): String {
        if (domainHasOnlyAscii(input)) {
            return input
        }
        if (input.isEmpty()) {
            return input
        }
        let normalized = domainNormalizeSeparators(input)
        let labels = normalized.split(".", -1)
        var out = ArrayList<String>()
        for (label in labels) {
            out.add(domainLabelToAscii(label))
        }
        var joined = ""
        for (i in 0..out.size) {
            if (i > 0) {
                joined += "."
            }
            joined += out[i]
        }
        joined
    }

    private init(allowLocal: Bool) {
        allowLocalValue = allowLocal
        myCountryCodeTLDsMinus = countryCodeTLDsMinus
        myCountryCodeTLDsPlus = countryCodeTLDsPlus
        myGenericTLDsPlus = genericTLDsPlus
        myGenericTLDsMinus = genericTLDsMinus
        myLocalTLDsPlus = localTLDsPlus
        myLocalTLDsMinus = localTLDsMinus
    }

    private init(allowLocal: Bool, items: ArrayList<Item>) {
        allowLocalValue = allowLocal
        var ccMinus = countryCodeTLDsMinus
        var ccPlus = countryCodeTLDsPlus
        var genMinus = genericTLDsMinus
        var genPlus = genericTLDsPlus
        var locMinus = localTLDsMinus
        var locPlus = localTLDsPlus
        for (item in items) {
            let copy = domainNormalizeOverrides(item.values)
            match (item.typeValue) {
                case ArrayType.COUNTRY_CODE_MINUS => ccMinus = copy
                case ArrayType.COUNTRY_CODE_PLUS => ccPlus = copy
                case ArrayType.GENERIC_MINUS => genMinus = copy
                case ArrayType.GENERIC_PLUS => genPlus = copy
                case ArrayType.LOCAL_MINUS => locMinus = copy
                case ArrayType.LOCAL_PLUS => locPlus = copy
                case ArrayType.COUNTRY_CODE_RO => continue
                case ArrayType.GENERIC_RO => continue
                case ArrayType.INFRASTRUCTURE_RO => continue
                case ArrayType.LOCAL_RO => continue
            }
        }
        myCountryCodeTLDsMinus = ccMinus
        myCountryCodeTLDsPlus = ccPlus
        myGenericTLDsPlus = genPlus
        myGenericTLDsMinus = genMinus
        myLocalTLDsPlus = locPlus
        myLocalTLDsMinus = locMinus
    }

    private func chompLeadingDot(str: String): String {
        if (str.startsWith(".")) {
            return str[1..]
        }
        str
    }

    public operator func ==(right: DomainValidator): Bool {
        allowLocalValue == right.allowLocalValue &&
            myCountryCodeTLDsMinus == right.myCountryCodeTLDsMinus &&
            myCountryCodeTLDsPlus == right.myCountryCodeTLDsPlus &&
            myGenericTLDsPlus == right.myGenericTLDsPlus &&
            myGenericTLDsMinus == right.myGenericTLDsMinus &&
            myLocalTLDsPlus == right.myLocalTLDsPlus &&
            myLocalTLDsMinus == right.myLocalTLDsMinus
    }

    public operator func !=(right: DomainValidator): Bool {
        !(this == right)
    }

    public func getOverrides(table: ArrayType): Array<String> {
        let array = match (table) {
            case ArrayType.COUNTRY_CODE_MINUS => myCountryCodeTLDsMinus
            case ArrayType.COUNTRY_CODE_PLUS => myCountryCodeTLDsPlus
            case ArrayType.GENERIC_MINUS => myGenericTLDsMinus
            case ArrayType.GENERIC_PLUS => myGenericTLDsPlus
            case ArrayType.LOCAL_MINUS => myLocalTLDsMinus
            case ArrayType.LOCAL_PLUS => myLocalTLDsPlus
            case _ => throw IllegalArgumentException(UNEXPECTED_ENUM_VALUE + table.toString())
        }
        domainCopy(array)
    }

    public func isAllowLocal(): Bool {
        allowLocalValue
    }

    public func isValid(domain: ?String): Bool {
        match (domain) {
            case Some(value) =>
                let ascii = DomainValidator.unicodeToASCII(value)
                if (ascii.size > DOMAIN_MAX_LENGTH) {
                    return false
                }
                if (let Some(groups) <- domainRegex.`match`(Some(ascii))) {
                    return groups.size > 0 && isValidTld(groups[0])
                }
                allowLocalValue && hostnameRegex.isValid(Some(ascii))
            case None =>
                false
        }
    }

    public func isValidDomainSyntax(domain: ?String): Bool {
        match (domain) {
            case Some(value) =>
                let ascii = DomainValidator.unicodeToASCII(value)
                if (ascii.size > DOMAIN_MAX_LENGTH) {
                    return false
                }
                if (let Some(groups) <- domainRegex.`match`(Some(ascii))) {
                    return groups.size > 0
                }
                hostnameRegex.isValid(Some(ascii))
            case None =>
                false
        }
    }

    public func isValidCountryCodeTld(ccTld: String): Bool {
        let key = chompLeadingDot(DomainValidator.unicodeToASCII(ccTld).toAsciiLower())
        (domainArrayContains(COUNTRY_CODE_TLDS, key) || domainArrayContains(myCountryCodeTLDsPlus, key)) &&
            !domainArrayContains(myCountryCodeTLDsMinus, key)
    }

    public func isValidGenericTld(gTld: String): Bool {
        let key = chompLeadingDot(DomainValidator.unicodeToASCII(gTld).toAsciiLower())
        (domainArrayContains(GENERIC_TLDS, key) || domainArrayContains(myGenericTLDsPlus, key)) &&
            !domainArrayContains(myGenericTLDsMinus, key)
    }

    public func isValidInfrastructureTld(iTld: String): Bool {
        let key = chompLeadingDot(DomainValidator.unicodeToASCII(iTld).toAsciiLower())
        domainArrayContains(INFRASTRUCTURE_TLDS, key)
    }

    public func isValidLocalTld(lTld: String): Bool {
        let key = chompLeadingDot(DomainValidator.unicodeToASCII(lTld).toAsciiLower())
        (domainArrayContains(LOCAL_TLDS, key) || domainArrayContains(myLocalTLDsPlus, key)) &&
            !domainArrayContains(myLocalTLDsMinus, key)
    }

    public func isValidTld(tld: String): Bool {
        if (allowLocalValue && isValidLocalTld(tld)) {
            return true
        }
        isValidInfrastructureTld(tld) || isValidGenericTld(tld) || isValidCountryCodeTld(tld)
    }
}
