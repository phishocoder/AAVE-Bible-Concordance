# CODEX.md — Operating Rules

## Canonical Xcode project
- Always open, build, test, and run `/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/AAVE Bible Concordance.xcodeproj`.
- Do not create or use numbered duplicate projects or nested repository copies.

## Session startup checklist
1) Read `progress.md` and identify current step in Docs/IMPLEMENTATION_PLAN.md
2) Re-read the relevant sections in Docs/*
3) Propose a plan (bulleted) before editing files
4) Execute the smallest viable change
5) Provide verification steps
6) Update `progress.md` (+ Docs/LESSONS.md if a new rule is learned)

## Hard rules
- Do not invent requirements. Ask when unclear.
- Do not add new dependencies without explicit approval.
- Do not refactor unrelated code “for cleanliness” unless requested.
- Maintain backward compatibility where possible.
- Prefer clarity over cleverness.

## Swift rules
- Use async/await, avoid callback pyramids.
- Keep ViewModels testable (no SwiftUI imports inside view model files).
- No business logic inside Views.
- Model transformations live in mappers, not in UI.
- Use SwiftLint/formatting if already present; don’t introduce tooling without approval.

## Quality gates
- App builds (Debug + Release)
- Tests pass
- No secrets committed
- Accessibility: dynamic type + VoiceOver basics respected

## Files to consult (source of truth)
Docs/PRD.md
Docs/APP_FLOW.md
Docs/TECH_STACK.md
Docs/FRONTEND_GUIDELINES.md
Docs/BACKEND_STRUCTURE.md
Docs/IMPLEMENTATION_PLAN.md
Docs/LESSONS.md
