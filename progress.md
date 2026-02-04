# progress.md

## Current focus
- Step: 1.2 from Docs/IMPLEMENTATION_PLAN.md
- Goal: Ship social-lite achievements + leaderboard display names.

## Completed
- 2026-02-04: Added Home achievements summary card + perfect-score achievement.
- 2026-02-04: Updated leaderboard display names via users collection + cache.
- 2026-02-04: Added profile display name save to Firestore.

## In progress
- Add optional achievements empty-state CTA tuning (if needed).

## Next up
- Expand achievements summary styling and add analytics if desired.

## Known bugs / tech debt
- UsernamePromptView still exists but is no longer primary for display name.

## Notes for future sessions
- Consider migrating leaderboard to async/await Firestore once stable.
