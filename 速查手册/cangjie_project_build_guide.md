# 仓颉项目构建与管理指南

这是一份给 Agent 使用的仓颉项目构建、包管理和验证指南。它和 [cangjie_language_basics.md](./cangjie_language_basics.md) 分工如下：

- `cangjie_language_basics.md`：语言基础、类型、函数、集合、异常、测试语法。
- `cangjie_project_build_guide.md`：项目结构、包/模块、`cjpm.toml`、依赖、workspace、构建、运行、测试、覆盖率和常见构建问题。

---

## 1. 核心概念

### 1.1 包与模块

仓颉项目管理中最容易混淆的是“包”和“模块”：

- **包**是编译的最小单元。每个包有自己的名字空间，同一个包内不允许有同名顶层定义或声明，函数重载除外。一个包可以包含多个源文件。
- **模块**是若干包的集合，是第三方开发者发布的最小单元。
- 一个模块的程序入口只能在模块根目录下，顶层最多只能有一个 `main`。

入口函数规则：

- 入口名为 `main`，不写 `func`。
- `main` 可以没有参数，也可以接收 `Array<String>`。
- `main` 返回类型可以是整数类型或 `Unit`。
- `main` 不可被访问修饰符修饰。
- 包被导入时，其中定义的 `main` 不会被导入。

示例：

```cangjie
main(args: Array<String>): Int64 {
    for (arg in args) {
        println(arg)
    }
    return 0
}
```

### 1.2 包声明与目录路径

包声明规则：

- 包声明使用 `package`。
- 包声明必须位于源文件非空非注释的首行。
- 同一个包中的不同源文件包声明必须一致。
- 包名必须是合法普通标识符。
- 包名需要反映源文件相对于源码根目录的路径，并把路径分隔符替换为 `.`。
- 源码根目录默认名为 `src`。
- 源码根目录下的包可以没有包声明，此时编译器默认包名为 `default`。

示例目录：

```text
src
├── main.cj
└── directory_0
    ├── c.cj
    └── directory_1
        ├── a.cj
        └── b.cj
```

对应包声明：

```cangjie
// src/directory_0/c.cj
package default.directory_0
```

```cangjie
// src/directory_0/directory_1/a.cj
package default.directory_0.directory_1
```

注意：

- 包所在文件夹名必须与包名一致。
- 子包不能和当前包的顶层声明同名。
- 包之间不能形成循环依赖。

### 1.3 有效源码包规则

`cjpm` 只会把有效源码包纳入扫描和编译。一个目录要被识别为有效源码包，必须满足：

1. 该目录直接包含至少一个 `.cj` 文件。
2. 它的父包、父包的父包直到 root 包也都是有效源码包。

如果中间目录没有直接包含 `.cj` 文件，`cjpm` 会忽略它及其子包，并打印类似告警：

```text
Warning: there is no '.cj' file in directory 'demo/src/pkg0', and its subdirectories will not be scanned as source code
```

修复方式是在中间包目录加入一个符合包管理规格的 `.cj` 文件，即使它只包含包声明也可以：

```cangjie
package demo.pkg0
```

这是排查“源码文件明明存在但没有被编译”时的第一检查点。

### 1.4 import 与可见性

常见导入形式：

```cangjie
import std.collection.*
import std.collection.{ArrayList, HashMap}
import std.collection.HashMap as Map
```

导入规则：

- `import` 必须位于包声明之后、其他声明之前。
- 只允许导入当前文件可见的顶层声明或定义。
- 禁止导入当前源文件所在包的声明或定义。
- 禁止包间循环依赖。
- `core` 包会被隐式导入；`String`、`Range` 等能直接使用并不意味着它们是“无需包系统”的特殊类型。
- 导入声明如果和当前包顶层声明重名且不构成函数重载，会被当前包声明遮盖。
- 存在同名导入冲突时，可用 `import as` 重命名，或导入包名作为命名空间。

