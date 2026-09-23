# Cursor commands quick reference

This folder contains Cursor command definitions and related helper docs used in this repo.

**AWS skills:** Repo-specific skills live in [`.cursor/skills/`](skills/). AWS Agent Toolkit skills are **not committed** — sync locally with [`scripts/sync-agent-toolkit-skills-to-repo.sh`](../scripts/sync-agent-toolkit-skills-to-repo.sh). See [skills/README.md](skills/README.md) and [NOTICE.md](../NOTICE.md).

**AWS MCP:** [`.cursor/mcp.json`](mcp.json) defines the **`aws-mcp`** server (`uvx` + `mcp-proxy-for-aws`). Requires [uv](https://docs.astral.sh/uv/) and valid AWS credentials. Sync from `~/.cursor/mcp.json` with [`scripts/sync-agent-toolkit-mcp-to-repo.sh`](../scripts/sync-agent-toolkit-mcp-to-repo.sh).

Start with [`AGENTS.md`](../AGENTS.md) for repo routing, source-of-truth precedence, and task routing.

This file lives at `.cursor/README.md` (outside `.cursor/commands/`) so it is **not** interpreted as a command.

---

## Commands

### `/review`

- **Purpose**: Run a code audit using the standard audit framework.
- **Scope rules**:
  - If there are **staged and/or unstaged changes**, review those.
  - If there are **no changes**, review the **most recent commit**.
  - If an **`HAV-###`** is mentioned, use it as requirements context.
- **Outputs**:
  - Writes audit artifacts to `tmp/code-review/`:
    - `tmp/code-review/AUDIT_REPORT_<TIMESTAMP>.md`
    - `tmp/code-review/AUDIT_REPORT_<TIMESTAMP>.json`
  - Chat output is a short pointer + summary (no full report/JSON dump).

### `/review-branch`

- **Purpose**: Audit a whole branch’s work (all commits in range) using the standard audit framework.
- **Scope rules**:
  - Feature/topic branch: audit from inferred base merge-base → `HEAD`.
  - `dev` / `main` / `master`: audit since the last merged PR (best-effort via GitHub, fallback to git history).
  - If an **`HAV-###`** is mentioned, use it as requirements context.
- **Outputs**:
  - Same as `/review` (writes to `tmp/code-review/`).

### `/re-audit`

- **Purpose**: Re-audit after fixes were applied.
- **Scope rules**:
  - Re-check the **previously reported issues** against the **current codebase** (not tied to staged/committed state).
  - If an **`HAV-###`** is mentioned, ensure fixes meet its criteria.
- **Outputs**:
  - Same as `/review` (writes to `tmp/code-review/`).

### `/review-parallel`

- **Purpose**: Run a code audit using multiple independent subagents, then consolidate their findings into one merged report.
- **Optional**: You can specify how many subagents to use (e.g. “use 2 subagents” or “run with 5 agents”); default is 3–4, with a reasonable cap (e.g. 6).
- **Workflow**:
  - Orchestrator generates a unique `RUN_ID` and run directory `tmp/code-review/RUN_<RUN_ID>/`.
  - Spawns subagents using the custom Cursor subagent `review-audit-subagent` (defined at `.cursor/agents/review-audit-subagent.md`) for consistent behavior (model + write capabilities).
  - Spawns N subagents (N from your request or default 3–4), each given **explicit output paths** (e.g. `AUDIT_REPORT_<RUN_ID>_A.json`) so there are no write conflicts.
  - Each subagent performs a full review of the same scope and writes only to its assigned paths.
  - Orchestrator merges all subreports (findings de-duplicated and renumbered), writes `tmp/code-review/RUN_<RUN_ID>/AUDIT_REPORT_<RUN_ID>_MERGED.{md,json}`, and a manifest in the run directory.
- **Outputs**:
  - Run directory with per-subagent reports and `MANIFEST.json`.
  - Single merged report at `tmp/code-review/RUN_<RUN_ID>/AUDIT_REPORT_<RUN_ID>_MERGED.{md,json}`. Use `/fix-merged` to fix issues from this report.
- **Scope**: Staged/unstaged changes or most recent commit (same as `/review`). For **branch scope** (full branch since base), use `/review-branch-parallel` instead.

### `/review-parallel-high`

- **Purpose**: Same as `/review-parallel`, but uses high-depth subagent `review-audit-subagent-high` for stricter/deeper parallel audits.
- **Workflow**: Same as `/review-parallel`; only subagent identity/model changes.
- **When to use**: Higher scrutiny / deeper reasoning when speed and cost are less important.

### `/review-branch-parallel`

- **Purpose**: Same as `/review-parallel` but **scope is always the current branch** (all commits and net diff since the branch base, per `/review-branch`). Use when you want a parallel multi-agent review of the entire branch, not just staged changes or the latest commit.
- **Workflow**: Same orchestration as `/review-parallel` (RUN_ID, shared context, N subagents in Write mode, merge, manifest, verification once). Scope is computed via @.cursor/commands/review-branch.md (merge-base or last PR merge).
- **Outputs**: Same as `/review-parallel` (run directory, merged report for `/fix-merged`).

### `/review-branch-parallel-high`

- **Purpose**: Same as `/review-branch-parallel`, but uses high-depth subagent `review-audit-subagent-high`.
- **Workflow**: Same as `/review-branch-parallel`; only subagent identity/model changes.
- **When to use**: Deeper branch-wide audits for high-risk changes.

### `/fix-single`

- **Purpose**: Validate and fix issues from the latest **single-run** code review report (`/review` or `/review-branch`).
- **Input**:
  - Reads the latest timestamped report `tmp/code-review/AUDIT_REPORT_*.json` (excludes `*_MERGED.json`). Use `/fix-merged` for merged reports.
- **Workflow**:
  - Validates each finding exists first.
  - Fixes only confirmed issues; pushes back (with evidence) on invalid/misinterpreted findings.
  - Uses durable fixes; if a larger refactor is best, it proposes options and asks what to do.
- **Outputs**:
  - Produces a “fix report” in chat only (no artifact files).
  - Does **not** commit unless explicitly asked.

### `/fix-merged`

- **Purpose**: Validate and fix issues from the latest **merged** report produced by `/review-parallel` or `/review-branch-parallel` (consolidated findings from multiple subagents).
- **Input**:
  - Reads the latest merged report under `tmp/code-review/RUN_*/AUDIT_REPORT_*_MERGED.json`. Use `/fix-single` for single-run reports.
- **Workflow**:
  - Same as `/fix-single` (validate, fix confirmed issues, push back on invalid findings, durable fixes).
- **Outputs**:
  - Produces a “fix report” in chat only (no artifact files).
  - Does **not** commit unless explicitly asked.

### `/oversee`

- **Purpose**: Reusable product + technical **gatekeeper** for decisions (overseer / Product Owner / Architect assistant style).
- **How**: Uses the custom Cursor subagent `productowner` (see `.cursor/agents/productowner.md`) to return a crisp **APPROVE/BLOCK/NEEDS-INFO** verdict against the **PRD** (source of truth unless you state otherwise) + explicit user instructions + repo standards.
- **Inputs**: Provide HAV key(s), PR/branch scope, and/or review run dir (`tmp/code-review/RUN_<RUN_ID>/`) when applicable.

### `/implement-linear-issue`

- **Purpose**: Create an implementation plan for a specific Linear issue (any team prefix).
- **Input**:
  - Requires a Linear issue key like `HAV-24` (accepts variants like `hav 24`; otherwise it will ask).
  - Optional: set `.cursor/linear.json` with `{ "defaultIssuePrefix": "HAV" }` if you often refer to issues by number only.
- **Workflow**:
  - Loads host project context (if any) + issue context.
  - Creates a local branch `feature/hav-<number>-<slug>` (e.g. `feature/hav-24-vendor-onboarding`).
  - Posts a detailed emoji-styled implementation plan as a **Linear comment**.
  - Does **not** implement code until explicitly approved.
- **Outputs**:
  - Plan is posted **only** in Linear (not repeated in chat).
  - Chat output is a brief summary + link to the issue/comment.

### `/implement-linear-issue-with-audit`

- **Purpose**: Audit prerequisite issue(s), then create a plan for the target issue (any team prefix).
- **Input**:
  - Requires a target issue key (otherwise it will ask).
  - Optional: provide prerequisite issue keys to audit in the same message (e.g. “audit HAV-18, HAV-19”).
- **Workflow**:
  - Audits prerequisite issue(s) using the same workflow/framework as `/review`.
  - Writes per-prerequisite audit artifacts to:
    - `tmp/code-review/<ISSUE_KEY>/AUDIT_REPORT_<TIMESTAMP>.md`
    - `tmp/code-review/<ISSUE_KEY>/AUDIT_REPORT_<TIMESTAMP>.json`
  - Posts the target issue plan as a **Linear comment**.
  - Does **not** implement code until explicitly approved.
- **Outputs**:
  - No audit report/JSON pasted into chat; chat output is a short summary + file paths + Linear links.

### `/delete-feature-branch`

- **Purpose**: Safely delete a feature branch locally + remotely after verifying merge to `dev`.
- **Safety gates**:
  - Refuses to delete protected branches (`dev`, `main`, `master`, default branch).
  - Requires clean working tree.
  - Requires GitHub CLI auth (`gh auth status`).
  - Verifies PR was merged into `dev` and merge commit is in `origin/dev`.
  - Requires explicit confirmation phrase before deleting:
    - `CONFIRM DELETE <BRANCH>`

### `/commit`

- **Purpose**: Create a git commit for **already-staged** changes.
- **Safety gates**:
  - Will not stage files for you.
  - If nothing is staged, it will stop and tell you what to do.
- **Implementation**:
  - Uses `COMMIT_MESSAGE.txt` temp file workflow.

### `/pr`

- **Purpose**: Create or update a GitHub PR using `gh`.
- Notes:
  - Uses `PR_MESSAGE.txt` temp file workflow.
  - Has a safety gate for targeting `main`/`master`.

