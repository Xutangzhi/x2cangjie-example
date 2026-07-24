package validator

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class ISBNValidator {
//   constructors:
//     public init()
//
//   methods:
//     public func isValid(isbn: ?String): Bool
// }

import validator.routines.*
import validator.routines.checkdigit.*

private let LEGACY_ISBN10_REGEX =
    "^(?:(\\d{9}[0-9X])|(?:(\\d{1,5})(?:\\-|\\s)(\\d{1,7})(?:\\-|\\s)(\\d{1,6})(?:\\-|\\s)([0-9X])))$"

public class ISBNValidator {
    private let isbn10Validator = CodeValidator(LEGACY_ISBN10_REGEX, 10, Some(ISBN10CheckDigit.ISBN10_CHECK_DIGIT))

    public init() {}

    public func isValid(isbn: ?String): Bool {
        isbn10Validator.isValid(isbn)
    }
}
