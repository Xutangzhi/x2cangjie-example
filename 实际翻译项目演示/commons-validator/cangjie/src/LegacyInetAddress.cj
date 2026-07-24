package validator

import std.collection.*
import std.regex.*

private let LEGACY_INET_MAX_BYTE: Int64 = 128
private let LEGACY_IPV4_MAX_OCTET_VALUE: Int64 = 255
private let LEGACY_MAX_UNSIGNED_SHORT: Int64 = 0xffff
private let LEGACY_BASE_16: Int64 = 16
private let LEGACY_IPV6_MAX_HEX_GROUPS: Int64 = 8
private let LEGACY_IPV6_MAX_HEX_DIGITS_PER_GROUP: Int64 = 4
private let LEGACY_DIGITS_PATTERN = Regex("^\\d{1,3}$")
private let LEGACY_ID_CHECK_PATTERN = Regex("^[^\\s/%]+$")
private let LEGACY_IPV4_PATTERN = Regex("^(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})$")

private func legacyInetIsBlank(text: String): Bool {
    text.trimAscii().isEmpty()
}

private func legacyInetCountToken(token: String, target: String): Int64 {
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

private func legacyInetParseDecimal(text: String): Int64 {
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

private func legacyInetParseHex(text: String): Int64 {
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
        value = value * LEGACY_BASE_16 + digit
    }
    value
}

private func legacyInetCollapseCompressedOctets(octets: Array<String>): Array<String> {
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

func legacyIsValidInet4Address(inet4Address: ?String): Bool {
    match (inet4Address) {
        case Some(input) =>
            match (LEGACY_IPV4_PATTERN.find(input, group: true)) {
                case Some(md) =>
                    for (group in 1..5) {
                        let ipSegment = md.matchString(group)
                        if (legacyInetIsBlank(ipSegment)) {
                            return false
                        }
                        try {
                            let parsed = legacyInetParseDecimal(ipSegment)
                            if (parsed > LEGACY_IPV4_MAX_OCTET_VALUE || (ipSegment.size > 1 && ipSegment.startsWith("0"))) {
                                return false
                            }
                        } catch (e: Exception) {
                            return false
                        }
                    }
                    true
                case None =>
                    false
            }
        case None =>
            false
    }
}

func legacyIsValidInet6Address(inet6Address: ?String): Bool {
    if (let Some(input) <- inet6Address) {
        var parts = input.split("/", -1)
        if (parts.isEmpty()) {
            return false
        }
        if (parts.size > 2) {
            return false
        }
        if (parts.size == 2) {
            if (!LEGACY_DIGITS_PATTERN.matches(parts[1])) {
                return false
            }
            try {
                let bits = legacyInetParseDecimal(parts[1])
                if (bits < 0 || bits > LEGACY_INET_MAX_BYTE) {
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
        if (parts.size == 2 && !LEGACY_ID_CHECK_PATTERN.matches(parts[1])) {
            return false
        }

        let address = parts[0]
        let containsCompressedZeroes = address.contains("::")
        if (containsCompressedZeroes && legacyInetCountToken("::", address) > 1) {
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
            octets = legacyInetCollapseCompressedOctets(octets)
        }
        if (octets.size > LEGACY_IPV6_MAX_HEX_GROUPS) {
            return false
        }

        var validOctets = 0
        var emptyOctets = 0
        for (index in 0..octets.size) {
            let octet = octets[index]
            if (legacyInetIsBlank(octet)) {
                emptyOctets++
                if (emptyOctets > 1) {
                    return false
                }
            } else {
                emptyOctets = 0
                if (index == octets.size - 1 && octet.contains(".")) {
                    if (!legacyIsValidInet4Address(Some(octet))) {
                        return false
                    }
                    validOctets += 2
                    continue
                }
                if (octet.size > LEGACY_IPV6_MAX_HEX_DIGITS_PER_GROUP) {
                    return false
                }
                try {
                    let octetInt = legacyInetParseHex(octet)
                    if (octetInt < 0 || octetInt > LEGACY_MAX_UNSIGNED_SHORT) {
                        return false
                    }
                } catch (e: Exception) {
                    return false
                }
            }
            validOctets++
        }
        if (validOctets > LEGACY_IPV6_MAX_HEX_GROUPS || (validOctets < LEGACY_IPV6_MAX_HEX_GROUPS && !containsCompressedZeroes)) {
            return false
        }
        return true
    }
    false
}

func legacyIsValidInetAddress(inetAddress: ?String): Bool {
    legacyIsValidInet4Address(inetAddress) || legacyIsValidInet6Address(inetAddress)
}
