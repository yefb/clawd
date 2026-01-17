# GardenOS - Plant Care Journal App

## Project Status (Jan 2026)
- **Repo:** github.com/yefb/gardenos-ios (private)
- **Estado:** Beta ready, esperando aprobación de Apple para WeatherKit
- **Última actividad:** 7 de enero 2026
- **Target lanzamiento:** Early 2026

## Tech Stack
- **Language:** Swift 5.9+
- **UI:** SwiftUI (100%, no UIKit)
- **Data:** SwiftData
- **Cloud:** CloudKit (Pro tier)
- **Payments:** StoreKit 2
- **Target:** iOS 17+ (iPhone only v1)
- **Philosophy:** Zero third-party dependencies, all native

## Business Model
- **Free Tier:** Up to 3 plants, local-only storage
- **Pro Tier:** Unlimited plants, iCloud sync, advanced features
- **Pricing:** $2.99/month or $29/year (7-day trial)
- **Philosophy:** Paid sustainable model from day 1

## Core Features (Implemented)
✅ Plant profiles with photos & metadata
✅ Journal entries (notes, watering, fertilizing, repotting, etc.)
✅ Care schedules with streaks
✅ Celebration overlays for milestones
✅ Slide-in animations
✅ Adaptive photo sizing
✅ Auto-metadata time context
✅ Hold-to-complete buttons
✅ Tap-to-enrich entries
✅ Dark mode + accessibility (VoiceOver, Dynamic Type)

## Weather Integration (Pending Approval)
- **Choice:** WeatherKit (Apple native)
- **Rationale:** 
  - No API keys in bundle (privacy-first)
  - 500K calls/month free
  - Native Swift integration
  - Security >> convenience
- **Data captured:** Temp, humidity, UV index, conditions, precipitation
- **Storage:** Denormalized with each care log for offline access

## Sprint History
**Jan 5, 2026** - Massive feature sprint (10 PRs merged):
- #17: Celebration milestones
- #16: Entry animations
- #15: Adaptive photo sizing
- #14: Auto-metadata time context
- #13: Hold-to-complete buttons
- #12: Streak display
- #11: Tap-to-enrich
- #10: Unified card structure
- #9: Enhanced care icons
- #8: Completion animations

**Jan 7, 2026:**
- Localization fixes (time context, overdue labels)

## Philosophy
"Micro.blog for plants" - No algorithms, no vanity metrics
- Privacy-first (no tracking, no ads)
- Chronological timeline
- Native iOS experience
- Serious tool for serious users
- Inspired by: Bear, OmniGroup, DEVONtechnologies

## Roadmap
- [x] Core journal + care features
- [x] Streaks & celebrations
- [x] Animations & polish
- [ ] WeatherKit approval ← CURRENT BLOCKER
- [ ] Beta on TestFlight
- [ ] App Store submission
- [ ] Early 2026 launch

## Landing Page
- Public repo: github.com/yefb/gardenos-landing
- Live: gardenos.app (presumably)

## Related
Part of Hayeshi software company (hayeshi.com)
