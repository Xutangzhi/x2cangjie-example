# Migration Decision Log

## DEC-0001
Type: test-strategy
Status: accepted
Scope: all P0 slices, source tests, target tests
Context:
The Java project has 396 source test methods covering public routines and core config behavior; preserving their assertion intent is the highest-value parity signal.
Decision:
Use source JUnit tests as the semantic oracle and translate representative assertions per behavior slice into std.unittest tests.
Evidence:
- mvn -q test passed in java/commons-validator
- references/migration_guide/quick-ref/test_map.md
Impact:
Target tests must exercise production Cangjie code paths and not placeholders.
Follow-up:
Each todo feature contract lists translated tests and command evidence.

## DEC-0002
Type: dependency
Status: accepted
Scope: module-core, module-resources, ValidatorUtils, Field, ValidatorResources
Context:
The provided cangjie/src skeleton exposes a standalone library API; the Java dependencies are used for reflection/property access, XML digester configuration, logging, and map wrappers that can be represented by narrow explicit Cangjie code. No runtime external service or protocol dependency is required.
Decision:
Do not introduce direct Cangjie third-party replacements for Java commons-beanutils, commons-digester, commons-logging, or commons-collections.
Evidence:
- java/commons-validator/pom.xml dependencies
- repo-scan dependency signals
- references/migration_guide/quick-ref/api_map.md reflection/XML guidance
Impact:
Target implements explicit adapters/registries and XML/resource handling instead of fake stubs or unverified TPC packages.
Follow-up:
If later hidden tests require full XML digester compatibility beyond fixture-backed behavior, add a focused dependency query or parser enhancement.

## DEC-0003
Type: scope
Status: accepted
Scope: java/commons-validator/src/example/org/apache/commons/validator/example
Context:
The user-provided target API skeleton only covers cangjie/src library APIs, and Java src/example is not Maven main source.
Decision:
Example source tree is outside this target skeleton migration.
Evidence:
- cangjie/src contains no example API skeleton
- repo-scan marks src/example as other source set
- java/commons-validator/pom.xml main source roots are src/main/java/resources
Impact:
Library behavior, public main APIs, resources, and tests remain in scope; demo CLI/sample beans are not delivered in cangjie/src.
Follow-up:
Create a separate Cangjie example app only if future evaluation explicitly includes Java src/example.

