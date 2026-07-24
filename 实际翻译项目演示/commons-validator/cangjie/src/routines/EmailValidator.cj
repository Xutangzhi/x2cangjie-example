package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// top-level fields/constants:
//   var index = start + 1
//   let value = EmailValidator(false, true)

import std.regex.*

private let EMAIL_SPECIAL_CHARS = "\\(\\)<>@,;:'\\\\\\\"\\.\\[\\]"
private let EMAIL_VALID_CHARS = "(\\\\.)|[^\\s" + EMAIL_SPECIAL_CHARS + "]"
private let EMAIL_QUOTED_USER = "(\"(\\\\\"|[^\"])*\")"
private let EMAIL_WORD = "((" + EMAIL_VALID_CHARS + "|')+|" + EMAIL_QUOTED_USER + ")"
private let EMAIL_REGEX = "^(.+)@(\\S+)$"
private let IP_DOMAIN_REGEX = "^\\[(.*)\\]$"
private let USER_REGEX = "^" + EMAIL_WORD + "(\\." + EMAIL_WORD + ")*$"
private let MAX_USERNAME_LEN: Int64 = 64

private func emailContainsIsoControl(value: String): Bool {
    for (character in value.toRuneArray()) {
        let pos = character.position()
        if (pos <= 0x1F || (pos >= 0x7F && pos <= 0x9F)) {
            return true
        }
    }
    false
}

public class EmailValidator {
    private static let EMAIL_VALIDATOR = EmailValidator(false, false)
    private static let EMAIL_VALIDATOR_WITH_TLD = EmailValidator(false, true)
    private static let EMAIL_VALIDATOR_WITH_LOCAL = EmailValidator(true, false)
    private static let EMAIL_VALIDATOR_WITH_LOCAL_WITH_TLD = EmailValidator(true, true)
    private static let EMAIL_PATTERN = Regex(EMAIL_REGEX)
    private static let IP_DOMAIN_PATTERN = Regex(IP_DOMAIN_REGEX)
    private static let USER_PATTERN = Regex(USER_REGEX)

    private let allowTld: Bool
    private let domainValidator: DomainValidator

    public static func getInstance(): EmailValidator {
        EMAIL_VALIDATOR
    }

    public static func getInstance(allowLocal: Bool): EmailValidator {
        getInstance(allowLocal, false)
    }

    public static func getInstance(allowLocal: Bool, allowTld: Bool): EmailValidator {
        if (allowLocal) {
            if (allowTld) {
                return EMAIL_VALIDATOR_WITH_LOCAL_WITH_TLD
            }
            return EMAIL_VALIDATOR_WITH_LOCAL
        }
        if (allowTld) {
            return EMAIL_VALIDATOR_WITH_TLD
        }
        EMAIL_VALIDATOR
    }

    protected init(allowLocal: Bool) {
        this.allowTld = false
        this.domainValidator = DomainValidator.getInstance(allowLocal)
    }

    protected init(allowLocal: Bool, allowTld: Bool) {
        this.allowTld = allowTld
        this.domainValidator = DomainValidator.getInstance(allowLocal)
    }

    public init(allowLocal: Bool, allowTld: Bool, domainValidator: DomainValidator) {
        this(allowLocal, allowTld, Some(domainValidator))
    }

    public init(allowLocal: Bool, allowTld: Bool, domainValidator: ?DomainValidator) {
        this.allowTld = allowTld
        match (domainValidator) {
            case Some(validator) =>
                if (validator.isAllowLocal() != allowLocal) {
                    throw IllegalArgumentException("DomainValidator must agree with allowLocal setting")
                }
                this.domainValidator = validator
            case None =>
                throw IllegalArgumentException("DomainValidator cannot be null")
        }
    }

    public func isValid(email: ?String): Bool {
        match (email) {
            case Some(value) =>
                if (value.endsWith(".") || emailContainsIsoControl(value)) {
                    return false
                }
                match (EmailValidator.EMAIL_PATTERN.find(value, group: true)) {
                    case Some(md) =>
                        isValidUser(md.matchString(1)) && isValidDomain(md.matchString(2))
                    case None =>
                        false
                }
            case None =>
                false
        }
    }

    protected func isValidDomain(domain: String): Bool {
        match (EmailValidator.IP_DOMAIN_PATTERN.find(domain, group: true)) {
            case Some(md) =>
                InetAddressValidator.getInstance().isValid(Some(md.matchString(1)))
            case None =>
                if (allowTld) {
                    return domainValidator.isValid(Some(domain)) ||
                        (!domain.startsWith(".") && domainValidator.isValidTld(domain))
                }
                domainValidator.isValid(Some(domain))
        }
    }

    protected func isValidUser(user: String): Bool {
        if (user.size > MAX_USERNAME_LEN) {
            return false
        }
        EmailValidator.USER_PATTERN.matches(user)
    }
}
