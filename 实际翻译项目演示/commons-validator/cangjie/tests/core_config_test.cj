package commons_validator_test

import std.collection.*
import std.fs.*
import std.unittest.*

import validator.*
import validator.util.FastHashMap as UtilFastHashMap
import validator.util.Flags as UtilFlags
import validator.util.ValidatorUtils as UtilValidatorUtils

let CORE_RESOURCE_DIR = "../java/commons-validator/src/test/resources/org/apache/commons/validator/"

func coreEnsure(condition: Bool, message: String): Unit {
    if (!condition) {
        throw Exception(message)
    }
}

func coreEnsureSomeString(expected: String, actual: ?String, message: String): Unit {
    match (actual) {
        case Some(value) => coreEnsure(value == expected, "${message}: expected=${expected}, actual=${value}")
        case None => throw Exception("${message}: expected=${expected}, actual=None")
    }
}

func coreEnsureNoneString(actual: ?String, message: String): Unit {
    match (actual) {
        case Some(value) => throw Exception("${message}: expected=None, actual=${value}")
        case None => ()
    }
}

func coreResource(name: String): String {
    CORE_RESOURCE_DIR + name
}

func coreInputStream(name: String): InputStream {
    InputStream(File.readFrom(coreResource(name)))
}

func coreLoadResources(name: String): ValidatorResources {
    ValidatorResources(coreResource(name))
}

func coreLoadResourceStreams(names: Array<String>): ValidatorResources {
    let streams = ArrayList<InputStream>()
    for (name in names) {
        streams.add(coreInputStream(name))
    }
    ValidatorResources(streams.toArray())
}

private class CoreNameBean <: ValidatorPropertyAccess {
    private var firstName: ?String = None<String>
    private var middleName: ?String = None<String>
    private var lastName: ?String = None<String>

    public init() {}

    public func getFirstName(): ?String {
        firstName
    }

    public func getMiddleName(): ?String {
        middleName
    }

    public func getLastName(): ?String {
        lastName
    }

    public func setFirstName(value: String): Unit {
        firstName = Some(value)
    }

    public func setMiddleName(value: String): Unit {
        middleName = Some(value)
    }

    public func setLastName(value: String): Unit {
        lastName = Some(value)
    }

    public func getValidatorPropertyValue(property: String): ?String {
        if (property == "firstName") {
            return firstName
        }
        if (property == "middleName") {
            return middleName
        }
        if (property == "lastName") {
            return lastName
        }
        None<String>
    }
}

private class CoreValueBean <: ValidatorPropertyAccess {
    private var value: ?String = None<String>

    public init() {}

    public func getValue(): ?String {
        value
    }

    public func setValue(value: String): Unit {
        this.value = Some(value)
    }

    public func getValidatorPropertyValue(property: String): ?String {
        if (property == "value") {
            return value
        }
        None<String>
    }
}

private class CoreTestBean <: ValidatorPropertyAccess {
    private var letter: ?String = None<String>
    private var date: ?String = None<String>

    public init() {}

    public func getLetter(): ?String {
        letter
    }

    public func getDate(): ?String {
        date
    }

    public func setLetter(value: String): Unit {
        letter = Some(value)
    }

    public func setDate(value: String): Unit {
        date = Some(value)
    }

    public func getValidatorPropertyValue(property: String): ?String {
        if (property == "letter") {
            return letter
        }
        if (property == "date") {
            return date
        }
        None<String>
    }
}

private func coreNameBean(firstName: ?String, middleName: ?String, lastName: ?String): CoreNameBean {
    let bean = CoreNameBean()
    match (firstName) {
        case Some(value) => bean.setFirstName(value)
        case None => ()
    }
    match (middleName) {
        case Some(value) => bean.setMiddleName(value)
        case None => ()
    }
    match (lastName) {
        case Some(value) => bean.setLastName(value)
        case None => ()
    }
    bean
}

private func coreValueBean(value: String): CoreValueBean {
    let bean = CoreValueBean()
    bean.setValue(value)
    bean
}

private func coreTestBean(letter: ?String, date: ?String): CoreTestBean {
    let bean = CoreTestBean()
    match (letter) {
        case Some(value) => bean.setLetter(value)
        case None => ()
    }
    match (date) {
        case Some(value) => bean.setDate(value)
        case None => ()
    }
    bean
}

func coreRequireValidatorResult(results: ValidatorResults, field: String): ValidatorResult {
    match (results.getValidatorResult(field)) {
        case Some(result) => result
        case None => throw Exception("Missing ValidatorResult for field ${field}")
    }
}

func coreEnsureActionResult(results: ValidatorResults, field: String, action: String, expected: Bool): Unit {
    let result = coreRequireValidatorResult(results, field)
    coreEnsure(result.containsAction(action), "Missing action ${action} for field ${field}")
    coreEnsure(result.isValid(action) == expected, "Unexpected validity for ${field}.${action}")
}

