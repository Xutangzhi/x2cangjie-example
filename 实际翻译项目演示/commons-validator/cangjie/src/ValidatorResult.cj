package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class ResultStatus {
//   constructors:
//     public init(valid: Bool, result: ?Any)
//     public init(ignored: ValidatorResult, valid: Bool, result: ?Any)
//
//   methods:
//     public func getResult(): ?Any
//     public func isValid(): Bool
//     public func setResult(result: ?Any): Unit
//     public func setValid(valid: Bool): Unit
// }

// public class ValidatorResult {
//   constructors:
//     public init(field: Field)
//
//   methods:
//     public func add(validatorName: String, result: Bool): Unit
//     public func add(validatorName: String, result: Bool, value: ?Any): Unit
//     public func containsAction(validatorName: String): Bool
//     public func getActionMap(): HashMap<String, ResultStatus>
//     public func getActions(): Array<String>
//     public func getField(): Field
//     public func getResult(validatorName: String): ?Any
//     public func isValid(validatorName: String): Bool
// }

import std.collection.*

public class ResultStatus {
    private var valid: Bool
    private var result: ?Any

    public init(valid: Bool, result: ?Any) {
        this.valid = valid
        this.result = result
    }

    public init(ignored: ValidatorResult, valid: Bool, result: ?Any) {
        this.valid = valid
        this.result = result
    }

    public func getResult(): ?Any {
        result
    }

    public func isValid(): Bool {
        valid
    }

    public func setResult(result: ?Any): Unit {
        this.result = result
    }

    public func setValid(valid: Bool): Unit {
        this.valid = valid
    }
}

public class ValidatorResult {
    private let actionMap = HashMap<String, ResultStatus>()
    private let fieldValue: Field

    public init(field: Field) {
        fieldValue = field
    }

    public func add(validatorName: String, result: Bool): Unit {
        add(validatorName, result, None<Any>)
    }

    public func add(validatorName: String, result: Bool, value: ?Any): Unit {
        actionMap[validatorName] = ResultStatus(result, value)
    }

    public func containsAction(validatorName: String): Bool {
        match (actionMap.get(validatorName)) {
            case Some(_) => true
            case None => false
        }
    }

    public func getActionMap(): HashMap<String, ResultStatus> {
        let result = HashMap<String, ResultStatus>()
        for (key in actionMap.keys()) {
            match (actionMap.get(key)) {
                case Some(value) => result[key] = value
                case None => ()
            }
        }
        result
    }

    public func getActions(): Array<String> {
        var out = ArrayList<String>()
        for (key in actionMap.keys()) {
            out.add(key)
        }
        out.toArray()
    }

    public func getField(): Field {
        fieldValue
    }

    public func getResult(validatorName: String): ?Any {
        match (actionMap.get(validatorName)) {
            case Some(status) => status.getResult()
            case None => None<Any>
        }
    }

    public func isValid(validatorName: String): Bool {
        match (actionMap.get(validatorName)) {
            case Some(status) => status.isValid()
            case None => false
        }
    }
}
