---
name: senior-flutter-engineer
description: Senior workflow for Flutter mobile work in this repo. Use when editing havey-customer, havey-driver, mobile compliance, platform channels, or mobile docs/config.
---

# Senior Flutter Engineer

Use this skill for Flutter/Dart work in the Havey mobile apps. Stay diff-first and preserve existing behavior unless the user asked for a change.

## Quick Start

1. Confirm scope from the actual diff and touched files.
2. Identify whether the change affects customer app, driver app, or shared mobile compliance.
3. Make the smallest correct change.
4. Run the smallest verification set that gives confidence.
5. Do a documentation drift pass before finishing.

## Load Deeper Docs When Needed

- Flutter/mobile standards: `docs/BestPractices/flutter-mobile.md`
- Mobile compliance and store rules: `apps/mobile/compliance/README.md`
- Mobile engineer runbook: `docs/development/mobile-engineer-runbook.md`
- Product requirements: `docs/product/PRD-havey-platform.md`
- Restricted categories (alcohol, pharmacy): `docs/contracts/restricted-category-policy.md`
- Backend/API contracts: `.cursor/skills/senior-dotnet-engineer/SKILL.md`

## Core Defaults

- Keep customer and driver app responsibilities separate.
- Treat location, notifications, payments, auth, and restricted-category flows as high-risk.
- Follow platform store compliance before adding permissions, SDKs, tracking, or payments.
- Prefer clear widget boundaries and testable state management over large monolithic screens.

## Review Checklist

- Does the change follow `docs/BestPractices/flutter-mobile.md`?
- If permissions, SDKs, analytics, auth, payments, or restricted categories changed, was compliance reviewed?
- Are async flows, error states, and offline/poor-network behavior handled?
- Are secrets, tokens, and PII kept out of logs and local storage?
- Do platform-specific files (Android/iOS) stay aligned with the Dart change?

## Verification

Run the smallest relevant set:

- `flutter analyze`
- Targeted widget/unit tests for the changed area
- Platform build checks only when the change is broad or platform-specific

## Documentation Drift Pass

After any mobile code/test/config/doc change:

- Check compliance docs, privacy disclosures, and store metadata when behavior or SDK usage changed.
- Search for changed route names, env keys, and API contracts and keep docs consistent.
- If docs and code disagree, surface the conflict instead of guessing.

## Decision Standard

Favor the most direct solution that is correct, testable, and easy to reason about. Prefer small focused widgets and explicit platform boundaries over clever abstractions.
