---
name: developing-solidworks
description: Develop, modify, debug, and verify C# automation for SOLIDWORKS 2024 using SolidWorks.Interop assemblies and COM APIs. Use for .cs or .csproj work that opens, reads, creates, modifies, exports, or validates SOLIDWORKS parts, assemblies, or drawings.
---

# Develop SOLIDWORKS 2024 C# Automation

Treat this skill as an execution contract. Base every API call on the local SOLIDWORKS 2024 knowledge base and verify behavior in a real SOLIDWORKS session before claiming success.

## Required environment

- Run on Windows with SOLIDWORKS 2024 installed and licensed.
- Use the SOLIDWORKS 2024 Interop assemblies available on the machine.
- Resolve the OpenCode reference named `solidworks-api-kb` before writing code.
- Expect that reference to contain `llm_index/`, `markdown/`, and `AGENTS.md` from the SWAPI knowledge base.

If the reference or required index files are unavailable, stop with `SOLIDWORKS_API_KB_NOT_FOUND`. Do not replace missing documentation with model memory.

## Documentation-first workflow

For every interface, method, property, delegate, or enum used:

1. Search `solidworks-api-kb/llm_index/symbols.tsv` for the exact symbol or a narrow substring.
2. When exploring an interface, search `solidworks-api-kb/llm_index/interface_members.jsonl`.
3. Use `solidworks-api-kb/llm_index/documents.tsv` to resolve the full document when necessary.
4. Open only the relevant file under `solidworks-api-kb/markdown/`.
5. Confirm the C# or .NET signature, parameters, return value, remarks, and version notes.
6. Search related examples only after confirming the primary API contract.

Typical searches:

```powershell
rg -n -F "IModelDoc2.OpenDoc6" <solidworks-api-kb>\llm_index\symbols.tsv
rg -n '"interface": "IModelDoc2"' <solidworks-api-kb>\llm_index\interface_members.jsonl
rg -n -F "swDocumentTypes_e" <solidworks-api-kb>\llm_index\symbols.tsv
```

Replace `<solidworks-api-kb>` with the resolved reference path. Quote paths that contain spaces.

Before implementation, record:

```text
API_EVIDENCE
- symbol:
- index_match:
- documentation_path:
- confirmed_signature:
- relevant_enum_path:
- api_version: SOLIDWORKS 2024
- uncertainty: none | description
```

If an exact contract cannot be confirmed, stop with `API_DOCUMENTATION_NOT_FOUND` and report the searches performed.

## Implementation rules

- Use named arguments for calls with many or easily confused parameters.
- Use the exact documented parameter order, types, and enum values.
- Cast enums explicitly when the COM signature requires an integer.
- Treat SOLIDWORKS API linear units as meters unless the checked documentation states otherwise; name variables with units.
- Check active document existence and required document type before document-specific operations.
- Check every returned COM object for `null`.
- Check boolean and status return values; never assume a call succeeded because it did not throw.
- Prefer user-preference or document-derived template paths over hardcoded machine paths.
- Preserve documents, configurations, selections, and application instances that the user did not ask to modify or close.
- Put cleanup in `finally` blocks. Release only COM references owned by the program, and close SOLIDWORKS only if the program launched it and the task requires closure.
- Do not add sample-specific conditionals or bypasses to make one test pass.

## Runtime verification

Compilation is necessary but insufficient. After every code change:

1. Run the relevant automated tests.
2. Run the application, normally with `dotnet run --project <project.csproj>` for an SDK-style executable project.
3. Use a test document or working copy unless the user explicitly authorized changes to an original document.
4. Verify the expected SOLIDWORKS side effects through API-readable assertions.
5. Verify every required output file exists and can be reopened when applicable.
6. Rerun the full relevant test suite after the final code change.

Record:

```text
RUN_EVIDENCE
- command:
- exit_code:
- solidworks_version:
- input_document:
- output_document:
- assertions:
  - name:
    expected:
    actual:
    passed:
- tests:
- cleanup_result:
```

Success requires all mandatory assertions to pass:

```text
SUCCESS = documented_api_contract
          AND process_exit_code_is_zero
          AND expected_document_state
          AND required_output_files_exist
          AND relevant_tests_pass
```

If SOLIDWORKS cannot be launched or accessed, the license is unavailable, or desktop COM execution is blocked, return `RUNTIME_VERIFICATION_BLOCKED`. Provide the exact blocker and do not claim functional success.

## Troubleshooting

When a call fails or returns an unexpected result:

1. Preserve the exact error, HRESULT, return value, selection state, and document type.
2. Recheck the primary API topic and its remarks.
3. Search the index for related interfaces, status enums, and examples.
4. Minimize the failure into the smallest reproducible operation.
5. Change one assumption at a time and rerun the same assertion.

Ask for clarification when the requested behavior depends materially on document type, configuration, units, template, or whether an existing SOLIDWORKS session may be modified.
