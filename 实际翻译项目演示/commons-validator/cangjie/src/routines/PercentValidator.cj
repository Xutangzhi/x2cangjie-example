package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class PercentValidator <: BigDecimalValidator {
//   static functions:
//     public static func getInstance(): BigDecimalValidator
//
//   constructors:
//     public init()
//     public init(strict: Bool)
//
//   methods:
//     protected override func parse(value: String, formatter: ValidatorNumberFormat): ?Any
//     public override func isValid(value: ?String, pattern: ?String, locale: ?Locale): Bool
//     public override func validate(value: ?String): ?BigDecimal
//     public override func validate(value: ?String, locale: Locale): ?BigDecimal
//     public override func validate(value: ?String, pattern: String): ?BigDecimal
//     public override func validate(value: ?String, pattern: ?String, locale: ?Locale): ?BigDecimal
// }

public class PercentValidator <: BigDecimalValidator {
    private static let VALIDATOR = PercentValidator()

    public static func getInstance(): BigDecimalValidator {
        VALIDATOR
    }

    public init() {
        this(true)
    }

    public init(strict: Bool) {
        super(strict, PERCENT_FORMAT, true)
    }

    private func normalizePercentValue(value: BigDecimal, formatter: ValidatorNumberFormat): BigDecimal {
        let shifted = value.movePointLeft(2)
        let scale = determineScale(formatter)
        if (scale >= 0) {
            return shifted.setScale(scale)
        }
        shifted.trimFractionZeros()
    }

    protected override func parse(value: String, formatter: ValidatorNumberFormat): ?Any {
        let percentSymbol = "${formatter.getLocale().percentSymbol}"
        let parsed = super.parse(value, formatter)
        match (parsed) {
            case Some(parsedValue: BigDecimal) =>
                if (value.contains(percentSymbol)) {
                    return Some(normalizePercentValue(parsedValue, formatter))
                }
                return Some(parsedValue)
            case Some(_) =>
                return parsed
            case None =>
                ()
        }
        match (super.parse(value, formatter.withoutPercentSymbol())) {
            case Some(parsedValue: BigDecimal) =>
                Some(normalizePercentValue(parsedValue, formatter))
            case _ =>
                None<Any>
        }
    }

    public override func isValid(value: ?String, pattern: ?String, locale: ?Locale): Bool {
        match (validate(value, pattern, locale)) {
            case Some(_) => true
            case None => false
        }
    }

    public override func validate(value: ?String): ?BigDecimal {
        validate(value, None<String>, None<Locale>)
    }

    public override func validate(value: ?String, locale: Locale): ?BigDecimal {
        validate(value, None<String>, Some(locale))
    }

    public override func validate(value: ?String, pattern: String): ?BigDecimal {
        validate(value, Some(pattern), None<Locale>)
    }

    public override func validate(value: ?String, pattern: ?String, locale: ?Locale): ?BigDecimal {
        match (parse(value, pattern, locale)) {
            case Some(parsed: BigDecimal) => Some(parsed)
            case _ => None<BigDecimal>
        }
    }
}
