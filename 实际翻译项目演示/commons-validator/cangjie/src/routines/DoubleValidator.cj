package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class DoubleValidator <: AbstractNumberValidator {
//   static functions:
//     public static func getInstance(): DoubleValidator
//
//   constructors:
//     public init()
//     public init(strict: Bool, formatType: Int64)
//
//   methods:
//     public func isInRange(value: Float64, min: Float64, max: Float64): Bool
//     public func maxValue(value: Float64, max: Float64): Bool
//     public func minValue(value: Float64, min: Float64): Bool
//     protected override func processParsedValue(value: ValidatorRawNumber, formatter: ValidatorNumberFormat): ?Any
//     public func validate(value: ?String): ?Float64
//     public func validate(value: ?String, locale: Locale): ?Float64
//     public func validate(value: ?String, pattern: String): ?Float64
//     public func validate(value: ?String, pattern: ?String, locale: ?Locale): ?Float64
// }

public class DoubleValidator <: AbstractNumberValidator {
    private static let VALIDATOR = DoubleValidator()

    public static func getInstance(): DoubleValidator {
        VALIDATOR
    }

    public init() {
        this(true, STANDARD_FORMAT)
    }

    public init(strict: Bool, formatType: Int64) {
        super(strict, formatType, true)
    }

    public func isInRange(value: Float64, min: Float64, max: Float64): Bool {
        value >= min && value <= max
    }

    public func maxValue(value: Float64, max: Float64): Bool {
        value <= max
    }

    public func minValue(value: Float64, min: Float64): Bool {
        value >= min
    }

    protected override func processParsedValue(value: ValidatorRawNumber, formatter: ValidatorNumberFormat): ?Any {
        match (value.doubleValue()) {
            case Some(parsed) =>
                if (parsed > ROUTINES_DOUBLE_MAX || parsed < -ROUTINES_DOUBLE_MAX) {
                    return None<Any>
                }
                Some(parsed)
            case None =>
                None<Any>
        }
    }

    public func validate(value: ?String): ?Float64 {
        validate(value, None<String>, None<Locale>)
    }

    public func validate(value: ?String, locale: Locale): ?Float64 {
        validate(value, None<String>, Some(locale))
    }

    public func validate(value: ?String, pattern: String): ?Float64 {
        validate(value, Some(pattern), None<Locale>)
    }

    public func validate(value: ?String, pattern: ?String, locale: ?Locale): ?Float64 {
        match (parse(value, pattern, locale)) {
            case Some(parsed: Float64) => Some(parsed)
            case _ => None<Float64>
        }
    }
}
