# review-branch

Use the review framework in @.cursor/prompts/general-code-audit-review-prompt.md.

The only difference for `/review-branch` is **what to review** (scope selection): review **all commits in the branch** since the branch began.

---

## Scope selection (MANDATORY)

Pick a base SHA, then review **everything from base to HEAD**.

```bash
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
git fetch origin --prune
```

### If `BRANCH` is NOT `dev`, `main`, or `master` (feature/topic branch)

Compute the most likely base branch and the branch start (merge-base):

```bash
DEFAULT_BRANCH="$(git symbolic-ref -q --short refs/remotes/origin/HEAD | sed 's#^origin/##')"
CANDIDATES="$DEFAULT_BRANCH dev develop main master"
BEST_BASE=""
BEST_TS=0
for b in $CANDIDATES; do
  git show-ref --verify --quiet "refs/remotes/origin/$b" || continue
  mb="$(git merge-base "origin/$b" HEAD)" || continue
  ts="$(git show -s --format=%ct "$mb" 2>/dev/null || echo 0)"
  if [ "$ts" -gt "$BEST_TS" ]; then
    BEST_TS="$ts"
    BEST_BASE="$b"
  fi
done
BASE_BRANCH="${BEST_BASE:-$DEFAULT_BRANCH}"
BASE_SHA="$(git merge-base "origin/$BASE_BRANCH" HEAD)"
```

### If `BRANCH` is `dev` or `main` or `master`

Review **all commits since the last PR merged into that branch** (prefer `gh`, fallback to git history):

```bash
LAST_PR_MERGE_SHA="$(gh pr list --base "$BRANCH" --state merged --limit 1 --json mergeCommit --jq '.[0].mergeCommit.oid' 2>/dev/null || true)"
if [ -n "$LAST_PR_MERGE_SHA" ]; then
  BASE_SHA="$LAST_PR_MERGE_SHA"
else
  BASE_SHA="$(git log --first-parent --merges -n 1 --format=%H)"
fi
```

Now review the full commit set + net diff:

```bash
git log --oneline --decorate "$BASE_SHA"..HEAD

git diff --stat "$BASE_SHA"...HEAD
git diff "$BASE_SHA"...HEAD
```

If a **Linear issue like `HAV-###` is mentioned** (user message, branch name, commits, PR title/body):

  - Retrieve the issue **body AND comments** using Linear tools (if direct lookup fails, search issues by query).
  - Treat comments as authoritative clarifications (e.g., “prefer sentinel `outboxStatus=\"none\"`”, scope boundaries, implementation notes).
  - Use **issue body + comments** as requirements context and verify the branch commits meet its acceptance criteria.
  - If comments contradict the issue body, explicitly flag the discrepancy in the audit report and state which source you followed (and why).

---

## How to apply the framework

Follow @.cursor/prompts/general-code-audit-review-prompt.md exactly, with these scope overrides:

- **Step 1: Discover Scope**: use `BASE_SHA` and review the full range (`git log BASE_SHA..HEAD` and `git diff BASE_SHA...HEAD`).
- **Constraints**: audit the whole selected commit range (not just the working tree).

---

## Output files (MANDATORY)

Write reports to **unique, timestamped filenames** so repeated runs (and parallel agents) never conflict.

```bash
REPORT_TS="$(date -u +%Y%m%dT%H%M%SZ)"
REPORT_MD="tmp/code-review/AUDIT_REPORT_${REPORT_TS}.md"
REPORT_JSON="tmp/code-review/AUDIT_REPORT_${REPORT_TS}.json"
mkdir -p tmp/code-review
printf 'Report paths:\n- %s\n- %s\n' "$REPORT_MD" "$REPORT_JSON"
```

Then write the full reports to **exactly those paths**, per @.cursor/prompts/general-code-audit-review-prompt.md.

