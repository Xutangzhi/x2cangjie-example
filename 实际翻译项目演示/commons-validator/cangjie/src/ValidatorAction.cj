package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class ValidatorAction <: ToString {
//   constructors:
//     public init()
//
//   methods:
//     public func executeValidationMethod(field: Field, params: HashMap<String, Any>, results: ValidatorResults): Bool
//     public func getClassName(): String
//     public func getClassname(): String
//     public func getDependencyList(): Array<String>
//     public func getDepends(): ?String
//     public func getMethod(): String
//     public func getMethodParams(): String
//     public func getMsg(): ?String
//     public func getJavascript(): ?String
//     public func getJsFunctionName(): ?String
//     public func getName(): String
//     public func initialize(): Unit
//     protected func loadJavascriptFunction(): Unit
//     public func isDependency(validatorName: String): Bool
//     public func setClassName(className: String): Unit
//     public func setClassname(className: String): Unit
//     public func setDepends(depends: String): Unit
//     public func setMethod(method: String): Unit
//     public func setMethodParams(methodParams: String): Unit
//     public func setMsg(msg: String): Unit
//     public func setJavascript(javascript: String): Unit
//     public func setJsFunction(jsFunction: String): Unit
//     public func setJsFunctionName(jsFunctionName: String): Unit
//     public func setName(name: String): Unit
//     public func toString(): String
// }

// top-level functions:
//   public func validatorRegisterMethod(className: String, method: String, methodParams: String, invoker: (Array<Any>) -> ?Any): Unit

import std.collection.*
import std.fs.*

private let validatorRegisteredMethods = HashMap<String, (Array<Any>) -> ?Any>()
private var validatorBuiltinMethodsLoaded = false

private func validatorMethodKey(className: String, method: String, methodParams: String): String {
    className.trimAscii() + "#" + method.trimAscii() + "#" + methodParams.replace("\n", "").replace("\r", "").replace(" ", "")
}

private func validatorActionGetField(values: Array<Any>, index: Int64): Field {
    match (values[index]) {
        case field: Field => field
        case _ => throw ValidatorException("Expected Field parameter")
    }
}

private func validatorActionGetValidator(values: Array<Any>, index: Int64): Validator {
    match (values[index]) {
        case validator: Validator => validator
        case _ => throw ValidatorException("Expected Validator parameter")
    }
}

private func validatorActionGetLocale(values: Array<Any>, index: Int64): Locale {
    match (values[index]) {
        case locale: Locale => locale
        case _ => throw ValidatorException("Expected Locale parameter")
    }
}

private func validatorActionParameterAliases(name: String): Array<String> {
    if (name == Validator.BEAN_PARAM || name == "java.lang.Object") {
        return [Validator.BEAN_PARAM, "java.lang.Object"]
    }
    if (name == Validator.VALIDATOR_ACTION_PARAM || name == "org.apache.commons.validator.ValidatorAction") {
        return [Validator.VALIDATOR_ACTION_PARAM, "org.apache.commons.validator.ValidatorAction"]
    }
    if (name == Validator.VALIDATOR_RESULTS_PARAM || name == "org.apache.commons.validator.ValidatorResults") {
        return [Validator.VALIDATOR_RESULTS_PARAM, "org.apache.commons.validator.ValidatorResults"]
    }
    if (name == Validator.FORM_PARAM || name == "org.apache.commons.validator.Form") {
        return [Validator.FORM_PARAM, "org.apache.commons.validator.Form"]
    }
    if (name == Validator.FIELD_PARAM || name == "org.apache.commons.validator.Field") {
        return [Validator.FIELD_PARAM, "org.apache.commons.validator.Field"]
    }
    if (name == Validator.VALIDATOR_PARAM || name == "org.apache.commons.validator.Validator") {
        return [Validator.VALIDATOR_PARAM, "org.apache.commons.validator.Validator"]
    }
    if (name == Validator.LOCALE_PARAM || name == "java.util.Locale") {
        return [Validator.LOCALE_PARAM, "java.util.Locale"]
    }
    [name]
}

private func validatorActionEqualsIgnoreCase(left: String, right: String): Bool {
    left.toAsciiLower() == right.toAsciiLower()
}

private func validatorActionCapitalize(value: String): String {
    if (value.isEmpty()) {
        return value
    }
    if (value.size == 1) {
        return value.toAsciiUpper()
    }
    value[0..1].toAsciiUpper() + value[1..]
}

private func validatorActionValue(bean: Any, field: Field): ?String {
    ValidatorUtils.getValueAsString(bean, field.getProperty())
}

private func validatorActionValidateRequired(bean: Any, field: Field): Bool {
    match (validatorActionValue(bean, field)) {
        case Some(value) => !GenericValidator.isBlankOrNull(value)
        case None => false
    }
}

private func validatorActionValidateRequiredIf(bean: Any, field: Field, validator: Validator): Bool {
    let form = match (validator.getParameterValue(Validator.BEAN_PARAM)) {
        case Some(value) => value
        case None => bean
    }
    let value = match (bean) {
        case text: String => Some(text)
        case _ => ValidatorUtils.getValueAsString(bean, field.getProperty())
    }

    var required = false
    let fieldJoin = match (field.getVarValue("fieldJoin")) {
        case Some(joinValue) =>
            if (GenericValidator.isBlankOrNull(joinValue)) { "AND" } else { joinValue }
        case None => "AND"
    }
    if (validatorActionEqualsIgnoreCase(fieldJoin, "AND")) {
        required = true
    }

    var index: Int64 = 0
    while (true) {
        match (field.getVarValue("field[${index}]")) {
            case Some(dependPropValue) =>
                var dependProp = dependPropValue
                let dependTest = match (field.getVarValue("fieldTest[${index}]")) {
                    case Some(testValue) => testValue
                    case None => ""
                }
                let dependTestValue = match (field.getVarValue("fieldValue[${index}]")) {
                    case Some(testValue) => testValue
                    case None => ""
                }
                let dependIndexed = match (field.getVarValue("fieldIndexed[${index}]")) {
                    case Some(indexedValue) => indexedValue
                    case None => "false"
                }
                var thisRequired = false
                if (field.isIndexed() && validatorActionEqualsIgnoreCase(dependIndexed, "true")) {
                    let key = field.getKey()
                    let leftBracket = key.indexOf("[")
                    let dot = key.indexOf(".")
                    match (leftBracket) {
                        case Some(_) =>
                            match (dot) {
                                case Some(dotIndex) =>
                                    let prefix = key[0..dotIndex + 1]
                                    dependProp = prefix + dependProp
                                case None => ()
                            }
                        case None => ()
                    }
                }
                let dependVal = ValidatorUtils.getValueAsString(form, dependProp)
                if (dependTest == "NULL") {
                    thisRequired = match (dependVal) {
                        case Some(text) => text.isEmpty()
                        case None => true
                    }
                }
                if (dependTest == "NOTNULL") {
                    thisRequired = match (dependVal) {
                        case Some(text) => !text.isEmpty()
                        case None => false
                    }
                }
                if (dependTest == "EQUAL") {
                    thisRequired = match (dependVal) {
                        case Some(text) => validatorActionEqualsIgnoreCase(dependTestValue, text)
                        case None => false
                    }
                }
                if (validatorActionEqualsIgnoreCase(fieldJoin, "AND")) {
                    required = required && thisRequired
                } else {
                    required = required || thisRequired
                }
                index++
            case None =>
                break
        }
    }

    if (!required) {
        return true
    }
    match (value) {
        case Some(text) => !text.isEmpty()
        case None => false
    }
}

private func validatorRegisterBuiltinMethods(): Unit {
    if (validatorBuiltinMethodsLoaded) {
        return
    }
    validatorBuiltinMethodsLoaded = true

    validatorRegisterMethod("org.apache.commons.validator.GenericValidatorImpl", "validateByte", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        Some(match (values[0]) {
            case bean => GenericValidator.isByte(validatorActionValue(bean, validatorActionGetField(values, 1)))
        })
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericValidatorImpl", "validateShort", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        Some(match (values[0]) {
            case bean => GenericValidator.isShort(validatorActionValue(bean, validatorActionGetField(values, 1)))
        })
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericValidatorImpl", "validateInt", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        Some(match (values[0]) {
            case bean => GenericValidator.isInt(validatorActionValue(bean, validatorActionGetField(values, 1)))
        })
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericValidatorImpl", "validateLong", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        Some(match (values[0]) {
            case bean => GenericValidator.isLong(validatorActionValue(bean, validatorActionGetField(values, 1)))
        })
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericValidatorImpl", "validateFloat", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        Some(match (values[0]) {
            case bean => GenericValidator.isFloat(validatorActionValue(bean, validatorActionGetField(values, 1)))
        })
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericValidatorImpl", "validateDouble", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        Some(match (values[0]) {
            case bean => GenericValidator.isDouble(validatorActionValue(bean, validatorActionGetField(values, 1)))
        })
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericValidatorImpl", "validateEmail", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        Some(match (values[0]) {
            case bean => GenericValidator.isEmail(validatorActionValue(bean, validatorActionGetField(values, 1)))
        })
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericValidatorImpl", "validatePositive", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        let field = validatorActionGetField(values, 1)
        match (GenericTypeValidator.formatInt(validatorActionValue(values[0], field))) {
            case Some(parsed) => Some(parsed > 0)
            case None => Some(false)
        }
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericValidatorImpl", "validateRequired", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        Some(validatorActionValidateRequired(values[0], validatorActionGetField(values, 1)))
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericValidatorImpl", "validateRequiredIf", "java.lang.Object,org.apache.commons.validator.Field,org.apache.commons.validator.Validator", { values =>
        Some(validatorActionValidateRequiredIf(values[0], validatorActionGetField(values, 1), validatorActionGetValidator(values, 2)))
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericValidatorImpl", "validateRaiseException", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        let field = validatorActionGetField(values, 1)
        let value = validatorActionValue(values[0], field)
        match (value) {
            case Some(text) =>
                if (text == "RUNTIME") {
                    throw Exception("RUNTIME-EXCEPTION")
                }
                if (text == "CHECKED") {
                    throw Exception("CHECKED-EXCEPTION")
                }
                throw ValidatorException("VALIDATOR-EXCEPTION")
            case None =>
                throw ValidatorException("VALIDATOR-EXCEPTION")
        }
    })

    validatorRegisterMethod("org.apache.commons.validator.GenericTypeValidatorImpl", "validateByte", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        match (GenericTypeValidator.formatByte(validatorActionValue(values[0], validatorActionGetField(values, 1)))) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericTypeValidatorImpl", "validateByte", "java.lang.Object,org.apache.commons.validator.Field,java.util.Locale", { values =>
        match (GenericTypeValidator.formatByte(validatorActionValue(values[0], validatorActionGetField(values, 1)), validatorActionGetLocale(values, 2))) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericTypeValidatorImpl", "validateShort", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        match (GenericTypeValidator.formatShort(validatorActionValue(values[0], validatorActionGetField(values, 1)))) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericTypeValidatorImpl", "validateShort", "java.lang.Object,org.apache.commons.validator.Field,java.util.Locale", { values =>
        match (GenericTypeValidator.formatShort(validatorActionValue(values[0], validatorActionGetField(values, 1)), validatorActionGetLocale(values, 2))) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericTypeValidatorImpl", "validateInt", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        match (GenericTypeValidator.formatInt(validatorActionValue(values[0], validatorActionGetField(values, 1)))) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericTypeValidatorImpl", "validateInt", "java.lang.Object,org.apache.commons.validator.Field,java.util.Locale", { values =>
        match (GenericTypeValidator.formatInt(validatorActionValue(values[0], validatorActionGetField(values, 1)), validatorActionGetLocale(values, 2))) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericTypeValidatorImpl", "validateLong", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        match (GenericTypeValidator.formatLong(validatorActionValue(values[0], validatorActionGetField(values, 1)))) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericTypeValidatorImpl", "validateLong", "java.lang.Object,org.apache.commons.validator.Field,java.util.Locale", { values =>
        match (GenericTypeValidator.formatLong(validatorActionValue(values[0], validatorActionGetField(values, 1)), validatorActionGetLocale(values, 2))) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericTypeValidatorImpl", "validateFloat", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        match (GenericTypeValidator.formatFloat(validatorActionValue(values[0], validatorActionGetField(values, 1)))) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericTypeValidatorImpl", "validateFloat", "java.lang.Object,org.apache.commons.validator.Field,java.util.Locale", { values =>
        match (GenericTypeValidator.formatFloat(validatorActionValue(values[0], validatorActionGetField(values, 1)), validatorActionGetLocale(values, 2))) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericTypeValidatorImpl", "validateDouble", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        match (GenericTypeValidator.formatDouble(validatorActionValue(values[0], validatorActionGetField(values, 1)))) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericTypeValidatorImpl", "validateDouble", "java.lang.Object,org.apache.commons.validator.Field,java.util.Locale", { values =>
        match (GenericTypeValidator.formatDouble(validatorActionValue(values[0], validatorActionGetField(values, 1)), validatorActionGetLocale(values, 2))) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericTypeValidatorImpl", "validateDate", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        let field = validatorActionGetField(values, 1)
        let raw = validatorActionValue(values[0], field)
        match (field.getVarValue("datePattern")) {
            case Some(pattern) =>
                if (!pattern.isEmpty()) {
                    return match (GenericTypeValidator.formatDate(raw, pattern, false)) {
                        case Some(parsed) => Some(parsed)
                        case None => None<Any>
                    }
                }
            case None => ()
        }
        match (field.getVarValue("datePatternStrict")) {
            case Some(pattern) =>
                if (!pattern.isEmpty()) {
                    return match (GenericTypeValidator.formatDate(raw, pattern, true)) {
                        case Some(parsed) => Some(parsed)
                        case None => None<Any>
                    }
                }
            case None => ()
        }
        None<Any>
    })
    validatorRegisterMethod("org.apache.commons.validator.GenericTypeValidatorImpl", "validateDate", "java.lang.Object,org.apache.commons.validator.Field,java.util.Locale", { values =>
        match (GenericTypeValidator.formatDate(validatorActionValue(values[0], validatorActionGetField(values, 1)), validatorActionGetLocale(values, 2))) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    })

    validatorRegisterMethod("org.apache.commons.validator.ParameterValidatorImpl", "validateParameter", "java.lang.Object,org.apache.commons.validator.Form,org.apache.commons.validator.Field,org.apache.commons.validator.Validator,org.apache.commons.validator.ValidatorAction,org.apache.commons.validator.ValidatorResults,java.util.Locale", { _ =>
        Some(true)
    })

    validatorRegisterMethod("org.apache.commons.validator.ValidatorTest", "formatDate", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        let field = validatorActionGetField(values, 1)
        match (GenericTypeValidator.formatDate(validatorActionValue(values[0], field), "M/d/yyyy", false)) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    })
    validatorRegisterMethod("org.apache.commons.validator.ValidatorTest", "isCapLetter", "java.lang.Object,org.apache.commons.validator.Field,java.util.List", { values =>
        let field = validatorActionGetField(values, 1)
        let list = values[2]
        let valid = match (validatorActionValue(values[0], field)) {
            case Some(text) =>
                text.size == 1 && text[0..1] >= "A" && text[0..1] <= "Z"
            case None => false
        }
        if (!valid) {
            match (list) {
                case entries: ArrayList<String> => entries.add("Error")
                case _ => ()
            }
        }
        Some(valid)
    })

    validatorRegisterMethod("org.apache.commons.validator.TestValidator", "validateRequired", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        Some(validatorActionValidateRequired(values[0], validatorActionGetField(values, 1)))
    })
    validatorRegisterMethod("org.apache.commons.validator.TestValidator", "validateByte", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        Some(GenericValidator.isByte(validatorActionValue(values[0], validatorActionGetField(values, 1))))
    })
    validatorRegisterMethod("org.apache.commons.validator.TestTypeValidator", "validateByte", "java.lang.Object,org.apache.commons.validator.Field", { values =>
        match (GenericTypeValidator.formatByte(validatorActionValue(values[0], validatorActionGetField(values, 1)))) {
            case Some(parsed) => Some(parsed)
            case None => None<Any>
        }
    })
}

