# Java Repo Scan Summary

- Repo: `commons-validator`
- Path: `/Users/xutangzhi/Desktop/exp_projects/x2cangjie/formulate_version/commons-validator`
- Build: maven
- Files: java=163 main=73 test=88 generated=0 ignored=0
- Surface: types=184 production_api=698 test_methods=396 disabled_tests=2
- Signals: risks=concurrency, config, io, network, reflection, serialization, time, xml

## Migration Focus

Production package focus:
- `org.apache.commons.validator.routines` types=35
- `org.apache.commons.validator` types=27
- `org.apache.commons.validator.routines.checkdigit` types=18
- `org.apache.commons.validator.example` types=2
- `org.apache.commons.validator.util` types=2

Largest production API owners:
- `org.apache.commons.validator.Field` api=39
- `org.apache.commons.validator.GenericValidator` api=32
- `org.apache.commons.validator.ValidatorAction` api=24
- `org.apache.commons.validator.Validator` api=21
- `org.apache.commons.validator.ValidatorResources` api=20
- `org.apache.commons.validator.routines.CalendarValidator` api=19
- `org.apache.commons.validator.routines.DateValidator` api=18
- `org.apache.commons.validator.FormSet` api=17

## Module Dependency Order

Cyclic module groups (translate together):
- `org.apache.commons.validator`, `org.apache.commons.validator.routines`, `org.apache.commons.validator.routines.checkdigit`, `org.apache.commons.validator.util`

1. `org.apache.commons.validator.example` depends_on=`org.apache.commons.validator`
2. `org.apache.commons.validator.util` depends_on=`org.apache.commons.validator`
3. `org.apache.commons.validator` depends_on=`org.apache.commons.validator.routines`,`org.apache.commons.validator.util`
4. `org.apache.commons.validator.routines` depends_on=`org.apache.commons.validator`,`org.apache.commons.validator.routines.checkdigit`
5. `org.apache.commons.validator.routines.checkdigit` depends_on=`org.apache.commons.validator`,`org.apache.commons.validator.routines`

## Build Signals

Build files:
- `java/commons-validator/pom.xml` (maven)
main dependencies:
- `commons-beanutils:commons-beanutils:1.11.0`
- `commons-digester:commons-digester:2.1`
- `commons-logging:commons-logging:1.3.6`
- `commons-collections:commons-collections:3.2.2`
test dependencies:
- `org.apache.commons:commons-csv:1.14.1`
- `org.junit.jupiter:junit-jupiter`
- `org.junit-pioneer:junit-pioneer`
- `org.bitstrings.test:junit-clptr:1.2.2`
- `org.apache.commons:commons-lang3:3.20.0`

## Source Sets

- `java` other files=2
- `java/commons-validator/src/main/java` main files=73
- `java/commons-validator/src/test/java` test files=88

## Test Families

- `org.apache.commons.validator.routines.UrlValidatorTest` methods=33
- `org.apache.commons.validator.routines.EmailValidatorTest` methods=25 disabled=1
- `org.apache.commons.validator.routines.CreditCardValidatorTest` methods=21
- `org.apache.commons.validator.routines.DomainValidatorStartupTest` methods=21
- `org.apache.commons.validator.routines.DomainValidatorTest` methods=20 disabled=1
- `org.apache.commons.validator.routines.IBANValidatorTest` methods=16
- `org.apache.commons.validator.util.FlagsTest` methods=13
- `org.apache.commons.validator.routines.ISBNValidatorTest` methods=12
- `org.apache.commons.validator.EmailTest` methods=11
- `org.apache.commons.validator.routines.AbstractNumberValidatorTest` methods=10
- `org.apache.commons.validator.FieldTest` methods=9
- `org.apache.commons.validator.routines.ISSNValidatorTest` methods=9
- `org.apache.commons.validator.ExtensionTest` methods=8
- `org.apache.commons.validator.MultipleTest` methods=8
- `org.apache.commons.validator.routines.InetAddressValidatorTest` methods=8
- `org.apache.commons.validator.routines.RegexValidatorTest` methods=8

## Dependency Signals

- Internal import edges: 68
- Main external packages: `java.io`, `java.lang`, `java.math`, `java.net`, `java.nio`, `java.text`, `java.util`, `org.apache.commons`, `org.xml.sax`
- Test external packages: `java.io`, `java.lang`, `java.math`, `java.net`, `java.nio`, `java.text`, `java.util`, `org.apache.commons`

## Risk Evidence

- concurrency: 6 (production=6)
  - `java/commons-validator/src/main/java/org/apache/commons/validator/Field.java:57` [main] protected volatile int page;
- config: 7 (production=7)
  - `.translation/final-reviewer/issue-queue.yaml` [resource] configuration resource
- io: 12 (production=12)
  - `java/commons-validator/src/example/org/apache/commons/validator/example/ValidateExample.java:4` [other] import java.io.IOException;
- network: 6 (production=3 test=3)
  - `java/commons-validator/src/main/java/org/apache/commons/validator/ValidatorResources.java:7` [main] import java.net.URL;
- reflection: 3 (production=2 test=1)
  - `java/commons-validator/src/main/java/org/apache/commons/validator/Field.java:5` [main] import java.lang.reflect.InvocationTargetException;
- serialization: 12 (production=12)
  - `java/commons-validator/src/main/java/org/apache/commons/validator/Arg.java:4` [main] import java.io.Serializable;
- time: 12 (production=5 test=7)
  - `java/commons-validator/src/main/java/org/apache/commons/validator/GenericTypeValidator.java:10` [main] import java.util.Date;
- xml: 12 (production=3 test=9)
  - `java/commons-validator/src/example/org/apache/commons/validator/example/ValidateExample.java:19` [other] import org.xml.sax.SAXException;

## Resources And Config

- build: 1 `java/commons-validator/pom.xml`
- config: 25 `.translation/final-reviewer/issue-queue.yaml`, `.translation/tester/issue-queue.yaml`, `.translation/translator/decision-log.yaml`
- resource: 19 `java/commons-validator/src/main/resources/org/apache/commons/validator/digester-rules.xml`, `java/commons-validator/src/test/resources/org/apache/commons/validator/DateTest-config.xml`, `java/commons-validator/src/test/resources/org/apache/commons/validator/EmailTest-config.xml`

## Translator Next Steps

- Review this scan for false positives and missing generated sources.
- Use java_types, public_api, tests, and dependency_graph to draft module-backlog.yaml.
- Convert risk_flags into explicit migration decisions or focused follow-up scans.
- Do not treat this scan as final truth; translator must verify against source behavior and tests.
