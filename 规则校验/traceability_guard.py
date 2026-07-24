#!/usr/bin/env python3
"""Derived traceability checks for Java-to-Cangjie migration state.

The facts in this module are derived from existing YAML state. They are not a
new hand-maintained source of truth.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


TRANSLATOR = ".translation/translator"
TESTER = ".translation/tester"
FINAL_REVIEWER = ".translation/final-reviewer"

P0_P1 = {"P0", "P1"}
TERMINAL_TODO_STATUSES = {"finished", "blocked", "accepted-deviation"}
TERMINAL_LEDGER_STATUSES = {"verified", "blocked", "accepted-deviation"}
PARTIAL_STATUSES = {"blocked", "accepted-deviation"}
FORMAL = ".translation/formal"
RULES_FILE = Path(__file__).resolve().parent.parent / "rules" / "traceability.dl"


@dataclass
class TraceabilityFacts:
    behaviors: dict[str, dict[str, Any]] = field(default_factory=dict)
    todos: dict[str, dict[str, Any]] = field(default_factory=dict)
    obligations: dict[str, dict[str, Any]] = field(default_factory=dict)
    source_tests: dict[str, dict[str, Any]] = field(default_factory=dict)
    public_apis: dict[str, dict[str, Any]] = field(default_factory=dict)
    runtime_entries: dict[str, dict[str, Any]] = field(default_factory=dict)
    runtime_modules: dict[str, dict[str, Any]] = field(default_factory=dict)
    dependency_boundaries: dict[str, dict[str, Any]] = field(default_factory=dict)
    decisions: dict[str, dict[str, Any]] = field(default_factory=dict)
    inventory_decisions: set[tuple[str, str]] = field(default_factory=set)
    planned_runtime_modules: set[str] = field(default_factory=set)
    decided_items: set[str] = field(default_factory=set)
    covers: set[tuple[str, str]] = field(default_factory=set)
    contract_covers: set[tuple[str, str]] = field(default_factory=set)
    requires: set[tuple[str, str]] = field(default_factory=set)
    todo_obligations: set[tuple[str, str]] = field(default_factory=set)
    behavior_obligations: set[tuple[str, str]] = field(default_factory=set)
    contract_behavior_obligations: set[tuple[str, str]] = field(default_factory=set)
    contract_tdd_behaviors: set[str] = field(default_factory=set)
    contract_tdd_shape_ok: set[str] = field(default_factory=set)
    evidence_for: set[tuple[str, str]] = field(default_factory=set)
    proves: set[tuple[str, str]] = field(default_factory=set)
    blocked_entry_complete: set[str] = field(default_factory=set)
    closure_kind: str = ""
    tester_verified: set[str] = field(default_factory=set)
    tester_accepted_deviation: set[str] = field(default_factory=set)
    tester_snapshots_by_todo: dict[str, list[dict[str, Any]]] = field(default_factory=dict)
    tester_pass_evidence: set[tuple[str, str, str]] = field(default_factory=set)
    tester_accepted_evidence: set[tuple[str, str, str]] = field(default_factory=set)
    snapshot_parse_errors: dict[str, str] = field(default_factory=dict)


def validate_traceability(
    *,
    repo: Path,
    phase: str,
    backlog: Any = None,
    ledger: Any = None,
    todo: Any = None,
    contract: Any = None,
    tester_report: Any = None,
    reviewer_report: Any = None,
    blocked: Any = None,
    decision_log: Any = None,
    write_artifacts: bool = True,
) -> list[dict[str, str]]:
    """Return yaml_guard-compatible issues for the derived fact graph."""
    phase = normalize_phase(phase)
    facts = build_facts(
        repo=repo,
        backlog=backlog,
        ledger=ledger,
        todo=todo,
        contract=contract if phase in {"contract", "tester", "all"} else None,
        tester_report=tester_report,
        reviewer_report=reviewer_report,
        blocked=blocked,
        decision_log=decision_log,
    )
    issues: list[dict[str, str]] = []

    if not RULES_FILE.is_file():
        issues.append(error("rules/traceability.dl", "missing traceability rule contract", "TR-CERT-002"))
    else:
        validate_rule_contract_alignment(issues)

    validate_graph_integrity(facts, issues)

    if phase in {"todo", "plan-accepted", "contract", "tester", "closure-ready", "reviewed", "delivery", "all"}:
        validate_plan_traceability(repo, facts, backlog, ledger, todo, issues)
    if phase in {"contract", "tester", "all"}:
        validate_contract_traceability(facts, ledger, todo, contract, issues)
    if phase in {"closure-ready", "reviewed", "delivery", "all"}:
        validate_closure_traceability(repo, facts, ledger, todo, reviewer_report, blocked, issues)

    if write_artifacts:
        try:
            write_formal_artifacts(repo, phase, facts, issues)
        except Exception as exc:  # noqa: BLE001 - artifact write failures must fail the gate.
            issues.append(error(f"{FORMAL}/certificates/{phase}.json", f"cannot write formal artifacts: {exc}", "TR-CERT-001"))

    return issues


def build_facts(
    *,
    repo: Path,
    backlog: Any = None,
    ledger: Any = None,
    todo: Any = None,
    contract: Any = None,
    tester_report: Any = None,
    reviewer_report: Any = None,
    blocked: Any = None,
    decision_log: Any = None,
) -> TraceabilityFacts:
    facts = TraceabilityFacts()
    add_decision_facts(facts, decision_log)
    add_backlog_facts(facts, backlog)
    add_ledger_facts(facts, ledger)
    add_todo_facts(facts, todo)
    add_contract_facts(facts, contract)
    add_tester_report_facts(facts, tester_report)
    add_tester_snapshot_facts(facts, repo)
    add_closure_facts(facts, reviewer_report, blocked)
    infer_todo_covers_from_obligations(facts)
    return facts


def add_decision_facts(facts: TraceabilityFacts, decision_log: Any) -> None:
    for decision in as_list(as_map(decision_log).get("decisions", [])):
        if not isinstance(decision, dict):
            continue
        decision_id = str(decision.get("decision_id") or "")
        if decision_id:
            facts.decisions[decision_id] = decision


def add_backlog_facts(facts: TraceabilityFacts, backlog: Any) -> None:
    backlog_map = as_map(backlog)
    for item in as_list(as_map(backlog_map.get("test_inventory")).get("source_tests", [])):
        if not isinstance(item, dict):
            continue
        test_id = str(item.get("test_id") or item.get("id") or item.get("source_ref") or "")
        if test_id:
            facts.source_tests[test_id] = item
            remember_inventory_decisions(facts, test_id, item)
            if inventory_item_decided(item):
                remember_decided_item(facts, test_id, item)
    for item in as_list(as_map(backlog_map.get("public_api_graph")).get("apis", [])):
        if not isinstance(item, dict):
            continue
        api_id = str(item.get("api_id") or item.get("id") or item.get("source_ref") or item.get("signature") or "")
        if api_id:
            facts.public_apis[api_id] = item
            remember_inventory_decisions(facts, api_id, item)
            if inventory_item_decided(item):
                remember_decided_item(facts, api_id, item)
    for module in as_list(as_map(backlog_map.get("module_graph")).get("modules", [])):
        if not isinstance(module, dict):
            continue
        module_id = str(module.get("module_id") or "")
        if module_id and module.get("classification") == "runtime-critical":
            facts.runtime_modules[module_id] = module
            remember_inventory_decisions(facts, module_id, module)
            if inventory_item_decided(module):
                remember_decided_item(facts, module_id, module)
    for index, boundary in enumerate(as_list(as_map(backlog_map.get("dependency_inventory")).get("external_boundaries", []))):
        boundary_id = dependency_boundary_id(boundary, index)
        if boundary_id:
            facts.dependency_boundaries[boundary_id] = as_map(boundary) if isinstance(boundary, dict) else {"boundary_id": boundary_id, "value": boundary}
            remember_inventory_decisions(facts, boundary_id, boundary)
            if inventory_item_decided(boundary):
                remember_decided_item(facts, boundary_id, boundary)
    for group_name, entries in as_map(backlog_map.get("runtime_entries")).items():
        for index, entry in enumerate(as_list(entries)):
            entry_id = runtime_entry_id(group_name, entry, index)
            if entry_id:
                facts.runtime_entries[entry_id] = {"entry_id": entry_id, "group": group_name, "entry": entry}
                remember_inventory_decisions(facts, entry_id, entry)
                if inventory_item_decided(entry):
                    remember_decided_item(facts, entry_id, entry)

    for item in as_list(as_map(backlog).get("planned_slices", [])):
        if not isinstance(item, dict):
            continue
        slice_id = str(item.get("slice_id") or "")
        priority = str(item.get("priority") or "")
        facts.planned_runtime_modules.update(str(value) for value in as_list(item.get("source_modules", [])) if value)
        for behavior_id in behavior_ids_from(item):
            register_behavior(
                facts,
                behavior_id,
                source="planned_slice",
                priority=priority,
                slice_id=slice_id,
                source_refs=as_list(item.get("source_modules", [])),
            )


def add_ledger_facts(facts: TraceabilityFacts, ledger: Any) -> None:
    for obligation in as_list(as_map(ledger).get("obligations", [])):
        if not isinstance(obligation, dict):
            continue
        obligation_id = str(obligation.get("obligation_id") or "")
        if not obligation_id:
            continue
        facts.obligations[obligation_id] = obligation
        priority = str(obligation.get("priority") or "")
        source_ref = str(obligation.get("source_ref") or "")
        for behavior_id in behavior_ids_from(obligation):
            register_behavior(
                facts,
                behavior_id,
                source="ledger",
                priority=priority,
                slice_id=str(obligation.get("slice_id") or ""),
                source_refs=[source_ref] if source_ref else [],
            )
            facts.behavior_obligations.add((behavior_id, obligation_id))
        todo_id = str(obligation.get("todo_id") or "")
        if todo_id:
            facts.todo_obligations.add((todo_id, obligation_id))
        for evidence_kind, values in as_map(obligation.get("evidence")).items():
            if not isinstance(values, list):
                continue
            for index, evidence in enumerate(values):
                evidence_id = f"ledger:{obligation_id}:{evidence_kind}:{index}"
                facts.evidence_for.add((evidence_id, obligation_id))
                for behavior_id in behavior_ids_from(evidence):
                    facts.proves.add((evidence_id, behavior_id))


def add_todo_facts(facts: TraceabilityFacts, todo: Any) -> None:
    for item in as_list(as_map(todo).get("todos", [])):
        if not isinstance(item, dict):
            continue
        todo_id = str(item.get("todo_id") or "")
        if not todo_id:
            continue
        facts.todos[todo_id] = item
        priority = str(item.get("priority") or "")
        for dep_id in as_list(item.get("depends_on", [])):
            if dep_id:
                facts.requires.add((todo_id, str(dep_id)))
        for obligation_id in as_list(item.get("ledger_obligation_ids", [])):
            if obligation_id:
                facts.todo_obligations.add((todo_id, str(obligation_id)))
        for behavior_id in behavior_ids_from(item):
            register_behavior(
                facts,
                behavior_id,
                source="todo",
                priority=priority,
                slice_id=str(item.get("slice_id") or ""),
                source_refs=as_list(item.get("source_refs", [])),
            )
            facts.covers.add((todo_id, behavior_id))


def add_contract_facts(facts: TraceabilityFacts, contract: Any) -> None:
    active_todo = str(as_map(contract).get("active_todo_id") or "")
    for behavior in as_list(as_map(contract).get("claimed_behaviors", [])):
        if not isinstance(behavior, dict):
            continue
        behavior_id = str(behavior.get("behavior_id") or "")
        if not behavior_id:
            continue
        register_behavior(
            facts,
            behavior_id,
            source="feature_contract",
            priority="",
            slice_id=str(as_map(contract).get("active_slice") or ""),
            source_refs=as_list(behavior.get("source_refs", [])),
        )
        if active_todo:
            facts.contract_covers.add((active_todo, behavior_id))
        for obligation_id in as_list(behavior.get("ledger_obligation_ids", [])):
            if obligation_id:
                facts.contract_behavior_obligations.add((behavior_id, str(obligation_id)))
    for index, evidence in enumerate(as_list(as_map(contract).get("tdd_evidence", []))):
        if not isinstance(evidence, dict):
            continue
        behavior_id = str(evidence.get("behavior_id") or "")
        evidence_id = f"contract:{active_todo}:{behavior_id or index}"
        for obligation_id in as_list(evidence.get("ledger_obligation_ids", [])):
            if obligation_id:
                facts.evidence_for.add((evidence_id, str(obligation_id)))
        if behavior_id:
            facts.contract_tdd_behaviors.add(behavior_id)
            if tdd_evidence_shape_ok(evidence):
                facts.contract_tdd_shape_ok.add(behavior_id)
            facts.proves.add((evidence_id, behavior_id))


def add_closure_facts(facts: TraceabilityFacts, reviewer_report: Any, blocked: Any) -> None:
    closure_kind = str(as_map(as_map(reviewer_report).get("closure")).get("completion_kind") or "")
    if closure_kind:
        facts.closure_kind = closure_kind
    for obligation_id in facts.obligations:
        if not blocked_entry_issues(blocked, obligation_id):
            facts.blocked_entry_complete.add(obligation_id)


def add_tester_report_facts(facts: TraceabilityFacts, report: Any) -> None:
    report_map = as_map(report)
    if report_map.get("report_type") != "TODO_VERIFICATION":
        return
    report_id = str(report_map.get("report_id") or "latest")
    verdict = as_map(report_map.get("todo_verdict"))
    todo_id = str(verdict.get("todo_id") or report_map.get("active_todo_id") or "")
    add_tester_verdict_facts(facts, report_map, report_id, todo_id, "", immutable=False)


def add_tester_snapshot_facts(facts: TraceabilityFacts, repo: Path) -> None:
    reports_dir = repo / TESTER / "reports"
    if not reports_dir.is_dir():
        return
    for path in sorted(reports_dir.glob("*.yaml")):
        rel_path = path.relative_to(repo).as_posix()
        try:
            report = as_map(load_yaml(path))
        except Exception as exc:
            facts.snapshot_parse_errors[rel_path] = str(exc)
            continue
        if report.get("report_type") != "TODO_VERIFICATION":
            continue
        report_id = str(report.get("report_id") or path.stem)
        verdict = as_map(report.get("todo_verdict"))
        todo_id = str(verdict.get("todo_id") or report.get("active_todo_id") or "")
        facts.tester_snapshots_by_todo.setdefault(todo_id, []).append(report)
        add_tester_verdict_facts(facts, report, report_id, todo_id, rel_path, immutable=True)


def add_tester_verdict_facts(
    facts: TraceabilityFacts,
    report: dict[str, Any],
    report_id: str,
    todo_id: str,
    snapshot_path: str,
    *,
    immutable: bool,
) -> None:
    verdict = as_map(report.get("todo_verdict"))
    if report.get("decision") != "PASS":
        return
    verdict_kind = verdict.get("verdict")
    can_mark_finished = verdict.get("can_mark_finished") is True
    for obligation_id in as_list(verdict.get("verified_obligation_ids", [])):
        if not obligation_id:
            continue
        evidence_id = f"tester:{report_id}:{obligation_id}"
        facts.evidence_for.add((evidence_id, str(obligation_id)))
        if immutable and verdict_kind == "pass" and can_mark_finished:
            facts.tester_verified.add(str(obligation_id))
            facts.tester_pass_evidence.add((todo_id, str(obligation_id), snapshot_path))
    if verdict_kind == "accepted-deviation":
        for obligation_id in as_list(verdict.get("verified_obligation_ids", [])):
            if obligation_id and immutable:
                facts.tester_accepted_deviation.add(str(obligation_id))
                facts.tester_accepted_evidence.add((todo_id, str(obligation_id), snapshot_path))


def infer_todo_covers_from_obligations(facts: TraceabilityFacts) -> None:
    obligations_by_todo: dict[str, set[str]] = {}
    for todo_id, obligation_id in facts.todo_obligations:
        obligations_by_todo.setdefault(todo_id, set()).add(obligation_id)
    behaviors_by_obligation: dict[str, set[str]] = {}
    for behavior_id, obligation_id in facts.behavior_obligations:
        behaviors_by_obligation.setdefault(obligation_id, set()).add(behavior_id)
    for todo_id, obligation_ids in obligations_by_todo.items():
        for obligation_id in obligation_ids:
            for behavior_id in behaviors_by_obligation.get(obligation_id, set()):
                facts.covers.add((todo_id, behavior_id))


def validate_graph_integrity(facts: TraceabilityFacts, issues: list[dict[str, str]]) -> None:
    for todo_id, dep_id in sorted(facts.requires):
        if dep_id not in facts.todos:
            issues.append(error(f"{TRANSLATOR}/migration-todo.yaml", f"requires({todo_id},{dep_id}) references missing todo", "TR-GRAPH-001"))
    for todo_id, behavior_id in sorted(facts.covers):
        if todo_id not in facts.todos:
            issues.append(error(f"{TRANSLATOR}/migration-todo.yaml", f"covers({todo_id},{behavior_id}) references missing todo", "TR-GRAPH-002"))
        if behavior_id not in facts.behaviors:
            issues.append(error(f"{TRANSLATOR}/migration-todo.yaml", f"covers({todo_id},{behavior_id}) references missing behavior", "TR-GRAPH-002"))
    for todo_id, obligation_id in sorted(facts.todo_obligations):
        if todo_id not in facts.todos:
            issues.append(error(f"{TRANSLATOR}/migration-todo.yaml", f"todo_obligation({todo_id},{obligation_id}) references missing todo", "TR-GRAPH-003"))
        if obligation_id not in facts.obligations:
            issues.append(error(f"{TRANSLATOR}/migration-todo.yaml", f"todo_obligation({todo_id},{obligation_id}) references missing obligation", "TR-GRAPH-003"))
    for behavior_id, obligation_id in sorted(facts.behavior_obligations):
        if behavior_id not in facts.behaviors:
            issues.append(error(f"{TRANSLATOR}/translation-ledger.yaml", f"obligation_of({obligation_id},{behavior_id}) references missing behavior", "TR-GRAPH-004"))
        if obligation_id not in facts.obligations:
            issues.append(error(f"{TRANSLATOR}/translation-ledger.yaml", f"obligation_of({obligation_id},{behavior_id}) references missing obligation", "TR-GRAPH-004"))
    validate_dependency_cycles(facts, issues)


def validate_plan_traceability(
    repo: Path, facts: TraceabilityFacts, backlog: Any, ledger: Any, todo: Any, issues: list[dict[str, str]]
) -> None:
    for item in as_list(as_map(backlog).get("planned_slices", [])):
        if not isinstance(item, dict) or item.get("priority") not in P0_P1:
            continue
        if not behavior_ids_from(item):
            issues.append(error(f"{TRANSLATOR}/module-backlog.yaml", f"P0/P1 planned slice {item.get('slice_id')} requires behavior_ids", "TR-PLAN-001"))
    validate_slice_behavior_alignment(facts, backlog, issues)

    for obligation_id, obligation in sorted(facts.obligations.items()):
        if obligation.get("priority") not in P0_P1:
            continue
        if not behavior_ids_from(obligation):
            issues.append(error(f"{TRANSLATOR}/translation-ledger.yaml", f"P0/P1 obligation {obligation_id} requires behavior_ids", "TR-PLAN-002"))

    covered_behaviors = {behavior_id for _, behavior_id in facts.covers}
    behavior_obligations = {}
    for behavior_id, obligation_id in facts.behavior_obligations:
        behavior_obligations.setdefault(behavior_id, set()).add(obligation_id)

    for behavior_id, behavior in sorted(facts.behaviors.items()):
        if behavior_priority(behavior) not in P0_P1:
            continue
        if behavior_id not in covered_behaviors:
            issues.append(error(f"{TRANSLATOR}/migration-todo.yaml", f"P0/P1 behavior {behavior_id} is not covered by any todo", "TR-PLAN-003"))
        if not behavior_obligations.get(behavior_id):
            issues.append(error(f"{TRANSLATOR}/translation-ledger.yaml", f"P0/P1 behavior {behavior_id} has no obligation", "TR-PLAN-004"))

    for todo_id, todo_item in sorted(facts.todos.items()):
        if todo_item.get("priority") not in P0_P1:
            continue
        if not [behavior_id for current_todo, behavior_id in facts.covers if current_todo == todo_id]:
            issues.append(error(f"{TRANSLATOR}/migration-todo.yaml", f"P0/P1 todo {todo_id} covers no behavior", "TR-PLAN-005"))

    validate_source_test_traceability(facts, todo, issues)
    validate_inventory_decision_references(repo, facts, issues)
    validate_inventory_coverage(facts, backlog, ledger, todo, issues)


def validate_slice_behavior_alignment(
    facts: TraceabilityFacts, backlog: Any, issues: list[dict[str, str]]
) -> None:
    for item in as_list(as_map(backlog).get("planned_slices", [])):
        if not isinstance(item, dict) or item.get("priority") not in P0_P1:
            continue
        slice_id = str(item.get("slice_id") or "")
        if not slice_id:
            continue
        slice_todo_ids = {
            todo_id
            for todo_id, todo_item in facts.todos.items()
            if str(as_map(todo_item).get("slice_id") or "") == slice_id
        }
        slice_obligation_ids = {
            obligation_id
            for obligation_id, obligation in facts.obligations.items()
            if str(as_map(obligation).get("slice_id") or "") == slice_id
        }
        for behavior_id in behavior_ids_from(item):
            todo_ids = {
                todo_id
                for todo_id in slice_todo_ids
                if (todo_id, behavior_id) in facts.covers
                or behavior_id in behavior_ids_from(facts.todos.get(todo_id, {}))
            }
            obligation_ids = {
                obligation_id
                for obligation_id in slice_obligation_ids
                if behavior_id in behavior_ids_from(facts.obligations.get(obligation_id, {}))
            }
            if not todo_ids:
                issues.append(
                    error(
                        f"{TRANSLATOR}/migration-todo.yaml",
                        f"P0/P1 slice {slice_id} behavior {behavior_id} has no todo in the same slice",
                        "TR-PLAN-006",
                    )
                )
            if not obligation_ids:
                issues.append(
                    error(
                        f"{TRANSLATOR}/translation-ledger.yaml",
                        f"P0/P1 slice {slice_id} behavior {behavior_id} has no obligation in the same slice",
                        "TR-PLAN-007",
                    )
                )
            if todo_ids and obligation_ids and not any(
                (todo_id, obligation_id) in facts.todo_obligations
                for todo_id in todo_ids
                for obligation_id in obligation_ids
            ):
                issues.append(
                    error(
                        f"{TRANSLATOR}/migration-todo.yaml",
                        f"P0/P1 slice {slice_id} behavior {behavior_id} has no todo linked to its same-slice obligation",
                        "TR-PLAN-008",
                    )
                )


def validate_contract_traceability(
    facts: TraceabilityFacts, ledger: Any, todo: Any, contract: Any, issues: list[dict[str, str]]
) -> None:
    contract_map = as_map(contract)
    if not contract_map:
        return
    active_todo = str(contract_map.get("active_todo_id") or "")
    active_behaviors = {behavior_id for todo_id, behavior_id in facts.covers if todo_id == active_todo}
    claimed = {
        str(item.get("behavior_id")): item
        for item in as_list(contract_map.get("claimed_behaviors", []))
        if isinstance(item, dict) and item.get("behavior_id")
    }
    evidence_by_behavior = {
        str(item.get("behavior_id")): item
        for item in as_list(contract_map.get("tdd_evidence", []))
        if isinstance(item, dict) and item.get("behavior_id")
    }
    for behavior_id, evidence in sorted(evidence_by_behavior.items()):
        validate_tdd_evidence_shape(behavior_id, evidence, issues)
    for behavior_id, behavior in sorted(claimed.items()):
        if not active_behaviors:
            issues.append(error(f"{TRANSLATOR}/migration-todo.yaml", f"active todo {active_todo} has no planned behavior coverage", "TR-CONTRACT-001"))
        elif behavior_id not in active_behaviors:
            issues.append(error(f"{TRANSLATOR}/feature-contract.yaml", f"claimed behavior {behavior_id} is outside active todo {active_todo} covers", "TR-CONTRACT-001"))
        obligation_ids = {str(item) for item in as_list(behavior.get("ledger_obligation_ids", [])) if item}
        if not obligation_ids:
            issues.append(error(f"{TRANSLATOR}/feature-contract.yaml", f"claimed behavior {behavior_id} requires ledger_obligation_ids", "TR-CONTRACT-002"))
        linked = {obligation_id for b_id, obligation_id in facts.behavior_obligations if b_id == behavior_id}
        missing_links = sorted(obligation_ids - linked)
        if missing_links:
            issues.append(error(f"{TRANSLATOR}/translation-ledger.yaml", f"claimed behavior {behavior_id} obligations lack behavior_ids link: {', '.join(missing_links)}", "TR-CONTRACT-003"))
        evidence = evidence_by_behavior.get(behavior_id)
        if not evidence:
            issues.append(error(f"{TRANSLATOR}/feature-contract.yaml", f"claimed behavior {behavior_id} requires tdd_evidence", "TR-CONTRACT-004"))
            continue
        evidence_obligations = {str(item) for item in as_list(evidence.get("ledger_obligation_ids", [])) if item}
        missing_evidence_obligations = sorted(obligation_ids - evidence_obligations)
        if missing_evidence_obligations:
            issues.append(error(f"{TRANSLATOR}/feature-contract.yaml", f"tdd_evidence for {behavior_id} misses obligations: {', '.join(missing_evidence_obligations)}", "TR-CONTRACT-005"))


def validate_closure_traceability(
    repo: Path,
    facts: TraceabilityFacts,
    ledger: Any,
    todo: Any,
    reviewer_report: Any,
    blocked: Any,
    issues: list[dict[str, str]],
) -> None:
    behavior_obligations: dict[str, set[str]] = {}
    for behavior_id, obligation_id in facts.behavior_obligations:
        behavior_obligations.setdefault(behavior_id, set()).add(obligation_id)
    obligation_todos: dict[str, set[str]] = {}
    for todo_id, obligation_id in facts.todo_obligations:
        obligation_todos.setdefault(obligation_id, set()).add(todo_id)
    terminal_report_paths = {
        str(as_map(todo_item.get("tester_gate")).get("report_path") or "")
        for todo_item in facts.todos.values()
        if as_map(todo_item).get("status") in TERMINAL_TODO_STATUSES
    }
    for report_path in sorted(path for path in terminal_report_paths if path):
        if report_path in facts.snapshot_parse_errors:
            issues.append(error(f"{TESTER}/reports", f"terminal tester snapshot cannot be parsed: {report_path}: {facts.snapshot_parse_errors[report_path]}", "TR-CLOSURE-001"))

    for obligation_id, obligation in sorted(facts.obligations.items()):
        validate_terminal_obligation_evidence(repo, facts, obligation_todos, obligation_id, obligation, blocked, issues)

    for behavior_id, behavior in sorted(facts.behaviors.items()):
        if behavior_priority(behavior) not in P0_P1:
            continue
        obligation_ids = behavior_obligations.get(behavior_id, set())
        if not obligation_ids:
            issues.append(error(f"{TRANSLATOR}/translation-ledger.yaml", f"P0/P1 behavior {behavior_id} cannot close without obligations", "TR-CLOSURE-002"))
            continue
        for obligation_id in sorted(obligation_ids):
            obligation = facts.obligations.get(obligation_id, {})
            status = obligation.get("status")
            if status not in TERMINAL_LEDGER_STATUSES:
                issues.append(error(f"{TRANSLATOR}/translation-ledger.yaml", f"P0/P1 behavior {behavior_id} has nonterminal obligation {obligation_id}", "TR-CLOSURE-003"))
            for todo_id in obligation_todos.get(obligation_id, set()):
                todo_status = as_map(facts.todos.get(todo_id)).get("status")
                if todo_status not in TERMINAL_TODO_STATUSES:
                    issues.append(error(f"{TRANSLATOR}/migration-todo.yaml", f"obligation {obligation_id} is covered by nonterminal todo {todo_id}", "TR-CLOSURE-008"))

    completion_kind = as_map(as_map(reviewer_report).get("closure")).get("completion_kind")
    if completion_kind == "complete":
        partial_todos = sorted(
            todo_id
            for todo_id, todo_item in facts.todos.items()
            if as_map(todo_item).get("status") in PARTIAL_STATUSES
        )
        if partial_todos:
            issues.append(error(f"{TRANSLATOR}/migration-todo.yaml", f"complete closure cannot include partial todos: {', '.join(partial_todos)}", "TR-CLOSURE-009"))
        partial_behaviors = sorted(
            behavior_id
            for behavior_id, obligation_ids in behavior_obligations.items()
            if any(as_map(facts.obligations.get(obligation_id)).get("status") in PARTIAL_STATUSES for obligation_id in obligation_ids)
        )
        if partial_behaviors:
            issues.append(error(f"{FINAL_REVIEWER}/reviewer-report.yaml", f"complete closure cannot include partial behaviors: {', '.join(partial_behaviors)}", "TR-CLOSURE-009"))
    if completion_kind == "blocked-partial":
        has_partial = any(as_map(todo_item).get("status") in PARTIAL_STATUSES for todo_item in facts.todos.values()) or any(
            as_map(obligation).get("status") in PARTIAL_STATUSES for obligation in facts.obligations.values()
        )
        if not has_partial:
            issues.append(error(f"{FINAL_REVIEWER}/reviewer-report.yaml", "blocked-partial closure requires at least one blocked or accepted-deviation todo or obligation", "TR-CLOSURE-010"))


def validate_terminal_obligation_evidence(
    repo: Path,
    facts: TraceabilityFacts,
    obligation_todos: dict[str, set[str]],
    obligation_id: str,
    obligation: dict[str, Any],
    blocked: Any,
    issues: list[dict[str, str]],
) -> None:
    status = obligation.get("status")
    if status == "verified" and not has_terminal_tester_pass_evidence(facts, obligation_todos, obligation_id):
        issues.append(error(f"{TRANSLATOR}/translation-ledger.yaml", f"verified obligation {obligation_id} lacks tester evidence", "TR-CLOSURE-004"))
    if status == "blocked":
        for message in blocked_entry_issues(blocked, obligation_id):
            issues.append(error(f"{TRANSLATOR}/blocked-todos.yaml", f"blocked obligation {obligation_id} {message}", "TR-CLOSURE-005"))
    if status == "accepted-deviation" and not has_valid_decision_id_list(obligation.get("decision_ids", [])):
        issues.append(error(f"{TRANSLATOR}/translation-ledger.yaml", f"accepted-deviation obligation {obligation_id} requires non-empty decision_ids list", "TR-CLOSURE-006"))
    if status == "accepted-deviation":
        for message in decision_reference_issues(repo, facts, obligation.get("decision_ids", []), expected_type="accepted-deviation"):
            issues.append(error(f"{TRANSLATOR}/decision-log.yaml", f"accepted-deviation obligation {obligation_id} {message}", "TR-DECISION-001"))
        for message in decision_snapshot_binding_issues(facts, obligation_todos, obligation_id, obligation.get("decision_ids", [])):
            issues.append(error(f"{TRANSLATOR}/decision-log.yaml", f"accepted-deviation obligation {obligation_id} {message}", "TR-DECISION-001"))
    if status == "accepted-deviation" and not has_terminal_tester_accepted_evidence(facts, obligation_todos, obligation_id):
        issues.append(error(f"{TRANSLATOR}/translation-ledger.yaml", f"accepted-deviation obligation {obligation_id} lacks tester accepted-deviation evidence", "TR-CLOSURE-007"))


def validate_source_test_traceability(facts: TraceabilityFacts, todo: Any, issues: list[dict[str, str]]) -> None:
    obligations_by_todo: dict[str, list[dict[str, Any]]] = {}
    for todo_id, obligation_id in facts.todo_obligations:
        obligation = facts.obligations.get(obligation_id)
        if obligation:
            obligations_by_todo.setdefault(todo_id, []).append(obligation)
    for todo_id, obligations in obligations_by_todo.items():
        if not any(obligation.get("kind") == "source-test" for obligation in obligations):
            continue
        todo_item = facts.todos.get(todo_id, {})
        if not as_list(todo_item.get("source_test_ids", [])):
            issues.append(error(f"{TRANSLATOR}/migration-todo.yaml", f"todo {todo_id} covers source-test obligations but has empty source_test_ids", "TR-SOURCE-001"))


def validate_inventory_coverage(
    facts: TraceabilityFacts, backlog: Any, ledger: Any, todo: Any, issues: list[dict[str, str]]
) -> None:
    todo_source_tests = {
        str(value)
        for item in facts.todos.values()
        for value in as_list(as_map(item).get("source_test_ids", []))
        if value
    }
    obligation_source_tests = {
        str(value)
        for obligation in facts.obligations.values()
        for value in as_list(as_map(obligation).get("source_test_ids", []))
        if value
    }
    todo_public_apis = {
        str(value)
        for item in facts.todos.values()
        for value in as_list(as_map(item).get("public_api_ids", []))
        if value
    }
    planned_source_modules = {
        str(value)
        for item in as_list(as_map(backlog).get("planned_slices", []))
        for value in as_list(as_map(item).get("source_modules", []))
        if value
    }
    obligation_module_ids = {
        str(as_map(obligation).get("module_id") or "")
        for obligation in facts.obligations.values()
        if as_map(obligation).get("module_id")
    }

    for test_id, test in sorted(facts.source_tests.items()):
        source_ref = str(as_map(test).get("source_ref") or "")
        if inventory_item_decided(test):
            continue
        if (
            test_id in todo_source_tests
            or test_id in obligation_source_tests
            or any(obligation_matches_inventory(obligation, test_id, source_ref, "source-test") for obligation in facts.obligations.values())
        ):
            continue
        issues.append(
            error(
                f"{TRANSLATOR}/module-backlog.yaml",
                f"source test {test_id} is not mapped to any todo, source-test obligation, or supported scope/block/deviation decision",
                "TR-COVERAGE-001",
            )
        )

    for api_id, api in sorted(facts.public_apis.items()):
        api_map = as_map(api)
        if api_map.get("priority") not in P0_P1:
            continue
        source_ref = str(api_map.get("source_ref") or "")
        if inventory_item_decided(api_map):
            continue
        if (
            api_id in todo_public_apis
            or any(obligation_matches_inventory(obligation, api_id, source_ref, "public-api") for obligation in facts.obligations.values())
        ):
            continue
        issues.append(
            error(
                f"{TRANSLATOR}/module-backlog.yaml",
                f"P0/P1 public API {api_id} is not mapped to any todo, public-api obligation, or supported scope/block/deviation decision",
                "TR-COVERAGE-002",
            )
        )

    for entry_id, entry in sorted(facts.runtime_entries.items()):
        entry_map = as_map(entry.get("entry")) if isinstance(entry, dict) else {}
        entry_ref = inventory_ref(entry_map) or entry_id
        if inventory_item_decided(entry_map):
            continue
        if any(obligation_matches_inventory(obligation, entry_id, entry_ref, "runtime-entry") for obligation in facts.obligations.values()):
            continue
        issues.append(
            error(
                f"{TRANSLATOR}/module-backlog.yaml",
                f"runtime entry {entry_id} is not mapped to any runtime-entry obligation or supported scope/block/deviation decision",
                "TR-COVERAGE-003",
            )
        )

    for module_id, module in sorted(facts.runtime_modules.items()):
        module_map = as_map(module)
        source_paths = {str(value) for value in as_list(module_map.get("source_paths", [])) if value}
        if inventory_item_decided(module_map) or module_map.get("classification") == "blocked":
            continue
        if module_id in obligation_module_ids or module_id in planned_source_modules or source_paths.intersection(planned_source_modules):
            continue
        issues.append(
            error(
                f"{TRANSLATOR}/module-backlog.yaml",
                f"runtime-critical module {module_id} is not mapped to any obligation, planned slice, or supported scope/block/deviation decision",
                "TR-COVERAGE-004",
            )
        )

    for boundary_id, boundary in sorted(facts.dependency_boundaries.items()):
        boundary_map = as_map(boundary)
        boundary_ref = inventory_ref(boundary_map) or boundary_id
        if inventory_item_decided(boundary_map):
            continue
        if any(obligation_matches_inventory(obligation, boundary_id, boundary_ref, "dependency-boundary") for obligation in facts.obligations.values()):
            continue
        issues.append(
            error(
                f"{TRANSLATOR}/module-backlog.yaml",
                f"dependency boundary {boundary_id} is not mapped to any dependency-boundary obligation or supported scope/block/deviation decision",
                "TR-COVERAGE-005",
            )
        )


def validate_dependency_cycles(facts: TraceabilityFacts, issues: list[dict[str, str]]) -> None:
    graph: dict[str, list[str]] = {}
    for todo_id, dep_id in facts.requires:
        graph.setdefault(todo_id, []).append(dep_id)

    visiting: set[str] = set()
    visited: set[str] = set()
    path: list[str] = []

    def walk(node: str) -> bool:
        if node in visiting:
            try:
                cycle = path[path.index(node) :] + [node]
            except ValueError:
                cycle = path + [node]
            issues.append(error(f"{TRANSLATOR}/migration-todo.yaml", "todo dependency cycle: " + " -> ".join(cycle), "TR-GRAPH-005"))
            return True
        if node in visited:
            return False
        visiting.add(node)
        path.append(node)
        for dep in graph.get(node, []):
            if walk(dep):
                return True
        path.pop()
        visiting.remove(node)
        visited.add(node)
        return False

    for todo_id in sorted(graph):
        if walk(todo_id):
            return


def validate_tdd_evidence_shape(
    behavior_id: str, evidence: dict[str, Any], issues: list[dict[str, str]]
) -> None:
    required = {
        "red": ("command", "result", "failure_proves"),
        "green": ("command", "result"),
        "smoke": ("command", "result"),
    }
    for phase, keys in required.items():
        block = as_map(evidence.get(phase))
        missing = [key for key in keys if not str(block.get(key) or "").strip()]
        if missing:
            issues.append(error(f"{TRANSLATOR}/feature-contract.yaml", f"tdd_evidence {behavior_id}.{phase} missing: {', '.join(missing)}", "TR-CONTRACT-006"))
    refactor = as_map(evidence.get("refactor"))
    if not any(str(refactor.get(key) or "").strip() for key in ("command", "result", "note")):
        issues.append(error(f"{TRANSLATOR}/feature-contract.yaml", f"tdd_evidence {behavior_id}.refactor requires command/result or note", "TR-CONTRACT-006"))


def blocked_entry_issues(blocked: Any, obligation_id: str) -> list[str]:
    for item in as_list(as_map(blocked).get("blocked", as_map(blocked).get("blocked_todos", []))):
        if not isinstance(item, dict):
            continue
        if obligation_id in {str(ref) for ref in as_list(item.get("ledger_obligation_ids", []))}:
            issues: list[str] = []
            if not str(item.get("reason") or "").strip():
                issues.append("lacks blocked reason")
            if not as_list(item.get("evidence", [])):
                issues.append("lacks blocked evidence")
            if not str(item.get("recovery_condition") or "").strip():
                issues.append("lacks recovery_condition")
            if not as_list(item.get("commands_attempted", [])):
                issues.append("lacks commands_attempted")
            return issues
    return ["lacks blocked-todos entry"]


def has_terminal_tester_pass_evidence(
    facts: TraceabilityFacts, obligation_todos: dict[str, set[str]], obligation_id: str
) -> bool:
    for todo_id in obligation_todos.get(obligation_id, set()):
        todo_item = as_map(facts.todos.get(todo_id))
        if todo_item.get("status") != "finished":
            continue
        report_path = str(as_map(todo_item.get("tester_gate")).get("report_path") or "")
        if (todo_id, obligation_id, report_path) in facts.tester_pass_evidence:
            return True
    return False


def has_terminal_tester_accepted_evidence(
    facts: TraceabilityFacts, obligation_todos: dict[str, set[str]], obligation_id: str
) -> bool:
    for todo_id in obligation_todos.get(obligation_id, set()):
        todo_item = as_map(facts.todos.get(todo_id))
        if todo_item.get("status") != "accepted-deviation":
            continue
        report_path = str(as_map(todo_item.get("tester_gate")).get("report_path") or "")
        if (todo_id, obligation_id, report_path) in facts.tester_accepted_evidence:
            return True
    return False


def register_behavior(
    facts: TraceabilityFacts,
    behavior_id: str,
    *,
    source: str,
    priority: str,
    slice_id: str,
    source_refs: list[Any],
) -> None:
    if not behavior_id:
        return
    item = facts.behaviors.setdefault(
        behavior_id,
        {
            "behavior_id": behavior_id,
            "sources": [],
            "priorities": [],
            "slice_ids": [],
            "source_refs": [],
        },
    )
    item["sources"].append(source)
    if priority:
        item["priorities"].append(priority)
    if slice_id:
        item["slice_ids"].append(slice_id)
    item["source_refs"].extend(str(ref) for ref in source_refs if ref)


def behavior_ids_from(item: Any) -> list[str]:
    if not isinstance(item, dict):
        return []
    values: list[Any] = []
    if item.get("behavior_id"):
        values.append(item.get("behavior_id"))
    values.extend(as_list(item.get("behavior_ids", [])))
    return sorted({str(value) for value in values if str(value or "").strip()})


def runtime_entry_id(group_name: str, entry: Any, index: int) -> str:
    if isinstance(entry, dict):
        for key in ("entry_id", "runtime_entry_id", "id", "name", "source_ref", "command", "path"):
            value = entry.get(key)
            if value:
                return str(value)
        return f"{group_name}:{index}"
    if entry:
        return str(entry)
    return ""


def dependency_boundary_id(boundary: Any, index: int) -> str:
    if isinstance(boundary, dict):
        for key in ("boundary_id", "dependency_id", "id", "name", "source_ref", "coord", "package"):
            value = boundary.get(key)
            if value:
                return str(value)
        return f"external_boundary:{index}"
    if boundary:
        return str(boundary)
    return ""


def inventory_ref(item: dict[str, Any]) -> str:
    for key in ("source_ref", "signature", "name", "entry_id", "api_id", "test_id", "module_id", "boundary_id"):
        value = item.get(key)
        if value:
            return str(value)
    return ""


def remember_decided_item(facts: TraceabilityFacts, item_id: str, item: Any) -> None:
    if item_id:
        facts.decided_items.add(item_id)
    ref = inventory_ref(as_map(item))
    if ref:
        facts.decided_items.add(ref)


def remember_inventory_decisions(facts: TraceabilityFacts, item_id: str, item: Any) -> None:
    if not item_id:
        return
    for decision_id in inventory_decision_refs(item):
        facts.inventory_decisions.add((item_id, decision_id))


def inventory_decision_refs(item: Any) -> list[str]:
    item_map = as_map(item)
    refs: list[str] = []
    refs.extend(non_empty_string_values(item_map.get("scope_decision_id")))
    refs.extend(non_empty_string_values(item_map.get("scope_decision_ids", [])))
    decision = as_map(item_map.get("decision"))
    decision_type = str(decision.get("type") or decision.get("Type") or item_map.get("decision_type") or item_map.get("decision_kind") or "")
    if decision_type in {"scope", "blocked", "accepted-deviation"}:
        for value in (item_map.get("decision_id"), decision.get("id"), decision.get("decision_id")):
            refs.extend(non_empty_string_values(value))
        refs.extend(non_empty_string_values(item_map.get("decision_ids", [])))
    return sorted(set(refs))


def inventory_item_decided(item: Any) -> bool:
    item_map = as_map(item)
    status = str(
        item_map.get("coverage_status")
        or item_map.get("scope")
        or ""
    )
    decision = as_map(item_map.get("decision"))
    decision_type = str(decision.get("type") or decision.get("Type") or item_map.get("decision_type") or item_map.get("decision_kind") or "")
    typed_scope_decision = decision_type in {"scope", "blocked", "accepted-deviation"}
    has_scope_decision_ref = has_non_empty_value(item_map.get("scope_decision_id")) or bool(non_empty_string_values(item_map.get("scope_decision_ids", [])))
    has_typed_decision_ref = (
        has_non_empty_value(item_map.get("decision_id"))
        or bool(non_empty_string_values(item_map.get("decision_ids", [])))
        or has_non_empty_value(decision.get("id"))
        or has_non_empty_value(decision.get("decision_id"))
    )
    has_supported_ref = has_scope_decision_ref or (typed_scope_decision and has_typed_decision_ref)
    has_support = inventory_decision_has_support(item_map)
    if status in {"blocked", "accepted-deviation", "out-of-scope", "excluded"} and has_support and has_supported_ref:
        return True
    if has_scope_decision_ref and has_support:
        return True
    if typed_scope_decision and has_typed_decision_ref and has_support:
        return True
    return False


def validate_inventory_decision_references(repo: Path, facts: TraceabilityFacts, issues: list[dict[str, str]]) -> None:
    for item_id, decision_id in sorted(facts.inventory_decisions):
        for message in inventory_decision_reference_issues(repo, facts, decision_id):
            issues.append(error(f"{TRANSLATOR}/decision-log.yaml", f"inventory item {item_id} {message}", "TR-DECISION-002"))


def inventory_decision_reference_issues(repo: Path, facts: TraceabilityFacts, decision_id: str) -> list[str]:
    decision = facts.decisions.get(decision_id)
    if not decision:
        return [f"references missing decision {decision_id}"]
    messages: list[str] = []
    decision_type = str(decision.get("type") or "")
    if decision_type not in {"scope", "blocked", "accepted-deviation"}:
        messages.append(f"decision {decision_id} has type={decision_type}; allowed=['accepted-deviation', 'blocked', 'scope']")
    if decision.get("status") != "accepted":
        messages.append(f"decision {decision_id} must have status=accepted")
    for key in ("scope", "impact", "follow_up"):
        if not has_structured_content(decision.get(key)):
            messages.append(f"decision {decision_id} requires {key}")
    if not any(has_structured_content(item) for item in as_list(decision.get("evidence", []))):
        messages.append(f"decision {decision_id} requires non-empty evidence")
    tester_report_path = str(decision.get("tester_report_path") or "")
    if decision_type == "accepted-deviation":
        if not tester_report_path:
            messages.append(f"decision {decision_id} requires tester_report_path")
        elif not is_tester_report_snapshot(tester_report_path):
            messages.append(f"decision {decision_id} tester_report_path must be an immutable tester report snapshot")
        elif not (repo / tester_report_path).is_file():
            messages.append(f"decision {decision_id} tester_report_path does not exist: {tester_report_path}")
    return messages


def inventory_decision_has_support(item_map: dict[str, Any]) -> bool:
    for key in ("blocked_reason", "reason", "scope_reason", "rationale", "justification", "note"):
        if str(item_map.get(key) or "").strip():
            return True
    if any(value for value in as_list(item_map.get("evidence", []))):
        return True
    decision = as_map(item_map.get("decision"))
    if decision:
        for key in ("reason", "rationale", "justification", "note", "evidence"):
            value = decision.get(key)
            if isinstance(value, list) and any(item for item in value):
                return True
            if str(value or "").strip():
                return True
    return False


def has_non_empty_value(value: Any) -> bool:
    return isinstance(value, str) and bool(value.strip())


def non_empty_string_values(value: Any) -> list[str]:
    if isinstance(value, str):
        return [value.strip()] if value.strip() else []
    return [item.strip() for item in as_list(value) if isinstance(item, str) and item.strip()]


def has_valid_decision_id_list(value: Any) -> bool:
    items = as_list(value)
    return bool(items) and all(isinstance(item, str) and item.strip() for item in items)


def decision_reference_issues(repo: Path, facts: TraceabilityFacts, decision_ids: Any, *, expected_type: str) -> list[str]:
    issues: list[str] = []
    ids = [item.strip() for item in as_list(decision_ids) if isinstance(item, str) and item.strip()]
    for decision_id in ids:
        decision = facts.decisions.get(decision_id)
        if not decision:
            issues.append(f"references missing decision {decision_id}")
            continue
        if decision.get("type") != expected_type:
            issues.append(f"decision {decision_id} has type={decision.get('type')}; expected {expected_type}")
        if decision.get("status") != "accepted":
            issues.append(f"decision {decision_id} must have status=accepted")
        for key in ("scope", "impact", "follow_up"):
            if not has_structured_content(decision.get(key)):
                issues.append(f"decision {decision_id} requires {key}")
        if not any(has_structured_content(item) for item in as_list(decision.get("evidence", []))):
            issues.append(f"decision {decision_id} requires non-empty evidence")
        tester_report_path = str(decision.get("tester_report_path") or "")
        if expected_type == "accepted-deviation":
            if not tester_report_path:
                issues.append(f"decision {decision_id} requires tester_report_path")
            elif not is_tester_report_snapshot(tester_report_path):
                issues.append(f"decision {decision_id} tester_report_path must be an immutable tester report snapshot")
            elif not (repo / tester_report_path).is_file():
                issues.append(f"decision {decision_id} tester_report_path does not exist: {tester_report_path}")
    return issues


def decision_snapshot_binding_issues(
    facts: TraceabilityFacts,
    obligation_todos: dict[str, set[str]],
    obligation_id: str,
    decision_ids: Any,
) -> list[str]:
    issues: list[str] = []
    accepted_snapshots: set[str] = set()
    for todo_id in obligation_todos.get(obligation_id, set()):
        todo_item = as_map(facts.todos.get(todo_id))
        if todo_item.get("status") != "accepted-deviation":
            continue
        snapshot_path = str(as_map(todo_item.get("tester_gate")).get("report_path") or "")
        if snapshot_path and (todo_id, obligation_id, snapshot_path) in facts.tester_accepted_evidence:
            accepted_snapshots.add(snapshot_path)
    if not accepted_snapshots:
        return issues
    ids = [item.strip() for item in as_list(decision_ids) if isinstance(item, str) and item.strip()]
    for decision_id in ids:
        decision = facts.decisions.get(decision_id)
        if not decision or decision.get("type") != "accepted-deviation":
            continue
        tester_report_path = str(decision.get("tester_report_path") or "")
        if tester_report_path and tester_report_path not in accepted_snapshots:
            issues.append(
                "decision "
                f"{decision_id} tester_report_path {tester_report_path} "
                f"does not match tester accepted-deviation evidence snapshots: {', '.join(sorted(accepted_snapshots))}"
            )
    return issues


def has_structured_content(value: Any) -> bool:
    if isinstance(value, str):
        return bool(value.strip())
    if isinstance(value, list):
        return any(has_structured_content(item) for item in value)
    if isinstance(value, dict):
        return any(has_structured_content(item) for item in value.values())
    return False


def is_tester_report_snapshot(path: str) -> bool:
    return is_safe_relative_path(path) and path.startswith(f"{TESTER}/reports/") and path.endswith(".yaml")


def is_safe_relative_path(path: str) -> bool:
    if not path or Path(path).is_absolute():
        return False
    return ".." not in Path(path).parts


def obligation_matches_inventory(obligation: Any, inventory_id: str, source_ref: str, required_kind: str) -> bool:
    obligation_map = as_map(obligation)
    if obligation_map.get("kind") != required_kind:
        return False
    haystack = {str(obligation_map.get("source_ref") or "")}
    if required_kind == "source-test":
        haystack.update(str(value) for value in as_list(obligation_map.get("source_test_ids", [])) if value)
    needle_values = {inventory_id}
    if source_ref:
        needle_values.add(source_ref)
    return any(value and value in haystack for value in needle_values)


def tdd_evidence_shape_ok(evidence: dict[str, Any]) -> bool:
    required = {
        "red": ("command", "result", "failure_proves"),
        "green": ("command", "result"),
        "smoke": ("command", "result"),
    }
    for phase, keys in required.items():
        block = as_map(evidence.get(phase))
        if any(not str(block.get(key) or "").strip() for key in keys):
            return False
    refactor = as_map(evidence.get("refactor"))
    return any(str(refactor.get(key) or "").strip() for key in ("command", "result", "note"))


def behavior_priority(behavior: dict[str, Any]) -> str:
    priorities = [priority for priority in behavior.get("priorities", []) if priority]
    if "P0" in priorities:
        return "P0"
    if "P1" in priorities:
        return "P1"
    if "P2" in priorities:
        return "P2"
    if "P3" in priorities:
        return "P3"
    return ""


def export_predicates(facts: TraceabilityFacts) -> str:
    lines: list[str] = []
    for behavior_id, behavior in sorted(facts.behaviors.items()):
        lines.append(f"behavior({atom(behavior_id)}).")
        if behavior_priority(behavior) in P0_P1:
            lines.append(f"p0_p1_behavior({atom(behavior_id)}).")
    for todo_id, todo_item in sorted(facts.todos.items()):
        lines.append(f"todo({atom(todo_id)}).")
        if as_map(todo_item).get("priority") in P0_P1:
            lines.append(f"p0_p1_todo({atom(todo_id)}).")
        status = str(as_map(todo_item).get("status") or "")
        if status in TERMINAL_TODO_STATUSES:
            lines.append(f"todo_terminal({atom(todo_id)}).")
        if status == "finished":
            lines.append(f"todo_finished({atom(todo_id)}).")
        if status == "blocked":
            lines.append(f"todo_blocked({atom(todo_id)}).")
        if status == "accepted-deviation":
            lines.append(f"todo_accepted_deviation({atom(todo_id)}).")
        report_path = str(as_map(as_map(todo_item).get("tester_gate")).get("report_path") or "")
        if report_path:
            lines.append(f"todo_tester_snapshot({atom(todo_id)},{atom(report_path)}).")
        for test_id in as_list(as_map(todo_item).get("source_test_ids", [])):
            if test_id:
                lines.append(f"todo_source_test({atom(todo_id)},{atom(str(test_id))}).")
        for api_id in as_list(as_map(todo_item).get("public_api_ids", [])):
            if api_id:
                lines.append(f"todo_public_api({atom(todo_id)},{atom(str(api_id))}).")
    for obligation_id, obligation in sorted(facts.obligations.items()):
        lines.append(f"obligation({atom(obligation_id)}).")
        if as_map(obligation).get("priority") in P0_P1:
            lines.append(f"p0_p1_obligation({atom(obligation_id)}).")
        status = str(as_map(obligation).get("status") or "")
        if status in TERMINAL_LEDGER_STATUSES:
            lines.append(f"ledger_terminal({atom(obligation_id)}).")
        if status == "verified":
            lines.append(f"ledger_verified({atom(obligation_id)}).")
        if status == "blocked":
            lines.append(f"ledger_blocked({atom(obligation_id)}).")
        if status == "accepted-deviation":
            lines.append(f"ledger_accepted_deviation({atom(obligation_id)}).")
            if has_valid_decision_id_list(as_map(obligation).get("decision_ids", [])):
                lines.append(f"accepted_deviation_has_decision({atom(obligation_id)}).")
        kind = str(as_map(obligation).get("kind") or "")
        if kind:
            lines.append(f"obligation_kind({atom(obligation_id)},{atom(kind)}).")
        source_ref = str(as_map(obligation).get("source_ref") or "")
        if source_ref:
            lines.append(f"obligation_source_ref({atom(obligation_id)},{atom(source_ref)}).")
        module_id = str(as_map(obligation).get("module_id") or "")
        if module_id:
            lines.append(f"obligation_module({atom(obligation_id)},{atom(module_id)}).")
        for test_id in as_list(as_map(obligation).get("source_test_ids", [])):
            if test_id:
                lines.append(f"obligation_source_test({atom(obligation_id)},{atom(str(test_id))}).")
        for decision_id in as_list(as_map(obligation).get("decision_ids", [])):
            if isinstance(decision_id, str) and decision_id.strip():
                lines.append(f"obligation_decision({atom(obligation_id)},{atom(decision_id.strip())}).")
    for decision_id, decision in sorted(facts.decisions.items()):
        lines.append(f"decision({atom(decision_id)}).")
        decision_type = str(as_map(decision).get("type") or "")
        decision_status = str(as_map(decision).get("status") or "")
        if decision_type:
            lines.append(f"decision_type({atom(decision_id)},{atom(decision_type)}).")
        if decision_status:
            lines.append(f"decision_status({atom(decision_id)},{atom(decision_status)}).")
    for item_id, decision_id in sorted(facts.inventory_decisions):
        lines.append(f"inventory_decision({atom(item_id)},{atom(decision_id)}).")
    for test_id in sorted(facts.source_tests):
        lines.append(f"source_test({atom(test_id)}).")
        source_ref = inventory_ref(as_map(facts.source_tests.get(test_id)))
        if source_ref and source_ref != test_id:
            lines.append(f"source_test_ref({atom(test_id)},{atom(source_ref)}).")
    for api_id, api in sorted(facts.public_apis.items()):
        lines.append(f"public_api({atom(api_id)}).")
        source_ref = inventory_ref(as_map(api))
        if source_ref and source_ref != api_id:
            lines.append(f"public_api_ref({atom(api_id)},{atom(source_ref)}).")
        if as_map(api).get("priority") in P0_P1:
            lines.append(f"p0_p1_public_api({atom(api_id)}).")
    for entry_id in sorted(facts.runtime_entries):
        lines.append(f"runtime_entry({atom(entry_id)}).")
        entry_map = as_map(as_map(facts.runtime_entries.get(entry_id)).get("entry"))
        entry_ref = inventory_ref(entry_map)
        if entry_ref and entry_ref != entry_id:
            lines.append(f"runtime_entry_ref({atom(entry_id)},{atom(entry_ref)}).")
    for module_id, module in sorted(facts.runtime_modules.items()):
        lines.append(f"runtime_critical_module({atom(module_id)}).")
        for source_path in as_list(as_map(module).get("source_paths", [])):
            if source_path:
                lines.append(f"runtime_module_path({atom(module_id)},{atom(str(source_path))}).")
    for boundary_id, boundary in sorted(facts.dependency_boundaries.items()):
        lines.append(f"dependency_boundary({atom(boundary_id)}).")
        boundary_ref = inventory_ref(as_map(boundary))
        if boundary_ref and boundary_ref != boundary_id:
            lines.append(f"dependency_boundary_ref({atom(boundary_id)},{atom(boundary_ref)}).")
    for module_id in sorted(facts.planned_runtime_modules):
        lines.append(f"planned_runtime_module({atom(module_id)}).")
    for item_id in sorted(facts.decided_items):
        lines.append(f"decided({atom(item_id)}).")
    for todo_id, behavior_id in sorted(facts.covers):
        lines.append(f"covers({atom(todo_id)},{atom(behavior_id)}).")
    for todo_id, behavior_id in sorted(facts.contract_covers):
        lines.append(f"contract_covers({atom(todo_id)},{atom(behavior_id)}).")
    for todo_id, dep_id in sorted(facts.requires):
        lines.append(f"requires({atom(todo_id)},{atom(dep_id)}).")
    for todo_id, obligation_id in sorted(facts.todo_obligations):
        lines.append(f"todo_obligation({atom(todo_id)},{atom(obligation_id)}).")
    for behavior_id, obligation_id in sorted(facts.behavior_obligations):
        lines.append(f"obligation_of({atom(obligation_id)},{atom(behavior_id)}).")
    for behavior_id, obligation_id in sorted(facts.contract_behavior_obligations):
        lines.append(f"contract_obligation({atom(behavior_id)},{atom(obligation_id)}).")
    for behavior_id in sorted(facts.contract_tdd_behaviors):
        lines.append(f"contract_has_tdd({atom(behavior_id)}).")
    for behavior_id in sorted(facts.contract_tdd_shape_ok):
        lines.append(f"contract_tdd_shape_ok({atom(behavior_id)}).")
    contract_evidence_for = {
        (behavior_id, obligation_id)
        for evidence_id, behavior_id in facts.proves
        if evidence_id.startswith("contract:")
        for current_evidence_id, obligation_id in facts.evidence_for
        if current_evidence_id == evidence_id
    }
    for behavior_id, obligation_id in sorted(contract_evidence_for):
        lines.append(f"contract_evidence_for({atom(behavior_id)},{atom(obligation_id)}).")
    for evidence_id, obligation_id in sorted(facts.evidence_for):
        lines.append(f"evidence({atom(evidence_id)}).")
        lines.append(f"evidence_for({atom(evidence_id)},{atom(obligation_id)}).")
    for evidence_id, behavior_id in sorted(facts.proves):
        lines.append(f"proves({atom(evidence_id)},{atom(behavior_id)}).")
    for todo_id, obligation_id, snapshot_path in sorted(facts.tester_pass_evidence):
        lines.append(f"tester_pass_evidence({atom(todo_id)},{atom(obligation_id)},{atom(snapshot_path)}).")
    for todo_id, obligation_id, snapshot_path in sorted(facts.tester_accepted_evidence):
        lines.append(f"tester_accepted_evidence({atom(todo_id)},{atom(obligation_id)},{atom(snapshot_path)}).")
    for obligation_id in sorted(facts.blocked_entry_complete):
        lines.append(f"blocked_entry_complete({atom(obligation_id)}).")
    if facts.closure_kind:
        lines.append(f"closure_kind({atom(facts.closure_kind)}).")
    return "\n".join(lines) + ("\n" if lines else "")


def write_formal_artifacts(repo: Path, phase: str, facts: TraceabilityFacts, issues: list[dict[str, str]]) -> None:
    formal_dir = repo / FORMAL
    facts_dir = formal_dir / "facts"
    violations_dir = formal_dir / "violations"
    certs_dir = formal_dir / "certificates"
    for directory in (facts_dir, violations_dir, certs_dir):
        directory.mkdir(parents=True, exist_ok=True)

    phase_name = artifact_phase_name(phase)
    facts_rel = f"{FORMAL}/facts/{phase_name}.facts"
    violations_rel = f"{FORMAL}/violations/{phase_name}.json"
    certificate_rel = f"{FORMAL}/certificates/{phase_name}.json"

    errors = [issue for issue in issues if issue.get("severity") == "error"]
    facts_text = export_predicates(facts)
    violations_payload = {
        "schema_version": 1,
        "phase": phase,
        "ok": not errors,
        "violation_count": len(errors),
        "violations": issues,
    }
    certificate_payload = {
        "schema_version": 1,
        "kind": "datalog-style-traceability-certificate",
        "scope": "traceability-subgate",
        "phase": phase,
        "ok": not errors,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "checker": {
            "path": "scripts/traceability_guard.py",
            "sha256": sha256_file(Path(__file__).resolve()),
        },
        "rules": {
            "path": "rules/traceability.dl",
            "sha256": sha256_file(RULES_FILE) if RULES_FILE.is_file() else "",
        },
        "inputs": collect_input_hashes(repo, phase),
        "artifacts": {
            "facts": facts_rel,
            "violations": violations_rel,
            "certificate": certificate_rel,
        },
        "evaluated_rule_ids": collect_rule_ids_from_rules(),
        "failed_rule_ids": sorted({str(issue.get("rule_id") or "TR-UNCLASSIFIED") for issue in issues}),
        "violation_count": len(errors),
    }

    (repo / facts_rel).write_text(facts_text, encoding="utf-8")
    (repo / violations_rel).write_text(json.dumps(violations_payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    (repo / certificate_rel).write_text(json.dumps(certificate_payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def artifact_phase_name(phase: str) -> str:
    return "".join(ch if ch.isalnum() or ch in {"-", "_"} else "_" for ch in phase)


def collect_input_hashes(repo: Path, phase: str) -> dict[str, dict[str, Any]]:
    rels = [
        f"{TRANSLATOR}/module-backlog.yaml",
        f"{TRANSLATOR}/decision-log.yaml",
        f"{TRANSLATOR}/migration-todo.yaml",
        f"{TRANSLATOR}/translation-ledger.yaml",
        f"{TESTER}/tester-report.yaml",
        f"{TRANSLATOR}/blocked-todos.yaml",
        f"{FINAL_REVIEWER}/reviewer-report.yaml",
        f"{FORMAL}/gate-history.jsonl",
        f"{FORMAL}/gate-history.head.json",
    ]
    if phase in {"contract", "tester", "all"}:
        rels.append(f"{TRANSLATOR}/feature-contract.yaml")
    reports_dir = repo / TESTER / "reports"
    if reports_dir.is_dir():
        rels.extend(path.relative_to(repo).as_posix() for path in sorted(reports_dir.glob("*.yaml")))
    out: dict[str, dict[str, Any]] = {}
    for rel in sorted(set(rels)):
        path = repo / rel
        out[rel] = {
            "exists": path.is_file(),
            "sha256": sha256_file(path) if path.is_file() else "",
        }
    return out


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def collect_rule_ids_from_rules() -> list[str]:
    if not RULES_FILE.is_file():
        return []
    return sorted(set(re.findall(r"TR-[A-Z]+-[0-9]+", RULES_FILE.read_text(encoding="utf-8"))))


def collect_rule_ids_from_python() -> list[str]:
    source = Path(__file__).read_text(encoding="utf-8")
    return sorted(set(re.findall(r"TR-[A-Z]+-[0-9]+", source)) - {"TR-UNCLASSIFIED"})


def validate_rule_contract_alignment(issues: list[dict[str, str]]) -> None:
    rules_ids = set(collect_rule_ids_from_rules())
    python_ids = set(collect_rule_ids_from_python())
    missing = sorted(python_ids - rules_ids)
    if missing:
        issues.append(
            error(
                "rules/traceability.dl",
                "Python evaluator emits rule IDs missing from rule contract: " + ", ".join(missing),
                "TR-CERT-003",
            )
        )


def atom(value: str) -> str:
    if value and (value[0].islower() or value[0] == "_") and all(ch.isalnum() or ch == "_" for ch in value):
        return value
    return json.dumps(value, ensure_ascii=False)


def normalize_phase(phase: str) -> str:
    aliases = {
        "plan_accepted": "plan-accepted",
        "closure_ready": "closure-ready",
        "reviewer-ready": "closure-ready",
        "reviewer": "reviewed",
        "final": "delivery",
    }
    return aliases.get(phase, phase)


def load_yaml(path: Path) -> Any:
    raw = path.read_text(encoding="utf-8")
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        pass
    ruby = (
        "require 'yaml'; require 'json'; "
        "obj = YAML.respond_to?(:unsafe_load_file) ? YAML.unsafe_load_file(ARGV[0]) : YAML.load_file(ARGV[0]); "
        "puts JSON.generate(obj)"
    )
    result = subprocess.run(["ruby", "-e", ruby, str(path)], text=True, capture_output=True)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "ruby YAML parser failed")
    return json.loads(result.stdout or "null")


def load_optional(repo: Path, rel: str, issues: list[dict[str, str]] | None = None) -> Any:
    path = repo / rel
    if not path.exists() or path.suffix not in {".yaml", ".yml", ".json"}:
        return None
    try:
        return load_yaml(path)
    except Exception as exc:
        if issues is not None:
            issues.append(error(rel, f"cannot parse YAML/JSON: {exc}", "TR-LOAD-001"))
            return None
        raise


def as_map(value: Any) -> dict[str, Any]:
    return value if isinstance(value, dict) else {}


def as_list(value: Any) -> list[Any]:
    return value if isinstance(value, list) else []


def error(file: str, message: str, rule_id: str = "TR-UNCLASSIFIED") -> dict[str, str]:
    return {"severity": "error", "file": file, "message": message, "rule_id": rule_id}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Validate derived traceability facts.")
    parser.add_argument("target_repo")
    parser.add_argument("--phase", default="all")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--facts", action="store_true", help="Print derived Prolog-style facts")
    args = parser.parse_args(argv)

    repo = Path(args.target_repo).expanduser().resolve()
    if not repo.is_dir():
        issues = [error("repo", f"target repo does not exist: {repo}", "TR-CLI-001")]
        return emit(args, issues)

    load_issues: list[dict[str, str]] = []
    backlog = load_optional(repo, f"{TRANSLATOR}/module-backlog.yaml", load_issues)
    decision_log = load_optional(repo, f"{TRANSLATOR}/decision-log.yaml", load_issues)
    ledger = load_optional(repo, f"{TRANSLATOR}/translation-ledger.yaml", load_issues)
    todo = load_optional(repo, f"{TRANSLATOR}/migration-todo.yaml", load_issues)
    contract = load_optional(repo, f"{TRANSLATOR}/feature-contract.yaml", load_issues)
    tester_report = load_optional(repo, f"{TESTER}/tester-report.yaml", load_issues)
    reviewer_report = load_optional(repo, f"{FINAL_REVIEWER}/reviewer-report.yaml", load_issues)
    blocked = load_optional(repo, f"{TRANSLATOR}/blocked-todos.yaml", load_issues)
    if load_issues:
        return emit(args, load_issues)

    phase = normalize_phase(args.phase)
    facts = build_facts(
        repo=repo,
        backlog=backlog,
        decision_log=decision_log,
        ledger=ledger,
        todo=todo,
        contract=contract if phase in {"contract", "tester", "all"} else None,
        tester_report=tester_report,
        reviewer_report=reviewer_report,
        blocked=blocked,
    )
    if args.facts:
        print(export_predicates(facts), end="")
        return 0

    issues = validate_traceability(
        repo=repo,
        phase=phase,
        backlog=backlog,
        decision_log=decision_log,
        ledger=ledger,
        todo=todo,
        contract=contract,
        tester_report=tester_report,
        reviewer_report=reviewer_report,
        blocked=blocked,
    )
    return emit(args, issues)


def emit(args: argparse.Namespace, issues: list[dict[str, str]]) -> int:
    errors = [issue for issue in issues if issue["severity"] == "error"]
    payload = {"ok": not errors, "phase": args.phase, "issues": issues}
    if args.json:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        for issue in issues:
            rule_id = issue.get("rule_id", "TR-UNCLASSIFIED")
            print(f"[{issue['severity'].upper()}] {rule_id} {issue['file']}: {issue['message']}")
        print("[OK] traceability validation passed" if not errors else "[FAIL] traceability validation failed")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