public func validatorRegisterMethod(className: String, method: String, methodParams: String, invoker: (Array<Any>) -> ?Any): Unit {
    validatorRegisteredMethods[validatorMethodKey(className, method, methodParams)] = invoker
}

public class ValidatorAction <: ToString {
    private var name = ""
    private var className = ""
    private var method = ""
    private var methodParams = Validator.BEAN_PARAM + "," + Validator.VALIDATOR_ACTION_PARAM + "," + Validator.FIELD_PARAM
    private var depends: ?String = None<String>
    private var msg: ?String = None<String>
    private var jsFunctionName: ?String = None<String>
    private var jsFunction: ?String = None<String>
    private var javascript: ?String = None<String>
    private let dependencyList = ArrayList<String>()
    private let methodParameterList = ArrayList<String>()

    public init() {
        setMethodParams(methodParams)
    }

    public func executeValidationMethod(field: Field, params: HashMap<String, Any>, results: ValidatorResults): Bool {
        executeValidationMethod(field, params, results, 0)
    }

    public func executeValidationMethod(field: Field, params: HashMap<String, Any>, results: ValidatorResults, pos: Int64): Bool {
        validatorRegisterBuiltinMethods()
        params[Validator.VALIDATOR_ACTION_PARAM] = this
        params["org.apache.commons.validator.ValidatorAction"] = this
        let key = validatorMethodKey(className, method, methodParams)
        try {
            let paramValues = getParameterValues(params)
            if (field.isIndexed()) {
                handleIndexedField(field, pos, paramValues)
            }
            match (validatorRegisteredMethods.get(key)) {
                case Some(invoker) =>
                    let result = invoker(paramValues)
                    let valid = isValid(result)
                    let validatorValue = match (params.get(Validator.VALIDATOR_PARAM)) {
                        case Some(value) =>
                            match (value) {
                                case validator: Validator => validator
                                case _ => Validator(ValidatorResources())
                            }
                        case None => Validator(ValidatorResources())
                    }
                    if (!valid || !validatorValue.getOnlyReturnErrors()) {
                        results.add(field, name, valid, result)
                    }
                    valid
                case None =>
                    throw ValidatorException("No such validation method: ${method}")
            }
        } catch (e: ValidatorException) {
            throw e
        } catch (e: Exception) {
            results.add(field, name, false)
            false
        }
    }

