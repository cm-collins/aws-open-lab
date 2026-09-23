# review-parallel

Run a code audit using **multiple independent subagents** that each produce a full review; then **consolidate** their findings into a single merged report for `/fix-merged` to consume.

Use the review framework in @.cursor/prompts/general-code-audit-review-prompt.md.

---

## When to use

- You want to spawn several subagents to review the **same scope** in parallel (e.g. 3–4 agents).
- Each subagent performs a **full independent review** and writes its own report to **orchestrator-assigned paths only**.
- The orchestrator **merges** all subreports into one `AUDIT_REPORT_<RUN_ID>_MERGED.{md,json}` so `/fix-merged` has a single canonical input.

**Number of subagents (optional)**: You may specify how many subagents to use when you invoke the command (e.g. “use 2 subagents”, “run with 5 agents”). If you do not specify, the orchestrator uses a **default of 3 or 4**. The orchestrator MUST respect a user-specified number within a reasonable range (e.g. 2–6); if the user asks for more than the max, cap at the max and note it in the chat summary.

**Verification and concurrent runs**: If multiple subagents run build/test or other verification commands at the same time, they can contend for resources (CPU, memory, test output dirs) or shared state (DB, ports) and produce flaky or conflicting results. Subagents in this workflow must **not** run verification; the orchestrator runs it **once** after the merge (see Step 5).

**Run end-to-end**: The orchestrator MUST run the full workflow (Steps 1 through 6) in **one continuous run**. Do NOT pause after a step to say "Next I will do X" or to ask for approval before proceeding. Execute scope → shared context (if used) → spawn subagents → wait for them → merge → manifest → verification → chat summary without stopping. Only pause for user input when there is a **critical blocker** (e.g. cannot determine scope, tool/auth failure that cannot be worked around, or a real conflict that cannot be resolved without a user decision). The user expects to start the command and get a complete result without having to approve each phase.

**Subagents in Write mode**: When spawning subagents, the orchestrator MUST ensure **each** subagent runs in **Write mode** (not Read-Only). For **every** subagent you spawn (A, B, C, D, …), explicitly request or enable Write mode for **that** agent. If you spawn agents one at a time, request Write mode for every single spawn—do not assume the first agent’s permissions apply to the rest (e.g. agent D may still end up read-only if not explicitly given Write mode). Subagents that run read-only cannot write reports and the workflow will fail or be incomplete.

---

## Step 1: Orchestrator — Generate run ID and run directory (MANDATORY)

Before spawning any subagent, the orchestrator MUST:

1. Generate a unique `RUN_ID`: UTC timestamp plus a short random suffix (e.g. 4–6 alphanumeric chars) so concurrent runs never collide.
2. Create the run directory and ensure it exists.

```bash
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$(openssl rand -hex 3 2>/dev/null || echo $$)"
RUN_DIR="tmp/code-review/RUN_${RUN_ID}"
mkdir -p "$RUN_DIR"
echo "RUN_ID=$RUN_ID"
echo "RUN_DIR=$RUN_DIR"
```

3. Decide **scope** using the same rules as `/review` (see @.cursor/commands/review.md): staged/unstaged changes, or most recent commit. **For branch scope** (base..HEAD), use `/review-branch-parallel` instead.

---

## Step 1.5: Orchestrator — Gather shared context once (RECOMMENDED)

Before spawning subagents, the orchestrator SHOULD fetch **once** the information that every subagent will need according to the audit prompt. Write it into the run directory so subagents can use it as their starting point instead of each making duplicate calls (e.g. to Linear, or re-reading the same docs).

1. **Scope summary**: Capture a short summary of what is in scope (e.g. `git diff --cached --stat`, `git diff --stat`, or `git show --stat HEAD`, depending on scope).
2. **Linear** (if the repo/PR uses Linear): Fetch issues tied to this scope (e.g. branch name, PR title, or commit messages). Include issue identifiers, titles, and descriptions (or links). One orchestrator call instead of N subagent calls.
3. **Key docs** (optional): If scope clearly touches a known area, list the 1–3 most relevant source-of-truth docs (e.g. from `docs/architecture/`, `docs/product/`, `docs/BestPractices/`) and either paste a short summary or their paths. Subagents will still load more as needed per Step 0 of the audit prompt.

Write the result to:

- **`tmp/code-review/RUN_<RUN_ID>/shared_context.md`** — human-readable summary (scope, Linear issues, doc pointers). Create this file so subagents can be told “use this as your starting context”.

If useful, also write a minimal **`tmp/code-review/RUN_<RUN_ID>/shared_context.json`** (e.g. scope + list of Linear issue IDs/titles) for structured use. Keep both files concise.

