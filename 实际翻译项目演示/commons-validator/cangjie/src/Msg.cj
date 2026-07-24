package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class Msg <: ToString & ValidatorCloneableValue {
//   constructors:
//     public init()
//
//   methods:
//     public func clone(): Msg
//     public func validatorUtilsClone(): Any
//     public func getBundle(): ?String
//     public func getKey(): String
//     public func getName(): ?String
//     public func isResource(): Bool
//     public func setBundle(bundle: String): Unit
//     public func setKey(key: String): Unit
//     public func setName(name: String): Unit
//     public func setResource(resource: Bool): Unit
//     public func toString(): String
// }
public class Msg <: ToString & ValidatorCloneableValue {
    private var bundle: ?String = None<String>
    private var key = ""
    private var name: ?String = None<String>
    private var resource = true

    public init() {}

    public func clone(): Msg {
        let copy = Msg()
        match (bundle) {
            case Some(value) => copy.setBundle(value)
            case None => ()
        }
        copy.setKey(key)
        match (name) {
            case Some(value) => copy.setName(value)
            case None => ()
        }
        copy.setResource(resource)
        copy
    }

    public func validatorUtilsClone(): Any {
        clone()
    }

    public func getBundle(): ?String {
        bundle
    }

    public func getKey(): String {
        key
    }

    public func getName(): ?String {
        name
    }

    public func isResource(): Bool {
        resource
    }

    public func setBundle(bundle: String): Unit {
        this.bundle = Some(bundle)
    }

    public func setKey(key: String): Unit {
        this.key = key
    }

    public func setName(name: String): Unit {
        this.name = Some(name)
    }

    public func setResource(resource: Bool): Unit {
        this.resource = resource
    }

    public func toString(): String {
        "Msg: name=${name}  key=${key}  resource=${resource}  bundle=${bundle}\n"
    }
}
