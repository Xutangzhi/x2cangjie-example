package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class FormSet <: ToString {
//   static fields/constants:
//     public static let GLOBAL_FORMSET: Int64 = 1
//     public static let LANGUAGE_FORMSET: Int64 = 2
//     public static let COUNTRY_FORMSET: Int64 = 3
//     public static let VARIANT_FORMSET: Int64 = 4
//
//   constructors:
//     public init()
//
//   methods:
//     public func addConstant(name: String, value: String): Unit
//     public func addForm(form: Form): Unit
//     public func displayKey(): String
//     public func getCountry(): ?String
//     public func getForm(formName: String): ?Form
//     public func getConstants(): HashMap<String, String>
//     public func getForms(): HashMap<String, Form>
//     public func getLanguage(): ?String
//     public func getType(): Int64
//     public func getVariant(): ?String
//     public func isMerged(): Bool
//     public func isProcessed(): Bool
//     public func merge(parent: ?FormSet): Unit
//     public func process(globalConstants: HashMap<String, String>): Unit
//     public func setCountry(country: String): Unit
//     public func setLanguage(language: String): Unit
//     public func setVariant(variant: String): Unit
//     public func toString(): String
// }

import std.collection.*

public class FormSet <: ToString {
    public static let GLOBAL_FORMSET: Int64 = 1
    public static let LANGUAGE_FORMSET: Int64 = 2
    public static let COUNTRY_FORMSET: Int64 = 3
    public static let VARIANT_FORMSET: Int64 = 4

    private var processed = false
    private var language: ?String = None<String>
    private var country: ?String = None<String>
    private var variant: ?String = None<String>
    private let forms = HashMap<String, Form>()
    private let constants = HashMap<String, String>()
    private var merged = false

    public init() {}

    public func addConstant(name: String, value: String): Unit {
        if (!validatorFormSetHasString(constants, name)) {
            constants[name] = value
        }
    }

    public func addForm(form: Form): Unit {
        if (!validatorFormSetHasForm(forms, form.getName())) {
            forms[form.getName()] = form
        }
    }

    public func displayKey(): String {
        var result = ""
        match (language) {
            case Some(value) =>
                if (!value.isEmpty()) {
                    result += "language=${value}"
                }
            case None => ()
        }
        match (country) {
            case Some(value) =>
                if (!value.isEmpty()) {
                    if (!result.isEmpty()) {
                        result += ", "
                    }
                    result += "country=${value}"
                }
            case None => ()
        }
        match (variant) {
            case Some(value) =>
                if (!value.isEmpty()) {
                    if (!result.isEmpty()) {
                        result += ", "
                    }
                    result += "variant=${value}"
                }
            case None => ()
        }
        if (result.isEmpty()) {
            return "default"
        }
        result
    }

    public func getCountry(): ?String {
        country
    }

    public func getForm(formName: String): ?Form {
        forms.get(formName)
    }

    public func getConstants(): HashMap<String, String> {
        let result = HashMap<String, String>()
        for (key in constants.keys()) {
            match (constants.get(key)) {
                case Some(value) => result[key] = value
                case None => ()
            }
        }
        result
    }

    public func getForms(): HashMap<String, Form> {
        let result = HashMap<String, Form>()
        for (key in forms.keys()) {
            match (forms.get(key)) {
                case Some(value) => result[key] = value
                case None => ()
            }
        }
        result
    }

    public func getLanguage(): ?String {
        language
    }

    public func getType(): Int64 {
        if (let Some(variantValue) <- variant) {
            if (!variantValue.isEmpty()) {
                if (!validatorFormSetHasLocaleValue(language) || !validatorFormSetHasLocaleValue(country)) {
                    throw NullPointerException("When variant is specified, country and language must be specified.")
                }
                return VARIANT_FORMSET
            }
        }
        if (let Some(countryValue) <- country) {
            if (!countryValue.isEmpty()) {
                if (!validatorFormSetHasLocaleValue(language)) {
                    throw NullPointerException("When country is specified, language must be specified.")
                }
                return COUNTRY_FORMSET
            }
        }
        if (let Some(languageValue) <- language) {
            if (!languageValue.isEmpty()) {
                return LANGUAGE_FORMSET
            }
        }
        GLOBAL_FORMSET
    }

    public func getVariant(): ?String {
        variant
    }

    public func isMerged(): Bool {
        merged
    }

    public func isProcessed(): Bool {
        processed
    }

    public func merge(parent: ?FormSet): Unit {
        match (parent) {
            case Some(depends) =>
                let parentForms = depends.getForms()
                for (key in parentForms.keys()) {
                    match (parentForms.get(key)) {
                        case Some(parentForm) =>
                            match (forms.get(key)) {
                                case Some(form) => form.merge(parentForm)
                                case None => addForm(parentForm)
                            }
                        case None => ()
                    }
                }
            case None => ()
        }
        merged = true
    }

    public func process(globalConstants: HashMap<String, String>): Unit {
        for (formKey in forms.keys()) {
            match (forms.get(formKey)) {
                case Some(form) => form.process(globalConstants, constants, forms)
                case None => ()
            }
        }
        processed = true
    }

    public func setCountry(country: String): Unit {
        this.country = Some(country)
    }

    public func setLanguage(language: String): Unit {
        this.language = Some(language)
    }

    public func setVariant(variant: String): Unit {
        this.variant = Some(variant)
    }

    public func toString(): String {
        var result = "FormSet: language=${language}  country=${country}  variant=${variant}\n"
        for (formKey in forms.keys()) {
            match (forms.get(formKey)) {
                case Some(form) => result += "   ${form}\n"
                case None => ()
            }
        }
        result
    }
}

private func validatorFormSetHasString(map: HashMap<String, String>, key: String): Bool {
    match (map.get(key)) {
        case Some(_) => true
        case None => false
    }
}

private func validatorFormSetHasForm(map: HashMap<String, Form>, key: String): Bool {
    match (map.get(key)) {
        case Some(_) => true
        case None => false
    }
}

private func validatorFormSetHasLocaleValue(value: ?String): Bool {
    match (value) {
        case Some(text) => !text.isEmpty()
        case None => false
    }
}
