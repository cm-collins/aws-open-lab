# implement-linear-issue

Automate planning for implementing a specific Linear issue (any team prefix).

This command is **planning-only**: you MUST NOT implement any code until the user explicitly approves the plan.

---

## Issue key resolution (MANDATORY)

Havey issues use the **`HAV-*`** prefix on the **Havey** Linear team.

Linear issue keys look like `HAV-<NUMBER>` (e.g. `HAV-24`, `HAV-172`).

### Parse from the user message

1. Look for an issue key in the user message using pattern `([A-Za-z]+)[\s_-]*(\d+)`.
2. **Normalize** to canonical form: uppercase prefix + hyphen + number.
   - Examples: `hav 24` → `HAV-24`, `HAV_24` → `HAV-24`
3. If the user gave **only a number** (e.g. `24`, `issue 24`):
   - If `.cursor/linear.json` exists and has `defaultIssuePrefix`, use that prefix (default `HAV`).
   - Otherwise STOP and ask: “Which Linear issue do you want me to implement? (e.g. `HAV-24`)”
4. If no issue key can be resolved, STOP and ask:
   - “Which Linear issue do you want me to implement? (e.g. `HAV-24`)”

### Derived values (use consistently)

From canonical `ISSUE_KEY` (e.g. `HAV-24`):

| Variable | Example | Rule |
|----------|---------|------|
| `ISSUE_PREFIX` | `HAV` | Part before `-` |
| `ISSUE_NUMBER` | `24` | Part after `-` |
| `LINEAR_ID` | `hav-24` | `{prefix lower}-{number}` |
| `BRANCH_TYPE` | `feature` | Default `feature`; use `fix`, `docs`, `infra`, `security`, `refactor`, `test`, `ci`, or `chore` when the issue clearly indicates it |

Branch name format (per `CONTRIBUTING.md`):

```text
{BRANCH_TYPE}/{LINEAR_ID}-short-slug-from-issue-title
```

Example: `HAV-24` + title “Add vendor onboarding” → `feature/hav-24-vendor-onboarding`

---

## Preconditions (MANDATORY)

- This command only runs for a specific Havey Linear issue key like `HAV-24`.

---

## Output rules (MANDATORY)

- The **full implementation plan** must be posted **only** as a Linear comment on the issue.
- Do **not** paste the full plan into chat (token-saving).
- Do **not** create any plan files (`.md`, `.json`, etc.) unless the user explicitly requests it.

---

## Step -1: Load repo standards (MANDATORY)

Before doing anything else (including calling Linear tools), you MUST load the repo’s engineering standards:

1. Read `AGENTS.md` (required).
2. After reading the issue, load any applicable skill from `.cursor/skills/` per **Task routing** in `AGENTS.md` (e.g. frontend or .NET skills when the issue scope is clear).
3. If scope is unclear during planning, note which skill(s) you expect to apply during implementation.

Hard requirements:

- If you cannot access/read `AGENTS.md`, STOP and ask the user to attach/share it (or provide relevant excerpts).
- You MUST apply those rules to all work produced by this command (even though this is planning-only).

Output requirement (auditability):

- In the final chat response, include a short section titled **“Standards loaded”** with:
  - confirmation that you read `AGENTS.md` (and any routed skill files), and
  - one short direct quote from `AGENTS.md` (max 1 line; under 120 characters), and
  - 2–5 bullets of the most relevant constraints you applied while writing the plan (e.g., schema verification hard-stop, smallest-change bias, verification gates).

---

## Step 0: Load issue + project context (MANDATORY)

1. Retrieve the Linear issue using Linear tools:
   - Use `get_issue` with the canonical issue key if possible.
   - If direct lookup fails, use `list_issues` / search to find the correct issue.
2. If the issue is part of a Linear project:
   - Retrieve the project details and read enough context to understand the project goals, constraints, and timeline.
   - Treat the project as the “host project” and summarize the relevant project context (what success looks like, constraints, related work).
3. Read the issue carefully:
   - Title, description, acceptance criteria, constraints, labels, priority, and any links/attachments.
   - Also read existing issue comments to avoid duplicating prior decisions.

Output requirement:

- In the final chat response, include a short list of “What I learned from the project” and “What I learned from the issue”.

---

## Step 0.5: Create (or switch to) a working branch (MANDATORY)

Problem this prevents:
- Agents sometimes continue later in the same conversation and accidentally start implementing on `dev` (or whatever branch they were already on). This step makes the “correct branch” state deterministic.

Rules:
- You MUST create (or switch to) a **local** branch for the issue while still in planning-only mode.
- You MUST NOT change code in this command.
- You MUST NOT push the branch remote until the plan is explicitly approved.

Minimum workflow (commands):

