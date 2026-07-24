package commons_validator_test

import std.collection.*
import std.fs.*

import validator.routines.*

func ibanTestEnsure(condition: Bool, message: String): Unit {
    if (!condition) {
        throw Exception(message)
    }
}

func ibanTestExpectIllegalArgumentMessage(action: () -> Unit): String {
    try {
        action()
        throw Exception("Expected IllegalArgumentException")
    } catch (e: IllegalArgumentException) {
        e.message
    }
}

func ibanTestExpectIllegalStateMessage(action: () -> Unit): String {
    try {
        action()
        throw Exception("Expected IllegalStateException")
    } catch (e: IllegalStateException) {
        e.message
    }
}

func ibanTestStripQuotes(value: String): String {
    let trimmed = value.trimAscii()
    if (trimmed.size >= 2 && trimmed.startsWith("\"") && trimmed.endsWith("\"")) {
        return trimmed[1..trimmed.size - 1]
    }
    trimmed
}

func ibanTestStripCr(value: String): String {
    if (value.endsWith("\r")) {
        return value[0..value.size - 1]
    }
    value
}

func ibanTestReadTsvRows(): Array<Array<String>> {
    let path = "tests/iban_registry_v99_utf8.txt"
    let raw = String.fromUtf8(File.readFrom(path))
    var rows = ArrayList<Array<String>>()
    for (line in raw.split("\n", -1)) {
        let normalized = ibanTestStripCr(line)
        if (!normalized.isEmpty()) {
            rows.add(normalized.split("\t", -1))
        }
    }
    rows.toArray()
}

func ibanTestFindRow(rows: Array<Array<String>>, label: String): Array<String> {
    for (row in rows) {
        if (!row.isEmpty() && row[0] == label) {
            return row
        }
    }
    throw Exception("Missing row ${label}")
}

func ibanTestParseInt(text: String): Int64 {
    var value: Int64 = 0
    for (character in text.trimAscii().toRuneArray()) {
        if (!character.isAsciiNumber()) {
            throw Exception("Invalid integer ${text}")
        }
        value = value * 10 + character.position() - r'0'.position()
    }
    value
}

func ibanTestAdditionalCodes(field: String): Array<String> {
    let cleaned = ibanTestStripQuotes(field).replace("(French part)", "")
    if (cleaned == "N/A" || cleaned.isEmpty()) {
        return []
    }
    var result = ArrayList<String>()
    for (item in cleaned.split(",", -1)) {
        let code = item.trimAscii()
        if (!code.isEmpty()) {
            result.add(code)
        }
    }
    result.toArray()
}

func ibanTestSegmentRegex(kind: Rune, length: Int64): String {
    match (kind) {
        case r'n' => "\\d{${length}}"
        case r'a' => "[A-Z]{${length}}"
        case r'c' => "[A-Z0-9]{${length}}"
        case _ => throw Exception("Unexpected IBAN pattern kind ${kind}")
    }
}

func ibanTestFormatToRegex(ibanPattern: String, expectedLength: Int64): String {
    let chars = ibanPattern.toRuneArray()
    var index: Int64 = 0
    var total: Int64 = 0
    var currentKind = r'?'
    var currentLength: Int64 = 0
    var result = ""

    while (index < chars.size) {
        ibanTestEnsure(chars[index].isAsciiNumber(), "Expected digit at ${index} in ${ibanPattern}")
        var partLength: Int64 = 0
        while (index < chars.size && chars[index].isAsciiNumber()) {
            partLength = partLength * 10 + chars[index].position() - r'0'.position()
            index++
        }
        total += partLength
        ibanTestEnsure(index < chars.size && chars[index] == r'!', "Expected ! in ${ibanPattern}")
        index++
        ibanTestEnsure(index < chars.size, "Missing kind in ${ibanPattern}")
        let kind = chars[index]
        index++
        if (currentLength == 0) {
            currentKind = kind
            currentLength = partLength
        } else if (currentKind == kind) {
            currentLength += partLength
        } else {
            result += ibanTestSegmentRegex(currentKind, currentLength)
            currentKind = kind
            currentLength = partLength
        }
    }
    if (currentLength > 0) {
        result += ibanTestSegmentRegex(currentKind, currentLength)
    }
    ibanTestEnsure(total == expectedLength, "Wrong pattern length for ${ibanPattern}: expected=${expectedLength} actual=${total}")
    result
}

func ibanTestArrayContains(values: Array<String>, target: String): Bool {
    for (value in values) {
        if (value == target) {
            return true
        }
    }
    false
}

func ibanTestOptionIsNone(value: ?Validator): Bool {
    match (value) {
        case Some(_) => false
        case None => true
    }
}

func ibanTestOptionIsSome(value: ?Validator): Bool {
    match (value) {
        case Some(_) => true
        case None => false
    }
}

