---
name: developing-solidworks
description: Develop, modify, debug, run, and verify C# automation for SOLIDWORKS 2024 through SolidWorks.Interop and COM APIs. Use for .cs or .csproj tasks that create, inspect, modify, export, or validate SOLIDWORKS parts, assemblies, drawings, features, configurations, or documents.
---

# Develop SOLIDWORKS 2024 C# Automation

Turn the user's engineering intent into a verified SOLIDWORKS artifact.

The objective is the user's requested artifact and its acceptance conditions.

The local SWAPI knowledge base is evidence for making correct API decisions. Documentation lookup is not itself progress.

## Environment

Expected runtime environment:

- Windows
- licensed SOLIDWORKS 2024
- SOLIDWORKS 2024 Interop assemblies
- C# / .NET project
- this workspace contains the local SWAPI knowledge base

The knowledge base is already bundled locally.

Expected repository content:

```text
<workspace>/
├── llm_index/
│   ├── symbols.tsv
│   ├── documents.tsv
│   ├── interface_members.jsonl
│   └── ...
├── markdown/
│   └── ...
├── AGENTS.md
└── .opencode/
    └── skills/
        └── developing-solidworks/
            └── SKILL.md
```

Do not:

- resolve an external `solidworks-api-kb` reference;
- depend on machine-specific absolute paths;
- search other drives for the knowledge base;
- substitute model memory for an API contract when local documentation is available.

Resolve `KB_ROOT` once from the current workspace.

Prefer the workspace root when it contains both:

```text
llm_index/
markdown/
```

If necessary, locate a workspace-visible directory containing both folders.

Do not search outside the current workspace.

If they cannot be found, stop with:

```text
SOLIDWORKS_API_KB_NOT_FOUND
```

and report the expected relative directories.

# Core invariants

Maintain four invariants.

## 1. Goal conservation

The implementation path may change.

The user's requested outcome and frozen acceptance conditions may not.

## 2. Legal mutation

Modify only authorized files, documents, features, configurations, and application state.

Use documented SOLIDWORKS 2024 API contracts for COM operations.

## 3. Evidence-based progress

Progress means:

```text
a previously pending acceptance condition
becomes proven by observable evidence
without breaking previously passed conditions
```

Reading documentation, writing code, or compiling successfully does not by itself count as completion.

## 4. Valid termination

Return `SUCCESS` only when all required acceptance conditions have passed.

Return `BLOCKED` only when an observable blocker prevents further useful legal action.

# Rollout loop

Use this loop:

```text
SCOPE
  ↓
FREEZE ACCEPTANCE
  ↓
SELECT ONE PENDING CHECK
  ↓
GET MINIMUM API EVIDENCE
  ↓
IMPLEMENT MINIMUM CHANGE
  ↓
RUN
  ↓
ASSERT
  ↓
PASS ─────→ next pending check
  │
  └ FAIL ─→ diagnose from observed evidence
                ↓
             retry
                ↓
         SUCCESS | BLOCKED
```

Do not stop at a plan when the requested task is executable.

# 1. Scope the task

Before implementation, identify only what is necessary to execute the task:

- requested final artifact or document state;
- input documents and values;
- required output;
- units and document types;
- state that may change;
- state that must remain unchanged;
- assumptions required to execute.

Prefer a reasonable explicit assumption when it does not materially alter the requested artifact.

Do not create unnecessary architecture before the transformation is understood.

# 2. Freeze the acceptance contract

Translate the request into falsifiable checks before implementation.

Use:

```yaml
ACCEPTANCE_CONTRACT:
  goal: <observable final result>

  protected:
    - <state that must remain unchanged>

  assumptions:
    - <necessary executable assumption>

  checks:
    - id: AC-1
      requirement: <user requirement>
      predicate: <true/false proposition>
      method: <SOLIDWORKS_API | FILESYSTEM | TEST | VISUAL | USER>
      expected: <pass condition>
      evidence: <value or artifact to capture>
```

Every material user requirement must map to at least one check.

Include preservation checks when the task must leave existing content unchanged.

Prefer deterministic evidence in this order:

1. SOLIDWORKS API-readable state
2. automated test
3. filesystem assertion
4. save → reopen → read validation
5. visual inspection
6. user judgment for inherently subjective criteria

After implementation begins, do not weaken a failed acceptance condition merely to obtain a pass.

# 3. Select one pending check

Work on one meaningful acceptance slice at a time.

Choose:

```text
smallest useful change
that can make one pending check pass
without breaking already-passed checks
```

Avoid implementing speculative future requirements.

# 4. Get minimum API evidence

Do not browse the knowledge base broadly.

Every lookup must answer one concrete uncertainty blocking the next action.

Before lookup, establish:

```yaml
LOOKUP_INTENT:
  acceptance_id: AC-N
  uncertainty: <exact missing API contract or observed error>
  query: <symbol / enum / HRESULT / narrow phrase>
  evidence_needed: <signature / parameter / return / enum / remark>
  stop_when: <finding that permits the next action>
```

Stop searching as soon as the needed contract is known.

## Local SWAPI lookup order

Use the bundled knowledge base directly.

### Step 1 — exact symbol

Search:

```text
<KB_ROOT>/llm_index/symbols.tsv
```

Example:

```powershell
rg -n -F "IModelDoc2.Save" "<KB_ROOT>\llm_index\symbols.tsv"
```