In the subagent instructions (Step 2), point agents at `shared_context.md` (and optional JSON) and tell them they may still gather additional context as needed.

---

## Step 2: Orchestrator — Spawn subagents with explicit output paths (MANDATORY)

Determine **N** (number of subagents): use the user-specified number if given (see “Number of subagents” above), otherwise default to 3 or 4. Cap N at a reasonable maximum (e.g. 6). Spawn **N** subagents, **each** in **Write mode** (not Read-Only). For every spawn (A, then B, then C, then D, …), explicitly request Write mode for that agent—do not assume one request applies to all. **Each subagent must be given exact output paths**; they must not discover or invent their own.

- **Use Cursor’s custom subagent definition**: Spawn each subagent using the custom Cursor subagent `review-audit-subagent` (defined in @.cursor/agents/review-audit-subagent.md). This avoids “quirky” ad-hoc subagent behavior (unexpected read-only, wrong model, etc.) by using an explicit, named subagent configuration.
- Use distinct **agent tags** per subagent (e.g. `A`, `B`, `C`, `D` or `1`, `2`, `3`, `4`); use as many tags as N (e.g. for N=2 use A and B; for N=5 use A–E).
- For each subagent, pass **in the instructions** the exact paths it must write to:

| Agent tag | JSON path |
|-----------|-----------|
| A | `tmp/code-review/RUN_<RUN_ID>/AUDIT_REPORT_<RUN_ID>_A.json` |
| B | `.../AUDIT_REPORT_<RUN_ID>_B.json` |
| C | `.../AUDIT_REPORT_<RUN_ID>_C.json` |
| D | `.../AUDIT_REPORT_<RUN_ID>_D.json` |

Instruction text to give each subagent (customize `<RUN_ID>`, `<TAG>`, and scope as needed):

- **Shared context**: If you created `tmp/code-review/RUN_<RUN_ID>/shared_context.md` (and optional `shared_context.json`) in Step 1.5, tell each subagent: "Use the contents of `tmp/code-review/RUN_<RUN_ID>/shared_context.md` as your **starting context** (scope, Linear issues, key docs). You may still load additional context (e.g. further docs) as needed per the review framework."
- “You are running as the Cursor subagent **`review-audit-subagent`** (see @.cursor/agents/review-audit-subagent.md) and must follow its rules. **You MUST write your full report only to these paths** (do not use any other paths):
  - JSON: `tmp/code-review/RUN_<RUN_ID>/AUDIT_REPORT_<RUN_ID>_<TAG>.json`
  Review scope: [describe scope — e.g. staged changes, or branch BASE_SHA..HEAD]. Create the run directory if needed (`mkdir -p tmp/code-review/RUN_<RUN_ID>`), then write the reports to exactly these paths.”
- **Do NOT run build, test, or any other verification commands** (e.g. no `python -m pytest`). Only perform the code review and write the report. Verification will be run once by the orchestrator after the merge.
- **No pause / no progress-only checkpoint messages**: instruct each subagent to run end-to-end in one continuous pass and return only once it has either (a) written the JSON artifact, or (b) hit a true hard blocker. Subagents must not stop just to announce "next I will ...".

Subagents must **create new files only**; they must **never edit** existing report files.

---

## Step 3: Orchestrator — Consolidate subreports into merged report (MANDATORY)

After all subagents have finished and written their JSON reports:

1. **Collect** all valid per-subagent JSON files under `tmp/code-review/RUN_<RUN_ID>/` (A/B/C/D/...). Exclude `MANIFEST.json` and explicitly exclude any `*_MERGED.json`.
2. **Merge** using these rules:
   - **auditSummary**: Treat `verdict` precedence as `FAIL` > `ERROR` > `PASS`.
     - If **any** subreport has `verdict: "FAIL"`, the merged verdict is `FAIL`.
     - Else if **any** subreport has `verdict: "ERROR"`, the merged verdict is `ERROR`.
     - Otherwise the merged verdict is `PASS`.
     Merge or summarize other auditSummary fields (e.g. take the “worst” status per category, or concatenate short notes).
   - **findings (MANDATORY de-duplication)**:
     - Do **not** include previously merged files as inputs. Only merge per-subagent files (A/B/C/D/...). Explicitly exclude `*_MERGED.json`.
     - De-duplicate findings in two passes:
       1) **Exact-ish key**: `(normalized primary path, normalized line, normalized title)`
       2) **Semantic same-defect key**: same normalized primary path + strongly overlapping problem/fix intent (wording may differ between subagents).
     - Treat findings as duplicates when they describe the same defect with different wording (for example: same file/area and same failure mode, but different title phrasing).
     - Keep one canonical finding per duplicate group (prefer the highest priority / most complete evidence text), then merge provenance from all duplicates.
     - Renumber `id` sequentially from 1 after de-duplication.
     - Add **provenance** for every canonical finding: include all contributing subagent tags in `evidence.commands` (e.g. `sourceSubagents:A,B,D`).
     - If two findings are very close but not clearly the same defect, keep both and add a short note explaining why they were not merged.
   - **scope / contextDocumentsReviewed / verification**: Use the first subreport’s values, or merge (e.g. union of context documents). Set `generatedAt` to the merge time (UTC).
   - **Implementation requirement**: Use a deterministic scripted merge (Python) rather than ad-hoc manual reasoning when possible.