let VALID_IBAN_FIXTURES = [
    "AD1200012030200359100100",
    "AE070331234567890123456",
    "AL47212110090000000235698741",
    "AT611904300234573201",
    "AZ21NABZ00000000137010001944",
    "BA391290079401028494",
    "BE68539007547034",
    "BG80BNBG96611020345678",
    "BH67BMAG00001299123456",
    "BI4210000100010000332045181",
    "BR1800000000141455123924100C2",
    "BR1800360305000010009795493C1",
    "BR9700360305000010009795493P1",
    "BY13NBRB3600900000002Z00AB00",
    "CH9300762011623852957",
    "CR05015202001026284066",
    "CY17002001280000001200527600",
    "CZ6508000000192000145399",
    "CZ9455000000001011038930",
    "DE89370400440532013000",
    "DJ2110002010010409943020008",
    "DK5000400440116243",
    "DO28BAGR00000001212453611324",
    "EE382200221020145685",
    "EG380019000500000000263180002",
    "ES9121000418450200051332",
    "FI2112345600000785",
    "FI5542345670000081",
    "AX2112345600000785",
    "AX5542345670000081",
    "FK88SC123456789012",
    "FO6264600001631634",
    "FR1420041010050500013M02606",
    "BL6820041010050500013M02606",
    "GF4120041010050500013M02606",
    "GP1120041010050500013M02606",
    "MF8420041010050500013M02606",
    "MQ5120041010050500013M02606",
    "NC8420041010050500013M02606",
    "PF5720041010050500013M02606",
    "PM3620041010050500013M02606",
    "RE4220041010050500013M02606",
    "TF2120041010050500013M02606",
    "WF9120041010050500013M02606",
    "YT3120041010050500013M02606",
    "GB29NWBK60161331926819",
    "GE29NB0000000101904917",
    "GI75NWBK000000007099453",
    "GL8964710001000206",
    "GR1601101250000000012300695",
    "GT82TRAJ01020000001210029690",
    "HN88CABF00000000000250005469",
    "HR1210010051863000160",
    "HU42117730161111101800000000",
    "IE29AIBK93115212345678",
    "IL620108000000099999999",
    "IQ98NBIQ850123456789012",
    "IS140159260076545510730339",
    "IT60X0542811101000000123456",
    "JO94CBJO0010000000000131000302",
    "KW81CBKU0000000000001234560101",
    "KZ86125KZT5004100100",
    "LB62099900000001001901229114",
    "LC55HEMM000100010012001200023015",
    "LI21088100002324013AA",
    "LT121000011101001000",
    "LU280019400644750000",
    "LY83002048000020100120361",
    "LV80BANK0000435195001",
    "MC5811222000010123456789030",
    "MD24AG000225100013104168",
    "ME25505000012345678951",
    "MK07250120000058984",
    "MN121234123456789123",
    "MR1300020001010000123456753",
    "MT84MALT011000012345MTLCAST001S",
    "MU17BOMM0101101030300200000MUR",
    "NI45BAPR00000013000003558124",
    "NL91ABNA0417164300",
    "NO9386011117947",
    "OM810180000001299123456",
    "PK36SCBL0000001123456702",
    "PL61109010140000071219812874",
    "PS92PALS000000000400123456702",
    "PT50000201231234567890154",
    "QA58DOHB00001234567890ABCDEFG",
    "RO49AAAA1B31007593840000",
    "RS35260005601001611379",
    "RU0204452560040702810412345678901",
    "SA0380000000608010167519",
    "SC18SSCB11010000000000001497USD",
    "SD8811123456789012",
    "SE4550000000058398257466",
    "SI56191000000123438",
    "SI56263300012039086",
    "SK3112000000198742637541",
    "SM86U0322509800000000270100",
    "SO211000001001000100141",
    "ST68000100010051845310112",
    "SV62CENR00000000000000700025",
    "SV43ACAT00000000000000123123",
    "TL380080012345678910157",
    "TN5910006035183598478831",
    "TR330006100519786457841326",
    "UA213223130000026007233566001",
    "UA213996220000026007233566001",
    "VA59001123000012345678",
    "VG96VPVG0000012345678901",
    "XK051212012345678906",
    "YE15CBYE0001018861234567891234"
]

let INVALID_IBAN_FIXTURES = [
    "",
    "   ",
    "A",
    "AB",
    "FR1420041010050500013m02606",
    "MT84MALT011000012345mtlcast001s",
    "LI21088100002324013aa",
    "QA58DOHB00001234567890abcdefg",
    "RO49AAAA1b31007593840000",
    "LC62HEMM000100010012001200023015",
    "BY00NBRB3600000000000Z00AB00",
    "ST68000200010192194210112",
    "SV62CENR0000000000000700025",
    "NI04BAPR00000013000003558124",
    "RU1704452522540817810538091310419"
]