func coreEnsureActionNotRun(results: ValidatorResults, field: String, action: String): Unit {
    let result = coreRequireValidatorResult(results, field)
    coreEnsure(!result.containsAction(action), "Action ${action} should not have run for field ${field}")
}

func coreValidate(resources: ValidatorResources, formKey: String, bean: Any): ValidatorResults {
    let validator = Validator(resources, formKey)
    validator.setParameter(Validator.BEAN_PARAM, bean)
    validator.validate()
}

func coreValidateWithLocale(resources: ValidatorResources, formKey: String, bean: Any, locale: Locale): ValidatorResults {
    let validator = Validator(resources, formKey)
    validator.setParameter(Validator.BEAN_PARAM, bean)
    validator.setParameter(Validator.LOCALE_PARAM, locale)
    validator.validate()
}

func corePropertyNamesContains(results: ValidatorResults, property: String): Bool {
    for (name in results.getPropertyNames()) {
        if (name == property) {
            return true
        }
    }
    false
}

func coreArgIsNone(value: ?Arg): Bool {
    match (value) {
        case Some(_) => false
        case None => true
    }
}

func coreValidatorResultIsNone(value: ?ValidatorResult): Bool {
    match (value) {
        case Some(_) => false
        case None => true
    }
}

func coreValidatorResultIsSome(value: ?ValidatorResult): Bool {
    match (value) {
        case Some(_) => true
        case None => false
    }
}

func coreFormIsSome(value: ?Form): Bool {
    match (value) {
        case Some(_) => true
        case None => false
    }
}

func coreExpectValidatorExceptionMessage(expected: String, action: () -> Unit): Unit {
    try {
        action()
        throw Exception("Expected ValidatorException with message ${expected}")
    } catch (e: ValidatorException) {
        coreEnsure(e.message == expected, "ValidatorException message mismatch")
    }
}

func coreExpectIllegalArgument(action: () -> Unit): Unit {
    try {
        action()
        throw Exception("Expected IllegalArgumentException")
    } catch (_: IllegalArgumentException) {
        ()
    }
}

func coreManualResources(useDeprecatedSetter: Bool): ValidatorResources {
    let resources = ValidatorResources()
    let action = ValidatorAction()
    action.setName("capLetter")
    if (useDeprecatedSetter) {
        action.setClassname("org.apache.commons.validator.ValidatorTest")
    } else {
        action.setClassName("org.apache.commons.validator.ValidatorTest")
    }
    action.setMethod("isCapLetter")
    action.setMethodParams("java.lang.Object,org.apache.commons.validator.Field,java.util.List")

    let field = Field()
    field.setProperty("letter")
    field.setDepends("capLetter")

    let form = Form()
    form.setName("testForm")
    form.addField(field)

    let formSet = FormSet()
    formSet.addForm(form)

    resources.addValidatorAction(action)
    resources.addFormSet(formSet)
    resources.process()
    resources
}

func coreDateResources(): ValidatorResources {
    let resources = ValidatorResources()
    let action = ValidatorAction()
    action.setName("date")
    action.setClassname("org.apache.commons.validator.ValidatorTest")
    action.setMethod("formatDate")
    action.setMethodParams("java.lang.Object,org.apache.commons.validator.Field")

    let field = Field()
    field.setProperty("date")
    field.setDepends("date")

    let form = Form()
    form.setName("testForm")
    form.addField(field)

    let formSet = FormSet()
    formSet.addForm(form)

    resources.addValidatorAction(action)
    resources.addFormSet(formSet)
    resources.process()
    resources
}

func coreCheckRetrieveForm(resources: ValidatorResources, locale: Locale, formKey: String, expectedVarValue: String): Unit {
    match (resources.getForm(locale, formKey)) {
        case Some(form) =>
            match (form.getField("testProperty")) {
                case Some(field) => coreEnsureSomeString(expectedVarValue, field.getVarValue("localeVar"), "locale var mismatch for ${formKey}")
                case None => throw Exception("Missing testProperty for ${formKey}")
            }
        case None =>
            throw Exception("Missing form ${formKey} for locale ${locale.toString()}")
    }
}

func coreCheckRetrieveFormNotFound(resources: ValidatorResources, locale: Locale, formKey: String): Unit {
    match (resources.getForm(locale, formKey)) {
        case Some(_) => throw Exception("Expected no form for ${formKey} and locale ${locale.toString()}")
        case None => ()
    }
}

func coreCreateArg(key: String, name: ?String, position: ?Int64): Arg {
    let arg = Arg()
    arg.setKey(key)
    match (name) {
        case Some(value) => arg.setName(value)
        case None => ()
    }
    match (position) {
        case Some(value) => arg.setPosition(value)
        case None => ()
    }
    arg
}