    public func getClassName(): String {
        className
    }

    public func getClassname(): String {
        className
    }

    public func getDependencyList(): Array<String> {
        dependencyList.toArray()
    }

    public func getDepends(): ?String {
        depends
    }

    public func getMethod(): String {
        method
    }

    public func getMethodParams(): String {
        methodParams
    }

    public func getMsg(): ?String {
        msg
    }

    public func getJavascript(): ?String {
        javascript
    }

    public func getJsFunctionName(): ?String {
        jsFunctionName
    }

    public func getName(): String {
        name
    }

    public func initialize(): Unit {
        loadJavascriptFunction()
    }

    protected func loadJavascriptFunction(): Unit {
        match (javascript) {
            case Some(_) => return
            case None => ()
        }
        match (jsFunction) {
            case Some(path) =>
                let normalized = if (path.startsWith("/")) {
                    path
                } else {
                    path.replace(".", "/") + ".js"
                }
                try {
                    javascript = Some(String.fromUtf8(File.readFrom(normalized)))
                } catch (_: Exception) {
                    javascript = None<String>
                }
            case None =>
                jsFunction = Some("org.apache.commons.validator.javascript.validate" + validatorActionCapitalize(name))
        }
    }

    public func isDependency(validatorName: String): Bool {
        for (depend in dependencyList) {
            if (depend == validatorName) {
                return true
            }
        }
        false
    }

