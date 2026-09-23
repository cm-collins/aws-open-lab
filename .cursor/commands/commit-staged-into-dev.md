# commit-staged-into-dev

Land the **currently staged** changes into `dev`, then update your work to sit on top of that `dev` commit.

This is the “I accidentally built the change on my feature branch, but I want it committed to `dev` and my branch rebased on top of it” workflow.

Hard rules:

- **Commit staged changes only** (do not stage files).
- If there are **no staged changes**, stop and tell the user to stage files (or ask if they want you to stage).
- Use the temp file workflow for the commit message:
  - write `COMMIT_MESSAGE.txt` in repo root
  - commit using `git commit --file COMMIT_MESSAGE.txt`
  - delete `COMMIT_MESSAGE.txt` after a successful commit
- Do **not** use `--no-verify`, `--amend`, force pushes, or destructive git commands unless required by the workflow below.
- Do not rewrite `dev` history (no reset + force-push). If something wrong lands on `dev`, use `git revert`.
- Do not rewrite an already-pushed feature branch by default. Prefer creating a new branch on top of `origin/dev`.

---

## What “success” looks like

- `origin/dev` contains the new commit.
- Your work continues on a branch based on `origin/dev` (so history reads as if the landed change “was already in dev”).
- The original feature branch remains intact (no “did we lose commits?” moments).

---

## Execution steps

### 0) Preflight cleanup (always)

These steps make the workflow more reliable when the repo is in a half-finished git state.

Run:

- `git rebase --abort` (if a rebase is in progress; ignore errors)
- `git merge --abort` (if a merge is in progress; ignore errors)

### 0.1) Capture current state

Run:

- `git status`
- `git diff --cached --stat`
- `git diff --cached`
- `git rev-parse --abbrev-ref HEAD` (store as `FEATURE_BRANCH`)
- `git rev-parse HEAD` (store as `FEATURE_TIP_BEFORE`)
- `git fetch origin --prune`
- `git rev-parse origin/dev` (store as `DEV_TIP_BEFORE`)

If `FEATURE_BRANCH` is `dev`, stop and ask the user what branch should be updated after landing.

Mandatory safety gate:

- If `git status --porcelain` shows any unstaged/untracked changes beyond the staged set, stop and either:
  - stash them with `git stash push -u --keep-index -m "temp: unblock commit-staged-into-dev"`, or
  - commit them separately before continuing.

### 0.2) Create a safety snapshot (always)

Create an easy rollback point **before** any history rewrite:

- Set `FEATURE_BACKUP_REF="${FEATURE_BRANCH}-backup-${FEATURE_TIP_BEFORE}"`
- `git branch -f "$FEATURE_BACKUP_REF" "$FEATURE_TIP_BEFORE"`

Notes:

- This is a local backup ref. Do not delete it until the user confirms everything looks correct.
- Optional (recommended for extra safety): create and push a backup tag so the pre-change tip is recoverable even if your local repo gets wiped:
  - `BACKUP_TAG="backup/${FEATURE_BRANCH}/${FEATURE_TIP_BEFORE}"`
  - `git tag -a "$BACKUP_TAG" "$FEATURE_TIP_BEFORE" -m "backup before commit-staged-into-dev"`
  - `git push origin "$BACKUP_TAG"`

If something goes wrong, you can return to the pre-change state with:

- `git switch "$FEATURE_BRANCH"`
- `git reset --hard "$FEATURE_BACKUP_REF"`

### 0.3) Optional stash to unblock rebases (only if needed)

If you have untracked or unstaged local changes that might block the workflow (but you still want to keep the staged changes intact):

- Check: `git status --porcelain`
- If there are local changes beyond the staged set, run:
- `git stash push -u --keep-index -m "temp: unblock commit-staged-into-dev"`
  - Store the created stash ref as `UNBLOCK_STASH` (the newest `stash@{0}`).

At the end of the workflow, if `UNBLOCK_STASH` was created:

- `git stash pop`

If `stash pop` conflicts, resolve or leave it stashed and report to the user.

### 1) Commit the staged changes on the feature branch

Draft a commit message (use the repo’s normal style).

Write `COMMIT_MESSAGE.txt`, then:

- `git commit --file COMMIT_MESSAGE.txt`
- `rm COMMIT_MESSAGE.txt`

Capture the new commit hash as `LANDED_COMMIT` (`git rev-parse HEAD`).

### 2) Cherry-pick the commit onto `dev` and push

Run:

- `git fetch origin --prune`
- `git switch dev`
- `git pull --ff-only origin dev`
- `git cherry-pick $LANDED_COMMIT`
- `git push origin dev`

If cherry-pick conflicts, resolve them on `dev`, then continue and push (or stop and report if resolution is ambiguous).

Rollback note for `dev`:

- This workflow **does not rewrite `dev` history** (it pushes a new commit).
- If the user decides the landed change should not be on `dev`, the safe undo is usually:
  - `git switch dev && git pull --ff-only origin dev`
  - `git revert <dev-commit-hash>`
  - `git push origin dev`
  - (Avoid resetting `dev` unless the user explicitly asks and understands the impact on collaborators.)

### 3) Update your work to sit on top of `origin/dev` (safe default: no history rewrite)

#### Preferred path (safe): create a new branch on top of `origin/dev`

This avoids force-pushing and preserves the original branch as an easy “nothing got lost” anchor.

Run:

- `git fetch origin --prune`
- `git switch "$FEATURE_BRANCH"`
- `git switch -c "${FEATURE_BRANCH}-on-dev" origin/dev`

Cherry-pick **only** the feature work commits:

- `git log --oneline origin/dev.."$FEATURE_BACKUP_REF"`
- `git cherry-pick origin/dev.."$FEATURE_BACKUP_REF"`

Then publish the new branch:

- `git push -u origin HEAD`

If cherry-pick conflicts, resolve them and continue. The original branch is still untouched.

#### If cherry-pick fails because of local changes

This means there are local modifications/untracked files blocking the operation.

Run:

- `git stash push -u --keep-index -m "temp: unblock commit-staged-into-dev"`
- Re-run the branch creation + cherry-pick commands above
- `git stash pop`

If `stash pop` conflicts, resolve or leave it stashed and report to the user.

#### Optional (advanced): rewrite the original feature branch (only if the user explicitly asks)

If and only if the user wants the original branch name updated, you may point it at the new history and force-with-lease push:

- `git branch -f "$FEATURE_BRANCH" "${FEATURE_BRANCH}-on-dev"`
- `git switch "$FEATURE_BRANCH"`
- `git push --force-with-lease origin "$FEATURE_BRANCH"`

Do not do this by default.

### 4) Final verification (always do this)

Run:

- `git status`
- `git log --oneline --decorate -5`
- `git log --oneline origin/dev..HEAD` (on the new branch, this should be only your feature work commits)
- Evidence that nothing was dropped:
  - `git diff --stat "$FEATURE_BACKUP_REF"..HEAD`
  - `git diff "$FEATURE_BACKUP_REF"..HEAD` (spot-check key files)

Report:

- New `dev` commit hash (the cherry-picked hash on `dev`)
- New branch name and tip hash (e.g. `${FEATURE_BRANCH}-on-dev`)
- Confirm the original branch still exists at `FEATURE_TIP_BEFORE` (or via `FEATURE_BACKUP_REF`)

Cleanup note:

- Keep `FEATURE_BACKUP_REF` until the user confirms everything looks correct.
- If the workflow created `UNBLOCK_STASH`, ensure it was popped (or explicitly left in `git stash list` with a note).

