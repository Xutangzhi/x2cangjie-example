package commons_validator_test

import std.unittest.*

import validator.routines.*
import validator.routines.checkdigit.*

func routinesCreateCalendar(zone: ?TimeZone, date: Int64, time: Int64): Calendar {
    let calendar = match (zone) {
        case Some(value) => Calendar.getInstance(value)
        case None => Calendar.getInstance()
    }
    let year = date / 10000
    let month = (date / 100) % 100 - 1
    let day = date % 100
    let hour = time / 10000
    let minute = (time / 100) % 100
    let second = time % 100
    calendar.set(year, month, day, hour, minute)
    calendar.set(Calendar.SECOND, second)
    calendar.set(Calendar.MILLISECOND, 0)
    calendar
}

func routinesCreateDate(zone: ?TimeZone, date: Int64, time: Int64): Date {
    routinesCreateCalendar(zone, date, time).getTime()
}

func routinesCreateTime(zone: ?TimeZone, time: Int64, millisecond: Int64): Calendar {
    let calendar = match (zone) {
        case Some(value) => Calendar.getInstance(value)
        case None => Calendar.getInstance()
    }
    let hour = time / 10000
    let minute = (time / 100) % 100
    let second = time % 100
    calendar.set(1970, 0, 1, hour, minute)
    calendar.set(Calendar.SECOND, second)
    calendar.set(Calendar.MILLISECOND, millisecond)
    calendar
}

func ensureSomeInt64(actual: ?Int64, expected: Int64, message: String): Unit {
    match (actual) {
        case Some(value) => routineEnsure(value == expected, "${message}: expected=${expected} actual=${value}")
        case None => throw Exception("${message}: expected Some(${expected}) actual=None")
    }
}

func ensureSomeFloat64(actual: ?Float64, expected: Float64, message: String): Unit {
    match (actual) {
        case Some(value) => routineEnsure(value == expected, "${message}: expected=${expected} actual=${value}")
        case None => throw Exception("${message}: expected Some(${expected}) actual=None")
    }
}

func ensureSomeBigInteger(actual: ?BigInteger, expected: BigInteger, message: String): Unit {
    match (actual) {
        case Some(value) => routineEnsure(value == expected, message)
        case None => throw Exception("${message}: expected Some actual=None")
    }
}

func ensureSomeBigDecimal(actual: ?BigDecimal, expected: BigDecimal, message: String): Unit {
    match (actual) {
        case Some(value) => routineEnsure(value == expected, message)
        case None => throw Exception("${message}: expected Some actual=None")
    }
}

@Test
class RoutinesNumericTimeTranslatedTest {
    @TestCase
    func numericValidatorMethodsAndRanges(): Unit {
        ensureSomeInt64(ByteValidator.getInstance().validate(",123"), 123, "byte default")
        ensureSomeInt64(ByteValidator.getInstance().validate(".123", Locale.GERMAN), 123, "byte locale")
        ensureSomeInt64(ByteValidator.getInstance().validate("1,23", "0,00"), 123, "byte pattern")
        routineEnsure(!ByteValidator.getInstance().isValid("XXXX"), "byte invalid")
        routineEnsure(ByteValidator.getInstance().isValid(",123"), "byte valid")
        routineEnsure(!ByteValidator.getInstance().isValid("128"), "byte upper bound")
        routineEnsure(!ByteValidator.getInstance().isValid("-129"), "byte lower bound")

        ensureSomeInt64(ShortValidator.getInstance().validate("12,345"), 12345, "short default")
        ensureSomeInt64(IntegerValidator.getInstance().validate("12,345"), 12345, "int default")
        ensureSomeInt64(LongValidator.getInstance().validate("12,345"), 12345, "long default")
        routineEnsure(IntegerValidator.getInstance().isValid("2147483647"), "int max")
        routineEnsure(!IntegerValidator.getInstance().isValid("2147483648"), "int beyond max")
        routineEnsure(IntegerValidator.getInstance().isValid("-2147483648"), "int min")
        routineEnsure(!IntegerValidator.getInstance().isValid("-2147483649"), "int beyond min")

        ensureSomeFloat64(FloatValidator.getInstance().validate("12,345"), 12345.0, "float default")
        ensureSomeFloat64(DoubleValidator.getInstance().validate("12,345"), 12345.0, "double default")
        match (FloatValidator.getInstance().validate("0.000000000000000000000000000000000000000000001401298464324817", "#.#################################################################")) {
            case Some(value) => routineEnsure(value > 1.0E-45 && value < 2.0E-45, "float min positive")
            case None => throw Exception("float min positive")
        }
        routineEnsure(!FloatValidator.getInstance().isValid("0.0000000000000000000000000000000000000000000001401298464324817", "#.#################################################################"), "float too small")

        ensureSomeBigInteger(BigIntegerValidator.getInstance().validate("12,345"), BigInteger("12345"), "bigint default")
        ensureSomeBigDecimal(BigDecimalValidator.getInstance().validate("12,345"), BigDecimal("12345"), "bigdecimal default")
        ensureSomeBigDecimal(BigDecimalValidator.getInstance().validate(".1"), BigDecimal(".1"), "bigdecimal leading dot")
        ensureSomeBigDecimal(BigDecimalValidator.getInstance().validate("12345.678990", "#,###.###"), BigDecimal("12345.67899"), "bigdecimal strict pattern")

        routineEnsure(!ByteValidator.getInstance().isInRange(9, 10, 20), "byte range low")
        routineEnsure(ByteValidator.getInstance().isInRange(10, 10, 20), "byte range min")
        routineEnsure(ByteValidator.getInstance().isInRange(20, 10, 20), "byte range max")
        routineEnsure(!ByteValidator.getInstance().isInRange(21, 10, 20), "byte range high")
        routineEnsure(IntegerValidator.getInstance().minValue(11, 10), "int minValue")
        routineEnsure(!IntegerValidator.getInstance().maxValue(21, 20), "int maxValue")
        routineEnsure(BigIntegerValidator.getInstance().maxValue(BigInteger("19"), 20), "bigint max")
        routineEnsure(!BigDecimalValidator().isInRange(BigDecimal("21"), 10.0, 20.0), "bigdecimal range high")
    }

