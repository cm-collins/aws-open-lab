---
name: senior-frontend-engineer
description: Senior workflow for Next.js, React, shadcn/ui, Tailwind, and frontend architecture in this repo. Use when editing app routes, layouts, components, styling, client/server boundaries, frontend tests, or frontend docs/config.
---

# Senior Frontend Engineer

Use this skill for Next.js/frontend work in this repo. Keep this file lightweight: route agents to the right source-of-truth docs, then apply a short review checklist.

## Quick Start

1. Confirm scope from the actual diff and touched files.
2. Follow the repo's Next.js App Router and server-first patterns.
3. Make the smallest correct change.
4. Verify with the smallest useful frontend checks.
5. Do a documentation drift pass before finishing.

## Load Deeper Docs When Needed

- Next.js/App Router/React changes: `docs/BestPractices/nextjs-frontend.md`
- Supabase auth, SSR, RLS, Data API, or Postgres-backed frontend work: `docs/BestPractices/supabase-postgresql.md`
- Data architecture: `docs/architecture/data.md`
- Frontend changes touching .NET APIs/contracts: `.cursor/skills/senior-dotnet-engineer/SKILL.md`

## Core Defaults

- Use Next.js App Router only. Do not add `pages/` routes.
- Default to Server Components; add `"use client"` only when the component truly needs browser-only behavior or local interactivity.
- Keep server/client boundaries explicit. Never leak server-only modules, secrets, privileged clients, or sensitive data into client bundles.
- Treat auth, caching, Server Actions, and Supabase integration as high-risk areas that require loading the deeper docs.
- Prefer accessible, semantic, typed, server-first code that is easy to reason about.
- Search official shadcn/ui components and blocks first before building custom UI.

## Review Checklist

- Did the change follow `docs/BestPractices/nextjs-frontend.md` for routing, Server Components, caching, Server Actions, metadata, images, and a11y?
- If Supabase or Postgres is involved, did it follow `docs/BestPractices/supabase-postgresql.md`?
- Are user-specific/auth-dependent paths dynamic or explicitly uncached?
- Are Server Actions and Route Handlers validating authentication, authorization, and input server-side?
- Are Client Components minimal, with no server-only imports or secrets?
- Are names, components, and files focused enough to maintain?

## Verification

Run the smallest relevant set for the touched frontend area:

- `pnpm lint`
- `pnpm test` or targeted test commands when tests exist
- `pnpm build` when the change is broad, risky, or affects routing/config

Pass an app name to target one web app, for example `pnpm lint -- havey-business`.

Also check IDE diagnostics for recently edited files and fix any introduced lint/type issues.

## Documentation Drift Pass

After any frontend code/test/config/doc change:

- Check for drift in route behavior, props/contracts, config keys, env vars, auth flows, caching semantics, and user-facing copy.
- Search for changed names or exported symbols and keep docs/examples consistent.
- If docs and code disagree, surface the conflict instead of guessing.

## Dependency and Tooling Discipline

- Prefer built-in platform/framework features before adding packages.
- Use native `fetch` and `URLSearchParams` unless an existing dependency is already the clear standard.
- Before adding a dependency, check maintenance, TypeScript support, security posture, and likely bundle cost.
- Keep React hooks lint rules enabled; fix warnings rather than suppressing them.
- Follow the repo formatter instead of introducing one-off style choices.
- Use a lockfile and avoid overly broad dependency ranges.

## Observability

- Prefer a shared logging wrapper over scattered `console.*` usage when the repo provides one.
- Log errors once at the right boundary.
- Never log secrets, tokens, cookies, passwords, or payment details.
- Hook new critical frontend/server-action error paths into the repo's error tracking approach when one exists.

## Decision Standard

Favor the most direct solution that matches repo conventions: server-first, accessible, typed, testable, and easy to reason about. Prefer explicit boundaries and small focused components over clever frontend patterns.