@Test
class CoreFieldTranslatedTest {
    @TestCase
    func fieldArgumentPositioningScenarios(): Unit {
        var field = Field()
        field.addArg(coreCreateArg("default-position-0", None<String>, None<Int64>))
        field.addArg(coreCreateArg("default-position-2", None<String>, Some(2)))
        field.addArg(coreCreateArg("default-position-3", None<String>, None<Int64>))
        coreEnsure(field.getArgs("required").size == 4, "default one-position size")
        coreEnsureSomeString("default-position-0", match (field.getArg("required", 0)) { case Some(arg) => arg.getKey() case None => None<String> }, "default one-position p0")
        coreEnsure(coreArgIsNone(field.getArg("required", 1)), "default one-position p1 should be null")
        coreEnsureSomeString("default-position-2", match (field.getArg("required", 2)) { case Some(arg) => arg.getKey() case None => None<String> }, "default one-position p2")
        coreEnsureSomeString("default-position-3", match (field.getArg("required", 3)) { case Some(arg) => arg.getKey() case None => None<String> }, "default one-position p3")

        field = Field()
        field.addArg(coreCreateArg("default-position-0", None<String>, None<Int64>))
        field.addArg(coreCreateArg("default-position-1", None<String>, None<Int64>))
        field.addArg(coreCreateArg("default-position-2", None<String>, None<Int64>))
        coreEnsure(field.getArgs("required").size == 3, "default implied size")
        coreEnsureSomeString("default-position-1", match (field.getArg("required", 1)) { case Some(arg) => arg.getKey() case None => None<String> }, "default implied p1")

        field = Field()
        field.addArg(coreCreateArg("default-position-0", None<String>, None<Int64>))
        field.addArg(coreCreateArg("default-position-2", None<String>, Some(2)))
        field.addArg(coreCreateArg("default-position-3", None<String>, None<Int64>))
        field.addArg(coreCreateArg("default-position-1", None<String>, Some(1)))
        coreEnsureSomeString("default-position-1", match (field.getArg("required", 1)) { case Some(arg) => arg.getKey() case None => None<String> }, "default some position p1")
        coreEnsureSomeString("default-position-3", match (field.getArg("required", 3)) { case Some(arg) => arg.getKey() case None => None<String> }, "default some position p3")

        field = Field()
        field.addArg(coreCreateArg("default-position-1", None<String>, Some(1)))
        field.addArg(coreCreateArg("default-position-0", None<String>, Some(0)))
        field.addArg(coreCreateArg("default-position-2", None<String>, Some(2)))
        coreEnsureSomeString("default-position-0", match (field.getArg("required", 0)) { case Some(arg) => arg.getKey() case None => None<String> }, "default explicit p0")
        coreEnsure(field.getArgs("required").size == 3, "default explicit size")

        field = Field()
        coreEnsure(field.getArgs("required").size == 0, "empty args size")

        field = Field()
        field.addArg(coreCreateArg("default-position-0", None<String>, None<Int64>))
        field.addArg(coreCreateArg("required-position-1", Some("required"), None<Int64>))
        field.addArg(coreCreateArg("required-position-2", Some("required"), None<Int64>))
        field.addArg(coreCreateArg("mask-position-1", Some("mask"), None<Int64>))
        coreEnsure(field.getArgs("required").size == 3, "override implied required size")
        coreEnsureSomeString("required-position-1", match (field.getArg("required", 1)) { case Some(arg) => arg.getKey() case None => None<String> }, "override implied required p1")
        coreEnsureSomeString("mask-position-1", match (field.getArg("mask", 1)) { case Some(arg) => arg.getKey() case None => None<String> }, "override implied mask p1")
        coreEnsure(coreArgIsNone(field.getArg("mask", 2)), "override implied mask p2 should be null")
        coreEnsure(coreArgIsNone(field.getArg(1)), "override implied default p1 should be null")

        field = Field()
        field.addArg(coreCreateArg("default-position-0", None<String>, None<Int64>))
        field.addArg(coreCreateArg("default-position-1", None<String>, None<Int64>))
        field.addArg(coreCreateArg("default-position-2", None<String>, None<Int64>))
        field.addArg(coreCreateArg("required-position-1", Some("required"), Some(1)))
        field.addArg(coreCreateArg("required-position-2", Some("required"), None<Int64>))
        field.addArg(coreCreateArg("mask-position-3", Some("mask"), None<Int64>))
        coreEnsure(field.getArgs("required").size == 4, "override some size")
        coreEnsureSomeString("required-position-1", match (field.getArg("required", 1)) { case Some(arg) => arg.getKey() case None => None<String> }, "override some required p1")
        coreEnsureSomeString("mask-position-3", match (field.getArg("mask", 3)) { case Some(arg) => arg.getKey() case None => None<String> }, "override some mask p3")
        coreEnsure(coreArgIsNone(field.getArg(3)), "override some default p3 should be null")

        field = Field()
        field.addArg(coreCreateArg("default-position-0", None<String>, None<Int64>))
        field.addArg(coreCreateArg("default-position-1", None<String>, None<Int64>))
        field.addArg(coreCreateArg("default-position-2", None<String>, None<Int64>))
        field.addArg(coreCreateArg("required-position-1", Some("required"), Some(1)))
        coreEnsure(field.getArgs("required").size == 3, "override position A size")
        coreEnsureSomeString("required-position-1", match (field.getArg("required", 1)) { case Some(arg) => arg.getKey() case None => None<String> }, "override position A required p1")
        coreEnsureSomeString("default-position-1", match (field.getArg("mask", 1)) { case Some(arg) => arg.getKey() case None => None<String> }, "override position A mask p1")
        coreEnsureSomeString("default-position-1", match (field.getArg(1)) { case Some(arg) => arg.getKey() case None => None<String> }, "override position A default p1")

        field = Field()
        field.addArg(coreCreateArg("required-position-3", Some("required"), Some(3)))
        field.addArg(coreCreateArg("required-position-1", Some("required"), Some(1)))
        field.addArg(coreCreateArg("default-position-0", None<String>, None<Int64>))
        field.addArg(coreCreateArg("default-position-1", None<String>, None<Int64>))
        field.addArg(coreCreateArg("default-position-2", None<String>, None<Int64>))
        coreEnsure(field.getArgs("required").size == 4, "override position B size")
        coreEnsureSomeString("default-position-0", match (field.getArg("required", 0)) { case Some(arg) => arg.getKey() case None => None<String> }, "override position B required p0")
        coreEnsureSomeString("required-position-1", match (field.getArg("required", 1)) { case Some(arg) => arg.getKey() case None => None<String> }, "override position B required p1")
        coreEnsureSomeString("default-position-2", match (field.getArg("required", 2)) { case Some(arg) => arg.getKey() case None => None<String> }, "override position B required p2")
        coreEnsureSomeString("required-position-3", match (field.getArg("required", 3)) { case Some(arg) => arg.getKey() case None => None<String> }, "override position B required p3")
        coreEnsure(coreArgIsNone(field.getArg("mask", 3)), "override position B mask p3 should be null")
    }
}