3. **Deterministic merge snippet (recommended default)**:

```bash
python - <<'PY'
from pathlib import Path
import json, re
from collections import defaultdict

run_id = "<RUN_ID>"
run_dir = Path(f"tmp/code-review/RUN_{run_id}")
paths = sorted(
    p for p in run_dir.glob(f"AUDIT_REPORT_{run_id}_*.json")
    if not p.name.endswith("_MERGED.json")
)
if not paths:
    raise SystemExit("No per-subagent JSON files found.")

prio_rank = {"P0": 0, "P1": 1, "P2": 2, "P3": 3}
all_reports = [json.loads(p.read_text(encoding="utf-8")) for p in paths]
raw_findings = []

def norm_text(s: str) -> str:
    s = (s or "").lower()
    s = re.sub(r"[^a-z0-9]+", " ", s).strip()
    return s

def path_line_key(f):
    loc = (f.get("locations") or [{}])[0]
    path = norm_text(loc.get("path", ""))
    line = str(loc.get("line", ""))
    return (path, line)

def exact_key(f):
    p, line = path_line_key(f)
    return (p, line, norm_text(f.get("title", "")))

def semantic_key(f):
    p, _ = path_line_key(f)
    problem = norm_text(f.get("problem", ""))
    fix = norm_text(f.get("fix", ""))
    signature = " ".join((problem + " " + fix).split()[:20])
    return (p, signature)

for report, path in zip(all_reports, paths):
    tag = path.stem.rsplit("_", 1)[-1]
    for f in report.get("findings", []):
        f = dict(f)
        f["_source_tag"] = tag
        raw_findings.append(f)

# pass 1: exact-ish dedupe
groups = defaultdict(list)
for f in raw_findings:
    groups[exact_key(f)].append(f)

pass1 = []
for _, group in groups.items():
    group = sorted(group, key=lambda x: (prio_rank.get(x.get("priority", "P3"), 9), -len(x.get("problem",""))))
    best = dict(group[0])
    tags = sorted({g["_source_tag"] for g in group})
    cmds = list((best.get("evidence") or {}).get("commands") or [])
    cmds = [c for c in cmds if not str(c).startswith("sourceSubagent:")]
    cmds.append(f"sourceSubagents:{','.join(tags)}")
    best.setdefault("evidence", {})["commands"] = cmds
    pass1.append(best)

# pass 2: semantic dedupe by path+problem/fix signature
groups2 = defaultdict(list)
for f in pass1:
    groups2[semantic_key(f)].append(f)

final_findings = []
for _, group in groups2.items():
    group = sorted(group, key=lambda x: (prio_rank.get(x.get("priority", "P3"), 9), -len(x.get("problem",""))))
    best = dict(group[0])
    tags = set()
    for g in group:
        for c in (g.get("evidence") or {}).get("commands", []):
            if str(c).startswith("sourceSubagents:"):
                tags.update(str(c).split(":",1)[1].split(","))
    if tags:
        cmds = [c for c in (best.get("evidence") or {}).get("commands", []) if not str(c).startswith("sourceSubagents:")]
        cmds.append(f"sourceSubagents:{','.join(sorted(tags))}")
        best.setdefault("evidence", {})["commands"] = cmds
    final_findings.append(best)

for i, f in enumerate(final_findings, start=1):
    f["id"] = i
    f.pop("_source_tag", None)

merged = dict(all_reports[0])
merged["findings"] = final_findings
merged.setdefault("verification", {})["notes"] = (
    f"Merged from {len(paths)} subreports; raw={len(raw_findings)}, "
    f"after_pass1={len(pass1)}, final={len(final_findings)}"
)

out_json = run_dir / f"AUDIT_REPORT_{run_id}_MERGED.json"
out_json.write_text(json.dumps(merged, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"Wrote {out_json}")
print(f"raw_findings={len(raw_findings)} duplicates_merged={len(raw_findings)-len(final_findings)} final={len(final_findings)}")
PY
```
4. **Write** the merged report to:
   - `tmp/code-review/RUN_<RUN_ID>/AUDIT_REPORT_<RUN_ID>_MERGED.json`
   - `tmp/code-review/RUN_<RUN_ID>/AUDIT_REPORT_<RUN_ID>_MERGED.md` (same content as the merged findings/summary in the standard Step 4 format from the audit prompt).
