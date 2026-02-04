# IMPLEMENTATION_PLAN — Incremental Build Steps

1. Repo hygiene
  1.1 Add Docs/ and root rules (CODEX.md, progress.md)
  1.2 Ensure .gitignore covers secrets + DerivedData
  1.3 Add basic CI build step (optional)

2. Data layer
  2.1 Define models (Book/Chapter/Verse/Commentary)
  2.2 Implement repository interfaces
  2.3 Add sample data loader and caching

3. Reader
  3.1 Reader screen layout (per guidelines)
  3.2 Verse rendering component
  3.3 Navigation between chapters

4. Commentary
  4.1 Commentary screen
  4.2 Link commentary ranges to verses
  4.3 Takeaways section (no emojis)

5. Search
  5.1 Basic search UI
  5.2 Search across verse text
  5.3 Open result → reader scroll to verse

6. Bookmarks
  6.1 Bookmark toggle UI
  6.2 Bookmarks list
  6.3 Delete/manage

7. Polish + release readiness
  7.1 Accessibility pass
  7.2 Performance pass
  7.3 Crash logging (if used)

## Notes
- Expand each step into smaller tasks before implementation.
- Document decisions and rules learned in Docs/LESSONS.md.