    @TestCase
    func currencyAndPercentValidators(): Unit {
        let previousDefault = Locale.getDefault()
        Locale.setDefault(Locale.UK)
        try {
            let currency = CurrencyValidator.getInstance()
            routineEnsure(currency.getFormatType() == AbstractNumberValidator.CURRENCY_FORMAT, "currency type")
            ensureSomeBigDecimal(currency.validate("£1,234.56", Locale.UK), BigDecimal("1234.56"), "currency uk")
            ensureSomeBigDecimal(currency.validate("1,234.56", Locale.UK), BigDecimal("1234.56"), "currency no symbol")
            ensureSomeBigDecimal(currency.validate("$1,234.56", Locale.US), BigDecimal("1234.56"), "currency us")
            ensureSomeBigDecimal(currency.validate("-$1,234.56", Locale.US), BigDecimal("-1234.56"), "currency us negative")
            routineEnsure(!currency.isValid("$1,234.56", Locale.UK), "currency wrong symbol")
            routineEnsure(!CurrencyValidator(true, false).isValid("£1,234.56", Locale.UK), "currency integer invalid")
            ensureSomeBigDecimal(currency.validate("£1,234.567", "¤#,##0.000;[¤#,##0.000]"), BigDecimal("1234.567"), "currency pattern")
            ensureSomeBigDecimal(currency.validate("[£1,234.567]", "¤#,##0.000;[¤#,##0.000]"), BigDecimal("-1234.567"), "currency pattern negative")
            ensureSomeBigDecimal(currency.validate("1,234.567", "¤#,##0.000;[¤#,##0.000]"), BigDecimal("1234.567"), "currency pattern no symbol")
            ensureSomeBigDecimal(currency.validate("[1,234.567]", "¤#,##0.000;[¤#,##0.000]"), BigDecimal("-1234.567"), "currency pattern negative no symbol")

            let percent = PercentValidator.getInstance()
            routineEnsure(percent.getFormatType() == AbstractNumberValidator.PERCENT_FORMAT, "percent type")
            ensureSomeBigDecimal(percent.validate("12%"), BigDecimal("0.12"), "percent default")
            ensureSomeBigDecimal(percent.validate("-12%", Locale.US), BigDecimal("-0.12"), "percent negative")
            ensureSomeBigDecimal(percent.validate("12", Locale.UK), BigDecimal("0.12"), "percent no symbol")
            ensureSomeBigDecimal(percent.validate("12", Locale.US), BigDecimal("0.12"), "percent no symbol us")
            ensureSomeBigDecimal(percent.validate("100%"), BigDecimal("1.00"), "percent hundred")
            routineEnsure(!percent.isValid("12@", Locale.US), "percent wrong symbol")
            routineEnsure(!percent.isValid("(12%)", Locale.US), "percent wrong negative")
        } catch (e: Exception) {
            Locale.setDefault(previousDefault)
            throw e
        }
        Locale.setDefault(previousDefault)
    }

