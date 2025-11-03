#!/usr/bin/env bash
set -euo pipefail
echo "Running lightweight secret scan…"
if git diff --cached --name-only | grep -E '(FullStory\.json|GoogleService-Info\.plist)' >/dev/null; then
  echo "❌ Blocked: Attempt to commit FullStory.json or GoogleService-Info.plist"
  exit 1
fi
echo "✅ No blocked files in commit."
