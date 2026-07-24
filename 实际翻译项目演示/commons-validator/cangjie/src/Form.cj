package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class Form <: ToString {
//   constructors:
//     public init()
//
//   methods:
//     public func addField(field: Field): Unit
//     public func containsField(fieldName: String): Bool
//     public func getExtends(): ?String
//     public func getField(fieldName: String): ?Field
//     protected func getFieldMap(): HashMap<String, Field>
//     public func getFields(): Array<Field>
//     public func getName(): String
//     public func isExtending(): Bool
//     public func isProcessed(): Bool
//     public func merge(depends: Form): Unit
//     public func process(globalConstants: HashMap<String, String>, constants: HashMap<String, String>, forms: HashMap<String, Form>): Unit
//     public func validate(params: HashMap<String, Any>, actions: HashMap<String, ValidatorAction>, page: Int64): ValidatorResults
//     public func validate(params: HashMap<String, Any>, actions: HashMap<String, ValidatorAction>, page: Int64, fieldName: ?String): ValidatorResults
//     public func setExtends(inherit: String): Unit
//     public func setName(name: String): Unit
//     public func toString(): String
// }

import std.collection.*

public class Form <: ToString {
    private var name = ""
    private var fieldList = ArrayList<Field>()
    private let fieldMap = HashMap<String, Field>()
    private var inherit: ?String = None<String>
    private var processed = false

    public init() {}

    public func addField(field: Field): Unit {
        fieldList.add(field)
        fieldMap[field.getKey()] = field
    }

    public func containsField(fieldName: String): Bool {
        match (fieldMap.get(fieldName)) {
            case Some(_) => true
            case None => false
        }
    }

    public func getExtends(): ?String {
        inherit
    }

    public func getField(fieldName: String): ?Field {
        fieldMap.get(fieldName)
    }

    protected func getFieldMap(): HashMap<String, Field> {
        fieldMap
    }

    public func getFields(): Array<Field> {
        fieldList.toArray()
    }

    public func getName(): String {
        name
    }

    public func isExtending(): Bool {
        match (inherit) {
            case Some(_) => true
            case None => false
        }
    }

    public func isProcessed(): Bool {
        processed
    }

    public func merge(depends: Form): Unit {
        var tempFields = ArrayList<Field>()
        let tempMap = HashMap<String, Field>()
        for (defaultField in depends.getFields()) {
            let fieldKey = defaultField.getKey()
            if (!containsField(fieldKey)) {
                tempFields.add(defaultField)
                tempMap[fieldKey] = defaultField
            } else {
                match (getField(fieldKey)) {
                    case Some(oldField) =>
                        tempFields.add(oldField)
                        tempMap[fieldKey] = oldField
                    case None => ()
                }
            }
        }
        let mergedFields = ArrayList<Field>()
        for (field in tempFields) {
            mergedFields.add(field)
        }
        for (field in fieldList) {
            if (!validatorFormHasField(tempMap, field.getKey())) {
                mergedFields.add(field)
            }
        }
        fieldList = mergedFields
        for (fieldKey in tempMap.keys()) {
            match (tempMap.get(fieldKey)) {
                case Some(field) => fieldMap[fieldKey] = field
                case None => ()
            }
        }
    }

    public func process(globalConstants: HashMap<String, String>, constants: HashMap<String, String>, forms: HashMap<String, Form>): Unit {
        if (isProcessed()) {
            return
        }

        var startIndex: Int64 = 0
        let inheritedFields = ArrayList<Field>()
        if (isExtending()) {
            match (inherit) {
                case Some(parentName) =>
                    match (forms.get(parentName)) {
                        case Some(parent) =>
                            if (!parent.isProcessed()) {
                                parent.process(constants, globalConstants, forms)
                            }
                            for (field in parent.getFields()) {
                                if (!validatorFormHasField(fieldMap, field.getKey())) {
                                    inheritedFields.add(field)
                                    fieldMap[field.getKey()] = field
                                    startIndex++
                                }
                            }
                        case None => ()
                    }
                case None => ()
            }
        }
        if (!inheritedFields.isEmpty()) {
            let newFieldList = ArrayList<Field>()
            for (field in inheritedFields) {
                newFieldList.add(field)
            }
            for (field in fieldList) {
                newFieldList.add(field)
            }
            fieldList = newFieldList
        }
        for (i in startIndex..fieldList.size) {
            fieldList[i].process(globalConstants, constants)
        }
        processed = true
    }

    public func validate(params: HashMap<String, Any>, actions: HashMap<String, ValidatorAction>, page: Int64): ValidatorResults {
        validate(params, actions, page, None<String>)
    }

    public func validate(params: HashMap<String, Any>, actions: HashMap<String, ValidatorAction>, page: Int64, fieldName: ?String): ValidatorResults {
        let results = ValidatorResults()
        params[Validator.VALIDATOR_RESULTS_PARAM] = results
        params["org.apache.commons.validator.ValidatorResults"] = results

        match (fieldName) {
            case Some(targetFieldName) =>
                match (fieldMap.get(targetFieldName)) {
                    case Some(field) =>
                        params[Validator.FIELD_PARAM] = field
                        params["org.apache.commons.validator.Field"] = field
                        if (field.getPage() <= page) {
                            results.merge(field.validate(params, actions))
                        }
                    case None =>
                        throw ValidatorException("Unknown field ${targetFieldName} in form ${getName()}")
                }
            case None =>
                for (field in fieldList) {
                    params[Validator.FIELD_PARAM] = field
                    params["org.apache.commons.validator.Field"] = field
                    if (field.getPage() <= page) {
                        results.merge(field.validate(params, actions))
                    }
                }
        }
        results
    }

    public func setExtends(inherit: String): Unit {
        this.inherit = Some(inherit)
    }

    public func setName(name: String): Unit {
        this.name = name
    }

    public func toString(): String {
        var result = "Form: ${name}\n"
        for (field in fieldList) {
            result += "\tField: \n"
            result += field.toString()
            result += "\n"
        }
        result
    }
}

private func validatorFormHasField(map: HashMap<String, Field>, key: String): Bool {
    match (map.get(key)) {
        case Some(_) => true
        case None => false
    }
}
