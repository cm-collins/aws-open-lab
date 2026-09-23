Create Linear issues for implementing this repo's current PRD/TRD or source-of-truth plan. Use small, dependency-aware issues that fit Havey platform work: customer and driver mobile apps, vendor and operations web apps, ASP.NET Core backend, Supabase data layer, dispatch/order flows, payments and settlements, compliance for restricted categories, and Azure infrastructure.

Structure the work using dependency-driven sequencing at two levels:
	1.	across phases, and
	2.	within tasks inside each phase.

Do not create issues just to increase issue count. I want a small set of well-scoped, reasonable units of work. Each issue should represent a chunk that can be executed independently by an AI agent from start to finish, once its dependencies are satisfied.

Each issue should:
	•	belong to the `Havey` Linear team
	•	use the repo's required issue template from `docs/development/linear-issue-workflow.md`
	•	have a clear objective and completion criteria
	•	be self-contained enough for one agent to own end-to-end
	•	explicitly note any prerequisite issue(s) using `HAV-*` identifiers
	•	fit logically into the dependency order of the overall project

Prioritize clarity, execution flow, and minimal coordination overhead over exhaustive decomposition.
