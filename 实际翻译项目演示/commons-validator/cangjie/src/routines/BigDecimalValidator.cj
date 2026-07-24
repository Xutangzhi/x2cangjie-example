package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public open class BigDecimalValidator <: AbstractNumberValidator {
//   static functions:
//     public static func getInstance(): BigDecimalValidator
//
//   constructors:
//     public init()
//     public init(strict: Bool)
//     protected init(strict: Bool, formatType: Int64, allowFractions: Bool)
//
//   methods:
//     public func isInRange(value: BigDecimal, min: Float64, max: Float64): Bool
//     public func maxValue(value: BigDecimal, max: Float64): Bool
//     public func minValue(value: BigDecimal, min: Float64): Bool
//     protected override func processParsedValue(value: ValidatorRawNumber, formatter: ValidatorNumberFormat): ?Any
//     public open func validate(value: ?String): ?BigDecimal
//     public open func validate(value: ?String, locale: Locale): ?BigDecimal
//     public open func validate(value: ?String, pattern: String): ?BigDecimal
//     public open func validate(value: ?String, pattern: ?String, locale: ?Locale): ?BigDecimal
// }

public open class BigDecimalValidator <: AbstractNumberValidator {
    private static let VALIDATOR = BigDecimalValidator()

    public static func getInstance(): BigDecimalValidator {
        VALIDATOR
    }

    public init() {
        this(true)
    }

    public init(strict: Bool) {
        this(strict, STANDARD_FORMAT, true)
    }

    protected init(strict: Bool, formatType: Int64, allowFractions: Bool) {
        super(strict, formatType, allowFractions)
    }

    public func isInRange(value: BigDecimal, min: Float64, max: Float64): Bool {
        value.doubleValue() >= min && value.doubleValue() <= max
    }

    public func maxValue(value: BigDecimal, max: Float64): Bool {
        value.doubleValue() <= max
    }

    public func minValue(value: BigDecimal, min: Float64): Bool {
        value.doubleValue() >= min
    }

    protected override func processParsedValue(value: ValidatorRawNumber, formatter: ValidatorNumberFormat): ?Any {
        var decimal = BigDecimal.fromNormalized(value.normalized())
        let scale = determineScale(formatter)
        if (scale >= 0) {
            decimal = decimal.setScale(scale)
        } else {
            decimal = decimal.trimFractionZeros()
        }
        Some(decimal)
    }

    public open func validate(value: ?String): ?BigDecimal {
        validate(value, None<String>, None<Locale>)
    }

    public open func validate(value: ?String, locale: Locale): ?BigDecimal {
        validate(value, None<String>, Some(locale))
    }

    public open func validate(value: ?String, pattern: String): ?BigDecimal {
        validate(value, Some(pattern), None<Locale>)
    }

    public open func validate(value: ?String, pattern: ?String, locale: ?Locale): ?BigDecimal {
        match (parse(value, pattern, locale)) {
            case Some(parsed: BigDecimal) => Some(parsed)
            case _ => None<BigDecimal>
        }
    }
}
