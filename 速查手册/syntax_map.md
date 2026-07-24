# Java -> 仓颉语法映射表

适用范围：Java 17 源码迁移到仓颉 `cjc 1.0.5` 后端。本文只写可由本地仓颉文档确认的语法映射；Java 语义与仓颉语法不等价时，明确要求 wrapper 或重写。

## 0. 先记住 15 条默认规则

1. Java `final` 局部变量/字段通常迁为 `let`；需要重新赋值的变量迁为 `var`。仓颉 `let` 只能赋值一次。
2. Java primitive 按宽度迁移：`boolean -> Bool`，`short -> Int16`，`int -> Int32`，`long -> Int64`，`float -> Float32`，`double -> Float64`。
3. Java `byte` 必须先判定语义：二进制 buffer 用 `Byte/UInt8`，有符号算术用 `Int8`。
4. Java `char` 是 UTF-16 code unit；仓颉 `Rune` 是字符语义，`String[]` 是 UTF-8 byte。涉及 `charAt/length/subSequence` 时必须 wrapper。
5. Java reference/null 不直译；可空值迁为 `Option<T>` 或 `?T`。
6. Java `T[]` 通常迁为 `Array<T>`；Java `List<T>` 迁为 `ArrayList<T>` 或接口 `List<T>`。
7. Java `class` 迁为仓颉 `class`；只有确认不依赖对象身份、继承和可变共享时，DTO 才考虑 `struct`。
8. Java `extends/implements` 都使用仓颉 `<:`；普通类要被继承必须 `open`，覆盖父类 open 方法用 `override`。
9. Java checked exception 在仓颉没有同等编译期检查；异常边界仍要显式保留。
10. Java `try-with-resources` 迁为仓颉 `try (r = Resource()) { ... }`，资源类型必须实现 `Resource`。
11. Java `switch` 迁为 `match`；Java fall-through `switch` 不要机械替换。
12. Java lambda/method reference 迁为仓颉 lambda `{ x: T => ... }`；重载目标类型不明确时显式标注参数类型。
13. Java Stream 不按语法翻译；改为 for 循环、集合函数或显式迭代器。
14. Java annotation/reflection/proxy/DI 不是语法问题，按框架迁移处理。
15. Java `synchronized/volatile/ThreadLocal/Executor` 需要并发设计，不做 token 级替换。

## 1. 包、导入、入口

### 1.1 package/import

Java:

```java
package com.example.user;

import java.util.List;
import java.util.*;
import static java.util.Collections.emptyList;
```

仓颉：

```cangjie
package com.example.user

import std.collection.List
import std.collection.*
import std.collection.{ArrayList, HashMap}
import std.collection as coll
```

规则：

- 仓颉 `core` 默认导入；其他包显式 `import`。
- 仓颉支持单项导入、通配导入、分组导入、别名导入。
- Java `static import` 不要机械翻；通常改为普通导入后直接调用函数/类型静态成员，或用本地 helper。

### 1.2 main

Java:

```java
public static void main(String[] args) {
    System.out.println(args.length);
}
```

仓颉：

```cangjie
main(args: Array<String>): Int64 {
    println(args.size)
    return 0
}
```

规则：

- 仓颉入口函数写 `main`，不写 `func`。
- 参数可省略，也可写 `Array<String>`。
- 返回类型可为整数类型或 `Unit`。

## 2. 变量、常量、类型

### 2.1 局部变量和 final

Java:

```java
final int id = 1;
String name = "alice";
name = name.trim();
```

仓颉：

```cangjie
let id: Int32 = 1
var name: String = "alice"
name = name.trimAscii()
```

规则：

- 仓颉变量必须用 `let`、`var` 或 `const`。
- 顶层变量和静态成员变量必须初始化。
- Java 非 `final` 但实际只赋值一次时，Agent 可以用 `let`，但不能改变可观察语义。
- `const` 只用于编译期常量；不要把所有 Java `static final` 都无脑改成 `const`。

### 2.2 基础类型

| Java | 仓颉 | 注意 |
|---|---|---|
| `boolean` | `Bool` | 条件表达式必须是 `Bool` |
| `byte` | `Int8` 或 `Byte` | `Byte = UInt8`，二进制优先 `Byte` |
| `short` | `Int16` |  |
| `int` | `Int32` | 仓颉整数字面量无上下文默认 `Int64` |
| `long` | `Int64` | Java `123L` -> 仓颉可用 `123i64` |
| `float` | `Float32` |  |
| `double` | `Float64` |  |
| `char` | `Rune` 或 wrapper | UTF-16 code unit 不等价 |
| `void` | `Unit` | 函数返回 `Unit` 可省略显式 `return` |

