package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class ValidatorResults {
//   constructors:
//     public init()
//
//   methods:
//     public func add(field: Field, validatorName: String, result: Bool): Unit
//     public func add(field: Field, validatorName: String, result: Bool, value: ?Any): Unit
//     public func clear(): Unit
//     public func getPropertyNames(): HashSet<String>
//     public func getValidatorResult(key: String): ?ValidatorResult
//     public func getResultValueMap(): HashMap<String, Any>
//     public func isEmpty(): Bool
//     public func merge(other: ValidatorResults): Unit
// }

import std.collection.*

public class ValidatorResults {
    private let resultsMap = HashMap<String, ValidatorResult>()

    public init() {}

    public func add(field: Field, validatorName: String, result: Bool): Unit {
        add(field, validatorName, result, None<Any>)
    }

    public func add(field: Field, validatorName: String, result: Bool, value: ?Any): Unit {
        let key = field.getKey()
        var validatorResult: ValidatorResult
        match (resultsMap.get(key)) {
            case Some(existing) =>
                validatorResult = existing
            case None =>
                validatorResult = ValidatorResult(field)
                resultsMap[key] = validatorResult
        }
        validatorResult.add(validatorName, result, value)
    }

    public func clear(): Unit {
        resultsMap.clear()
    }

    public func getPropertyNames(): HashSet<String> {
        let set = HashSet<String>()
        for (key in resultsMap.keys()) {
            set.add(key)
        }
        set
    }

    public func getValidatorResult(key: String): ?ValidatorResult {
        resultsMap.get(key)
    }

    public func getResultValueMap(): HashMap<String, Any> {
        let result = HashMap<String, Any>()
        for (key in resultsMap.keys()) {
            match (resultsMap.get(key)) {
                case Some(validatorResult) =>
                    for (action in validatorResult.getActions()) {
                        match (validatorResult.getResult(action)) {
                            case Some(value) =>
                                match (value) {
                                    case _: Bool => ()
                                    case _ => result[key] = value
                                }
                            case None => ()
                        }
                    }
                case None => ()
            }
        }
        result
    }

    public func isEmpty(): Bool {
        resultsMap.isEmpty()
    }

    public func merge(other: ValidatorResults): Unit {
        for (key in other.resultsMap.keys()) {
            match (other.resultsMap.get(key)) {
                case Some(value) => resultsMap[key] = value
                case None => ()
            }
        }
    }
}
