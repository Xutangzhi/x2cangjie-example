package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class Validator {
//   fields/properties:
//     public let countryCode: String
//     public let otherCountryCodes: Array<String>
//
//   constructors:
//     public init(countryCode: String, ibanLength: Int64, regexWithCC: String)
//     public init(countryCode: String, ibanLength: Int64, regexWithoutCC: String, otherCountryCodes: Array<String>)
//
//   methods:
//     public func getIbanLength(): Int64
//     public func getRegexValidator(): RegexValidator
// }

// public class IBANValidator {
//   static functions:
//     public static func getInstance(): IBANValidator
//
//   constructors:
//     public init()
//     public init(validators: Array<Validator>)
//
//   methods:
//     public func getDefaultValidators(): Array<Validator>
//     public func getValidator(code: ?String): ?Validator
//     public func hasValidator(code: ?String): Bool
//     public func isValid(code: ?String): Bool
//     public func setValidator(countryCode: String, length: Int64, format: String): ?Validator
//     public func setValidator(validator: Validator): ?Validator
//     public func validate(code: ?String): IBANValidatorStatus
// }

import std.collection.*
import validator.routines.checkdigit.*

private func ibanIsUpperCaseLetter(value: Rune): Bool {
    value >= r'A' && value <= r'Z'
}

private class IBANValidatorEntry {
    let key: String
    let validator: Validator

    init(key: String, validator: Validator) {
        this.key = key
        this.validator = validator
    }
}

private func ibanCreateEntries(validators: Array<Validator>): Array<IBANValidatorEntry> {
    var entries = ArrayList<IBANValidatorEntry>()
    for (validator in validators) {
        entries.add(IBANValidatorEntry(validator.countryCode, validator))
        for (otherCode in validator.otherCountryCodes) {
            entries.add(IBANValidatorEntry(otherCode, validator))
        }
    }
    entries.toArray()
}

public class Validator {
    private static let MIN_LEN: Int64 = 8
    private static let MAX_LEN: Int64 = 34

    public let countryCode: String
    public let otherCountryCodes: Array<String>
    private let regexValidator: RegexValidator
    private let ibanLength: Int64

    public init(countryCode: String, ibanLength: Int64, regexWithCC: String) {
        this(countryCode, ibanLength, regexWithCC[countryCode.size..], [])
    }

    public init(countryCode: String, ibanLength: Int64, regexWithoutCC: String, otherCountryCodes: Array<String>) {
        if (countryCode.size != 2 || !ibanIsUpperCaseLetter(countryCode.toRuneArray()[0]) || !ibanIsUpperCaseLetter(countryCode.toRuneArray()[1])) {
            throw IllegalArgumentException("Invalid country Code; must be exactly 2 upper-case characters")
        }
        if (ibanLength > MAX_LEN || ibanLength < MIN_LEN) {
            throw IllegalArgumentException("Invalid length parameter, must be in range ${MIN_LEN} to ${MAX_LEN} inclusive: ${ibanLength}")
        }
        this.countryCode = countryCode
        this.otherCountryCodes = otherCountryCodes.clone()
        this.ibanLength = ibanLength
        var regexList = ArrayList<String>()
        regexList.add(countryCode + regexWithoutCC)
        for (otherCode in this.otherCountryCodes) {
            regexList.add(otherCode + regexWithoutCC)
        }
        this.regexValidator = RegexValidator(Some(regexList.toArray()))
    }

    public func getIbanLength(): Int64 {
        ibanLength
    }

    public func getRegexValidator(): RegexValidator {
        regexValidator
    }
}

public class IBANValidator {
    private static let DEFAULT_VALIDATORS: Array<Validator> = [
        Validator("AD", 24, "AD\\d{10}[A-Z0-9]{12}"),
        Validator("AE", 23, "AE\\d{21}"),
        Validator("AL", 28, "AL\\d{10}[A-Z0-9]{16}"),
        Validator("AT", 20, "AT\\d{18}"),
        Validator("AZ", 28, "AZ\\d{2}[A-Z]{4}[A-Z0-9]{20}"),
        Validator("BA", 20, "BA\\d{18}"),
        Validator("BE", 16, "BE\\d{14}"),
        Validator("BG", 22, "BG\\d{2}[A-Z]{4}\\d{6}[A-Z0-9]{8}"),
        Validator("BH", 22, "BH\\d{2}[A-Z]{4}[A-Z0-9]{14}"),
        Validator("BI", 27, "BI\\d{25}"),
        Validator("BR", 29, "BR\\d{25}[A-Z]{1}[A-Z0-9]{1}"),
        Validator("BY", 28, "BY\\d{2}[A-Z0-9]{4}\\d{4}[A-Z0-9]{16}"),
        Validator("CH", 21, "CH\\d{7}[A-Z0-9]{12}"),
        Validator("CR", 22, "CR\\d{20}"),
        Validator("CY", 28, "CY\\d{10}[A-Z0-9]{16}"),
        Validator("CZ", 24, "CZ\\d{22}"),
        Validator("DE", 22, "DE\\d{20}"),
        Validator("DJ", 27, "DJ\\d{25}"),
        Validator("DK", 18, "DK\\d{16}"),
        Validator("DO", 28, "DO\\d{2}[A-Z0-9]{4}\\d{20}"),
        Validator("EE", 20, "EE\\d{18}"),
        Validator("EG", 29, "EG\\d{27}"),
        Validator("ES", 24, "ES\\d{22}"),
        Validator("FI", 18, "\\d{16}", ["AX"]),
        Validator("FK", 18, "FK\\d{2}[A-Z]{2}\\d{12}"),
        Validator("FO", 18, "FO\\d{16}"),
        Validator("FR", 27, "\\d{12}[A-Z0-9]{11}\\d{2}", ["GF", "GP", "MQ", "RE", "PF", "TF", "YT", "NC", "BL", "MF", "PM", "WF"]),
        Validator("GB", 22, "\\d{2}[A-Z]{4}\\d{14}", ["IM", "JE", "GG"]),
        Validator("GE", 22, "GE\\d{2}[A-Z]{2}\\d{16}"),
        Validator("GI", 23, "GI\\d{2}[A-Z]{4}[A-Z0-9]{15}"),
        Validator("GL", 18, "GL\\d{16}"),
        Validator("GR", 27, "GR\\d{9}[A-Z0-9]{16}"),
        Validator("GT", 28, "GT\\d{2}[A-Z0-9]{24}"),
        Validator("HN", 28, "HN\\d{2}[A-Z]{4}\\d{20}"),
        Validator("HR", 21, "HR\\d{19}"),
        Validator("HU", 28, "HU\\d{26}"),
        Validator("IE", 22, "IE\\d{2}[A-Z]{4}\\d{14}"),
        Validator("IL", 23, "IL\\d{21}"),
        Validator("IQ", 23, "IQ\\d{2}[A-Z]{4}\\d{15}"),
        Validator("IS", 26, "IS\\d{24}"),
        Validator("IT", 27, "IT\\d{2}[A-Z]{1}\\d{10}[A-Z0-9]{12}"),
        Validator("JO", 30, "JO\\d{2}[A-Z]{4}\\d{4}[A-Z0-9]{18}"),
        Validator("KW", 30, "KW\\d{2}[A-Z]{4}[A-Z0-9]{22}"),
        Validator("KZ", 20, "KZ\\d{5}[A-Z0-9]{13}"),
        Validator("LB", 28, "LB\\d{6}[A-Z0-9]{20}"),
        Validator("LC", 32, "LC\\d{2}[A-Z]{4}[A-Z0-9]{24}"),
        Validator("LI", 21, "LI\\d{7}[A-Z0-9]{12}"),
        Validator("LT", 20, "LT\\d{18}"),
        Validator("LU", 20, "LU\\d{5}[A-Z0-9]{13}"),
        Validator("LV", 21, "LV\\d{2}[A-Z]{4}[A-Z0-9]{13}"),
        Validator("LY", 25, "LY\\d{23}"),
        Validator("MC", 27, "MC\\d{12}[A-Z0-9]{11}\\d{2}"),
        Validator("MD", 24, "MD\\d{2}[A-Z0-9]{20}"),
        Validator("ME", 22, "ME\\d{20}"),
        Validator("MK", 19, "MK\\d{5}[A-Z0-9]{10}\\d{2}"),
        Validator("MN", 20, "MN\\d{18}"),
        Validator("MR", 27, "MR\\d{25}"),
        Validator("MT", 31, "MT\\d{2}[A-Z]{4}\\d{5}[A-Z0-9]{18}"),
        Validator("MU", 30, "MU\\d{2}[A-Z]{4}\\d{19}[A-Z]{3}"),
        Validator("NI", 28, "NI\\d{2}[A-Z]{4}\\d{20}"),
        Validator("NL", 18, "NL\\d{2}[A-Z]{4}\\d{10}"),
        Validator("NO", 15, "NO\\d{13}"),
        Validator("OM", 23, "OM\\d{5}[A-Z0-9]{16}"),
        Validator("PK", 24, "PK\\d{2}[A-Z]{4}[A-Z0-9]{16}"),
        Validator("PL", 28, "PL\\d{26}"),
        Validator("PS", 29, "PS\\d{2}[A-Z]{4}[A-Z0-9]{21}"),
        Validator("PT", 25, "PT\\d{23}"),
        Validator("QA", 29, "QA\\d{2}[A-Z]{4}[A-Z0-9]{21}"),
        Validator("RO", 24, "RO\\d{2}[A-Z]{4}[A-Z0-9]{16}"),
        Validator("RS", 22, "RS\\d{20}"),
        Validator("RU", 33, "RU\\d{16}[A-Z0-9]{15}"),
        Validator("SA", 24, "SA\\d{4}[A-Z0-9]{18}"),
        Validator("SC", 31, "SC\\d{2}[A-Z]{4}\\d{20}[A-Z]{3}"),
        Validator("SD", 18, "SD\\d{16}"),
        Validator("SE", 24, "SE\\d{22}"),
        Validator("SI", 19, "SI\\d{17}"),
        Validator("SK", 24, "SK\\d{22}"),
        Validator("SM", 27, "SM\\d{2}[A-Z]{1}\\d{10}[A-Z0-9]{12}"),
        Validator("SO", 23, "SO\\d{21}"),
        Validator("ST", 25, "ST\\d{23}"),
        Validator("SV", 28, "SV\\d{2}[A-Z]{4}\\d{20}"),
        Validator("TL", 23, "TL\\d{21}"),
        Validator("TN", 24, "TN\\d{22}"),
        Validator("TR", 26, "TR\\d{8}[A-Z0-9]{16}"),
        Validator("UA", 29, "UA\\d{8}[A-Z0-9]{19}"),
        Validator("VA", 22, "VA\\d{20}"),
        Validator("VG", 24, "VG\\d{2}[A-Z]{4}\\d{16}"),
        Validator("XK", 20, "XK\\d{18}"),
        Validator("YE", 30, "YE\\d{2}[A-Z]{4}\\d{4}[A-Z0-9]{18}")
    ]
    private static let DEFAULT_IBAN_VALIDATOR = IBANValidator(DEFAULT_VALIDATORS, false)
    private static let SHORT_CODE_LEN: Int64 = 2

    private var validatorEntries: Array<IBANValidatorEntry>
    private let modifiable: Bool

    public static func getInstance(): IBANValidator {
        DEFAULT_IBAN_VALIDATOR
    }

    private init(validators: Array<Validator>, modifiable: Bool) {
        this.validatorEntries = ibanCreateEntries(validators)
        this.modifiable = modifiable
    }

    public init() {
        this(DEFAULT_VALIDATORS, true)
    }

    public init(validators: Array<Validator>) {
        this(validators.clone(), true)
    }

    public func getDefaultValidators(): Array<Validator> {
        DEFAULT_VALIDATORS.clone()
    }

    public func getValidator(code: ?String): ?Validator {
        match (code) {
            case Some(value) =>
                if (value.size < SHORT_CODE_LEN) {
                    return None<Validator>
                }
                let key = value[0..SHORT_CODE_LEN]
                for (entry in validatorEntries) {
                    if (entry.key == key) {
                        return Some(entry.validator)
                    }
                }
                None<Validator>
            case None =>
                None<Validator>
        }
    }

    public func hasValidator(code: ?String): Bool {
        match (getValidator(code)) {
            case Some(_) => true
            case None => false
        }
    }

    public func isValid(code: ?String): Bool {
        validate(code) == IBANValidatorStatus.VALID
    }

    public func setValidator(countryCode: String, length: Int64, format: String): ?Validator {
        if (!modifiable) {
            throw IllegalStateException("The singleton validator cannot be modified")
        }
        if (length < 0) {
            var updated = ArrayList<IBANValidatorEntry>()
            var previous: ?Validator = None
            var removed = false
            for (entry in validatorEntries) {
                if (!removed && entry.key == countryCode) {
                    previous = Some(entry.validator)
                    removed = true
                } else {
                    updated.add(entry)
                }
            }
            validatorEntries = updated.toArray()
            return previous
        }
        setValidator(Validator(countryCode, length, format))
    }

    public func setValidator(validator: Validator): ?Validator {
        if (!modifiable) {
            throw IllegalStateException("The singleton validator cannot be modified")
        }
        var updated = ArrayList<IBANValidatorEntry>()
        var previous: ?Validator = None
        var replaced = false
        for (entry in validatorEntries) {
            if (!replaced && entry.key == validator.countryCode) {
                previous = Some(entry.validator)
                updated.add(IBANValidatorEntry(validator.countryCode, validator))
                replaced = true
            } else {
                updated.add(entry)
            }
        }
        if (!replaced) {
            updated.add(IBANValidatorEntry(validator.countryCode, validator))
        }
        validatorEntries = updated.toArray()
        previous
    }

    public func validate(code: ?String): IBANValidatorStatus {
        match (code) {
            case Some(value) =>
                match (getValidator(Some(value))) {
                    case Some(formatValidator) =>
                        if (value.size != formatValidator.getIbanLength()) {
                            return IBANValidatorStatus.INVALID_LENGTH
                        }
                        if (!formatValidator.getRegexValidator().isValid(Some(value))) {
                            return IBANValidatorStatus.INVALID_PATTERN
                        }
                        if (IBANCheckDigit.IBAN_CHECK_DIGIT.isValid(value)) {
                            return IBANValidatorStatus.VALID
                        }
                        IBANValidatorStatus.INVALID_CHECKSUM
                    case None =>
                        IBANValidatorStatus.UNKNOWN_COUNTRY
                }
            case None =>
                IBANValidatorStatus.UNKNOWN_COUNTRY
        }
    }
}