Java:

```java
int count = 10;
long total = 10L;
byte b = (byte) 255;
```

仓颉：

```cangjie
let count: Int32 = 10
let total: Int64 = 10i64
let b: Byte = 255u8
```

### 2.3 字符串、文本块、插值

Java:

```java
String message = "hello " + name;
String json = """
  {"name":"alice"}
  """;
```

仓颉：

```cangjie
let message = "hello ${name}"
let json = """
  {"name":"alice"}
  """
```

规则：

- Java `+` 拼接可以迁为仓颉 `+` 或插值 `${}`。
- Java `String.length()` 不等于仓颉 `String.size`。仓颉 `size` 是 UTF-8 字节长度。
- Java `charAt(i)` 不等于仓颉 `s[i]`。仓颉 `s[i]` 返回 UTF-8 byte。
- 字符级遍历优先 `toRuneArray()`；二进制协议优先 `toArray()`。

## 3. null、Optional、模式拆箱

Java:

```java
String nick = user.getNick();
if (nick != null) {
    return nick;
}
return "anonymous";
```

仓颉：

```cangjie
let nick: ?String = user.getNick()
match (nick) {
    case Some(v) => return v
    case None => return "anonymous"
}
```

也可使用 `let pattern`：

```cangjie
if (let Some(v) <- nick) {
    return v
}
return "anonymous"
```

规则：

- Java nullable 字段：`T field` -> `var field: ?T` 或业务 wrapper。
- Java `Optional<T>` -> `Option<T>`；`Optional.empty()` -> `None<T>`。
- Java `Objects.requireNonNull(x)` -> wrapper：`x.getOrThrow()` 或抛业务异常，不散落处理。
- Java `?.` 不存在；仓颉对 `Option` 支持 `?.`、`??` 等糖，但复杂链路建议显式 `match` 保持可读性。

## 4. 数组与集合

### 4.1 数组

Java:

```java
int[] nums = new int[] {1, 2, 3};
nums[0] = 10;
int n = nums.length;
```

仓颉：

```cangjie
var nums: Array<Int32> = [1, 2, 3]
nums[0] = 10
let n = nums.size
```

固定长度初始化：

```cangjie
let zeros = Array<Int64>(10, repeat: 0)
let squares = Array<Int64>(10, { i => i * i })
```

### 4.2 List/Map/Set

Java:

```java
List<String> names = new ArrayList<>();
names.add("alice");
String first = names.get(0);

Map<String, Integer> ages = new HashMap<>();
ages.put("alice", 18);
```

仓颉：

```cangjie
import std.collection.*

var names = ArrayList<String>()
names.add("alice")
let first = names.get(0).getOrThrow()

var ages = HashMap<String, Int64>()
let previous = ages.add("alice", 18)
```

规则：

- Java `list.size()` -> 仓颉 `list.size`。
- Java `map.get(k)` -> 仓颉 `map.get(k)` 返回 `Option<V>`。
- Java 集合允许 null 时，元素类型改成 `Option<T>` 或 wrapper。
- Java `Iterator.hasNext()/next()` 可迁为仓颉 `for (x in xs)`；若源码依赖 remove/并发修改异常，要 wrapper。

## 5. 函数、方法、lambda

### 5.1 函数定义

Java:

```java
int add(int a, int b) {
    return a + b;
}
```

仓颉：

```cangjie
func add(a: Int32, b: Int32): Int32 {
    return a + b
}
```

或使用函数体最后表达式：

```cangjie
func add(a: Int32, b: Int32): Int32 {
    a + b
}
```

### 5.2 命名参数和默认值

Java 常见 builder/overload：

```java
User create(String name, int age) { ... }
```

仓颉可用命名参数：

```cangjie
func create(name!: String, age!: Int64 = 0): User {
    User(name, age)
}

let u = create(name: "alice", age: 18)
```

规则：

- 仓颉命名参数写 `p!: T`，调用时写 `p: value`。
- 默认值只能给命名参数。
- Java overload 很多时，可合并为命名参数 + 默认值，但必须保持二进制/源码调用语义的迁移要求。

### 5.3 lambda 与方法引用

Java:

```java
Function<Integer, Integer> inc = x -> x + 1;
list.sort((a, b) -> a.age() - b.age());
```

仓颉：

