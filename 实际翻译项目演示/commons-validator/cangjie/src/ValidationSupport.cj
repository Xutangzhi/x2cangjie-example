package validator

import std.collection.*

private func validatorSupportArrayString(values: Array<Any>): String {
    var out = "["
    for (i in 0..values.size) {
        if (i > 0) {
            out += ", "
        }
        out += validatorSupportAnyString(values[i])
    }
    out + "]"
}

private func validatorSupportAnyString(value: Any): String {
    match (value) {
        case text: String => text
        case values: Array<Any> => validatorSupportArrayString(values)
        case values: Array<String> =>
            var copied = ArrayList<Any>()
            for (entry in values) {
                copied.add(entry)
            }
            validatorSupportArrayString(copied.toArray())
        case values: ArrayList<Any> => validatorSupportArrayString(values.toArray())
        case values: ArrayList<String> =>
            var copied = ArrayList<Any>()
            for (entry in values) {
                copied.add(entry)
            }
            validatorSupportArrayString(copied.toArray())
        case stringable: ToString => stringable.toString()
        case _ => ""
    }
}

private func validatorSupportCloneValue(value: Any): Any {
    match (value) {
        case cloneable: ValidatorCloneableValue => cloneable.validatorUtilsClone()
        case _ => value
    }
}

private func validatorSupportParseInt64(text: String): Int64 {
    let trimmed = text.trimAscii()
    if (trimmed.isEmpty()) {
        return 0
    }
    var negative = false
    var index: Int64 = 0
    let chars = trimmed.toRuneArray()
    if (chars[0] == r'-') {
        negative = true
        index = 1
    }
    var value: Int64 = 0
    while (index < chars.size) {
        value = value * 10 + chars[index].position() - r'0'.position()
        index++
    }
    if (negative) {
        return -value
    }
    value
}

private func validatorSupportResolveIndexedValue(current: Any, indexText: String): ?Any {
    let index = validatorSupportParseInt64(indexText)
    match (current) {
        case values: Array<Any> =>
            if (index < 0 || index >= values.size) {
                return None<Any>
            }
            Some(values[index])
        case values: Array<String> =>
            if (index < 0 || index >= values.size) {
                return None<Any>
            }
            Some(values[index])
        case values: ArrayList<Any> =>
            if (index < 0 || index >= values.size) {
                return None<Any>
            }
            Some(values[index])
        case values: ArrayList<String> =>
            if (index < 0 || index >= values.size) {
                return None<Any>
            }
            Some(values[index])
        case _ =>
            None<Any>
    }
}

private func validatorSupportResolveDirectProperty(bean: Any, property: String): ?Any {
    match (bean) {
        case access: ValidatorPropertyAccess =>
            match (access.getValidatorPropertyValue(property)) {
                case Some(value) => Some(value)
                case None => None<Any>
            }
        case map: HashMap<String, Any> =>
            map.get(property)
        case map: HashMap<String, String> =>
            match (map.get(property)) {
                case Some(value) => Some(value)
                case None => None<Any>
            }
        case _ =>
            None<Any>
    }
}

private func validatorSupportResolveRawProperty(bean: Any, property: String): ?Any {
    var current: ?Any = Some(bean)
    for (segment in property.split(".", -1)) {
        if (segment.isEmpty()) {
            return None<Any>
        }
        match (current) {
            case Some(value) =>
                if (segment.contains("[") && segment.endsWith("]")) {
                    let bracket = segment.indexOf("[")
                    match (bracket) {
                        case Some(position) =>
                            let head = segment[0..position]
                            let tail = segment[position + 1..segment.size - 1]
                            current = if (head.isEmpty()) {
                                validatorSupportResolveIndexedValue(value, tail)
                            } else {
                                match (validatorSupportResolveDirectProperty(value, head)) {
                                    case Some(indexedValue) => validatorSupportResolveIndexedValue(indexedValue, tail)
                                    case None => None<Any>
                                }
                            }
                        case None =>
                            current = validatorSupportResolveDirectProperty(value, segment)
                    }
                } else {
                    current = validatorSupportResolveDirectProperty(value, segment)
                }
            case None =>
                return None<Any>
        }
    }
    current
}

public interface ValidatorCloneableValue {
    func validatorUtilsClone(): Any
}

public interface ValidatorPropertyAccess {
    func getValidatorPropertyValue(property: String): ?String
}

public class FastHashMap<K, V> where K <: Hashable & Equatable<K>, V <: ToString {
    private let valuesMap = HashMap<K, V>()
    private var fast = false

