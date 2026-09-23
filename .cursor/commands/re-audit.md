# re-audit

This command is run **after fixes have been applied** to issues previously found by a code review agent.

Use the review framework in @.cursor/prompts/general-code-audit-review-prompt.md.

---

## Primary goals

- Re-audit to ensure the fixes were applied **correctly** (not superficial patches).
- Re-audit to ensure there are **no remaining bugs or issues** and no regressions introduced by the fixes.
- Provide the audit report in the **same exact format** as the initial review.

---

## Output format (MANDATORY)

- Always use the report format from @.cursor/prompts/general-code-audit-review-prompt.md (Step 4) **exactly**.

---

## Re-audit scope (MANDATORY)

The re-audit scope is: **verify that the fixes you previously recommended have been applied correctly**, regardless of whether the fixes are staged, committed, pushed, or still in the working tree.

You MUST:

- Locate the prior audit report and extract the full list of issues (Issue 1, Issue 2, ...), including each issue’s category and location.
- For each previously reported issue:
  - Inspect the **current** codebase at the referenced locations and confirm whether the issue is fully resolved.
  - If partially resolved or resolved incorrectly, explain why and what remains.
  - If the fix introduces a new risk/regression, call it out as a new finding (with a new Issue number).
- Do not limit the re-audit to a particular git scope. Use git commands only as supporting evidence when useful (e.g., to find what changed since the prior audit).

If a **Linear issue like `HAV-###` is mentioned** (user message, branch name, commit message, PR title/body) OR referenced in the **prior audit report**:

- Retrieve it using Linear tools (if direct lookup fails, search issues by query).
- Always treat Linear as potentially updated since the initial audit: **re-fetch the issue now** and use its *current* acceptance criteria as requirements context when verifying the applied fixes.

---

## How to apply the framework

Follow @.cursor/prompts/general-code-audit-review-prompt.md exactly, with this scope override:

- **Step 1: Discover Scope**: scope is defined by the previously reported issues + the current state of the codebase (verify each fix).

