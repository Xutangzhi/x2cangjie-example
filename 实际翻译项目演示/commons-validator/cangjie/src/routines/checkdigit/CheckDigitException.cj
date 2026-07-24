package validator.routines.checkdigit

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public open class CheckDigitException <: Exception {
//   constructors:
//     public init()
//     public init(message: String)
//     public init(message: String, cause: Exception)
//
//   methods:
//     public open override func getClassName(): String
// }

public open class CheckDigitException <: Exception {
    private let causeValue: Exception

    public init() {
        super()
        causeValue = Exception()
    }

    public init(message: String) {
        super(message)
        causeValue = Exception()
    }

    public init(message: String, cause: Exception) {
        super(message)
        causeValue = cause
    }

    public func getCause(): Exception {
        causeValue
    }

    public open override func getClassName(): String {
        "CheckDigitException"
    }
}