    public init() {}

    public func add(key: K, value: V): Unit {
        valuesMap[key] = value
    }

    public func put(key: K, value: V): Unit {
        valuesMap[key] = value
    }

    public func get(key: K): ?V {
        valuesMap.get(key)
    }

    public func contains(key: K): Bool {
        containsKey(key)
    }

    public func containsKey(key: K): Bool {
        match (valuesMap.get(key)) {
            case Some(_) => true
            case None => false
        }
    }

    public func remove(key: K): Unit {
        valuesMap.remove(key)
    }

    public func clear(): Unit {
        valuesMap.clear()
    }

    public func isEmpty(): Bool {
        valuesMap.isEmpty()
    }

    public func keys(): Array<K> {
        var out = ArrayList<K>()
        for (key in valuesMap.keys()) {
            out.add(key)
        }
        out.toArray()
    }

    public func values(): Array<V> {
        var out = ArrayList<V>()
        for (value in valuesMap.values()) {
            out.add(value)
        }
        out.toArray()
    }

    public func putAll(other: FastHashMap<K, V>): Unit {
        for (key in other.keys()) {
            match (other.get(key)) {
                case Some(value) => valuesMap[key] = value
                case None => ()
            }
        }
    }

    public func setFast(fast: Bool): Unit {
        this.fast = fast
    }

    public func isFast(): Bool {
        fast
    }

    public func size(): Int64 {
        valuesMap.size
    }

    public operator func ==(right: FastHashMap<K, V>): Bool {
        if (fast != right.fast || size() != right.size()) {
            return false
        }
        for (key in keys()) {
            match (get(key)) {
                case Some(value) =>
                    match (right.get(key)) {
                        case Some(otherValue) =>
                            if (value.toString() != otherValue.toString()) {
                                return false
                            }
                        case None =>
                            return false
                    }
                case None =>
                    if (right.containsKey(key)) {
                        return false
                    }
            }
        }
        true
    }

    public func equals(other: Any): Bool {
        match (other) {
            case right: FastHashMap<K, V> => this == right
            case _ => false
        }
    }

    public func hashCode(): Int64 {
        var hash: Int64 = if (fast) { 1 } else { 0 }
        for (key in keys()) {
            hash = hash * 31 + key.hashCode()
            match (get(key)) {
                case Some(value) => hash = hash * 31 + value.toString().hashCode()
                case None => ()
            }
        }
        hash
    }
}

public class ValidatorUtils {
    public static func copyHashMap<K, V>(map: HashMap<K, V>): HashMap<K, V> where K <: Hashable & Equatable<K> {
        let result = HashMap<K, V>()
        for (key in map.keys()) {
            match (map.get(key)) {
                case Some(value) => result[key] = value
                case None => ()
            }
        }
        result
    }

    public static func copyFastHashMap<K, V>(fastHashMap: FastHashMap<K, V>): FastHashMap<K, V> where K <: Hashable & Equatable<K>, V <: ToString {
        let result = FastHashMap<K, V>()
        for (key in fastHashMap.keys()) {
            match (fastHashMap.get(key)) {
                case Some(value) =>
                    match (validatorSupportCloneValue(value)) {
                        case cloned: V => result.put(key, cloned)
                        case _ => result.put(key, value)
                    }
                case None => ()
            }
        }
        result.setFast(fastHashMap.isFast())
        result
    }

    public static func copyMap(map: HashMap<String, Any>): HashMap<String, Any> {
        let result = HashMap<String, Any>()
        for (key in map.keys()) {
            match (map.get(key)) {
                case Some(value) => result[key] = validatorSupportCloneValue(value)
                case None => ()
            }
        }
        result
    }

    public static func getValueAsString(bean: Any, property: String): ?String {
        match (validatorSupportResolveRawProperty(bean, property)) {
            case Some(value) =>
                match (value) {
                    case text: String => Some(text)
                    case values: Array<String> => Some(validatorSupportAnyString(values))
                    case values: Array<Any> => Some(validatorSupportAnyString(values))
                    case values: ArrayList<String> => Some(validatorSupportAnyString(values))
                    case values: ArrayList<Any> => Some(validatorSupportAnyString(values))
                    case _ => Some(validatorSupportAnyString(value))
                }
            case None =>
                None<String>
        }
    }

    public static func replace(value: String, key: String, replaceValue: String): String {
        value.replace(key, replaceValue)
    }

    public init() {}
}
