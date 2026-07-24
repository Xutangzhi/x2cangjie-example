# Fix Patterns Archive

This file records reusable migration patterns discovered while translating `commons-validator`.

## Pattern 1: Object-backed bean parity instead of map stand-ins

- Problem: grouped translated tests initially used `HashMap` fixtures for Java bean inputs, which failed to exercise the same property-access boundary as the Java source tests.
- Fix:
  - add object-backed adapters in `cangjie/tests/core_config_test.cj`
  - implement `validator.ValidatorPropertyAccess`
  - pass real bean objects through `Validator.BEAN_PARAM`
- Reuse when a Java source test depends on getter/property lookup semantics rather than raw map access.

## Pattern 2: Bridge util-package and validator-package property access

- Problem: `org.apache.commons.validator.util.ValidatorUtils.getValueAsString(Object, String)` is an active Java public API, but the translated util package originally used a separate property-access interface boundary.
- Fix:
  - in `cangjie/src/util/ValidatorUtils.cj`, accept both `validator.util.ValidatorPropertyAccess` and `validator.ValidatorPropertyAccess`
  - add direct translated assertions against `validator.util.ValidatorUtils.getValueAsString(...)`
- Reuse when a translated public utility API duplicates or parallels an internal helper path and both must stay semantically aligned.

## Pattern 3: Grouped translated tests with explicit source mapping

- Problem: the target suite is smaller than the Java suite because multiple source tests are intentionally grouped into one translated executable case.
- Fix:
  - keep explicit `source_test_ids` -> target test group mapping in `feature-contract.yaml`
  - preserve the source assertions inside each grouped test body
  - forbid placeholder or `ensure(true)` coverage
- Reuse when the skeleton API supports a denser translated test surface without losing source-test traceability.

## Pattern 4: XML fixture-backed config slices need real resource replay

- Problem: config/resource behavior cannot be validated from constructors alone.
- Fix:
  - load the original Java XML fixtures from `java/commons-validator/src/test/resources/...`
  - assert locale fallback, extension merge, entity import, and validator resource behavior from translated tests
- Reuse when a slice depends on declarative resources or parser-side behavior.
