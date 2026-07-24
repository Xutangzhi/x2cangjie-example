package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class ValidatorResources {
//   constructors:
//     public init()
//     public init(resource: ?String)
//     public init(resource: String)
//     public init(resource: InputStream)
//     public init(resource: URL)
//     public init(resources: Array<InputStream>)
//     public init(resources: Array<String>)
//     public init(resources: Array<URL>)
//
//   methods:
//     public func addConstant(name: String, value: String): Unit
//     public func addFormSet(formSet: FormSet): Unit
//     public func addValidatorAction(validatorAction: ValidatorAction): Unit
//     protected func getConstants(): HashMap<String, String>
//     public func getForm(locale: Locale, formKey: String): ?Form
//     public func getForm(formKey: String): ?Form
//     public func getForm(language: String, country: String, variant: String, formKey: String): ?Form
//     public func getForm(language: ?String, country: ?String, variant: ?String, formKey: String): ?Form
//     public func getValidatorAction(key: String): ?ValidatorAction
//     protected func getActions(): HashMap<String, ValidatorAction>
//     public func getValidatorActions(): HashMap<String, ValidatorAction>
//     public func getFormSet(language: ?String, country: ?String, variant: ?String): ?FormSet
//     protected func getFormSets(): HashMap<String, FormSet>
//     protected func buildKey(formSet: FormSet): String
//     public func process(): Unit
// }

// public class InputStream {
//   constructors:
//     public init(bytes: Array<UInt8>)
//
//   methods:
//     public func close(): Unit
//     public func readAllBytes(): Array<UInt8>
// }

// public class URL {
//   constructors:
//     public init(externalForm: String)
//
//   methods:
//     public func openStream(): InputStream
//     public func toExternalForm(): String
// }

// top-level fields/constants:
//   let doctype = validatorXml__slice(chars, start, index + 1)
//   var expanded = validatorXml__slice(chars, 0, start) + validatorXml__slice(chars, index + 1, chars.size)
//   let entities = validatorXml__extractEntities(doctype, baseDir)
//   let normalized = validatorXml__normalizeResource(resource)
//   let baseDir = validatorXml__dirname(normalized)
//   let raw = String.fromUtf8(File.readFrom(normalized))
//   let trimmed = value.trimAscii()
//   var index = start + 1
//   var inQuote = false
//   let attrStart = index
//   let attrName = validatorXml__slice(chars, attrStart, index)
//   var attrValue = ""
//   let valueStart = index

import std.collection.*
import std.fs.*

private class ValidatorXmlNode {
    let name: String
    let attributes: HashMap<String, String>
    let children = ArrayList<ValidatorXmlNode>()
    var text = ""

    init(name: String, attributes: HashMap<String, String>) {
        this.name = name
        this.attributes = attributes
    }
}

private func validatorXml__equalsIgnoreCase(left: String, right: String): Bool {
    left.toAsciiLower() == right.toAsciiLower()
}

private func validatorXml__isWhitespace(value: Rune): Bool {
    value == r' ' || value == r'\t' || value == r'\n' || value == r'\r'
}

private func validatorXml__parseInt64(text: String): Int64 {
    let trimmed = text.trimAscii()
    if (trimmed.isEmpty()) {
        return 0
    }
    var negative = false
    var index: Int64 = 0
    let chars = trimmed.toRuneArray()
    if (chars[0] == r'-') {
        negative = true
        index = 1
    }
    var value: Int64 = 0
    while (index < chars.size) {
        value = value * 10 + chars[index].position() - r'0'.position()
        index++
    }
    if (negative) {
        return -value
    }
    value
}

private func validatorXml__slice(chars: Array<Rune>, start: Int64, end: Int64): String {
    var out = ""
    for (i in start..end) {
        out += chars[i].toString()
    }
    out
}

private func validatorXml__normalizeResource(resource: String): String {
    let trimmed = resource.trimAscii()
    if (trimmed.startsWith("file://")) {
        return trimmed[7..trimmed.size]
    }
    if (trimmed.startsWith("file:")) {
        return trimmed[5..trimmed.size]
    }
    trimmed
}

private func validatorXml__dirname(path: String): String {
    var lastSlash: Int64 = -1
    let chars = path.toRuneArray()
    for (i in 0..chars.size) {
        if (chars[i] == r'/') {
            lastSlash = i
        }
    }
    if (lastSlash >= 0) {
        return path[0..lastSlash + 1]
    }
    ""
}

private func validatorXml__decode(value: String): String {
    value.replace("&lt;", "<").replace("&gt;", ">").replace("&quot;", "\"").replace("&apos;", "'").replace("&amp;", "&")
}

private func validatorXml__findDoctypeEnd(chars: Array<Rune>, start: Int64): Int64 {
    var index = start + 1
    var inQuote = false
    var internalSubsetDepth: Int64 = 0
    while (index < chars.size) {
        if (chars[index] == r'"') {
            inQuote = !inQuote
        } else if (!inQuote && chars[index] == r'[') {
            internalSubsetDepth++
        } else if (!inQuote && chars[index] == r']' && internalSubsetDepth > 0) {
            internalSubsetDepth--
        } else if (!inQuote && chars[index] == r'>' && internalSubsetDepth == 0) {
            return index + 1
        }
        index++
    }
    chars.size
}

private func validatorXml__extractEntities(doctype: String, baseDir: String): HashMap<String, String> {
    let entities = HashMap<String, String>()
    var searchStart: Int64 = 0
    while (searchStart < doctype.size) {
        match (doctype.indexOf("<!ENTITY", searchStart)) {
            case Some(entityStart) =>
                match (doctype.indexOf(">", entityStart)) {
                    case Some(entityEnd) =>
                        let declaration = doctype[entityStart..entityEnd + 1]
                        let normalized = declaration.replace("<!ENTITY", "").replace(">", "").trimAscii()
                        let parts = normalized.split(" SYSTEM ", -1)
                        if (parts.size == 2) {
                            let entityName = parts[0].trimAscii()
                            let entityPath = validatorXml__decode(parts[1].trimAscii().replace("\"", ""))
                            let resolved = if (entityPath.startsWith("/")) { entityPath } else if (baseDir.isEmpty()) { entityPath } else { baseDir + entityPath }
                            entities[entityName] = String.fromUtf8(File.readFrom(resolved))
                        }
                        searchStart = entityEnd + 1
                    case None =>
                        searchStart = doctype.size
                }
            case None =>
                searchStart = doctype.size
            }
    }
    entities
}

private func validatorXml__stripComments(xml: String): String {
    var current = xml
    while (true) {
        match (current.indexOf("<!--")) {
            case Some(start) =>
                match (current.indexOf("-->", start)) {
                    case Some(end) =>
                        current = current[0..start] + current[end + 3..current.size]
                    case None => return current
                }
            case None => return current
        }
    }
    current
}

private func validatorXml__expandCustomEntities(resource: String, validatorXml: String): String {
    let chars = validatorXml.toRuneArray()
    match (validatorXml.indexOf("<!DOCTYPE")) {
        case Some(start) =>
            let end = validatorXml__findDoctypeEnd(chars, start)
            let doctype = validatorXml__slice(chars, start, end)
            var expanded = validatorXml__slice(chars, 0, start) + validatorXml__slice(chars, end, chars.size)
            let entities = validatorXml__extractEntities(doctype, validatorXml__dirname(validatorXml__normalizeResource(resource)))
            for (key in entities.keys()) {
                match (entities.get(key)) {
                    case Some(value) => expanded = expanded.replace("&${key};", value)
                    case None => ()
                }
            }
            expanded
        case None =>
            validatorXml
    }
}

private func validatorXml__parseAttributes(chars: Array<Rune>, start: Int64, end: Int64): HashMap<String, String> {
    let attributes = HashMap<String, String>()
    var index = start
    while (index < end) {
        while (index < end && validatorXml__isWhitespace(chars[index])) {
            index++
        }
        if (index >= end) {
            break
        }
        let attrStart = index
        while (index < end && chars[index] != r'=' && !validatorXml__isWhitespace(chars[index])) {
            index++
        }
        let attrName = validatorXml__slice(chars, attrStart, index)
        while (index < end && (validatorXml__isWhitespace(chars[index]) || chars[index] == r'=')) {
            index++
        }
        if (index >= end) {
            break
        }
        let quoteChar = chars[index]
        index++
        let valueStart = index
        while (index < end && chars[index] != quoteChar) {
            index++
        }
        let attrValue = validatorXml__decode(validatorXml__slice(chars, valueStart, index))
        attributes[attrName] = attrValue
        index++
    }
    attributes
}

private func validatorXml__parse(resource: String, xml: String): ValidatorXmlNode {
    let normalized = validatorXml__stripComments(validatorXml__expandCustomEntities(resource, xml))
    let chars = normalized.toRuneArray()
    var index: Int64 = 0
    var root: ?ValidatorXmlNode = None<ValidatorXmlNode>
    var stack = ArrayList<ValidatorXmlNode>()

    while (index < chars.size) {
        if (chars[index] == r'<') {
            if (index + 1 < chars.size && chars[index + 1] == r'?') {
                index += 2
                while (index + 1 < chars.size) {
                    if (chars[index] == r'?' && chars[index + 1] == r'>') {
                        index += 2
                        break
                    }
                    index++
                }
                continue
            }
            if (index + 1 < chars.size && chars[index + 1] == r'/') {
                index += 2
                while (index < chars.size && chars[index] != r'>') {
                    index++
                }
                if (!stack.isEmpty()) {
                    let newStack = ArrayList<ValidatorXmlNode>()
                    var stackIndex: Int64 = 0
                    while (stackIndex + 1 < stack.size) {
                        newStack.add(stack[stackIndex])
                        stackIndex++
                    }
                    stack = newStack
                }
                index++
                continue
            }
            let tagStart = index + 1
            index++
            while (index < chars.size && !validatorXml__isWhitespace(chars[index]) && chars[index] != r'/' && chars[index] != r'>') {
                index++
            }
            let name = validatorXml__slice(chars, tagStart, index)
            let attrStart = index
            var selfClosing = false
            while (index < chars.size && chars[index] != r'>') {
                if (chars[index] == r'/' && index + 1 < chars.size && chars[index + 1] == r'>') {
                    selfClosing = true
                    break
                }
                index++
            }
            let attrEnd = if (selfClosing) { index } else { index }
            let node = ValidatorXmlNode(name, validatorXml__parseAttributes(chars, attrStart, attrEnd))
            if (!stack.isEmpty()) {
                stack[stack.size - 1].children.add(node)
            } else {
                root = Some(node)
            }
            if (!selfClosing) {
                stack.add(node)
            }
            if (selfClosing) {
                index += 2
            } else {
                index++
            }
        } else {
            let textStart = index
            while (index < chars.size && chars[index] != r'<') {
                index++
            }
            if (!stack.isEmpty()) {
                stack[stack.size - 1].text += validatorXml__decode(validatorXml__slice(chars, textStart, index))
            }
        }
    }
    match (root) {
        case Some(node) => node
        case None => throw IllegalArgumentException("Invalid XML resource ${resource}")
    }
}

private func validatorXml__childText(node: ValidatorXmlNode, name: String): ?String {
    for (child in node.children) {
        if (child.name == name) {
            return Some(child.text.trimAscii())
        }
    }
    None<String>
}

private func validatorXml__boolAttr(node: ValidatorXmlNode, name: String, defaultValue: Bool): Bool {
    match (node.attributes.get(name)) {
        case Some(value) => !validatorXml__equalsIgnoreCase(value, "false")
        case None => defaultValue
    }
}

private func validatorXml__parseField(node: ValidatorXmlNode): Field {
    let field = Field()
    match (node.attributes.get("property")) {
        case Some(value) => field.setProperty(value)
        case None => ()
    }
    match (node.attributes.get("depends")) {
        case Some(value) => field.setDepends(value)
        case None => ()
    }
    match (node.attributes.get("page")) {
        case Some(value) =>
            if (!value.trimAscii().isEmpty()) {
                field.setPage(validatorXml__parseInt64(value.trimAscii()))
            }
        case None => ()
    }
    match (node.attributes.get("fieldOrder")) {
        case Some(value) =>
            if (!value.trimAscii().isEmpty()) {
                field.setFieldOrder(validatorXml__parseInt64(value.trimAscii()))
            }
        case None => ()
    }
    match (node.attributes.get("indexedListProperty")) {
        case Some(value) => field.setIndexedListProperty(value)
        case None => ()
    }
    match (node.attributes.get("indexedProperty")) {
        case Some(value) => field.setIndexedProperty(value)
        case None => ()
    }
    match (node.attributes.get("clientValidation")) {
        case Some(value) => field.setClientValidation(!validatorXml__equalsIgnoreCase(value, "false"))
        case None => ()
    }

    for (child in node.children) {
        if (child.name == "arg" || (child.name.startsWith("arg") && child.name.size == 4)) {
            let arg = Arg()
            match (child.attributes.get("key")) {
                case Some(value) => arg.setKey(value)
                case None => ()
            }
            match (child.attributes.get("name")) {
                case Some(value) => arg.setName(value)
                case None => ()
            }
            match (child.attributes.get("position")) {
                case Some(value) =>
                    if (!value.trimAscii().isEmpty()) {
                        arg.setPosition(validatorXml__parseInt64(value.trimAscii()))
                    }
                case None =>
                    if (child.name != "arg") {
                        arg.setPosition(validatorXml__parseInt64(child.name[3..child.name.size]))
                    }
            }
            match (child.attributes.get("bundle")) {
                case Some(value) => arg.setBundle(value)
                case None => ()
            }
            if (!validatorXml__boolAttr(child, "resource", true)) {
                arg.setResource(false)
            }
            field.addArg(arg)
        } else if (child.name == "msg") {
            let message = Msg()
            match (child.attributes.get("key")) {
                case Some(value) => message.setKey(value)
                case None => ()
            }
            match (child.attributes.get("name")) {
                case Some(value) => message.setName(value)
                case None => ()
            }
            match (child.attributes.get("bundle")) {
                case Some(value) => message.setBundle(value)
                case None => ()
            }
            if (!validatorXml__boolAttr(child, "resource", true)) {
                message.setResource(false)
            }
            field.addMsg(message)
        } else if (child.name == "var") {
            let variable = Var()
            match (validatorXml__childText(child, "var-name")) {
                case Some(value) => variable.setName(value)
                case None => ()
            }
            match (validatorXml__childText(child, "var-value")) {
                case Some(value) => variable.setValue(value)
                case None => ()
            }
            match (validatorXml__childText(child, "var-jstype")) {
                case Some(value) =>
                    if (!value.isEmpty()) {
                        variable.setJsType(value)
                    }
                case None => ()
            }
            match (child.attributes.get("bundle")) {
                case Some(value) => variable.setBundle(value)
                case None => ()
            }
            if (validatorXml__boolAttr(child, "resource", false)) {
                variable.setResource(true)
            }
            field.addVar(variable)
        }
    }
    field
}

private func validatorXml__parseForm(node: ValidatorXmlNode): Form {
    let form = Form()
    match (node.attributes.get("name")) {
        case Some(value) => form.setName(value)
        case None => ()
    }
    match (node.attributes.get("extends")) {
        case Some(value) => form.setExtends(value)
        case None => ()
    }
    for (child in node.children) {
        if (child.name == "field") {
            form.addField(validatorXml__parseField(child))
        }
    }
    form
}

private func validatorXml__parseFormSet(resources: ValidatorResources, node: ValidatorXmlNode): Unit {
    let factory = FormSetFactory()
    let formSet = factory.createObject(resources, node.attributes)
    for (child in node.children) {
        if (child.name == "constant") {
            let constantName = validatorXml__childText(child, "constant-name")
            let constantValue = validatorXml__childText(child, "constant-value")
            match (constantName) {
                case Some(name) =>
                    match (constantValue) {
                        case Some(value) => formSet.addConstant(name, value)
                        case None => ()
                    }
                case None => ()
            }
        } else if (child.name == "form") {
            formSet.addForm(validatorXml__parseForm(child))
        }
    }
}

private func validatorXml__parseValidatorAction(node: ValidatorXmlNode): ValidatorAction {
    let action = ValidatorAction()
    match (node.attributes.get("name")) {
        case Some(value) => action.setName(value)
        case None => ()
    }
    match (node.attributes.get("classname")) {
        case Some(value) => action.setClassname(value)
        case None => ()
    }
    match (node.attributes.get("className")) {
        case Some(value) => action.setClassName(value)
        case None => ()
    }
    match (node.attributes.get("method")) {
        case Some(value) => action.setMethod(value)
        case None => ()
    }
    match (node.attributes.get("methodParams")) {
        case Some(value) => action.setMethodParams(value)
        case None => ()
    }
    match (node.attributes.get("depends")) {
        case Some(value) => action.setDepends(value)
        case None => ()
    }
    match (node.attributes.get("msg")) {
        case Some(value) => action.setMsg(value)
        case None => ()
    }
    match (node.attributes.get("jsFunction")) {
        case Some(value) => action.setJsFunction(value)
        case None => ()
    }
    match (node.attributes.get("jsFunctionName")) {
        case Some(value) => action.setJsFunctionName(value)
        case None => ()
    }
    action
}

private func validatorXml__loadIntoResources(resources: ValidatorResources, resourceName: String, xmlText: String): Unit {
    let root = validatorXml__parse(resourceName, xmlText)
    if (root.name != "form-validation") {
        throw IllegalArgumentException("Unexpected root element ${root.name}")
    }
    for (child in root.children) {
        if (child.name == "global") {
            for (grandChild in child.children) {
                if (grandChild.name == "validator") {
                    resources.addValidatorAction(validatorXml__parseValidatorAction(grandChild))
                }
            }
        } else if (child.name == "formset") {
            validatorXml__parseFormSet(resources, child)
        }
    }
}

public class InputStream {
    private let bytes: Array<UInt8>

    public init(bytes: Array<UInt8>) {
        this.bytes = bytes.clone()
    }

    public func close(): Unit {}

    public func readAllBytes(): Array<UInt8> {
        bytes.clone()
    }
}

public class URL {
    private let externalForm: String

    public init(externalForm: String) {
        this.externalForm = externalForm
    }

    public func openStream(): InputStream {
        InputStream(File.readFrom(validatorXml__normalizeResource(externalForm)))
    }

    public func toExternalForm(): String {
        externalForm
    }
}

public class ValidatorResources {
    private let formSets = HashMap<String, FormSet>()
    private let constants = HashMap<String, String>()
    private let actions = HashMap<String, ValidatorAction>()
    private var defaultFormSet = FormSet()

    public init() {}

    public init(resource: ?String) {
        this()
        match (resource) {
            case Some(value) =>
                validatorXml__loadIntoResources(this, value, String.fromUtf8(File.readFrom(validatorXml__normalizeResource(value))))
                process()
            case None =>
                throw IllegalArgumentException("Resource is null")
        }
    }

    public init(resource: String) {
        this(Some(resource))
    }

    public init(resource: InputStream) {
        this([resource])
    }

    public init(resource: URL) {
        this([resource])
    }

    public init(resources: Array<InputStream>) {
        this()
        for (i in 0..resources.size) {
            validatorXml__loadIntoResources(this, "stream-${i}", String.fromUtf8(resources[i].readAllBytes()))
        }
        process()
    }

    public init(resources: Array<String>) {
        this()
        for (resource in resources) {
            let normalized = validatorXml__normalizeResource(resource)
            validatorXml__loadIntoResources(this, resource, String.fromUtf8(File.readFrom(normalized)))
        }
        process()
    }

    public init(resources: Array<URL>) {
        this()
        for (resource in resources) {
            validatorXml__loadIntoResources(this, resource.toExternalForm(), String.fromUtf8(resource.openStream().readAllBytes()))
        }
        process()
    }

    public func addConstant(name: String, value: String): Unit {
        constants[name] = value
    }

    public func addFormSet(formSet: FormSet): Unit {
        let key = buildKey(formSet)
        if (key.isEmpty()) {
            defaultFormSet = formSet
        } else {
            formSets[key] = formSet
        }
    }

    public func addValidatorAction(validatorAction: ValidatorAction): Unit {
        validatorAction.initialize()
        actions[validatorAction.getName()] = validatorAction
    }

    protected func getConstants(): HashMap<String, String> {
        let result = HashMap<String, String>()
        for (key in constants.keys()) {
            match (constants.get(key)) {
                case Some(value) => result[key] = value
                case None => ()
            }
        }
        result
    }

    public func getForm(locale: Locale, formKey: String): ?Form {
        getForm(locale.language, locale.country, locale.variant, formKey)
    }

    public func getForm(formKey: String): ?Form {
        let locale = Locale.getDefault()
        getForm(locale, formKey)
    }

    public func getForm(language: String, country: String, variant: String, formKey: String): ?Form {
        getForm(Some(language), Some(country), Some(variant), formKey)
    }

    public func getForm(language: ?String, country: ?String, variant: ?String, formKey: String): ?Form {
        var form: ?Form = None<Form>
        var key = buildLocale(language, country, variant)
        if (!key.isEmpty()) {
            match (formSets.get(key)) {
                case Some(formSet) => form = formSet.getForm(formKey)
                case None => ()
            }
        }
        if (!validatorResourcesHasForm(form)) {
            key = buildLocale(language, country, None<String>)
            if (!key.isEmpty()) {
                match (formSets.get(key)) {
                    case Some(formSet) => form = formSet.getForm(formKey)
                    case None => ()
                }
            }
        }
        if (!validatorResourcesHasForm(form)) {
            key = buildLocale(language, None<String>, None<String>)
            if (!key.isEmpty()) {
                match (formSets.get(key)) {
                    case Some(formSet) => form = formSet.getForm(formKey)
                    case None => ()
                }
            }
        }
        if (!validatorResourcesHasForm(form)) {
            return defaultFormSet.getForm(formKey)
        }
        form
    }

    public func getValidatorAction(key: String): ?ValidatorAction {
        actions.get(key)
    }

    protected func getActions(): HashMap<String, ValidatorAction> {
        let result = HashMap<String, ValidatorAction>()
        for (key in actions.keys()) {
            match (actions.get(key)) {
                case Some(value) => result[key] = value
                case None => ()
            }
        }
        result
    }

    public func getValidatorActions(): HashMap<String, ValidatorAction> {
        getActions()
    }

    public func getFormSet(language: ?String, country: ?String, variant: ?String): ?FormSet {
        let key = buildLocale(language, country, variant)
        if (key.isEmpty()) {
            return Some(defaultFormSet)
        }
        formSets.get(key)
    }

    protected func getFormSets(): HashMap<String, FormSet> {
        let result = HashMap<String, FormSet>()
        for (key in formSets.keys()) {
            match (formSets.get(key)) {
                case Some(value) => result[key] = value
                case None => ()
            }
        }
        result
    }

    protected func buildKey(formSet: FormSet): String {
        buildLocale(formSet.getLanguage(), formSet.getCountry(), formSet.getVariant())
    }

    public func process(): Unit {
        defaultFormSet.process(constants)
        for (key in formSets.keys()) {
            match (formSets.get(key)) {
                case Some(formSet) => formSet.merge(getParent(formSet))
                case None => ()
            }
        }
        for (key in formSets.keys()) {
            match (formSets.get(key)) {
                case Some(formSet) =>
                    if (!formSet.isProcessed()) {
                        formSet.process(constants)
                    }
                case None => ()
            }
        }
    }

    private func buildLocale(language: ?String, country: ?String, variant: ?String): String {
        var key = match (language) {
            case Some(value) =>
                if (value.isEmpty()) { "" } else { value }
            case None => ""
        }
        match (country) {
            case Some(value) =>
                if (!value.isEmpty()) {
                    key += "_" + value
                }
            case None => ()
        }
        match (variant) {
            case Some(value) =>
                if (!value.isEmpty()) {
                    key += "_" + value
                }
            case None => ()
        }
        key
    }

    private func getParent(formSet: FormSet): ?FormSet {
        if (formSet.getType() == FormSet.LANGUAGE_FORMSET) {
            return Some(defaultFormSet)
        }
        if (formSet.getType() == FormSet.COUNTRY_FORMSET) {
            match (getFormSet(formSet.getLanguage(), None<String>, None<String>)) {
                case Some(parent) => return Some(parent)
                case None => return Some(defaultFormSet)
            }
        }
        if (formSet.getType() == FormSet.VARIANT_FORMSET) {
            match (getFormSet(formSet.getLanguage(), formSet.getCountry(), None<String>)) {
                case Some(parent) => return Some(parent)
                case None =>
                    match (getFormSet(formSet.getLanguage(), None<String>, None<String>)) {
                        case Some(parent) => return Some(parent)
                        case None => return Some(defaultFormSet)
                    }
            }
        }
        None<FormSet>
    }
}

private func validatorResourcesHasForm(form: ?Form): Bool {
    match (form) {
        case Some(_) => true
        case None => false
    }
}
