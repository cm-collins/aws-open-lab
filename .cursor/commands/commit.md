# commit

Create a git commit for the **already-staged** changes.

Hard rules:

- Commit **staged changes only** (never stage files as part of `/commit`).
- If there are **no staged changes**, do not commit; tell the user what to do next.
- Use a temp file workflow:
  - write the message to `COMMIT_MESSAGE.txt` in repo root
  - commit using `git commit --file COMMIT_MESSAGE.txt`
  - delete `COMMIT_MESSAGE.txt` after a successful commit
- Do **not** use `--no-verify`, `--amend`, force pushes, or destructive git commands unless the user explicitly asks.
- Use **simple plain English** for the commit title, the introduction sentence(s), and the final summary line so they are easy to understand quickly.
- Technical details are allowed in bullet points, but keep core intent language clear and non-jargony.

---

## SIMPLE CHANGE TEMPLATE (default)

Format:

<emoji> <type>(<scope>): <what changed and why>

<One short sentence that gives a bit more detail on what changed and why. Keep it to 1–2 lines max.>

- <Change detail 1>
- <Change detail 2>
- <More bullets as needed, but keep it concise>

Summary: <very short impact summary, 1 line>.

Rules:

- `<type>` is usually: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.
- `<scope>` is a short area name like `auth`, `api`, `ui`, `db`, etc.
- Subject line is imperative: "add", "update", "fix", not "added".
- Subject line should be simple plain English and easy for a non-specialist teammate to understand.
- Keep everything compact; do NOT add long paragraphs.
- Emoji usage:
  - Use **exactly one** emoji at the start of the subject line.
  - Do **not** use emojis elsewhere in the body text.
  - Required mapping: `✨ feat`, `🐛 fix`, `🧹 chore`, `📝 docs`, `♻️ refactor`, `✅ test`, `🎨 style`, `🔧 config`, `🚀 ci`

Example style (do not reuse verbatim):

✨ feat(auth): add JWT-based login

Replace session-based authentication with JWTs to enable stateless API calls from mobile clients.

- Add /auth/login route returning access and refresh tokens
- Store password hashes using argon2
- Update auth middleware to validate JWT on each request

Summary: Enables stateless auth for mobile clients.

---

## COMPLEX CHANGE TEMPLATE (use only when needed)

Use this if the change touches multiple parts of the system, migrations, or non-trivial logic — but keep it brief.

Format:

<emoji> <type>: <short, high-level description of the change and why>

Rationale:
<1–2 short sentences explaining why this change is needed.>

Changes:

- <Key change 1>
- <Key change 2>

Technical:

- <Important technical detail 1>
- <Important technical detail 2>

Summary:
<1 short sentence summarizing the overall impact>.

Plain-English rule:

- In the complex template, keep the **title**, **Rationale**, and **Summary** in simple plain English.
- Put deeper technical wording in the **Changes** and **Technical** sections.

---

## Execution steps (do this, don’t just output text)

1. Verify scope:
   - `git status`
   - `git diff --cached --stat`
   - `git diff --cached`
2. If nothing is staged, stop and instruct the user to stage files (or ask if they want you to stage).
3. Draft the commit message using the templates above (infer scope/intent from the staged diff).
4. Write `COMMIT_MESSAGE.txt` in repo root with the message.
5. Run `git commit --file COMMIT_MESSAGE.txt`
6. Delete `COMMIT_MESSAGE.txt`
7. Run `git status` and report success (include the new commit hash).

