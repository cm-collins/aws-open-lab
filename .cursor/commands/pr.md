# pr

Create (or update) a pull request using GitHub CLI (`gh`) when the user asks for one.

Hard rules:

- Always use GitHub CLI to **create or update** the PR (never “just print a message”).
- Always follow the “file body” workflow:
  - write to `PR_MESSAGE.txt`
  - create/update PR using `gh ... --body-file PR_MESSAGE.txt`
  - delete `PR_MESSAGE.txt` after successful PR creation/update
- Always end by outputting the **PR URL** (and nothing else).
- **Safety gate for protected base branches**:
  - If the inferred/selected PR base branch is `main` or `master` (or any alias that resolves to `origin/main` or `origin/master`), you MUST stop and ask the user to explicitly confirm that targeting `main`/`master` is what they want.
  - You MUST NOT create or update the PR targeting `main`/`master` unless and until the user gives explicit confirmation in this conversation.

---

## PR message format

Format:

# <emoji> <Title> (<Issue ID if applicable>)

## 📋 Overview

<2-3 sentences describing what the PR does and why. Include context about the problem being solved or feature being added.>

## ✨ What's Included

### <emoji> <Section Title>

<Description of what's in this section>

- <Detail 1>
- <Detail 2>
- <More bullets as needed>

### <emoji> <Another Section>

<Description>

- <Detail 1>
- <Detail 2>

## <emoji> <Philosophy/Design Section> (if applicable)

### <emoji> <Subsection>

<Explanation of design decisions or approach>

## ✅ Test Results / Verification

✅ **Key result 1**

- Detail 1
- Detail 2

✅ **Key result 2**

## 📁 Files Changed

- <Summary of file changes>
- <Key files or directories affected>

## ✅ Verification Checklist

- [x]  ✅ <Checklist item 1>
- [x]  ✅ <Checklist item 2>
- [x]  ✅ <Checklist item 3>

## 🔗 Related

- <Link to related issue or documentation>

Rules:

- **Use emojis ONLY on:**
  - Main title (one emoji)
  - Section headers (##) - one emoji per section
  - Subsection headers (###) - one emoji per subsection
  - Checklist items (✅ emoji before each item)
- **Do NOT use emojis in body text** - keep descriptions clean
- Be comprehensive but organized - cover all major aspects
- Include test results, verification steps, and related links
- Always include a verification checklist showing what was tested/verified

---

## Execution steps (ensure PR message is accurate)

Do **not** write a PR message from memory. Build it from the commits + diff that will be included.

1. **Verify scope**:
   - `git status`
2. **Determine the base branch automatically** (infer the branch HEAD most likely forked from):
   - Ensure remotes are up to date:
     - `git fetch origin --prune`
   - Get the repo default branch (used as a candidate + fallback):
     - `git symbolic-ref refs/remotes/origin/HEAD` (extract the branch name)
   - Build a small ordered candidate set (include only those that exist on `origin`):
     - default branch from `origin/HEAD`
     - `dev`, `develop`, `main`, `master`
   - For each candidate `origin/<candidate>`, compute the merge-base with `HEAD` and pick the candidate whose merge-base has the **most recent commit timestamp** (this is typically the branch you forked from when `dev` is ahead of `main`):
     - You may use this non-interactive snippet:
       - `DEFAULT_BRANCH="$(git symbolic-ref -q --short refs/remotes/origin/HEAD | sed 's#^origin/##')"`
       - `CANDIDATES="$DEFAULT_BRANCH dev develop main master"`
       - `BEST_BASE=""`
       - `BEST_TS=0`
       - `for b in $CANDIDATES; do git show-ref --verify --quiet "refs/remotes/origin/$b" || continue; mb="$(git merge-base "origin/$b" HEAD)" || continue; ts="$(git show -s --format=%ct "$mb" 2>/dev/null || echo 0)"; if [ "$ts" -gt "$BEST_TS" ]; then BEST_TS="$ts"; BEST_BASE="$b"; fi; done`
       - `BASE_BRANCH="${BEST_BASE:-$DEFAULT_BRANCH}"`
   - If inference fails, fall back to the default branch from `origin/HEAD` (or `main`, then `master`).
   - **Safety gate**: if `BASE_BRANCH` resolves to `main` or `master`, STOP and ask the user to explicitly confirm they want to target `main`/`master`. Do not proceed until they confirm.
3. **Review ALL commits that will be in the PR**:
   - `git log --oneline --decorate <base>..HEAD`
4. **Review the net change vs base** (this is the PR’s true diff):
   - `git diff --stat <base>...HEAD`
   - `git diff <base>...HEAD`
5. **Draft the PR title + body** using the template above:
   - Summary should reflect the net diff and the intent across commits (not just the latest commit).
   - Test plan should match what was actually run (or explicitly list TODOs).
6. **Write `PR_MESSAGE.txt`** in repo root with the PR body.
7. **Ensure the current branch is pushed** (create upstream if missing):
   - Prefer:
     - `git push -u origin HEAD`
   - If an upstream already exists and you only need to sync:
     - `git push`
8. **Create or update the PR using GitHub CLI** (never skip this step):
   - First, check if a PR already exists for this branch:
     - `gh pr view --json url --jq .url`
   - If a PR exists:
     - `gh pr edit --title "<title>" --body-file PR_MESSAGE.txt`
     - Output the PR URL from `gh pr view --json url --jq .url`
   - If a PR does not exist:
     - `gh pr create --base <base-branch> --head <head-branch> --title "<title>" --body-file PR_MESSAGE.txt`
     - Output the PR URL (capture from command output or via `gh pr view --json url --jq .url`)
9. **Delete `PR_MESSAGE.txt`** after successful PR creation/update.

