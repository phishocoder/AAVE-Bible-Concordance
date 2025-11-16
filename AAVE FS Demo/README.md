# AAVE FS Demo

This target demonstrates the FullStory iOS SDK (v1.65.x) using the CLI-driven configuration flow.

## FullStory Org ID
- `o-242815-na1`

## CLI binary location
Place the FullStory command-line tool at:
```
Tools/FullStoryCommandLine
```

## One-time setup
```bash
chmod +x Tools/FullStoryCommandLine
Tools/FullStoryCommandLine configure \
  --orgId o-242815-na1 \
  --output "AAVE FS Demo/FullStory.json"
```

The configure step writes `FullStory.json`, which is bundled at build time to carry Org ID and SwiftUI settings.

## Build phase
A Run Script build phase named **FullStory CLI Build** runs before "Compile Sources". Script contents:
```sh
set -euo pipefail

FS_CLI="${SRCROOT}/Tools/FullStoryCommandLine"
FS_CONFIG="${SRCROOT}/AAVE FS Demo/FullStory.json"
FS_OUTPUT="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/FullStory.json"

if [ -x "$FS_CLI" ] && [ -f "$FS_CONFIG" ]; then
  "$FS_CLI" build --config "$FS_CONFIG" --output "$FS_OUTPUT"
  echo "✅ FullStory CLI build complete: $FS_OUTPUT"
else
  echo "⚠️  Missing CLI or config:"
  echo "   $FS_CLI"
  echo "   $FS_CONFIG"
  # Do not hard-fail during local iteration; warn instead:
  # exit 1
fi
```

## Running the demo
- Select the **AAVE FS Demo** scheme in Xcode.
- Build and run on a simulator or device.

## Verifying capture
- Open FullStory → **Captured Events / Session Replay** to confirm sessions appear for Org `o-242815-na1`.