```bash
# Safety: do not switch branches with a dirty tree
git status --porcelain

# Ensure base refs exist locally
git fetch origin --prune

# Pick a base for the local working branch (prefer dev)
BASE_BRANCH="dev"
git show-ref --verify --quiet "refs/remotes/origin/$BASE_BRANCH" || BASE_BRANCH="$(git symbolic-ref -q --short refs/remotes/origin/HEAD | sed 's#^origin/##')"

# Resolve from canonical issue key + title (see Issue key resolution above)
ISSUE_KEY="HAV-24"          # normalized
ISSUE_TITLE="<issue title>"
ISSUE_PREFIX="${ISSUE_KEY%%-*}"
ISSUE_NUMBER="${ISSUE_KEY#*-}"
LINEAR_ID="$(printf '%s' "$ISSUE_PREFIX" | tr '[:upper:]' '[:lower:]')-${ISSUE_NUMBER}"
BRANCH_TYPE="feature"
ISSUE_SLUG="$(printf '%s' "$ISSUE_TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g; s/-+/-/g' | cut -c1-40)"
[ -n "$ISSUE_SLUG" ] || ISSUE_SLUG="wip"
BRANCH="${BRANCH_TYPE}/${LINEAR_ID}-${ISSUE_SLUG}"

# Switch/create idempotently
git show-ref --verify --quiet "refs/heads/$BRANCH" && git switch "$BRANCH" || git switch -c "$BRANCH" "origin/$BASE_BRANCH" --no-track

# Never track origin/dev from a feature branch — a plain `git push` would update dev.
git branch --unset-upstream 2>/dev/null || true

# Verify branch state (must print the issue branch)
git rev-parse --abbrev-ref HEAD
```

Hard stop:
- If `git status --porcelain` is non-empty, STOP and ask the user to clean/stash/commit before you proceed (do not guess what to do with their local changes).

---

## Step 1: Produce a detailed implementation plan (MANDATORY)

Create a **detailed implementation plan** in plain English that is easy to skim.

### Style requirements

- Use emojis in headings for scanability:
  - Main sections (##) must have an emoji.
  - Subsections (###) should have an emoji when helpful.
- Keep paragraphs short; prefer bullets, checklists, and tables where useful.
- If a diagram helps, include a Mermaid diagram (only if it improves clarity).

### Plan content requirements

Your plan MUST include:

- **🎯 Goal / Outcome**: what will be true when the issue is done.
- **📦 Scope**:
  - In-scope items
  - Out-of-scope items
- **🧭 Approach**: the intended technical approach and why it fits this repo’s conventions.
- **🧩 Implementation steps**: a step-by-step checklist (grouped by component/file/area).
- **🧪 Test plan**: what tests you will add/update and what commands you expect to run.
- **🔍 Validation / QA**: how to verify behavior beyond tests (smoke checks, manual flows, etc.).
- **🚀 Rollout plan** (if applicable): deploy sequencing, feature flags, backwards compatibility.
- **⚠️ Risks & mitigations**: top risks, how you will reduce them.
- **❓ Questions / confirmations**: any clarifications you need from the reviewer before implementing.
- **🪵 Tracking**: link related PRs/issues/docs (if known).

### Output format

Write the plan in Markdown, using this template (replace `<ISSUE_KEY>` with the canonical key, e.g. `HAV-24`):

```md
## 🧾 <ISSUE_KEY> Implementation Plan — <short title>

### 🎯 Goal / Outcome
- ...

### 📦 Scope
- **In scope**
  - [ ] ...
- **Out of scope**
  - ...

### 🧭 Approach
- ...

### 🧩 Implementation Steps
#### 🧱 <Area 1>
- [ ] ...

#### 🧱 <Area 2>
- [ ] ...

### 🧪 Test Plan
- [ ] ...
```bash
<commands>
```

### 🔍 Validation / QA
- ...

### 🚀 Rollout Plan (if applicable)
- ...

### ⚠️ Risks & Mitigations
- ...

### ❓ Questions / Confirmations
- ...

### 🪵 Tracking / Links
- Issue: <link>
- Project: <link if applicable>
```

---

## Step 2: Post the plan to Linear for review (MANDATORY)

Post the implementation plan as a **new comment** on the issue using Linear tools.

Rules:

- Do NOT edit/delete existing comments; add a new comment.
- The comment should clearly indicate it is a proposed plan awaiting approval.
- If the issue already has a previous plan comment from you, add a new comment with an updated timestamp and explain what changed.

---

## Step 3: Report back in chat (MANDATORY)

After posting the plan comment:

- Provide a brief, plain-English summary in chat (do NOT repeat the plan):
  - Resolved issue key (canonical form)
  - Key findings from the project + issue
  - A very short summary of the approach (3–6 bullets)
  - Local branch name created
  - Any blocking questions
- Include a link to the Linear issue (and ideally the specific comment, if you can reference it).

---

## Step 4: Do not implement until approved (MANDATORY)

After posting the plan, STOP.

- Do NOT change code.
- Do NOT push the branch remote.
- Do NOT run implementation tasks.

Wait for explicit user instruction like: “Plan approved, proceed.”

When (and only when) the plan is approved, the next steps will be:

- Push the already-created issue branch to remote:
  - `git push -u origin HEAD`
- Then proceed with implementation following the approved plan.