```cangjie
let inc: (Int64) -> Int64 = { x => x + 1 }
let byAge = { a: User, b: User => a.age.compare(b.age) }
```

规则：

- 仓颉 lambda 形态：`{ p1: T1, p2: T2 => body }`。
- 无参数 lambda：`{ => body }`，除非作为尾随 lambda。
- Java method reference 如 `User::getName` 通常改为 `{ u: User => u.getName() }`。
- Java 函数式接口迁移为函数类型 `(A) -> B`，除非接口本身有身份、默认方法或多方法约束。

## 6. class、struct、interface、继承

### 6.1 class 与构造器

Java:

```java
public class User {
    private final long id;
    private String name;

    public User(long id, String name) {
        this.id = id;
        this.name = name;
    }

    public String name() {
        return name;
    }
}
```

仓颉：

```cangjie
public class User {
    private let id: Int64
    private var name: String

    public init(id: Int64, name: String) {
        this.id = id
        this.name = name
    }

    public func getName(): String {
        name
    }
}
```

规则：

- Java constructor -> 仓颉 `init`。
- Java `this.field = ...` -> 仓颉同样使用 `this.field`。
- Java getter/setter 可以保留方法，也可以迁为仓颉属性，但跨语言迁移初期优先保留方法形态，降低行为风险。

### 6.2 primary constructor

简单不可变数据类可写：

```cangjie
public class User {
    public User(let id: Int64, let name: String) {}
}
```

使用条件：

- 构造逻辑很简单。
- 不需要额外校验、转换、日志、副作用。
- 字段可见性符合源码 API。

### 6.3 interface

Java:

```java
interface Repository<T> {
    Optional<T> find(long id);
}

final class UserRepository implements Repository<User> {
    public Optional<User> find(long id) { ... }
}
```

仓颉：

```cangjie
interface Repository<T> {
    func find(id: Int64): Option<T>
}

class UserRepository <: Repository<User> {
    public func find(id: Int64): Option<User> {
        None<User>
    }
}
```

规则：

- Java `implements` -> 仓颉 `<:`。
- 仓颉接口默认 open；实现类型中接口方法通常写 `public func`。

### 6.4 继承、open、override、sealed

Java:

```java
class Base {
    String kind() { return "base"; }
}

class Child extends Base {
    @Override String kind() { return "child"; }
}
```

仓颉：

```cangjie
open class Base {
    public open func kind(): String {
        "base"
    }
}

class Child <: Base {
    public override func kind(): String {
        "child"
    }
}
```

规则：

- 非抽象仓颉类要被继承必须 `open`。
- 父类方法要被覆盖必须 `open`；子类覆盖写 `override`。
- 仓颉类只能继承一个 class，但可实现多个 interface：`class C <: Base & I1 & I2`。
- Java sealed class 可迁为仓颉 `sealed abstract class` 或 `sealed interface`，但包边界和可继承范围要重新确认。

### 6.5 abstract

Java:

```java
abstract class Shape {
    abstract double area();
}
```

仓颉：

```cangjie
abstract class Shape {
    public func area(): Float64
}
```

规则：

- 抽象类天然可被继承，`open` 可省略。
- 抽象成员函数没有函数体，必须 `public` 或 `protected`。

### 6.6 record/DTO

Java:

```java
public record UserDto(long id, String name) {}
```

仓颉候选：

```cangjie
public class UserDto {
    public UserDto(let id: Int64, let name: String) {}
}
```

规则：

- Java record 自动提供构造、component accessor、`equals/hashCode/toString`。
- 仓颉迁移时必须明确这些方法是否被依赖；不要只迁字段后丢掉值相等语义。
- 如项目已有 deriving/代码生成规范，可按项目规范生成等价方法；否则手写或 wrapper。

## 7. 泛型

Java:

```java
class Box<T extends Number> {
    private final T value;
}
```

仓颉：

```cangjie
class Box<T> where T <: NumberLike {
    let value: T

    public init(value: T) {
        this.value = value
    }
}
```

规则：

- Java `T extends X` -> 仓颉 `where T <: X`。
- 多约束使用 `&`：`where T <: I1 & I2`。
- Java wildcard 没有直接 1:1：
  - `List<? extends T>`：通常改为只读泛型接口或函数泛型约束。
  - `List<? super T>`：通常改为写入接口或重设 API。
  - raw type：必须消除，补真实类型或 `Object` wrapper。
- Java type erasure 相关反射逻辑不能按泛型语法迁移。

## 8. 控制流

### 8.1 if/else

Java:

```java
String label = score >= 60 ? "pass" : "fail";
```

