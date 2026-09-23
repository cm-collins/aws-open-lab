# implement-linear-issue-with-audit

Automate planning for implementing a specific Linear issue (any team prefix), **plus** perform a review-style audit of prerequisite issue(s) to confirm prerequisites were implemented correctly.

This command is **planning-only**: you MUST NOT implement any code until the user explicitly approves the plan.

---

## Issue key resolution (MANDATORY)

Use the same rules as @.cursor/commands/implement-linear-issue.md:

- Parse and normalize issue keys from the user message (`HAV-24`, `hav 24`, etc.).
- Derive branch names as `{type}/hav-{number}-short-slug` (e.g. `feature/hav-24-vendor-onboarding`).
- Default prefix: `HAV`. Optional override in `.cursor/linear.json` → `defaultIssuePrefix` when the user gives only a number.

The **target** issue is the one the user wants to implement. **Prerequisite** issue keys may appear after “audit” in the user message.

---

## Preconditions (MANDATORY)

- This command requires a **target** Linear issue key.
- If the user did **not** provide a target issue key, STOP and ask: “Which Linear issue do you want me to implement? (e.g. `HAV-24`)”
- The user MAY optionally provide prerequisite issue key(s) to audit in the same message (one or many), e.g.:
  - “implement HAV-24 with audit HAV-18”
  - “implement HAV-109 with audit HAV-127, HAV-128”
  - “implement HAV-24 with audit: HAV-18 HAV-19”

If the user provides prerequisite issue key(s), you MUST audit **exactly those** (do not infer different prerequisites unless the user asks).

---

## Output rules (MANDATORY)

- The **full implementation plan** must be posted **only** as a Linear comment on the target issue.
- Do **not** paste the full plan into chat (token-saving).
- For the prerequisite audit(s), follow the `/review` command behavior explicitly:
  - @.cursor/commands/review.md
  - and the shared audit framework: @.cursor/prompts/general-code-audit-review-prompt.md
- For each prerequisite audit, you MUST produce audit artifacts (markdown + JSON). To avoid overwriting other reports, write them to issue-scoped paths:
  - `tmp/code-review/<ISSUE_KEY>/AUDIT_REPORT_<TIMESTAMP>.md`
  - `tmp/code-review/<ISSUE_KEY>/AUDIT_REPORT_<TIMESTAMP>.json`
  - Use the canonical issue key in the path (e.g. `tmp/code-review/HAV-18/`, `tmp/code-review/HAV-127/`).
- Do **not** paste the audit markdown report or JSON into chat. Chat output must be a short pointer + summary only.
- Do **not** create any other plan files unless the user explicitly requests it.

---

## Step -1: Load repo standards (MANDATORY)

Before doing anything else (including calling Linear tools or starting prerequisite audit commands), you MUST load the repo’s engineering standards:

1. Read `AGENTS.md` (required).
2. Load any applicable skill from `.cursor/skills/` per **Task routing** in `AGENTS.md` once issue scope is known.

Hard requirements:

- If you cannot access/read `AGENTS.md`, STOP and ask the user to attach/share it (or provide relevant excerpts).
- You MUST apply those rules to all work produced by this command (planning + audit).

Output requirement (auditability):

- In the final chat response, include a short section titled **“Standards loaded”** with:
  - confirmation that you read `AGENTS.md` (and any routed skill files), and
  - one short direct quote from `AGENTS.md` (max 1 line; under 120 characters), and
  - 2–5 bullets of the most relevant constraints you applied while executing the audit and writing the plan.

---

## Step 0: Resolve target + prerequisite issue(s) (MANDATORY)

Do NOT assume “preceding issue” is `(N-1)`.

### If prerequisites were provided by the user

- Parse the user message for issue keys after “audit”.
- Normalize each to canonical form (`PREFIX-NUMBER`). If ambiguous/malformed, STOP and ask for the exact prerequisite issue key(s).

### Otherwise: infer prerequisites from Linear

1. Retrieve the target issue in Linear.
2. Identify prerequisite issue(s) from the strongest available signals:
   - **Blocked-by / dependency relations** on the target issue (preferred)
   - Explicit mentions in the description like “depends on HAV-XXX”, “prerequisite: HAV-XXX”
   - Linked issues / related-to relations that are clearly prerequisites
   - Host project sequencing notes (if the project defines an order)
3. If you cannot confidently identify prerequisite issue(s), STOP and ask:
   - “Which prerequisite issue(s) should I audit before planning this one?”

Prerequisites may be **one or many** issues (possibly mixed prefixes only if explicitly linked; do not invent cross-team dependencies).

### Confirmation gate for inferred prerequisites (MANDATORY)

If (and only if) prerequisites were **inferred** (not explicitly provided by the user):

1. Retrieve each inferred prerequisite issue from Linear and capture:
   - Issue key (canonical)
   - Title
   - The reason it was inferred (e.g., “blocked-by relation”, “mentioned in description”, etc.)
2. In chat, present a short list like:
   - `HAV-18 — <title>` (reason: blocked-by)
   - `HAV-19 — <title>` (reason: mentioned in description)
