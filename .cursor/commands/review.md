# review

Use the review framework in @.cursor/prompts/general-code-audit-review-prompt.md.

The only difference for `/review` is **what to review** (scope selection).

---

## Scope selection (MANDATORY)

First, determine what to review:

```bash
git status --porcelain
git diff --cached --stat
git diff --stat
```

Apply these rules:

- If there are **any staged and/or unstaged changes**, review those:
  - Staged: `git diff --cached --stat` + `git diff --cached`
  - Unstaged: `git diff --stat` + `git diff`
- If there are **no staged or unstaged changes**, review the **most recent commit**:
  - `git show --stat HEAD`
  - `git show HEAD`
- If a **Linear issue like `HAV-###` is mentioned** (user message, branch name, commit message, PR title/body):
  - Retrieve the issue **body AND comments** using Linear tools (if direct lookup fails, search issues by query).
  - Treat comments as authoritative clarifications (e.g., “prefer sentinel `outboxStatus=\"none\"`”, scope boundaries, implementation notes).
  - Use **issue body + comments** as requirements context and verify the changes/commit meet acceptance criteria.
  - If comments contradict the issue body, explicitly flag the discrepancy in the audit report and state which source you followed (and why).

---

## How to apply the framework

Follow @.cursor/prompts/general-code-audit-review-prompt.md exactly, with these scope overrides:

- **Step 1: Discover Scope**: use the scope-appropriate git commands above (not only `git diff --cached`).
- **Constraints**: review staged/unstaged changes if present; otherwise review the most recent commit (do not audit the entire codebase unless explicitly requested).

---

## Output files (MANDATORY)

Write reports to **unique, timestamped filenames** so repeated runs (and parallel agents) never conflict.

Generate a UTC timestamp and decide output paths:

```bash
REPORT_TS="$(date -u +%Y%m%dT%H%M%SZ)"
REPORT_MD="tmp/code-review/AUDIT_REPORT_${REPORT_TS}.md"
REPORT_JSON="tmp/code-review/AUDIT_REPORT_${REPORT_TS}.json"
mkdir -p tmp/code-review
printf 'Report paths:\n- %s\n- %s\n' "$REPORT_MD" "$REPORT_JSON"
```

Then write the full reports to **exactly those paths**, per @.cursor/prompts/general-code-audit-review-prompt.md.

