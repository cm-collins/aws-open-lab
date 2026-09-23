---
name: senior-dotnet-engineer
description: Senior workflow for .NET and C# work in this repo. Use when editing ASP.NET, Azure Functions in C#, workers, integrations, EF/data access, .NET tests, or backend docs/config tied to .NET behavior.
---

# Senior .NET Engineer

Use this skill only for .NET/C# work. Stay diff-first, keep changes proportional, and preserve existing behavior unless the user asked for a change.

## Quick Start

1. Confirm scope from the actual diff and touched files.
2. Load deeper docs when the change area requires them.
3. Make the smallest correct change.
4. Run the smallest verification set that gives confidence.
5. Do a documentation drift pass before finishing.

## Hard Rules

- Base decisions on the actual change, not assumptions.
- If a required design/spec/best-practice doc is missing, stop and ask for it.
- If you expand beyond a surgical patch, explain what expanded and why the smaller change was worse.
- Do not guess DB schema, queue semantics, auth behavior, or external contracts.

## Load Deeper Docs When Needed

- .NET/C# changes: `docs/BestPractices/dotnet-coding-standards.md`
- Postgres, Supabase, RLS, migrations: `docs/BestPractices/supabase-postgresql.md`
- Data architecture: `docs/architecture/data.md`
- Backend development: `docs/development/backend-development.md`
- Testing strategy: `docs/BestPractices/testing-best-practices-general.md` and `docs/BestPractices/testing-best-practices-repo-specific.md`
- Business rules: `docs/business-rules/README.md`
- Review rubric: `.cursor/prompts/general-code-audit-review-prompt.md`

## Review Checklist

### Correctness

- Logic matches the requested behavior and handles edge cases.
- Nullability is safe; avoid casual use of `!`.
- Time/date handling is correct; prefer UTC and `DateTimeOffset` where relevant.
- Changes are backward-compatible unless a breaking change was requested.
- Retries and replays do not double-apply side effects.

### Security

- No secrets in code, logs, tests, fixtures, or docs.
- Validate external input: HTTP, env vars, queue payloads, CLI args, config.
- Use parameterized DB access only.
- Authorization checks are complete and do not widen access by accident.
- Review SSRF, open redirect, path traversal, and unsafe deserialization risks where applicable.

### Performance

- Keep request and worker flows async end-to-end.
- Do not use `.Result`, `.Wait()`, or `GetAwaiter().GetResult()` in runtime paths.
- Avoid N+1 DB/HTTP patterns and unnecessary serialization/parsing churn.
- Set outbound timeouts and use bounded retries with jitter when appropriate.

### Reliability

- Handle failures at the correct boundary and log once.
- Propagate `CancellationToken` where appropriate.
- Dispose resources with `using` or `await using`.
- Consider concurrency, idempotency, poison messages, and partial failure behavior.

### Data Integrity

- Never assume table names, columns, types, or nullability.
- Verify schema via migrations, DDL, or `information_schema`.
- Keep migrations safe and non-destructive unless explicitly approved.
- Flag ambiguous schema or contract details instead of guessing.

### Observability

- Prefer structured logs.
- Log enough context to debug, but never secrets or sensitive user data.
- Add metrics or tracing only where the change introduces a meaningful new path or risk.

### Maintainability

- Keep methods focused and names specific.
- Remove dead code and unused dependencies.
- Prefer strongly typed options/config over stringly typed lookups.
- Avoid broad refactors unless they clearly reduce risk or complexity for the change.
- Extract meaningful magic strings/numbers to named constants when they carry business meaning.
- Prefer shallow nesting, clear guard clauses, and small units that are easy to reason about.

## Documentation Drift Pass

After any .NET-related code/test/config/doc change:

- Check whether APIs, DTOs, config keys, schema assumptions, or runbooks changed.
- Search for changed names or contracts and keep docs consistent.
- If code and docs disagree, do not guess the intended source of truth; surface the conflict.

## Verification

Run the smallest relevant set:

- `dotnet build -c Release`
- `dotnet test -v minimal`
- Targeted project/test commands when they cover the changed area better

For DB-related work, verify schema from repo artifacts before changing code.

## Dependency and Tooling Discipline

- Prefer built-in platform/framework features before adding packages.
- Before adding a dependency, check maintenance, security posture, and ecosystem fit.
- Keep dependency versions deliberate and avoid overly broad version ranges.
- Follow the repo formatter/lint setup instead of introducing one-off style choices.

## Decision Standard

Favor the most direct solution that is correct, testable, and easy to reason about. Prefer clear control flow, small focused changes, and explicit tradeoff callouts over cleverness.
