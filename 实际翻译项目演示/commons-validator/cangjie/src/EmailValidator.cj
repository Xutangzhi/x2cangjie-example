package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// top-level fields/constants:
//   let runes = ArrayList<Rune>()
//   let segments = legacyEmailValidator__split(text, r'.')
//   let runes = ArrayList<Rune>()
//   let out = ArrayList<Rune>()
//   var depth: Int64 = 0
//   var index: Int64 = 0

// top-level functions:
//   public static func getInstance(): EmailValidator
//   public init()
//   public func isValid(email: ?String): Bool
//   protected func isValidDomain(domain: String): Bool
//   protected func isValidIpAddress(ipAddress: String): Bool
//   protected func isValidSymbolicDomain(domain: String): Bool
//   protected func isValidUser(user: String): Bool
//   protected func stripComments(emailStr: String): String

import std.regex.*

private let LEGACY_SPECIAL_CHARS = "\\(\\)<>@,;:'\\\\\\\"\\.\\[\\]"
private let LEGACY_VALID_CHARS = "[^\\s" + LEGACY_SPECIAL_CHARS + "]"
private let LEGACY_QUOTED_USER = "(\"[^\"]*\")"
private let LEGACY_ATOM = LEGACY_VALID_CHARS + "+"
private let LEGACY_WORD = "((" + LEGACY_VALID_CHARS + "|')+|" + LEGACY_QUOTED_USER + ")"
private let LEGACY_IP_DOMAIN_PATTERN = Regex("^\\[(.*)\\]$")
private let LEGACY_TLD_PATTERN = Regex("^([a-zA-Z]+)$")
private let LEGACY_USER_PATTERN = Regex("^\\s*" + LEGACY_WORD + "(\\." + LEGACY_WORD + ")*$")
private let LEGACY_DOMAIN_PATTERN = Regex("^" + LEGACY_ATOM + "(\\." + LEGACY_ATOM + ")*\\s*$")
private let LEGACY_DOMAIN_LABEL_PATTERN = Regex("^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?$")

private func legacyEmailContainsIsoControl(value: String): Bool {
    for (character in value.toRuneArray()) {
        let pos = character.position()
        if (pos <= 0x1F || (pos >= 0x7F && pos <= 0x9F)) {
            return true
        }
    }
    false
}

public class EmailValidator {
    private static let EMAIL_VALIDATOR = EmailValidator()

    public static func getInstance(): EmailValidator {
        EMAIL_VALIDATOR
    }

    protected init() {}

    public func isValid(email: ?String): Bool {
        match (email) {
            case Some(value) =>
                if (value.endsWith(".") || legacyEmailContainsIsoControl(value) || value.trimAscii() != value) {
                    return false
                }
                match (value.indexOf("@")) {
                    case Some(atIndex) =>
                        if (atIndex <= 0 || atIndex >= value.size - 1) {
                            return false
                        }
                        let user = value[0..atIndex]
                        let domain = value[atIndex + 1..]
                        isValidUser(user) && isValidDomain(domain)
                    case None =>
                        false
                }
            case None =>
                false
        }
    }

    protected func isValidDomain(domain: String): Bool {
        match (LEGACY_IP_DOMAIN_PATTERN.find(domain, group: true)) {
            case Some(md) =>
                legacyIsValidInetAddress(Some(md.matchString(1)))
            case None =>
                LEGACY_DOMAIN_PATTERN.matches(domain) && isValidSymbolicDomain(domain)
        }
    }

    protected func isValidIpAddress(ipAddress: String): Bool {
        legacyIsValidInetAddress(Some(ipAddress))
    }

    protected func isValidSymbolicDomain(domain: String): Bool {
        let trimmed = domain.trimAscii()
        let segments = trimmed.split(".")
        if (segments.size < 2) {
            return false
        }
        for (i in 0..segments.size - 1) {
            if (segments[i].isEmpty() || !LEGACY_DOMAIN_LABEL_PATTERN.matches(segments[i])) {
                return false
            }
        }
        let tld = segments[segments.size - 1]
        tld.size > 1 && tld.size <= 6 && LEGACY_TLD_PATTERN.matches(tld)
    }

    protected func isValidUser(user: String): Bool {
        LEGACY_USER_PATTERN.matches(user)
    }

    protected func stripComments(emailStr: String): String {
        emailStr
    }
}
