package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class CurrencyValidator <: BigDecimalValidator {
//   static functions:
//     public static func getInstance(): BigDecimalValidator
//
//   constructors:
//     public init()
//     public init(strict: Bool, allowFractions: Bool)
//
//   methods:
//     protected override func parse(value: String, formatter: ValidatorNumberFormat): ?Any
//     public override func isValid(value: ?String, pattern: ?String, locale: ?Locale): Bool
//     public override func validate(value: ?String): ?BigDecimal
//     public override func validate(value: ?String, locale: Locale): ?BigDecimal
//     public override func validate(value: ?String, pattern: String): ?BigDecimal
//     public override func validate(value: ?String, pattern: ?String, locale: ?Locale): ?BigDecimal
// }

public class CurrencyValidator <: BigDecimalValidator {
    private static let VALIDATOR = CurrencyValidator()

    public static func getInstance(): BigDecimalValidator {
        VALIDATOR
    }

    public init() {
        this(true, true)
    }

    public init(strict: Bool, allowFractions: Bool) {
        super(strict, CURRENCY_FORMAT, allowFractions)
    }

    protected override func parse(value: String, formatter: ValidatorNumberFormat): ?Any {
        let parsed = super.parse(value, formatter)
        match (parsed) {
            case Some(_) =>
                return parsed
            case None =>
                ()
        }
        super.parse(value, formatter.withoutCurrencySymbol())
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
