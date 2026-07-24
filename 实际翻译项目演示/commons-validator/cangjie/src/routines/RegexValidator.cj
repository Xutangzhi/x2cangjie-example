package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class RegexValidator {
//   constructors:
//     public init(regex: ?String)
//     public init(regex1: String, regex2: String)
//     public init(regex: ?String, caseSensitive: Bool)
//     public init(regexs: ?Array<String>)
//     public init(regexs: ?Array<String>, caseSensitive: Bool)
//     public init(nullableRegexs: Array<?String>)
//     public init(nullableRegexs: Array<?String>, caseSensitive: Bool)
//
//   operator methods:
//     public operator func ==(right: RegexValidator): Bool
//     public operator func !=(right: RegexValidator): Bool
//
//   methods:
//     public func getPatterns(): Array<Regex>
//     public func getRegexStrings(): Array<String>
//     public func isValid(value: ?String): Bool
//     public func validate(value: ?String): ?String
//     public func toString(): String
// }

// public open class PatternSyntaxException <: Exception {
//   constructors:
//     public init(message: String)
//
//   methods:
//     public override func toString(): String
// }

import std.collection.*
import std.regex.*

private func regexValidatorNormalize(regexs: Array<?String>): Array<String> {
    if (regexs.isEmpty()) {
        throw IllegalArgumentException("Regular expressions are missing")
    }
    var out = ArrayList<String>()
    for (i in 0..regexs.size) {
        match (regexs[i]) {
            case Some(regex) =>
                if (regex.isEmpty()) {
                    throw IllegalArgumentException("Regular expression[${i}] is missing")
                }
                out.add(regex)
            case None =>
                throw IllegalArgumentException("Regular expression[${i}] is missing")
        }
    }
    out.toArray()
}

private func regexValidatorCompileFlags(caseSensitive: Bool): Array<RegexFlag> {
    if (caseSensitive) {
        return []
    }
    [RegexFlag.IgnoreCase]
}

private func regexValidatorCompileAll(regexs: Array<String>, caseSensitive: Bool): Array<Regex> {
    let flags = regexValidatorCompileFlags(caseSensitive)
    var out = ArrayList<Regex>()
    for (regex in regexs) {
        try {
            out.add(Regex(regex, flags))
        } catch (e: Exception) {
            throw PatternSyntaxException(e.message)
        }
    }
    out.toArray()
}

private func regexValidatorRequireArray(regexs: ?Array<String>): Array<String> {
    match (regexs) {
        case Some(values) => values.clone()
        case None => throw IllegalArgumentException("Regular expressions are missing")
    }
}

private func regexValidatorMatchGroups(pattern: Regex, value: String): ?Array<String> {
    if (!pattern.matches(value)) {
        return None<Array<String>>
    }
    match (pattern.find(value, group: true)) {
        case Some(md) =>
            let count = md.groupCount()
            var groups = ArrayList<String>()
            for (group in 1..count + 1) {
                groups.add(md.matchString(group))
            }
            Some(groups.toArray())
        case None =>
            None<Array<String>>
    }
}

public open class PatternSyntaxException <: Exception {
    public init(message: String) {
        super(message)
    }

    public override func toString(): String {
        if (message.isEmpty()) {
            return "PatternSyntaxException"
        }
        "PatternSyntaxException: ${message}"
    }
}

public class RegexValidator {
    private let patterns: Array<Regex>
    private let regexStrings: Array<String>

    private init(normalizedRegexs: Array<String>, caseSensitive: Bool, _internal: Int64) {
        regexStrings = normalizedRegexs.clone()
        patterns = regexValidatorCompileAll(regexStrings, caseSensitive)
    }

    public init(regex: ?String) {
        this(regexValidatorNormalize([regex]), true, 0)
    }

    public init(regex1: String, regex2: String) {
        this(regexValidatorNormalize([Some(regex1), Some(regex2)]), true, 0)
    }

    public init(regex: ?String, caseSensitive: Bool) {
        this(regexValidatorNormalize([regex]), caseSensitive, 0)
    }

    public init(regexs: ?Array<String>) {
        this(regexValidatorRequireArray(regexs), true, 0)
    }

    public init(regexs: ?Array<String>, caseSensitive: Bool) {
        this(regexValidatorRequireArray(regexs), caseSensitive, 0)
    }

    public init(nullableRegexs: Array<?String>) {
        this(regexValidatorNormalize(nullableRegexs), true, 0)
    }

    public init(nullableRegexs: Array<?String>, caseSensitive: Bool) {
        this(regexValidatorNormalize(nullableRegexs), caseSensitive, 0)
    }

    public operator func ==(right: RegexValidator): Bool {
        regexStrings == right.regexStrings
    }

    public operator func !=(right: RegexValidator): Bool {
        !(this == right)
    }

    public func getPatterns(): Array<Regex> {
        patterns.clone()
    }

    public func getRegexStrings(): Array<String> {
        regexStrings.clone()
    }

    public func isValid(value: ?String): Bool {
        match (value) {
            case Some(text) =>
                for (pattern in patterns) {
                    if (pattern.matches(text)) {
                        return true
                    }
                }
                false
            case None =>
                false
        }
    }

    public func `match`(value: ?String): ?Array<String> {
        match (value) {
            case Some(text) =>
                for (pattern in patterns) {
                    if (let Some(groups) <- regexValidatorMatchGroups(pattern, text)) {
                        return Some(groups)
                    }
                }
                None<Array<String>>
            case None =>
                None<Array<String>>
        }
    }

    public func validate(value: ?String): ?String {
        if (let Some(groups) <- this.`match`(value)) {
            if (groups.size == 1) {
                return Some(groups[0])
            }
            var buffer = ""
            for (group in groups) {
                buffer += group
            }
            return Some(buffer)
        }
        None<String>
    }

    public func toString(): String {
        var buffer = "RegexValidator{"
        for (i in 0..regexStrings.size) {
            if (i > 0) {
                buffer += ","
            }
            buffer += regexStrings[i]
        }
        buffer + "}"
    }
}
