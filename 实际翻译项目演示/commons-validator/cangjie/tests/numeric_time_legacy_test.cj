package commons_validator_test

import std.unittest.*

import validator.*

@Test
class LegacyNumericDateTranslatedTest {
    @TestCase
    func genericValidatorLengthBehaviors(): Unit {
        routineEnsure(!GenericValidator.maxLength("12345\n\r", 4, 0), "max length 4/0")
        routineEnsure(GenericValidator.maxLength("12345\n\r", 5, 0), "max length 5/0")
        routineEnsure(GenericValidator.maxLength("12345\n\r", 6, 0), "max length 6/0")
        routineEnsure(GenericValidator.maxLength("12345\n\r", 7, 0), "max length 7/0")

        routineEnsure(!GenericValidator.maxLength("12345\n\r", 4, 1), "max length 4/1")
        routineEnsure(!GenericValidator.maxLength("12345\n\r", 5, 1), "max length 5/1")
        routineEnsure(GenericValidator.maxLength("12345\n\r", 6, 1), "max length 6/1")
        routineEnsure(GenericValidator.maxLength("12345\n\r", 7, 1), "max length 7/1")

        routineEnsure(!GenericValidator.maxLength("12345\n\r", 4, 2), "max length 4/2")
        routineEnsure(!GenericValidator.maxLength("12345\n\r", 5, 2), "max length 5/2")
        routineEnsure(!GenericValidator.maxLength("12345\n\r", 6, 2), "max length 6/2")
        routineEnsure(GenericValidator.maxLength("12345\n\r", 7, 2), "max length 7/2")

        routineEnsure(GenericValidator.minLength("12345\n\r", 5, 0), "min length 5/0")
        routineEnsure(!GenericValidator.minLength("12345\n\r", 6, 0), "min length 6/0")
        routineEnsure(!GenericValidator.minLength("12345\n\r", 7, 0), "min length 7/0")
        routineEnsure(!GenericValidator.minLength("12345\n\r", 8, 0), "min length 8/0")

        routineEnsure(GenericValidator.minLength("12345\n\r", 5, 1), "min length 5/1")
        routineEnsure(GenericValidator.minLength("12345\n\r", 6, 1), "min length 6/1")
        routineEnsure(!GenericValidator.minLength("12345\n\r", 7, 1), "min length 7/1")
        routineEnsure(!GenericValidator.minLength("12345\n\r", 8, 1), "min length 8/1")

        routineEnsure(GenericValidator.minLength("12345\n\r", 5, 2), "min length 5/2")
        routineEnsure(GenericValidator.minLength("12345\n\r", 6, 2), "min length 6/2")
        routineEnsure(GenericValidator.minLength("12345\n\r", 7, 2), "min length 7/2")
        routineEnsure(!GenericValidator.minLength("12345\n\r", 8, 2), "min length 8/2")
    }