### Step 2 — interface members

If the member name is unknown, search:

```text
<KB_ROOT>/llm_index/interface_members.jsonl
```

Example:

```powershell
rg -n '"interface": "IModelDoc2"' "<KB_ROOT>\llm_index\interface_members.jsonl"
```

### Step 3 — resolve documentation

Use:

```text
<KB_ROOT>/llm_index/documents.tsv
```

to locate the relevant primary document.

### Step 4 — read primary documentation

Open only the directly relevant document under:

```text
<KB_ROOT>/markdown/
```

Confirm only what is required for the next action:

- C# signature;
- parameter order and meaning;
- units;
- return value;
- error/status semantics;
- enum values;
- prerequisites;
- important remarks.

### Step 5 — examples only when necessary

Search examples only when the primary API contract leaves a concrete implementation ambiguity.

Do not continue reading documentation merely because related material exists.

Record:

```yaml
API_EVIDENCE:
  acceptance_id: AC-N
  symbol: <interface.member or enum>
  index_match: <local index location>
  documentation: <local markdown path>
  confirmed_contract: <fact needed for implementation>
  api_version: SOLIDWORKS 2024
  uncertainty: none | <remaining uncertainty>
```

If focused lookup cannot find the required contract, return:

```text
API_DOCUMENTATION_NOT_FOUND
```

with the queries attempted.

# 5. Implement the smallest slice

Implement only enough to satisfy the selected acceptance check.

For SOLIDWORKS COM code:

- use documented parameter order and types;
- use explicit enum conversions when COM requires integers;
- treat API linear units as meters unless documentation says otherwise;
- include units in variable names when ambiguity is possible;
- validate active document and document type before document-specific actions;
- check returned COM objects for `null`;
- inspect boolean, integer status, error code, and HRESULT results where applicable;
- avoid machine-specific template or file paths when document-derived or user-provided paths exist;
- prefer working copies unless modification of the original is explicitly intended;
- preserve unrelated features, configurations, selections, documents, and application state;
- clean up owned resources in `finally`;
- close SOLIDWORKS only if this program launched it and closing it is allowed.

Do not add sample-specific conditionals merely to make one test pass.

Do not refactor unrelated code during an acceptance slice.

# 6. Run against real SOLIDWORKS

Compilation is necessary but not sufficient.

After each executable slice:

1. run relevant automated tests;
2. compile the project;
3. run the program against SOLIDWORKS 2024;
4. evaluate the selected acceptance check;
5. rerun previously passed checks affected by the change;
6. verify output files when applicable;
7. save and reopen output when persistence matters.

Typical executable project:

```powershell
dotnet run --project <project.csproj>
```

Use actual runtime behavior as the feedback signal.

Record:

```yaml
RUN_EVIDENCE:
  command: <command executed>
  exit_code: <integer>
  solidworks_version: <observed version>

  checks:
    - id: AC-1
      expected: <frozen expectation>
      actual: <observed result>
      passed: true | false
      evidence: <API value / test / file / visual evidence>

  protected_state:
    passed: true | false
    evidence: <observed result>
```

# 7. Learn from failure

A failed run is evidence.

Do not immediately broaden the search or rewrite large parts of the implementation.

For a failed check:

```text
observe exact failure
      ↓
assign failure to one layer
      ↓
form one testable hypothesis
      ↓
obtain API evidence only if required
      ↓
change the smallest relevant thing
      ↓
rerun the same check
```

Classify the failure when useful:

```text
REQUIREMENT
API_CONTRACT
CODE
COM_RUNTIME
DOCUMENT_STATE
SOLIDWORKS_STATE
FILESYSTEM
ASSERTION
ENVIRONMENT
```

Preserve:

- expected value;
- actual value;
- exception;
- HRESULT;
- document type;
- relevant selection/configuration state.

A new documentation lookup is justified only when new evidence creates a concrete API uncertainty.

Do not alternate between searching and editing without producing new runtime evidence.

# 8. Finish only on evidence

Return `SUCCESS` only when:

```text
all frozen acceptance checks pass
AND
protected-state checks pass
AND
the relevant real SOLIDWORKS execution succeeds
AND
required output artifacts exist
AND
saved artifacts reopen successfully when applicable
AND
relevant tests pass
```

If SOLIDWORKS cannot be launched, COM automation cannot execute, or a required license/capability is unavailable, return:

```text
RUNTIME_VERIFICATION_BLOCKED
```

Do not claim functional success based only on compilation or code inspection.

For other blockers report:

```yaml
BLOCKED:
  acceptance_id: <AC-N>
  blocker: <observable blocker>
  evidence: <exact error or state>
  last_action: <last useful action attempted>
  required_to_continue: <missing input or capability>
```

# Final report

Keep the final report concise.

Include:

```yaml
RESULT: SUCCESS | BLOCKED

GOAL:
  <requested outcome>

CHANGES:
  - <important changed file or artifact>

ACCEPTANCE:
  - id: AC-1
    passed: true | false
    evidence: <observable evidence>

API_EVIDENCE:
  - <core API contract used>

RUN:
  command: <final command>
  result: <observed result>

OUTPUT:
  - <artifact path>

REMAINING:
  - <only unresolved assumption or blocker>
```

The deliverable is the verified engineering result, not the amount of documentation read or code produced.