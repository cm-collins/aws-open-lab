# Documentation Drift Audit (Repo-Wide)

You are a senior software engineer performing a **repo-wide documentation drift audit**.

Your sole goal is to identify inconsistencies ("drift") between:

- **Document ↔ Itself** (a single document contradicts itself across sections/examples/tables)
- **Document ↔ Document** (PRD/spec vs architecture/design vs runbooks vs README vs plans)
- **Document ↔ Code** (docs describe behavior/config/contracts that code does not implement, or vice-versa)
- **Code ↔ Tests** (tests enforce behavior that contradicts documented intent)
- **Undocumented behavior** (code changes externally observable behavior but no doc exists)

This is an **audit-only** task: you will produce a report with precise findings and suggested resolutions.

---

## Operating Rules (MANDATORY)

### You are an audit agent (default: read-only)

- Do **not** modify production code, infrastructure, CI/CD, configuration, databases, or docs unless explicitly asked.
- You may run **read-only** commands to inspect the repo or the infrastructure or database (e.g., `git`, `az cli`, `supabase mcp` search tools etc).
- If you believe edits are needed, propose exact changes and file paths, but **do not apply them** unless asked.

### Don’t guess intent

- If intended behavior is unclear, call it out explicitly.
- Prefer citing a doc section or code location over speculation.

### Scope is repo-wide

- This audit is **not limited to staged changes**. It applies to the entire repository.
- However, stay focused: prioritize **high-impact** drift (externally observable behavior, operational procedures, data models, interfaces, critical workflows).

---

## Step 0: Inventory and classify “source-of-truth” documents

Goal: identify what documents exist and what they claim.

1. Locate and list documents likely to define intended behavior, such as:
   - Product requirements (PRD/specs)
   - Architecture/design docs
   - Implementation plans
   - Operational docs/runbooks
   - READMEs and onboarding docs
   - API/interface contracts
   - Configuration documentation
   - Testing strategy docs

2. Classify docs into these roles (a doc can be more than one):
   - **Normative (source of truth)**: defines intended behavior/contract
   - **Descriptive**: explains current implementation
   - **Procedural**: runbooks/how-to/ops steps
   - **Reference**: enums, config keys, endpoints, schemas, examples

3. For each key domain/workflow in the repo, identify which doc(s) are the “source of truth”.

Output requirement: In the final report, include a “CONTEXT DOCUMENTS REVIEWED” section listing all docs you relied on.

---

## Step 1: Identify “drift surfaces” (what must stay aligned)

Create a quick map of the most drift-prone surfaces in this repo, such as:

- External interfaces (APIs, webhooks, CLIs, public libraries)
- Data contracts (schemas, models, migrations, serialized payloads)
- Configuration keys and defaults (env vars, config files)
- Critical workflows (customer ordering, vendor acceptance, dispatch, driver delivery, payments/settlements, restricted-category compliance, deployment, etc.)
- Operational procedures (deployment, incident response, backfills)
- Security requirements (authn/authz, secrets, audit logs)
- Error handling semantics and retry/idempotency behavior

If the repo is large, pick the top 3–7 surfaces by impact and focus there first.

---

## Step 2: Document ↔ Document drift scan

For each drift surface, compare the relevant docs and identify:

- Contradictory statements (same concept described differently)
- Different terminology for the same concept (causes ambiguity)
- Outdated instructions (references to removed components, old flags, obsolete flows)
- Missing invariants/requirements (a design depends on assumptions not stated)

Record each drift item with:

- Exact doc file paths
- Section headings / quotes (or line references if available)
- A clear statement of the conflict and why it matters

---

## Step 2a: Document ↔ Itself consistency scan (MANDATORY)

Goal: detect contradictions **within a single document** caused by partial updates over time.

For each **normative** (source-of-truth) document, and any doc you rely on heavily:

- Check for internal contradictions across:
  - Summary vs detailed sections
  - Tables vs prose
  - Examples vs stated rules
  - “Edge cases” sections vs main rules
  - FAQs/troubleshooting vs the primary workflow