    public func setClassName(className: String): Unit {
        this.className = className
    }

    public func setClassname(className: String): Unit {
        this.className = className
    }

    public func setDepends(depends: String): Unit {
        this.depends = Some(depends)
        dependencyList.clear()
        for (item in depends.split(",", -1)) {
            let token = item.trimAscii()
            if (!token.isEmpty()) {
                dependencyList.add(token)
            }
        }
    }

    public func setMethod(method: String): Unit {
        this.method = method
    }

    public func setMethodParams(methodParams: String): Unit {
        this.methodParams = methodParams
        methodParameterList.clear()
        for (item in methodParams.split(",", -1)) {
            let token = item.replace("\n", "").replace("\r", "").trimAscii()
            if (!token.isEmpty()) {
                methodParameterList.add(token)
            }
        }
    }

    public func setMsg(msg: String): Unit {
        this.msg = Some(msg)
    }

    public func setJavascript(javascript: String): Unit {
        match (jsFunction) {
            case Some(_) => throw IllegalStateException("Cannot call setJavascript() after calling setJsFunction()")
            case None => this.javascript = Some(javascript)
        }
    }

    public func setJsFunction(jsFunction: String): Unit {
        match (javascript) {
            case Some(_) => throw IllegalStateException("Cannot call setJsFunction() after calling setJavascript()")
            case None => this.jsFunction = Some(jsFunction)
        }
    }