@Test
class CoreManualValidatorTranslatedTest {
    @TestCase
    func validatorManualBooleanAndDeprecated(): Unit {
        for (deprecated in [false, true]) {
            let resources = coreManualResources(deprecated)
            let list = ArrayList<String>()
            let bean = coreTestBean(Some("A"), None<String>)
            coreEnsureSomeString("A", ValidatorUtils.getValueAsString(bean, "letter"), "manual validator letter property bridge")
            coreEnsureSomeString("A", UtilValidatorUtils.getValueAsString(bean, "letter"), "manual util validator letter property bridge")

            let validator = Validator(resources, "testForm")
            validator.setParameter(Validator.BEAN_PARAM, bean)
            validator.setParameter("java.util.List", list)
            _ = validator.validate()
            coreEnsure(list.isEmpty(), "manual boolean valid letter should not append error")

            list.clear()
            bean.setLetter("AA")
            _ = validator.validate()
            coreEnsure(list.size == 1, "manual boolean invalid letter should append one error")
        }
    }

    @TestCase
    func validatorManualObjectAndFieldFiltering(): Unit {
        let resources = coreDateResources()
        let bean = coreTestBean(None<String>, Some("2/3/1999"))
        coreEnsureSomeString("2/3/1999", ValidatorUtils.getValueAsString(bean, "date"), "manual validator date property bridge")
        coreEnsureSomeString("2/3/1999", UtilValidatorUtils.getValueAsString(bean, "date"), "manual util validator date property bridge")
        let validator = Validator(resources, "testForm")
        validator.setParameter(Validator.BEAN_PARAM, bean)

        var results = validator.validate()
        coreEnsureActionResult(results, "date", "date", true)
        coreEnsure(corePropertyNamesContains(results, "date"), "date property should be present when valid")

        bean.setDate("2/30/1999")
        results = validator.validate()
        coreEnsureActionResult(results, "date", "date", false)

        bean.setDate("2/3/1999")
        validator.setOnlyReturnErrors(true)
        results = validator.validate()
        coreEnsure(!corePropertyNamesContains(results, "date"), "onlyReturnErrors should suppress passing field")

        let fieldOnly = Validator(resources, "testForm", "date")
        fieldOnly.setParameter(Validator.BEAN_PARAM, bean)
        results = fieldOnly.validate()
        coreEnsure(corePropertyNamesContains(results, "date"), "field-only validator should include requested field")
    }
}

