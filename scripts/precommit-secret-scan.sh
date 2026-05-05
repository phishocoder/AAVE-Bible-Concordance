#!/usr/bin/env bash
set -euo pipefail
echo "Running lightweight secret scan…"
if git diff --cached --name-only | grep -E '(GoogleService-Info\.plist)' >/dev/null; then
  echo "❌ Blocked: Attempt to commit GoogleService-Info.plist"
  exit 1
fi
echo "✅ No blocked files in commit."
