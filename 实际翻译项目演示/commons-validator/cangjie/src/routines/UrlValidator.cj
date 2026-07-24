package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class UrlValidator {
//   static fields/constants:
//     public static let ALLOW_ALL_SCHEMES: Int64 = Int64(1) << 0
//     public static let ALLOW_2_SLASHES: Int64 = Int64(1) << 1
//     public static let NO_FRAGMENTS: Int64 = Int64(1) << 2
//     public static let ALLOW_LOCAL_URLS: Int64 = Int64(1) << 3
//
//   static functions:
//     public static func getInstance(): UrlValidator
//
//   constructors:
//     public init()
//     public init(options: Int64)
//     public init(authorityValidator: RegexValidator, options: Int64)
//     public init(schemes: Array<String>)
//     public init(schemes: Array<String>, options: Int64)
//     public init(schemes: ?Array<String>, authorityValidator: ?RegexValidator, options: Int64)
//     public init(schemes: ?Array<String>, authorityValidator: ?RegexValidator, options: Int64, domainValidator: ?DomainValidator)
//
//   methods:
//     public func countToken(token: String, target: String): Int64
//     public func isValid(value: ?String): Bool
//     public func isValidAuthority(authority: ?String): Bool
//     public func isValidFragment(fragment: ?String): Bool
//     public func isValidPath(path: ?String): Bool
//     public func isValidQuery(query: ?String): Bool
//     public func isValidScheme(scheme: ?String): Bool
// }

import std.collection.*
import std.regex.*

private let URL_MAX_UNSIGNED_16_BIT_INT: Int64 = 0xFFFF
private let URL_SCHEME_REGEX = "^[A-Za-z][A-Za-z0-9\\+\\-\\.]*$"
private let URL_AUTHORITY_CHARS_REGEX = "A-Za-z0-9\\-\\."
private let URL_IPV6_REGEX = "::FFFF:(?:\\d{1,3}\\.){3}\\d{1,3}|[0-9a-fA-F:]+"
private let URL_USERINFO_CHARS_REGEX = "[a-zA-Z0-9%-._~!$&'()*+,;=]"
private let URL_USERINFO_FIELD_REGEX = URL_USERINFO_CHARS_REGEX + "+(?::" + URL_USERINFO_CHARS_REGEX + "*)?@"
private let URL_AUTHORITY_REGEX =
    "(?:\\[(" + URL_IPV6_REGEX + ")\\]|(?:(?:" + URL_USERINFO_FIELD_REGEX + ")?([" + URL_AUTHORITY_CHARS_REGEX + "]*)))(?::(\\d*))?(.*)?"
private let URL_PATH_REGEX = "^(/[-\\w:@&?=+,.!/~*'%$_;\\(\\)]*)?$"
private let URL_QUERY_REGEX = "^(\\S*)$"
private let URL_DEFAULT_SCHEMES = ["http", "https", "ftp"]

private class ParsedUrl {
    let scheme: String
    let authority: ?String
    let path: String
    let query: ?String
    let fragment: ?String

    init(scheme: String, authority: ?String, path: String, query: ?String, fragment: ?String) {
        this.scheme = scheme
        this.authority = authority
        this.path = path
        this.query = query
        this.fragment = fragment
    }
}

private func urlIsHexDigit(character: Rune): Bool {
    character.isAsciiNumber() || (character >= r'a' && character <= r'f') || (character >= r'A' && character <= r'F')
}

private func urlHasIllegalCharacters(value: String): Bool {
    for (character in value.toRuneArray()) {
        let pos = character.position()
        if (pos <= 0x20 || pos == 0x7F || character == r'\\') {
            return true
        }
    }
    false
}

private func urlHasInvalidPercentEncoding(value: String): Bool {
    let runes = value.toRuneArray()
    for (i in 0..runes.size) {
        if (runes[i] == r'%') {
            if (i + 2 >= runes.size) {
                return true
            }
            if (!urlIsHexDigit(runes[i + 1]) || !urlIsHexDigit(runes[i + 2])) {
                return true
            }
        }
    }
    false
}

private func urlCountToken(token: String, target: String): Int64 {
    var tokenIndex = 0
    var count = 0
    while (true) {
        match (target.indexOf(token, tokenIndex)) {
            case Some(index) =>
                tokenIndex = index + 1
                count++
            case None =>
                return count
        }
    }
    count
}

private func urlParseDecimal(text: String): Int64 {
    if (text.isEmpty()) {
        throw IllegalArgumentException("Empty decimal value")
    }
    var value: Int64 = 0
    for (character in text.toRuneArray()) {
        if (!character.isAsciiNumber()) {
            throw IllegalArgumentException("Non-decimal character")
        }
        value = value * 10 + character.position() - r'0'.position()
    }
    value
}

private func urlAnySeparatorBefore(value: String, separatorIndex: Int64): Bool {
    for (separator in ["/", "?", "#"]) {
        if (let Some(index) <- value.indexOf(separator)) {
            if (index < separatorIndex) {
                return true
            }
        }
    }
    false
}

private func urlParse(value: String): ?ParsedUrl {
    if (let Some(colonIndex) <- value.indexOf(":")) {
        if (colonIndex == 0 || urlAnySeparatorBefore(value, colonIndex)) {
            return None<ParsedUrl>
        }
        let scheme = value[0..colonIndex]
        var remainder = value[colonIndex + 1..]
        var fragment: ?String = None
        if (let Some(hashIndex) <- remainder.indexOf("#")) {
            fragment = Some(remainder[hashIndex + 1..])
            remainder = remainder[0..hashIndex]
        }
        var query: ?String = None
        if (let Some(queryIndex) <- remainder.indexOf("?")) {
            query = Some(remainder[queryIndex + 1..])
            remainder = remainder[0..queryIndex]
        }
        var authority: ?String = None
        var path = ""
        if (remainder.startsWith("//")) {
            let afterSlashes = remainder[2..]
            if (let Some(slashIndex) <- afterSlashes.indexOf("/")) {
                authority = Some(afterSlashes[0..slashIndex])
                path = afterSlashes[slashIndex..]
            } else {
                authority = Some(afterSlashes)
            }
        } else {
            path = remainder
        }
        return Some(ParsedUrl(scheme, authority, path, query, fragment))
    }
    None<ParsedUrl>
}

private func urlNormalizePath(path: String): String {
    let absolute = path.startsWith("/")
    let trailingSlash = path.endsWith("/") && path != "/"
    let segments = path.split("/", -1)
    var stack = ArrayList<String>()
    let start = if (absolute) { 1 } else { 0 }
    for (i in start..segments.size) {
        let segment = segments[i]
        if (segment.isEmpty() || segment == ".") {
            continue
        }
        if (segment == "..") {
            if (!stack.isEmpty() && stack[stack.size - 1] != "..") {
                var trimmed = ArrayList<String>()
                for (j in 0..stack.size - 1) {
                    trimmed.add(stack[j])
                }
                stack = trimmed
            } else {
                stack.add(segment)
            }
        } else {
            stack.add(segment)
        }
    }

    var normalized = if (absolute) { "/" } else { "" }
    for (i in 0..stack.size) {
        if (i > 0) {
            normalized += "/"
        }
        normalized += stack[i]
    }
    if (trailingSlash && !normalized.endsWith("/")) {
        normalized += "/"
    }
    normalized
}

private func urlBlankOrNull(value: ?String): Bool {
    match (value) {
        case Some(text) => text.trimAscii().isEmpty()
        case None => true
    }
}

public class UrlValidator {
    public static let ALLOW_ALL_SCHEMES: Int64 = Int64(1) << 0
    public static let ALLOW_2_SLASHES: Int64 = Int64(1) << 1
    public static let NO_FRAGMENTS: Int64 = Int64(1) << 2
    public static let ALLOW_LOCAL_URLS: Int64 = Int64(1) << 3

    private static let DEFAULT_URL_VALIDATOR = UrlValidator()
    private static let SCHEME_PATTERN = Regex(URL_SCHEME_REGEX)
    private static let AUTHORITY_PATTERN = Regex("^" + URL_AUTHORITY_REGEX + "$")
    private static let PATH_PATTERN = Regex(URL_PATH_REGEX)
    private static let QUERY_PATTERN = Regex(URL_QUERY_REGEX)

    private let options: Int64
    private let allowedSchemes: Array<String>
    private let authorityValidator: ?RegexValidator
    private let domainValidator: DomainValidator

    public static func getInstance(): UrlValidator {
        DEFAULT_URL_VALIDATOR
    }

    private static func isOptionOn(flag: Int64, options: Int64): Bool {
        (options & flag) > 0
    }

    public init() {
        this(None<Array<String>>, None<RegexValidator>, 0)
    }

    public init(options: Int64) {
        this(None<Array<String>>, None<RegexValidator>, options)
    }

    public init(authorityValidator: RegexValidator, options: Int64) {
        this(None<Array<String>>, Some(authorityValidator), options)
    }

    public init(schemes: Array<String>) {
        this(Some(schemes), None<RegexValidator>, 0)
    }

    public init(schemes: Array<String>, options: Int64) {
        this(Some(schemes), None<RegexValidator>, options)
    }

    public init(schemes: ?Array<String>, authorityValidator: ?RegexValidator, options: Int64) {
        this(schemes, authorityValidator, options, Some(DomainValidator.getInstance(UrlValidator.isOptionOn(ALLOW_LOCAL_URLS, options))))
    }

    public init(schemes: ?Array<String>, authorityValidator: ?RegexValidator, options: Int64, domainValidator: ?DomainValidator) {
        this.options = options
        this.authorityValidator = authorityValidator
        match (domainValidator) {
            case Some(validator) =>
                if (validator.isAllowLocal() != UrlValidator.isOptionOn(ALLOW_LOCAL_URLS, options)) {
                    throw IllegalArgumentException("DomainValidator disagrees with ALLOW_LOCAL_URLS setting")
                }
                this.domainValidator = validator
            case None =>
                throw IllegalArgumentException("DomainValidator must not be null")
        }

        if (UrlValidator.isOptionOn(ALLOW_ALL_SCHEMES, options)) {
            allowedSchemes = []
        } else {
            let source = match (schemes) {
                case Some(values) => values
                case None => URL_DEFAULT_SCHEMES
            }
            var normalized = ArrayList<String>()
            for (scheme in source) {
                normalized.add(scheme.toAsciiLower())
            }
            allowedSchemes = normalized.toArray()
        }
    }

    private func isOff(flag: Int64): Bool {
        (options & flag) == 0
    }

    private func isOn(flag: Int64): Bool {
        (options & flag) > 0
    }

    public func countToken(token: String, target: String): Int64 {
        urlCountToken(token, target)
    }

    public func isValid(value: ?String): Bool {
        match (value) {
            case Some(text) =>
                if (urlHasIllegalCharacters(text) || urlHasInvalidPercentEncoding(text)) {
                    return false
                }
                if (let Some(parts) <- urlParse(text)) {
                    if (!isValidScheme(Some(parts.scheme))) {
                        return false
                    }
                    if (parts.scheme.toAsciiLower() == "file" && urlBlankOrNull(parts.authority)) {
                        return true
                    }
                    if (parts.scheme.toAsciiLower() == "file") {
                        if (let Some(authority) <- parts.authority) {
                            if (authority.contains(":")) {
                                return false
                            }
                        }
                    }
                    if (!isValidAuthority(parts.authority)) {
                        return false
                    }
                    if (!isValidPath(Some(parts.path)) || !isValidQuery(parts.query) || !isValidFragment(parts.fragment)) {
                        return false
                    }
                    return true
                }
                false
            case None =>
                false
        }
    }

    public func isValidAuthority(authority: ?String): Bool {
        match (authority) {
            case Some(text) =>
                if (let Some(validator) <- authorityValidator) {
                    if (validator.isValid(Some(text))) {
                        return true
                    }
                }

                let ascii = DomainValidator.unicodeToASCII(text)
                if (!UrlValidator.AUTHORITY_PATTERN.matches(ascii)) {
                    return false
                }
                match (UrlValidator.AUTHORITY_PATTERN.find(ascii, group: true)) {
                    case Some(md) =>
                        let ipv6 = md.matchString(1)
                        if (!ipv6.isEmpty()) {
                            if (!InetAddressValidator.getInstance().isValidInet6Address(Some(ipv6))) {
                                return false
                            }
                        } else {
                            let hostLocation = md.matchString(2)
                            if (!domainValidator.isValid(Some(hostLocation)) && !InetAddressValidator.getInstance().isValidInet4Address(Some(hostLocation))) {
                                return false
                            }
                            let port = md.matchString(3)
                            if (!port.trimAscii().isEmpty()) {
                                try {
                                    let parsed = urlParseDecimal(port)
                                    if (parsed < 0 || parsed > URL_MAX_UNSIGNED_16_BIT_INT) {
                                        return false
                                    }
                                } catch (e: Exception) {
                                    return false
                                }
                            }
                        }

                        let extra = md.matchString(4)
                        extra.trimAscii().isEmpty()
                    case None =>
                        false
                }
            case None =>
                false
        }
    }

    public func isValidFragment(fragment: ?String): Bool {
        match (fragment) {
            case Some(_) => isOff(NO_FRAGMENTS)
            case None => true
        }
    }

    public func isValidPath(path: ?String): Bool {
        match (path) {
            case Some(text) =>
                if (!UrlValidator.PATH_PATTERN.matches(text)) {
                    return false
                }
                let normalized = urlNormalizePath(text)
                if (normalized.startsWith("/../") || normalized == "/..") {
                    return false
                }
                if (isOff(ALLOW_2_SLASHES) && countToken("//", text) > 0) {
                    return false
                }
                true
            case None =>
                false
        }
    }

    public func isValidQuery(query: ?String): Bool {
        match (query) {
            case Some(text) => UrlValidator.QUERY_PATTERN.matches(text)
            case None => true
        }
    }

    public func isValidScheme(scheme: ?String): Bool {
        match (scheme) {
            case Some(text) =>
                if (!UrlValidator.SCHEME_PATTERN.matches(text)) {
                    return false
                }
                if (isOff(ALLOW_ALL_SCHEMES) && !allowedSchemes.contains(text.toAsciiLower())) {
                    return false
                }
                true
            case None =>
                false
        }
    }
}
