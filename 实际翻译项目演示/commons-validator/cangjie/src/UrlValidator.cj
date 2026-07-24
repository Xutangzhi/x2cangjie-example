package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class UrlValidator {
//   static fields/constants:
//     public static let ALLOW_ALL_SCHEMES: Int64 = Int64(1) << 0
//     public static let ALLOW_2_SLASHES: Int64 = Int64(1) << 1
//     public static let NO_FRAGMENTS: Int64 = Int64(1) << 2
//
//   fields/properties:
//     protected let defaultSchemes = ["http", "https", "ftp"]
//
//   constructors:
//     public init()
//     public init(options: Int64)
//     public init(schemes: ?Array<String>)
//     public init(schemes: ?Array<String>, options: Int64)
//
//   methods:
//     protected func countToken(token: String, target: String): Int64
//     public func isValid(value: ?String): Bool
//     protected func isValidAuthority(authority: ?String): Bool
//     protected func isValidFragment(fragment: ?String): Bool
//     protected func isValidPath(path: ?String): Bool
//     protected func isValidQuery(_query: ?String): Bool
//     public func isValidScheme(scheme: ?String): Bool
// }

import std.collection.*
import std.regex.*

private let LEGACY_TOP_LEVEL_MAX_LEN: Int64 = 4
private let LEGACY_TOP_LEVEL_MIN_LEN: Int64 = 2
private let LEGACY_ALPHA_CHARS = "a-zA-Z"
private let LEGACY_SPECIAL_CHARS = ";/@&=,.?:+$"
private let LEGACY_VALID_CHARS = "[^\\s" + LEGACY_SPECIAL_CHARS + "]"
private let LEGACY_AUTHORITY_CHARS_REGEX = "A-Za-z0-9\\-\\."
private let LEGACY_ATOM = LEGACY_VALID_CHARS + "+"
private let LEGACY_URL_REGEX = "^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?"
private let LEGACY_AUTHORITY_REGEX = "^([" + LEGACY_AUTHORITY_CHARS_REGEX + "]*)(:\\d*)?(.*)?"
private let LEGACY_URL_PATTERN = Regex(LEGACY_URL_REGEX)
private let LEGACY_SCHEME_PATTERN = Regex("^[A-Za-z][A-Za-z0-9\\+\\-\\.]*$")
private let LEGACY_AUTHORITY_PATTERN = Regex(LEGACY_AUTHORITY_REGEX)
private let LEGACY_PATH_PATTERN = Regex("^(/[-\\w:@&?=+,.!/~*'%$_;]*)?$")
private let LEGACY_QUERY_PATTERN = Regex("^(.*)$")
private let LEGACY_DOMAIN_PATTERN = Regex("^" + LEGACY_ATOM + "(\\." + LEGACY_ATOM + ")*$")
private let LEGACY_PORT_PATTERN = Regex("^:(\\d{1,5})$")
private let LEGACY_ATOM_PATTERN = Regex("^(" + LEGACY_ATOM + ").*?$")
private let LEGACY_ALPHA_PATTERN = Regex("^[" + LEGACY_ALPHA_CHARS + "]")

private let LEGACY_PARSE_URL_SCHEME: Int64 = 2
private let LEGACY_PARSE_URL_AUTHORITY: Int64 = 4
private let LEGACY_PARSE_URL_PATH: Int64 = 5
private let LEGACY_PARSE_URL_QUERY: Int64 = 7
private let LEGACY_PARSE_URL_FRAGMENT: Int64 = 9

private let LEGACY_PARSE_AUTHORITY_HOST_IP: Int64 = 1
private let LEGACY_PARSE_AUTHORITY_PORT: Int64 = 2
private let LEGACY_PARSE_AUTHORITY_EXTRA: Int64 = 3

private class LegacyParsedUrl {
    let scheme: ?String
    let authority: ?String
    let path: ?String
    let query: ?String
    let fragment: ?String

    init(scheme: ?String, authority: ?String, path: ?String, query: ?String, fragment: ?String) {
        this.scheme = scheme
        this.authority = authority
        this.path = path
        this.query = query
        this.fragment = fragment
    }
}

private func legacyUrlCountToken(token: String, target: String): Int64 {
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

private func legacyUrlHasOnlyAscii(value: String): Bool {
    for (character in value.toRuneArray()) {
        if (character.position() > 0x7F) {
            return false
        }
    }
    true
}

private func legacyUrlParse(value: String): ?LegacyParsedUrl {
    var fragment: ?String = None
    var base = value
    if (let Some(hashIndex) <- base.indexOf("#")) {
        fragment = Some(base[hashIndex + 1..])
        base = base[0..hashIndex]
    }

    var query: ?String = None
    if (let Some(queryIndex) <- base.indexOf("?")) {
        query = Some(base[queryIndex + 1..])
        base = base[0..queryIndex]
    }

    var scheme: ?String = None
    var remainder = base
    if (let Some(colonIndex) <- base.indexOf(":")) {
        if (let Some(slashIndex) <- base.indexOf("/")) {
            if (slashIndex < colonIndex) {
                return None<LegacyParsedUrl>
            }
        }
        scheme = Some(base[0..colonIndex])
        remainder = base[colonIndex + 1..]
    }

    var authority: ?String = None
    var path: ?String = Some("")
    if (remainder.startsWith("//")) {
        let afterSlashes = remainder[2..]
        if (let Some(slashIndex) <- afterSlashes.indexOf("/")) {
            authority = Some(afterSlashes[0..slashIndex])
            path = Some(afterSlashes[slashIndex..])
        } else {
            authority = Some(afterSlashes)
            path = Some("")
        }
    } else {
        path = Some(remainder)
    }
    Some(LegacyParsedUrl(scheme, authority, path, query, fragment))
}

public class UrlValidator {
    public static let ALLOW_ALL_SCHEMES: Int64 = Int64(1) << 0
    public static let ALLOW_2_SLASHES: Int64 = Int64(1) << 1
    public static let NO_FRAGMENTS: Int64 = Int64(1) << 2

    protected let defaultSchemes = ["http", "https", "ftp"]
    private let options: Int64
    private let allowedSchemes: Array<String>

    public init() {
        this(None<Array<String>>, 0)
    }

    public init(options: Int64) {
        this(None<Array<String>>, options)
    }

    public init(schemes: ?Array<String>) {
        this(schemes, 0)
    }

    public init(schemes: ?Array<String>, options: Int64) {
        this.options = options
        if ((options & ALLOW_ALL_SCHEMES) > 0) {
            allowedSchemes = []
        } else {
            allowedSchemes = match (schemes) {
                case Some(values) => values.clone()
                case None => defaultSchemes.clone()
            }
        }
    }

    protected func countToken(token: String, target: String): Int64 {
        legacyUrlCountToken(token, target)
    }

    public func isValid(value: ?String): Bool {
        match (value) {
            case Some(text) =>
                if (!legacyUrlHasOnlyAscii(text)) {
                    return false
                }
                match (legacyUrlParse(text)) {
                    case Some(parts) =>
                        if (!isValidScheme(parts.scheme) || !isValidAuthority(parts.authority) || !isValidPath(parts.path)) {
                            return false
                        }
                        if (!isValidQuery(parts.query)) {
                            return false
                        }
                        isValidFragment(parts.fragment)
                    case None =>
                        false
                }
            case None =>
                false
        }
    }

    protected func isValidAuthority(authority: ?String): Bool {
        match (authority) {
            case Some(text) =>
                if (!LEGACY_AUTHORITY_PATTERN.matches(text)) {
                    return false
                }
                match (LEGACY_AUTHORITY_PATTERN.find(text, group: true)) {
                    case Some(md) =>
                        var hostIp = md.matchString(LEGACY_PARSE_AUTHORITY_HOST_IP)
                        let ipv4Address = legacyIsValidInetAddress(Some(hostIp))
                        var hostname = false
                        if (!ipv4Address) {
                            hostname = LEGACY_DOMAIN_PATTERN.matches(hostIp)
                        }
                        if (hostname) {
                            let chars = hostIp.toRuneArray()
                            var size: Int64 = 1
                            for (character in chars) {
                                if (character == r'.') {
                                    size++
                                }
                            }
                            var domainSegment = Array<String>(size, repeat: "")
                            var matchMore = true
                            var segmentCount: Int64 = 0
                            while (matchMore) {
                                matchMore = LEGACY_ATOM_PATTERN.matches(hostIp)
                                if (matchMore) {
                                    match (LEGACY_ATOM_PATTERN.find(hostIp, group: true)) {
                                        case Some(atomMatch) =>
                                            domainSegment[segmentCount] = atomMatch.matchString(1)
                                            let segmentLength = domainSegment[segmentCount].size + 1
                                            hostIp = if (segmentLength >= hostIp.size) { "" } else { hostIp[segmentLength..] }
                                            segmentCount++
                                        case None =>
                                            matchMore = false
                                    }
                                }
                            }
                            let topLevel = domainSegment[segmentCount - 1]
                            if (topLevel.size < LEGACY_TOP_LEVEL_MIN_LEN || topLevel.size > LEGACY_TOP_LEVEL_MAX_LEN || !LEGACY_ALPHA_PATTERN.matches(topLevel[0..1]) || segmentCount < 2) {
                                return false
                            }
                        }
                        if (!hostname && !ipv4Address) {
                            return false
                        }
                        let port = md.matchString(LEGACY_PARSE_AUTHORITY_PORT)
                        if (!port.isEmpty() && !LEGACY_PORT_PATTERN.matches(port)) {
                            return false
                        }
                        let extra = md.matchString(LEGACY_PARSE_AUTHORITY_EXTRA)
                        extra.trimAscii().isEmpty()
                    case None =>
                        false
                }
            case None =>
                false
        }
    }

    protected func isValidFragment(fragment: ?String): Bool {
        match (fragment) {
            case Some(_) => (options & NO_FRAGMENTS) == 0
            case None => true
        }
    }

    protected func isValidPath(path: ?String): Bool {
        match (path) {
            case Some(text) =>
                if (!LEGACY_PATH_PATTERN.matches(text)) {
                    return false
                }
                let slash2Count = countToken("//", text)
                if ((options & ALLOW_2_SLASHES) == 0 && slash2Count > 0) {
                    return false
                }
                let slashCount = countToken("/", text)
                let dot2Count = countToken("..", text)
                !(dot2Count > 0 && slashCount - slash2Count - 1 <= dot2Count)
            case None =>
                false
        }
    }

    protected func isValidQuery(_query: ?String): Bool {
        match (_query) {
            case Some(text) => LEGACY_QUERY_PATTERN.matches(text)
            case None => true
        }
    }

    public func isValidScheme(scheme: ?String): Bool {
        match (scheme) {
            case Some(text) =>
                if (!LEGACY_SCHEME_PATTERN.matches(text)) {
                    return false
                }
                if ((options & ALLOW_ALL_SCHEMES) == 0 && !allowedSchemes.contains(text)) {
                    return false
                }
                true
            case None =>
                false
        }
    }
}
