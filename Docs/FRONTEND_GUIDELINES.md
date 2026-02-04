# FRONTEND_GUIDELINES — UI System & Rules

## Design principles
- Warm, optimistic, culturally fluent
- High contrast and clear hierarchy for readability
- Friendly but reverent tone

## Typography (launch screen font is preferred)
Font family: **SF Pro Rounded** (system rounded) across UI.

### Typography tokens
| Token | SwiftUI | Usage |
| --- | --- | --- |
| `AAVETypography.logo` | `Font.system(size: 72, weight: .bold, design: .rounded)` | Launch logo / brand wordmark |
| `AAVETypography.launchSubtitle` | `Font.system(size: 22, weight: .semibold, design: .rounded)` | Launch subtitle |
| `AAVETypography.tagline` | `Font.system(.title3, design: .rounded).weight(.semibold)` | Taglines |
| `AAVETypography.sectionTitle` | `Font.system(.headline, design: .rounded).weight(.semibold)` | Section headers |
| `AAVETypography.button` | `Font.system(.headline, design: .rounded).weight(.medium)` | Buttons |
| `AAVETypography.body` | `Font.system(.body, design: .rounded)` | Body copy |
| `AAVETypography.caption` | `Font.system(.caption, design: .rounded)` | Helper text / metadata |
| `AAVETypography.toolIcon` | `Font.system(size: 22, weight: .semibold)` | Tool buttons |
| `AAVETypography.toolbarIcon` | `Font.system(size: 19, weight: .semibold)` | Bottom toolbar icons |
| `AAVETypography.chapterNumber` | `Font.system(.headline)` | Chapter numbers |

## Spacing
- Scale: 4 / 8 / 12 / 16 / 24 / 32 / 48

## Color system (derived from app icon)
> Source image: `/Users/philshobo/Downloads/aave_icon_default.png`

### Brand gradient (background)
- Gradient start: **#D03110** (deep red-orange)
- Gradient mid: **#F2AA19** (warm gold)
- Gradient end: **#1D772C** (deep green)

### Core palette
| Token | Hex | Usage |
| --- | --- | --- |
| `AAVEColors.brandRed` | **#D03110** | Gradient start, alerts |
| `AAVEColors.brandGold` | **#F2AA19** | Primary accent |
| `AAVEColors.brandOrange` | **#E95D19** | Secondary accent |
| `AAVEColors.brandGreen` | **#1D772C** | Success / positive |
| `AAVEColors.brandOlive` | **#9EA823** | Supporting accent |
| `AAVEColors.brandBrown` | **#4B2410** | Text / ink |
| `AAVEColors.paper` | **#FDFBF8** | Surfaces / cards |
| `AAVEColors.surface` | Asset: `PrimaryBackground` | Primary surface (light/dark adaptive) |
| `AAVEColors.surfaceSecondary` | Asset: `SecondaryBackground` | Secondary surface (light/dark adaptive) |
| `AAVEColors.textPrimary` | Asset: `TextColor` | Primary text (light/dark adaptive) |

### Usage guidance
- Backgrounds: use the warm gradient or Off-White (#FDFBF8)
- Primary actions: Primary Gold (#F2AA19) on Deep Brown (#4B2410) text
- Secondary actions: Secondary Orange (#E95D19)
- Success/positive: Leaf Green (#1D772C)
- Text/ink: Deep Brown (#4B2410)
- Surfaces/cards: Off-White (#FDFBF8) with subtle shadows

## Components (token usage)
| Component | Typography | Color tokens |
| --- | --- | --- |
| Primary button | `AAVETypography.button` | Background `AAVEColors.brandGold`, text `AAVEColors.textOnBrand` |
| Secondary button | `AAVETypography.button` | Background `AAVEColors.brandOrange`, text `AAVEColors.textOnBrand` |
| Toolbar buttons | `AAVETypography.toolbarIcon` | Icon `AAVEColors.textPrimary` |
| Tool tiles | `AAVETypography.toolIcon`, `AAVETypography.caption` | Surface `AAVEColors.surface`, icon `AAVEColors.accent` when active |
| Chapter pills | `AAVETypography.chapterNumber`, `AAVETypography.caption` | Stroke `AAVEColors.accent`, fill `AAVEColors.accent.opacity(0.12)` |
| Verse cards | `AAVETypography.body` | Surface `AAVEColors.surfaceSecondary`, text `AAVEColors.textPrimary` |

## Accessibility
- Dynamic Type: required
- Contrast: ensure minimum WCAG AA for text
- Tap targets: TBD
- VoiceOver labels: required

## Motion
- Subtle micro-interactions only (haptics, transitions)

## Platform notes (TBD)
- iOS-specific UI rules:
- Android-specific UI rules:
