package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class ISINValidator {
//   static functions:
//     public static func getInstance(checkCountryCode: Bool): ISINValidator
//
//   methods:
//     public func isValid(code: ?String): Bool
//     public func validate(code: ?String): ?String
// }

import validator.routines.checkdigit.*

public class ISINValidator {
    private static let ISIN_REGEX = "([A-Z]{2}[A-Z0-9]{9}[0-9])"
    private static let VALIDATOR = CodeValidator(ISIN_REGEX, 12, Some(ISINCheckDigit.ISIN_CHECK_DIGIT))
    private static let ISIN_VALIDATOR_FALSE = ISINValidator(false)
    private static let ISIN_VALIDATOR_TRUE = ISINValidator(true)
    private static let SPECIALS: Array<String> = [
        "AA", "AC", "AD", "AE", "AF", "AG", "AI", "AL", "AM", "AN", "AO", "AP", "AQ", "AR", "AS", "AT", "AU",
        "AW", "AX", "AZ", "BA", "BB", "BD", "BE", "BF", "BG", "BH", "BI", "BJ", "BL", "BM", "BN", "BO", "BQ",
        "BR", "BS", "BT", "BU", "BV", "BW", "BX", "BY", "BZ", "CA", "CC", "CD", "CF", "CG", "CH", "CI", "CK",
        "CL", "CM", "CN", "CO", "CP", "CQ", "CR", "CS", "CT", "CU", "CV", "CW", "CX", "CY", "CZ", "DD", "DE",
        "DG", "DJ", "DK", "DM", "DO", "DY", "DZ", "EA", "EC", "EE", "EF", "EG", "EH", "EM", "EP", "ER", "ES",
        "ET", "EU", "EV", "EW", "EZ", "FI", "FJ", "FK", "FL", "FM", "FO", "FQ", "FR", "FX", "GA", "GB", "GC",
        "GD", "GE", "GF", "GG", "GH", "GI", "GL", "GM", "GN", "GP", "GQ", "GR", "GS", "GT", "GU", "GW", "GY",
        "HK", "HM", "HN", "HR", "HT", "HU", "HV", "IB", "IC", "ID", "IE", "IL", "IM", "IN", "IO", "IQ", "IR",
        "IS", "IT", "JA", "JE", "JM", "JO", "JP", "JT", "KE", "KG", "KH", "KI", "KM", "KN", "KP", "KR", "KW",
        "KY", "KZ", "LA", "LB", "LC", "LF", "LI", "LK", "LR", "LS", "LT", "LU", "LV", "LY", "MA", "MC", "MD",
        "ME", "MF", "MG", "MH", "MI", "MK", "ML", "MM", "MN", "MO", "MP", "MQ", "MR", "MS", "MT", "MU", "MV",
        "MW", "MX", "MY", "MZ", "NA", "NC", "NE", "NF", "NG", "NH", "NI", "NL", "NO", "NP", "NQ", "NR", "NT",
        "NU", "NZ", "OA", "OM", "PA", "PC", "PE", "PF", "PG", "PH", "PI", "PK", "PL", "PM", "PN", "PR", "PS",
        "PT", "PU", "PW", "PY", "PZ", "QA", "QM", "QN", "QO", "QP", "QQ", "QR", "QS", "QT", "QU", "QV", "QW",
        "QX", "QY", "QZ", "RA", "RB", "RC", "RE", "RH", "RI", "RL", "RM", "RN", "RO", "RP", "RS", "RU", "RW",
        "SA", "SB", "SC", "SD", "SE", "SF", "SG", "SH", "SI", "SJ", "SK", "SL", "SM", "SN", "SO", "SR", "SS",
        "ST", "SU", "SV", "SX", "SY", "SZ", "TA", "TC", "TD", "TF", "TG", "TH", "TJ", "TK", "TL", "TM", "TN",
        "TO", "TP", "TR", "TT", "TV", "TW", "TZ", "UA", "UG", "UK", "UM", "UN", "US", "UY", "UZ", "VA", "VC",
        "VD", "VE", "VG", "VI", "VN", "VU", "WF", "WG", "WK", "WL", "WO", "WS", "WV", "XA", "XB", "XC", "XD",
        "XE", "XF", "XG", "XH", "XI", "XJ", "XK", "XL", "XM", "XN", "XO", "XP", "XQ", "XR", "XS", "XT", "XU",
        "XV", "XW", "XX", "XY", "XZ", "YD", "YE", "YT", "YU", "YV", "ZA", "ZM", "ZR", "ZW", "ZZ"
    ]

    private let checkCountryCode: Bool

    public static func getInstance(checkCountryCode: Bool): ISINValidator {
        if (checkCountryCode) {
            return ISIN_VALIDATOR_TRUE
        }
        ISIN_VALIDATOR_FALSE
    }

    private static func isAllowedCountryCode(code: String): Bool {
        for (value in SPECIALS) {
            if (value == code) {
                return true
            }
        }
        false
    }

    private init(checkCountryCode: Bool) {
        this.checkCountryCode = checkCountryCode
    }

    public func isValid(code: ?String): Bool {
        match (VALIDATOR.validate(code)) {
            case Some(value) =>
                if (checkCountryCode) {
                    return ISINValidator.isAllowedCountryCode(value[0..2])
                }
                true
            case None =>
                false
        }
    }

    public func validate(code: ?String): ?String {
        match (VALIDATOR.validate(code)) {
            case Some(value) =>
                if (checkCountryCode && !ISINValidator.isAllowedCountryCode(value[0..2])) {
                    return None<String>
                }
                Some(value)
            case None =>
                None<String>
        }
    }
}
