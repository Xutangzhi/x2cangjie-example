package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public open class ValidatorException <: Exception {
//   constructors:
//     public init()
//     public init(message: String)
//
//   methods:
//     public open override func getClassName(): String
// }

public open class ValidatorException <: Exception {
    public init() {
        super()
    }

    public init(message: String) {
        super(message)
    }

    public open override func getClassName(): String {
        "ValidatorException"
    }
}
