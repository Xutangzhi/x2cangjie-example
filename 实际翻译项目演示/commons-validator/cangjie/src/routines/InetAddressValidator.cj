package validator.routines

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class InetAddressValidator {
//   static functions:
//     public static func getInstance(): InetAddressValidator
//
//   constructors:
//     public init()
//
//   methods:
//     public func isValid(inetAddress: ?String): Bool
//     public func isValidInet4Address(inet4Address: ?String): Bool
//     public func isValidInet6Address(inet6Address: ?String): Bool
// }

import std.collection.*
import std.regex.*

private let INET_MAX_BYTE: Int64 = 128
private let IPV4_MAX_OCTET_VALUE: Int64 = 255
private let MAX_UNSIGNED_SHORT: Int64 = 0xffff
private let BASE_16: Int64 = 16
private let IPV6_MAX_HEX_GROUPS: Int64 = 8
private let IPV6_MAX_HEX_DIGITS_PER_GROUP: Int64 = 4

private func inetCountToken(token: String, target: String): Int64 {
    var tokenIndex = 0
    var count = 0
    while (true) {
        match (target.indexOf(token, tokenIndex)) {
            case Some(index) =>
                tokenIndex = index + 1
                count++
            case None =>
                return count
        }
    }
    count
}

private func inetIsBlankOrNull(value: ?String): Bool {
    match (value) {
        case Some(text) => text.trimAscii().isEmpty()
        case None => true
    }
}

private func inetIsBlank(text: String): Bool {
    text.trimAscii().isEmpty()
}

private func inetParseDecimal(text: String): Int64 {
    if (text.isEmpty()) {
        throw IllegalArgumentException("Empty decimal value")
    }
    var value: Int64 = 0
    for (character in text.toRuneArray()) {
        if (!character.isAsciiNumber()) {
            throw IllegalArgumentException("Non-decimal character")
        }
        value = value * 10 + character.position() - r'0'.position()
    }
    value
}

private func inetParseHex(text: String): Int64 {
    if (text.isEmpty()) {
        throw IllegalArgumentException("Empty hex value")
    }
    var value: Int64 = 0
    for (character in text.toRuneArray()) {
        let digit = if (character.isAsciiNumber()) {
            character.position() - r'0'.position()
        } else if (character >= r'a' && character <= r'f') {
            character.position() - r'a'.position() + 10
        } else if (character >= r'A' && character <= r'F') {
            character.position() - r'A'.position() + 10
        } else {
            throw IllegalArgumentException("Non-hex character")
        }
        value = value * BASE_16 + digit
    }
    value
}

private func inetCollapseCompressedOctets(octets: Array<String>): Array<String> {
    var collapsed = ArrayList<String>()
    var previousEmpty = false
    for (octet in octets) {
        if (octet.isEmpty()) {
            if (!previousEmpty) {
                collapsed.add(octet)
                previousEmpty = true
            }
        } else {
            previousEmpty = false
            collapsed.add(octet)
        }
    }
    collapsed.toArray()
}

public class InetAddressValidator {
    private static let VALIDATOR = InetAddressValidator()
    private static let DIGITS_REGEX = Regex("^\\d{1,3}$")
    private static let ID_CHECK_REGEX = Regex("^[^\\s/%]+$")
    private static let IPV4_VALIDATOR = RegexValidator("^(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})$")

    public static func getInstance(): InetAddressValidator {
        VALIDATOR
    }

    public init() {}

    public func isValid(inetAddress: ?String): Bool {
        isValidInet4Address(inetAddress) || isValidInet6Address(inetAddress)
    }

    public func isValidInet4Address(inet4Address: ?String): Bool {
        let groups = IPV4_VALIDATOR.`match`(inet4Address)
        if (let Some(parts) <- groups) {
            for (ipSegment in parts) {
                if (inetIsBlank(ipSegment)) {
                    return false
                }
                try {
                    let parsed = inetParseDecimal(ipSegment)
                    if (parsed > IPV4_MAX_OCTET_VALUE || (ipSegment.size > 1 && ipSegment.startsWith("0"))) {
                        return false
                    }
                } catch (e: Exception) {
                    return false
                }
            }
            return true
        }
        false
    }

    public func isValidInet6Address(inet6Address: ?String): Bool {
        if (let Some(input) <- inet6Address) {
            var parts = input.split("/", -1)
            if (parts.isEmpty()) {
                return false
            }
            if (parts.size > 2) {
                return false
            }
            if (parts.size == 2) {
                if (!DIGITS_REGEX.matches(parts[1])) {
                    return false
                }
                try {
                    let bits = inetParseDecimal(parts[1])
                    if (bits < 0 || bits > INET_MAX_BYTE) {
                        return false
                    }
                } catch (e: Exception) {
                    return false
                }
            }

            parts = parts[0].split("%", -1)
            if (parts.isEmpty()) {
                return false
            }
            if (parts.size > 2) {
                return false
            }
            if (parts.size == 2 && !ID_CHECK_REGEX.matches(parts[1])) {
                return false
            }

            let address = parts[0]
            if (address.isEmpty()) {
                return false
            }
            let containsCompressedZeroes = address.contains("::")
            if (containsCompressedZeroes && inetCountToken("::", address) > 1) {
                return false
            }
            let startsWithCompressed = address.startsWith("::")
            let endsWithCompressed = address.endsWith("::")
            let endsWithSep = address.endsWith(":")
            if ((address.startsWith(":") && !startsWithCompressed) || (endsWithSep && !endsWithCompressed)) {
                return false
            }

            var octets = address.split(":", -1)
            if (containsCompressedZeroes) {
                octets = inetCollapseCompressedOctets(octets)
            }
            if (octets.size > IPV6_MAX_HEX_GROUPS) {
                return false
            }

            var validOctets = 0
            var emptyOctets = 0
            for (index in 0..octets.size) {
                let octet = octets[index]
                if (inetIsBlank(octet)) {
                    emptyOctets++
                    if (emptyOctets > 1) {
                        return false
                    }
                } else {
                    emptyOctets = 0
                    if (index == octets.size - 1 && octet.contains(".")) {
                        if (!isValidInet4Address(Some(octet))) {
                            return false
                        }
                        validOctets += 2
                        continue
                    }
                    if (octet.size > IPV6_MAX_HEX_DIGITS_PER_GROUP) {
                        return false
                    }
                    try {
                        let octetInt = inetParseHex(octet)
                        if (octetInt < 0 || octetInt > MAX_UNSIGNED_SHORT) {
                            return false
                        }
                    } catch (e: Exception) {
                        return false
                    }
                }
                validOctets++
            }
            if (validOctets > IPV6_MAX_HEX_GROUPS || (validOctets < IPV6_MAX_HEX_GROUPS && !containsCompressedZeroes)) {
                return false
            }
            return true
        }
        false
    }
}