`import` 可带访问修饰符用于重导出：

- `private import`：默认形式，仅当前文件可访问。
- `internal import`：当前包及其子包可访问，非当前包访问需要显式导入。
- `protected import`：当前 module 内可访问，非当前包访问需要显式导入。
- `public import`：外部可访问，非当前包访问需要显式导入。

注意：包本身不能被重导出；如果 `import` 导入的是包，不允许加 `public`、`protected` 或 `internal`。

---

## 2. `cjpm` 命令速查

`cjpm` 是仓颉包管理工具，用于初始化、检查、构建、运行、测试、性能测试、清理和依赖管理。

| 命令 | 用途 | 常用场景 |
|---|---|---|
| `cjpm init` | 初始化模块或 workspace | 新建项目、生成 `cjpm.toml` 和默认源码目录 |
| `cjpm check` | 检查依赖 | 排查循环依赖、缺失依赖、编译顺序 |
| `cjpm update` | 更新依赖 | 更新 lock 中的依赖版本 |
| `cjpm tree` | 展示依赖树 | 查看源码依赖和测试依赖关系 |
| `cjpm build` | 构建项目 | 编译生产代码 |
| `cjpm run` | 构建并运行二进制 | 运行可执行模块 |
| `cjpm test` | 编译并运行单元测试 | 验证测试文件 |
| `cjpm bench` | 运行性能用例 | 执行 `@Bench` 测试 |
| `cjpm clean` | 清理构建产物 | 删除 `target`、覆盖率中间文件等 |

---

## 3. 初始化项目

`cjpm init` 可初始化模块或 workspace。

初始化模块时：

- 默认在当前文件夹创建 `cjpm.toml`。
- 新建 `src` 源码文件夹。
- 如果产物类型是可执行程序，会在 `src` 下生成默认 `main.cj`。
- 如果已有 `cjpm.toml` 或源码文件夹内已有 `main.cj`，会跳过对应文件创建步骤。

常用选项：

```bash
cjpm init
cjpm init --name demo --path project
cjpm init --type=static
cjpm init --workspace
```

选项含义：

- `--name <value>`：指定新建模块 root 包名；不指定时默认为上一级子文件夹名称。
- `--path <value>`：指定新建模块路径；不指定时默认为当前文件夹。
- `--type=<executable|static|dynamic>`：指定产物类型；缺省为 `executable`。
- `--workspace`：新建 workspace 配置文件；指定后其他 init 选项会被忽略。

---

## 4. `cjpm.toml` 基础

`cjpm.toml` 是模块或 workspace 的配置文件。`cjpm` 主要通过它解析项目、依赖和构建选项。

### 4.1 单模块 `[package]`

单模块配置使用 `[package]`。本地手册列出的关键字段包括：

```toml
[package]
cjc-version = "x.y.z"
name = "demo"
description = "nothing here"
version = "1.0.0"
output-type = "executable"
src-dir = ""
target-dir = ""
compile-option = ""
override-compile-option = ""
link-option = ""
```

字段含义：

- `cjc-version`：所需 `cjc` 的最低版本要求，需要和当前环境兼容。
- `name`：当前模块名称，同时也是模块 root 包名。
- `description`：描述信息，仅作说明。
- `version`：模块版本号。
- `output-type`：输出类型，可为 `executable`、`static`、`dynamic`。
- `src-dir`：源码目录；不指定时默认为 `src`。
- `target-dir`：构建产物目录；不指定时默认为 `target`。
- `compile-option`：传给 `cjc` 的额外编译选项，对模块内所有包生效。
- `override-compile-option`：传给 `cjc` 的额外全局编译选项，对入口模块及依赖模块的包生效，优先级高于 `compile-option`。
- `link-option`：传给链接器的选项，只会自动透传给动态库和可执行产物对应的包。

注意：