仓颉：

```cangjie
let label = if (score >= 60) {
    "pass"
} else {
    "fail"
}
```

规则：

- 仓颉 `if` 条件必须是 `Bool`；不能用整数、字符串、对象做 truthy 判断。
- 带 `else` 的 `if` 可作为表达式；各分支类型需兼容。

### 8.2 for/while

Java:

```java
for (String name : names) {
    System.out.println(name);
}

for (int i = 0; i < names.size(); i++) {
    System.out.println(names.get(i));
}
```

仓颉：

```cangjie
for (name in names) {
    println(name)
}

for (i in 0..names.size) {
    println(names.get(i).getOrThrow())
}
```

规则：

- Java enhanced for -> 仓颉 `for (x in xs)`。
- Java index loop -> 仓颉 range loop；注意下标类型通常是 `Int64`。
- Java `while/do while` 可迁为仓颉 `while` / `do-while`，条件仍必须是 `Bool`。

### 8.3 switch -> match

Java switch expression:

```java
String label = switch (status) {
    case ACTIVE -> "active";
    case DISABLED -> "disabled";
};
```

仓颉：

```cangjie
let label = match (status) {
    case Active => "active"
    case Disabled => "disabled"
}
```

Java fall-through switch:

```java
switch (code) {
    case 1:
    case 2:
        handle();
        break;
    default:
        other();
}
```

仓颉：

```cangjie
match (code) {
    case 1 | 2 => handle()
    case _ => other()
}
```

规则：

- 仓颉 `match` 要穷尽；最后常用 `case _ => ...`。
- Java fall-through、副作用顺序、`break` 标签要重写。
- Java 17 preview 的 switch pattern 不纳入默认机械迁移。

## 9. enum 与 pattern

Java:

```java
enum Status {
    ACTIVE, DISABLED
}
```

仓颉：

```cangjie
enum Status {
    | Active
    | Disabled
}
```

带值枚举：

```cangjie
enum Result<T> {
    | Ok(T)
    | Err(String)
}
```

匹配：

```cangjie
let text = match (result) {
    case Ok(v) => "value=${v}"
    case Err(msg) => "error=${msg}"
}
```

规则：

- Java enum 的字段、构造器、方法可迁为仓颉 enum 成员函数或改成 class/struct。
- Java `Enum.name()/ordinal()` 若被依赖，必须显式实现或 wrapper；不要默认用仓颉显示文本替代。

## 10. 异常和资源

### 10.1 throw/try/catch/finally

Java:

```java
try {
    run();
} catch (IOException e) {
    throw new RuntimeException(e);
} finally {
    cleanup();
}
```

仓颉：

```cangjie
try {
    run()
} catch (e: IOException) {
    throw Exception(e.toString())
} finally {
    cleanup()
}
```

规则：

- 仓颉 `throw` 后必须是 `Exception` 子类型。
- Java checked exception 不会被仓颉编译器强制声明；迁移时通过 wrapper 保持接口契约。
- 多 catch 迁移为多个 `catch (e: Type)`，注意从具体到宽泛。

### 10.2 try-with-resources

Java:

```java
try (InputStream in = Files.newInputStream(path)) {
    return in.readAllBytes();
}
```

仓颉：

```cangjie
import std.fs.*
import std.io.*

try (file = File(path, Read)) {
    return readToEnd(file)
}
```

规则：

- 仓颉资源类型必须实现 `Resource`：`isClosed(): Bool`、`close(): Unit`。
- Java suppressed exception 语义若被测试覆盖，需要 wrapper。

## 11. 相等、哈希、字符串表示

| Java | 仓颉迁移 |
|---|---|
| `==` primitive | `==` |
| `==` reference identity | 保留 class identity 或显式 identity wrapper |
| `equals` | 实现/派生 `Equatable<T>` 或保留业务方法 |
| `hashCode` | 实现 `Hashable`，尤其是作为 `HashMap` key 时 |
| `toString` | 实现 `ToString.toString()` |
| `Objects.equals(a,b)` | `Option` 安全比较 helper |

规则：

- Java `==` 对对象是引用相等；仓颉 class 相等/自定义相等要查目标类型定义，不能默认改成值相等。
- Java record 的值相等必须显式保留。
- `HashMap` key 类型必须满足 `Hashable & Equatable`。

## 12. 静态成员、初始化顺序、单例

Java:

```java
class Config {
    static final int TIMEOUT = 10;
    static {
        init();
    }
}
```

仓颉：

