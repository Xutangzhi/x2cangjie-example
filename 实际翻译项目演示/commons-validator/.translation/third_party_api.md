# Third-party API / TPC Decisions

No Cangjie TPC package is adopted for this migration plan. The Java dependencies in `java/commons-validator/pom.xml` are implementation aids rather than externally visible protocols: commons-beanutils for property access, commons-digester for XML config loading, commons-logging for warnings, and commons-collections for FastHashMap compatibility. DEC-0002 records the decision to implement explicit Cangjie adapters/parsers/wrappers inside the provided skeleton and verify them with source tests and target smoke commands.