- `name` 必须是合法标识符，且本地手册说明当前模块名必须是仅含 ASCII 字符的合法标识符。
- `output-type` 不指定时 `cjpm init` 默认生成 `executable`。
- 只有主模块的 `output-type` 可以为 `executable`。
- 如果命令行同时指定 `--target-dir`，命令行选项优先级更高。
- 若 `target-dir` 在配置中不为空，执行 `cjpm clean` 时会删除该目录，调用前必须确认安全。

### 4.2 单包配置 `package-configuration`

`package-configuration` 可为模块内单个包配置输出类型和编译选项：

```toml
[package.package-configuration."demo.aoo"]
output-type = "dynamic"
compile-option = "-g"
```

用途：

- 对特定包指定 `output-type`。
- 对特定包指定 `compile-option`。
- 生成多个二进制产物时，为多个包声明 `output-type = "executable"`。

### 4.3 workspace

workspace 使用 `[workspace]`，并且不能和 `[package]` 出现在同一个 `cjpm.toml` 中。

```toml
[workspace]
members = ["aoo", "boo", "coo"]
build-members = ["aoo", "boo"]
test-members = ["aoo"]
compile-option = "-Woff all"
override-compile-option = "-O2"

[dependencies]
xoo = { path = "path_xoo" }
```

字段含义：

- `members`：workspace 成员模块列表，支持绝对路径和相对路径；成员必须是模块，不能是另一个 workspace。
- `build-members`：本次编译的模块；不指定时默认编译 workspace 内所有模块；必须是 `members` 子集。
- `test-members`：本次测试的模块；不指定时默认单元测试 workspace 内所有模块；必须是 `build-members` 子集。
- `compile-option`、`override-compile-option`、`link-option`、`target-dir`：workspace 公共配置。

workspace 中除 `[package]` 外的其他公共配置可对成员生效。例如 workspace 中配置 `[dependencies]` 后，成员模块可以直接使用该依赖，无需每个子模块重复配置。

### 4.4 dependencies

`[dependencies]` 通过源码方式导入其他仓颉模块，支持本地路径依赖和远程 `git` 依赖。

本地依赖：

```toml
[dependencies]
pro0 = { path = "./pro0" }
pro1 = { path = "./pro1" }
```

远程依赖：

```toml
[dependencies]
pro0 = { git = "git://github.com/org/pro0.git", tag = "v1.0.0" }
pro1 = { git = "https://gitee.com/anotherorg/pro1", branch = "dev" }
```

远程依赖规则：

- `git` 字段需要是有效 URL。
- `branch`、`tag`、`commitId` 最多可以配置一个或多个，但仅优先级最高者生效。
- 优先级为 `commitId` > `branch` > `tag`。
- `cjpm` 下载远程依赖后，会把当前 `commit-hash` 保存到 `cjpm.lock`。
- 后续 `cjpm` 调用会使用 lock 中保存的版本，直到执行 `cjpm update`。

可通过 `output-type` 覆盖源码依赖自身配置，取值只能是 `static` 或 `dynamic`：

```toml
[dependencies]
pro0 = { path = "./pro0", output-type = "static" }
pro1 = { git = "https://gitee.com/anotherorg/pro1", output-type = "dynamic" }
```

### 4.5 test-dependencies、script-dependencies、replace

`[test-dependencies]`：

- 格式与 `[dependencies]` 相同。
- 仅用于测试阶段。
- 仅可用于文件名形如 `xxx_test.cj` 的测试文件。
- 编译主项目时这些依赖不会被编译。

`[script-dependencies]`：

- 格式与 `[dependencies]` 相同。
- 仅用于构建脚本。
- 和源码依赖、测试依赖相互独立。
- 如果构建脚本与源码/测试都需要同一模块，需要分别在 `script-dependencies` 与 `dependencies` 或 `test-dependencies` 中配置。

`[replace]`：

- 格式与 `[dependencies]` 相同。
- 用于替换间接依赖中的同名模块。
- 替换项会作为编译该模块时最终使用的依赖版本。

