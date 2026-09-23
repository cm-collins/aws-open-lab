# review-branch-parallel

Run a **branch-scope** code audit using multiple independent subagents, then consolidate their findings into one merged report. Same orchestration as `/review-parallel`, but **scope is always the current branch** (all commits and net diff since the branch base), per @.cursor/commands/review-branch.md.

Use the review framework in @.cursor/prompts/general-code-audit-review-prompt.md.

---

## When to use

- You want a **parallel** multi-subagent review of the **entire branch** (everything since the branch base), not just staged changes or the latest commit.
- Scope is computed the same way as `/review-branch`: merge-base for feature branches, or last PR merge for `main`/`dev`/`master`.
- Output is the same as `/review-parallel`: run directory, per-subagent JSON reports, and merged report `RUN_<RUN_ID>/AUDIT_REPORT_<RUN_ID>_MERGED.{md,json}` for `/fix-merged`.

All other behavior (number of subagents, run end-to-end, Write mode, shared context, verification once, and **using the named Cursor subagent `review-audit-subagent`**) is the same as @.cursor/commands/review-parallel.md — read that command for **Run end-to-end**, **Subagents in Write mode**, **Number of subagents**, and Steps 1.5–6.

---

## Step 1: Orchestrator — Generate run ID, run directory, and branch scope (MANDATORY)

1. Generate `RUN_ID` and create the run directory (same as @.cursor/commands/review-parallel.md Step 1, items 1–2):

```bash
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$(openssl rand -hex 3 2>/dev/null || echo $$)"
RUN_DIR="tmp/code-review/RUN_${RUN_ID}"
mkdir -p "$RUN_DIR"
echo "RUN_ID=$RUN_ID"
echo "RUN_DIR=$RUN_DIR"
```

2. **Scope = branch only**: Compute scope using **@.cursor/commands/review-branch.md** only (do not use staged/unstaged or most recent commit). Follow the "Scope selection (MANDATORY)" section of review-branch.md:
   - If current branch is not `dev`/`main`/`master`: compute `BASE_SHA` via merge-base with the best candidate base branch (e.g. `origin/main`).
   - If current branch is `dev`/`main`/`master`: use last PR merged into that branch as `BASE_SHA`, or fallback to last merge commit.
   - **Validate scope SHAs before proceeding** (stop if invalid):

     ```bash
     git rev-parse --verify "$BASE_SHA^{commit}"
     git rev-parse --verify "HEAD^{commit}"
     ```

   - Then capture:
     - `git log --oneline --decorate "$BASE_SHA"..HEAD`
     - `git diff --stat "$BASE_SHA"...HEAD`
     - `git diff "$BASE_SHA"...HEAD` (for shared context summary or subagent instructions)
   - If a Linear issue (e.g. HAV-###) is mentioned, retrieve issue body and comments per review-branch.md and include in shared context.

Record **BASE_SHA**, **HEAD**, and **branch name** for use in Step 1.5 and in subagent instructions.

---

## Steps 1.5–6: Same as review-parallel

Follow **Steps 1.5 through 6** of @.cursor/commands/review-parallel.md exactly, with this scope override:

- **Shared context (Step 1.5)**: Scope summary must describe **branch scope**: branch name, BASE_SHA, HEAD, output of `git log --oneline BASE_SHA..HEAD`, and a short summary of `git diff --stat BASE_SHA...HEAD`. Include Linear issues for the branch if applicable.
- **Subagent instructions (Step 2)**: Spawn the named Cursor subagent **`review-audit-subagent`** (see @.cursor/agents/review-audit-subagent.md). Tell each subagent that **review scope is the branch range**: they must use `git log BASE_SHA..HEAD` and `git diff BASE_SHA...HEAD` (and the framework's Step 1: Discover Scope) to review the full branch, per @.cursor/commands/review-branch.md. Give them the exact BASE_SHA and HEAD so they don't recompute.

All other steps (spawn N subagents in Write mode, merge, manifest, verification once, chat summary) are unchanged.

---

## Constraints

- **Branch scope only**: This command always reviews the branch range (BASE_SHA..HEAD). For staged/unstaged or single-commit scope, use `/review-parallel` instead.
- All other constraints from @.cursor/commands/review-parallel.md apply (run end-to-end, subagents in Write mode, no verification in subagents, etc.).
