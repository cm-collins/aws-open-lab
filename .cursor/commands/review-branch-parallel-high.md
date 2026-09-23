# review-branch-parallel-high

Run the same workflow as `/review-branch-parallel`, but use the **high-depth** custom subagent:

- `review-audit-subagent-high` (defined in @.cursor/agents/review-audit-subagent-high.md)

Use this when you want a deeper branch-wide parallel audit pass.

---

## How to run

Follow @.cursor/commands/review-branch-parallel.md **exactly** (all steps and constraints), with one override:

- In **Step 2 (spawn subagents)**, spawn `review-audit-subagent-high` instead of `review-audit-subagent`.
- In the subagent instruction text, reference `@.cursor/agents/review-audit-subagent-high.md`.

Everything else remains the same:

- branch-scope computation via @.cursor/commands/review-branch.md
- RUN_ID/run directory behavior
- shared context generation
- explicit output paths per subagent
- merged report + manifest behavior
- one-time orchestrator verification
- end-to-end, no-pauses behavior

---

## Constraints

- All constraints from @.cursor/commands/review-branch-parallel.md apply.
- Only the subagent identity/model changes.