### 4.6 target 与交叉编译配置

`[target.<target-name>]` 用于后端和平台隔离配置。`target-name` 可通过 `cjc -v` 输出中的 `Target` 项获取。

常见字段：

- `compile-option`
- `override-compile-option`
- `link-option`
- `dependencies`
- `test-dependencies`
- `bin-dependencies`
- `compile-macros-for-target`

可以继续配置 debug / release 专属字段：

```toml
[target.x86_64-unknown-linux-gnu.debug]
compile-option = "..."

[target.x86_64-unknown-linux-gnu.release]
link-option = "..."
```

合并优先级按本地手册规则处理：

1. debug / release 模式下对应 target 的配置。
2. debug / release 无关的对应 target 配置。
3. 公共配置。

### 4.7 profile

`[profile]` 可配置 `build`、`test`、`bench`、`run` 和自定义透传选项。

`profile.test` 示例：

```toml
[profile.test]
parallel = true
filter = "*.*"
no-color = true
timeout-each = "4m"
random-seed = 10
report-path = "reports"
report-format = "xml"
verbose = true

[profile.test.build]
compile-option = ""
lto = "thin"
mock = "on"

[profile.test.env]
MY_ENV = { value = "abc" }
PATH = { value = "/usr/bin", splice-type = "prepend" }
```

规则：

- 测试配置支持指定编译和运行测试用例时的选项。
- 所有字段均可缺省，不配置时不生效。
- 顶层模块设置的 `profile.test` 才会生效。
- 控制台选项和配置文件同时存在时，控制台选项优先级更高。
- `profile.test.env` 可配置运行测试时的临时环境变量。
- 环境变量 `splice-type` 可取 `absent`、`replace`、`prepend`、`append`。

---

## 5. 构建

### 5.1 基本构建

```bash
cjpm check
cjpm build
cjpm build -V
```

`cjpm build` 会先检查依赖，检查通过后调用 `cjc` 构建。

常用选项：

- `-i, --incremental`：开启 `cjpm` 包级别增量编译。
- `-j, --jobs <N>`：指定并行编译最大并发数，最终最大并发数取 `N` 和 `2倍 CPU 核数` 的最小值。
- `-V, --verbose`：展示编译日志。
- `-g`：生成 debug 版本产物。
- `--mock`：构建带有 mock 支持的版本。
- `--coverage`：生成覆盖率信息。
- `--cfg`：透传 `cjpm.toml` 中的自定义 cfg 选项。
- `-m, --member <value>`：workspace 下指定单个模块作为编译入口。
- `--target-dir <value>`：指定输出产物目录。
- `-o, --output <value>`：指定输出可执行文件名称；默认 `main`，Windows 下默认 `main.exe`。
- `--target <value>`：交叉编译到指定目标平台。
- `-l, --lint`：编译时调用 `cjlint`。
- `--skip-script`：跳过构建脚本编译运行。

产物位置：

- 中间文件默认在 `target`。
- release 可执行文件默认在 `target/release/bin`。
- debug 可执行文件默认在 `target/debug/bin`。

注意：

- `-i, --incremental` 仅开启 `cjpm` 包级别增量编译。
- 如果导入的库内容变更，需要重新全量构建。
- `build` 会创建 `cjpm.lock`，保存可传递依赖的确切版本，用于后续可复制构建。
- 如果需要所有项目参与者拥有可复制构建，`cjpm.lock` 应提交到版本控制系统。

### 5.2 lint

`cjpm build -l` 会在编译期间调用 `cjlint`：

- 检查到“要求”级别规范违规时，构建失败。
- 检查到“建议”级别违规时仅告警，构建可正常完成。

---

## 6. 运行

`cjpm run` 用于运行当前项目构建出的二进制产物，并默认先执行 build 流程。

