package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class IntegerValidator <: AbstractNumberValidator {
//   static functions:
//     public static func getInstance(): IntegerValidator
//
//   constructors:
//     public init()
//     public init(strict: Bool, formatType: Int64)
//
//   methods:
//     public func isInRange(value: Int64, min: Int64, max: Int64): Bool
//     public func maxValue(value: Int64, max: Int64): Bool
//     public func minValue(value: Int64, min: Int64): Bool
//     protected override func processParsedValue(value: ValidatorRawNumber, formatter: ValidatorNumberFormat): ?Any
//     public func validate(value: ?String): ?Int64
//     public func validate(value: ?String, locale: Locale): ?Int64
//     public func validate(value: ?String, pattern: String): ?Int64
//     public func validate(value: ?String, pattern: ?String, locale: ?Locale): ?Int64
// }

public class IntegerValidator <: AbstractNumberValidator {
    private static let VALIDATOR = IntegerValidator()

    public static func getInstance(): IntegerValidator {
        VALIDATOR
    }

    public init() {
        this(true, STANDARD_FORMAT)
    }

    public init(strict: Bool, formatType: Int64) {
        super(strict, formatType, false)
    }

    public func isInRange(value: Int64, min: Int64, max: Int64): Bool {
        value >= min && value <= max
    }

    public func maxValue(value: Int64, max: Int64): Bool {
        value <= max
    }

    public func minValue(value: Int64, min: Int64): Bool {
        value >= min
    }

    protected override func processParsedValue(value: ValidatorRawNumber, formatter: ValidatorNumberFormat): ?Any {
        let normalized = value.normalized()
        if (!numberFitsSignedRange(normalized, "-2147483648", "2147483647")) {
            return None<Any>
        }
        match (numberParseInt64Exact(normalized)) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    }

    public func validate(value: ?String): ?Int64 {
        validate(value, None<String>, None<Locale>)
    }

    public func validate(value: ?String, locale: Locale): ?Int64 {
        validate(value, None<String>, Some(locale))
    }

    public func validate(value: ?String, pattern: String): ?Int64 {
        validate(value, Some(pattern), None<Locale>)
    }

    public func validate(value: ?String, pattern: ?String, locale: ?Locale): ?Int64 {
        match (parse(value, pattern, locale)) {
            case Some(parsed: Int64) => Some(parsed)
            case _ => None<Int64>
        }
    }
}
