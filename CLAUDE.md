# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Setlist Metronome** — an iOS SwiftUI app that combines a BPM metronome with setlist management. Musicians can create setlists of songs (each with a name and BPM), then tap through them in the Metronome tab.

## Build & Test Commands

Build via Xcode or `xcodebuild`:

```bash
# Build for simulator
xcodebuild -project "Setlist Metronome.xcodeproj" -scheme swift_metronome \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild test -project "Setlist Metronome.xcodeproj" -scheme swift_metronome \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

The test target uses Swift Testing (`import Testing` with `#expect(...)` macros), not XCTest.

## Architecture

### Navigation
`RootView` uses a `TabView` with `.page` style (horizontal swipe, no visible tab bar). Tab indices:
- `0` — `SettingsView` (swipe left from Metronome)
- `1` — `MetronomeView` (default/launch tab)
- `2` — `SetlistView` (swipe right from Metronome)

### State Management
`AppState` is an `@Observable` class injected at the app root via `.environment(AppState())`. Views access it with `@Environment(AppState.self)`. It holds:
- `activeSetlist: Setlist?` — which setlist is currently selected (nil = show all standalone tempos)
- `selectedAccentPattern: AccentPattern` — time signature for accent beats (2/4–7/4, or none)
- `selectedClickSound: ClickSound` — classic/soft/sharp

### Audio
`SynthMetronome` is a singleton (`SynthMetronome.shared`) that synthesizes metronome clicks using `AVAudioEngine` + `AVAudioPlayerNode`. It pre-generates PCM buffers for tap/accent sounds across all three `ClickStyle` variants at init time. No audio files are used — all sounds are synthesized sine waves. The audio session uses `.playback` category with `.mixWithOthers`.

### Data Layer (SwiftData)
Three models registered in the `ModelContainer` schema:
- `Setlist` — name + array of `Tempo` objects
- `Tempo` — name, bpm, order (Int for sort position), optional `setlist` relationship
- `Item` — legacy scaffold model (unused, kept in schema to avoid migration issues)

`Tempo.order` is the sort key within a setlist. When reordering, all affected `Tempo.order` values are updated manually.

When `appState.activeSetlist == nil`, `MetronomeView` displays all `Tempo` records where `setlist == nil` (standalone tempos not in any setlist).

### Key Patterns
- SwiftData queries use `@Query` in views; filtering by setlist happens in computed properties since `@Query` predicates on relationships have limitations.
- `AppState.ClickSound` maps to `SynthMetronome.ClickStyle` via an extension in `AppState.swift`.
- `MetronomeView` disables the idle timer (`UIApplication.shared.isIdleTimerDisabled = true`) while active.
- Tap tempo averages up to the last 5 intervals, resets if gap > 2 seconds, clamps BPM to 40–240.