```bash
cjpm run
cjpm run -g
cjpm run --build-args="-s -j16" --run-args="a b c"
```

常用选项：

- `--name <value>`：指定运行的二进制名称；不指定时默认为 `main`。
- `--build-args <value>`：传给 build 流程的参数。
- `--skip-build`：跳过构建流程，直接运行已有产物。
- `--run-args <value>`：传给二进制产物的参数。
- `--target-dir <value>`：指定运行产物目录。
- `-g`：运行 debug 版本产物。
- `-V, --verbose`：展示运行日志。
- `--skip-script`：跳过构建脚本编译运行。

---

## 7. 测试

### 7.1 基本测试

`cjpm test` 用于编译并运行仓颉单元测试用例，测试产物默认在 `target/release/unittest_bin`。

```bash
cjpm test
cjpm test src/koo
cjpm test src/koo src
```

规则：

- 不指定路径时，默认执行模块级别单元测试。
- 模块级别单元测试默认只测试当前模块。
- 当前模块直接或间接依赖的其他模块内测试不会默认执行。
- `cjpm test` 的前提是当前项目能够 `build` 成功。
- 可指定一个或多个待测试单包路径，例如 `cjpm test path1 path2`。
- 测试文件通常命名为 `xxx_test.cj`。

测试文件结构示例：

```text
src
├── main.cj
├── main_test.cj
└── koo
    ├── koo.cj
    └── koo_test.cj
```

### 7.2 测试常用选项

- `--no-run`：仅编译单元测试产物。
- `--skip-build`：仅执行已有单元测试产物。
- `-i, --incremental`：测试代码增量编译。
- `-j, --jobs <N>`：测试编译最大并发数。
- `-V, --verbose`：输出单元测试日志。
- `-g`：生成 debug 版本测试产物，位置为 `target/debug/unittest_bin`。
- `--module <value>`：指定目标测试模块；目标模块需要被当前模块直接或间接依赖，或就是当前模块。
- `--target-dir <value>`：指定测试产物目录。
- `--coverage`：生成覆盖率数据，配合 `cjcov` 生成报告。
- `-m, --member <value>`：workspace 下测试单个模块。
- `--target <value>`：交叉编译生成目标平台测试结果。
- `--dry-run`：不执行用例，只打印用例。
- `--filter <value>`：过滤测试子集。
- `--include-tags <value>`：运行指定 tag 子集。
- `--exclude-tags <value>`：排除指定 tag 子集。
- `--random-seed <N>`：指定随机种子。
- `--timeout-each <value>`：指定单个测试用例默认超时时间，格式为 `%d[millis|s|m|h]`。
- `--parallel`：指定并行测试方案。
- `--report-path <value>`：指定测试报告目录。
- `--report-format <value>`：指定报告格式；当前单元测试报告仅支持 `xml`。
- `--show-all-output`：打印所有测试输出，包括通过的测试。
- `--no-capture-output`：不捕获输出，执行期间立即打印。
- `--no-progress`：禁用进度报告。

过滤示例：

```bash
cjpm test --filter=*
cjpm test --filter=*.*Test,*.*case*
```

tag 示例：

```bash
cjpm test --include-tags=Unittest
cjpm test --include-tags=Unittest,Smoke
cjpm test --include-tags=Unittest+Smoke
cjpm test --exclude-tags=Smoke
```

### 7.3 mock 相关构建

本地手册说明：

- `cjpm test` 会自动构建所有带有 mock 支持的包。
- 测试中可以对自定义类或依赖源模块的类进行 mock 测试。
- 如果要从某些二进制依赖中 mock 类，应通过 `cjpm build --mock` 构建带 mock 支持的类。

---

## 8. 覆盖率

覆盖率相关工具是 `cjcov`。多文件场景推荐使用：

```bash
cjpm test --coverage
cjcov --root=./ --html-details -o html_output
```

本地手册中的事实：