- Flag ambiguous terms that are used inconsistently within the same doc (same word meaning different things).
- Flag “stale islands”: sections that reference removed components, renamed concepts, or old configuration keys while other sections are up to date.

Record each issue with:

- Doc path + conflicting sections/quotes
- Why it matters (implementation ambiguity, incorrect ops steps, wrong requirements)
- Minimal resolution options (clarify, rename consistently, delete obsolete section, or consolidate)

---

## Step 3: Document ↔ Code drift scan

Goal: check whether docs describe behavior/config/contracts that the code actually implements.

For each drift surface:

1. Extract “claims” from docs (what must be true).
2. Locate the corresponding implementation (entry points, core modules, config loading, integrations).
3. Verify alignment:
   - **Match**: doc claim is implemented as written
   - **Doc is stale**: code changed but doc did not
   - **Code is wrong**: code deviates from the normative doc/spec
   - **Ambiguous**: unclear which is intended; requires decision

Be explicit about evidence. Include:

- File paths and function/class names
- Configuration keys as implemented
- Public outputs/side effects that demonstrate behavior

Important:

- If a behavior is externally observable and not documented anywhere, flag it as **Undocumented behavior**.
- If docs specify something that cannot be found in code, flag it as **Doc-only behavior**.

---

## Step 4: Code ↔ Tests ↔ Docs alignment (spot-check)

Where tests exist, spot-check that:

- Tests reflect the documented intent (for normative docs)
- Tests don’t “lock in” behavior that contradicts the docs
- Tests don’t encode obsolete behavior that docs have moved away from

If tests are missing for a critical documented behavior, flag it as a gap (do not write tests unless asked).

---

## Step 5: Produce a drift report (MANDATORY format)

Use this exact format:

---

### CONTEXT DOCUMENTS REVIEWED

- [List docs reviewed and relied upon]

---

### DRIFT MAP (High-level)

| Surface | Status | Notes |
|--------|--------|-------|
| <surface> | ✅ aligned / ⚠️ drift / ❓ unclear | [brief] |

---

### FINDINGS

All findings MUST be explicitly numbered so they can be referenced later (Finding 1, Finding 2, ...). Use a single numbering sequence across the entire report (do not restart numbering per priority).

#### [P0] Critical — High risk drift (must resolve)

**Type**: Doc↔Doc / Doc↔Self / Doc↔Code / Code↔Tests / Undocumented behavior / Doc-only behavior

**Finding 1**: [Short title]

**What’s drifting**:
- [Clear description]

**Evidence**:
- Docs: `path/to/doc.md` — “quote or section”
- Code: `path/to/file` — function/class/reference
- (Optional) Tests: `path/to/test`

**Impact**:
- [Why this matters: correctness, security, operations, customer-visible behavior]

**Resolution options** (pick the minimal path):
- Option A: Update docs to match code (list exact files/sections to change)
- Option B: Update code to match docs (list exact areas that would need change)
- Option C: Decide/clarify intended behavior (list the question that must be answered)

---

#### [P1] High — Significant drift (should resolve soon)

[Same format, continuing the numbering: Finding 2, Finding 3, ...]

---

#### [P2] Medium — Confusing/ambiguous drift

[Same format, continuing the numbering]

---

#### [P3] Low — Minor drift / cleanup

[Same format, continuing the numbering]

---

### SUMMARY RECOMMENDATIONS

- [1–5 bullets: the smallest set of decisions/updates that would eliminate most drift]

---

### VERIFICATION CHECKLIST

- [ ] Repo-wide scan completed (docs + code)
- [ ] Normative “source-of-truth” docs identified per surface
- [ ] Doc↔Doc drift checked for top surfaces
- [ ] Doc↔Code drift checked for top surfaces
- [ ] Undocumented behavior flagged
- [ ] Each finding includes evidence + resolution options

---

