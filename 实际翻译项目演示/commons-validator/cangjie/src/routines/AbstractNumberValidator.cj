package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class BigInteger {
//   static functions:
//     public static func fromNormalized(source: String): BigInteger
//
//   constructors:
//     public init(source: String)
//
//   operator methods:
//     public operator func ==(right: BigInteger): Bool
//     public operator func !=(right: BigInteger): Bool
//
//   methods:
//     public func longValue(): Int64
//     public func toString(): String
// }

// public class BigDecimal {
//   static functions:
//     public static func fromNormalized(source: String): BigDecimal
//
//   constructors:
//     public init(source: String)
//
//   operator methods:
//     public operator func ==(right: BigDecimal): Bool
//     public operator func !=(right: BigDecimal): Bool
//
//   methods:
//     public func doubleValue(): Float64
//     public func longValue(): Int64
//     public func movePointLeft(places: Int64): BigDecimal
//     public func setScale(scale: Int64): BigDecimal
//     public func trimFractionZeros(): BigDecimal
//     public func toString(): String
// }

// public class ValidatorRawNumber {
//   constructors:
//     public init(normalizedValue: String)
//
//   methods:
//     public func normalized(): String
//     public func hasFraction(): Bool
//     public func longValue(): ?Int64
//     public func doubleValue(): ?Float64
//     public func movePointLeft(places: Int64): ValidatorRawNumber
// }

// public class ValidatorNumberFormat {
//   constructors:
//     public init(locale: Locale, formatType: Int64, groupingSeparator: Rune, decimalSeparator: Rune, groupingSize: Int64, minimumFractionDigits: Int64, maximumFractionDigits: Int64, parseIntegerOnly: Bool, decimalAllowed: Bool, percentRequired: Bool)
//
//   methods:
//     public func getFormatType(): Int64
//     public func getMinimumFractionDigits(): Int64
//     public func getMaximumFractionDigits(): Int64
//     public func getGroupingSize(): Int64
//     public func isParseIntegerOnly(): Bool
//     public func withPercentRequired(required: Bool): ValidatorNumberFormat
//     public func withoutCurrencySymbol(): ValidatorNumberFormat
//     public func withoutPercentSymbol(): ValidatorNumberFormat
//     func getLocale(): Locale
//     public func parse(value: String, strict: Bool): ?ValidatorRawNumber
//     public func format(value: Any): String
// }

// public abstract class AbstractNumberValidator <: AbstractFormatValidator {
//   static fields/constants:
//     public static let STANDARD_FORMAT: Int64 = 0
//     public static let CURRENCY_FORMAT: Int64 = 1
//     public static let PERCENT_FORMAT: Int64 = 2
//
//   constructors:
//     public init(strict: Bool, formatType: Int64, allowFractions: Bool)
//
//   methods:
//     protected func parseValue(value: ?String, pattern: ?String, locale: ?Locale): ?Any
//     public func parse(value: ?String): ?Any
//     public func parse(value: ?String, locale: Locale): ?Any
//     public func parse(value: ?String, pattern: String): ?Any
//     public func parse(value: ?String, pattern: ?String, locale: ?Locale): ?Any
//     protected func getFormat(locale: Locale): ValidatorNumberFormat
//     protected override func getFormat(pattern: ?String, locale: ?Locale): ValidatorNumberFormat
//     public func determineScale(format: ValidatorNumberFormat): Int64
//     public func getFormatType(): Int64
//     public func isAllowFractions(): Bool
//     public func isInRange(value: Any, min: Any, max: Any): Bool
//     public func maxValue(value: Any, max: Any): Bool
//     public func minValue(value: Any, min: Any): Bool
//     protected func processParsedValue(value: Any, formatter: ValidatorNumberFormat): ?Any
//     public open override func isValid(value: ?String, pattern: ?String, locale: ?Locale): Bool
// }

import std.collection.*

let ROUTINES_FLOAT_MAX: Float64 = 3.4028234663852886E38
let ROUTINES_FLOAT_MIN_POSITIVE: Float64 = 1.401298464324817E-45
let ROUTINES_DOUBLE_MAX: Float64 = 1.7976931348623157E308

private func numberBlankOrNull(value: ?String): Bool {
    match (value) {
        case Some(text) => text.trimAscii().isEmpty()
        case None => true
    }
}

private func numberTrimLeadingZeros(value: String): String {
    if (value.isEmpty()) {
        return "0"
    }
    var index = 0
    let runes = value.toRuneArray()
    while (index < runes.size - 1 && runes[index] == r'0') {
        index++
    }
    value[index..]
}

private func numberNormalizeInteger(value: String): String {
    if (value.isEmpty()) {
        return "0"
    }
    let negative = value.startsWith("-")
    let core = if (negative || value.startsWith("+")) { value[1..] } else { value }
    let normalized = numberTrimLeadingZeros(core)
    if (negative && normalized != "0") {
        return "-" + normalized
    }
    normalized
}

private func numberSplitNormalizedInteger(value: String): (Bool, String) {
    let negative = value.startsWith("-")
    let core = if (negative) { value[1..] } else { value }
    (negative, numberTrimLeadingZeros(core))
}

private func numberComparePositiveIntegers(left: String, right: String): Int64 {
    let normalizedLeft = numberTrimLeadingZeros(left)
    let normalizedRight = numberTrimLeadingZeros(right)
    if (normalizedLeft.size < normalizedRight.size) {
        return -1
    }
    if (normalizedLeft.size > normalizedRight.size) {
        return 1
    }
    if (normalizedLeft < normalizedRight) {
        return -1
    }
    if (normalizedLeft > normalizedRight) {
        return 1
    }
    0
}

private func numberCompareSignedIntegers(left: String, right: String): Int64 {
    let (leftNegative, leftCore) = numberSplitNormalizedInteger(left)
    let (rightNegative, rightCore) = numberSplitNormalizedInteger(right)
    if (leftNegative && !rightNegative) {
        return -1
    }
    if (!leftNegative && rightNegative) {
        return 1
    }
    let comparison = numberComparePositiveIntegers(leftCore, rightCore)
    if (leftNegative) {
        return -comparison
    }
    comparison
}

func numberFitsSignedRange(value: String, minValue: String, maxValue: String): Bool {
    numberCompareSignedIntegers(value, minValue) >= 0 && numberCompareSignedIntegers(value, maxValue) <= 0
}

func numberParseInt64Exact(value: String): ?Int64 {
    if (!numberFitsSignedRange(value, "-9223372036854775808", "9223372036854775807")) {
        return None<Int64>
    }
    let normalized = numberNormalizeInteger(value)
    let negative = normalized.startsWith("-")
    let core = if (negative) { normalized[1..] } else { normalized }
    var result: Int64 = 0
    for (character in core.toRuneArray()) {
        if (!character.isAsciiNumber()) {
            return None<Int64>
        }
        let digit = character.position() - r'0'.position()
        result = if (negative) { result * 10 - digit } else { result * 10 + digit }
    }
    Some(result)
}

private func numberPow10(exponent: Int64): Float64 {
    if (exponent == 0) {
        return 1.0
    }
    var power = 1.0
    if (exponent > 0) {
        for (_ in 0..exponent) {
            power *= 10.0
        }
        return power
    }
    for (_ in 0..(-exponent)) {
        power /= 10.0
    }
    power
}

private func numberParseFloatLiteral(value: String, allowSuffix: Bool): ?Float64 {
    let trimmed = value.trimAscii()
    if (trimmed.isEmpty()) {
        return None<Float64>
    }
    var text = trimmed
    let last = text.toRuneArray()[text.toRuneArray().size - 1]
    if (allowSuffix && (last == r'f' || last == r'F' || last == r'd' || last == r'D')) {
        text = text[0..text.size - 1]
    }
    if (text.isEmpty()) {
        return None<Float64>
    }
    var index = 0
    var negative = false
    if (text.startsWith("-")) {
        negative = true
        index = 1
    } else if (text.startsWith("+")) {
        index = 1
    }
    if (index >= text.size) {
        return None<Float64>
    }

    let runes = text.toRuneArray()
    var seenDigit = false
    var seenDot = false
    var seenExponent = false
    var exponentSign = 1
    var exponentValue: Int64 = 0
    var fractionalDigits: Int64 = 0
    var mantissa = 0.0

    while (index < runes.size) {
        let character = runes[index]
        if (character.isAsciiNumber()) {
            seenDigit = true
            if (!seenExponent) {
                mantissa = mantissa * 10.0 + Float64(character.position() - r'0'.position())
                if (seenDot) {
                    fractionalDigits++
                }
            } else {
                exponentValue = exponentValue * 10 + character.position() - r'0'.position()
            }
            index++
            continue
        }
        if (character == r'.') {
            if (seenDot || seenExponent) {
                return None<Float64>
            }
            seenDot = true
            index++
            continue
        }
        if (character == r'e' || character == r'E') {
            if (seenExponent || !seenDigit) {
                return None<Float64>
            }
            seenExponent = true
            index++
            if (index < runes.size && (runes[index] == r'+' || runes[index] == r'-')) {
                exponentSign = if (runes[index] == r'-') { -1 } else { 1 }
                index++
            }
            if (index >= runes.size || !runes[index].isAsciiNumber()) {
                return None<Float64>
            }
            continue
        }
        return None<Float64>
    }
    if (!seenDigit) {
        return None<Float64>
    }
    let power = exponentSign * exponentValue - fractionalDigits
    if (power > 308) {
        return None<Float64>
    }
    if (power < -400) {
        return Some(0.0)
    }
    var result = mantissa * numberPow10(power)
    if (negative) {
        result = -result
    }
    Some(result)
}

private func numberSplitDecimalString(value: String): (Bool, String, String) {
    let negative = value.startsWith("-")
    let unsigned = if (negative || value.startsWith("+")) { value[1..] } else { value }
    if (let Some(dotIndex) <- unsigned.indexOf(".")) {
        let intPart = if (dotIndex == 0) { "0" } else { unsigned[0..dotIndex] }
        let fraction = if (dotIndex + 1 >= unsigned.size) { "" } else { unsigned[dotIndex + 1..] }
        return (negative, numberTrimLeadingZeros(intPart), fraction)
    }
    (negative, numberTrimLeadingZeros(unsigned), "")
}

private func numberComposeDecimalString(negative: Bool, integerPart: String, fractionPart: String): String {
    let normalizedInt = numberTrimLeadingZeros(integerPart)
    let sign = if (negative && (normalizedInt != "0" || !numberAllRunesEqual(fractionPart, r'0'))) { "-" } else { "" }
    if (fractionPart.isEmpty()) {
        return sign + normalizedInt
    }
    sign + normalizedInt + "." + fractionPart
}

private func numberRemoveFractionTrailingZeros(value: String): String {
    let (negative, integerPart, fractionPart) = numberSplitDecimalString(value)
    if (fractionPart.isEmpty()) {
        return numberComposeDecimalString(negative, integerPart, "")
    }
    var end = fractionPart.size
    while (end > 0 && fractionPart[end - 1] == "0"[0]) {
        end--
    }
    if (end == 0) {
        return numberComposeDecimalString(negative, integerPart, "")
    }
    numberComposeDecimalString(negative, integerPart, fractionPart[0..end])
}

private func numberMovePointLeft(value: String, places: Int64): String {
    let (negative, integerPart, fractionPart) = numberSplitDecimalString(value)
    let digits = numberTrimLeadingZeros(integerPart + fractionPart)
    let originalScale = fractionPart.size
    let newScale = originalScale + places
    if (newScale <= 0) {
        var zeroRunes = ArrayList<Rune>()
        for (_ in 0..(-newScale)) {
            zeroRunes.add(r'0')
        }
        return numberComposeDecimalString(negative, digits + String(zeroRunes), "")
    }
    if (digits.size <= newScale) {
        let zeroPaddingSize = newScale - digits.size
        var paddingRunes = ArrayList<Rune>()
        for (_ in 0..zeroPaddingSize) {
            paddingRunes.add(r'0')
        }
        return numberComposeDecimalString(negative, "0", String(paddingRunes) + digits)
    }
    let cut = digits.size - newScale
    numberComposeDecimalString(negative, digits[0..cut], digits[cut..])
}

private func numberSetScaleDown(value: String, scale: Int64): String {
    let (negative, integerPart, fractionPart) = numberSplitDecimalString(value)
    if (scale <= 0) {
        return numberComposeDecimalString(negative, integerPart, "")
    }
    if (fractionPart.size == scale) {
        return numberComposeDecimalString(negative, integerPart, fractionPart)
    }
    if (fractionPart.size > scale) {
        return numberComposeDecimalString(negative, integerPart, fractionPart[0..scale])
    }
    var paddingRunes = ArrayList<Rune>()
    for (_ in 0..(scale - fractionPart.size)) {
        paddingRunes.add(r'0')
    }
    numberComposeDecimalString(negative, integerPart, fractionPart + String(paddingRunes))
}

private func numberAllRunesEqual(value: String, expected: Rune): Bool {
    for (character in value.toRuneArray()) {
        if (character != expected) {
            return false
        }
    }
    true
}

func numberCurrencySymbol(locale: Locale): String {
    if (locale == Locale.UK) {
        return "£"
    }
    if (locale == Locale.US) {
        return "$"
    }
    "¤"
}

private func numberDefaultLocale(locale: ?Locale): Locale {
    match (locale) {
        case Some(value) => value
        case None => Locale.getDefault()
    }
}

private func numberPatternIndexOfLast(pattern: String, character: Rune): Int64 {
    var found: Int64 = -1
    let runes = pattern.toRuneArray()
    for (i in 0..runes.size) {
        if (runes[i] == character) {
            found = i
        }
    }
    found
}

func numberAnyToDecimalText(value: Any): String {
    match (value) {
        case numeric: Int64 => "${numeric}"
        case numeric: Float64 => "${numeric}"
        case numeric: BigInteger => numeric.toString()
        case numeric: BigDecimal => numeric.toString()
        case _ => "0"
    }
}

private func numberPatternFirstPlaceholder(pattern: String): Int64 {
    let runes = pattern.toRuneArray()
    for (i in 0..runes.size) {
        if (runes[i] == r'#' || runes[i] == r'0' || runes[i] == r',' || runes[i] == r'.') {
            return i
        }
    }
    -1
}

private func numberPatternLastPlaceholder(pattern: String): Int64 {
    let runes = pattern.toRuneArray()
    var result: Int64 = -1
    for (i in 0..runes.size) {
        if (runes[i] == r'#' || runes[i] == r'0' || runes[i] == r',' || runes[i] == r'.') {
            result = i
        }
    }
    result
}

private func numberPatternGroupingSize(numericPattern: String): Int64 {
    let lastGroupingIndex = numberPatternIndexOfLast(numericPattern, r',')
    if (lastGroupingIndex < 0) {
        return 0
    }
    let decimalIndex = numberPatternIndexOfLast(numericPattern, r'.')
    let end = if (decimalIndex >= 0) { decimalIndex } else { numericPattern.size }
    end - lastGroupingIndex - 1
}

private func numberPatternMinFractionDigits(numericPattern: String): Int64 {
    if (let Some(dotIndex) <- numericPattern.indexOf(".")) {
        var count = 0
        for (character in numericPattern[dotIndex + 1..].toRuneArray()) {
            if (character == r'0') {
                count++
            }
        }
        return count
    }
    0
}

private func numberPatternMaxFractionDigits(numericPattern: String): Int64 {
    if (let Some(dotIndex) <- numericPattern.indexOf(".")) {
        var count = 0
        for (character in numericPattern[dotIndex + 1..].toRuneArray()) {
            if (character == r'0' || character == r'#') {
                count++
            }
        }
        return count
    }
    0
}

private func numberPatternTranslateAffix(pattern: String, locale: Locale): String {
    pattern.replace("¤", numberCurrencySymbol(locale)).replace("%", "${locale.percentSymbol}")
}

private func numberStringSliceByRunes(value: String, start: Int64, endExclusive: Int64): String {
    let runes = value.toRuneArray()
    var out = ArrayList<Rune>()
    for (i in start..endExclusive) {
        out.add(runes[i])
    }
    String(out)
}

private func numberRunesMatchAt(valueRunes: Array<Rune>, index: Int64, expected: String): Bool {
    let expectedRunes = expected.toRuneArray()
    if (index + expectedRunes.size > valueRunes.size) {
        return false
    }
    for (i in 0..expectedRunes.size) {
        if (valueRunes[index + i] != expectedRunes[i]) {
            return false
        }
    }
    true
}

private func numberStringToFormatter(
    patternText: String,
    locale: Locale,
    formatType: Int64,
    allowFractions: Bool
): ValidatorNumberFormat {
    let parts = patternText.split(";")
    let positivePattern = parts[0]
    let negativePattern = if (parts.size > 1) { parts[1] } else { "-" + positivePattern }
    let firstPlaceholder = numberPatternFirstPlaceholder(positivePattern)
    let lastPlaceholder = numberPatternLastPlaceholder(positivePattern)
    if (firstPlaceholder < 0 || lastPlaceholder < 0) {
        return ValidatorNumberFormat(locale, formatType, locale.groupingSeparator, locale.decimalSeparator, 0, 0, 0, !allowFractions, allowFractions, false)
    }
    let positivePrefix = numberPatternTranslateAffix(numberStringSliceByRunes(positivePattern, 0, firstPlaceholder), locale)
    let positiveSuffix = numberPatternTranslateAffix(numberStringSliceByRunes(positivePattern, lastPlaceholder + 1, positivePattern.toRuneArray().size), locale)
    let negativeFirst = numberPatternFirstPlaceholder(negativePattern)
    let negativeLast = numberPatternLastPlaceholder(negativePattern)
    let negativePrefix = if (negativeFirst >= 0) { numberPatternTranslateAffix(numberStringSliceByRunes(negativePattern, 0, negativeFirst), locale) } else { "-" + positivePrefix }
    let negativeSuffix = if (negativeLast >= 0) { numberPatternTranslateAffix(numberStringSliceByRunes(negativePattern, negativeLast + 1, negativePattern.toRuneArray().size), locale) } else { positiveSuffix }
    let numericPattern = numberStringSliceByRunes(positivePattern, firstPlaceholder, lastPlaceholder + 1)
    let formatter = ValidatorNumberFormat(
        locale,
        formatType,
        locale.groupingSeparator,
        locale.decimalSeparator,
        numberPatternGroupingSize(numericPattern),
        numberPatternMinFractionDigits(numericPattern),
        numberPatternMaxFractionDigits(numericPattern),
        !allowFractions,
        allowFractions,
        positiveSuffix.contains("${locale.percentSymbol}") || negativeSuffix.contains("${locale.percentSymbol}")
    )
    formatter.setAffixes(positivePrefix, positiveSuffix, negativePrefix, negativeSuffix)
    formatter.setCurrencySymbol(numberCurrencySymbol(locale))
    formatter.setUseGrouping(numberPatternGroupingSize(numericPattern) > 0)
    formatter
}

public class BigInteger {
    private let normalizedValue: String

    public static func fromNormalized(source: String): BigInteger {
        BigInteger(numberNormalizeInteger(source))
    }

    public init(source: String) {
        normalizedValue = numberNormalizeInteger(source)
    }

    public operator func ==(right: BigInteger): Bool {
        normalizedValue == right.normalizedValue
    }

    public operator func !=(right: BigInteger): Bool {
        !(this == right)
    }

    public func longValue(): Int64 {
        match (numberParseInt64Exact(normalizedValue)) {
            case Some(value) => value
            case None => 0
        }
    }

    public func toString(): String {
        normalizedValue
    }
}

public class BigDecimal {
    private let normalizedValue: String

    public static func fromNormalized(source: String): BigDecimal {
        BigDecimal(source)
    }

    public init(source: String) {
        let value = source.trimAscii()
        let negative = value.startsWith("-")
        let unsigned = if (negative || value.startsWith("+")) { value[1..] } else { value }
        if (let Some(dotIndex) <- unsigned.indexOf(".")) {
            let integerPart = if (dotIndex == 0) { "0" } else { unsigned[0..dotIndex] }
            let fractionPart = if (dotIndex + 1 >= unsigned.size) { "" } else { unsigned[dotIndex + 1..] }
            normalizedValue = numberComposeDecimalString(negative, integerPart, fractionPart)
        } else {
            normalizedValue = numberComposeDecimalString(negative, unsigned, "")
        }
    }

    public operator func ==(right: BigDecimal): Bool {
        normalizedValue == right.normalizedValue
    }

    public operator func !=(right: BigDecimal): Bool {
        !(this == right)
    }

    public func doubleValue(): Float64 {
        match (numberParseFloatLiteral(normalizedValue, false)) {
            case Some(value) => value
            case None => 0.0
        }
    }

    public func longValue(): Int64 {
        let (negative, integerPart, _) = numberSplitDecimalString(normalizedValue)
        match (numberParseInt64Exact(if (negative) { "-" + integerPart } else { integerPart })) {
            case Some(value) => value
            case None => 0
        }
    }

    public func movePointLeft(places: Int64): BigDecimal {
        BigDecimal.fromNormalized(numberMovePointLeft(normalizedValue, places))
    }

    public func setScale(scale: Int64): BigDecimal {
        BigDecimal.fromNormalized(numberSetScaleDown(normalizedValue, scale))
    }

    public func trimFractionZeros(): BigDecimal {
        BigDecimal.fromNormalized(numberRemoveFractionTrailingZeros(normalizedValue))
    }

    public func toString(): String {
        normalizedValue
    }
}

public class ValidatorRawNumber {
    private let normalizedValue: String

    public init(normalizedValue: String) {
        this.normalizedValue = normalizedValue
    }

    public func normalized(): String {
        normalizedValue
    }

    public func hasFraction(): Bool {
        normalizedValue.contains(".")
    }

    public func longValue(): ?Int64 {
        if (hasFraction()) {
            return None<Int64>
        }
        numberParseInt64Exact(normalizedValue)
    }

    public func doubleValue(): ?Float64 {
        numberParseFloatLiteral(normalizedValue, false)
    }

    public func movePointLeft(places: Int64): ValidatorRawNumber {
        ValidatorRawNumber(numberMovePointLeft(normalizedValue, places))
    }
}

public class Locale {
    public static let US = Locale("en", "US", "", r'.', r',', r'%')
    public static let UK = Locale("en", "GB", "", r'.', r',', r'%')
    public static let GERMAN = Locale("de", "DE", "", r',', r'.', r'%')
    public static let GERMANY = Locale("de", "DE", "", r',', r'.', r'%')
    public static let FRENCH = Locale("fr", "", "", r',', r' ', r'%')

    private static var defaultLocale: Locale = US

    public let language: String
    public let country: String
    public let variant: String
    public let decimalSeparator: Rune
    public let groupingSeparator: Rune
    public let percentSymbol: Rune

    public static func getDefault(): Locale {
        defaultLocale
    }

    public static func setDefault(locale: Locale): Unit {
        defaultLocale = locale
    }

    public init(language: String, country: String) {
        this.language = language
        this.country = country
        this.variant = ""
        this.decimalSeparator = r'.'
        this.groupingSeparator = r','
        this.percentSymbol = r'%'
    }

    public init(language: String, country: String, variant: String) {
        this.language = language
        this.country = country
        this.variant = variant
        this.decimalSeparator = r'.'
        this.groupingSeparator = r','
        this.percentSymbol = r'%'
    }

    public init(language: String, country: String, variant: String, decimalSeparator: Rune, groupingSeparator: Rune, percentSymbol: Rune) {
        this.language = language
        this.country = country
        this.variant = variant
        this.decimalSeparator = decimalSeparator
        this.groupingSeparator = groupingSeparator
        this.percentSymbol = percentSymbol
    }

    public operator func ==(right: Locale): Bool {
        language == right.language &&
            country == right.country &&
            variant == right.variant &&
            decimalSeparator == right.decimalSeparator &&
            groupingSeparator == right.groupingSeparator &&
            percentSymbol == right.percentSymbol
    }

    public operator func !=(right: Locale): Bool {
        !(this == right)
    }

    public func toString(): String {
        if (!variant.isEmpty()) {
            return "${language}_${country}_${variant}"
        }
        if (!country.isEmpty()) {
            return "${language}_${country}"
        }
        language
    }
}

public class ValidatorNumberFormat {
    private let locale: Locale
    private let formatType: Int64
    private let groupingSeparator: Rune
    private let decimalSeparator: Rune
    private let groupingSize: Int64
    private let minimumFractionDigits: Int64
    private let maximumFractionDigits: Int64
    private let parseIntegerOnly: Bool
    private let decimalAllowed: Bool
    private let percentRequired: Bool

    private var positivePrefix = ""
    private var positiveSuffix = ""
    private var negativePrefix = "-"
    private var negativeSuffix = ""
    private var currencySymbol = "¤"
    private var useGrouping = true

    public init(locale: Locale, formatType: Int64, groupingSeparator: Rune, decimalSeparator: Rune, groupingSize: Int64, minimumFractionDigits: Int64, maximumFractionDigits: Int64, parseIntegerOnly: Bool, decimalAllowed: Bool, percentRequired: Bool) {
        this.locale = locale
        this.formatType = formatType
        this.groupingSeparator = groupingSeparator
        this.decimalSeparator = decimalSeparator
        this.groupingSize = groupingSize
        this.minimumFractionDigits = minimumFractionDigits
        this.maximumFractionDigits = maximumFractionDigits
        this.parseIntegerOnly = parseIntegerOnly
        this.decimalAllowed = decimalAllowed
        this.percentRequired = percentRequired
    }

    internal func setAffixes(positivePrefix: String, positiveSuffix: String, negativePrefix: String, negativeSuffix: String): Unit {
        this.positivePrefix = positivePrefix
        this.positiveSuffix = positiveSuffix
        this.negativePrefix = negativePrefix
        this.negativeSuffix = negativeSuffix
    }

    internal func setCurrencySymbol(currencySymbol: String): Unit {
        this.currencySymbol = currencySymbol
    }

    internal func setUseGrouping(useGrouping: Bool): Unit {
        this.useGrouping = useGrouping
    }

    public func getFormatType(): Int64 {
        formatType
    }

    public func getMinimumFractionDigits(): Int64 {
        minimumFractionDigits
    }

    public func getMaximumFractionDigits(): Int64 {
        maximumFractionDigits
    }

    public func getGroupingSize(): Int64 {
        groupingSize
    }

    public func isParseIntegerOnly(): Bool {
        parseIntegerOnly
    }

    public func withPercentRequired(required: Bool): ValidatorNumberFormat {
        let copy = ValidatorNumberFormat(locale, formatType, groupingSeparator, decimalSeparator, groupingSize, minimumFractionDigits, maximumFractionDigits, parseIntegerOnly, decimalAllowed, required)
        copy.setAffixes(positivePrefix, positiveSuffix, negativePrefix, negativeSuffix)
        copy.setCurrencySymbol(currencySymbol)
        copy.setUseGrouping(useGrouping)
        copy
    }

    public func withoutCurrencySymbol(): ValidatorNumberFormat {
        let copy = ValidatorNumberFormat(locale, formatType, groupingSeparator, decimalSeparator, groupingSize, minimumFractionDigits, maximumFractionDigits, parseIntegerOnly, decimalAllowed, percentRequired)
        copy.setAffixes(
            positivePrefix.replace(currencySymbol, ""),
            positiveSuffix.replace(currencySymbol, ""),
            negativePrefix.replace(currencySymbol, ""),
            negativeSuffix.replace(currencySymbol, "")
        )
        copy.setCurrencySymbol(currencySymbol)
        copy.setUseGrouping(useGrouping)
        copy
    }

    public func withoutPercentSymbol(): ValidatorNumberFormat {
        let percentSymbol = "${locale.percentSymbol}"
        let copy = ValidatorNumberFormat(locale, formatType, groupingSeparator, decimalSeparator, groupingSize, minimumFractionDigits, maximumFractionDigits, parseIntegerOnly, decimalAllowed, false)
        copy.setAffixes(
            positivePrefix.replace(percentSymbol, ""),
            positiveSuffix.replace(percentSymbol, ""),
            negativePrefix.replace(percentSymbol, ""),
            negativeSuffix.replace(percentSymbol, "")
        )
        copy.setCurrencySymbol(currencySymbol)
        copy.setUseGrouping(useGrouping)
        copy
    }

    func getLocale(): Locale {
        locale
    }

    public func parse(value: String, strict: Bool): ?ValidatorRawNumber {
        if (value.isEmpty()) {
            return None<ValidatorRawNumber>
        }
        var index: Int64 = 0
        var negative = false
        let runes = value.toRuneArray()
        if (!positivePrefix.isEmpty() && numberRunesMatchAt(runes, 0, positivePrefix)) {
            index = positivePrefix.toRuneArray().size
        } else if (!negativePrefix.isEmpty() && numberRunesMatchAt(runes, 0, negativePrefix)) {
            index = negativePrefix.toRuneArray().size
            negative = true
        }
        var integerDigits = ""
        var fractionDigits = ""
        var seenDigit = false
        var seenDecimal = false

        while (index < runes.size) {
            let character = runes[index]
            if (character.isAsciiNumber()) {
                seenDigit = true
                if (seenDecimal) {
                    fractionDigits += "${character}"
                } else {
                    integerDigits += "${character}"
                }
                index++
                continue
            }
            if (character == groupingSeparator && useGrouping && !seenDecimal) {
                index++
                continue
            }
            if (character == decimalSeparator && decimalAllowed && !parseIntegerOnly && !seenDecimal) {
                seenDecimal = true
                index++
                continue
            }
            break
        }

        if (!seenDigit) {
            return None<ValidatorRawNumber>
        }

        let expectedSuffix = if (negative) { negativeSuffix } else { positiveSuffix }
        if (!expectedSuffix.isEmpty()) {
            if (numberRunesMatchAt(runes, index, expectedSuffix)) {
                index += expectedSuffix.toRuneArray().size
            } else if (strict) {
                return None<ValidatorRawNumber>
            }
        }

        let activeSuffix = if (negative) { negativeSuffix } else { positiveSuffix }
        let activePrefix = if (negative) { negativePrefix } else { positivePrefix }
        if (percentRequired && !(activeSuffix.contains("${locale.percentSymbol}") || activePrefix.contains("${locale.percentSymbol}"))) {
            return None<ValidatorRawNumber>
        }

        if (strict && index != runes.size) {
            return None<ValidatorRawNumber>
        }

        let integerPart = if (integerDigits.isEmpty()) { "0" } else { integerDigits }
        let normalized = numberComposeDecimalString(negative, integerPart, fractionDigits)
        Some(ValidatorRawNumber(normalized))
    }

    private func formatIntegerPortion(digits: String): String {
        if (!useGrouping || groupingSize <= 0) {
            return digits
        }
        let runes = digits.toRuneArray()
        var out = ArrayList<Rune>()
        var remaining = runes.size
        for (i in 0..runes.size) {
            out.add(runes[i])
            remaining--
            if (remaining > 0 && remaining % groupingSize == 0) {
                out.add(groupingSeparator)
            }
        }
        String(out)
    }

    public func format(value: Any): String {
        let rawText = numberAnyToDecimalText(value)
        let (negative, integerPart, fractionPart) = numberSplitDecimalString(rawText)
        let prefix = if (negative) { negativePrefix } else { positivePrefix }
        let suffix = if (negative) { negativeSuffix } else { positiveSuffix }
        let intDigits = formatIntegerPortion(integerPart)
        var fraction = fractionPart
        if (maximumFractionDigits >= 0 && fraction.size > maximumFractionDigits) {
            fraction = fraction[0..maximumFractionDigits]
        }
        if (fraction.size < minimumFractionDigits) {
            var padding = ArrayList<Rune>()
            for (_ in 0..(minimumFractionDigits - fraction.size)) {
                padding.add(r'0')
            }
            fraction += String(padding)
        }
        if (!fraction.isEmpty()) {
            return prefix + intDigits + "${decimalSeparator}" + fraction + suffix
        }
        prefix + intDigits + suffix
    }
}

public open class AbstractNumberValidator <: AbstractFormatValidator {
    public static let STANDARD_FORMAT: Int64 = 0
    public static let CURRENCY_FORMAT: Int64 = 1
    public static let PERCENT_FORMAT: Int64 = 2

    private let allowFractions: Bool
    private let formatType: Int64

    public init(strict: Bool, formatType: Int64, allowFractions: Bool) {
        super(strict)
        this.allowFractions = allowFractions
        this.formatType = formatType
    }

    protected func parseValue(value: ?String, pattern: ?String, locale: ?Locale): ?Any {
        match (value) {
            case Some(text) =>
                let trimmed = text.trimAscii()
                if (trimmed.isEmpty()) {
                    return None<Any>
                }
                parse(trimmed, getFormat(pattern, locale))
            case None =>
                None<Any>
        }
    }

    public func parse(value: ?String): ?Any {
        parse(value, None<String>, None<Locale>)
    }

    public func parse(value: ?String, locale: Locale): ?Any {
        parse(value, None<String>, Some(locale))
    }

    public func parse(value: ?String, pattern: String): ?Any {
        parse(value, Some(pattern), None<Locale>)
    }

    public func parse(value: ?String, pattern: ?String, locale: ?Locale): ?Any {
        parseValue(value, pattern, locale)
    }

    protected func getFormat(locale: Locale): ValidatorNumberFormat {
        let actualLocale = locale
        let formatter =
            if (formatType == CURRENCY_FORMAT) {
                ValidatorNumberFormat(actualLocale, formatType, actualLocale.groupingSeparator, actualLocale.decimalSeparator, 3, if (allowFractions) { 2 } else { 0 }, if (allowFractions) { 2 } else { 0 }, !allowFractions, allowFractions, false)
            } else if (formatType == PERCENT_FORMAT) {
                ValidatorNumberFormat(actualLocale, formatType, actualLocale.groupingSeparator, actualLocale.decimalSeparator, 3, 0, 0, false, true, true)
            } else {
                ValidatorNumberFormat(actualLocale, formatType, actualLocale.groupingSeparator, actualLocale.decimalSeparator, 3, 0, -1, !allowFractions, allowFractions, false)
            }
        if (formatType == CURRENCY_FORMAT) {
            formatter.setAffixes(numberCurrencySymbol(actualLocale), "", "-" + numberCurrencySymbol(actualLocale), "")
        } else if (formatType == PERCENT_FORMAT) {
            formatter.setAffixes("", "${actualLocale.percentSymbol}", "-", "${actualLocale.percentSymbol}")
        } else {
            formatter.setAffixes("", "", "-", "")
        }
        formatter.setCurrencySymbol(numberCurrencySymbol(actualLocale))
        formatter.setUseGrouping(true)
        formatter
    }

    protected override func getFormat(pattern: ?String, locale: ?Locale): ValidatorNumberFormat {
        match (pattern) {
            case Some(text) =>
                if (text.trimAscii().isEmpty()) {
                    return getFormat(numberDefaultLocale(locale))
                }
                numberStringToFormatter(text, numberDefaultLocale(locale), formatType, allowFractions)
            case None =>
                getFormat(numberDefaultLocale(locale))
        }
    }

    public func determineScale(format: ValidatorNumberFormat): Int64 {
        if (!isStrict()) {
            return -1
        }
        if (!allowFractions || format.isParseIntegerOnly()) {
            return 0
        }
        let minimumFraction = format.getMinimumFractionDigits()
        let maximumFraction = format.getMaximumFractionDigits()
        if (maximumFraction < 0 || minimumFraction != maximumFraction) {
            return -1
        }
        var scale = minimumFraction
        if (formatType == PERCENT_FORMAT) {
            scale += 2
        }
        scale
    }

    public func getFormatType(): Int64 {
        formatType
    }

    public func isAllowFractions(): Bool {
        allowFractions
    }

    private func anyToInteger(value: Any): Int64 {
        match (numberParseInt64Exact(numberNormalizeInteger(numberAnyToDecimalText(value)))) {
            case Some(parsed) => parsed
            case None => 0
        }
    }

    private func anyToDouble(value: Any): Float64 {
        match (numberParseFloatLiteral(numberAnyToDecimalText(value), false)) {
            case Some(parsed) => parsed
            case None => 0.0
        }
    }

    public func isInRange(value: Any, min: Any, max: Any): Bool {
        minValue(value, min) && maxValue(value, max)
    }

    public func maxValue(value: Any, max: Any): Bool {
        if (allowFractions) {
            return anyToDouble(value) <= anyToDouble(max)
        }
        anyToInteger(value) <= anyToInteger(max)
    }

    public func minValue(value: Any, min: Any): Bool {
        if (allowFractions) {
            return anyToDouble(value) >= anyToDouble(min)
        }
        anyToInteger(value) >= anyToInteger(min)
    }

    protected open func processParsedValue(value: Any, formatter: ValidatorNumberFormat): ?Any {
        match (value) {
            case parsedValue: ValidatorRawNumber =>
                Some(parsedValue)
            case _ =>
                None<Any>
        }
    }

    public open override func isValid(value: ?String, pattern: ?String, locale: ?Locale): Bool {
        match (parse(value, pattern, locale)) {
            case Some(_) => true
            case None => false
        }
    }
}