- `cjpm test --coverage` 可配合 `cjcov` 生成单元测试覆盖率报告。
- 使用 `cjpm test --coverage` 统计覆盖率时，源代码中的 `main` 不再作为程序入口执行，因此会显示为未被覆盖。
- `cjcov --html-details` 可生成每个源文件的 HTML 报告。
- 总覆盖率报告文件名固定为 `index.html`。
- `cjcov` 支持 `--root`、`--output`、`--branches`、`--xml`、`--json`、`--include`、`--exclude` 等选项。
- 分支覆盖率是实验功能，手册说明可能生成不精确的分支覆盖率。

清理覆盖率中间产物：

```bash
cjpm clean
```

`cjpm clean` 会清理 `target`；如果使用过 `cjpm build --coverage` 或 `cjpm test --coverage`，还会清除 `cov_output`、当前目录下的 `*.gcno` 和 `*.gcda` 文件。

---

## 9. 性能测试

`cjpm bench` 用于执行性能用例并打印测试结果，性能用例由 `@Bench` 标注。

```bash
cjpm bench
cjpm bench src
cjpm bench src --filter=*
```

常见事实：

- 性能测试产物默认存放在 `target/release/unittest_bin`。
- `-g` 生成 debug 版本产物，位置为 `target/debug/unittest_bin`。
- workspace 下可用 `-m, --member <value>` 指定单个模块。
- 可通过 `--target` 交叉编译生成目标平台性能测试结果。
- `profile.bench` 可配置性能测试运行选项。

---

## 10. 清理

```bash
cjpm clean
cjpm clean --target-dir temp
```

`cjpm clean` 用于清理构建过程中的临时产物：

- 默认清理 `target`。
- `-g` 可指定仅清理 debug 版本产物。
- `--target-dir <value>` 可指定要清理的产物目录。
- 使用覆盖率功能后，还会清理 `cov_output`、当前目录下的 `*.gcno` 和 `*.gcda`。
- `--skip-script` 可跳过构建脚本的编译运行。

注意：如果配置了自定义 `target-dir`，清理前必须确认路径安全。

---

## 11. 依赖检查与依赖树

### 11.1 `cjpm check`

```bash
cjpm check
cjpm check -m module_name
```

用途：

- 检查项目依赖。
- 成功时打印有效包编译顺序。
- 可暴露循环依赖。
- 可暴露缺失依赖。
- workspace 下 `-m, --member <value>` 可指定单个模块作为检查入口。
- `--no-tests` 可排除测试相关依赖。
- `--skip-script` 可跳过构建脚本。

常见错误形态：

```text
Error: cyclic dependency
```

```text
Error: can not find the following dependencies
```

### 11.2 `cjpm tree`

`cjpm tree` 用于展示源码依赖关系。

常用选项：

- `--depth <value>`：控制展示深度。
- `-p, --package <value>`：指定某个包为根节点。
- `--invert <value>`：反向展示依赖。
- `--verbose`：展示更详细信息。
- `--target <value>`：把指定目标平台的依赖加入分析。
- `--no-tests`：排除 `test-dependencies`。

---

## 12. 构建脚本

`cjpm` 支持构建脚本。项目可定义 `build.cj`，并定义某些命令前后的行为。以 `build` 为例，定义 `pre-build` 和 `post-build` 后，`cjpm build` 会先编译 `build.cj`，在构建前后执行对应行为。

本地手册中的注意点：

- `build.cj` 的输出会重定向到 `build-script-cache/[target|release]/[module-name]/bin/script-log`。
- 多模块场景下，被依赖模块的 `build.cj` 会在编译和单元测试流程中生效。
- 构建脚本可以通过 `[script-dependencies]` 导入依赖。
- 构建脚本依赖和源码/测试依赖相互独立。

Agent 处理构建脚本时：

- 不要忽略 `build.cj`，它可能影响构建、生成文件或环境检查。
- 命令失败时查看 `build-script-cache/.../script-log`。
- 修改脚本依赖时同步检查 `[script-dependencies]`。

