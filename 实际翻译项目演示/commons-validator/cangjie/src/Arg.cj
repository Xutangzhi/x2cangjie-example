package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class Arg <: ToString & ValidatorCloneableValue {
//   constructors:
//     public init()
//
//   methods:
//     public func clone(): Arg
//     public func validatorUtilsClone(): Any
//     public func getBundle(): ?String
//     public func getKey(): ?String
//     public func getName(): ?String
//     public func getPosition(): Int64
//     public func isResource(): Bool
//     public func setBundle(bundle: String): Unit
//     public func setKey(key: String): Unit
//     public func setName(name: String): Unit
//     public func setPosition(position: Int64): Unit
//     public func setResource(resource: Bool): Unit
//     public func toString(): String
// }
public class Arg <: ToString & ValidatorCloneableValue {
    private var bundle: ?String = None<String>
    private var key: ?String = None<String>
    private var name: ?String = None<String>
    private var position: Int64 = -1
    private var resource = true

    public init() {}

    public func clone(): Arg {
        let copy = Arg()
        match (bundle) {
            case Some(value) => copy.setBundle(value)
            case None => ()
        }
        match (key) {
            case Some(value) => copy.setKey(value)
            case None => ()
        }
        match (name) {
            case Some(value) => copy.setName(value)
            case None => ()
        }
        copy.setPosition(position)
        copy.setResource(resource)
        copy
    }

    public func validatorUtilsClone(): Any {
        clone()
    }

    public func getBundle(): ?String {
        bundle
    }

    public func getKey(): ?String {
        key
    }

    public func getName(): ?String {
        name
    }

    public func getPosition(): Int64 {
        position
    }

    public func isResource(): Bool {
        resource
    }

    public func setBundle(bundle: String): Unit {
        this.bundle = Some(bundle)
    }

    public func setKey(key: String): Unit {
        this.key = Some(key)
    }

    public func setName(name: String): Unit {
        this.name = Some(name)
    }

    public func setPosition(position: Int64): Unit {
        this.position = position
    }

    public func setResource(resource: Bool): Unit {
        this.resource = resource
    }

    public func toString(): String {
        "Arg: name=${name}  key=${key}  position=${position}  bundle=${bundle}  resource=${resource}\n"
    }
}
