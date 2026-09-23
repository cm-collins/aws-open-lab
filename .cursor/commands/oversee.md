# oversee

Use the custom Cursor subagent **`productowner`** (defined in @.cursor/agents/productowner.md) as a reusable Product Owner assistant + technical gatekeeper for decisions.

This command is for when you want an “overseer / Product Owner / Architect assistant” voice to:

- Validate work from other agents
- Check alignment against the **PRD** (source of truth unless you state otherwise) + your explicit instructions + repo standards
- Provide a crisp APPROVE/BLOCK/NEEDS-INFO verdict with concrete next steps

---

## How to run (MANDATORY)

1. Identify what decision is being asked. Prefer one of:
   - “Is this ready to merge?”
   - “Does this align with the PRD / requirements?”
   - “Does this align with HAV-### intent (only if you want the Linear issue to be authoritative)?”
   - “Did we fix only the intended scope?”
   - “Are there hidden risks / drift?”

2. Provide the productowner subagent with the minimal necessary inputs:
   - PRD / requirements doc path(s) or the specific section(s) that define the behavior (preferred)
   - HAV key(s) (e.g. `HAV-172`) only if you want them considered authoritative or referenced by the PRD
   - PR URL or branch range (BASE..HEAD) if relevant
   - Review run directory `tmp/code-review/RUN_<RUN_ID>/` if reviewing an audit run
   - Merged audit report path `.../AUDIT_REPORT_<RUN_ID>_MERGED.json` if available

3. Spawn the Cursor subagent **`productowner`** and ask it for a verdict using its required output format.

---

## Output

The productowner subagent returns:

- **Verdict**: APPROVE / BLOCK / NEEDS-INFO
- A short “why”
- Required changes or minimum questions (if needed)

Communication note: responses should be written in simple, clear, plain English (per @.cursor/agents/productowner.md) and should not label sections with “plain English” in headings.