```cangjie
class Config {
    public static const TIMEOUT: Int64 = 10

    static init() {
        initConfig()
    }
}
```

规则：

- Java `static final` 编译期常量可迁为 `static const` 或顶层 `const`。
- 非编译期常量用 `static let`。
- Java class initialization lazy/order 语义复杂；如果源码依赖初始化时机，写测试后迁移。
- Java singleton enum 不直接等价，建议用显式单例对象/模块级封装。

## 13. 注解、反射、模块、构建

| Java 特性 | 仓颉处理 |
|---|---|
| annotation | 仓颉注解能力不同；业务注解通常转配置或代码生成输入 |
| reflection | 需要单独设计；Java `Class/Method/Field` 不直译 |
| dynamic proxy | 框架级重构 |
| `ServiceLoader` | 改为显式注册表或构建期生成 |
| Java module-info | 仓颉 package/module 结构重建 |
| Maven `pom.xml` | 用于依赖盘点，不是仓颉构建文件 |
| resources | 明确复制到仓颉运行目录或生成资源访问 wrapper |

## 14. 并发语法与语义

### 14.1 Thread/Future

Java:

```java
Thread t = new Thread(() -> run());
t.start();
t.join();
```

仓颉：

```cangjie
let fut: Future<Unit> = spawn { =>
    run()
}
fut.get()
```

### 14.2 synchronized

Java:

```java
synchronized (lock) {
    count++;
}
```

仓颉：

```cangjie
import std.sync.*

synchronized(mtx) {
    count++
}
```

规则：

- 仓颉 `synchronized` 后接 `Lock` 实例，例如 `Mutex`。
- Java 任意对象都可作为 monitor；仓颉要显式建锁字段。
- `wait/notify/notifyAll` 迁为 `Condition` 语义，不逐 token 替换。
- Java `volatile` 迁为锁或 `Atomic*`；必须保留 happens-before 语义。

## 15. 不要机械翻译的语法表象

| Java 表象 | 不要直接翻译为 | 正确处理 |
|---|---|---|
| `x != null` | 某个仓颉 null 判断 | 用 `Option` + `match/if let` |
| `str.length()` | `str.size` | 先判断 Java 是否需要 UTF-16 code unit 长度 |
| `str.charAt(i)` | `str[i]` | `str[i]` 是 UTF-8 byte；写 wrapper |
| `String.split(regex)` | `String.split(str)` | 用 `Regex.split` |
| `List.add` 返回值 | 忽略返回值 | 若源码使用返回值，wrapper 返回 `true` 或真实结果 |
| `Map.get` null | `get().getOrThrow()` | 区分无 key、null value、异常 |
| `switch` fall-through | `match` 简单分支 | 合并 case 或重写控制流 |
| `Stream.parallel()` | 普通 for 循环 | 并发语义重新设计 |
| `synchronized(obj)` | `synchronized(obj)` | 新建/注入 `Mutex` |
| `@Transactional` | 注释保留 | 显式事务 wrapper |
| Lombok 注解 | 仓颉注解 | 先展开成构造器/getter/equals/hashCode 等真实语义 |

## 16. Agent 执行顺序

1. 先跑 Java 侧静态扫描：类型、null、异常、集合、并发、反射、框架注解。
2. 对语言语法按本文迁移；对 API 语义查 `api_map.md`。
3. 遇到 `String/char/null/Map/Stream/concurrency/reflection` 立即停下做 wrapper/重写决策。
4. 每迁移一个类，补齐构造器、可见性、继承、equals/hashCode/toString、异常边界。
5. 每迁移一个包，跑行为测试：边界值、null/None、异常、编码、资源关闭、并发。
6. 本地文档未确认的仓颉语法/API，不编造；记录为 blocked。

## 17. 本机语法验证记录

2026-05-15 已用本机 `cjc 1.0.5 (cjnative)` 编译并运行覆盖这些语法映射的小程序：

- `main(): Int64`、顶层函数、变量声明、基础类型标注、数组字面量、范围循环。
- `if` 表达式、`match`、enum 构造、`Option<T>`、`if let Some(v) <- option`。
- lambda 类型 `(T) -> R`、接口实现、泛型接口、`open`/`override`、`abstract class`、主构造器属性。
- `Resource` + `try (r = ...)`、`spawn { => ... }`、`Future<T>.get()`、`synchronized(mutex)`。

这些只证明仓颉语法与标准库调用在当前环境可编译运行；Java 语义是否等价仍必须按 `api_map.md` 的 wrapper/重写规则逐项测试。