    @TestCase
    func dateAndCalendarValidators(): Unit {
        let est = TimeZone.getTimeZone("EST")
        let eet = TimeZone.getTimeZone("EET")
        let gmt = TimeZone.GMT

        let dateValidator = DateValidator.getInstance()
        routineEnsure(dateValidator.isValid("12/31/05"), "date default valid")
        routineEnsure(dateValidator.isValid("31.12.2005", Locale.GERMAN), "date locale valid")
        routineEnsure(dateValidator.isValid("2005-12-31", "yyyy-MM-dd"), "date pattern valid")
        routineEnsure(!dateValidator.isValid("XXXX"), "date default invalid")
        ensureSomeFloat64(Some(Float64(dateValidator.compareYears(routinesCreateDate(Some(gmt), 20050823, 124522), routinesCreateDate(Some(gmt), 20060101, 124522), gmt))), -1.0, "date compare years")
        routineEnsure(dateValidator.compareDates(routinesCreateDate(Some(gmt), 20050823, 124522), routinesCreateDate(Some(gmt), 20050824, 124522), gmt) == -1, "date compare dates")
        routineEnsure(dateValidator.compareQuarters(routinesCreateDate(Some(gmt), 20050823, 124522), routinesCreateDate(Some(gmt), 20051001, 124522), gmt, 2) == 0, "date compare quarter")
        match (dateValidator.validate("12/31/05", eet)) {
            case Some(value) => routineEnsure(value != routinesCreateDate(None<TimeZone>, 20051231, 0), "date zone variant")
            case None => throw Exception("date zone none")
        }

        let calValidator = CalendarValidator.getInstance()
        match (calValidator.validate("12/31/05")) {
            case Some(calendar) => routineEnsure(calendar.get(Calendar.YEAR) == 2005 && calendar.get(Calendar.MONTH) == 11 && calendar.get(Calendar.DATE) == 31, "calendar default")
            case None => throw Exception("calendar default none")
        }
        match (calValidator.validate("31.12.2005", Locale.GERMAN, est)) {
            case Some(calendar) =>
                routineEnsure(calendar.getTimeZone() == est, "calendar zone")
                routineEnsure(calendar.get(Calendar.YEAR) == 2005 && calendar.get(Calendar.MONTH) == 11 && calendar.get(Calendar.DATE) == 31, "calendar locale zone values")
            case None => throw Exception("calendar locale zone none")
        }
        routineEnsure(calValidator.compareDates(routinesCreateCalendar(Some(gmt), 20050823, 124522), routinesCreateCalendar(Some(gmt), 20050824, 124522)) == -1, "calendar compare date")
        routineEnsure(calValidator.compareMonths(routinesCreateCalendar(Some(gmt), 20050823, 124522), routinesCreateCalendar(Some(gmt), 20050901, 124522)) == -1, "calendar compare month")
        routineEnsure(calValidator.compareQuarters(routinesCreateCalendar(Some(gmt), 20050823, 124522), routinesCreateCalendar(Some(gmt), 20051001, 124522), 2) == 0, "calendar compare quarter")
        let calEst = routinesCreateCalendar(Some(est), 20051123, 120345)
        CalendarValidator.adjustToTimeZone(calEst, gmt)
        routineEnsure(calEst.getTimeZone() == gmt, "adjust timezone to gmt")
        CalendarValidator.adjustToTimeZone(calEst, est)
        routineEnsure(calEst.getTimeZone() == est, "adjust timezone back")
        routineEnsure(calValidator.format(routinesCreateCalendar(Some(gmt), 20051231, 11500), "yyyy-MM-dd HH:mm") == "2005-12-31 01:15", "calendar format pattern")
    }

