package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public enum IBANValidatorStatus {
//   enum cases:
//     | VALID
//     | UNKNOWN_COUNTRY
//     | INVALID_LENGTH
//     | INVALID_PATTERN
//     | INVALID_CHECKSUM
//
//   operator methods:
//     public operator func ==(right: IBANValidatorStatus): Bool
//     public operator func !=(right: IBANValidatorStatus): Bool
//
//   methods:
//     public func toString(): String
// }

public enum IBANValidatorStatus <: ToString & Equatable<IBANValidatorStatus> {
    | VALID
    | UNKNOWN_COUNTRY
    | INVALID_LENGTH
    | INVALID_PATTERN
    | INVALID_CHECKSUM

    public func toString(): String {
        match (this) {
            case VALID => "VALID"
            case UNKNOWN_COUNTRY => "UNKNOWN_COUNTRY"
            case INVALID_LENGTH => "INVALID_LENGTH"
            case INVALID_PATTERN => "INVALID_PATTERN"
            case INVALID_CHECKSUM => "INVALID_CHECKSUM"
        }
    }

    public operator func ==(right: IBANValidatorStatus): Bool {
        this.toString() == right.toString()
    }

    public operator func !=(right: IBANValidatorStatus): Bool {
        !(this == right)
    }
}
