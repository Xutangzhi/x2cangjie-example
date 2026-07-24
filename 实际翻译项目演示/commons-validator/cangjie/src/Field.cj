package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class Field <: ToString {
//   static fields/constants:
//     public static let TOKEN_INDEXED = "[]"
//
//   constructors:
//     public init()
//
//   methods:
//     public func addArg(arg: Arg): Unit
//     public func addMsg(message: Msg): Unit
//     public func addVar(name: String, value: String, jsType: String): Unit
//     public func addVar(variable: Var): Unit
//     public func generateKey(): Unit
//     public func getArg(position: Int64): ?Arg
//     public func getArg(name: String, position: Int64): ?Arg
//     public func getArgs(name: String): Array<?Arg>
//     public func getDependencyList(): Array<String>
//     public func getDepends(): ?String
//     public func getFieldOrder(): Int64
//     public func getMessage(name: String): ?Msg
//     public func getMessages(): FastHashMap<String, Msg>
//     protected func getMsgMap(): FastHashMap<String, Msg>
//     public func getMsg(name: String): ?String
//     public func getIndexedListProperty(): ?String
//     public func getIndexedProperty(): ?String
//     public func getKey(): String
//     public func getPage(): Int64
//     public func getProperty(): String
//     public func getVar(mainKey: String): ?Var
//     public func getVarValue(mainKey: String): ?String
//     public func getVars(): FastHashMap<String, Var>
//     protected func getVarMap(): FastHashMap<String, Var>
//     public func isClientValidation(): Bool
//     public func isDependency(validatorName: String): Bool
//     public func isIndexed(): Bool
//     public func clone(): Field
//     public func toString(): String
//     public func process(globalConstants: HashMap<String, String>, constants: HashMap<String, String>): Unit
//     public func validate(params: HashMap<String, Any>, actions: HashMap<String, ValidatorAction>): ValidatorResults
//     public func setDepends(depends: String): Unit
//     public func setFieldOrder(fieldOrder: Int64): Unit
//     public func setClientValidation(clientValidation: Bool): Unit
//     public func setIndexedListProperty(indexedListProperty: String): Unit
//     public func setIndexedProperty(indexedProperty: String): Unit
//     public func setKey(key: String): Unit
//     public func setPage(page: Int64): Unit
//     public func setProperty(property: String): Unit
// }

import std.collection.*

private let VALIDATOR_FIELD_DEFAULT_ARG = "org.apache.commons.validator.Field.DEFAULT"
private let VALIDATOR_FIELD_TOKEN_START = "$" + "{"
private let VALIDATOR_FIELD_TOKEN_END = "}"
private let VALIDATOR_FIELD_TOKEN_VAR = "var:"

private func validatorFieldString(value: ?String): String {
    match (value) {
        case Some(text) => text
        case None => ""
    }
}

private func validatorFieldCopyArgMap(source: HashMap<String, Arg>): HashMap<String, Arg> {
    let result = HashMap<String, Arg>()
    for (key in source.keys()) {
        match (source.get(key)) {
            case Some(arg) => result[key] = arg.clone()
            case None => ()
        }
    }
    result
}

private func validatorFieldRawProperty(bean: Any, property: String): ?Any {
    match (bean) {
        case map: HashMap<String, Any> =>
            map.get(property)
        case _ =>
            None<Any>
    }
}

private func validatorFieldAnyArray(raw: Any, property: String): Array<Any> {
    match (raw) {
        case values: Array<Any> =>
            values.clone()
        case values: Array<String> =>
            var out = ArrayList<Any>()
            for (value in values) {
                out.add(value)
            }
            out.toArray()
        case values: ArrayList<Any> =>
            values.toArray()
        case values: ArrayList<String> =>
            var out = ArrayList<Any>()
            for (value in values) {
                out.add(value)
            }
            out.toArray()
        case _ =>
            throw ValidatorException("${property} is not indexed")
    }
}

public class Field <: ToString {
    public static let TOKEN_INDEXED = "[]"

    private var property = ""
    private var indexedProperty: ?String = None<String>
    private var indexedListProperty: ?String = None<String>
    private var key = ""
    private var depends: ?String = None<String>
    private var page: Int64 = 0
    private var clientValidation = true
    private var fieldOrder: Int64 = 0
    private let dependencyList = ArrayList<String>()
    private var hVars = FastHashMap<String, Var>()
    private var hMsgs = FastHashMap<String, Msg>()
    private let args = HashMap<Int64, HashMap<String, Arg>>()
    private var argsSize: Int64 = 0

    public init() {}

    public func addArg(arg: Arg): Unit {
        match (arg.getKey()) {
            case Some(argKey) =>
                if (argKey.isEmpty()) {
                    return
                }
            case None =>
                return
        }

        determineArgPosition(arg)
        ensureArgsCapacity(arg)

        let position = arg.getPosition()
        let argMap = match (args.get(position)) {
            case Some(existing) => existing
            case None =>
                let created = HashMap<String, Arg>()
                args[position] = created
                created
        }
        match (arg.getName()) {
            case Some(name) => argMap[name] = arg
            case None => argMap[VALIDATOR_FIELD_DEFAULT_ARG] = arg
        }
    }

    public func addMsg(message: Msg): Unit {
        match (message.getName()) {
            case Some(name) => hMsgs.add(name, message)
            case None => ()
        }
    }

    public func addVar(name: String, value: String, jsType: String): Unit {
        addVar(Var(name, value, jsType))
    }

    public func addVar(variable: Var): Unit {
        match (variable.getName()) {
            case Some(name) => hVars.add(name, variable)
            case None => ()
        }
    }

    private func determineArgPosition(arg: Arg): Unit {
        if (arg.getPosition() >= 0) {
            return
        }
        if (argsSize == 0) {
            arg.setPosition(0)
            return
        }

        let keyName = match (arg.getName()) {
            case Some(name) => name
            case None => VALIDATOR_FIELD_DEFAULT_ARG
        }
        var lastPosition: Int64 = -1
        var lastDefault: Int64 = -1
        for (i in 0..argsSize) {
            match (args.get(i)) {
                case Some(argMap) =>
                    match (argMap.get(keyName)) {
                        case Some(_) => lastPosition = i
                        case None => ()
                    }
                    match (argMap.get(VALIDATOR_FIELD_DEFAULT_ARG)) {
                        case Some(_) => lastDefault = i
                        case None => ()
                    }
                case None => ()
            }
        }
        if (lastPosition < 0) {
            lastPosition = lastDefault
        }
        arg.setPosition(lastPosition + 1)
    }

    private func ensureArgsCapacity(arg: Arg): Unit {
        if (arg.getPosition() + 1 > argsSize) {
            argsSize = arg.getPosition() + 1
        }
    }

    public func generateKey(): Unit {
        if (isIndexed()) {
            key = validatorFieldString(indexedListProperty) + TOKEN_INDEXED + "." + property
        } else {
            key = property
        }
    }

    public func getArg(position: Int64): ?Arg {
        getArg(VALIDATOR_FIELD_DEFAULT_ARG, position)
    }

    public func getArg(name: String, position: Int64): ?Arg {
        if (position < 0 || position >= argsSize) {
            return None<Arg>
        }
        match (args.get(position)) {
            case Some(argMap) =>
                match (argMap.get(name)) {
                    case Some(arg) => Some(arg)
                    case None =>
                        if (name == VALIDATOR_FIELD_DEFAULT_ARG) {
                            None<Arg>
                        } else {
                            getArg(position)
                        }
                }
            case None =>
                None<Arg>
        }
    }

    public func getArgs(name: String): Array<?Arg> {
        var out = ArrayList<?Arg>()
        for (i in 0..argsSize) {
            out.add(getArg(name, i))
        }
        out.toArray()
    }

    public func getDependencyList(): Array<String> {
        dependencyList.toArray()
    }

    public func getDepends(): ?String {
        depends
    }

    public func getFieldOrder(): Int64 {
        fieldOrder
    }

    public func getMessage(name: String): ?Msg {
        hMsgs.get(name)
    }

    public func getMessages(): FastHashMap<String, Msg> {
        ValidatorUtils.copyFastHashMap(hMsgs)
    }

    protected func getMsgMap(): FastHashMap<String, Msg> {
        hMsgs
    }

    public func getMsg(name: String): ?String {
        match (getMessage(name)) {
            case Some(message) => Some(message.getKey())
            case None => None<String>
        }
    }

    public func getIndexedListProperty(): ?String {
        indexedListProperty
    }

    public func getIndexedProperty(): ?String {
        indexedProperty
    }

    public func getKey(): String {
        if (key.isEmpty()) {
            generateKey()
        }
        key
    }

    public func getPage(): Int64 {
        page
    }

    public func getProperty(): String {
        property
    }

    public func getVar(mainKey: String): ?Var {
        hVars.get(mainKey)
    }

    public func getVarValue(mainKey: String): ?String {
        match (getVar(mainKey)) {
            case Some(variable) => variable.getValue()
            case None => None<String>
        }
    }

    public func getVars(): FastHashMap<String, Var> {
        ValidatorUtils.copyFastHashMap(hVars)
    }

    protected func getVarMap(): FastHashMap<String, Var> {
        hVars
    }

    public func isClientValidation(): Bool {
        clientValidation
    }

    public func isDependency(validatorName: String): Bool {
        for (depend in dependencyList) {
            if (depend == validatorName) {
                return true
            }
        }
        false
    }

    public func isIndexed(): Bool {
        match (indexedListProperty) {
            case Some(value) => !value.isEmpty()
            case None => false
        }
    }

    public func clone(): Field {
        let copy = Field()
        copy.setProperty(property)
        match (indexedProperty) {
            case Some(value) => copy.setIndexedProperty(value)
            case None => ()
        }
        match (indexedListProperty) {
            case Some(value) => copy.setIndexedListProperty(value)
            case None => ()
        }
        copy.setKey(key)
        match (depends) {
            case Some(value) => copy.setDepends(value)
            case None => ()
        }
        copy.setPage(page)
        copy.setClientValidation(clientValidation)
        copy.setFieldOrder(fieldOrder)
        copy.hVars = ValidatorUtils.copyFastHashMap(hVars)
        copy.hMsgs = ValidatorUtils.copyFastHashMap(hMsgs)
        copy.argsSize = argsSize
        for (position in args.keys()) {
            match (args.get(position)) {
                case Some(argMap) => copy.args[position] = validatorFieldCopyArgMap(argMap)
                case None => ()
            }
        }
        copy
    }

    public func toString(): String {
        var result = "\t\tkey = ${key}\n"
        result += "\t\tproperty = ${property}\n"
        result += "\t\tindexedProperty = ${indexedProperty}\n"
        result += "\t\tindexedListProperty = ${indexedListProperty}\n"
        result += "\t\tdepends = ${depends}\n"
        result += "\t\tpage = ${page}\n"
        result += "\t\tfieldOrder = ${fieldOrder}\n"
        if (!hVars.isEmpty()) {
            result += "\t\tVars:\n"
            for (varKey in hVars.keys()) {
                result += "\t\t\t${varKey}=${hVars.get(varKey)}\n"
            }
        }
        result
    }

    public func process(globalConstants: HashMap<String, String>, constants: HashMap<String, String>): Unit {
        hMsgs.setFast(false)
        hVars.setFast(true)

        generateKey()

        for (constantKey in constants.keys()) {
            match (constants.get(constantKey)) {
                case Some(replaceValue) =>
                    let token = VALIDATOR_FIELD_TOKEN_START + constantKey + VALIDATOR_FIELD_TOKEN_END
                    property = ValidatorUtils.replace(property, token, replaceValue)
                    processVars(token, replaceValue)
                    processMessageComponents(token, replaceValue)
                case None => ()
            }
        }

        for (constantKey in globalConstants.keys()) {
            match (globalConstants.get(constantKey)) {
                case Some(replaceValue) =>
                    let token = VALIDATOR_FIELD_TOKEN_START + constantKey + VALIDATOR_FIELD_TOKEN_END
                    property = ValidatorUtils.replace(property, token, replaceValue)
                    processVars(token, replaceValue)
                    processMessageComponents(token, replaceValue)
                case None => ()
            }
        }

        for (varKey in hVars.keys()) {
            match (getVar(varKey)) {
                case Some(variable) =>
                    match (variable.getValue()) {
                        case Some(replaceValue) =>
                            processMessageComponents(VALIDATOR_FIELD_TOKEN_START + VALIDATOR_FIELD_TOKEN_VAR + varKey + VALIDATOR_FIELD_TOKEN_END, replaceValue)
                        case None => ()
                    }
                case None => ()
            }
        }

        hMsgs.setFast(true)
    }

    private func processArg(token: String, replaceValue: String): Unit {
        for (position in args.keys()) {
            match (args.get(position)) {
                case Some(argMap) =>
                    for (argKey in argMap.keys()) {
                        match (argMap.get(argKey)) {
                            case Some(arg) =>
                                match (arg.getKey()) {
                                    case Some(value) => arg.setKey(ValidatorUtils.replace(value, token, replaceValue))
                                    case None => ()
                                }
                            case None => ()
                        }
                    }
                case None => ()
            }
        }
    }

    private func processMessageComponents(token: String, replaceValue: String): Unit {
        let varKey = VALIDATOR_FIELD_TOKEN_START + VALIDATOR_FIELD_TOKEN_VAR
        if (!token.startsWith(varKey)) {
            for (msgKey in hMsgs.keys()) {
                match (hMsgs.get(msgKey)) {
                    case Some(message) => message.setKey(ValidatorUtils.replace(message.getKey(), token, replaceValue))
                    case None => ()
                }
            }
        }
        processArg(token, replaceValue)
    }

    private func processVars(token: String, replaceValue: String): Unit {
        for (varKey in hVars.keys()) {
            match (hVars.get(varKey)) {
                case Some(variable) =>
                    match (variable.getValue()) {
                        case Some(value) => variable.setValue(ValidatorUtils.replace(value, token, replaceValue))
                        case None => ()
                    }
                case None => ()
            }
        }
    }

    private func handleMissingAction(name: String): Nothing {
        throw ValidatorException("No ValidatorAction named ${name} found for field ${getProperty()}")
    }

    public func getIndexedProperty(bean: Any): Array<Any> {
        let propertyName = validatorFieldString(getIndexedListProperty())
        match (validatorFieldRawProperty(bean, propertyName)) {
            case Some(raw) => validatorFieldAnyArray(raw, getKey())
            case None => throw ValidatorException("${getKey()} is not indexed")
        }
    }

    private func getIndexedPropertySize(bean: Any): Int64 {
        let propertyName = validatorFieldString(getIndexedListProperty())
        match (validatorFieldRawProperty(bean, propertyName)) {
            case Some(raw) =>
                match (raw) {
                    case values: Array<Any> => values.size
                    case values: Array<String> => values.size
                    case values: ArrayList<Any> => values.size
                    case values: ArrayList<String> => values.size
                    case _ => throw ValidatorException("${getKey()} is not indexed")
                }
            case None =>
                0
        }
    }

    private func runDependentValidators(va: ValidatorAction, results: ValidatorResults, actions: HashMap<String, ValidatorAction>, params: HashMap<String, Any>, pos: Int64): Bool {
        let dependentValidators = va.getDependencyList()
        if (dependentValidators.isEmpty()) {
            return true
        }
        for (depend in dependentValidators) {
            match (actions.get(depend)) {
                case Some(action) =>
                    if (!validateForRule(action, results, actions, params, pos)) {
                        return false
                    }
                case None =>
                    handleMissingAction(depend)
            }
        }
        true
    }

    public func validate(params: HashMap<String, Any>, actions: HashMap<String, ValidatorAction>): ValidatorResults {
        match (getDepends()) {
            case None => return ValidatorResults()
            case Some(_) => ()
        }

        let allResults = ValidatorResults()
        match (params.get(Validator.BEAN_PARAM)) {
            case Some(bean) =>
                let numberOfFieldsToValidate = if (isIndexed()) { getIndexedPropertySize(bean) } else { 1 }
                for (fieldNumber in 0..numberOfFieldsToValidate) {
                    let results = ValidatorResults()
                    for (depend in dependencyList) {
                        match (actions.get(depend)) {
                            case Some(action) =>
                                let good = validateForRule(action, results, actions, params, fieldNumber)
                                if (!good) {
                                    allResults.merge(results)
                                    return allResults
                                }
                            case None =>
                                handleMissingAction(depend)
                        }
                    }
                    allResults.merge(results)
                }
                allResults
            case None =>
                allResults
        }
    }

    private func validateForRule(va: ValidatorAction, results: ValidatorResults, actions: HashMap<String, ValidatorAction>, params: HashMap<String, Any>, pos: Int64): Bool {
        match (results.getValidatorResult(getKey())) {
            case Some(existing) =>
                if (existing.containsAction(va.getName())) {
                    return existing.isValid(va.getName())
                }
            case None => ()
        }
        if (!runDependentValidators(va, results, actions, params, pos)) {
            return false
        }
        va.executeValidationMethod(this, params, results, pos)
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

    public func setFieldOrder(fieldOrder: Int64): Unit {
        this.fieldOrder = fieldOrder
    }

    public func setClientValidation(clientValidation: Bool): Unit {
        this.clientValidation = clientValidation
    }

    public func setIndexedListProperty(indexedListProperty: String): Unit {
        this.indexedListProperty = Some(indexedListProperty)
    }

    public func setIndexedProperty(indexedProperty: String): Unit {
        this.indexedProperty = Some(indexedProperty)
    }

    public func setKey(key: String): Unit {
        this.key = key
    }

    public func setPage(page: Int64): Unit {
        this.page = page
    }

    public func setProperty(property: String): Unit {
        this.property = property
    }
}
