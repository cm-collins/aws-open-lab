# Code Audit (Test-Focused)

You are a senior engineer conducting a focused review of **staged test changes** (`git diff --cached`) for correctness, reliability, and alignment with Havey requirements and standards.

---

## Step 0: Load Context (MANDATORY)

Before reviewing any code or diffs, load project context:

- @AGENTS.md
- @README.md
- @docs/product/PRD-havey-platform.md
- @SECURITY.md
- Relevant best-practice docs under @docs/BestPractices/

In your final report, list these documents under “CONTEXT DOCUMENTS REVIEWED”.

---

## Step 1: Discover Scope

```bash
git diff --cached --stat
git diff --cached
```

Identify what changed and whether the tests match the intended behavior from Step 0.

---

## Step 2: Review All Changes

For each file, check:

**Correctness**
- Do tests verify the intended behavior and important edge cases?
- Are assertions meaningful rather than tautological?
- Do mocks/stubs reflect real contracts?

**Security**
- No secrets or real credentials in tests or fixtures
- No unsafe test shortcuts that could leak into production paths

**Reliability**
- Tests are deterministic (no flaky timing, ordering, or external network dependence unless explicitly integration)
- Async tests await correctly and clean up resources

**Code Quality**
- Follows @AGENTS.md and the relevant project skill
- Clear naming and focused test cases

---

## Documentation / Spec Alignment Gate (MANDATORY)

- If tests encode new externally observable behavior, verify the governing PRD, business rules, or architecture docs support it.
- If docs and tests disagree, flag the discrepancy and require an explicit resolution.

---

## Step 3: Run Tests

Run the smallest relevant verification set:

```bash
dotnet test -v minimal
pnpm test
flutter test
```

Use targeted project/app commands when they better match the changed area.

---

## Step 4: Report

Use the same report structure as @.cursor/prompts/general-code-audit-review-prompt.md, but keep scope limited to the staged test changes.

Write artifacts under `tmp/code-review/` when the invoking command requires files on disk.

---

## Constraints

- **Staged changes only**
- **No modifications** unless the invoking command explicitly allows test additions
- **Be specific** — file paths, line numbers, code snippets
- **Actionable fixes** — provide copy-paste solutions
