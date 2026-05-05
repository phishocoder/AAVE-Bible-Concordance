# 13-inch iPad Screenshot Upload Notes

## Recommended upload
Upload this file to App Store Connect for the `13-inch iPad` screenshot requirement:

- [ipad13-home-portrait-2048x2732.png](/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/AppStoreAssets/iPad13/ipad13-home-portrait-2048x2732.png)

## What it shows
- Main `Home` experience
- Daily verse / study entry point
- Reading streak and discovery cards
- Real in-app UI captured from the iPad Pro 13-inch simulator

## Capture source
- Simulator device: `iPad Pro 13-inch (M5)`
- Orientation: portrait
- Native capture was trimmed to Apple-friendly upload size: `2048 × 2732`

## Alternate source kept for reference
- [ipad13-home-portrait.png](/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/AppStoreAssets/iPad13/ipad13-home-portrait.png)
  Native simulator export before crop

## If you want to recapture manually later
1. Open the project in Xcode.
2. Select scheme `AAVE Bible Concordance`.
3. Run on simulator `iPad Pro 13-inch (M5)`.
4. Dismiss any first-launch notification prompt.
5. Skip onboarding if it covers the home screen.
6. Stop on the `Home` tab with the `For You Today` card visible.
7. In Terminal, run:
```bash
xcrun simctl io C3EE4831-6543-4CF9-9CED-D54D31F1FD33 screenshot /tmp/aave-ipad13.png
```
8. Crop or resize to `2048 × 2732` if App Store Connect rejects the native export.