    @TestCase
    func timeValidatorBehaviors(): Unit {
        let previousDefaultLocale = Locale.getDefault()
        let previousDefaultZone = TimeZone.getDefault()
        Locale.setDefault(Locale.UK)
        TimeZone.setDefault(TimeZone.GMT)
        try {
            let validator = TimeValidator.getInstance()
            routineEnsure(validator.compareTime(routinesCreateTime(Some(TimeZone.GMT), 154523, 400), routinesCreateTime(Some(TimeZone.GMT), 154523, 500)) == -1, "time compare milli")
            routineEnsure(validator.compareSeconds(routinesCreateTime(Some(TimeZone.GMT), 154523, 400), routinesCreateTime(Some(TimeZone.GMT), 154524, 100)) == -1, "time compare sec")
            routineEnsure(validator.compareMinutes(routinesCreateTime(Some(TimeZone.GMT), 154523, 400), routinesCreateTime(Some(TimeZone.GMT), 154623, 100)) == -1, "time compare min")
            routineEnsure(validator.compareHours(routinesCreateTime(Some(TimeZone.GMT), 154523, 400), routinesCreateTime(Some(TimeZone.GMT), 164523, 100)) == -1, "time compare hour")

            routineEnsure(validator.isValid("16:49", Locale.UK), "time locale valid")
            routineEnsure(!validator.isValid("24:00", Locale.UK), "time locale invalid")
            routineEnsure(validator.isValid("16-23-46", "HH-mm-ss"), "time pattern valid")
            routineEnsure(!validator.isValid("24-00-00", "HH-mm-ss"), "time pattern invalid")
            match (validator.validate("16:49:23", "HH:mm:ss")) {
                case Some(calendar) => routineEnsure(validator.format(calendar, "HH-mm-ss") == "16-49-23", "time format pattern")
                case None => throw Exception("time format none")
            }

            let est = TimeZone.getTimeZone("EST")
            match (validator.validate("16:49", est)) {
                case Some(calendar) =>
                    routineEnsure(calendar.getTimeZone() == est, "time zone")
                    routineEnsure(calendar.get(Calendar.HOUR_OF_DAY) == 16 && calendar.get(Calendar.MINUTE) == 49, "time zone values")
                case None => throw Exception("time zone none")
            }
        } catch (e: Exception) {
            Locale.setDefault(previousDefaultLocale)
            TimeZone.setDefault(previousDefaultZone)
            throw e
        }
        Locale.setDefault(previousDefaultLocale)
        TimeZone.setDefault(previousDefaultZone)
    }

    @TestCase
    func codeValidatorBehaviors(): Unit {
        var validator = CodeValidator(None<String>, -1, -1, None<CheckDigit>)
        match (validator.getCheckDigit()) {
            case None => ()
            case Some(_) => throw Exception("code no checkdigit")
        }
        routineEnsureSome("9781930110992", validator.validate("9781930110992"), "code raw invalid still passes without checkdigit")
        routineEnsure(validator.isValid("9781930110991"), "code raw valid without checkdigit")

        validator = CodeValidator(None<String>, -1, Some(EAN13CheckDigit.EAN13_CHECK_DIGIT))
        routineEnsureNone(validator.validate("9781930110992"), "code invalid with checkdigit")
        routineEnsureSome("9781930110991", validator.validate("9781930110991"), "code valid with checkdigit")
        routineEnsure(!validator.isValid("9781930110992"), "code invalid isValid")

        let regex = RegexValidator("^[0-9]*$")
        let constructorValidator = CodeValidator(regex, 13, Some(EAN13CheckDigit.EAN13_CHECK_DIGIT))
        routineEnsure(constructorValidator.getMinLength() == 13 && constructorValidator.getMaxLength() == 13, "code ctor lengths")
        match (constructorValidator.getRegexValidator()) {
            case Some(value) => routineEnsure(value.toString() == regex.toString(), "code ctor regex")
            case None => throw Exception("code ctor regex none")
        }

        validator = CodeValidator(None<String>, 11, 21, None<CheckDigit>)
        routineEnsureNone(validator.validate("1234567890"), "code min length")
        routineEnsureSome("12345678901", validator.validate("12345678901"), "code exact lower bound")
        routineEnsureSome("123456789012345678901", validator.validate("123456789012345678901"), "code exact upper bound")
        routineEnsureNone(validator.validate("1234567890123456789012"), "code above upper bound")

        validator = CodeValidator("^(?:([0-9]{3})(?:[-\\s])([0-9]{3}))|([0-9]{6})$", 6, None<CheckDigit>)
        routineEnsureSome("123456", validator.validate("123-456"), "code reformat dash")
        routineEnsureSome("123456", validator.validate("123 456"), "code reformat space")
        routineEnsureSome("123456", validator.validate("123456"), "code plain")
        routineEnsureNone(validator.validate("123.456"), "code invalid separator")
    }
}
