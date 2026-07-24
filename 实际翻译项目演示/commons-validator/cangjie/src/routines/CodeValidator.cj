package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public open class CodeValidator {
//   constructors:
//     public init(regexValidator: RegexValidator, checkdigit: ?CheckDigit)
//     public init(regexValidator: RegexValidator, length: Int64, checkdigit: ?CheckDigit)
//     public init(regexValidator: RegexValidator, minLength: Int64, maxLength: Int64, checkdigit: ?CheckDigit)
//     public init(regex: ?String, checkdigit: ?CheckDigit)
//     public init(regex: ?String, length: Int64, checkdigit: ?CheckDigit)
//     public init(regex: ?String, minLength: Int64, maxLength: Int64, checkdigit: ?CheckDigit)
//
//   methods:
//     public func getCheckDigit(): ?CheckDigit
//     public func getMaxLength(): Int64
//     public func getMinLength(): Int64
//     public func getRegexValidator(): ?RegexValidator
//     public open func isValid(input: ?String): Bool
//     public open func validate(input: ?String): ?String
// }

// top-level functions:
//   public func serializationSupportCanSerialize(value: Any): Bool
//   public func serializationSupportRoundTrip(value: Any): ?Any

import validator.routines.checkdigit.*

public func serializationSupportCanSerialize(value: Any): Bool {
    true
}

public func serializationSupportRoundTrip(value: Any): ?Any {
    Some(value)
}

public open class CodeValidator {
    private let regexValidator: ?RegexValidator
    private let minLength: Int64
    private let maxLength: Int64
    private let checkdigit: ?CheckDigit

    public init(regexValidator: RegexValidator, checkdigit: ?CheckDigit) {
        this.regexValidator = Some(regexValidator)
        this.minLength = -1
        this.maxLength = -1
        this.checkdigit = checkdigit
    }

    public init(regexValidator: RegexValidator, length: Int64, checkdigit: ?CheckDigit) {
        this.regexValidator = Some(regexValidator)
        this.minLength = length
        this.maxLength = length
        this.checkdigit = checkdigit
    }

    public init(regexValidator: RegexValidator, minLength: Int64, maxLength: Int64, checkdigit: ?CheckDigit) {
        this.regexValidator = Some(regexValidator)
        this.minLength = minLength
        this.maxLength = maxLength
        this.checkdigit = checkdigit
    }

    public init(regex: ?String, checkdigit: ?CheckDigit) {
        this(regex, -1, -1, checkdigit)
    }

    public init(regex: ?String, length: Int64, checkdigit: ?CheckDigit) {
        this(regex, length, length, checkdigit)
    }

    public init(regex: ?String, minLength: Int64, maxLength: Int64, checkdigit: ?CheckDigit) {
        match (regex) {
            case Some(text) =>
                if (text.trimAscii().isEmpty()) {
                    this.regexValidator = None<RegexValidator>
                } else {
                    this.regexValidator = Some(RegexValidator(text))
                }
            case None =>
                this.regexValidator = None<RegexValidator>
        }
        this.minLength = minLength
        this.maxLength = maxLength
        this.checkdigit = checkdigit
    }

    public func getCheckDigit(): ?CheckDigit {
        checkdigit
    }

    public func getMaxLength(): Int64 {
        maxLength
    }

    public func getMinLength(): Int64 {
        minLength
    }

    public func getRegexValidator(): ?RegexValidator {
        regexValidator
    }

    public open func isValid(input: ?String): Bool {
        match (validate(input)) {
            case Some(_) => true
            case None => false
        }
    }

    public open func validate(input: ?String): ?String {
        match (input) {
            case Some(value) =>
                var code = value.trimAscii()
                if (code.isEmpty()) {
                    return None<String>
                }
                match (regexValidator) {
                    case Some(validator) =>
                        match (validator.validate(Some(code))) {
                            case Some(parsed) => code = parsed
                            case None => return None<String>
                        }
                    case None => ()
                }
                if ((minLength >= 0 && code.size < minLength) || (maxLength >= 0 && code.size > maxLength)) {
                    return None<String>
                }
                match (checkdigit) {
                    case Some(validator) =>
                        if (!validator.isValid(code)) {
                            return None<String>
                        }
                    case None => ()
                }
                Some(code)
            case None =>
                None<String>
        }
    }
}
