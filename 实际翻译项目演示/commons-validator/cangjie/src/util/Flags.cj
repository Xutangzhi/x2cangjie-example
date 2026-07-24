package validator.util

// Benchmark API skeleton generated from a reference Cangjie project.
// Implement declarations listed below using the Java source/tests as the semantic specification.
// This file intentionally omits implementation bodies.

// public class Flags {
//   constructors:
//     public init()
//     public init(flags: Int64)
//
//   methods:
//     public func clear(): Unit
//     public func clone(): Flags
//     public func getFlags(): Int64
//     public func hashCode(): Int64
//     public func equals(other: Any): Bool
//     public func isOff(flag: Int64): Bool
//     public func isOn(flag: Int64): Bool
//     public func toString(): String
//     public func turnOff(flag: Int64): Unit
//     public func turnOffAll(): Unit
//     public func turnOn(flag: Int64): Unit
//     public func turnOnAll(): Unit
// }

public class Flags {
    private var flags: Int64 = 0

    public init() {}

    public init(flags: Int64) {
        this.flags = flags
    }

    public func clear(): Unit {
        flags = 0
    }

    public func clone(): Flags {
        Flags(flags)
    }

    public func getFlags(): Int64 {
        flags
    }

    public func hashCode(): Int64 {
        flags
    }

    public func equals(other: Any): Bool {
        match (other) {
            case value: Flags => flags == value.flags
            case _ => false
        }
    }

    public func isOff(flag: Int64): Bool {
        (flags & flag) == 0
    }

    public func isOn(flag: Int64): Bool {
        (flags & flag) == flag
    }

    public func toString(): String {
        var bit: Int64 = 63
        var out = ""
        while (bit >= 0) {
            let mask = Int64(1) << bit
            out += if ((flags & mask) != 0) { "1" } else { "0" }
            if (bit == 0) {
                break
            }
            bit--
        }
        out
    }

    public func turnOff(flag: Int64): Unit {
        flags &= (flag ^ Int64(-1))
    }

    public func turnOffAll(): Unit {
        flags = 0
    }

    public func turnOn(flag: Int64): Unit {
        flags |= flag
    }

    public func turnOnAll(): Unit {
        flags = -1
    }
}
