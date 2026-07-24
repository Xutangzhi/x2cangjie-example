package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class Validator {
//   static fields/constants:
//     public static let BEAN_PARAM = "java.lang.Object"
//     public static let VALIDATOR_ACTION_PARAM = "validator.ValidatorAction"
//     public static let VALIDATOR_RESULTS_PARAM = "validator.ValidatorResults"
//     public static let FORM_PARAM = "validator.Form"
//     public static let FIELD_PARAM = "validator.Field"
//     public static let VALIDATOR_PARAM = "validator.Validator"
//     public static let LOCALE_PARAM = "java.util.Locale"
//
//   constructors:
//     public init(resources: ValidatorResources)
//     public init(resources: ValidatorResources, formName: String)
//     public init(resources: ValidatorResources, formName: String, fieldName: String)
//
//   methods:
//     public func clear(): Unit
//     public func getFieldName(): ?String
//     public func getFormName(): ?String
//     public func getOnlyReturnErrors(): Bool
//     public func getPage(): Int64
//     public func getParameters(): HashMap<String, Any>
//     public func getParameterValue(parameterClassName: String): ?Any
//     public func getResources(): ValidatorResources
//     public func getClassLoader(): ?Any
//     public func getUseContextClassLoader(): Bool
//     public func setFieldName(fieldName: String): Unit
//     public func setFormName(formName: String): Unit
//     public func setOnlyReturnErrors(onlyReturnErrors: Bool): Unit
//     public func setPage(page: Int64): Unit
//     public func setClassLoader(classLoader: Any): Unit
//     public func setUseContextClassLoader(useContextClassLoader: Bool): Unit
//     public func setParameter(parameterClassName: String, value: Any): Unit
//     public func validate(): ValidatorResults
// }

// public class Locale {
//   static fields/constants:
//     public static let US = Locale("en", "US", "")
//     public static let UK = Locale("en", "UK", "")
//     public static let FRENCH = Locale("fr", "", "")
//
//   fields/properties:
//     public let language: String
//     public let country: String
//     public let variant: String
//
//   static functions:
//     public static func getDefault(): Locale
//     public static func setDefault(locale: Locale): Unit
//
//   constructors:
//     public init(language: String, country: String)
//     public init(language: String, country: String, variant: String)
//
//   operator methods:
//     public operator func ==(right: Locale): Bool
//     public operator func !=(right: Locale): Bool
//
//   methods:
//     public func toString(): String
// }

import std.collection.*

public class Locale {
    public static let US = Locale("en", "US", "")
    public static let UK = Locale("en", "UK", "")
    public static let FRENCH = Locale("fr", "", "")

    private static var defaultLocale: Locale = US

    public let language: String
    public let country: String
    public let variant: String

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
    }

    public init(language: String, country: String, variant: String) {
        this.language = language
        this.country = country
        this.variant = variant
    }

    public operator func ==(right: Locale): Bool {
        language == right.language && country == right.country && variant == right.variant
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

private func validatorParameterAliases(name: String): Array<String> {
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

private func validatorPutAliasedParameter(parameters: HashMap<String, Any>, parameterClassName: String, value: Any): Unit {
    for (alias in validatorParameterAliases(parameterClassName)) {
        parameters[alias] = value
    }
}

public class Validator {
    public static let BEAN_PARAM = "java.lang.Object"
    public static let VALIDATOR_ACTION_PARAM = "validator.ValidatorAction"
    public static let VALIDATOR_RESULTS_PARAM = "validator.ValidatorResults"
    public static let FORM_PARAM = "validator.Form"
    public static let FIELD_PARAM = "validator.Field"
    public static let VALIDATOR_PARAM = "validator.Validator"
    public static let LOCALE_PARAM = "java.util.Locale"

    private let resources: ValidatorResources
    private var formName: ?String = None<String>
    private var fieldName: ?String = None<String>
    private let parameters = HashMap<String, Any>()
    private var page: Int64 = 0
    private var classLoader: ?Any = None<Any>
    private var useContextClassLoader = false
    private var onlyReturnErrors = false

    public init(resources: ValidatorResources) {
        this(resources, None<String>, None<String>)
    }

    public init(resources: ValidatorResources, formName: String) {
        this(resources, Some(formName), None<String>)
    }

    public init(resources: ValidatorResources, formName: String, fieldName: String) {
        this(resources, Some(formName), Some(fieldName))
    }

    private init(resources: ValidatorResources, formName: ?String, fieldName: ?String) {
        this.resources = resources
        this.formName = formName
        this.fieldName = fieldName
    }

    public func clear(): Unit {
        formName = None<String>
        fieldName = None<String>
        parameters.clear()
        page = 0
    }

    public func getFieldName(): ?String {
        fieldName
    }

    public func getFormName(): ?String {
        formName
    }

    public func getOnlyReturnErrors(): Bool {
        onlyReturnErrors
    }

    public func getPage(): Int64 {
        page
    }

    public func getParameters(): HashMap<String, Any> {
        let result = HashMap<String, Any>()
        for (key in parameters.keys()) {
            match (parameters.get(key)) {
                case Some(value) => result[key] = value
                case None => ()
            }
        }
        result
    }

    public func getParameterValue(parameterClassName: String): ?Any {
        for (alias in validatorParameterAliases(parameterClassName)) {
            match (parameters.get(alias)) {
                case Some(value) => return Some(value)
                case None => ()
            }
        }
        None<Any>
    }

    public func getResources(): ValidatorResources {
        resources
    }

    public func getClassLoader(): ?Any {
        classLoader
    }

    public func getUseContextClassLoader(): Bool {
        useContextClassLoader
    }

    public func setFieldName(fieldName: String): Unit {
        this.fieldName = Some(fieldName)
    }

    public func setFormName(formName: String): Unit {
        this.formName = Some(formName)
    }

    public func setOnlyReturnErrors(onlyReturnErrors: Bool): Unit {
        this.onlyReturnErrors = onlyReturnErrors
    }

    public func setPage(page: Int64): Unit {
        this.page = page
    }

    public func setClassLoader(classLoader: Any): Unit {
        this.classLoader = Some(classLoader)
    }

    public func setUseContextClassLoader(useContextClassLoader: Bool): Unit {
        this.useContextClassLoader = useContextClassLoader
    }

    public func setParameter(parameterClassName: String, value: Any): Unit {
        validatorPutAliasedParameter(parameters, parameterClassName, value)
    }

    public func validate(): ValidatorResults {
        let locale = match (getParameterValue(LOCALE_PARAM)) {
            case Some(value) =>
                match (value) {
                    case actual: Locale => actual
                    case _ => Locale.getDefault()
                }
            case None =>
                Locale.getDefault()
        }
        setParameter(VALIDATOR_PARAM, this)

        match (formName) {
            case Some(targetFormName) =>
                match (resources.getForm(locale, targetFormName)) {
                    case Some(form) =>
                        setParameter(FORM_PARAM, form)
                        return form.validate(parameters, resources.getValidatorActions(), page, fieldName)
                    case None =>
                        ValidatorResults()
                }
            case None =>
                ValidatorResults()
        }
    }
}
