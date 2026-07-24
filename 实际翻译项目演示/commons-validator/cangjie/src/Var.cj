package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class Var <: ToString & ValidatorCloneableValue {
//   static fields/constants:
//     public static let JSTYPE_INT = "int"
//     public static let JSTYPE_STRING = "string"
//     public static let JSTYPE_REGEXP = "regexp"
//
//   constructors:
//     public init()
//     public init(name: String, value: String, jsType: String)
//
//   methods:
//     public func clone(): Var
//     public func validatorUtilsClone(): Any
//     public func getBundle(): ?String
//     public func getJsType(): ?String
//     public func getName(): ?String
//     public func getValue(): ?String
//     public func isResource(): Bool
//     public func setBundle(bundle: String): Unit
//     public func setJsType(jsType: String): Unit
//     public func setName(name: String): Unit
//     public func setResource(resource: Bool): Unit
//     public func setValue(value: String): Unit
//     public func toString(): String
// }
public class Var <: ToString & ValidatorCloneableValue {
    public static let JSTYPE_INT = "int"
    public static let JSTYPE_STRING = "string"
    public static let JSTYPE_REGEXP = "regexp"

    private var name: ?String = None<String>
    private var value: ?String = None<String>
    private var jsType: ?String = None<String>
    private var resource = false
    private var bundle: ?String = None<String>

    public init() {}

    public init(name: String, value: String, jsType: String) {
        this.name = Some(name)
        this.value = Some(value)
        this.jsType = Some(jsType)
    }

    public func clone(): Var {
        let copy = Var()
        match (name) {
            case Some(v) => copy.setName(v)
            case None => ()
        }
        match (value) {
            case Some(v) => copy.setValue(v)
            case None => ()
        }
        match (jsType) {
            case Some(v) => copy.setJsType(v)
            case None => ()
        }
        copy.setResource(resource)
        match (bundle) {
            case Some(v) => copy.setBundle(v)
            case None => ()
        }
        copy
    }

    public func validatorUtilsClone(): Any {
        clone()
    }

    public func getBundle(): ?String {
        bundle
    }

    public func getJsType(): ?String {
        jsType
    }

    public func getName(): ?String {
        name
    }

    public func getValue(): ?String {
        value
    }

    public func isResource(): Bool {
        resource
    }

    public func setBundle(bundle: String): Unit {
        this.bundle = Some(bundle)
    }

    public func setJsType(jsType: String): Unit {
        this.jsType = Some(jsType)
    }

    public func setName(name: String): Unit {
        this.name = Some(name)
    }

    public func setResource(resource: Bool): Unit {
        this.resource = resource
    }

    public func setValue(value: String): Unit {
        this.value = Some(value)
    }

    public func toString(): String {
        var result = "Var: name=${name}  value=${value}  resource=${resource}"
        if (resource) {
            result += "  bundle=${bundle}"
        }
        result + "  jsType=${jsType}\n"
    }
}
