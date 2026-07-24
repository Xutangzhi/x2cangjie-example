package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public interface Attributes {
//   methods:
//     func getValue(name: String): ?String
// }

// public class FormSetFactory {
//   constructors:
//     public init()
//
//   methods:
//     public func createFormSet(resources: ValidatorResources, language: ?String, country: ?String, variant: ?String): FormSet
//     public func setValidatorResources(resources: ValidatorResources): Unit
//     public func createObject(attributes: Attributes): FormSet
//     public func createObject(resources: ValidatorResources, attributes: HashMap<String, String>): FormSet
// }

import std.collection.*

public interface Attributes {
    func getValue(name: String): ?String
}

public class FormSetFactory {
    private var resources: ?ValidatorResources = None<ValidatorResources>

    public init() {}

    public func createFormSet(resources: ValidatorResources, language: ?String, country: ?String, variant: ?String): FormSet {
        match (resources.getFormSet(language, country, variant)) {
            case Some(existing) =>
                existing
            case None =>
                let formSet = FormSet()
                match (language) {
                    case Some(value) => formSet.setLanguage(value)
                    case None => ()
                }
                match (country) {
                    case Some(value) => formSet.setCountry(value)
                    case None => ()
                }
                match (variant) {
                    case Some(value) => formSet.setVariant(value)
                    case None => ()
                }
                resources.addFormSet(formSet)
                formSet
        }
    }

    public func setValidatorResources(resources: ValidatorResources): Unit {
        this.resources = Some(resources)
    }

    public func createObject(attributes: Attributes): FormSet {
        match (resources) {
            case Some(actualResources) =>
                createFormSet(actualResources, attributes.getValue("language"), attributes.getValue("country"), attributes.getValue("variant"))
            case None =>
                throw IllegalStateException("ValidatorResources not set")
        }
    }

    public func createObject(resources: ValidatorResources, attributes: HashMap<String, String>): FormSet {
        createFormSet(resources, attributes.get("language"), attributes.get("country"), attributes.get("variant"))
    }
}