@Test
class CoreValidatorResultAndParameterTranslatedTest {
    @TestCase
    func parameterAndValidatorResultsBehavior(): Unit {
        let parameterResources = coreLoadResources("ParameterTest-config.xml")
        let bean = coreNameBean(Some("foo"), Some("123"), Some("456"))
        coreEnsureSomeString("foo", ValidatorUtils.getValueAsString(bean, "firstName"), "name bean firstName property bridge")
        coreEnsureSomeString("123", ValidatorUtils.getValueAsString(bean, "middleName"), "name bean middleName property bridge")
        coreEnsureSomeString("456", ValidatorUtils.getValueAsString(bean, "lastName"), "name bean lastName property bridge")
        coreEnsureNoneString(ValidatorUtils.getValueAsString(bean, "unknown"), "unknown bean property should resolve to None")
        coreEnsureSomeString("foo", UtilValidatorUtils.getValueAsString(bean, "firstName"), "util name bean firstName property bridge")
        coreEnsureSomeString("123", UtilValidatorUtils.getValueAsString(bean, "middleName"), "util name bean middleName property bridge")
        coreEnsureSomeString("456", UtilValidatorUtils.getValueAsString(bean, "lastName"), "util name bean lastName property bridge")
        coreEnsureNoneString(UtilValidatorUtils.getValueAsString(bean, "unknown"), "util unknown bean property should resolve to None")
        let validator = Validator(parameterResources, "nameForm")
        validator.setParameter(Validator.BEAN_PARAM, bean)
        validator.setParameter(Validator.LOCALE_PARAM, Locale.getDefault())
        _ = validator.validate()

        match (validator.getParameterValue(Validator.BEAN_PARAM)) {
            case Some(_) => ()
            case None => throw Exception("bean parameter missing")
        }
        match (validator.getParameterValue(Validator.FIELD_PARAM)) {
            case Some(_: Field) => ()
            case _ => throw Exception("field parameter type mismatch")
        }
        match (validator.getParameterValue(Validator.FORM_PARAM)) {
            case Some(_: Form) => ()
            case _ => throw Exception("form parameter type mismatch")
        }
        match (validator.getParameterValue(Validator.LOCALE_PARAM)) {
            case Some(_: Locale) => ()
            case _ => throw Exception("locale parameter type mismatch")
        }
        match (validator.getParameterValue(Validator.VALIDATOR_ACTION_PARAM)) {
            case Some(_: ValidatorAction) => ()
            case _ => throw Exception("validatorAction parameter type mismatch")
        }
        match (validator.getParameterValue(Validator.VALIDATOR_PARAM)) {
            case Some(_: Validator) => ()
            case _ => throw Exception("validator parameter type mismatch")
        }
        match (validator.getParameterValue(Validator.VALIDATOR_RESULTS_PARAM)) {
            case Some(_: ValidatorResults) => ()
            case _ => throw Exception("validatorResults parameter type mismatch")
        }

        let resultResources = coreLoadResources("ValidatorResultsTest-config.xml")
        var results = coreValidate(resultResources, "nameForm", coreNameBean(Some("foo"), Some("123"), Some("456")))
        coreEnsureActionResult(results, "firstName", "required", true)
        coreEnsureActionResult(results, "middleName", "required", true)
        coreEnsureActionResult(results, "middleName", "int", true)
        coreEnsureActionResult(results, "middleName", "positive", true)
        coreEnsureActionResult(results, "lastName", "required", true)
        coreEnsureActionResult(results, "lastName", "int", true)

        results = coreValidate(resultResources, "nameForm", coreNameBean(Some("foo"), Some("XXX"), None<String>))
        coreEnsureActionResult(results, "firstName", "required", true)
        coreEnsureActionResult(results, "middleName", "required", true)
        coreEnsureActionResult(results, "middleName", "int", false)
        coreEnsureActionNotRun(results, "middleName", "positive")
        coreEnsureActionResult(results, "lastName", "required", false)
        coreEnsureActionNotRun(results, "lastName", "int")
    }
}