3. Ask the user to confirm before you audit:
   - “Confirm I should audit these prerequisite issues before planning `<TARGET_ISSUE_KEY>`.”
4. STOP and do not audit until the user explicitly confirms.

If the user says “no” or provides different prerequisite issue key(s), use the user-provided list instead.

---

## Step 1: Load project + issue context in Linear (MANDATORY)

1. Retrieve the **target issue** using Linear tools.
2. Retrieve each **prerequisite issue** you identified (or the user provided).
3. If the target issue belongs to a Linear project:
   - Load the host project description and enough context to understand goals/constraints.
4. Read existing comments on the target + prerequisite issues to avoid duplicating prior decisions.

In the final chat response, include:

- “What I learned from the project” (if applicable)
- “What I learned from the target issue”
- “What I learned from the prerequisite issue(s)”

---

## Step 1.5: Create (or switch to) a working branch for the target issue (MANDATORY)

Problem this prevents:
- Agents sometimes perform later implementation work on `dev` because branch creation is deferred until “after approval” and can be forgotten. Creating the **local** issue branch now makes the working state deterministic without implementing code.

Rules:
- You MUST create (or switch to) a **local** `{type}/hav-{number}-...` branch for the target issue while still in planning-only mode.
- You MUST NOT change code.
- You MUST NOT push the branch remote until the plan is explicitly approved.

Minimum workflow: same as Step 0.5 in @.cursor/commands/implement-linear-issue.md (use the **target** issue key and title).

Hard stop:
- If `git status --porcelain` is non-empty, STOP and ask the user to clean/stash/commit before you proceed (do not guess what to do with their local changes).

---

## Step 2: Audit prerequisite issue(s) (MANDATORY)

Goal: validate prerequisites were implemented correctly, using the same audit workflow as `/review`:

- @.cursor/commands/review.md
- @.cursor/prompts/general-code-audit-review-prompt.md

For each prerequisite issue key `<ISSUE_KEY>`:

### 2.1 Choose audit scope (MANDATORY)

You MUST audit the code associated with the prerequisite issue. Prefer the strongest evidence source, in this order:

1. **Merged PR** for that issue:
   - If the issue links to a PR, use that PR.
   - Otherwise, search merged PRs targeting `dev` containing `<ISSUE_KEY>` in title/body/branch.
2. **Commit history** on `origin/dev` (fallback):
   - Search commit messages for `<ISSUE_KEY>` and use the relevant commit(s)/range.
3. If neither PR nor commits can be identified, STOP and report what link/info is missing.

Minimum commands (examples; adapt as needed):

```bash
git fetch origin --prune
STARTING_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
git switch dev
git pull --ff-only
```

After the prerequisite audit is complete (MANDATORY):

```bash
git switch "$STARTING_BRANCH"
git rev-parse --abbrev-ref HEAD
```

PR-based (preferred):

```bash
gh pr list --base dev --state merged --search "<ISSUE_KEY>" --limit 5
gh pr view <PR_NUMBER> --json url,mergedAt,baseRefName,headRefName,mergeCommit,statusCheckRollup
gh pr diff <PR_NUMBER>
```

Commit-based (fallback):

```bash
git log --oneline --decorate origin/dev --grep "<ISSUE_KEY>"
git show <SHA>
```

### 2.2 Produce audit artifacts (MANDATORY)

- Apply the framework in @.cursor/prompts/general-code-audit-review-prompt.md.
- Write:
  - `tmp/code-review/<ISSUE_KEY>/AUDIT_REPORT_<TIMESTAMP>.md`
  - `tmp/code-review/<ISSUE_KEY>/AUDIT_REPORT_<TIMESTAMP>.json`
- Do not stage/commit these artifacts (they are ignored by git).
- Chat output for each prerequisite audit must be short: verdict + P0/P1 titles/locations + artifact paths.

If any prerequisite audit **fails**, you MUST:

- Clearly state prerequisites are not satisfied.
- Do NOT proceed to planning unless the user explicitly asks you to proceed anyway (and you restate the risk).

---

## Step 3: Produce an implementation plan for the target issue (MANDATORY)

Create a detailed, emoji-styled plan in plain English (same style requirements as `/implement-linear-issue`) and post it as a **new Linear comment** on the target issue.

Constraints:

- Do NOT post the full plan in chat.
- Do NOT implement code.

---

## Step 4: Report back in chat (MANDATORY)

After posting the plan comment and writing the prerequisite audit artifacts, respond in chat with a short, skimmable summary:

- Target issue: key + link
- Prerequisite issue(s) audited: list keys + links
- Audit results (per prerequisite):
  - Verdict (PASS/FAIL)
  - Count of findings by priority (P0/P1/P2/P3)
  - Artifact paths
- Plan posted: confirm it was added as a Linear comment and provide the issue link
- Local branch name created
- Any blocking questions / confirmations

---

## Step 5: Do not implement until approved (MANDATORY)

After posting the plan and producing the audit artifacts, STOP.

- Do NOT change code.
- Do NOT push the branch remote.

When (and only when) the plan is approved, the next steps will be:

- Push the already-created issue branch to remote:
  - `git push -u origin HEAD`
- Then proceed with implementation following the approved plan.
