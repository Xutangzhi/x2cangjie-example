package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class BigIntegerValidator <: AbstractNumberValidator {
//   static functions:
//     public static func getInstance(): BigIntegerValidator
//
//   constructors:
//     public init()
//     public init(strict: Bool, formatType: Int64)
//
//   methods:
//     public func isInRange(value: BigInteger, min: Int64, max: Int64): Bool
//     public func maxValue(value: BigInteger, max: Int64): Bool
//     public func minValue(value: BigInteger, min: Int64): Bool
//     protected override func processParsedValue(value: ValidatorRawNumber, formatter: ValidatorNumberFormat): ?Any
//     public func validate(value: ?String): ?BigInteger
//     public func validate(value: ?String, locale: Locale): ?BigInteger
//     public func validate(value: ?String, pattern: String): ?BigInteger
//     public func validate(value: ?String, pattern: ?String, locale: ?Locale): ?BigInteger
// }

public class BigIntegerValidator <: AbstractNumberValidator {
    private static let VALIDATOR = BigIntegerValidator()

    public static func getInstance(): BigIntegerValidator {
        VALIDATOR
    }

    public init() {
        this(true, STANDARD_FORMAT)
    }

    public init(strict: Bool, formatType: Int64) {
        super(strict, formatType, false)
    }

    public func isInRange(value: BigInteger, min: Int64, max: Int64): Bool {
        let longValue = value.longValue()
        longValue >= min && longValue <= max
    }

    public func maxValue(value: BigInteger, max: Int64): Bool {
        value.longValue() <= max
    }

    public func minValue(value: BigInteger, min: Int64): Bool {
        value.longValue() >= min
    }

    protected override func processParsedValue(value: ValidatorRawNumber, formatter: ValidatorNumberFormat): ?Any {
        Some(BigInteger.fromNormalized(value.normalized()))
    }

    public func validate(value: ?String): ?BigInteger {
        validate(value, None<String>, None<Locale>)
    }

    public func validate(value: ?String, locale: Locale): ?BigInteger {
        validate(value, None<String>, Some(locale))
    }

    public func validate(value: ?String, pattern: String): ?BigInteger {
        validate(value, Some(pattern), None<Locale>)
    }

    public func validate(value: ?String, pattern: ?String, locale: ?Locale): ?BigInteger {
        match (parse(value, pattern, locale)) {
            case Some(parsed: BigInteger) => Some(parsed)
            case _ => None<BigInteger>
        }
    }
}