@Test
class CoreVarAndExceptionTranslatedTest {
    @TestCase
    func varsAndValidatorException(): Unit {
        let resources = coreLoadResources("VarTest-config.xml")
        match (resources.getForm(Locale.getDefault(), "testForm")) {
            case Some(form) =>
                match (form.getField("field-1")) {
                    case Some(field1) =>
                        coreEnsure(field1.getProperty() == "field-1", "field-1 property mismatch")
                        match (field1.getVar("var-1-1")) {
                            case Some(variable) =>
                                coreEnsureSomeString("var-1-1", variable.getName(), "var-1-1 name")
                                coreEnsureSomeString("value-1-1", variable.getValue(), "var-1-1 value")
                                coreEnsureSomeString("jstype-1-1", variable.getJsType(), "var-1-1 jsType")
                                coreEnsure(!variable.isResource(), "var-1-1 resource mismatch")
                                coreEnsureNoneString(variable.getBundle(), "var-1-1 bundle")
                            case None => throw Exception("Missing var-1-1")
                        }
                    case None => throw Exception("Missing field-1")
                }
                match (form.getField("field-2")) {
                    case Some(field2) =>
                        match (field2.getVar("var-2-1")) {
                            case Some(variable) =>
                                coreEnsure(variable.isResource(), "var-2-1 resource mismatch")
                                coreEnsureSomeString("bundle-2-1", variable.getBundle(), "var-2-1 bundle")
                            case None => throw Exception("Missing var-2-1")
                        }
                        match (field2.getVar("var-2-2")) {
                            case Some(variable) =>
                                coreEnsureSomeString("value-2-2", variable.getValue(), "var-2-2 value")
                                coreEnsureNoneString(variable.getJsType(), "var-2-2 jsType")
                                coreEnsure(!variable.isResource(), "var-2-2 resource mismatch")
                                coreEnsureSomeString("bundle-2-2", variable.getBundle(), "var-2-2 bundle")
                            case None => throw Exception("Missing var-2-2")
                        }
                    case None => throw Exception("Missing field-2")
                }
            case None => throw Exception("Missing testForm")
        }

        let exceptionResources = coreLoadResources("ExceptionTest-config.xml")
        let exceptionValidator = Validator(exceptionResources, "exceptionForm")
        let exceptionBean = coreValueBean("VALIDATOR")
        coreEnsureSomeString("VALIDATOR", UtilValidatorUtils.getValueAsString(exceptionBean, "value"), "util value bean property bridge")
        exceptionValidator.setParameter(Validator.BEAN_PARAM, exceptionBean)
        coreExpectValidatorExceptionMessage("VALIDATOR-EXCEPTION", { => _ = exceptionValidator.validate() })
    }
}

@Test
class CoreLocaleAndFormLookupTranslatedTest {
    @TestCase
    func localeFallbackAndRetrieveFormBehaviors(): Unit {
        let localeResources = coreLoadResources("LocaleTest-config.xml")
        let blankName = coreNameBean(Some(""), None<String>, Some(""))

        var results = coreValidateWithLocale(localeResources, "nameForm", blankName, Locale("en", "US", "TEST1"))
        coreEnsure(coreValidatorResultIsSome(results.getValidatorResult("firstName")), "locale1 firstName should be invalid")
        coreEnsure(coreValidatorResultIsSome(results.getValidatorResult("middleName")), "locale1 middleName should be invalid")
        coreEnsure(coreValidatorResultIsSome(results.getValidatorResult("lastName")), "locale1 lastName should be invalid")

        results = coreValidateWithLocale(localeResources, "nameForm", blankName, Locale("en", "US", "TEST2"))
        coreEnsure(coreValidatorResultIsNone(results.getValidatorResult("firstName")), "locale2 firstName should be absent")
        coreEnsure(coreValidatorResultIsNone(results.getValidatorResult("middleName")), "locale2 middleName should be absent")
        coreEnsure(coreValidatorResultIsSome(results.getValidatorResult("lastName")), "locale2 lastName should be invalid")

        results = coreValidateWithLocale(localeResources, "nameForm", blankName, Locale("en", "UK"))
        coreEnsure(coreValidatorResultIsSome(results.getValidatorResult("firstName")), "locale3 firstName should be invalid")
        coreEnsure(coreValidatorResultIsNone(results.getValidatorResult("middleName")), "locale3 middleName should be absent")
        coreEnsure(coreValidatorResultIsNone(results.getValidatorResult("lastName")), "locale3 lastName should be absent")

        results = coreValidateWithLocale(localeResources, "nameForm", blankName, Locale("en", "UK", "TEST"))
        coreEnsure(coreValidatorResultIsSome(results.getValidatorResult("firstName")), "locale4 firstName should fall back to en_UK")
        coreEnsure(coreValidatorResultIsNone(results.getValidatorResult("middleName")), "locale4 middleName should be absent")
        coreEnsure(coreValidatorResultIsNone(results.getValidatorResult("lastName")), "locale4 lastName should be absent")

        results = coreValidateWithLocale(localeResources, "nameForm", blankName, Locale("en", ""))
        coreEnsure(coreValidatorResultIsSome(results.getValidatorResult("firstName")), "locale5 firstName should use default")
        coreEnsure(coreValidatorResultIsNone(results.getValidatorResult("middleName")), "locale5 middleName should be absent")
        coreEnsure(coreValidatorResultIsSome(results.getValidatorResult("lastName")), "locale5 lastName should use default")

        let retrieveResources = coreLoadResourceStreams(["RetrieveFormTest-config.xml"])
        let canadaFrenchXxx = Locale("fr", "CA", "XXX")
        coreCheckRetrieveForm(retrieveResources, Locale.US, "testForm_default", "default")
        coreCheckRetrieveForm(retrieveResources, Locale.FRENCH, "testForm_default", "default")
        coreCheckRetrieveForm(retrieveResources, Locale("fr", "FR"), "testForm_language", "fr")
        coreCheckRetrieveForm(retrieveResources, Locale("fr", "CA"), "testForm_language_country", "fr_CA")
        coreCheckRetrieveForm(retrieveResources, canadaFrenchXxx, "testForm_language_country_variant", "fr_CA_XXX")
        coreCheckRetrieveFormNotFound(retrieveResources, Locale.US, "INVALID_NAME")
    }
}