---

## 13. Agent 项目处理流程

处理一个仓颉项目时，按这个顺序收集事实：

1. 找到项目根目录，确认是否存在 `cjpm.toml`。
2. 判断是单模块 `[package]` 还是 workspace `[workspace]`。
3. 读取 `src-dir`、`target-dir`、`output-type`、`dependencies`、`test-dependencies`、`profile.*`。
4. 检查包声明是否和源码目录匹配。
5. 检查每个中间包目录是否直接包含 `.cj` 文件。
6. 对 workspace，确认 `members`、`build-members`、`test-members`。
7. 先运行 `cjpm check`，需要细节时加 `-V` 到后续构建命令。
8. 运行 `cjpm build` 或 workspace 下的 `cjpm build -m <member>`。
9. 运行 `cjpm test` 或指定路径/模块的测试命令。
10. 若需要覆盖率，再运行 `cjpm test --coverage` 和 `cjcov`。

最小验证命令：

```bash
cjpm check
cjpm build
cjpm test
```

定位构建问题时：

```bash
cjpm build -V
cjpm test --dry-run
cjpm tree
```

workspace 常用：

```bash
cjpm check -m <member>
cjpm build -m <member>
cjpm test -m <member>
```

---

## 14. 常见问题定位

### 14.1 源文件没有被编译

优先检查：

- 该目录是否直接包含 `.cj` 文件。
- 父包目录是否也直接包含 `.cj` 文件。
- 包声明是否与 `src` 下相对路径一致。
- `src-dir` 是否被改过。

典型告警：

```text
Warning: there is no '.cj' file in directory ..., and its subdirectories will not be scanned as source code
```

### 14.2 import 找不到或循环依赖

优先检查：

- 是否导入了当前包自身声明。
- 被导入声明是否可见。
- 包名、目录名、模块名是否一致。
- 是否存在包间循环依赖。
- 是否需要 `import as` 解决同名冲突。

可运行：

```bash
cjpm check
cjpm tree
cjpm build -V
```

### 14.3 workspace 指定模块不生效

检查：

- `members` 是否包含该模块。
- `build-members` 是否是 `members` 子集。
- `test-members` 是否是 `build-members` 子集。
- 是否在命令中正确使用 `-m, --member`。
- 根 `cjpm.toml` 是否同时出现了 `[package]` 和 `[workspace]`；这不允许。

### 14.4 测试没有运行到预期模块

检查：

- `cjpm test` 默认只测试当前模块，不会默认执行依赖模块中的测试。
- workspace 中 `test-members` 是否限制了测试模块。
- 是否需要 `cjpm test -m <member>`。
- 是否传入了具体包路径，例如 `cjpm test src/koo`。
- 是否被 `--filter`、`--include-tags`、`--exclude-tags` 或 `profile.test` 过滤。
- 测试文件是否按 `xxx_test.cj` 命名。

### 14.5 覆盖率看起来缺少 `main`

本地手册说明：使用 `cjpm test --coverage` 统计覆盖率时，源代码中的 `main` 不再作为程序入口执行，因此会显示为未被覆盖。这不是单独的构建错误。

---

## 15. 本地来源

本指南内容来自以下本地文档：

- `CangjieCorpus/manual/source_zh_cn/package/package_overview.md`
- `CangjieCorpus/manual/source_zh_cn/package/package_name.md`
- `CangjieCorpus/manual/source_zh_cn/package/entry.md`
- `CangjieCorpus/manual/source_zh_cn/package/import.md`
- `CangjieCorpus/tools/source_zh_cn/tools/cjpm_manual_cjnative_community.md`
- `CangjieCorpus/tools/source_zh_cn/tools/cjcov_manual_cjnative.md`

需要更细的配置字段、命令参数、构建脚本或平台差异时，优先回查这些文件。