5. **Validate** the merged JSON parses as a single object:

```bash
python -c 'import json,sys; json.load(open(sys.argv[1],"r",encoding="utf-8"))' "tmp/code-review/RUN_<RUN_ID>/AUDIT_REPORT_<RUN_ID>_MERGED.json"
```

6. **Completion gate (MANDATORY)**: before moving on, confirm both merged artifacts exist.

```bash
test -f "tmp/code-review/RUN_<RUN_ID>/AUDIT_REPORT_<RUN_ID>_MERGED.json"
test -f "tmp/code-review/RUN_<RUN_ID>/AUDIT_REPORT_<RUN_ID>_MERGED.md"
```

If either merged artifact is missing, the run is **not complete**. Do not continue to Step 4 or report success in chat.

---

## Step 4: Orchestrator — Write manifest (MANDATORY)

Write `tmp/code-review/RUN_<RUN_ID>/MANIFEST.json` listing all subreports and the merged report:

```json
{
  "runId": "<RUN_ID>",
  "runDir": "tmp/code-review/RUN_<RUN_ID>",
  "subreports": [
    { "tag": "A", "json": "tmp/code-review/RUN_<RUN_ID>/AUDIT_REPORT_<RUN_ID>_A.json" },
    { "tag": "B", "json": "..." }
  ],
  "mergedReport": {
    "json": "tmp/code-review/RUN_<RUN_ID>/AUDIT_REPORT_<RUN_ID>_MERGED.json",
    "md": "tmp/code-review/RUN_<RUN_ID>/AUDIT_REPORT_<RUN_ID>_MERGED.md"
  }
}
```

After writing the manifest, confirm it exists:

```bash
test -f "tmp/code-review/RUN_<RUN_ID>/MANIFEST.json"
```

If `MANIFEST.json` is missing, the run is **not complete**. Do not continue to Step 5 or report success in chat.

---

## Step 5: Orchestrator — Run verification once (MANDATORY)

After writing the manifest, run verification **once** so the merged run has a single build/test result (avoids contention from multiple subagents running tests in parallel).

- Run the smallest set of commands that gives confidence for the reviewed scope (e.g. `dotnet test`, `pnpm test`, `flutter analyze`, or the same commands the audit prompt suggests for the repo).
- Record the outcome (pass/fail and any failure summary) for the final chat summary.

---

## Step 6: Chat output (MANDATORY)

In chat, output a short summary only (do not paste full reports or JSON):

- RUN_ID and RUN_DIR.
- Number of subagents spawned and paths to their reports.
- Path to the **merged report** (use `/fix-merged` to fix issues from this report).
- Merged verdict (PASS/FAIL/ERROR) and finding count.
- De-duplication summary: total raw findings, duplicates merged, final unique findings.
- **Verification**: Build/tests run once by orchestrator — pass/fail (and brief notes if failed).

Before sending the chat summary, the orchestrator MUST have already verified that all three files exist:

- `tmp/code-review/RUN_<RUN_ID>/AUDIT_REPORT_<RUN_ID>_MERGED.json`
- `tmp/code-review/RUN_<RUN_ID>/AUDIT_REPORT_<RUN_ID>_MERGED.md`
- `tmp/code-review/RUN_<RUN_ID>/MANIFEST.json`

If any of those files is missing, treat the command as failed/incomplete instead of reporting a successful run.

---

## Constraints

- **Run end-to-end**: The orchestrator must not pause for approval between steps; run Steps 1–6 to completion unless a critical blocker requires user input.
- **Subagents in Write mode**: For **each** subagent (A, B, C, D, …), explicitly request Write mode when spawning that agent; do not assume the first agent’s mode applies to the rest. Read-only subagents cannot produce reports.
- **No shared filenames**: Each subagent writes only to its assigned `_<TAG>` paths.
- **Orchestrator never reviews code**: It generates RUN_ID, optionally gathers shared context once (Step 1.5), spawns subagents with explicit paths, merges, writes MANIFEST, runs verification once, then reports.
- **Shared context is optional**: If the orchestrator creates `shared_context.md` (and optional `shared_context.json`), subagents use it as their starting context and may still load more; if not created, subagents gather all context themselves per the audit prompt.
- **Subagents do not run verification**: They only review and write reports; the orchestrator runs build/test once to avoid concurrent contention.
- **Subagents never merge**: They only run the standard audit and write to their given paths; they must use the paths provided (parallel-mode rule in the audit prompt).