    @TestCase
    func genericTypeValidatorLocaleAndPlain(): Unit {
        match (GenericTypeValidator.formatByte(Some("12"), Locale.US)) {
            case Some(value) => routineEnsure(Int64(value) == 12, "byte us")
            case None => throw Exception("byte us none")
        }
        match (GenericTypeValidator.formatShort(Some("-129"), Locale.FRENCH)) {
            case Some(value) => routineEnsure(Int64(value) == -129, "short fr")
            case None => throw Exception("short fr none")
        }
        match (GenericTypeValidator.formatInt(Some("-144"), Locale.US)) {
            case Some(value) => routineEnsure(Int64(value) == -144, "int us")
            case None => throw Exception("int us none")
        }
        match (GenericTypeValidator.formatLong(Some("88000"), Locale.US)) {
            case Some(value) => routineEnsure(value == 88000, "long us")
            case None => throw Exception("long us none")
        }
        match (GenericTypeValidator.formatFloat(Some("12.1555f"))) {
            case Some(value) => routineEnsure(Float64(value) > 12.15 && Float64(value) < 12.16, "float plain")
            case None => throw Exception("float plain none")
        }
        match (GenericTypeValidator.formatDouble(Some("129.1551511111d"))) {
            case Some(value) => routineEnsure(value > 129.155 && value < 129.156, "double plain")
            case None => throw Exception("double plain none")
        }
        match (GenericTypeValidator.formatFloat(Some("12,1555"), Locale.FRENCH)) {
            case Some(value) => routineEnsure(Float64(value) > 12.15 && Float64(value) < 12.16, "float fr")
            case None => throw Exception("float fr none")
        }
        match (GenericTypeValidator.formatDouble(Some("129,1551511111"), Locale.FRENCH)) {
            case Some(value) => routineEnsure(value > 129.155 && value < 129.156, "double fr")
            case None => throw Exception("double fr none")
        }
        match (GenericTypeValidator.formatDate(Some("12/21/2010"), Locale.US)) {
            case Some(value) => routineEnsure(value == Date(2010, 12, 21), "date us")
            case None => throw Exception("date us none")
        }
        match (GenericTypeValidator.formatDate(Some("21/12/2010"), Locale.FRENCH)) {
            case Some(value) => routineEnsure(value == Date(2010, 12, 21), "date fr")
            case None => throw Exception("date fr none")
        }
        match (GenericTypeValidator.formatCreditCard(Some("4111111111111111"))) {
            case Some(value) => routineEnsure(value == 4111111111111111, "credit card")
            case None => throw Exception("credit card none")
        }
    }

    @TestCase
    func legacyNumericAndDateValidation(): Unit {
        routineEnsure(GenericValidator.isByte(Some("0")), "byte zero")
        routineEnsure(GenericValidator.isByte(Some("127")), "byte max")
        routineEnsure(GenericValidator.isByte(Some("-128")), "byte min")
        routineEnsure(!GenericValidator.isByte(Some("128")), "byte beyond max")
        routineEnsure(!GenericValidator.isByte(Some("-129")), "byte beyond min")
        routineEnsure(!GenericValidator.isByte(None<String>), "byte none")

        routineEnsure(GenericValidator.isShort(Some("32767")), "short max")
        routineEnsure(GenericValidator.isShort(Some("-32768")), "short min")
        routineEnsure(!GenericValidator.isShort(Some("32768")), "short beyond max")
        routineEnsure(!GenericValidator.isShort(Some("-32769")), "short beyond min")

        routineEnsure(GenericValidator.isInt(Some("2147483647")), "int max")
        routineEnsure(GenericValidator.isInt(Some("-2147483648")), "int min")
        routineEnsure(!GenericValidator.isInt(Some("2147483648")), "int beyond max")
        routineEnsure(!GenericValidator.isInt(Some("-2147483649")), "int beyond min")

        routineEnsure(GenericValidator.isLong(Some("9223372036854775807")), "long max")
        routineEnsure(GenericValidator.isLong(Some("-9223372036854775808")), "long min")
        routineEnsure(!GenericValidator.isLong(Some("9223372036854775808")), "long beyond max")
        routineEnsure(!GenericValidator.isLong(Some("-9223372036854775809")), "long beyond min")

        routineEnsure(GenericValidator.isFloat(Some("3.4028235E38")), "float max")
        routineEnsure(GenericValidator.isFloat(Some("1.4E-45")), "float min positive")
        routineEnsure(!GenericValidator.isFloat(None<String>), "float none")

        routineEnsure(GenericValidator.isDouble(Some("1.7976931348623157E308")), "double max")
        routineEnsure(GenericValidator.isDouble(Some("4.9E-324")), "double min positive")
        routineEnsure(!GenericValidator.isDouble(None<String>), "double none")

        routineEnsure(DateValidator.getInstance().isValid(Some("12/01/2005"), Locale.US), "legacy date valid")
        routineEnsure(!DateValidator.getInstance().isValid(Some("12/01as/2005"), Locale.US), "legacy date invalid")
        routineEnsure(DateValidator.getInstance().isValid(Some("12/01/2005"), Some("MM/dd/yyyy"), true), "legacy strict pattern valid")
        routineEnsure(!DateValidator.getInstance().isValid(Some("2/12/1999"), Some("MM/dd/yyyy"), true), "legacy strict pattern invalid")
    }
}
