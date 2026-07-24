# Java-to-Cangjie Agent Rules

## Required Workflow

1. Migrate by verifiable backend behavior slices, not by file lists.
2. Build module/API/test/dependency models before selecting implementation todos.
3. Persist translator state under `.translation/translator/`.
4. Persist continuity tester state under `.translation/tester/`.
5. Persist final closure reviewer state under `.translation/final-reviewer/`.
6. Assign stable `behavior_ids` to P0/P1 slices, todos, and ledger obligations so the Datalog-style traceability graph can certify `behavior -> obligation -> todo -> evidence` traceability.
7. Do not start implementation until tester accepts the plan audit.
8. Advance todos from `.translation/translator/migration-todo.yaml`.
9. Use RED -> GREEN -> REFACTOR -> SMOKE for each verifiable behavior.
10. Mark a todo as `finished` only when tester report has `decision=PASS`, matching `todo_verdict.verdict=pass`, `todo_verdict.can_mark_finished=true`, and an immutable `.translation/tester/reports/<report_id>.yaml` evidence path.
11. Run state gates before transitions with both commands: `python3 <skill_dir>/scripts/yaml_guard.py <repo> --phase <gate> --strict --json` and `<skill_dir>/scripts/two_agent_gate_check.sh <gate> <repo>`. `yaml_guard.py` runs Datalog-style traceability checks and writes `.translation/formal/facts`, `.translation/formal/violations`, and `.translation/formal/certificates`; `two_agent_gate_check.sh` appends `.translation/formal/gate-history.jsonl`, updates `.translation/formal/gate-history.head.json`, and writes `.translation/formal/gate-certificates/<phase>.json` only after all checks pass.
12. Required gates are `todo` before Plan Tester, `plan-accepted` before implementation, `contract` before Todo Tester, `tester` after Todo Tester sync, `closure-ready` before final reviewer, `reviewed` after final reviewer sync, and `delivery` before final reporting.
13. If a gate fails, do not advance `run-state.yaml > translator.phase`, do not close todos, do not start final reviewer, and do not report completion. Fix state/code/tests/evidence and rerun the same gate.
14. Claim full migration only after final reviewer returns `decision=PASS` with `closure.completion_kind=complete`, the `reviewed` gate passes, and the `delivery` gate passes; `blocked-partial` must be described as a partial handoff, not full completion.
15. Unless final reviewer has returned `FINAL_CLOSURE PASS`, the `reviewed` gate has passed, and the `delivery` gate has passed, continue iterating or report a blocked wait state; do not stop as completed.
16. Keep this as a pure backend migration. Frontend/UI/mobile concerns are out of scope unless explicitly accepted as blocked or excluded.
17. Every in-scope source test must map to a todo `source_test_ids`, a `kind=source-test` obligation, or an explicit out-of-scope/blocked/accepted-deviation decision. Every P0/P1 public API must map to a todo `public_api_ids`, a `kind=public-api` obligation, or an explicit out-of-scope/blocked/accepted-deviation decision. Every runtime entry must map to a `kind=runtime-entry` obligation or explicit out-of-scope/blocked/accepted-deviation decision. Every runtime-critical module must map to a ledger obligation, planned slice `source_modules`, or explicit out-of-scope/blocked/accepted-deviation decision. Every external dependency boundary must map to a `kind=dependency-boundary` obligation or explicit out-of-scope/blocked/accepted-deviation decision.

## Avoid

1. Do not weaken source test assertions.
2. Do not hide source tests, public APIs, or runtime-critical modules.
3. Do not treat compile success as behavior parity.
4. Do not use mock, stub, empty adapter, or test-only branch as production behavior.
5. Do not declare completion from translator summaries alone.
6. Remove obsolete commented-out scaffolding once behavior is implemented; keep only comments that explain non-obvious migration decisions.