@Test
class CoreRequiredAndDependencyTranslatedTest {
    @TestCase
    func requiredNameRequiredIfAndMultipleBehaviors(): Unit {
        let requiredNameResources = coreLoadResources("RequiredNameTest-config.xml")
        var results = coreValidate(requiredNameResources, "nameForm", coreNameBean(None<String>, None<String>, None<String>))
        coreEnsureActionResult(results, "firstName", "required", false)
        coreEnsureActionResult(results, "lastName", "required", false)

        results = coreValidate(requiredNameResources, "nameForm", coreNameBean(Some("Joe"), None<String>, None<String>))
        coreEnsureActionResult(results, "firstName", "required", true)
        coreEnsureActionResult(results, "lastName", "required", false)

        results = coreValidate(requiredNameResources, "nameForm", coreNameBean(Some("Joe"), None<String>, Some("Smith")))
        coreEnsureActionResult(results, "firstName", "required", true)
        coreEnsureActionResult(results, "lastName", "required", true)

        let requiredIfResources = coreLoadResources("RequiredIfTest-config.xml")
        results = coreValidate(requiredIfResources, "nameForm", coreNameBean(None<String>, None<String>, None<String>))
        coreEnsureActionResult(results, "firstName", "requiredif", true)
        coreEnsureActionResult(results, "lastName", "requiredif", true)

        results = coreValidate(requiredIfResources, "nameForm", coreNameBean(Some(""), None<String>, Some("Test")))
        coreEnsureActionResult(results, "firstName", "requiredif", false)
        coreEnsureActionResult(results, "lastName", "requiredif", true)

        results = coreValidate(requiredIfResources, "nameForm", coreNameBean(Some("Joe"), None<String>, Some("")))
        coreEnsureActionResult(results, "firstName", "requiredif", true)
        coreEnsureActionResult(results, "lastName", "requiredif", false)

        let multipleResources = coreLoadResources("MultipleTests-config.xml")
        results = coreValidate(multipleResources, "nameForm", coreNameBean(None<String>, None<String>, None<String>))
        coreEnsureActionResult(results, "firstName", "required", false)
        coreEnsureActionResult(results, "lastName", "required", false)
        coreEnsureActionNotRun(results, "lastName", "int")

        results = coreValidate(multipleResources, "nameForm", coreNameBean(None<String>, Some("TEST"), None<String>))
        coreEnsureActionResult(results, "middleName", "required", true)
        coreEnsureActionResult(results, "middleName", "int", false)
        coreEnsureActionNotRun(results, "middleName", "positive")

        results = coreValidate(multipleResources, "nameForm", coreNameBean(None<String>, Some("-2534"), None<String>))
        coreEnsureActionResult(results, "middleName", "required", true)
        coreEnsureActionResult(results, "middleName", "int", true)
        coreEnsureActionResult(results, "middleName", "positive", false)

        results = coreValidate(multipleResources, "nameForm", coreNameBean(None<String>, Some("2534"), None<String>))
        coreEnsureActionResult(results, "middleName", "required", true)
        coreEnsureActionResult(results, "middleName", "int", true)
        coreEnsureActionResult(results, "middleName", "positive", true)
    }