    public func setJsFunctionName(jsFunctionName: String): Unit {
        this.jsFunctionName = Some(jsFunctionName)
    }

    public func setName(name: String): Unit {
        this.name = name
    }

    public func toString(): String {
        "ValidatorAction: ${name}\n"
    }

    private func getParameterValues(params: HashMap<String, Any>): Array<Any> {
        var out = ArrayList<Any>()
        for (parameterName in methodParameterList) {
            var value: ?Any = None<Any>
            for (alias in validatorActionParameterAliases(parameterName)) {
                match (params.get(alias)) {
                    case Some(found) =>
                        value = Some(found)
                        break
                    case None => ()
                }
            }
            match (value) {
                case Some(actual) => out.add(actual)
                case None => out.add("")
            }
        }
        out.toArray()
    }

    private func isValid(result: ?Any): Bool {
        match (result) {
            case Some(value) =>
                match (value) {
                    case valid: Bool => valid
                    case _ => true
                }
            case None => false
        }
    }

    private func handleIndexedField(field: Field, pos: Int64, paramValues: Array<Any>): Unit {
        var beanIndex: Int64 = -1
        var fieldIndex: Int64 = -1
        for (i in 0..methodParameterList.size) {
            let parameterName = methodParameterList[i]
            for (alias in validatorActionParameterAliases(parameterName)) {
                if (alias == Validator.BEAN_PARAM || alias == "java.lang.Object") {
                    beanIndex = i
                }
                if (alias == Validator.FIELD_PARAM || alias == "org.apache.commons.validator.Field") {
                    fieldIndex = i
                }
            }
        }
        if (beanIndex < 0 || fieldIndex < 0) {
            return
        }
        let indexedList = field.getIndexedProperty(paramValues[beanIndex])
        paramValues[beanIndex] = indexedList[pos]
        let indexedField = field.clone()
        indexedField.setKey(ValidatorUtils.replace(indexedField.getKey(), Field.TOKEN_INDEXED, "[${pos}]"))
        paramValues[fieldIndex] = indexedField
    }
}