    @TestCase
    func multipleConfigAndExtensionBehaviors(): Unit {
        let multiConfigResources = coreLoadResourceStreams(["MultipleConfigFilesTest-1-config.xml", "MultipleConfigFilesTest-2-config.xml"])
        var results = coreValidate(multiConfigResources, "nameForm", coreNameBean(None<String>, None<String>, None<String>))
        coreEnsureActionResult(results, "firstName", "required", false)
        coreEnsureActionResult(results, "lastName", "required", false)
        coreEnsureActionNotRun(results, "lastName", "int")

        match (multiConfigResources.getForm("", "", "", "testForm1")) {
            case Some(form) =>
                match (form.getField("testProperty1")) {
                    case Some(field) =>
                        coreEnsureSomeString("testConstValue1", field.getVarValue("var11"), "merged config default const 1")
                        coreEnsureSomeString("testConstValue2", field.getVarValue("var12"), "merged config default const 2")
                    case None => throw Exception("Missing testProperty1")
                }
            case None => throw Exception("Missing testForm1")
        }
        match (multiConfigResources.getForm("fr", "", "", "testForm2_fr")) {
            case Some(form) =>
                match (form.getField("testProperty2_fr")) {
                    case Some(field) =>
                        coreEnsureSomeString("testConstValue1_fr", field.getVarValue("var21_fr"), "merged config fr const 1")
                        coreEnsureSomeString("testConstValue2_fr", field.getVarValue("var22_fr"), "merged config fr const 2")
                    case None => throw Exception("Missing testProperty2_fr")
                }
            case None => throw Exception("Missing testForm2_fr")
        }

        results = coreValidate(multiConfigResources, "nameForm", coreNameBean(Some("Joe"), None<String>, Some("12345678")))
        coreEnsureActionResult(results, "firstName", "required", true)
        coreEnsureActionResult(results, "lastName", "int", true)

        let extensionResources = coreLoadResourceStreams(["ExtensionTest-config.xml"])
        match (extensionResources.getForm(Locale.getDefault(), "nameForm")) {
            case Some(form) =>
                coreEnsure(form.getFields().size == 2, "extension form size mismatch")
                coreEnsure(form.getFields()[0].getKey() == "firstName", "extension parent order mismatch")
                coreEnsure(form.getFields()[1].getKey() == "lastName", "extension parent order mismatch")
            case None => throw Exception("Missing extension nameForm")
        }
        match (extensionResources.getForm(Locale.getDefault(), "nameForm2")) {
            case Some(form) =>
                coreEnsure(form.getFields().size == 2, "extension form2 size mismatch")
                coreEnsure(form.getFields()[0].getKey() == "lastName", "extension override order mismatch")
                coreEnsure(form.getFields()[1].getKey() == "firstName", "extension override order mismatch")
            case None => throw Exception("Missing extension nameForm2")
        }

        results = coreValidate(extensionResources, "nameForm2", coreNameBean(None<String>, None<String>, Some("Smith")))
        let firstNameResult = coreRequireValidatorResult(results, "firstName")
        coreEnsure(coreValidatorResultIsNone(results.getValidatorResult("lastName")), "extension lastName should be null after override")
        match (firstNameResult.getField().getArg(0)) {
            case Some(arg) => coreEnsureSomeString("nameForm.lastname.displayname", arg.getKey(), "extension override arg key")
            case None => throw Exception("extension override arg missing")
        }
    }
}

@Test
class CoreResourceAndUtilTranslatedTest {
    @TestCase
    func validatorResourcesEntityImportAndUtilBehaviors(): Unit {
        coreExpectIllegalArgument({ => _ = ValidatorResources(None<String>) })

        let customResources = ValidatorResources(coreResource("TestNumber-config.xml"))
        coreEnsure(customResources.getValidatorActions().size > 0, "custom validator resources should load actions")

        let entityPath = coreResource("EntityImportTest-config.xml")
        let byString = ValidatorResources(entityPath)
        coreEnsure(coreFormIsSome(byString.getForm(Locale.getDefault(), "byteForm")), "entity import string constructor should load byteForm")
        let byUrl = ValidatorResources(URL(entityPath))
        coreEnsure(coreFormIsSome(byUrl.getForm(Locale.getDefault(), "byteForm")), "entity import URL constructor should load byteForm")

        let flags = UtilFlags()
        flags.turnOn(1)
        flags.turnOn(4)
        coreEnsure(flags.isOn(1), "flags long-flag should be on")
        coreEnsure(!flags.isOff(1), "flags long-flag should not be off")
        coreEnsure(flags.isOn(4), "flags int-flag should be on")
        coreEnsure(flags.isOff(2), "flags second flag should be off")
        coreEnsure(UtilFlags(45).hashCode() == 45, "flags hashCode mismatch")
        coreEnsure(UtilFlags(45).getFlags() == 45, "flags getFlags mismatch")
        let cleared = UtilFlags(98432)
        cleared.clear()
        coreEnsure(cleared.getFlags() == 0, "flags clear mismatch")
        let allOn = UtilFlags()
        allOn.turnOnAll()
        let highOrderBit = Int64(1) << 63
        coreEnsure(allOn.isOn(highOrderBit), "flags high-order bit mismatch")
        coreEnsure(allOn.getFlags() == -1, "flags turnOnAll mismatch")
        let rendered = UtilFlags()
        rendered.turnOn(4)
        coreEnsure(rendered.toString().size == 64, "flags toString length mismatch")
        coreEnsure(rendered.toString() == "0000000000000000000000000000000000000000000000000000000000000100", "flags toString bits mismatch")

        let original = UtilFastHashMap<String, String>()
        original.put("key1", "value1")
        original.put("key2", "value2")
        original.put("key3", "value3")
        original.setFast(true)
        let copy = UtilValidatorUtils.copyFastHashMap(original)
        coreEnsure(copy.equals(original), "copyFastHashMap equality mismatch")
        coreEnsure(copy.isFast(), "copyFastHashMap fast flag mismatch")
    }
}
